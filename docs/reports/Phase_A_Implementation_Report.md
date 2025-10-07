# Phase A 実装レポート

**日付**: 2025-10-05  
**マイルストーン**: M4 オーディオ実装（Hybrid Audio Architecture）  
**フェーズ**: Phase A（基盤）  
**ステータス**: ✅ 完了

---

## 📋 実装サマリー

**Phase A の目的**: Hybrid Audio Architecture の基盤を構築し、Phase B での最小再生実装に向けた土台を作成する。

**実装期間**: 1日（2025-10-05）

---

## ✅ 完了したタスク

### 1. Score / Bar モデルを追加 ✅

**ファイル**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/Models/Score.swift`

**実装内容**:
- `Score` 構造体: BPM と 小節配列（`bars: [Bar]`）を保持
- `Bar` 構造体: コードシンボル（`chord: String`）を保持
- `Score.from(slots:bpm:)`: 既存のUIの `slots: [String?]` から `Score` を生成
- `barCount`: 小節数を取得
- `totalDuration`: 総秒数を計算（BPM120なら1小節=2.0秒）

**主要コード**:
```swift
struct Score {
    var bpm: Double
    var bars: [Bar]
    
    static func from(slots: [String?], bpm: Double = 120.0) -> Score {
        let bars: [Bar] = slots.compactMap { chord -> Bar? in
            guard let chord = chord, !chord.isEmpty else { return nil }
            return Bar(chord: chord)
        }
        return Score(bpm: bpm, bars: bars)
    }
}

struct Bar {
    var chord: String  // "C", "Am7", "G/B" など
}
```

**技術課題と解決**:
- **課題**: `compactMap` の型推論エラー
- **解決**: 戻り値の型を明示的に `Bar?` として指定

---

### 2. GuitarBounceService を新規作成 ✅

**ファイル**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/GuitarBounceService.swift`

**実装内容**:
- 1小節（2.0秒@120BPM）のギターPCMをオフラインレンダリング
- 末尾120msを波形で線形フェードアウト
- LRUキャッシュ（最大16件）
- `CacheKey`: `(chord: String, program: UInt8, bpm: Double)`

**主要機能**:
1. **オフラインレンダリング**:
   - `AVAudioEngine.enableManualRenderingMode(.offline)`
   - 44.1kHz, 2ch
   - 4096フレームずつレンダリング

2. **ストラム遅延**:
   - デフォルト15ms
   - 最大6声まで

3. **フェードアウト**:
   - 末尾120msを線形フェード（1.0 → 0.0）
   - 波形レベルで直接操作

4. **キャッシュ管理**:
   - LRU方式
   - 最大16バッファ（約11MB）

**主要コード**:
```swift
func buffer(
    for key: CacheKey,
    sf2URL: URL,
    strumMs: Double = 15.0,
    releaseMs: Double = 120.0
) throws -> AVAudioPCMBuffer {
    // キャッシュヒット
    if let cached = cache[key] {
        return cached
    }
    
    // オフラインレンダリング
    let engine = AVAudioEngine()
    let sampler = AVAudioUnitSampler()
    // ... SF2ロード、CC初期化
    
    try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: 4096)
    try engine.start()
    
    // レンダリング実行
    // ... ストラム遅延で発音
    
    // 末尾フェード
    applyFadeOut(to: renderBuffer, durationMs: releaseMs)
    
    // キャッシュ登録
    cache[key] = renderBuffer
    return renderBuffer
}
```

---

### 3. HybridPlayer の土台 ✅

**ファイル**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/HybridPlayer.swift`

**実装内容**:
- `AVAudioEngine` + `AVAudioPlayerNode` (Guitar) + `AVAudioUnitSampler` × 2 (Bass/Drums)
- `AVAudioSequencer` の初期化
- `prepare(sf2URL:drumKitURL:)`: SF2ロード、AVAudioSession設定
- `play(score:guitarBuffers:onBarChange:)`: 再生開始（Phase Aはテスト実装）
- `stop()`: 停止、CC120/123でクリーンアップ

**システム構成**:
```
engine
  ├─ playerGtr (AVAudioPlayerNode)
  ├─ samplerBass (AVAudioUnitSampler)
  ├─ samplerDrum (AVAudioUnitSampler)
  └─ mainMixerNode
  
sequencer (AVAudioSequencer)
```

**AVAudioSession設定**:
- カテゴリ: `.playback`
- サンプルレート: 44.1kHz
- I/Oバッファ: 10ms（シミュレータ）、5ms（実機）

**主要コード**:
```swift
func prepare(sf2URL: URL, drumKitURL: URL?) throws {
    // AVAudioSession設定
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playback, mode: .default)
    try session.setPreferredSampleRate(44100.0)
    #if targetEnvironment(simulator)
    try session.setPreferredIOBufferDuration(0.01)  // 10ms
    #else
    try session.setPreferredIOBufferDuration(0.005) // 5ms
    #endif
    
    // Bass/Drum SF2ロード
    try samplerBass.loadSoundBankInstrument(at: sf2URL, program: 34, ...)
    try samplerDrum.loadSoundBankInstrument(at: drumKitURL ?? sf2URL, program: 0, ...)
    
    // CC初期化
    // ...
    
    if !engine.isRunning {
        try engine.start()
    }
}
```

---

### 4. SequencerBuilder の雛形 ✅

**ファイル**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/SequencerBuilder.swift`

**実装内容**:
- `build(score:includeBass:includeDrums:)`: ScoreからMusicSequenceを構築
- Phase A: テンポトラックのみ実装
- Phase B: ベーストラック追加（TODO）
- Phase C: ドラムトラック追加（TODO）

**主要コード**:
```swift
static func build(
    score: Score,
    includeBass: Bool = false,
    includeDrums: Bool = false
) throws -> MusicSequence {
    var musicSequence: MusicSequence?
    NewMusicSequence(&musicSequence)
    
    // テンポトラック設定
    var tempoTrack: MusicTrack?
    MusicSequenceGetTempoTrack(sequence, &tempoTrack)
    
    if let track = tempoTrack {
        MusicTrackNewExtendedTempoEvent(track, 0.0, score.bpm)
    }
    
    // Phase B/C: ベース/ドラムトラック追加（TODO）
    
    return sequence
}
```

---

### 5. ProgressionView を更新 ✅

**ファイル**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Views/ProgressionView.swift`

**実装内容**:
- `@State private var hybridPlayer: HybridPlayer?`
- `@State private var bounceService: GuitarBounceService?`
- `init()` で HybridPlayer と GuitarBounceService を初期化
- `playProgression()` に HybridPlayer のテストコード追加（コメントアウト）
- `stopProgression()` に HybridPlayer の停止コード追加（コメントアウト）

**注記**:
- Phase A では旧実装（ChordSequencer）を維持
- Phase B で HybridPlayer に完全移行
- コメントアウトしたコードは Phase B で有効化

---

## 🔧 技術課題と解決

### 1. `compactMap` の型推論エラー

**課題**:
```swift
let bars = slots.compactMap { chord in
    guard let chord = chord, !chord.isEmpty else { return nil }
    return Bar(chord: chord)
}
```
→ `generic parameter 'ElementOfResult' could not be inferred`

**解決**:
```swift
let bars: [Bar] = slots.compactMap { chord -> Bar? in
    guard let chord = chord, !chord.isEmpty else { return nil }
    return Bar(chord: chord)
}
```

---

### 2. `AVAudioSequencer.load(from:options:)` のAPIミスマッチ

**課題**:
```swift
sequencer.load(from: sequence, options: [])
```
→ `no exact matches in call to instance method 'load'`  
→ `AVAudioSequencer.load` は `URL` を期待、`MusicSequence` は受け付けない

**解決**:
- Phase A では `AVAudioSequencer` を再作成
- `MusicSequence` の直接設定は `AVAudioSequencer.musicSequence` が get-only のため不可
- Phase B で `MusicSequence` → 一時ファイル → `sequencer.load(from: fileURL)` の方法を検討

**実装**:
```swift
// Sequencerにセット
sequencer.stop()
// AVAudioSequencer.musicSequence は get-only なので、
// Phase A では Sequencer を再作成
sequencer = AVAudioSequencer(audioEngine: engine)

// MusicSequence を直接操作する方法がないため、
// Phase A では SequencerBuilder を使わず、
// Phase B で再設計します
```

---

## 📊 Phase A DoD 達成状況

| 項目 | 基準 | 達成 |
|------|------|------|
| **Score / Bar モデル** | 既存UIのslots→Scoreに集約 | ✅ 完了 |
| **GuitarBounceService** | オフラインrender→PCM化→末尾120msフェード | ✅ 完了 |
| **HybridPlayer** | Engine+PlayerNode+2サンプラー、prepare/start/stop | ✅ 完了 |
| **SequencerBuilder** | TempoTrackのみ | ✅ 完了 |
| **ビルド成功** | エラーなくビルド完了 | ✅ 完了 |

---

## 📝 次のステップ: Phase B（最小再生）

### Phase B タスク（1-2日）

1. **C/G/Am/F のギターPCM生成**
   - `GuitarBounceService` を使って4コードのPCMバッファを生成
   - PlayerNodeで連結再生

2. **ベース基本形をイベント化**
   - Root/5th パターンを生成
   - Sequencerで発音

3. **カウントイン実装**
   - クリックPCMを4つ先頭にschedule
   - または Drumトラックのハイハットで代用

4. **ループ実装**
   - 最後のcompletionで再スケジュール

5. **停止実装**
   - CC120/123 + reset

### Phase B 技術課題

- **MusicSequence → Sequencer**: 一時ファイル経由で `sequencer.load(from: fileURL)` を使用
- **PlayerNode + Sequencer 同期**: 0.2秒先に開始を予約して同期精度向上
- **ループのシームレス性**: バッファの連結で隙間なし

---

## 📂 作成したファイル

1. `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/Models/Score.swift`
2. `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/GuitarBounceService.swift`
3. `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/HybridPlayer.swift`
4. `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/SequencerBuilder.swift`

---

## 🎯 Phase A の成果

✅ **Hybrid Audio Architecture の基盤が完全に構築されました！**

- **Score/Barモデル**: 既存UIとの統合準備完了
- **GuitarBounceService**: オフラインレンダリング、フェードアウト、LRUキャッシュ実装完了
- **HybridPlayer**: Engine/PlayerNode/Sampler構成、prepare/start/stop実装完了
- **SequencerBuilder**: 雛形実装完了（Phase Bで拡張）
- **ビルド成功**: 全ての新規コードがエラーなくコンパイル完了

**Phase B での最小再生実装に向けた土台が完全に整いました！**

---

**実装担当**: AI Assistant  
**レビュー**: 2025-10-05  
**次回レビュー予定**: Phase B 完了時


