# A案実装結果 — ChatGPT 再相談用レポート

**日付**: 2025-10-05  
**実装**: A案（GuitarBounceService + HybridPlayer 修正）  
**結果**: **変化なし（音が伸び続ける）**  
**環境**: iOS Simulator (iPhone 16), Xcode, Swift, AVFoundation

---

## 📋 実装した内容

### A案の修正（ChatGPT 指示通り）

以下の修正を**すべて実装しました**が、結果は変わりませんでした。

---

## 1️⃣ GuitarBounceService.swift の修正

### 修正前の問題

```swift
// ❌ 問題1: DispatchQueue.asyncAfter でノート開始（壁時計ベース）
DispatchQueue.global(qos: .userInteractive).asyncAfter(
    deadline: .now() + Double(startFrame) / sampleRate
) {
    sampler.startNote(note, withVelocity: 80, onChannel: 0)
}

// ❌ 問題2: 同じバッファに繰り返し renderOffline（上書き）
while currentFrame < AVAudioFramePosition(totalFrames) {
    let framesToRender = min(4096, totalFrames - AVAudioFrameCount(currentFrame))
    let status = try engine.renderOffline(framesToRender, to: renderBuffer)
    currentFrame += AVAudioFramePosition(framesToRender)
}
```

### 修正後のコード

```swift
// ✅ 修正1: イベント駆動レンダーループ
// 1. イベントリスト作成（ノート開始位置）
let strumFrames = AVAudioFramePosition(strumMs / 1000.0 * sampleRate)
var events: [(frame: AVAudioFramePosition, note: UInt8)] = []
for (i, note) in midiNotes.enumerated() {
    let startFrame = AVAudioFramePosition(i) * strumFrames
    events.append((frame: startFrame, note: note))
}

// 2. Scratch バッファ（小さなブロック用）
let blockSize = engine.manualRenderingMaximumFrameCount
guard let scratchBuffer = AVAudioPCMBuffer(
    pcmFormat: engine.manualRenderingFormat,
    frameCapacity: blockSize
) else { throw error }

// 3. Accum バッファ（最終出力用）
guard let accumBuffer = AVAudioPCMBuffer(
    pcmFormat: engine.manualRenderingFormat,
    frameCapacity: totalFrames
) else { throw error }
accumBuffer.frameLength = totalFrames

// 4. イベント駆動レンダーループ
var framesRendered: AVAudioFrameCount = 0
var nextEventIndex = 0

while framesRendered < totalFrames {
    // 次のイベントまでのフレーム数を計算
    let framesToRender: AVAudioFrameCount
    if nextEventIndex < events.count {
        let nextEventFrame = events[nextEventIndex].frame
        let framesUntilEvent = AVAudioFrameCount(max(0, nextEventFrame - AVAudioFramePosition(framesRendered)))
        framesToRender = min(blockSize, framesUntilEvent, totalFrames - framesRendered)
    } else {
        framesToRender = min(blockSize, totalFrames - framesRendered)
    }
    
    // レンダリング
    if framesToRender > 0 {
        scratchBuffer.frameLength = framesToRender
        let status = try engine.renderOffline(framesToRender, to: scratchBuffer)
        
        guard status == .success else { throw error }
        
        // ✅ 修正2: Scratch → Accum にコピー
        for ch in 0..<Int(scratchBuffer.format.channelCount) {
            if let src = scratchBuffer.floatChannelData?[ch],
               let dst = accumBuffer.floatChannelData?[ch] {
                let dstOffset = Int(framesRendered)
                memcpy(dst.advanced(by: dstOffset), src, Int(framesToRender) * MemoryLayout<Float>.stride)
            }
        }
        
        framesRendered += framesToRender
    }
    
    // ✅ 修正3: イベント発火（フレーム位置が一致した瞬間にノート開始）
    while nextEventIndex < events.count && events[nextEventIndex].frame <= AVAudioFramePosition(framesRendered) {
        let note = events[nextEventIndex].note
        sampler.startNote(note, withVelocity: 80, onChannel: 0)
        print("🎵 Note On: \(note) at frame \(framesRendered)")
        nextEventIndex += 1
    }
}

engine.stop()

// 5. 末尾120msを線形フェード（accumBuffer に適用）
applyFadeOut(to: accumBuffer, durationMs: releaseMs)

// 6. 検証: 末尾が -90dB 以下か確認
verifyFadeOut(accumBuffer)

// 7. キャッシュ登録
cache[key] = accumBuffer
return accumBuffer
```

### 追加した検証関数

```swift
/// フェードアウト検証: 末尾が -90dB 以下か確認
private func verifyFadeOut(_ buffer: AVAudioPCMBuffer) {
    guard let floatData = buffer.floatChannelData else { return }
    
    let totalFrames = Int(buffer.frameLength)
    let checkFrames = min(1024, totalFrames)  // 末尾1024サンプルをチェック
    let startFrame = totalFrames - checkFrames
    
    var maxAbs: Float = 0.0
    for ch in 0..<Int(buffer.format.channelCount) {
        let channelData = floatData[ch]
        for i in startFrame..<totalFrames {
            maxAbs = max(maxAbs, abs(channelData[i]))
        }
    }
    
    let dB = maxAbs > 0 ? 20.0 * log10(maxAbs) : -100.0
    print("🔍 Fade-out verification: tail max = \(maxAbs) (\(dB) dB)")
    
    if dB > -90.0 {
        print("⚠️ Warning: tail is louder than -90dB")
    } else {
        print("✅ Fade-out OK: tail < -90dB")
    }
}
```

---

## 2️⃣ HybridPlayer.swift の修正

### 修正前の問題

```swift
// ❌ 問題: completion 内で次をスケジュール（隙間発生）
func scheduleNext() {
    playerGtr.scheduleBuffer(buffer) { [weak self] in
        // 完了後に次をスケジュール
        if currentIndex < buffers.count {
            scheduleNext()
        } else {
            currentIndex = 0
            scheduleNext()
        }
    }
}
scheduleNext()
```

### 修正後のコード

```swift
/// ギターPCMバッファをPlayerNodeにスケジュール（絶対サンプル時刻で連結）
private func scheduleGuitarBuffers(
    _ buffers: [AVAudioPCMBuffer],
    countInFrames: AVAudioFramePosition,
    onBarChange: @escaping (Int) -> Void
) {
    // ✅ A案: 絶対サンプル時刻で全バッファを先にスケジュール
    
    let sampleRate = engine.mainMixerNode.outputFormat(forBus: 0).sampleRate
    let barFrames = buffers.first?.frameLength ?? 88200  // 2.0s @ 44100Hz
    
    var cursor: AVAudioFramePosition = countInFrames
    
    for (index, buffer) in buffers.enumerated() {
        let when = AVAudioTime(sampleTime: cursor, atRate: sampleRate)
        
        playerGtr.scheduleBuffer(buffer, at: when, options: []) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            
            // バー変更通知
            DispatchQueue.main.async {
                onBarChange(index)
            }
        }
        
        cursor += AVAudioFramePosition(buffer.frameLength)
        print("🎵 Scheduled buffer \(index) at sampleTime \(when.sampleTime)")
    }
    
    // ループ: 最後のバッファ完了後に再度スケジュール
    if let lastBuffer = buffers.last {
        playerGtr.scheduleBuffer(lastBuffer) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            
            // ループ: 全バッファを再スケジュール
            self.scheduleGuitarBuffers(
                buffers,
                countInFrames: 0,  // ループ時はカウントイン不要
                onBarChange: onBarChange
            )
        }
    }
    
    print("✅ HybridPlayer: All buffers scheduled (\(buffers.count) bars)")
}
```

---

## 📊 実装結果

### ビルド

- ✅ **BUILD SUCCEEDED**
- エラーなし
- 警告なし

### 実行時の動作

- ❌ **変化なし**
- 音が伸び続ける
- 以前と同じ症状

---

## 🔍 予想される問題

### 仮説 1: HybridPlayer が実際には使われていない

**現在の状況**:
- `ProgressionView.swift` の `init()` で `ChordSequencer` を初期化している
- `HybridPlayer` は初期化されているが、実際には `ChordSequencer` にフォールバックしている可能性

**確認が必要**:
```swift
// ProgressionView.swift
init() {
    // Phase B-Lite: ChordSequencer を再有効化
    // ...
    _sequencer = State(initialValue: seq)  // ← これが成功している
    _hybridPlayer = State(initialValue: nil)  // ← nil に設定している
    _bounceService = State(initialValue: nil)  // ← nil に設定している
}
```

**問題**:
- `startPlayback()` で `if let player = hybridPlayer, let bounce = bounceService` がfalseになる
- → `else if let seq = sequencer` で `ChordSequencer` にフォールバックしている
- → **GuitarBounceService と HybridPlayer のコードが実行されていない**

---

## 💡 解決策の提案

### オプション 1: ProgressionView を修正して HybridPlayer を強制的に使う

```swift
init() {
    // HybridPlayer を優先
    _hybridPlayer = State(initialValue: HybridPlayer())
    _bounceService = State(initialValue: GuitarBounceService())
    
    // ChordSequencer は無効化
    _sequencer = State(initialValue: nil)
    print("✅ HybridPlayer mode (ChordSequencer disabled)")
}
```

### オプション 2: コンソールログで確認

以下のログが出ているか確認:
- `🎵 Note On: XX at frame XXXX` (GuitarBounceService)
- `🔍 Fade-out verification: tail < -90dB` (GuitarBounceService)
- `🎵 Scheduled buffer X at sampleTime XXXX` (HybridPlayer)

これらが**出ていない場合**、HybridPlayer が使われていない。

### オプション 3: Phase B-Lite を無効化

現在の `ChordSequencer` (Phase B-Lite) も修正したが、実際にはそちらが使われている可能性。

```swift
// ChordSequencer.swift の play() メソッド内
// Phase B-Lite: Note Duration を制限（60% = 1.2秒）
let noteDuration = barSec * 0.6
xfadeQ.asyncAfter(deadline: .now() + noteDuration) { [weak nextSampler] in
    // Note Off + CC120/123
}
```

これが実行されているが、効果がない = SF2 の Release が原因。

---

## 🤔 ChatGPT への質問

### Q1: HybridPlayer が使われていない可能性

**状況**:
- `ProgressionView.swift` で `_hybridPlayer = State(initialValue: nil)` に設定している
- → `ChordSequencer` にフォールバックしている
- → GuitarBounceService の修正が実行されていない

**質問**:
1. この仮説は正しいですか？
2. コンソールログで確認すべき内容は？
3. `ProgressionView.swift` の `init()` をどう修正すべきですか？

### Q2: Phase B-Lite (ChordSequencer) の効果がない理由

**状況**:
- `stopNote()` + `CC120/123` を送信している
- ログでは正しく実行されている
- しかし音が伸び続ける

**質問**:
1. `stopNote()` と `CC120` は SF2 の Release を無視できないのですか？
2. `FluidR3_GM.sf2` の Program 25 の Release エンベロープは変更できませんか？
3. 他に音を強制停止する方法はありますか？

### Q3: 代替案の提案

**B案（SMF→PCM）**と**C案（短Release SF2）**も検討すべきですか？

---

## 📎 添付情報

### 実装したファイル

1. **GuitarBounceService.swift** - イベント駆動レンダーループ + Scratch→Accum
2. **HybridPlayer.swift** - 絶対サンプル時刻スケジューリング
3. **ProgressionView.swift** - (**未修正**: まだ ChordSequencer を使っている)

### コンソールログ（必要な場合は実行して提供）

現在のログ:
- Phase B-Lite のログ（ChordSequencer）
- HybridPlayer のログは**出ていない**可能性

---

## 🎯 期待する回答

1. **HybridPlayer が使われていない問題の確認方法**
2. **ProgressionView.swift の修正方法**（HybridPlayer を強制的に使う）
3. **それでも音が伸びる場合の対処法**
4. **B案/C案への切り替え判断**

---

**最終更新**: 2025-10-05  
**ステータス**: A案実装完了、しかし効果なし、ChatGPT 再相談準備完了


