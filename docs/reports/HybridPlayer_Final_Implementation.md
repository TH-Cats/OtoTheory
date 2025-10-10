# HybridPlayer 最終実装レポート

**作成日**: 2025-10-09  
**対象**: Hybrid Audio Architecture（ギター PCM + ベース/ドラム MIDI）  
**状態**: ✅ 実装完了（テスト待ち）

---

## 🎯 実装した変更

### 1. ✅ HybridPlayer を常用に固定

**ProgressionView.swift**:
```swift
init() {
    // ✅ HybridPlayer を常用（Phase B 最終版）
    audioTrace("PATH = Hybrid (fixed)")
    
    // HybridPlayer, GuitarBounceService, ChordSequencer を全て初期化
    let hybrid = try HybridPlayer(sf2URL: url)
    let bounce = try GuitarBounceService(sf2URL: url)
    let seq = try ChordSequencer(sf2URL: url)  // クリック専用
}

private func startPlayback() {
    // ✅ HybridPlayer を常用
    guard let hybrid = hybridPlayer, let bounce = bounceService else {
        assertionFailure("HybridPlayer must be initialized")
        return
    }
    
    audioTrace("Playback started (HybridPlayer)")
    playWithHybridPlayer(chords: chords, player: hybrid, bounce: bounce)
}
```

**ログ確認**:
- `PATH = Hybrid (fixed)` が起動時に出力される
- `Playback started (HybridPlayer)` が再生時に出力される

---

### 2. ✅ GuitarBounceService のイベント駆動オフライン統一

**GuitarBounceService.swift**:
- ✅ `asyncAfter` による壁時計依存を排除
- ✅ イベント駆動レンダーループ（フレーム位置基準でノート開始）
- ✅ Scratch→Accum バッファ方式
- ✅ 末尾 120ms の線形フェードアウト
- ✅ -90dB 検証

**主要コード**:
```swift
// イベントリスト作成
var events: [(frame: AVAudioFramePosition, note: UInt8)] = []
for (i, note) in midiNotes.enumerated() {
    let startFrame = AVAudioFramePosition(i) * strumFrames
    events.append((frame: startFrame, note: note))
}

// レンダーループ
while framesRendered < totalFrames {
    // レンダリング
    let status = try engine.renderOffline(framesToRender, to: scratchBuffer)
    
    // Scratch → Accum にコピー
    memcpy(dst.advanced(by: dstOffset), src, ...)
    
    // イベント発火（フレーム位置が一致した瞬間にノート開始）
    while nextEventIndex < events.count && events[nextEventIndex].frame <= framesRendered {
        sampler.startNote(note, withVelocity: 80, onChannel: 0)
        nextEventIndex += 1
    }
}

// フェードアウト適用
applyFadeOut(to: accumBuffer, durationMs: releaseMs)

// 検証
verifyFadeOut(accumBuffer)  // 末尾が -90dB 以下か確認
```

---

### 3. ✅ HybridPlayer で絶対サンプル時刻 + 2周先行予約

**HybridPlayer.swift**:

**改善点**:
- ✅ 2周分（= 全バー×2）を先に予約
- ✅ 最後の1個の completion で次の2周を再予約
- ✅ OSLog で詳細ログ出力

**主要コード**:
```swift
private func scheduleGuitarBuffers(
    _ buffers: [AVAudioPCMBuffer],
    countInFrames: AVAudioFramePosition,
    onBarChange: @escaping (Int) -> Void
) {
    let sampleRate = engine.mainMixerNode.outputFormat(forBus: 0).sampleRate
    var cursor: AVAudioFramePosition = countInFrames
    
    // 2周分をスケジュール
    for cycle in 0..<2 {
        for (index, buffer) in buffers.enumerated() {
            let when = AVAudioTime(sampleTime: cursor, atRate: sampleRate)
            let isLastBuffer = (cycle == 1 && index == buffers.count - 1)
            
            playerGtr.scheduleBuffer(buffer, at: when, options: []) { [weak self] in
                // バー変更通知
                onBarChange(index)
                
                // 最後のバッファ完了後に次の2周を再予約
                if isLastBuffer {
                    self?.logger.info("LOOP re-scheduled (2x bars)")
                    self?.scheduleGuitarBuffers(buffers, countInFrames: cursor + ..., onBarChange: onBarChange)
                }
            }
            
            self.logger.info("GTR scheduled i=\(index) cycle=\(cycle) when.sampleTime=\(when.sampleTime)")
            cursor += AVAudioFramePosition(buffer.frameLength)
        }
    }
    
    logger.info("✅ HybridPlayer: 2 cycles scheduled (\(buffers.count * 2) bars)")
}
```

**期待されるログ**:
```
PATH = HybridPlayer (PCM)
GTR scheduled i=0 cycle=0 when.sampleTime=88200
GTR scheduled i=1 cycle=0 when.sampleTime=176400
GTR scheduled i=2 cycle=0 when.sampleTime=264600
GTR scheduled i=3 cycle=0 when.sampleTime=352800
GTR scheduled i=0 cycle=1 when.sampleTime=441000
GTR scheduled i=1 cycle=1 when.sampleTime=529200
GTR scheduled i=2 cycle=1 when.sampleTime=617400
GTR scheduled i=3 cycle=1 when.sampleTime=705600
✅ HybridPlayer: 2 cycles scheduled (8 bars)
COUNT-IN done
START at hostTime=...
Sequencer started (bass)
LOOP re-scheduled (2x bars)
```

---

### 4. ✅ ChordSequencer の危険操作を停止

**ChordSequencer.swift**:
- ✅ `hardKillSampler` は `stop()` 時のみ使用
- ✅ 再生中の `reset()` / `CC120/123` 常用を禁止
- ✅ クリック専用として最小限の機能のみ残す

---

### 5. ✅ OSLog でログ出力を追加

**HybridPlayer.swift**:
```swift
import os.log

private let logger = Logger(subsystem: "com.ototheory.app", category: "audio")

func play(...) {
    logger.info("PATH = HybridPlayer (PCM)")
    logger.info("COUNT-IN done")
    logger.info("START at hostTime=\(startTime.hostTime)")
    logger.info("GTR scheduled i=\(index) cycle=\(cycle) when.sampleTime=\(when.sampleTime)")
    logger.info("LOOP re-scheduled (2x bars)")
    logger.info("Sequencer started (bass)")
}
```

**ログ監視コマンド**:
```bash
xcrun simctl spawn booted log stream --style syslog --level info --predicate 'process == "OtoTheory" AND subsystem == "com.ototheory.app" AND category == "audio"'
```

---

## 🧪 テスト手順

### 1. ビルドと実行

```bash
cd /Users/nh/App/OtoTheory/OtoTheory-iOS
xcodebuild -project OtoTheory.xcodeproj -scheme OtoTheory -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### 2. ログ監視

別ターミナルで以下を実行：
```bash
xcrun simctl spawn booted log stream --style syslog --level info --predicate 'process == "OtoTheory" AND subsystem == "com.ototheory.app" AND category == "audio"'
```

### 3. HALC 警告監視

別ターミナルで以下を実行：
```bash
xcrun simctl spawn booted log stream --style syslog --process OtoTheory --predicate 'composedMessage CONTAINS "HALC_ProxyIOContext::IOWorkLoop"'
```

### 4. テスト項目

#### ✅ 必須項目（受け入れ条件）

1. **PATH = Hybrid (fixed)** がアプリ起動時に出力される
2. **Playback started (HybridPlayer)** が再生時に出力される
3. **GTR scheduled i=N cycle=M** が各バッファで出力される
4. **LOOP re-scheduled (2x bars)** が最後のバッファ完了後に出力される
5. **12小節連続再生**で途切れなし
6. **1拍目が軽くならない**
7. **HALC 警告が出ない**（CPU 過負荷なし）

#### 📊 期待される動作

- **C → G → Am → F** が 2.000秒ごとに切り替わる（BPM120）
- 各小節が**切れ目なく**鳴る
- **3周（12小節）**繰り返しても無音区間なし
- 停止→再生を5回繰り返しても正常動作

---

## 🔍 トラブルシューティング

### 問題1: `PATH = Hybrid` が出ない

**原因**: init() で ChordSequencer が優先されている

**対策**: `ProgressionView.init()` を確認

### 問題2: 2小節目以降が無音

**原因**: バッファの再スケジュールが失敗している

**対策**: 
- `LOOP re-scheduled` ログが出ているか確認
- `isLastBuffer` の判定を確認

### 問題3: HALC 警告が出る

**原因**: CPU 過負荷

**対策**:
- キャッシュサイズを減らす（16→8）
- バッファサイズを調整

---

## 📋 変更ファイル一覧

1. ✅ `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Views/ProgressionView.swift`
   - `init()`: HybridPlayer を常用に固定
   - `startPlayback()`: HybridPlayer を必須化

2. ✅ `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/GuitarBounceService.swift`
   - `init(sf2URL:)`: 追加
   - `buffer(for:...)`: イベント駆動オフライン統一済み

3. ✅ `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/HybridPlayer.swift`
   - `import os.log`: 追加
   - `logger`: OSLog 追加
   - `init(sf2URL:)`: 追加
   - `scheduleGuitarBuffers(...)`: 2周先行予約に変更
   - `play(...)`: OSLog ログ追加

4. ✅ `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/ChordSequencer.swift`
   - 危険操作は既に排除済み（フォールバック用として最小限）

---

## 🎯 次のステップ

### Step 1: ビルド確認

```bash
cd /Users/nh/App/OtoTheory/OtoTheory-iOS
xcodebuild -project OtoTheory.xcodeproj -scheme OtoTheory -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Step 2: シミュレーターで実行

1. Xcode で `⌘R` を押す
2. シミュレーターでアプリを起動
3. C, G, Am, F を入力
4. 再生ボタンを押す

### Step 3: ログ確認

1. ターミナルで OSLog を確認
2. `PATH = Hybrid (fixed)` が出ているか
3. `GTR scheduled i=...` が出ているか
4. `LOOP re-scheduled` が出ているか

### Step 4: 動作確認

1. 12小節連続で鳴るか
2. 1拍目が軽くないか
3. HALC 警告が出ないか

---

## ✅ 完了

- [x] HybridPlayer を常用に固定
- [x] GuitarBounceService をイベント駆動オフラインに統一
- [x] HybridPlayer で絶対サンプル時刻 + 2周先行予約を実装
- [x] ChordSequencer の危険操作を停止
- [x] OSLog でログ出力を追加
- [ ] テスト実行（ユーザー確認待ち）

---

**実装完了！シミュレーターでテストしてください。** 🚀
