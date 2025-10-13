# M4-E: Fretboard & Diatonic Table 実装プラン

**作成日**: 2025-10-12  
**優先度**: **最高（必須機能）**  
**対象**: OtoTheory iOS v1.0 - コア機能実装

---

## 🚨 現状の問題

### 欠落している必須機能

1. **Fretboard（フレットボード）**: 完全に未実装
2. **Diatonic Table（ダイアトニックテーブル）**: 完全に未実装
3. **セクション別コード進行**: UIのみ、実際の機能は未実装

### 現在のiOS実装状態

```
FindChordsView:
  ✅ Key/Scale選択UI
  ❌ Diatonic Table
  ❌ Fretboard
  ❌ Scale Table
  ❌ Chord Forms
  ❌ Basic Substitutes

ProgressionView:
  ✅ 12スロットUI
  ✅ コード選択・再生
  ✅ Key/Scale分析（候補5つ）
  ❌ Fretboard
  ❌ Diatonic Table
  ✅ Section UI（範囲指定のみ）
  ❌ Section別コード進行機能
```

---

## 📋 実装要件（SSOT準拠）

### 1. Fretboard（二層Overlay）

**Web版の仕様**（`ototheory-web/src/components/Fretboard.tsx`）:

- **二層Overlay システム**:
  - **Scale層**：ゴースト表示（小さい、薄い、輪郭のみ）
  - **Chord層**：メイン表示（大きい、塗りつぶし、ラベル付き）
  
- **表示モード切り替え**:
  - `Degrees`：度数表示（1, 2, 3, b3, 5, b7, etc.）
  - `Names`：音名表示（C, D, E, F, G, etc.）

- **Reset機能**:
  - **Chordのみリセット**（Scale層は保持）
  
- **インタラクション**:
  - タップ：単音試聴
  - 長押し：Chord Forms表示（将来実装）

- **レイアウト**:
  - 6弦（E-B-G-D-A-E）
  - 15フレット
  - Open string（開放弦）マーカー
  - フレット番号ドット（3, 5, 7, 9, 12, 15）
  - ナット（太線）

- **色システム**:
  - Root: 特別色（強調）
  - 3rd: 色1
  - 5th: 色2
  - 7th: 色3
  - その他スケール音: 基本色

### 2. Diatonic Table

**Web版の仕様**（`ototheory-web/src/components/DiatonicCapoTable.tsx`）:

- **ダイアトニックコード表示**:
  - I - II - III - IV - V - VI - VII
  - Major/Minor/Diminished表示
  - Roman数字表記

- **Open行**:
  - タップで和音試聴
  - Chord層に強調表示（Fretboardと連動）
  
- **Capo行**（折りたたみ）:
  - Top 2のみ表示（Shaped表記）
  - 音は鳴らさない
  - 注記: "Shaped=fingered / Sounding=actual"

- **非ヘプタ対応**:
  - Pentatonic/Blues: Roman表示（例外）
  - その他: Roman非表示

### 3. セクション別コード進行（Pro機能）

**現在の実装**（間違い）:
```swift
struct Section {
    var name: SectionType  // Verse, Chorus, etc.
    var range: ClosedRange<Int>  // 1つの進行の範囲を指定
    var repeatCount: Int
}
```

**正しい仕様**:
```swift
struct Section {
    var name: SectionType  // Verse, Chorus, etc.
    var chords: [String]  // セクション固有のコード進行
    var repeatCount: Int
}

// 曲全体の構造
struct SongStructure {
    var sections: [Section]  // 各セクションが独立した進行を持つ
}

// 例:
[
  Section(name: .verse, chords: ["C", "Am", "F", "G"], repeatCount: 2),
  Section(name: .chorus, chords: ["F", "G", "C", "Am"], repeatCount: 1),
  Section(name: .verse, chords: ["C", "Am", "F", "G"], repeatCount: 1),
  Section(name: .bridge, chords: ["Dm", "Em", "Am", "G"], repeatCount: 1)
]
```

---

## 🎯 実装計画

### Phase E-1: Fretboard コンポーネント（最優先）

**推定工数**: 2-3日

#### E-1.1: FretboardView 基本実装
- [ ] `FretboardView.swift` 作成
- [ ] SwiftUI Canvas描画システム
- [ ] 6弦×15フレットのレイアウト
- [ ] Open string マーカー
- [ ] フレット番号ドット
- [ ] ナット線

#### E-1.2: 二層Overlay システム
- [ ] `FretboardOverlay` モデル作成
```swift
struct FretboardOverlay {
    // Scale layer (ghost)
    var scaleRootPc: Int?
    var scaleType: String?
    var showScaleGhost: Bool = true
    
    // Chord layer (main)
    var chordNotes: [String]?  // e.g. ["C", "E", "G"]
    
    // Display mode
    var display: DisplayMode = .degrees  // .degrees or .names
    
    enum DisplayMode {
        case degrees  // 1, 2, 3, etc.
        case names    // C, D, E, etc.
    }
}
```

#### E-1.3: 音階ロジック統合
- [ ] `TheoryBridge`から`getScalePitches`呼び出し
- [ ] 度数計算（`degreeLabelFor`）
- [ ] 色付けロジック（Root/3rd/5th/7th）

#### E-1.4: インタラクション
- [ ] タップで単音試聴（`AVAudioEngine`連携）
- [ ] Reset機能（Chordのみクリア）
- [ ] Degrees/Names トグル

**DoD（E-1）**:
- ✅ 6弦×15フレットのフレットボード表示
- ✅ Scale層（ゴースト）+ Chord層（メイン）の二層表示
- ✅ Degrees/Names切り替え
- ✅ タップで単音試聴
- ✅ Resetボタン（Chordのみクリア）

---

### Phase E-2: Diatonic Table コンポーネント

**推定工数**: 1-2日

#### E-2.1: DiatonicTableView 基本実装
- [ ] `DiatonicTableView.swift` 作成
- [ ] I-VII Roman数字表示
- [ ] Major/Minor/Diminished表示
- [ ] `TheoryBridge`から`getDiatonicChords`呼び出し

#### E-2.2: Open行インタラクション
- [ ] タップで和音試聴
- [ ] Fretboardと連動（Chord層更新）
- [ ] 選択状態の視覚フィードバック

#### E-2.3: Capo行（折りたたみ）
- [ ] Top 2 Capo提案表示
- [ ] Shaped表記
- [ ] 注記表示
- [ ] 音は鳴らさない（無効化）

#### E-2.4: 非ヘプタ対応
- [ ] Pentatonic/Blues: Roman表示
- [ ] その他: Roman非表示

**DoD（E-2）**:
- ✅ I-VII ダイアトニックコード表示
- ✅ Open行タップで和音試聴
- ✅ Fretboardと連動（Chord層更新）
- ✅ Capo Top 2表示（折りたたみ）
- ✅ 非ヘプタ対応

---

### Phase E-3: FindChordsView統合

**推定工数**: 1日

#### E-3.1: レイアウト統合
- [ ] Key/Scale選択
- [ ] ↓
- [ ] Diatonic Table
- [ ] ↓
- [ ] Fretboard（二層Overlay）
- [ ] ↓
- [ ] Scale Table（将来実装）
- [ ] ↓
- [ ] Chord Forms（将来実装）

#### E-3.2: 状態管理
- [ ] `@State var selectedKey`
- [ ] `@State var selectedScale`
- [ ] `@State var selectedChord`（Diatonic選択）
- [ ] `@State var fretboardOverlay: FretboardOverlay`

**DoD（E-3）**:
- ✅ Key/Scale選択 → Diatonic更新
- ✅ Diatonicタップ → Fretboard Chord層更新
- ✅ Degrees/Names切り替え動作
- ✅ Reset動作

---

### Phase E-4: ProgressionView統合

**推定工数**: 1日

#### E-4.1: 結果カード統合
- [ ] Key/Scale分析結果の下にFretboard表示
- [ ] 選択中のコード → Fretboard Chord層に反映
- [ ] Diatonic Table表示（折りたたみ可）

#### E-4.2: インタラクション
- [ ] コード選択 → Fretboard更新
- [ ] Diatonicタップ → コード追加（+Add機能）
- [ ] Scale変更 → Fretboard更新

**DoD（E-4）**:
- ✅ 分析結果にFretboard表示
- ✅ コード選択とFretboard連動
- ✅ Diatonic Table統合

---

### Phase E-5: セクション別コード進行（Pro機能）

**推定工数**: 2-3日

#### E-5.1: データモデル再設計
- [ ] `Section`モデル修正
```swift
struct Section: Identifiable, Codable {
    let id: UUID
    var name: SectionType
    var chords: [String]  // セクション固有の進行
    var repeatCount: Int
}
```

#### E-5.2: SectionEditorView 再実装
- [ ] セクションごとのコード編集UI
- [ ] 12スロット×セクション数
- [ ] セクション追加・削除・並べ替え
- [ ] コード進行編集（各セクション独立）

#### E-5.3: 再生ロジック
- [ ] セクション順序での再生
- [ ] リピート回数対応
- [ ] セクション単位のループ

#### E-5.4: MIDI Export統合
- [ ] セクション別データをMIDI Markersに反映
- [ ] 各セクションの進行を正しく出力

**DoD（E-5）**:
- ✅ セクションごとに異なるコード進行を設定可能
- ✅ セクション順序で再生
- ✅ リピート回数動作
- ✅ MIDI Export対応

---

## 📊 実装優先順位

| Phase | 機能 | 優先度 | 工数 | 理由 |
|-------|------|--------|------|------|
| **E-1** | Fretboard | ★★★★★ | 2-3日 | SSOT必須、コア体験 |
| **E-2** | Diatonic Table | ★★★★★ | 1-2日 | SSOT必須、Fretboardと連動 |
| **E-3** | FindChords統合 | ★★★★☆ | 1日 | M3パリティ達成 |
| **E-4** | Progression統合 | ★★★★☆ | 1日 | M3パリティ達成 |
| **E-5** | Section別進行 | ★★★☆☆ | 2-3日 | Pro機能、既にUI有り |

**合計工数**: 7-10日

---

## 🎯 マイルストーン

### Week 1: Fretboard + Diatonic
- Day 1-3: **E-1 Fretboard**
- Day 4-5: **E-2 Diatonic Table**
- **Milestone**: コア可視化機能完成

### Week 2: 統合 + Section
- Day 1: **E-3 FindChords統合**
- Day 2: **E-4 Progression統合**
- Day 3-5: **E-5 Section別進行**
- **Milestone**: M4完全達成

---

## 🔧 技術実装詳細

### Fretboard描画（SwiftUI Canvas）

```swift
struct FretboardView: View {
    let strings = ["E", "B", "G", "D", "A", "E"]  // High to low
    let frets = 15
    let overlay: FretboardOverlay
    
    var body: some View {
        Canvas { context, size in
            // Draw strings (horizontal lines)
            // Draw frets (vertical lines)
            // Draw nut (thick line)
            // Draw fret dots (3, 5, 7, 9, 12, 15)
            // Draw overlays (scale ghost + chord main)
        }
        .gesture(TapGesture().onEnded { location in
            // Calculate string/fret from tap location
            // Play note
        })
    }
}
```

### TheoryBridge連携

```swift
// Get scale pitches
let scalePitches = theoryBridge.getScalePitches(key: "C", scale: "Ionian")

// Get diatonic chords
let diatonicChords = theoryBridge.getDiatonicChords(key: "C", scale: "Ionian")

// Calculate degree label
let degree = theoryBridge.degreeLabelFor(note: "E", key: "C", scale: "Ionian")
```

### Section データフロー

```
SectionEditorView
  ↓ (sections: [Section])
ProgressionView
  ↓ (flatten sections to timeline)
HybridPlayer
  ↓ (play with section markers)
MIDIExportService
  ↓ (add section markers to MIDI)
```

---

## 🚀 次のアクション

1. **即座に開始**: Phase E-1（Fretboard）
2. **Web版参照**: `ototheory-web/src/components/Fretboard.tsx`を徹底分析
3. **ビジュアルテスト**: 各フェーズでスクリーンショット確認
4. **SSOT準拠**: 二層Overlay、Degrees/Names、Reset=Chordのみ

---

## 📝 備考

- **Web版とのパリティ必須**: iOS版がWeb版より劣っていることは許容されない
- **二層Overlayは差別化要因**: 他のコード進行アプリにはない独自機能
- **Section別進行はPro価値の核**: DAWユーザーに不可欠

---

**承認**: 実装プラン確認後、Phase E-1から開始します。🎸

