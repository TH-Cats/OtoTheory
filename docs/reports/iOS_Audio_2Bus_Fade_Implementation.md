# iOS Audio 2バス・フェードアウト方式 実装レポート

**日付**: 2025-10-05  
**状況**: 2バス・フェードアウト方式を実装したが、全音符問題が解決しない

---

## 📊 実装の背景

### ChatGPTからのアドバイス（要点）
1. **根本原因**: `AVAudioUnitSampler` は SF2 の Release エンベロープをそのまま尊重。`stopNote()` は Note-Off を送るだけで、長い Release は止まらない。
2. **推奨解決策**: 2バス・フェードアウト方式（最小変更で即効性）
   - 2つのサブミックス（A/B）を交互に使用
   - 新しいコードを次のバスで再生開始
   - 前のバスを 120ms でフェードアウト
   - SF2の長いReleaseが聴こえなくなる

---

## 🏗️ 実装したアーキテクチャ

### ノード構成
```
SamplerA ──→ SubMixA ──┐
                        ├──→ MainMixer ──→ Output
SamplerB ──→ SubMixB ──┘
```

### 初期化コード
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
    
    init(sf2URL: URL) throws {
        self.sf2URL = sf2URL
        
        // エンジンにノードをアタッチ
        engine.attach(samplerA)
        engine.attach(samplerB)
        engine.attach(subMixA)
        engine.attach(subMixB)
        
        // 配線: Sampler → SubMix → MainMixer
        engine.connect(samplerA, to: subMixA, format: nil)
        engine.connect(samplerB, to: subMixB, format: nil)
        engine.connect(subMixA, to: engine.mainMixerNode, format: nil)
        engine.connect(subMixB, to: engine.mainMixerNode, format: nil)
        
        // 初期ボリューム
        subMixA.outputVolume = 1.0
        subMixB.outputVolume = 0.0  // Bは最初ミュート
        
        // 両方のサンプラーに同じSF2をロード
        for sampler in [samplerA, samplerB] {
            try sampler.loadSoundBankInstrument(
                at: sf2URL,
                program: 25,  // Acoustic Steel (デフォルト)
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
            
            // CC Reset（全チャンネル）
            for ch: UInt8 in 0...15 {
                sampler.sendController(64, withValue: 0, onChannel: ch)  // Sustain OFF
                sampler.sendController(91, withValue: 0, onChannel: ch)  // Reverb 0
                sampler.sendController(93, withValue: 0, onChannel: ch)  // Chorus 0
                sampler.sendController(7, withValue: 100, onChannel: ch)  // Volume 100
            }
        }
        
        // Audio Session を短いバッファに設定
        try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.005)  // 5ms
        
        // エンジン起動
        try engine.start()
        
        print("✅ ChordSequencer initialized (2-Bus Fade-out method)")
    }
}
```

---

## 🎵 再生ロジックの実装

### play() メソッド
```swift
func play(chords: [String], program: UInt8, bpm: Double, onBarChange: @escaping (Int?) -> Void) {
    guard !isPlaying else { return }
    isPlaying = true
    
    // 音色をロード（両方のサンプラー）
    changeInstrument(program)
    
    // 再生タスク
    playbackTask = Task { @MainActor in
        let beatSec = 60.0 / bpm
        let barSec = beatSec * 4
        let strumDelay = strumMs / 1000.0
        
        print("🎵 Starting playback (2-Bus Fade): BPM=\(bpm), fadeMs=\(fadeMs)")
        
        // カウントイン（高音4回）- サンプラーAで
        onBarChange(nil)
        for i in 0..<4 {
            samplerA.startNote(84, withVelocity: 127, onChannel: 0)  // C7
            try? await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
            samplerA.stopNote(84, onChannel: 0)
            
            if i < 3 {
                try? await Task.sleep(nanoseconds: UInt64((beatSec - 0.1) * 1_000_000_000))
            } else {
                try? await Task.sleep(nanoseconds: UInt64((beatSec - 0.1) * 1_000_000_000))
            }
            
            if !isPlaying { return }
        }
        
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
                
                // 今回使うサンプラーとサブミックス
                let currentSampler = currentBusIsA ? samplerA : samplerB
                let currentSub = currentBusIsA ? subMixA : subMixB
                let prevSub = currentBusIsA ? subMixB : subMixA
                
                // 前バスをフェードアウト開始（120ms）
                crossFade(from: prevSub, to: currentSub, fadeMs: fadeMs)
                
                // 軽ストラム（15ms）で各ノートを開始
                print("  🎸 Playing chord: \(symbol), notes: \(midiChord), bus: \(currentBusIsA ? "A" : "B")")
                for (i, note) in midiChord.prefix(maxVoices).enumerated() {
                    let delay = Double(i) * strumDelay
                    if delay > 0 {
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    }
                    currentSampler.startNote(note, withVelocity: 80, onChannel: 0)
                }
                
                // バスを切り替え
                currentBusIsA.toggle()
                
                // 次の小節まで待つ（4拍）
                try? await Task.sleep(nanoseconds: UInt64(barSec * 1_000_000_000))
            }
        }
        
        onBarChange(nil)
    }
}
```

### crossFade() メソッド
```swift
/// 前バスを fadeMs かけてフェードアウト、新バスをフェードイン
private func crossFade(from: AVAudioMixerNode, to: AVAudioMixerNode, fadeMs: Double) {
    let steps = 12  // 12ステップで滑らか
    let dt = (fadeMs / 1000.0) / Double(steps)
    
    // 新バスを即座にフルボリュームに
    to.outputVolume = 1.0
    
    // 前バスを段階的にフェードアウト
    let startVolume = from.outputVolume
    
    for i in 1...steps {
        let delay = dt * Double(i)
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak from] in
            let t = Float(i) / Float(steps)
            from?.outputVolume = startVolume * (1.0 - t)
        }
    }
    
    print("    🔊 Cross-fade: \(fadeMs)ms")
}
```

---

## 📋 実行時のログ

```
✅ ChordSequencer initialized (2-Bus Fade-out method)
✅ Audio Session: IOBufferDuration set to 5ms
🎵 Changing instrument to program: 25
✅ Instrument changed to program 25
✅ Playback started (Phase 1: Direct playback)
🎵 Starting playback (2-Bus Fade): BPM=120.0, fadeMs=120.0

[カウントイン: C7が4回鳴る]

🎸 Playing chord: C, notes: [60, 64, 67], bus: A
  🔊 Cross-fade: 120.0ms

🎸 Playing chord: Am, notes: [69, 60, 64], bus: B
  🔊 Cross-fade: 120.0ms

🎸 Playing chord: F, notes: [65, 69, 60], bus: A
  🔊 Cross-fade: 120.0ms

🎸 Playing chord: G, notes: [67, 71, 62], bus: B
  🔊 Cross-fade: 120.0ms

[ループ...]
```

**ログから確認できること**:
- ✅ 2つのサンプラー（A/B）が正しく初期化されている
- ✅ バスが正しく交互に切り替わっている（A→B→A→B...）
- ✅ crossFade() が各小節で呼ばれている
- ✅ タイミングは正確（4拍ごと）

---

## 🤔 実装の意図と期待される動作

### 意図
1. **バスA**でコードを再生開始（outputVolume = 1.0）
2. 4拍後、**バスB**で次のコードを再生開始（outputVolume = 1.0）
3. **同時に、バスAをフェードアウト開始**（120ms かけて outputVolume: 1.0 → 0.0）
4. バスAの音が120msで聴こえなくなる
5. SF2の長いReleaseがあっても、ミキサーでボリュームが0なので**聴こえない**

### 期待される動作
- **前のコードが120msでフェードアウト**
- **次のコードが即座に鳴り始める**
- **4拍でクリーンに切り替わる**

---

## ❌ 実際の動作（問題）

**全音符のまま鳴り続け、フェードアウトが効いていない**

### 観察された現象
1. コードが4拍で切れない
2. 前のコードが次のコードと重なって聞こえる（濁る）
3. フェードアウトの効果が感じられない
4. 全音符のまま鳴り続ける

---

## 🔍 考えられる原因

### 原因1: outputVolume の更新が効いていない？
**仮説**: `AVAudioMixerNode.outputVolume` の更新が、実際の音量に反映されていない。

**可能性**:
- `DispatchQueue.global().asyncAfter` でのタイミング問題
- オーディオスレッドとの同期問題
- iOS の AVAudioMixerNode の制約

### 原因2: フェードアウトのタイミングが遅い？
**仮説**: `crossFade()` が呼ばれるタイミングが、新しいコードの再生開始の**後**になっている。

**実装の順序**:
```swift
// 1. 前バスをフェードアウト開始
crossFade(from: prevSub, to: currentSub, fadeMs: fadeMs)

// 2. 新しいコードを再生開始
for (i, note) in midiChord.prefix(maxVoices).enumerated() {
    currentSampler.startNote(note, withVelocity: 80, onChannel: 0)
}

// 3. バスを切り替え
currentBusIsA.toggle()

// 4. 4拍待つ
try? await Task.sleep(nanoseconds: UInt64(barSec * 1_000_000_000))
```

**問題**:
- `crossFade()` は非同期（`DispatchQueue.global().asyncAfter`）
- `startNote()` は即座に実行される
- → **フェードアウトが始まる前に次のコードが鳴り始める可能性**

### 原因3: バスの切り替えタイミングが間違っている？
**仮説**: `currentBusIsA.toggle()` を呼ぶタイミングが間違っている。

**実装の順序**:
```swift
// 今回使うバスを決定
let currentSampler = currentBusIsA ? samplerA : samplerB
let currentSub = currentBusIsA ? subMixA : subMixB
let prevSub = currentBusIsA ? subMixB : subMixA

// フェードアウト開始
crossFade(from: prevSub, to: currentSub, fadeMs: fadeMs)

// 再生開始
currentSampler.startNote(...)

// バスを切り替え（次の小節用）
currentBusIsA.toggle()
```

**問題の可能性**:
- 最初の小節: `currentBusIsA = true` → 次は `false`
- 2小節目: `currentBusIsA = false` → `prevSub = subMixA`
- しかし、`subMixA` はまだ鳴っている最中？

### 原因4: outputVolume の初期化が間違っている？
**初期化**:
```swift
subMixA.outputVolume = 1.0
subMixB.outputVolume = 0.0  // Bは最初ミュート
```

**再生開始時**:
```swift
currentBusIsA = true
subMixA.outputVolume = 1.0
subMixB.outputVolume = 0.0
```

**1小節目**:
- `currentBusIsA = true` → バスA使用
- `prevSub = subMixB` (outputVolume = 0.0)
- `currentSub = subMixA` (outputVolume = 1.0)
- → **prevSubは既に0なので、フェードアウトの意味がない**

### 原因5: AVAudioMixerNode.outputVolume は期待通り動作しない？
**仮説**: `outputVolume` プロパティは、iOS でリアルタイムに効かない可能性。

**代替案**:
- `AVAudioPlayerNode` の `scheduleParameterRamp()` を使う？
- `AVAudioUnitEQ` や `AVAudioEnvironmentNode` で制御？

---

## 🎯 ChatGPTへの質問

### Q1: crossFade() の実装は正しいか？
**現在の実装**:
```swift
private func crossFade(from: AVAudioMixerNode, to: AVAudioMixerNode, fadeMs: Double) {
    let steps = 12
    let dt = (fadeMs / 1000.0) / Double(steps)
    
    to.outputVolume = 1.0
    
    let startVolume = from.outputVolume
    
    for i in 1...steps {
        let delay = dt * Double(i)
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak from] in
            let t = Float(i) / Float(steps)
            from?.outputVolume = startVolume * (1.0 - t)
        }
    }
}
```

**質問**:
1. `DispatchQueue.global().asyncAfter` は正しい？
2. `outputVolume` の更新はリアルタイムに効く？
3. `@MainActor` との相互作用は？

### Q2: バスの切り替えタイミングは正しいか？
**現在のロジック**:
```swift
// 各小節の開始時
let currentSampler = currentBusIsA ? samplerA : samplerB
let currentSub = currentBusIsA ? subMixA : subMixB
let prevSub = currentBusIsA ? subMixB : subMixA

crossFade(from: prevSub, to: currentSub, fadeMs: fadeMs)

// 再生開始
currentSampler.startNote(...)

// 次の小節用にトグル
currentBusIsA.toggle()

// 4拍待つ
try? await Task.sleep(nanoseconds: UInt64(barSec * 1_000_000_000))
```

**質問**:
1. `toggle()` のタイミングは正しい？
2. 最初の小節で `prevSub` が既に0なのは問題ない？

### Q3: outputVolume の代替手段はあるか？
**質問**:
1. `AVAudioMixerNode.outputVolume` はリアルタイムに効かない？
2. 代替手段: `scheduleParameterRamp()` を使うべき？
3. または `AVAudioPlayerNode` + `AVAudioPCMBuffer` で再生すべき？

### Q4: フェードアウトのタイミングを前倒しすべきか？
**現在の実装**:
- 小節の開始時にフェードアウト開始
- 同時に次のコードを再生開始

**代替案**:
- 小節の終わり（例: 3.5拍目）からフェードアウト開始？
- または、前の小節の終わりでフェードアウト開始？

### Q5: ChatGPTの元のアドバイスの解釈は合っているか？
**ChatGPTのアドバイス**:
> **配線**
> ```
> [ SamplerA ]─┐
>               ├─[ SubmixA ]──┐
> [ SamplerB ]─┘               ├─[ mainMixer ]─ Output
>                               └─[ Click/Metro ...]
> ```
> **切替ロジック（A/B 交互）**
> ```swift
> func crossTo(_ useA: Bool, fadeMs: Double = 120) {
>     let steps = 12, dt = fadeMs/1000.0/Double(steps)
>     let from = useA ? subB : subA
>     let to   = useA ? subA : subB
>     to.outputVolume = 1.0
>     let start = from.outputVolume
>     for i in 1...steps {
>         DispatchQueue.global().asyncAfter(deadline: .now() + dt*Double(i)) {
>             let t = Float(i)/Float(steps)
>             from.outputVolume = start * (1.0 - t)
>         }
>     }
> }
> ```

**質問**:
1. 実装は元のアドバイス通りか？
2. 配線図は正しく解釈しているか？
3. 何か見落としている点はあるか？

---

## 📦 環境情報

- **iOS Version**: 18.0 (Simulator & Device)
- **Xcode Version**: 15.x
- **Swift Version**: 5.x
- **Framework**: AVFoundation (AVAudioEngine + AVAudioUnitSampler + AVAudioMixerNode)
- **SF2 File**: TimGM6mb.sf2 (6MB)
- **BPM**: 120（テスト時）

---

## 📚 参考情報

### 関連ファイル
- `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/ChordSequencer.swift`（実装ファイル）
- `/Users/nh/App/OtoTheory/docs/reports/iOS_Audio_Phase1_Final_Report.md`（Phase 1レポート）

### SSOT要件
- **Attack**: ≈3–5ms
- **Release**: ≈80–150ms
- **Strum**: 10–20ms
- **Max Voices**: 6

### 以前試した方法（すべて失敗）
1. noteDuration の調整（4拍 → 3拍 → 3.5拍 → 2.5拍）
2. CC120/123 の送信
3. フェードアウトの追加（velocity 調整）
4. Audio Session の調整（5ms バッファ）
5. CC Reset の強化

---

## 🙏 求めるアドバイス

1. **crossFade() の実装が間違っている点**
2. **バスの切り替えタイミングの修正方法**
3. **outputVolume の代替手段（scheduleParameterRamp など）**
4. **フェードアウトのタイミング調整**
5. **元のアドバイスの正しい解釈**

---

**このレポートを ChatGPT に送って、実装の何が間違っているのか確認してください！**


