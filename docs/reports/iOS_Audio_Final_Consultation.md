# iOS オーディオ問題 — ChatGPT 最終相談用レポート

**日付**: 2025-10-05  
**問題**: iOS アプリでコード再生時に音が伸び続ける  
**環境**: iOS 18.0, Swift, AVFoundation, Xcode 16

---

## 📋 問題の概要

### 現象
- コード（C, G, Am, F など）を再生すると、**音が2秒以上伸び続ける**
- 次のコードの音と重なって濁る
- ループ時に前の音が残っている

### 期待される動作
- 各コードが **2.0秒（4拍 @ 120BPM）で完全に止まる**
- 次のコードと重ならない
- ループで隙間がない

---

## 🔧 試した解決策（すべて失敗）

### Phase 1: 2-Bus Fade-Out Method

**実装内容**:
```swift
// 2つのサンプラーを交互に使用
var samplerA: AVAudioUnitSampler
var samplerB: AVAudioUnitSampler
var currentSampler: AVAudioUnitSampler { isUsingA ? samplerA : samplerB }
var nextSampler: AVAudioUnitSampler { isUsingA ? samplerB : samplerA }

// コード再生時
func playChord() {
    // 1. 前のサンプラーをフェードアウト
    fadeOut(sampler: currentSampler, duration: 0.3)
    
    // 2. 次のサンプラーで新しいコードを再生
    for note in midiNotes {
        nextSampler.startNote(note, withVelocity: 80, onChannel: 0)
    }
    
    // 3. サンプラーを切り替え
    isUsingA.toggle()
}

// フェードアウト実装
func fadeOut(sampler: AVAudioUnitSampler, duration: Double) {
    // outputVolume を使用
    sampler.outputVolume = 1.0
    
    let steps = 30
    let stepDuration = duration / Double(steps)
    
    for i in 0..<steps {
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
            sampler.outputVolume = 1.0 - Float(i) / Float(steps)
        }
    }
    
    // 最後に CC120/123 を送信
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        sampler.sendMIDIEvent(0xB0, data1: 120, data2: 0)  // All Sound Off
        sampler.sendMIDIEvent(0xB0, data1: 123, data2: 0)  // All Notes Off
    }
}
```

**結果**: ❌ 失敗
- `DispatchQueue.asyncAfter` のタイミングが不正確
- SF2 の Release エンベロープが長すぎて止まらない
- `outputVolume` のフェードが効かない

---

### Phase 2: AVAudioSequencer Full Migration

**実装内容**:
```swift
// MusicSequence を使用
var musicSequence: MusicSequence?
var musicPlayer: MusicPlayer?

func playChord() {
    // 1. MusicSequence を作成
    NewMusicSequence(&musicSequence)
    
    // 2. トラックを追加
    var track: MusicTrack?
    MusicSequenceNewTrack(musicSequence!, &track)
    
    // 3. Note On/Off イベントを追加
    for note in midiNotes {
        var noteMessage = MIDINoteMessage(
            channel: 0,
            note: note,
            velocity: 80,
            releaseVelocity: 0,
            duration: 1.2  // 4拍の60% = 1.2秒
        )
        MusicTrackNewMIDINoteEvent(track!, 0.0, &noteMessage)
    }
    
    // 4. CC120/123 を追加（1.2秒後）
    var cc120 = MIDIChannelMessage(status: 0xB0, data1: 120, data2: 0, reserved: 0)
    MusicTrackNewMIDIChannelEvent(track!, 1.2, &cc120)
    
    // 5. 再生
    MusicPlayerSetSequence(musicPlayer!, musicSequence!)
    MusicPlayerStart(musicPlayer!)
}
```

**結果**: ❌ 失敗
- `duration` を短くしても SF2 の Release が優先される
- CC120/123 を送信しても音が止まらない
- カウントインとループが正常に動作しない

---

### Phase 3 (A案): Hybrid Audio Architecture

**実装内容**:
```swift
// GuitarBounceService: オフラインレンダリングでPCMバッファを生成
class GuitarBounceService {
    func buffer(for chord: String, sf2URL: URL) throws -> AVAudioPCMBuffer {
        let engine = AVAudioEngine()
        let sampler = AVAudioUnitSampler()
        
        // 1. エンジンをセットアップ
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: format)
        
        // 2. オフラインモード有効化
        try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: 4096)
        
        // 3. エンジン起動
        try engine.start()
        
        // 4. SF2 ロード ← ここで失敗！
        try sampler.loadSoundBankInstrument(
            at: sf2URL,
            program: 25,
            bankMSB: 0x00,
            bankLSB: 0x00
        )
        
        // 5. ノート発音 + レンダリング
        // ...
    }
}
```

**結果**: ❌ 失敗
- **エラー -10851**: SF2 ロード失敗
- `AVAudioUnitSampler.loadSoundBankInstrument()` は `enableManualRenderingMode(.offline)` と互換性なし
- シミュレータでも実機でも同じエラー

---

## 🔍 根本原因の分析

### SF2 の Release エンベロープ
- 使用している SF2: `FluidR3_GM.sf2`
- Program 25 (Acoustic Guitar Steel) の Release が長い（推定 2-3秒）
- iOS の `AVAudioUnitSampler` は **Release エンベロープを外から変更できない**

### iOS の制限
1. `stopNote()` は Note-Off を送信するだけで、強制停止ではない
2. CC120 (All Sound Off) も SF2 の Release を無視できない
3. `outputVolume` のフェードは Release 中の音に効かない
4. `enableManualRenderingMode(.offline)` では `AVAudioUnitSampler` を使用不可

---

## 💡 試していない解決策

### 代替案A: フルPCM方式（ChatGPT 推奨）

**概要**: SF2 を一切使わず、全ての楽器をPCMで事前レンダリング

**実装方法**:
1. ギター/ベース/ドラムを全て別々の `AVAudioEngine`（**リアルタイムモード**）でレンダリング
2. 各楽器ごとに1小節分のPCMバッファを生成
3. 末尾120msを線形フェードアウト
4. 生成したバッファを `AVAudioPlayerNode` で再生
5. LRU キャッシュで効率化

**期待される効果**:
- ✅ 音が2.0秒で完全に止まる（確実）
- ✅ SF2 の Release に依存しない
- ✅ タイミング精度が最高

**懸念点**:
- ❌ リアルタイムモードでのレンダリングが必要（オフラインモード不可）
- ❌ メモリ使用量が増加
- ❌ 初回レンダリングに時間がかかる

---

### 代替案B: 短リリースSF2

**概要**: FluidR3_GM の代わりに短リリース版の SF2 を使用

**実装方法**:
1. 短リリース版の SF2 を探す（Release < 100ms）
2. ライセンスを確認
3. SF2 ファイルを差し替え

**期待される効果**:
- ✅ 音が早く止まる（完全ではない）
- ✅ 実装変更は不要

**懸念点**:
- ❌ 短リリース版の SF2 の入手が困難
- ❌ 音質が劣化する可能性
- ❌ 完全に止めることは困難

---

## 🤔 ChatGPT への質問

### Q1: リアルタイムモードでのPCMレンダリング

**状況**:
- `enableManualRenderingMode(.offline)` では `AVAudioUnitSampler` が使えない
- リアルタイムモードでPCMバッファを生成する方法はあるか？

**質問**:
1. リアルタイムモードの `AVAudioEngine` でPCMバッファを録音する方法は？
2. `AVAudioEngine.installTap(onBus:bufferSize:format:block:)` を使えば良いか？
3. 録音中に他の音が混ざらないようにする方法は？
4. パフォーマンスへの影響は？

---

### Q2: 代替案Aの実装方法

**質問**:
1. リアルタイムモードで1小節分のPCMバッファを生成する具体的なコード例は？
2. `AVAudioEngine` を起動 → SF2ロード → ノート発音 → 録音 → 停止 の流れで良いか？
3. 録音したバッファに末尾フェードを適用する方法は？
4. 複数の楽器（ギター/ベース/ドラム）を同時にレンダリングする方法は？

---

### Q3: 短リリースSF2の推奨

**質問**:
1. 短リリース版の SF2 でおすすめはあるか？
2. Release < 100ms のアコースティックギター音源は？
3. ライセンスフリーで商用利用可能なものは？

---

### Q4: その他の解決策

**質問**:
1. `AVAudioUnitSampler` 以外の音源（`AVAudioUnitMIDISynth` など）は使えるか？
2. iOS の他のオーディオ API（AudioToolbox, Core Audio など）で解決できるか？
3. Web Audio API を iOS に移植する方法は？（WKWebView 経由？）

---

## 📊 現在のコード構造

### ChordSequencer.swift（現在使用中）

```swift
final class ChordSequencer {
    private let engine = AVAudioEngine()
    private let samplerA = AVAudioUnitSampler()
    private let samplerB = AVAudioUnitSampler()
    private var isUsingA = true
    
    init(sf2URL: URL) throws {
        // エンジンセットアップ
        engine.attach(samplerA)
        engine.attach(samplerB)
        engine.connect(samplerA, to: engine.mainMixerNode, format: format)
        engine.connect(samplerB, to: engine.mainMixerNode, format: format)
        
        // SF2ロード
        try samplerA.loadSoundBankInstrument(at: sf2URL, program: 25, bankMSB: 0x00, bankLSB: 0x00)
        try samplerB.loadSoundBankInstrument(at: sf2URL, program: 25, bankMSB: 0x00, bankLSB: 0x00)
        
        // エンジン起動
        try engine.start()
    }
    
    func play(chords: [String], program: UInt8, bpm: Double, onBarChange: @escaping (Int) -> Void) {
        let barSec = 60.0 / bpm * 4.0  // 2.0秒 @ 120BPM
        
        for (index, chord) in chords.enumerated() {
            let delay = barSec * Double(index)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.playChord(chord, program: program)
                onBarChange(index)
            }
        }
    }
    
    private func playChord(_ chord: String, program: UInt8) {
        let notes = chordToMidi(chord)
        
        // 前のサンプラーをフェードアウト（効果なし）
        fadeOut(sampler: currentSampler, duration: 0.3)
        
        // 次のサンプラーで新しいコードを再生
        for note in notes {
            nextSampler.startNote(note, withVelocity: 80, onChannel: 0)
        }
        
        isUsingA.toggle()
    }
}
```

---

## 📝 期待される回答

1. **リアルタイムモードでのPCMレンダリング方法**（具体的なコード例）
2. **代替案Aの実装手順**（ステップバイステップ）
3. **短リリースSF2の推奨**（具体的なファイル名/URL）
4. **その他の解決策**（もしあれば）

---

## 🔗 参考資料

- [Apple Developer Forums: AVAudioUnitSampler in offline mode](https://developer.apple.com/forums/)
- [過去のChatGPT相談](../reports/ChatGPT_Solution_Hybrid_Audio_Fix.md)
- [A案実装結果](../reports/A_Plan_Implementation_Result.md)
- [失敗分析レポート](../reports/Hybrid_Audio_Failure_Analysis.md)

---

**最終更新**: 2025-10-05  
**ステータス**: 解決策を模索中、ChatGPT に最終相談

