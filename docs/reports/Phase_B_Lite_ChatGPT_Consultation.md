# Phase B-Lite 実装 — ChatGPT 相談用レポート

**日付**: 2025-10-05  
**問題**: Note Off + CC120/123 を送信しても音が伸び続ける  
**環境**: iOS Simulator (iPhone 16), Xcode, Swift, AVFoundation

---

## 📋 問題の概要

### 症状
- 各コードの音が2秒以上伸び続ける
- 次のコードと音が重なる
- ループ時に音が重なって濁る

### 目標
- 各コードの音を明示的に停止させる
- 次のコードと重ならないようにする
- クリアな音の切り替えを実現

---

## 🔧 実装した内容

### Phase B-Lite のアプローチ

**基本方針**:
1. **Note Duration を明示的に制限** - 各コードのノートを60%（1.2秒）だけ鳴らす
2. **Note Off を明示的に送信** - `stopNote()` で各ノートを停止
3. **CC120/123 を送信** - All Sound Off / All Notes Off

### 実装コード

```swift
// ChordSequencer.swift の play() メソッド内

// 各コードの MIDI ノートを保存
let playedNotes = Array(midiChord.prefix(maxVoices))

// ストラムで発音
for (i, note) in playedNotes.enumerated() {
    let d = (Double(i) * strumMs / 1000.0)
    xfadeQ.asyncAfter(deadline: .now() + d) { [weak nextSampler] in
        nextSampler?.startNote(note, withVelocity: 80, onChannel: 0)
    }
}

// Phase B-Lite: Note Duration を制限（60% = 1.2秒）
let noteDuration = barSec * 0.6  // BPM120で 2.0 * 0.6 = 1.2秒
print("🎵 Phase B-Lite: Note Duration = \(noteDuration)s (60% of \(barSec)s)")

xfadeQ.asyncAfter(deadline: .now() + noteDuration) { [weak nextSampler] in
    print("⏹️ Phase B-Lite: Stopping notes after \(noteDuration)s")
    
    // 明示的に Note Off
    for note in playedNotes {
        nextSampler?.stopNote(note, onChannel: 0)
    }
    
    // CC120: All Sound Off
    nextSampler?.sendController(120, withValue: 0, onChannel: 0)
    nextSampler?.sendController(123, withValue: 0, onChannel: 0)
    
    print("✅ Phase B-Lite: Notes stopped, CC120/123 sent")
}
```

---

## 📊 デバッグ結果

### コンソールログ

```
✅ ChordSequencer initialized with FluidR3_GM.sf2 (Phase B-Lite)
✅ Audio Session: Category=.playback, SampleRate=44100, IOBufferDuration=10ms
🎵 Starting playback (2-Bus Fade): BPM=120, fadeMs=120

[46001ms] Playing chord: C  notes:[60, 64, 67]  bus:A
🎵 Phase B-Lite: Note Duration = 1.2s (60% of 2.0s)
[46138ms] Sampler hard-kill (CCs + AU reset)
⏹️ Phase B-Lite: Stopping notes after 1.2s
✅ Phase B-Lite: Notes stopped, CC120/123 sent

[48128ms] NEXT bus:B  PREV bus:A
[48128ms] Sampler flushed (CC120 + CC123)
[48128ms] Symmetric cross-fade start: 120ms  from:A to:B
[48128ms] Playing chord: G  notes:[67, 71, 74]  bus:B
🎵 Phase B-Lite: Note Duration = 1.2s (60% of 2.0s)
[48262ms] Sampler hard-kill (CCs + AU reset)
⏹️ Phase B-Lite: Stopping notes after 1.2s
✅ Phase B-Lite: Notes stopped, CC120/123 sent

[50017ms] NEXT bus:A  PREV bus:B
[50017ms] Sampler flushed (CC120 + CC123)
[50017ms] Symmetric cross-fade start: 120ms  from:B to:A
[50017ms] Playing chord: Am  notes:[69, 72, 76]  bus:A
🎵 Phase B-Lite: Note Duration = 1.2s (60% of 2.0s)
⏹️ Phase B-Lite: Stopping notes after 1.2s
✅ Phase B-Lite: Notes stopped, CC120/123 sent
```

### ログの解析

✅ **コードは正しく実行されている**:
- `stopNote()` が各ノートに対して呼ばれている
- `CC120` (All Sound Off) が送信されている
- `CC123` (All Notes Off) が送信されている
- タイミングも正確（1.2秒後）

❌ **しかし音は伸び続ける**:
- ユーザー報告: 音が2秒以上伸びる
- 次のコードと重なる
- 濁った音になる

---

## 🎵 オーディオ環境の詳細

### AVAudioUnitSampler の設定

```swift
// SF2 ロード
try sampler.loadSoundBankInstrument(
    at: sf2URL,
    program: 25,  // Acoustic Steel Guitar
    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),  // 0x79
    bankLSB: UInt8(kAUSampler_DefaultBankLSB)           // 0x00
)

// CC 初期化
for ch: UInt8 in 0...15 {
    sampler.sendController(64, withValue: 0, onChannel: ch)  // Sustain OFF
    sampler.sendController(91, withValue: 0, onChannel: ch)  // Reverb 0
    sampler.sendController(93, withValue: 0, onChannel: ch)  // Chorus 0
    sampler.sendController(7, withValue: 100, onChannel: ch) // Volume 100
}
```

### Audio Session

```swift
try AVAudioSession.sharedInstance().setCategory(.playback)
try AVAudioSession.sharedInstance().setPreferredSampleRate(44100)
try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.01)  // 10ms
```

### SF2 ファイル

- **使用中**: `FluidR3_GM.sf2`
- **サイズ**: 不明（Bundle に含まれている）
- **Program 25**: Acoustic Steel Guitar

---

## 🔍 試したこと

### 試行 1: Note Duration 90% (1.8秒)
- **結果**: 音が伸び続ける
- **ログ**: CC120/123 は正しく送信されている

### 試行 2: Note Duration 60% (1.2秒)
- **結果**: 変化なし、音が伸び続ける
- **ログ**: CC120/123 は正しく送信されている

### 試行 3: Clean Build
- Xcode で Product > Clean Build Folder
- 再ビルド・再起動
- **結果**: 変化なし

---

## 🤔 仮説

### 仮説 1: SF2 の Release エンベロープが長い
- `FluidR3_GM.sf2` の Acoustic Steel Guitar (Program 25) は Release が数秒かけてフェードアウトする設計
- `stopNote()` と `CC120` を送信しても、SF2 の内部 Release エンベロープが優先される
- iOS の `AVAudioUnitSampler` は SF2 の Release を尊重する

### 仮説 2: AVAudioUnitSampler の制限
- `stopNote()` は Note Off メッセージを送るだけ
- SF2 の Release フェーズに入るが、すぐに止まらない
- `CC120` (All Sound Off) も SF2 の Release を無視できない

### 仮説 3: 2-Bus クロスフェードとの干渉
- 2つのサンプラー（A/B）を交互に使用
- クロスフェード中に前のバスの音が残る
- `hardKillSampler()` でリセットしているが、Release は止められない

---

## 📝 質問

### Q1: AVAudioUnitSampler で SF2 の Release を強制停止する方法は？

**現在の試み**:
```swift
// Note Off
sampler.stopNote(note, onChannel: 0)

// CC120: All Sound Off
sampler.sendController(120, withValue: 0, onChannel: 0)

// CC123: All Notes Off
sampler.sendController(123, withValue: 0, onChannel: 0)

// AU Reset (hardKillSampler)
sampler.auAudioUnit.reset()
```

**質問**: 上記以外に SF2 の Release を無視して即座に音を止める方法はありますか？

### Q2: 短い Release の SF2 を使うべきか？

`FluidR3_GM.sf2` 以外に、**Release が短い SF2** はありますか？
または、SF2 の Release エンベロープを iOS 側で上書きする方法はありますか？

### Q3: 代替アプローチは？

**オプション A**: AVAudioPlayerNode で PCM を使う
- オフラインレンダリングで PCM バッファを生成
- Release を波形で制御
- **問題**: 前回失敗（SF2 ロードエラー、CPU オーバーロード）

**オプション B**: 音量フェードで疑似停止
```swift
// 音量を 1.0 → 0.0 にフェード（50ms）
for step in 0...10 {
    let volume = 1.0 - Float(step) / 10.0
    sampler.setVolume(volume, onChannel: 0)
    try? await Task.sleep(nanoseconds: 5_000_000)  // 5ms
}
```

**質問**: どのアプローチが最も確実ですか？

---

## 🎯 期待する回答

1. **SF2 の Release を強制停止する方法**（iOS/AVFoundation）
2. **短い Release の SF2 ファイル**の推奨
3. **代替アプローチ**の実装例
4. **根本的な解決策**があれば教えてください

---

## 📎 追加情報

### 環境
- **OS**: macOS 14.6.0
- **Xcode**: 最新版
- **Simulator**: iPhone 16 (iOS 最新版)
- **言語**: Swift 5
- **フレームワーク**: AVFoundation, AudioToolbox

### エラー（参考）
```
HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
```
→ CPU 負荷が高い（Simulator の制限）

---

**最終更新**: 2025-10-05  
**ステータス**: ChatGPT への相談準備完了


