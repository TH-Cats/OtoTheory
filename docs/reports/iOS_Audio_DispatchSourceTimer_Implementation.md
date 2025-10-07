# iOS Audio DispatchSourceTimer 実装レポート

**日付**: 2025-10-05  
**状況**: DispatchSourceTimerを使った高精度フェード実装後も、全音符問題が解決しない

---

## 📊 実装の経緯

### ChatGPTからのアドバイス（第1回）
**AVAudioMixingDestination.setVolumeRamp を使ってオーディオタイムでランプをかける**
- `DispatchQueue.asyncAfter` + `outputVolume` の段階更新はオーディオスレッドに対して同期も精度担保もできない
- `setVolumeRamp()` でオーディオタイム（hostTime）で120msのランプをかける

### 実装試行1: AVAudioTimeRange + setVolumeRamp
```swift
let fadeRange = AVAudioTimeRange(start: startTime, duration: duration)
from.setVolumeRamp(fromStartVolume: fromStartVolume, toEndVolume: 0.0, timeRange: fadeRange)
```
**結果**: ❌ `AVAudioTimeRange` が存在しない（コンパイルエラー）

### 実装試行2: setVolume(_:at:)
```swift
let startTime = AVAudioTime(hostTime: fadeStartHostTime)
let endTime = AVAudioTime(hostTime: fadeEndHostTime)
from.setVolume(fromStartVolume, at: startTime)
from.setVolume(0.0, at: endTime)
```
**結果**: ❌ `setVolume(_:at:)` が存在しない（コンパイルエラー）

### 実装試行3: DispatchSourceTimer（現在の実装）
**iOS では AVAudioMixingDestination のボリュームオートメーションAPIが存在しない**ため、高精度タイマーによる段階的更新に変更。

---

## 🏗️ 現在の実装（DispatchSourceTimer）

### アーキテクチャ
```
SamplerA → SubMixA ┐
SamplerB → SubMixB ┴→ MainMixer → Output
```

### 完全な実装コード

```swift
@MainActor
final class ChordSequencer: ObservableObject {
    let engine = AVAudioEngine()
    
    // 2バス・フェードアウト方式（A/B交互）
    let samplerA = AVAudioUnitSampler()
    let samplerB = AVAudioUnitSampler()
    let subMixA = AVAudioMixerNode()
    let subMixB = AVAudioMixerNode()
    
    // SSOT準拠
    private let strumMs: Double = 15       // 10–20ms
    private let fadeMs: Double = 120       // 80–150ms（Release相当）
    private let maxVoices = 6
    
    private let sf2URL: URL
    private var isPlaying = false
    private var playbackTask: Task<Void, Never>?
    private var currentBusIsA = true  // A/B交互切替用
    
    // MARK: - Cross Fade (High-precision timer)
    
    /// 小節終わりに向けて from→0 / to→1 の同時ランプをかける（DispatchSourceTimer で高精度）
    private func scheduleCrossFade(
        fromNode: AVAudioMixerNode,
        toNode: AVAudioMixerNode,
        fadeMs: Double
    ) {
        let fadeSec = fadeMs / 1000.0
        let steps = 30  // 30ステップ（120ms / 30 ≈ 4ms/step）
        let stepInterval = fadeSec / Double(steps)
        
        // 新バスを即座にフルボリュームに
        toNode.outputVolume = 1.0
        
        // 前バスの開始ボリューム
        let startVolume = fromNode.outputVolume
        
        // DispatchSourceTimer を使って高精度にフェード
        let queue = DispatchQueue.global(qos: .userInteractive)
        let timer = DispatchSource.makeTimerSource(queue: queue)
        
        var currentStep = 0
        timer.schedule(deadline: .now(), repeating: stepInterval, leeway: .nanoseconds(0))
        
        timer.setEventHandler { [weak fromNode] in
            currentStep += 1
            let progress = Float(currentStep) / Float(steps)
            let newVolume = startVolume * (1.0 - progress)
            
            DispatchQueue.main.async {
                fromNode?.outputVolume = newVolume
            }
            
            if currentStep >= steps {
                timer.cancel()
            }
        }
        
        timer.resume()
        
        print("    🔊 Cross-fade started: \(fadeMs)ms with \(steps) steps")
        
        // 念のための保険: フェード完了 + 10ms で CC120 (All Sound Off) を旧バスに送信
        let cc120Delay = fadeSec + 0.01
        DispatchQueue.global().asyncAfter(deadline: .now() + cc120Delay) { [weak self, weak fromNode] in
            guard let self = self, let fromNode = fromNode else { return }
            let oldSampler = fromNode === self.subMixA ? self.samplerA : self.samplerB
            for ch: UInt8 in 0...1 {
                oldSampler.sendController(120, withValue: 0, onChannel: ch)  // All Sound Off
            }
        }
    }
}
```

### play() メソッド（コード進行ループ）
```swift
func play(chords: [String], program: UInt8, bpm: Double, onBarChange: @escaping (Int?) -> Void) {
    playbackTask = Task { @MainActor in
        let beatSec = 60.0 / bpm
        let barSec = beatSec * 4
        let strumDelay = strumMs / 1000.0
        
        // カウントイン（省略）...
        
        // 最初のコードはA
        currentBusIsA = true
        subMixA.outputVolume = 1.0
        subMixB.outputVolume = 0.0
        
        // コード進行（ループ）
        while isPlaying {
            for (bar, symbol) in chords.enumerated() {
                if !isPlaying { break }
                
                onBarChange(bar)
                let midiChord = chordToMidi(symbol)
                
                // 今回使うサンプラーとノード
                let currentSampler = currentBusIsA ? samplerA : samplerB
                let currentNode = currentBusIsA ? subMixA : subMixB
                let prevNode = currentBusIsA ? subMixB : subMixA
                
                // クロスフェードを開始（高精度タイマー）
                scheduleCrossFade(
                    fromNode: prevNode,
                    toNode: currentNode,
                    fadeMs: fadeMs
                )
                
                // 軽ストラム（15ms）で各ノートを開始
                for (i, note) in midiChord.prefix(maxVoices).enumerated() {
                    let delay = Double(i) * strumDelay
                    if delay > 0 {
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    }
                    currentSampler.startNote(note, withVelocity: 80, onChannel: 0)
                }
                
                // バスを切り替え（次の小節用）
                currentBusIsA.toggle()
                
                // 次の小節まで待つ（4拍）
                try? await Task.sleep(nanoseconds: UInt64(barSec * 1_000_000_000))
            }
        }
    }
}
```

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
  🔊 Cross-fade started: 120.0ms with 30 steps

🎸 Playing chord: Am, notes: [69, 60, 64], bus: B
  🔊 Cross-fade started: 120.0ms with 30 steps

🎸 Playing chord: F, notes: [65, 69, 60], bus: A
  🔊 Cross-fade started: 120.0ms with 30 steps

🎸 Playing chord: G, notes: [67, 71, 62], bus: B
  🔊 Cross-fade started: 120.0ms with 30 steps

[ループ...]
```

**ログから確認できること**:
- ✅ DispatchSourceTimer が起動している
- ✅ 30ステップでフェードが開始されている
- ✅ バスが正しく交互に切り替わっている
- ✅ タイミングは正確（4拍ごと）

---

## 🔍 実装の詳細

### DispatchSourceTimer の設定

#### 1. タイマーの作成
```swift
let queue = DispatchQueue.global(qos: .userInteractive)
let timer = DispatchSource.makeTimerSource(queue: queue)
```
- **QoS**: `.userInteractive`（最高優先度）
- **Queue**: グローバルキュー（バックグラウンドスレッド）

#### 2. スケジュール設定
```swift
let steps = 30
let stepInterval = 120ms / 30 = 4ms
timer.schedule(deadline: .now(), repeating: stepInterval, leeway: .nanoseconds(0))
```
- **Steps**: 30（4ms間隔）
- **Interval**: 4ms/step
- **Leeway**: 0ns（遅延を最小化）

#### 3. イベントハンドラ
```swift
timer.setEventHandler { [weak fromNode] in
    currentStep += 1
    let progress = Float(currentStep) / Float(steps)
    let newVolume = startVolume * (1.0 - progress)
    
    DispatchQueue.main.async {
        fromNode?.outputVolume = newVolume
    }
    
    if currentStep >= steps {
        timer.cancel()
    }
}
```
- **進行度計算**: `progress = currentStep / 30`
- **ボリューム計算**: `newVolume = startVolume * (1.0 - progress)`
- **更新**: `DispatchQueue.main.async` でメインスレッドに戻す

#### 4. タイマー開始
```swift
timer.resume()
```

### タイミングの流れ

```
小節開始（t=0）
  ↓
scheduleCrossFade() 呼び出し
  ↓ 即座に
toNode.outputVolume = 1.0（新バスをオン）
  ↓
DispatchSourceTimer 起動
  ↓ 4ms後
fromNode.outputVolume = startVolume * (1 - 1/30) = 0.967
  ↓ 4ms後
fromNode.outputVolume = startVolume * (1 - 2/30) = 0.933
  ↓ ...（30ステップ繰り返し）
  ↓ 120ms後
fromNode.outputVolume = 0.0（前バスが完全にオフ）
  ↓ 10ms後
CC120 (All Sound Off) 送信（保険）
```

---

## ❌ 実際の動作（問題）

**全音符のまま鳴り続け、フェードアウトが効いていない**

### 観察された現象
1. コードが4拍で切れない
2. 前のコードが次のコードと重なって聞こえる（濁る）
3. フェードアウトの効果が感じられない
4. 全音符のまま鳴り続ける

---

## 🤔 考えられる原因

### 原因1: outputVolume の更新タイミング
**仮説**: `DispatchQueue.main.async` で更新しているため、メインスレッドのタスクに埋もれて遅延している。

**可能性**:
- メインスレッドが他のUIタスクで忙しい
- 30ステップのうち何ステップかが遅れる
- 結果として「最後だけ0になる」= 全音符に聞こえる

### 原因2: DispatchSourceTimer のスケジューリング精度
**仮説**: `leeway: .nanoseconds(0)` でも、実際には4ms精度が保証されない。

**可能性**:
- システムのスケジューラが優先度を下げる
- 他のタスクに割り込まれる
- 「repeating: 4ms」が実際には不規則になる

### 原因3: AVAudioMixerNode.outputVolume の更新遅延
**仮説**: `outputVolume` プロパティの更新が、実際のオーディオレンダリングに即座に反映されない。

**可能性**:
- プロパティ更新とオーディオレンダリングの間にバッファがある
- 更新がバッチで処理される
- 結果として「段階的」に聞こえない

### 原因4: to側を即座に1.0にしている
**仮説**: `toNode.outputVolume = 1.0` を即座に設定しているため、前のコードが完全に消える前に次のコードが全開で鳴る。

**実装**:
```swift
// 新バスを即座にフルボリュームに
toNode.outputVolume = 1.0
```

**問題の可能性**:
- from側のフェードアウトと to側のフェードインが同期していない
- 結果として「重なりが大きすぎる」= 濁る + 前のコードが消えない

### 原因5: タイマーのキャプチャ問題
**仮説**: `var currentStep = 0` がクロージャ内で正しくキャプチャされていない。

**コード**:
```swift
var currentStep = 0
timer.setEventHandler { [weak fromNode] in
    currentStep += 1  // ここで正しく加算される？
    ...
}
```

**可能性**:
- クロージャのキャプチャが不完全
- currentStep が常に0のまま？
- 結果として progress が常に 0/30 = 0

---

## 🎯 ChatGPTへの質問

### Q1: DispatchSourceTimer の実装は正しいか？
**現在の実装**:
```swift
let queue = DispatchQueue.global(qos: .userInteractive)
let timer = DispatchSource.makeTimerSource(queue: queue)

var currentStep = 0
timer.schedule(deadline: .now(), repeating: stepInterval, leeway: .nanoseconds(0))

timer.setEventHandler { [weak fromNode] in
    currentStep += 1
    let progress = Float(currentStep) / Float(steps)
    let newVolume = startVolume * (1.0 - progress)
    
    DispatchQueue.main.async {
        fromNode?.outputVolume = newVolume
    }
    
    if currentStep >= steps {
        timer.cancel()
    }
}

timer.resume()
```

**質問**:
1. `var currentStep` のキャプチャは正しい？
2. `DispatchQueue.main.async` は必要？（オーディオスレッドとの関係）
3. `leeway: .nanoseconds(0)` で本当に4ms精度が出る？
4. `timer.cancel()` のタイミングは正しい？

### Q2: to側も0→1にフェードすべきか？
**現在の実装**:
```swift
// 新バスを即座にフルボリュームに
toNode.outputVolume = 1.0
```

**質問**:
1. to側も0→1にフェードする必要がある？
2. 即座に1.0にすることで、前のコードが消えない原因になる？

### Q3: outputVolume の更新はリアルタイムに効くか？
**質問**:
1. `AVAudioMixerNode.outputVolume` の更新は、オーディオレンダリングに即座に反映される？
2. バッファリングや遅延はある？
3. メインスレッドでの更新は正しい？

### Q4: フェードのタイミングは正しいか？
**現在のタイミング**:
- 小節開始時にフェード開始
- 同時に次のコードを再生開始

**質問**:
1. 小節の終わり（例: 3.5拍目）からフェード開始すべき？
2. 「次の小節頭で完全に0.0」にするには、どのタイミングで開始すべき？

### Q5: 代替の実装方法はあるか？
**質問**:
1. `AVAudioPlayerNode` + `AVAudioPCMBuffer` でフェードを実装すべき？
2. より低レベルのAPIを使うべき？
3. 現実的な妥協点は？

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

### 1. Phase 1: 直接制御（stopNote()）
- **方法**: `sampler.stopNote()` で4拍後に停止
- **結果**: ❌ 全音符のまま（SF2のReleaseが優先される）

### 2. noteDuration 調整
- **試した値**: 4拍 → 3拍 → 3.5拍 → 2.5拍
- **結果**: ❌ すべて効果なし

### 3. DispatchQueue.asyncAfter（12ステップ）
- **方法**: 12ステップ（10ms/step）で outputVolume を更新
- **結果**: ❌ 全音符のまま

### 4. AVAudioMixingDestination.setVolumeRamp（試行）
- **方法**: オーディオタイムでランプを予約
- **結果**: ❌ API が存在しない（コンパイルエラー）

### 5. DispatchSourceTimer（30ステップ）← 現在
- **方法**: 30ステップ（4ms/step）、leeway=0、QoS=userInteractive
- **結果**: ❌ **全音符のまま**

---

## 🙏 求めるアドバイス

1. **DispatchSourceTimer の実装の修正点**
2. **to側のフェードイン実装**
3. **outputVolume の更新方法（メインスレッド vs オーディオスレッド）**
4. **フェードタイミングの調整**
5. **代替の実装方法（AVAudioPlayerNode など）**
6. **現実的な妥協点（短リリースSF2の使用など）**

---

## 💡 次の実装候補

### Option A: to側も0→1にフェード
```swift
timer.setEventHandler { [weak fromNode, weak toNode] in
    currentStep += 1
    let progress = Float(currentStep) / Float(steps)
    
    DispatchQueue.main.async {
        fromNode?.outputVolume = startVolume * (1.0 - progress)
        toNode?.outputVolume = progress  // 0→1
    }
    
    if currentStep >= steps {
        timer.cancel()
    }
}
```

### Option B: メインスレッドを経由しない
```swift
timer.setEventHandler { [weak fromNode] in
    currentStep += 1
    let progress = Float(currentStep) / Float(steps)
    let newVolume = startVolume * (1.0 - progress)
    
    // DispatchQueue.main.async を削除
    fromNode?.outputVolume = newVolume
    
    if currentStep >= steps {
        timer.cancel()
    }
}
```

### Option C: フェード開始を前倒し
```swift
// 小節開始から (barSec - fadeSec) 秒後にフェード開始
DispatchQueue.global().asyncAfter(deadline: .now() + (barSec - fadeSec)) {
    scheduleCrossFade(fromNode: prevNode, toNode: currentNode, fadeMs: fadeMs)
}
```

---

**このレポートを ChatGPT に送って、実装の何が間違っているのか確認してください！**


