# Phase 2: セクション編集実装レポート

**作成日**: 2025-10-11  
**対象**: OtoTheory iOS M4-B Pro機能実装 Phase 2

---

## ✅ 実装完了項目

### 1. **Section.swift** - セクションモデル
- **パス**: `/OtoTheory-iOS/OtoTheory/Models/Section.swift`
- **機能**:
  - `Section`構造体（`id`, `name`, `range`, `repeatCount`）
  - `SectionType`列挙型（Intro, Verse, Pre-Chorus, Chorus, Bridge, Solo, Outro, Interlude, Breakdown）
  - バリデーション（`isValid`, `overlaps`）
  - 配列拡張（`areAllValid`, `sortedByRange`, `section(at:)`）
  - Codable対応（ClosedRange<Int>のカスタムエンコーディング）

### 2. **Sketch.swift** - セクション永続化
- **パス**: `/OtoTheory-iOS/OtoTheory/Models/Sketch.swift`
- **変更**:
  - `sections: [Section]`プロパティ追加
  - デフォルト値は空配列

### 3. **SectionEditorView.swift** - セクション編集UI
- **パス**: `/OtoTheory-iOS/OtoTheory/Views/SectionEditorView.swift`
- **機能**:
  - セクション一覧表示（`SectionRow`）
  - セクション追加・編集・削除
  - ドラッグ並べ替え（`.onMove`）
  - セクション詳細編集（`SectionDetailView`）:
    - セクションタイプ選択（Picker）
    - 範囲設定（Start/End Bar）
    - リピート回数設定（1～8回）
    - 重複チェック（バリデーション）
  - ContentUnavailableView（空状態）

### 4. **ProgressionView** - セクション編集統合
- **パス**: `/OtoTheory-iOS/OtoTheory/Views/ProgressionView.swift`
- **変更**:
  - `@State private var sections: [Section] = []`追加
  - `@State private var showSectionEditor = false`追加
  - **Sectionsボタン追加**（Pro専用）:
    - Proユーザー: セクション編集画面を表示
    - Freeユーザー: Paywallを表示
    - セクション数表示（`(n)`）
  - `.sheet(isPresented: $showSectionEditor)`追加
  - **セクションマーカー表示**:
    - スクロール可能な横並び表示
    - セクション名、範囲、リピート回数を表示
    - アイコン付き

### 5. **SectionMarker** - マーカーUI
- **コンポーネント**:
  - セクション名
  - バー範囲（"Bars 1-4"）
  - リピートアイコン（`repeat ×n`）
  - 青い枠線＋背景

---

## 📊 アーキテクチャ

### セクション編集フロー

```
ProgressionView
  ↓ (Sectionsボタンタップ - Pro専用)
SectionEditorView (sheet)
  ├─ Section一覧（ドラッグ並べ替え可）
  ├─ 追加ボタン (+)
  └─ セクションタップ or 追加
      ↓
  SectionDetailView (sheet)
    ├─ セクションタイプ選択
    ├─ 範囲設定（Start/End Bar）
    ├─ リピート回数設定
    └─ 保存（重複チェック）
```

### データモデル

```
Sketch
  └─ sections: [Section]
      ├─ id: UUID
      ├─ name: SectionType (Verse, Chorus, etc.)
      ├─ range: ClosedRange<Int> (0...3)
      └─ repeatCount: Int (1～8)
```

### Pro分岐

```
ProgressionView - Sectionsボタン
  ├─ proManager.isProUser == true
  │   └─ showSectionEditor = true
  └─ proManager.isProUser == false
      └─ showPaywall = true
```

---

## 🎨 UI/UX

### 1. **Sectionsボタン**
- 位置: PresetボタンとResetボタンの間
- アイコン: `square.grid.3x2`
- セクション数バッジ: `(3)`（セクションがある場合）
- Pro専用（Freeユーザーはタップでpaywall）

### 2. **セクションマーカー**
- スロットグリッドの上に表示
- 横スクロール可能
- 各セクション:
  - アイコン（セクションタイプ別）
  - 名前（"Verse", "Chorus"等）
  - 範囲（"Bars 1-4"）
  - リピート（×2等、1回の場合は非表示）
- 青い枠線＋淡い背景

### 3. **SectionEditorView**
- ナビゲーションバー:
  - 左: "Done"ボタン
  - 右: "+"ボタン、Editボタン
- セクション一覧:
  - アイコン＋名前＋範囲
  - リピートアイコン（×n）
  - 右矢印（タップで編集）
- 空状態: ContentUnavailableView

### 4. **SectionDetailView**
- Form形式
- 3セクション:
  - "Section Type": Picker（9種類）
  - "Range": Start/End Bar（Stepper）
  - "Repeat": 1～8回（Stepper）
- 保存ボタン
- エラーアラート（重複チェック）

---

## 🧪 テスト項目

### ✅ ビルド成功
```bash
xcodebuild -project OtoTheory.xcodeproj -scheme OtoTheory \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build
```
**結果**: BUILD SUCCEEDED

### 🔜 手動テスト（次ステップ）
1. **セクション編集UI**:
   - ProgressionView → Sectionsボタン → SectionEditorView表示
   - 追加ボタン → SectionDetailView → セクション追加
   - セクションタップ → 編集 → 保存
   - セクション削除（スワイプ）
   - セクション並べ替え（ドラッグ）
2. **Pro分岐**:
   - Freeユーザー: Sectionsボタン → Paywall表示
   - Proユーザー: Sectionsボタン → SectionEditorView表示
3. **セクションマーカー**:
   - セクション追加後、ProgressionViewにマーカー表示
   - マーカーが横スクロール可能
   - リピート回数が正しく表示
4. **バリデーション**:
   - 重複範囲のセクション追加 → エラー表示
   - 無効な範囲（Start > End） → エラー表示

---

## 🔜 Phase 2.5: セクション再生機能（後続タスク）

**Phase 2では、セクション編集UIのみ実装済み。再生機能は後続フェーズで実装**

### 実装予定内容
1. **HybridPlayer拡張**:
   - セクション指定再生
   - セクションリピート
   - セクション境界での自動切り替え
2. **ProgressionView統合**:
   - セクション選択UI（再生するセクションを選択）
   - セクションループUI（現在のセクションをリピート）
3. **UI同期**:
   - 現在再生中のセクションをハイライト
   - セクション境界でマーカー更新

---

## 📝 次フェーズへの準備

### Phase 3: MIDI出力
- **Section Markers書き出し**（Phase 2で実装済みのセクション情報を使用）
- Chord Track生成
- Guide Tones生成（3rd + 7th）
- SMF Type-1書き出し

### Phase 4: Sketch無制限 & クラウド同期
- CloudKit統合
- セクション情報も含めて同期

### Phase 5: プリセット拡張
- Pro専用プリセット30種を追加

---

## 🎯 受け入れ基準（DoD）

| 項目 | ステータス |
|------|-----------|
| Sectionモデル実装 | ✅ 完了 |
| Sketchにsections追加 | ✅ 完了 |
| SectionEditorView実装 | ✅ 完了 |
| ProgressionViewにSectionsボタン追加 | ✅ 完了 |
| セクションマーカー表示 | ✅ 完了 |
| Pro分岐（Sectionsボタン） | ✅ 完了 |
| ビルド成功 | ✅ 完了 |
| セクション再生・ループ機能 | 🔜 Phase 2.5で実装予定 |

---

## 🚀 次のアクション

1. **Xcodeでアプリ起動** → セクション編集UI確認
2. **セクション追加・編集・削除** → 動作確認
3. **Phase 3 開始** → MIDI出力実装

---

**Phase 2 完了！** 🎉

**セクション編集UIは完成。再生機能はPhase 2.5またはPhase 3後に実装予定。**

