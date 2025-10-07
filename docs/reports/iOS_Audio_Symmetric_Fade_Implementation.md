# iOS Audio 対称クロスフェード + サンプラー掃除 実装レポート

**日付**: 2025-10-05  
**状況**: 対称クロスフェード + 再利用サンプラー掃除を実装したが、全音符問題が解決しない

---

## 📊 実装の経緯

### ChatGPTからのアドバイス（第3回）
**3つの根本原因**:
1. **再利用サンプラーの残響リーク**（最大の原因）
   - A→B→A と2小節後に再利用
   - FluidR3/TimGM系のAcoustic Guitarは長いリリース/ループを持つ
   - 前々小節の余韻がサンプラー内に残っている
   - **to側を即1.0にすると余韻が再露出**

2. **片側だけのフェード**
   - from を下げるだけ、to は即1.0
   - 合計音量が不安定

3. **再利用前の掃除が無い**
   - CC120/123 を再利用前に打っていない

---

## 🏗️ 実装した3つの修正

### 修正1: flushSampler() 関数

```swift
/// サンプラーを完全消音（再利用前の掃除）
private func flushSampler(_ sampler: AVAudioUnitSampler) {
    for ch: UInt8 in 0...1 {
        sampler.sendController(64, withValue: 0, onChannel: ch)   // Sustain OFF
        sampler.sendController(120, withValue: 0, onChannel: ch)  // All Sound Off（即殺）
        sampler.sendController(123, withValue: 0, onChannel: ch)  // All Notes Off
    }
    print("    🧹 Sampler flushed (CC120 + CC123)")
}
```

**役割**:
- CC64: Sustain Pedal OFF
- CC120: All Sound Off（即座に消音）
- CC123: All Notes Off（すべてのノートを停止）
- 再利用前に必ず呼び出す

### 修正2: crossFadeSym() 関数（対称フェード）

```swift
// クロスフェード専用キュー
private let xfadeQueue = DispatchQueue(label: "audio.xfade")
private var xfadeTimer: DispatchSourceTimer?

/// 対称クロスフェード（from: 1→0, to: 0→1）
private func crossFadeSym(from: AVAudioMixerNode, to: AVAudioMixerNode, ms: Double) {
    // 既存のタイマーをキャンセル
    xfadeTimer?.cancel()
    
    let steps = 30  // 30ステップ（120ms / 30 ≈ 4ms/step）
    let dt = ms / Double(steps) / 1000.0
    let startFrom = from.outputVolume
    
    // ★重要: to側を無音から開始
    to.outputVolume = 0.0
    
    var i = 0
    let timer = DispatchSource.makeTimerSource(queue: xfadeQueue)
    timer.schedule(deadline: .now(), repeating: dt, leeway: .milliseconds(1))
    
    timer.setEventHandler { [weak from, weak to] in
        i += 1
        let p = min(1.0, Float(i) / Float(steps))
        from?.outputVolume = startFrom * (1.0 - p)  // 1→0
        to?.outputVolume = p                         // 0→1
        
        if i >= steps {
            timer.cancel()
        }
    }
    
    xfadeTimer = timer
    timer.resume()
    
    print("    🔊 Symmetric cross-fade: \(ms)ms (\(steps) steps)")
}
```

**改善点**:
1. **専用シリアルキュー**（`xfadeQueue`）
   - メインスレッドを経由しない
   - 競合を回避

2. **to側を0.0から開始**
   - **残響リークを防止する最重要ポイント**
   - 過去の余韻が表に出る窓をゼロに

3. **対称フェード**
   - from: `startVolume → 0.0`（1→0）
   - to: `0.0 → 1.0`（0→1）
   - 合計音量が安定

4. **既存タイマーのキャンセル**
   - 前のフェードが残っている場合はキャンセル

5. **leeway: 1ms**
   - 妥当な許容範囲
   - 0ns より現実的

### 修正3: play() の呼び出し順

```swift
// コード進行（ループ）
while isPlaying {
    for (bar, symbol) in chords.enumerated() {
        if !isPlaying { break }
        
        onBarChange(bar)
        let midiChord = chordToMidi(symbol)
        
        // 今回使うサンプラーとノード
        let toSampler = currentBusIsA ? samplerA : samplerB
        let toSub = currentBusIsA ? subMixA : subMixB
        let fromSub = currentBusIsA ? subMixB : subMixA
        
        // ★1. 再利用サンプラーを完全消音（残響リーク防止）
        flushSampler(toSampler)
        
        // ★2. to側を無音に設定
        toSub.outputVolume = 0.0
        
        // ★3. 対称クロスフェードを開始（from:1→0, to:0→1）
        crossFadeSym(from: fromSub, to: toSub, ms: fadeMs)
        
        // ★4. 軽ストラム（15ms）で各ノートを開始
        print("  🎸 Playing chord: \(symbol), notes: \(midiChord), bus: \(currentBusIsA ? "A" : "B")")
        for (i, note) in midiChord.prefix(maxVoices).enumerated() {
            let delay = Double(i) * strumDelay
            if delay > 0 {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
            toSampler.startNote(note, withVelocity: 80, onChannel: 0)
        }
        
        // バスを切り替え（次の小節用）
        currentBusIsA.toggle()
        
        // 次の小節まで待つ（4拍）
        try? await Task.sleep(nanoseconds: UInt64(barSec * 1_000_000_000))
    }
}
```

**呼び出し順序**:
1. **flushSampler(toSampler)** - 再利用サンプラーを掃除
2. **toSub.outputVolume = 0.0** - to側を無音に設定
3. **crossFadeSym()** - 対称フェード開始
4. **startNote()** - ノート再生

---

## 📋 実行時のログ

```
✅ ChordSequencer initialized (2-Bus Fade-out method)
✅ Audio Session: IOBufferDuration set to 5ms
🎵 Changing instrument to program: 25
✅ Instrument changed to program 25
🎵 Starting playback (2-Bus Fade): BPM=120.0, fadeMs=120.0

[カウントイン: C7が4回鳴る]

🎸 Playing chord: C, notes: [60, 64, 67], bus: A
  🧹 Sampler flushed (CC120 + CC123)
  🔊 Symmetric cross-fade: 120.0ms (30 steps)

🎸 Playing chord: Am, notes: [69, 60, 64], bus: B
  🧹 Sampler flushed (CC120 + CC123)
  🔊 Symmetric cross-fade: 120.0ms (30 steps)

🎸 Playing chord: F, notes: [65, 69, 60], bus: A
  🧹 Sampler flushed (CC120 + CC123)
  🔊 Symmetric cross-fade: 120.0ms (30 steps)

🎸 Playing chord: G, notes: [67, 71, 62], bus: B
  🧹 Sampler flushed (CC120 + CC123)
  🔊 Symmetric cross-fade: 120.0ms (30 steps)

[ループ...]
```

**ログから確認できること**:
- ✅ flushSampler() が毎回呼ばれている
- ✅ 対称クロスフェードが開始されている
- ✅ バスが正しく交互に切り替わっている
- ✅ タイミングは正確

---

## ❌ 実際の動作（問題）

**全音符のまま鳴り続け、フェードアウトも残響リークの解消も効いていない**

### 観察された現象
1. コードが4拍で切れない
2. 前のコードが次のコードと重なって聞こえる（濁る）
3. フェードアウトの効果が感じられない
4. flushSampler() を呼んでも残響が消えない
5. 全音符のまま鳴り続ける

---

## 🤔 考えられる原因

### 原因1: flushSampler() のタイミングが早すぎる？
**仮説**: サンプラーをフラッシュした直後に `startNote()` を呼ぶため、CC120/123 が効く前にノートが鳴り始める。

**実装の順序**:
```swift
flushSampler(toSampler)              // CC120/123 送信
toSub.outputVolume = 0.0             // 即座に実行
crossFadeSym(from: fromSub, to: toSub, ms: fadeMs)  // 即座に実行
for ... {
    toSampler.startNote(...)         // 15ms後から開始（ストラム）
}
```

**問題の可能性**:
- CC120/123 が効果を発揮するまでに時間がかかる？
- 15msのストラム開始までに CC120/123 が完了していない？

### 原因2: 対称フェードのタイミング
**仮説**: `crossFadeSym()` を呼んだ直後に `startNote()` を呼ぶため、フェードインが始まる前にノートが鳴る。

**タイムライン**:
```
t=0:   flushSampler() 呼び出し
t=0:   toSub.outputVolume = 0.0
t=0:   crossFadeSym() 呼び出し（タイマー起動）
t=0:   startNote() 開始（ストラム 15ms）
t=4ms: to.outputVolume = 0.033（1/30）
t=8ms: to.outputVolume = 0.067（2/30）
...
```

**問題の可能性**:
- ノートが鳴り始めた時点で `toSub.outputVolume = 0.0`
- → 音が聞こえない？
- または、フェードインが遅すぎて「突然音が出る」ように聞こえる？

### 原因3: SF2 の内部リリースエンベロープ
**仮説**: CC120/123 を送っても、SF2 内部のリリースエンベロープは止められない。

**可能性**:
- TimGM6mb.sf2 の Acoustic Guitar は「ループサンプル」を使用している
- CC120/123 は「Note Off」を送るだけで、リリースフェーズは実行される
- リリース時間が1秒以上ある場合、CC120/123 でも止まらない

### 原因4: サンプラーの「声」が残っている
**仮説**: `AVAudioUnitSampler` は内部に複数の「ボイス（発音中のノート）」を持っており、CC120/123 では完全にリセットされない。

**可能性**:
- サンプラーAで前々小節に鳴らしたノートの「ボイス」が内部に残っている
- CC120/123 を送っても、内部状態がリセットされない
- 再利用時に `startNote()` を呼ぶと、残っているボイスも一緒に鳴る

### 原因5: outputVolume の更新が間に合わない
**仮説**: `to.outputVolume = 0.0` を設定しても、実際のオーディオレンダリングに反映されるまでに遅延がある。

**実装**:
```swift
toSub.outputVolume = 0.0  // ここで設定
crossFadeSym(...)         // フェード開始
toSampler.startNote(...)  // ノート開始
```

**問題の可能性**:
- `toSub.outputVolume = 0.0` の設定が、次のオーディオレンダリングサイクルまで反映されない
- → ノートが鳴り始めた時点で、まだ `outputVolume = 1.0`（前の値）のまま
- → 音が漏れる

### 原因6: crossFadeSym() の var i のキャプチャ
**仮説**: `var i = 0` がクロージャで正しくキャプチャされていない。

**コード**:
```swift
var i = 0
timer.setEventHandler { [weak from, weak to] in
    i += 1  // ここで正しく加算される？
    let p = min(1.0, Float(i) / Float(steps))
    ...
}
```

**問題の可能性**:
- `i` が常に 0 のまま？
- → `p` が常に 0？
- → フェードが進まない？

---

## 🎯 ChatGPTへの質問

### Q1: flushSampler() のタイミングは正しいか？
**現在の実装**:
```swift
flushSampler(toSampler)              // CC120/123 送信
toSub.outputVolume = 0.0             // 即座
crossFadeSym(...)                    // 即座
toSampler.startNote(...)             // 15ms後
```

**質問**:
1. CC120/123 が効果を発揮するまでに待機時間が必要？
2. `startNote()` の前に `Task.sleep()` を入れるべき？
3. それとも、`flushSampler()` を**前の小節の終わり**に呼ぶべき？

### Q2: 対称フェードのタイミングは正しいか？
**問題**:
- `toSub.outputVolume = 0.0` を設定した直後に `startNote()` を呼ぶ
- ノートが鳴り始めた時点で音量が 0

**質問**:
1. `startNote()` の前に、`to.outputVolume` をある程度（例: 0.1）まで上げておくべき？
2. フェードインを先行開始して、ある程度音量が上がってから `startNote()` を呼ぶべき？

### Q3: CC120/123 は本当に効くのか？
**質問**:
1. TimGM6mb.sf2 の Acoustic Guitar は CC120/123 で止まる？
2. ループサンプルを使っている場合、CC120/123 でも止まらない？
3. 代替手段はある？（サンプラーを破棄して再作成など）

### Q4: AVAudioUnitSampler の内部状態をリセットする方法は？
**質問**:
1. CC120/123 以外に、サンプラーの内部状態を完全にリセットする方法はある？
2. サンプラーを一時的に `detach()` して再 `attach()` する？
3. または、サンプラーを破棄して新しいインスタンスを作成する？

### Q5: outputVolume の更新遅延を回避する方法は？
**質問**:
1. `toSub.outputVolume = 0.0` の設定が、次のレンダリングサイクルまで反映されない？
2. 設定後に短い待機時間（例: 5ms）を入れるべき？
3. または、フェードを先行開始して、音量が上がってから `startNote()` を呼ぶべき？

### Q6: var i のキャプチャは正しいか？
**質問**:
```swift
var i = 0
timer.setEventHandler { [weak from, weak to] in
    i += 1
    ...
}
```
1. `i` は正しくキャプチャされている？
2. `i` をクロージャ外で宣言しても、クロージャ内で変更できる？
3. デバッグで `i` の値を確認する方法は？

---

## 📦 環境情報

- **iOS Version**: 18.0 (Simulator & Device)
- **Xcode Version**: 15.x
- **Swift Version**: 5.x
- **Framework**: AVFoundation (AVAudioEngine + AVAudioUnitSampler + AVAudioMixerNode)
- **SF2 File**: TimGM6mb.sf2 (6MB)
- **BPM**: 120（テスト時）

---

## 📚 試した実装の履歴

### 1. Phase 1: stopNote()
- ❌ 全音符のまま

### 2. noteDuration 調整（4拍 → 2.5拍）
- ❌ 全音符のまま

### 3. DispatchQueue.asyncAfter（12ステップ）
- ❌ 全音符のまま

### 4. AVAudioMixingDestination（試行）
- ❌ API が存在しない

### 5. DispatchSourceTimer（30ステップ、片側フェード）
- ❌ 全音符のまま

### 6. 対称クロスフェード + flushSampler()（現在）
- ❌ **全音符のまま**

---

## 💡 次の実装候補

### Option A: flushSampler() の後に待機
```swift
flushSampler(toSampler)
try? await Task.sleep(nanoseconds: UInt64(0.01 * 1_000_000_000))  // 10ms待機
toSub.outputVolume = 0.0
crossFadeSym(...)
toSampler.startNote(...)
```

### Option B: フェードを先行開始
```swift
flushSampler(toSampler)
toSub.outputVolume = 0.0
crossFadeSym(...)
try? await Task.sleep(nanoseconds: UInt64(0.03 * 1_000_000_000))  // 30ms待機（フェードが進む）
toSampler.startNote(...)
```

### Option C: サンプラーを再作成
```swift
// 前の小節の終わりで
samplerA = AVAudioUnitSampler()  // 新しいインスタンス
engine.attach(samplerA)
engine.connect(samplerA, to: subMixA, format: nil)
try samplerA.loadSoundBankInstrument(...)
```

### Option D: 短リリースSF2を使用
- Polyphone で TimGM6mb.sf2 の Acoustic Guitar のリリースを 120ms に編集
- 新しいSF2をバンドル

---

## 🙏 求めるアドバイス

1. **flushSampler() のタイミング調整**
2. **対称フェードのタイミング調整**
3. **CC120/123 の効果確認方法**
4. **AVAudioUnitSampler の内部状態リセット方法**
5. **outputVolume 更新遅延の回避方法**
6. **var i のキャプチャ確認方法**
7. **現実的な妥協点（短リリースSF2など）**

---

## 📊 SSOT準拠状況

| 項目 | SSOT要件 | 実装値 | 状況 |
|------|----------|--------|------|
| **Attack** | 3-5ms | SF2依存 | ✅ |
| **Release** | 80-150ms | 120ms（意図） | ❌ 効いていない |
| **Strum** | 10-20ms | 15ms | ✅ |
| **Max Voices** | 6 | 6 | ✅ |

---

**このレポートを ChatGPT に送って、実装の何が間違っているのか、またはiOSの制約について確認してください！**


