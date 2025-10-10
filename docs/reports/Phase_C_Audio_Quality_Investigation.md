# Phase C: 音色品質調査レポート

**調査日**: 2025/10/10  
**対象**: FluidR3_GM.sf2 の音色品質問題

---

## 🎯 調査対象

### 1. Acoustic Nylon (Program 24)
**問題**: 2拍目・3拍目にドラム音が混入

### 2. Distortion (Program 30)
**問題**: ワウペダル効果（音がうねる）

### 3. Over Drive (Program 29)
**問題**: ワウペダル効果（音がうねる）

---

## 🔍 調査結果

### Acoustic Nylon (Program 24) - ドラム音混入

#### 確認した項目
1. ✅ **MIDI チャンネル**: チャンネル0を使用（正常）
   - チャンネル10（ドラム専用）は使用していない
   
2. ✅ **ノートナンバー**: C3-G3 範囲（48-67）を使用（正常）
   - ドラムキットの範囲（35-81）と重複するが、チャンネルが異なるため問題なし

3. ✅ **Note On/Off タイミング**: ログから確認
   ```
   🎵 Note On: 48 at frame 0       ← 1拍目開始
   🎵 Note On: 52 at frame 661
   🎵 Note On: 55 at frame 1322
   🎵 Note Off: 48 at frame 15435  ← 1拍目終わり（350ms）
   🎵 Note On: 48 at frame 22050   ← 2拍目開始（500ms）← ドラム音が鳴る
   ```

#### 結論
**SF2 ファイルのサンプル自体に問題がある可能性が高い**

FluidR3_GM.sf2 の Program 24 (Nylon String Guitar) のサンプルに、
他の音（ドラム音）が混入している、またはエンベロープ設定が不適切。

---

### Distortion/Over Drive (Program 30/29) - ワウペダル効果

#### 確認した項目
1. ✅ **CC 設定**: Reverb/Chorus/Sustain を全て0に設定（正常）
2. ✅ **Modulation Wheel (CC 1)**: 設定していない（デフォルト0）

#### 推測される原因
- **SF2 ファイルの LFO 設定**: モジュレーションが自動的に適用されている
- **Pitch Bend 感度**: サンプル自体に周期的なピッチ変動がある
- **Filter Cutoff**: フィルターが自動的に開閉している

#### 結論
**FluidR3_GM.sf2 の Distortion/Over Drive サンプルに、
意図しないモジュレーション効果が含まれている**

---

## 💡 解決策

### 方法1: 別の SF2 ファイルを使用 ⭐ 推奨

#### 候補
1. **MuseScore_General.sf2**
   - サイズ: 約35MB
   - 品質: 高品質、クリーンなサンプル
   - ライセンス: MIT License（商用利用可）
   - ダウンロード: https://github.com/musescore/MuseScore/tree/master/share/sound

2. **GeneralUser GS.sf2**
   - サイズ: 約30MB
   - 品質: バランスの良い音質
   - ライセンス: 無料、商用利用可
   - ダウンロード: http://www.schristiancollins.com/generaluser.php

#### 実装手順
1. SF2 ファイルをダウンロード
2. Xcode プロジェクトの `Resources/` に追加
3. `Info.plist` または `Bundle.main` でパスを取得
4. UI で SF2 を切り替えられるようにする（開発中のみ）

---

### 方法2: Program 番号を変更

#### Acoustic Nylon の代替
- **Program 25**: Acoustic Steel（現在使用中、問題なし）
- **Program 42**: Cello（低音域、温かい音色）
- **Program 105**: Banjo（明るい音色）

#### Distortion/Over Drive の代替
- **Program 27**: Electric Clean（現在使用中、問題なし）
- **Program 28**: Electric Muted（現在使用中、問題なし）
- **Program 26**: Electric Jazz Guitar（クリーンな音色）

#### 実装手順
1. `ProgressionView.swift` の `instruments` 配列を更新
2. 新しい Program 番号でテスト
3. 音色名を適切に変更

---

### 方法3: CC でモジュレーションを抑制 ⚠️ 効果不明

#### 試せるCC
```swift
sampler.sendController(1, withValue: 0, onChannel: 0)   // Modulation Wheel
sampler.sendController(71, withValue: 64, onChannel: 0) // Filter Resonance
sampler.sendController(74, withValue: 64, onChannel: 0) // Filter Cutoff
sampler.sendController(76, withValue: 0, onChannel: 0)  // Vibrato Rate
sampler.sendController(77, withValue: 0, onChannel: 0)  // Vibrato Depth
```

#### リスク
- SF2 サンプル自体の問題は解決できない
- 一部のCC は `AVAudioUnitSampler` で無効な可能性

---

## 🎯 推奨アクション

### 短期（今すぐ実装可能）

#### 1. Program 番号を変更してテスト
```swift
// ProgressionView.swift
private let instruments = [
    ("Acoustic Steel", 25),
    // ("Acoustic Nylon ⚠️", 24),  // ← 除外
    ("Acoustic Nylon (Alt)", 105),  // ← Banjo に変更してテスト
    ("Electric Clean", 27),
    ("Electric Muted", 28),
    // Distortion/Over Drive は引き続き除外
    ("Piano", 0)
]
```

#### 2. 追加の CC でモジュレーション抑制を試す
```swift
// GuitarBounceService.swift の CC初期化
sampler.sendController(1, withValue: 0, onChannel: ch)   // Modulation Wheel
sampler.sendController(76, withValue: 0, onChannel: ch)  // Vibrato Rate
sampler.sendController(77, withValue: 0, onChannel: ch)  // Vibrato Depth
```

---

### 中期（Phase C で実装）

#### 3. MuseScore_General.sf2 を導入
1. SF2 ファイルをダウンロード
2. プロジェクトに追加
3. 音色を全てテスト
4. 問題がなければ FluidR3_GM.sf2 から切り替え

**メリット**:
- 高品質なサンプル
- クリーンな音色
- MIT License（商用利用可）

**デメリット**:
- アプリサイズが約35MB増加
- 全ての Program 番号をテストする必要がある

---

### 長期（M4.1+ で実装）

#### 4. カスタム SF2 を作成
- Acoustic Steel (25) のサンプルを使用
- Transpose/Pitch Shift で他の音色を作成
- 完全にコントロールできる小さな SF2 ファイル

---

## 📝 次のステップ

### Phase C-1: 音色品質改善（優先度 HIGH）

1. **即座に実装**: Program 番号変更テスト
   - Acoustic Nylon → Program 105 (Banjo)
   - テスト: ドラム音が消えるか確認

2. **CC 追加テスト**: Modulation/Vibrato を抑制
   - CC 1/76/77 を 0 に設定
   - Distortion/Over Drive でテスト

3. **MuseScore_General.sf2 導入**（効果があれば）
   - ダウンロード・追加
   - 全音色テスト
   - アプリサイズ確認

### Phase C-2: ベース有効化（優先度 MEDIUM）

- HybridPlayer で Bass Sequencer を有効化
- Root/5th パターン実装
- Humanize（±5ms, ±6Vel）追加

### Phase C-3: ドラムパターン（優先度 MEDIUM）

- Rock/Pop/Funk プリセット実装
- 16ステップパターン

---

## 🔧 実装コード（案）

### 1. Program 番号変更

```swift
// ProgressionView.swift
private let instruments = [
    ("Acoustic Steel", 25),
    ("Banjo (Nylon Alt)", 105),  // ← テスト
    ("Electric Clean", 27),
    ("Electric Muted", 28),
    ("Piano", 0)
]
```

### 2. CC 追加

```swift
// GuitarBounceService.swift - CC初期化
for ch: UInt8 in 0...1 {
    sampler.sendController(91, withValue: 0, onChannel: ch)  // Reverb
    sampler.sendController(93, withValue: 0, onChannel: ch)  // Chorus
    sampler.sendController(64, withValue: 0, onChannel: ch)  // Sustain
    sampler.sendController(7, withValue: 100, onChannel: ch) // Volume
    
    // ✅ 追加: モジュレーション抑制
    sampler.sendController(1, withValue: 0, onChannel: ch)   // Modulation Wheel
    sampler.sendController(76, withValue: 0, onChannel: ch)  // Vibrato Rate
    sampler.sendController(77, withValue: 0, onChannel: ch)  // Vibrato Depth
}
```

---

**調査完了。次のステップをユーザーに提案してください。**

