# On Chord MIDI Specification (SSOT)

## 概要

オンコード（スラッシュコード、例：C/E、Am7/G）のベース音を、MIDI Export機能とアプリ内再生の両方に反映させる仕様書。この仕様は全ての実装の基準となる。

## 基本仕様

### 1. オクターブ範囲とクランプ

#### ベーストラック
- **基準音**: C2(36)
- **範囲**: E1(28) ～ C3(48)
- **スラッシュコード**: オンベース音をC2基準で配置

#### ギタートラック
- **基準音**: C4(60)
- **オンベース範囲**: C3(48) ～ G3(55) にクランプ
- **衝突回避**: `(guitarBass - realBass) < 7` なら guitarBass を +12 して1オクターブ上げる

### 2. コード解析仕様

#### ParsedChord構造体
```swift
struct ParsedChord {
    let mainRoot: String   // "C" in "C/E"
    let quality: String    // "maj7" in "Cmaj7/F#"
    let onBass: String?    // "E" in "C/E", nil for regular chords
}
```

#### 解析ルール
- **スラッシュコード**: `"C/E"` → mainRoot="C", quality="", onBass="E"
- **複雑な表記**: `"Cmaj7/F#"` → mainRoot="C", quality="maj7", onBass="F#"
- **異名同音**: `"C#/Bb"` → mainRoot="C#", quality="", onBass="Bb"
- **通常コード**: `"Am7"` → mainRoot="A", quality="m7", onBass=nil

### 3. MIDI Export仕様

#### ギタートラック
- **ボイシング**: オンベース（最低音）+ メインコードの構成音
- **例**: `C/E` → [E3, C4, E4, G4] (E3はクランプ適用)
- **Voice Leading**: 上声部のみで最小移動距離を計算、オンベースは固定

#### ベーストラック
- **パターン**: 三段階安全弁システム
  1. **コードトーン内のオンベース** → オンベース ↔ メインルートの5度
  2. **非コードトーン** → オンベース4つ打ち
  3. **半音/全音接続** → ウォーク（経過音挿入）

#### 具体例
- **C/E**: ギター[E3,C4,E4,G4], ベース[E2↔G2]
- **Am7/G**: ギター[G3,A4,C5,E5,G5], ベース[G2↔E2]
- **Cmaj7/F#**: ギター[F#3,C4,E4,G4,B4], ベース[F#2×4]

### 4. アプリ内再生仕様

#### BassBounceService
- **ベース音抽出**: スラッシュコードの場合はオンベース、通常コードはルート
- **オクターブ**: C2(36)基準
- **例**: `Am7/G` → G2(43)

#### GuitarBounceService
- **ボイシング**: オンベース（最低音）+ メインコードの構成音
- **クランプ**: C3(48)～G3(55)範囲に制限
- **例**: `C/E` → [E3,C4,E4,G4] (E3はクランプ適用)

#### ChordSequencer
- **ボイシング**: GuitarBounceServiceと同様
- **用途**: レガシー再生エンジン

## 実装ファイル

### 1. MIDIExportService.swift
- `ParsedChord`構造体定義
- `parseChordSymbol()`: 統一パーサ
- `parseNoteToMIDI()`: ノート名→MIDI番号変換
- `clampGuitarBass()`: オクターブクランプ
- `isBassInChordTones()`: コードトーン判定
- `addBassLineEvents()`: ベーストラック生成（三段階安全弁）
- `parseChordVoicing()`: ギタートラック生成（Voice Leading）

### 2. BassBounceService.swift
- `chordToBassRoot()`: ベース音抽出（スラッシュ対応）
- `noteNameToMIDI()`: オクターブ指定変換

### 3. GuitarBounceService.swift
- `chordToMidi()`: ギターボイシング生成（クランプ付き）
- `noteNameToPitchClass()`: ピッチクラス変換

### 4. ChordSequencer.swift
- `chordToMidi()`: レガシー再生用ボイシング

## テスト仕様

### 1. 基本テストケース
- **C/E**: ギター[E3,C4,E4,G4], ベース[E2↔G2]
- **Am7/G**: ギター[G3,A4,C5,E5,G5], ベース[G2↔E2]
- **Cmaj7/F#**: ギター[F#3,C4,E4,G4,B4], ベース[F#2×4]

### 2. 複雑な表記テスト
- **C#/Bb**: シャープ・フラット表記
- **Cmaj7/F#**: 複合コード
- **Dm7b5/G**: テンション付き

### 3. エッジケース
- **通常コード**: `C`, `Am7` → 従来通り
- **無効な表記**: フォールバック処理
- **オクターブ衝突**: クランプ適用

## 制約事項

### 1. オクターブ制限
- ベース: E1(28) ～ C3(48)
- ギターオンベース: C3(48) ～ G3(55)
- 衝突時: ギターオンベースを+12

### 2. パフォーマンス
- キャッシュキー: コード文字列全体
- LRUサイズ: 32エントリ
- 正規化: 異名同音統一

### 3. 後方互換性
- 通常コードは従来通り
- Proガード判定維持
- 既存API変更なし

## バージョン管理

- **v1.0**: 初回実装（2024-10-20）
- **対象**: MIDI Export + アプリ内再生
- **範囲**: 全スラッシュコード対応

## 更新履歴

- 2024-10-20: 初版作成、実装完了
- 仕様変更時は必ずこの文書を更新し、全実装ファイルを同期する

---

**注意**: この仕様書は全ての実装の基準となる。仕様変更時は必ずこの文書を更新し、関連する全ファイルを同期すること。
