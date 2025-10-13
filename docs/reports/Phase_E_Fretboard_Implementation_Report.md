# Phase E: Fretboard & Diatonic Table & コード追加機能 実装レポート

**実装日**: 2025-10-12  
**対象**: OtoTheory iOS v1.0  
**ステータス**: Phase E-1 ~ E-4A 完了

---

## 📋 実装概要

### 完了したフェーズ

| Phase | 機能 | ステータス | 工数 |
|-------|------|----------|------|
| **E-1** | Fretboard可視化 | ✅ 完了 | 2日 |
| **E-2** | Diatonic Table | ✅ 完了 | 1日 |
| **E-3** | FindChordsView統合 | ✅ 完了 | 1日 |
| **E-4A** | 基本コード追加機能 | ✅ 完了 | 0.5日 |
| **E-4B** | Advanced Chord Builder | 🔜 次回 | - |
| **E-5** | Section別進行 | 📅 予定 | - |

---

## ✅ Phase E-1: Fretboard可視化（完了）

### 実装内容

#### 1. **FretboardView.swift**
- **SwiftUI Canvas**ベースの描画システム
- **15フレット × 6弦**の完全表示
- **二層Overlayシステム**:
  - Scale層: ゴーストドット（薄い、小さい）
  - Chord層: メインドット（濃い、大きい）
- **表示モード切り替え**:
  - Degrees（度数表示）
  - Names（音名表示）
- **ナット表示**（0フレットと1フレットの間の太線）
- **フレット番号**（0, 1, 3, 5, 7, 9, 12, 15）
- **Open Markers**（開放弦の丸印）
- **動的レイアウト**:
  - Portrait: 横スクロール可能
  - Landscape: 全体が収まるように自動調整

#### 2. **FretboardOverlay.swift**
- データモデル定義
- Scale + Chord情報を保持
- Factory methods: `scaleOnly()`, `scaleAndChord()`

#### 3. **Landscape Full-Screen Mode**
- **OrientationManager.swift**（新規作成）
  - `lockToLandscape()`: 強制横向き
  - `unlock()`: ロック解除
- **AppDelegate.swift**（新規作成）
  - `supportedInterfaceOrientationsFor`でOrientationManager連携
- **OtoTheoryApp.swift**
  - `@UIApplicationDelegateAdaptor`でAppDelegate統合

#### 4. **インタラクション**
- タップで単音試聴（AVAudioUnitSampler使用）
- Full-Screenボタンで横向き強制表示
- Reset機能（Chord層のみクリア、Scale層は保持）

### UI/UX改善
- ギターらしいデザイン（弦の横線を削除、よりクリーンに）
- 横向き推奨のヒント表示
- タブバーを自動非表示（Full-Screen時）
- Chord/Scale情報をトップバーに表示

### テスト結果
- ✅ 全15フレットが横向きで完全表示
- ✅ スケールドットとコードドットが正しく重なる
- ✅ 度数/音名の切り替えが動作
- ✅ タップでMIDI音再生
- ✅ Resetボタンでコード層のみクリア

---

## ✅ Phase E-2: Diatonic Table（完了）

### 実装内容

#### 1. **DiatonicTableView.swift**
- **Roman Numeral Header**（I, II, III, IV, V, VI, VII）
- **Open Row**（開放コード）:
  - タップで和音試聴
  - Fretboardと連動してChord層を表示
  - 再タップで選択解除
  - 長押しでProgressionに追加（Phase E-4A）
- **Capo Rows**（Top 2のみ）:
  - Easy open chord shapes (C, G, D, A, E)
  - Capo位置1-7を自動計算
  - Shaped表記（押さえ形）
- **Synchronized Horizontal Scrolling**:
  - Roman数字、Open、Capoすべて同期スクロール

#### 2. **DiatonicChord.swift**（新規モデル）
```swift
struct DiatonicChord: Identifiable {
    let id = UUID()
    let romanNumeral: String
    let chordName: String
    let quality: ChordQuality
}

struct CapoSuggestion: Identifiable {
    let id = UUID()
    let capoFret: Int
    let shapedChords: [DiatonicChord]
    let keyShape: String  // "Key of C", "Key of G", etc.
}
```

#### 3. **コード計算ロジック**
- `getMajorDiatonicChords()`: Major Key I-VII
- `getMinorDiatonicChords()`: Minor Key i-VII
- `getCapoSuggestions()`: Capo位置とShaped chords
- **Enharmonic Key対応**: Eb, Ab, Bb → D#, G#, A#へマッピング

### テスト結果
- ✅ Major/Minor両方のダイアトニック表示
- ✅ Capo提案が正しく計算される（Top 2）
- ✅ タップでFretboardと連動
- ✅ Roman数字とコードが正しく整列
- ✅ 横スクロールが同期

---

## ✅ Phase E-3: FindChordsView統合（完了）

### 実装内容

#### 1. **Key/Scale選択UI改善**
- 12キーをグリッド表示（2行 × 6列）
- Enharmonic equivalents対応（C#/Db, F#/Gb, etc.）
- 14種類のスケールをサポート:
  - Major (Ionian)
  - Natural Minor (Aeolian)
  - Dorian, Phrygian, Lydian, Mixolydian, Locrian
  - Harmonic Minor, Melodic Minor
  - Pentatonic Major/Minor
  - Blues
  - Diminished WH/HW

#### 2. **コンテンツ表示順序**
```
1. Key & Scale選択
2. Diatonic Table（Fretboardより上）
3. Suggested Scales for this chord（選択時のみ）
4. Substitute Chords（選択時のみ）
5. Fretboard
```

#### 3. **Suggested Scales for this chord**
- **ScaleSuggestions.swift**（新規ヘルパー）
- Chord qualityに基づいてスケール提案:
  - maj → Major Scale, Lydian
  - min → Natural Minor, Dorian, Phrygian
  - dom7 → Mixolydian, Altered
  - dim/m7b5 → Locrian, Diminished
- タップでスケールアルペジオ再生（ScalePreviewPlayer使用）
- 選択スケールのFretboardドット表示

#### 4. **Substitute Chords**
- **SubstituteChords.swift**（新規ヘルパー）
- 和声理論に基づく代理コード提案:
  - Same function (I→iii, V→vii°)
  - Modal interchange (Major key→i, iv, bVII)
  - Secondary dominants (V/V, V/vi)
  - Tritone substitution
  - Relative major/minor
- 長押しでProgressionに追加（Phase E-4A）

#### 5. **Full-Screen Fretboard強化**
- Chord名表示（選択時）
- Preview Scale表示（"Scale for this chord"ラベル付き）
- 2段階Reset機能:
  1. Preview Scale → 元のScale + Chord
  2. Chord → 元のScaleのみ

### テスト結果
- ✅ 全14スケールが正しく表示
- ✅ Suggested ScalesがChord qualityに応じて提案
- ✅ Substitute Chordsが和声的に適切
- ✅ Full-ScreenでChord/Scale情報表示
- ✅ 2段階Resetが正常動作

---

## ✅ Phase E-4A: 基本コード追加機能（完了）

### 実装内容

#### 1. **ToastView.swift**（新規コンポーネント）
- 軽量なトースト通知システム
- カスタマイズ可能:
  - メッセージテキスト
  - アイコン（SF Symbols）
  - 背景色（success=green, warning=orange, error=red）
  - 表示時間（デフォルト2秒）
- スムーズなアニメーション:
  - 出現: `.move(edge: .bottom)` + `.opacity`
  - Spring animation
- タブバーの上に表示（padding: 100）

#### 2. **ProgressionStore.swift**（新規ストア）
- **Singleton Pattern**: `ProgressionStore.shared`
- **Published Properties**:
  - `slots: [String?]` - 12スロット
  - `lastAddedSlotIndex: Int?` - ハイライト用
- **Methods**:
  - `addChord(_ chord: String) -> Bool` - 次の空きスロットに追加
  - `addChord(_ chord: String, at: Int)` - 特定スロットに追加
  - `removeChord(at: Int)` - スロット削除
  - `clearAll()` - 全削除
  - `nextAvailableSlot() -> Int?` - 次の空きスロット取得
- **Auto-highlight**:
  - 追加時に`lastAddedSlotIndex`を設定
  - 2秒後に自動クリア

#### 3. **ProgressionView統合**
- `@StateObject private var progressionStore = ProgressionStore.shared`
- `slots`をComputed propertyで後方互換性維持
- **SlotView拡張**:
  - `isHighlighted: Bool`プロパティ追加
  - ハイライト時のスタイル:
    - 緑色の太枠（strokeWidth: 4）
    - 緑色の背景（opacity: 0.25）
    - "New!"バッジ（右下）
    - 1.05倍に拡大（scaleEffect）
  - Spring animation

#### 4. **FindChordsView統合**
- `@StateObject private var progressionStore = ProgressionStore.shared`
- Toast state管理:
  ```swift
  @State private var showToast = false
  @State private var toastMessage = ""
  @State private var toastIcon: String? = "checkmark.circle.fill"
  @State private var toastColor: Color = .green
  ```
- `addChordToProgression(_ chord: String)`:
  - 非同期実行（`Task { @MainActor in }`）でUIフリーズ防止
  - Success: ハプティク振動 + Toast表示 + "Added C → Slot 3"
  - Full: 警告振動 + Toast表示 + "Progression is full (12/12)"
  - `generator.prepare()`で遅延削減

#### 5. **長押しジェスチャー実装**
- **DiatonicTableView**:
  - `onChordLongPress: ((String) -> Void)?`パラメータ追加
  - `DiatonicChordButton`に長押しジェスチャー
  - 長押し時の視覚効果:
    - scaleEffect: 1.0 → 0.8（80%縮小）
    - opacity: 1.0 → 0.5（半透明）
    - Spring animation（0.4秒）
    - 0.5秒後に自動復帰
- **SubstituteChordsView**:
  - `onLongPress: ((String) -> Void)?`パラメータ追加
  - `SubstituteChordRow`に長押しジェスチャー
  - 同様の視覚効果

#### 6. **ハプティクフィードバック**
- **Success** (コード追加成功):
  - `UINotificationFeedbackGenerator`
  - `.notificationOccurred(.success)`
  - 短い快適な振動
- **Warning** (Progression満杯):
  - `UINotificationFeedbackGenerator`
  - `.notificationOccurred(.warning)`
  - 2回の短い振動

#### 7. **メモリリーク修正**
- **問題**: `ScalePreviewPlayer`の二重初期化でフリーズ
- **修正**: 
  - `setupAudio()`で`if scalePreviewPlayer == nil`チェック
  - 1回のみ初期化
  - `[weak self]`でメモリリーク防止
- **Console Log**:
  - "deallocated with non-zero retain count"エラー解消

### テスト結果
- ✅ ダイアトニックコード長押し → Progression追加
- ✅ 代理コード長押し → Progression追加
- ✅ チップ縮小アニメーション動作
- ✅ Toast通知表示（スロット番号付き）
- ✅ Progressionスロットが緑ハイライト
- ✅ "New!"バッジ表示
- ✅ 2秒後に自動消滅
- ✅ 満杯時の警告Toast表示
- ✅ ハプティク振動が正常
- ✅ フリーズ問題解消
- ✅ 連続追加が安定動作

---

## 📁 新規作成ファイル

### Core Components
```
OtoTheory-iOS/OtoTheory/
├── Views/
│   ├── FretboardView.swift              ✅ (新規)
│   ├── DiatonicTableView.swift          ✅ (新規)
│   ├── ScaleSuggestionsView.swift       ✅ (新規)
│   └── SubstituteChordsView.swift       ✅ (新規)
├── Components/
│   └── ToastView.swift                  ✅ (新規)
├── Models/
│   ├── FretboardOverlay.swift           ✅ (新規)
│   └── DiatonicChord.swift              ✅ (新規)
├── Store/
│   └── ProgressionStore.swift           ✅ (新規)
├── Helpers/
│   ├── OrientationManager.swift         ✅ (新規)
│   ├── FretboardHelpers.swift           ✅ (新規)
│   ├── ScaleSuggestions.swift           ✅ (新規)
│   └── SubstituteChords.swift           ✅ (新規)
└── AppDelegate.swift                    ✅ (新規)
```

### 更新ファイル
```
OtoTheory-iOS/OtoTheory/
├── Views/
│   ├── FindChordsView.swift             ✏️ (大幅更新)
│   └── ProgressionView.swift            ✏️ (ProgressionStore統合)
└── OtoTheoryApp.swift                   ✏️ (AppDelegate統合)
```

---

## 🎨 UI/UX改善

### Before → After

#### 1. **Find Chords画面**
```
Before:
┌─────────────────────────┐
│ Coming Soon             │
│                         │
│                         │
└─────────────────────────┘

After:
┌─────────────────────────┐
│ Key: [C][C#][D]...      │
│ Scale: [Major▼]        │
├─────────────────────────┤
│ Diatonic Table          │
│ I   II  iii  IV  V  vi  │
│ [C] [Dm][Em][F] [G][Am] │ ← 長押しで追加
├─────────────────────────┤
│ Suggested Scales        │
│ [Major][Lydian]...      │ ← タップで試聴
├─────────────────────────┤
│ Substitute Chords       │
│ Em (Relative Minor)     │ ← 長押しで追加
├─────────────────────────┤
│ Fretboard (15 frets)    │
│ ○●○●○○○...           │
│ [°][♪][Full-Screen]    │
└─────────────────────────┘
```

#### 2. **Chord Progression画面**
```
Before:
┌───┬───┬───┬───┐
│   │   │   │   │
└───┴───┴───┴───┘

After (コード追加時):
┌───┬───┬───┬───┐
│ C │   │   │   │
│New│   │   │   │ ← 緑ハイライト + バッジ
└───┴───┴───┴───┘

Toast: "Added C → Slot 1" ✓
```

#### 3. **長押しアニメーション**
```
通常:        長押し中:      完了:
┌─────┐     ┌────┐      ┌─────┐
│  C  │ →   │ C  │  →   │  C  │
└─────┘     └────┘      └─────┘
100%        80% + 50%    100%
           (縮小+半透明)  (復帰)
```

---

## 🔧 技術的改善

### 1. **パフォーマンス最適化**
- **非同期処理**: `Task { @MainActor in }`でUI更新を非ブロッキング化
- **メモリ管理**: `[weak self]`でクロージャのリテインサイクル防止
- **Audio初期化**: 条件チェック（`if scalePreviewPlayer == nil`）で二重初期化防止
- **ハプティク準備**: `generator.prepare()`で遅延削減

### 2. **状態管理**
- **Singleton Pattern**: `ProgressionStore.shared`で全画面共有
- **Published Properties**: SwiftUIの自動UI更新
- **Computed Property**: 後方互換性維持（`slots`）

### 3. **アニメーション**
- **Spring Animation**: 物理的に自然な動き
  - `response: 0.4, dampingFraction: 0.6`（吸い込まれる演出）
  - `response: 0.3, dampingFraction: 0.8`（復帰）
- **Transition**: `.move(edge: .bottom)` + `.opacity`（Toast）

### 4. **エラーハンドリング**
- Progression満杯時の適切なフィードバック
- Enharmonic key対応（keyMap）
- Scale matching改善（ionian/major, aeolian/minor）

---

## 📊 コード統計

### 新規追加
- **ファイル数**: 13個
- **合計行数**: ~2,500行
- **SwiftUI Views**: 4個
- **Data Models**: 3個
- **Helper Classes**: 4個

### 更新
- **ファイル数**: 3個
- **変更行数**: ~500行

---

## 🎯 次のステップ

### Phase E-4B: Advanced Chord Builder（次回実装予定）
- Extensions（6, m6, 9, M9, m9, 11, M11, 13, M13）
- Altered Dominant（7b5, 7#5, 7b9, 7#9, 7#11, 7b13, 7alt）
- Diminished/Variants（dim7, m7b5）
- Suspensions/Adds（sus2, add9, add11, add13, 6/9）
- Aug/mM7（aug, mM7）
- Slash Chords（C/E, Am/C など）
- Paywall統合（Pro機能）

### Phase E-5: Section別コード進行（その後）
- Sectionモデル拡張（`chords`配列追加）
- ProgressionStore拡張（Section対応）
- UI実装（Section選択、スロット切り替え）
- 再生ロジック更新
- MIDI Export統合

---

## 🐛 既知の問題

### なし
- すべての主要機能が安定動作
- メモリリークなし
- UIフリーズなし

---

## ✅ 受け入れ基準（DoD）達成状況

| 項目 | ステータス |
|------|----------|
| Fretboard 15フレット表示 | ✅ |
| Scale/Chord二層Overlay | ✅ |
| Degrees/Names切り替え | ✅ |
| Landscape Full-Screen | ✅ |
| Diatonic Table表示 | ✅ |
| Capo提案（Top 2） | ✅ |
| Fretboardと連動 | ✅ |
| Suggested Scales | ✅ |
| Substitute Chords | ✅ |
| 長押しでProgression追加 | ✅ |
| Toast通知 | ✅ |
| ハプティクフィードバック | ✅ |
| スロットハイライト | ✅ |
| 吸い込まれる演出 | ✅ |

**すべての受け入れ基準を満たしています。** 🎉

---

## 📝 備考

### Web版パリティ
- ✅ Fretboard（二層Overlay、15フレット、度数/音名切り替え）
- ✅ Diatonic Table（Roman数字、Open/Capo）
- ✅ Suggested Scales
- ✅ Substitute Chords
- ⏳ Advanced Chord Builder（次回実装予定）
- ⏳ Section別コード進行（今後実装予定）

### ユーザーテスト
- ✅ 直感的な操作感
- ✅ スムーズなアニメーション
- ✅ 適切なフィードバック（視覚、触覚、音）
- ✅ 安定したパフォーマンス

---

**レポート作成日**: 2025-10-12  
**作成者**: AI Assistant  
**バージョン**: v1.0

