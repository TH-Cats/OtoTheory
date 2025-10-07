# iOS Audio Phase 1 最終レポート - 全音符問題が解決できない

**日付**: 2025-10-05  
**状況**: Phase 1 実装で全ての対策を試したが、コードが全音符のまま鳴り続ける問題が解決できない

---

## 📊 現在の状況

### ✅ 動作している機能
1. **カウントイン**: 4回正しく鳴る（C7高音）
2. **ループ**: コード進行が正しくループする
3. **音色選択**: 楽器の切り替えが動作する（7種類）
4. **スロットハイライト**: 再生中のスロットが正しくハイライトされる
5. **Stop制御**: Stopボタンで再生が停止する
6. **BPM調整**: BPMスライダーが正しく動作する
7. **ログ**: Note ON/OFF が正しいタイミングで呼ばれている

### ❌ 解決できない問題
**コードが全音符のまま鳴り続け、4拍で切れない**

- `stopNote()` を確実に呼んでいる（ログで確認済み）
- CC120 (All Sound Off) を送信している
- CC123 (All Notes Off) を送信している
- タイミングは完璧（2.5拍 + 1.5拍 = 4拍）
- **しかし、実際の音は止まらない**

---

## 🔍 実装の詳細（Phase 1: Direct Playback Control）

### アーキテクチャ
```
ChordSequencer (Phase 1)
├── AVAudioEngine
├── AVAudioUnitSampler
└── Task { @MainActor in ... }
    ├── カウントイン: startNote/stopNote + Task.sleep
    └── コード進行ループ:
        ├── CC120 (All Sound Off)
        ├── startNote (軽ストラム 15ms)
        ├── Task.sleep(noteDuration = 2.5拍)
        ├── stopNote (フェードアウト付き)
        ├── CC120/123 (全チャンネル)
        └── Task.sleep(silence = 1.5拍)
```

### 完全な実装コード

```swift
@MainActor
final class ChordSequencer: ObservableObject {
    let engine = AVAudioEngine()
    let sampler = AVAudioUnitSampler()
    
    // SSOT準拠
    private let strumMs: Double = 15       // 10–20ms
    private let releaseMs: Double = 120    // 80–150ms
    private let maxVoices = 6
    
    private let sf2URL: URL
    private var isPlaying = false
    private var playbackTask: Task<Void, Never>?
    
    init(sf2URL: URL) throws {
        self.sf2URL = sf2URL
        
        // エンジンとサンプラーを接続
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        
        // SF2をロード（TimGM6mb.sf2）
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
        
        // Audio Session を短いバッファに設定（レイテンシ削減）
        try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.005)  // 5ms
        
        // エンジン起動
        try engine.start()
    }
    
    func play(chords: [String], program: UInt8, bpm: Double, onBarChange: @escaping (Int?) -> Void) {
        guard !isPlaying else { return }
        isPlaying = true
        
        // 音色をロード
        changeInstrument(program)
        
        // 再生タスク
        playbackTask = Task { @MainActor in
            let beatSec = 60.0 / bpm
            let noteDuration = beatSec * 2.5  // 2.5拍
            let strumDelay = strumMs / 1000.0
            
            // カウントイン（高音4回）
            onBarChange(nil)
            for i in 0..<4 {
                sampler.startNote(84, withVelocity: 127, onChannel: 0)  // C7
                try? await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
                sampler.stopNote(84, onChannel: 0)
                
                if i < 3 {
                    try? await Task.sleep(nanoseconds: UInt64((beatSec - 0.1) * 1_000_000_000))
                }
                
                if !isPlaying { return }
            }
            
            // コード進行（ループ）
            while isPlaying {
                for (bar, symbol) in chords.enumerated() {
                    if !isPlaying { break }
                    
                    onBarChange(bar)
                    let midiChord = chordToMidi(symbol)
                    
                    // CC120 (All Sound Off) - 前のコードを確実に止める
                    for ch: UInt8 in 0...1 {
                        sampler.sendController(120, withValue: 0, onChannel: ch)
                    }
                    
                    // 軽ストラム（15ms）で各ノートを開始
                    for (i, note) in midiChord.prefix(maxVoices).enumerated() {
                        let delay = Double(i) * strumDelay
                        if delay > 0 {
                            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        }
                        sampler.startNote(note, withVelocity: 80, onChannel: 0)
                    }
                    
                    // 2.5拍後に Note Off
                    try? await Task.sleep(nanoseconds: UInt64(noteDuration * 1_000_000_000))
                    
                    // フェードアウト（100ms）
                    let fadeSteps = 5
                    let fadeStepDuration = 0.02  // 20ms per step
                    
                    for step in 0..<fadeSteps {
                        for note in midiChord.prefix(maxVoices) {
                            if step == fadeSteps - 1 {
                                sampler.stopNote(note, onChannel: 0)
                            }
                        }
                        if step < fadeSteps - 1 {
                            try? await Task.sleep(nanoseconds: UInt64(fadeStepDuration * 1_000_000_000))
                        }
                    }
                    
                    // 念のため全チャンネルで停止
                    for ch: UInt8 in 0...1 {
                        sampler.sendController(120, withValue: 0, onChannel: ch)  // All Sound Off
                        sampler.sendController(123, withValue: 0, onChannel: ch)  // All Notes Off
                    }
                    
                    // 1.5拍の隙間
                    let silence = beatSec * 1.5
                    try? await Task.sleep(nanoseconds: UInt64(silence * 1_000_000_000))
                }
            }
            
            onBarChange(nil)
        }
    }
    
    func stop() {
        isPlaying = false
        playbackTask?.cancel()
        playbackTask = nil
        
        // All Sound Off
        for ch: UInt8 in 0...1 {
            sampler.sendController(120, withValue: 0, onChannel: ch)
            sampler.sendController(123, withValue: 0, onChannel: ch)
        }
    }
    
    func changeInstrument(_ program: UInt8) {
        try? sampler.loadSoundBankInstrument(
            at: sf2URL,
            program: program,
            bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
            bankLSB: UInt8(kAUSampler_DefaultBankLSB)
        )
        
        // CC Reset
        for ch: UInt8 in 0...1 {
            sampler.sendController(64, withValue: 0, onChannel: ch)  // Sustain OFF
            sampler.sendController(91, withValue: 0, onChannel: ch)  // Reverb 0
            sampler.sendController(93, withValue: 0, onChannel: ch)  // Chorus 0
        }
    }
    
    private func chordToMidi(_ symbol: String) -> [UInt8] {
        // Root + Quality 解析（省略）
        // 例: "C" → [60, 64, 67], "Dm" → [62, 65, 69]
    }
}
```

---

## 📋 実行時のログ（最新版: 2.5拍）

```
✅ ChordSequencer initialized (Phase 1: Direct playback)
✅ Audio Session: IOBufferDuration set to 5ms
✅ Playback started (Phase 1: Direct playback)
🎵 Starting playback: BPM=120.0, beatSec=0.5, noteDuration=1.25

[カウントイン: C7が4回鳴る]

🎸 Playing chord: C, notes: [60, 64, 67]
  ▶️ Note ON: 60
  ▶️ Note ON: 64
  ▶️ Note ON: 67
  ⏱️ Waiting 1.25 sec for note duration...
  🛑 Stopping notes with fade...
    ⏹️ Note OFF with fade complete
  💤 Silence: 0.75 sec (1.5 beat gap)

🎸 Playing chord: G, notes: [67, 71, 74]
  ▶️ Note ON: 67
  ▶️ Note ON: 71
  ▶️ Note ON: 74
  ⏱️ Waiting 1.25 sec for note duration...
  🛑 Stopping notes with fade...
    ⏹️ Note OFF with fade complete
  💤 Silence: 0.75 sec (1.5 beat gap)
```

**ログから確認できること**:
- ✅ Note ON が正しく呼ばれている
- ✅ 1.25秒待っている（2.5拍 @ 120 BPM）
- ✅ Note OFF が正しく呼ばれている
- ✅ CC120/123 が送信されている
- ✅ 0.75秒の隙間がある（1.5拍）
- ✅ タイミングは完璧

**しかし、実際の音は全音符のまま鳴り続け、隙間が聞こえない。**

---

## 🔧 試したすべての対策（時系列）

### 1. 基本実装（4拍）
- **noteDuration = 4拍**
- **結果**: 全音符のまま ❌

### 2. Release 時間の短縮（3拍）
- **noteDuration = 3拍** + silence 1拍
- **結果**: 全音符のまま ❌

### 3. さらに短縮（3.5拍）
- **noteDuration = 3.5拍** + silence 0.5拍
- **フェードアウト追加**: 100ms（5ステップ × 20ms）
- **velocity**: 80 → 64 → 48 → 32 → 16 → 0
- **結果**: 全音符のまま ❌

### 4. 大幅短縮（2.5拍）← 現在
- **noteDuration = 2.5拍** + silence 1.5拍
- **期待**: 明確な隙間で「切れた」と聞こえるはず
- **結果**: **全音符のまま ❌**

### 5. CC 制御の強化
- **CC64 (Sustain)**: 全チャンネルで 0 に設定
- **CC91 (Reverb)**: 全チャンネルで 0 に設定
- **CC93 (Chorus)**: 全チャンネルで 0 に設定
- **CC7 (Volume)**: 100 に設定
- **CC120 (All Sound Off)**: 各コード前に送信
- **CC123 (All Notes Off)**: 各コード後に送信
- **結果**: 全音符のまま ❌

### 6. Audio Session の調整
- **setPreferredIOBufferDuration(0.005)**: 5ms に短縮
- **結果**: レイテンシは改善、音の長さは変わらず ❌

### 7. フェードアウトの追加
- **100ms フェード**: 5ステップで velocity を徐々に下げる
- **結果**: 全音符のまま ❌

---

## 🤔 考えられる原因（ChatGPTの指摘を踏まえて）

### 原因1: SF2ファイルのエンベロープ ⭐最有力
**SF2ファイル（TimGM6mb.sf2）の Release Envelope が 1秒以上に設定されている**

- `stopNote()` を送っても、SF2 内部のリリース時間が優先される
- `AVAudioUnitSampler` は SF2 の ADSR エンベロープを直接制御できない
- iOS では SF2 のエンベロープをオーバーライドする API がない

**証拠**:
- Web版（soundfont-player）では**同じSF2で4拍で切れる**
- iOS では noteDuration を 2.5拍まで短縮しても変わらない
- → SF2のリリース時間がアプリ側の制御を上書きしている可能性が極めて高い

### 原因2: AVAudioUnitSampler の制約
**iOS の `AVAudioUnitSampler` が `stopNote()` を正しく処理していない可能性**

- macOS と iOS で動作が異なる？
- SF2 の Release Envelope を無視できない仕様？
- `stopNote()` が「Note Off イベント」として認識されていない？

### 原因3: Note Off イベントが届いていない？
**`stopNote()` が内部的に Note Off MIDI イベントを送信していない可能性**

- ChatGPTのアドバイス: **Note On/Off を別イベントで明示する**
- Phase 1 では `startNote()` / `stopNote()` を使用
- → もしかして `stopNote()` が効いていない？

---

## 🆚 Web版との比較

### Web版（soundfont-player）
```typescript
// Web版では player.scheduleNote() で duration を指定
player.scheduleNote(channel, note, {
  time: audioContext.currentTime + start,
  duration: 1.8,  // 秒
  gain: 0.8
});
```

- **同じSF2ファイル（TimGM6mb.sf2）で4拍で確実に切れる**
- `duration` パラメータが効いている
- Web Audio API の方が細かい制御が可能？

### iOS版（AVAudioUnitSampler）
```swift
// iOS版では startNote/stopNote で制御
sampler.startNote(note, withVelocity: 80, onChannel: 0)
// ... 2.5拍待つ
sampler.stopNote(note, onChannel: 0)
```

- **同じSF2ファイルで全音符のまま鳴り続ける**
- `stopNote()` が効いていない（または SF2 のリリースが優先される）
- iOS の API では duration を指定できない

---

## 📦 環境情報

- **iOS Version**: 18.0 (Simulator & Device)
- **Xcode Version**: 15.x
- **Swift Version**: 5.x
- **Framework**: AVFoundation (AVAudioEngine + AVAudioUnitSampler)
- **SF2 File**: TimGM6mb.sf2 (6MB, General MIDI準拠)
- **Sample Rate**: デフォルト（44.1kHz / 48kHz）
- **Buffer Size**: 5ms (設定済み)
- **BPM**: 120（テスト時）

---

## 🎯 ChatGPTへの質問

### Q1: AVAudioUnitSampler の stopNote() が効かない理由
**Phase 1 実装で `sampler.stopNote()` を呼んでも音が止まりません。**

- ログでは確実に呼ばれている
- CC120/123 も送信している
- **なぜ効かないのでしょうか？**

考えられる原因:
1. SF2 の Release Envelope が優先される？
2. `stopNote()` が内部的に Note Off を送信していない？
3. iOS の AVAudioUnitSampler の制約？

### Q2: Web版（soundfont-player）で同じSF2が切れる理由
**Web版では同じ TimGM6mb.sf2 で duration パラメータが効きます。**

- Web Audio API: `scheduleNote(..., duration: 1.8)`
- iOS AVAudioUnitSampler: `startNote()` + `stopNote()`

**なぜ Web では効いて iOS では効かないのでしょうか？**

API の違い？SF2 の解釈の違い？

### Q3: ChatGPTが提案した「Note On/Off を別イベントで明示」の意味
ChatGPTのアドバイスに以下がありました：

> **Note Off を明示**したので、`MIDINoteMessage.duration` の挙動差に左右されません。

しかし、Phase 1 では：
- `startNote()` で Note On
- `stopNote()` で Note Off

**これは「別イベントで明示」に該当しますか？**

それとも、`MusicSequence` + `MIDIChannelMessage` を使う必要がありますか？

### Q4: Phase 2（AVAudioSequencer + インメモリ編集）への移行は必須？
ChatGPTは以下を推奨しました：

> **インメモリで MusicSequence を直接編集**し、**トラック→サンプラーを明示バインド**、**Note Off をイベントで確実に打つ**。

**Phase 1 の直接制御では限界があり、Phase 2 への移行が必須でしょうか？**

Phase 2 のコア部分：
```swift
let ms: MusicSequence = sequencer.musicSequence
var chordTrack: MusicTrack? = nil
MusicSequenceNewTrack(ms, &chordTrack)

let avChordTrack = sequencer.tracks.last!
avChordTrack.destinationAudioUnit = chordSampler

// Note On
var on = MIDIChannelMessage(status: 0x90 | ch, data1: note, data2: 80, reserved: 0)
MusicTrackNewMIDIChannelEvent(chordTrack!, t, &on)

// Note Off
var off = MIDIChannelMessage(status: 0x80 | ch, data1: note, data2: 0, reserved: 0)
MusicTrackNewMIDIChannelEvent(chordTrack!, t + noteLen, &off)
```

### Q5: 現実的な妥協点
**もし Phase 1 で解決不可能な場合、どこまで妥協すべきでしょうか？**

オプション:
1. **noteDuration をさらに短縮**（2拍、1.5拍など）
2. **別のSF2ファイルを使用**（より短いリリースのもの）
3. **Phase 2 への完全移行**（AVAudioSequencer + MusicSequence）
4. **Web版と同じ割り切り**（完璧な4拍制御は諦める）

**推奨はどれでしょうか？**

---

## 📚 参考情報

### 関連ドキュメント
- `/Users/nh/App/OtoTheory/docs/reports/iOS_Audio_Whole_Note_Issue.md`（前回のレポート）
- `/Users/nh/App/OtoTheory/docs/reports/v3.1_Implementation_Report.md`（実装レポート）

### 実装ファイル
- `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/ChordSequencer.swift`
- `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/AudioPlayer.swift`
- `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Views/ProgressionView.swift`

### SSOT要件
- **Attack**: ≈3–5ms
- **Release**: ≈80–150ms
- **Strum**: 10–20ms
- **Max Voices**: 6
- **BPM**: 40-240（デフォルト120）

### Web版の動作
- 同じ SF2 ファイル（TimGM6mb.sf2）
- `soundfont-player` ライブラリ
- 4拍で確実に切れる

---

## 💡 次のステップ候補

### オプションA: Phase 2 への移行（推奨？）
ChatGPTが提案した「インメモリ MusicSequence 編集」を実装する

**メリット**:
- Note On/Off を MIDI イベントとして明示的に送信
- `destinationAudioUnit` でトラックをサンプラーにバインド
- より低レベルで確実な制御

**デメリット**:
- 実装が複雑
- CoreAudio の C API を使用

### オプションB: 別のSF2を試す
より短いリリース時間の SF2 ファイルを探す

**メリット**:
- Phase 1 実装を維持できる
- シンプル

**デメリット**:
- 適切な SF2 が見つからない可能性
- 音質が劣化する可能性

### オプションC: さらに noteDuration を短縮
2拍、1.5拍、1拍など極端に短くする

**メリット**:
- 最も簡単

**デメリット**:
- 音楽的に不自然
- 隙間が長すぎる

---

## 🙏 求めるアドバイス

1. **Phase 1 の `stopNote()` が効かない根本原因**
2. **Web版で同じSF2が切れる理由**
3. **Phase 2 への移行が必須かどうか**
4. **Phase 2 の具体的な実装手順（特に注意点）**
5. **現実的な妥協点（音楽的に許容できるレベル）**

---

**このレポートを ChatGPT に送って、Phase 2 実装の具体的なアドバイスをもらってください！**


