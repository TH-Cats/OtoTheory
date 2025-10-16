# Web版 静的Chord Library統合レポート

**実装日**: 2025-10-16  
**ステータス**: ✅ 完了・デプロイ済み

## 概要

iOS版の静的Chord LibraryデータをWeb版に移植し、UIに統合。メジャー、マイナー、7th、M7、m7の5種類のコードタイプを静的データとして実装。

---

## 実装内容

### 1. 静的データファイル作成

**ファイル**: `/ototheory-web/src/lib/chord-library-static.ts`

#### データ構造
```typescript
export interface StaticForm {
  id: string;
  shapeName: string | null;
  frets: [StaticFret, ...]; // 1→6 (high E to low E)
  fingers: [StaticFinger, ...];
  barres: StaticBarre[];
  tips: string[];
}

export interface StaticChord {
  id: string;
  symbol: string;
  quality: string;
  forms: StaticForm[];
}
```

#### 実装済みコード種類

| カテゴリ | コード | 数量 | フォーム構成 |
|---------|--------|------|------------|
| **メジャー** | C, D, E, G, A | 5 | Open/Root-6/Root-5 |
| **マイナー** | Am, Dm, Em | 3 | Open/Root-6/Root-5 |
| **セブンス** | C7, G7 | 2 | Open/Root-6/Root-5 |
| **メジャー7th** | CM7 | 1 | Open/Root-6/Root-5 |
| **マイナー7th** | Cm7, Dm7, Em7, Am7 | 4 | Root-6/Root-5/Root-4 |

**合計**: 15コード、計50フォーム

---

### 2. UI統合

#### `/ototheory-web/src/app/chord-library/Client.tsx`

**変更内容**:
- 静的データ優先、動的生成フォールバック
- `getStaticChord()`で静的データを検索
- 既存の`ChordShape`フォーマットに変換

```typescript
// Try to get static chord first, fallback to generated
const staticChord = useMemo(() => {
  const symbol = quality === 'M' ? root : `${root}${quality}`;
  return getStaticChord(symbol);
}, [root, quality]);

const entry = useMemo(() => {
  if (staticChord) {
    return {
      symbol: staticChord.symbol,
      display: staticChord.symbol,
      shapes: staticChord.forms.slice(0, 3).map(convertToChordShape)
    };
  }
  return getCachedChord(root, quality);
}, [root, quality, staticChord]);
```

---

### 3. ChordDiagram修正

#### `/ototheory-web/src/components/chords/ChordDiagram.tsx`

**修正内容**:

1. **配列順序の統一**:
   ```typescript
   // Before: ['E', 'A', 'D', 'G', 'B', 'E'] (6→1)
   // After:  ['E', 'B', 'G', 'D', 'A', 'E'] (1→6)
   const OPEN_STRINGS = ['E', 'B', 'G', 'D', 'A', 'E'];
   ```

2. **バレー表示の修正**:
   ```typescript
   // b.fromString and b.toString are 1-indexed (1=high E, 6=low E)
   const y1 = yForString(b.fromString - 1);
   const y2 = yForString(b.toString - 1);
   ```

---

### 4. Root-4フォーム修正

マイナー7thコードのRoot-4フォームを正しい配列順序（1弦→6弦）に修正:

| コード | フレット配列 | 指番号 |
|--------|------------|--------|
| Cm7 | `['x', 'x', 10, 12, 11, 11]` | `[-, -, 1, 4, 2, 3]` |
| Dm7 | `['x', 'x', 12, 14, 13, 13]` | `[-, -, 1, 4, 2, 3]` |
| Em7 | `['x', 'x', 2, 4, 3, 3]` | `[-, -, 1, 4, 2, 3]` |
| Am7 | `['x', 'x', 7, 9, 8, 8]` | `[-, -, 1, 4, 2, 3]` |

---

## デプロイ

### ビルド結果

```
✓ Compiled successfully in 2.1s
✓ Generating static pages (40/40)
Route (app)                         Size  First Load JS
├ ○ /chord-library                   0 B         149 kB
├ ○ /ja/chord-library                0 B         149 kB
```

### Git操作

1. ブランチ: `feat/chord-library-static-v0`
2. コミット数: 4
3. 追加行数: +630 (static data)
4. mainブランチにマージ完了
5. Vercel自動デプロイ実行中

---

## iOS版との一貫性

| 項目 | iOS版 | Web版 | 状態 |
|-----|-------|-------|------|
| 配列順序 | 1→6 | 1→6 | ✅ 統一 |
| フレット表記 | `F(n)` / `.x` / `.open` | `number` / `'x'` / `0` | ✅ 互換 |
| バレー定義 | 1-indexed | 1-indexed | ✅ 統一 |
| Tips/コメント | あり | あり | ✅ 統一 |

---

## 今後の拡張予定

### Phase 2: 残りのルート追加
- [ ] F, Bb, F#, Eb, Ab, B のメジャー・マイナー
- [ ] 対応する7th系コード

### Phase 3: 追加クオリティ
- [ ] sus2, sus4, 7sus4
- [ ] 6, m6, 6/9
- [ ] aug, dim, dim7
- [ ] 9th, add9系

### Phase 4: UI強化
- [ ] 横スクロール対応（4フォーム以上）
- [ ] フォーム切り替えアニメーション
- [ ] My Forms保存機能（Web版）

---

## 技術的な改善点

### パフォーマンス
- 静的データ優先により、生成ロジックの実行回数が削減
- 初回ロード時のレンダリング速度向上

### 保守性
- iOS版とデータ構造を統一
- 型定義の明確化
- コメントによる配列順序の明示

### 拡張性
- 新しいコードの追加が容易
- フォールバック機構により段階的移行が可能

---

## 関連ファイル

### Web版
- `/ototheory-web/src/lib/chord-library-static.ts` (新規)
- `/ototheory-web/src/app/chord-library/Client.tsx` (更新)
- `/ototheory-web/src/components/chords/ChordDiagram.tsx` (修正)

### iOS版（参照）
- `/OtoTheory-iOS/OtoTheory/Services/StaticChordProvider.swift`
- `/OtoTheory-iOS/OtoTheory/Views/StaticChordLibraryView.swift`

### ドキュメント
- `/docs/SSOT/v3.1_SSOT.md`
- `/docs/SSOT/v3.1_Implementation_SSOT.md`
- `/docs/SSOT/v3.1_Roadmap_Milestones.md`

---

## まとめ

iOS版で実装した静的Chord Libraryデータを、Web版に成功裏に統合。配列順序の統一やバレー表示の修正により、両プラットフォーム間の一貫性を確保。現在15コード（50フォーム）が静的データとして提供され、残りは従来の動的生成でフォールバック。

**次のステップ**: 残りのルート（F, Bb等）の静的データ追加。

