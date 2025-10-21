# ローカライゼーションガイド

*最終更新: 2025/01/19*

## 概要

OtoTheory v3.2では、グローバルなLocaleContextを導入し、全コンポーネントで統一されたローカライゼーション管理を実現しています。

## アーキテクチャ

### LocaleContext

**ファイル**: `src/contexts/LocaleContext.tsx`

```typescript
interface LocaleContextValue {
  locale: 'ja' | 'en';
  isJapanese: boolean;
}

// 使用例
const { locale, isJapanese } = useLocale();
```

### 統一ヘルパー関数

各機能ごとに専用のヘルパー関数を提供：

- **ChordBuilder**: `src/lib/i18n/content.ts`
- **DiatonicTable**: `src/lib/i18n/diatonic.ts`
- **Fretboard**: `src/lib/i18n/fretboard.ts`

## 正しい実装パターン

### ✅ 推奨パターン

```typescript
// 1. LocaleContextを使用
import { useLocale } from '@/contexts/LocaleContext';

function MyComponent() {
  const { isJapanese } = useLocale();
  
  return (
    <div>
      <h1>{isJapanese ? "タイトル" : "Title"}</h1>
    </div>
  );
}

// 2. ヘルパー関数を使用
import { getDiatonicLabel } from '@/lib/i18n/diatonic';

function DiatonicTable() {
  const { locale } = useLocale();
  
  return (
    <div>
      {[1,2,3,4,5,6,7].map(degree => (
        <span key={degree}>
          {getDiatonicLabel(degree, locale)}
        </span>
      ))}
    </div>
  );
}
```

### ❌ 避けるべきパターン

```typescript
// 1. 直接的なpathname判定
const isJapanese = pathname.startsWith('/ja'); // ❌

// 2. window.locationの直接使用
const isJapanese = window.location.pathname.startsWith('/ja/'); // ❌

// 3. ハードコードされた言語判定
const label = isJapanese ? "日本語" : "English"; // ❌ ヘルパー関数を使うべき
```

## 実装ガイドライン

### 1. 新しいコンポーネントの作成

1. **LocaleContextをインポート**
   ```typescript
   import { useLocale } from '@/contexts/LocaleContext';
   ```

2. **統一ヘルパー関数を使用**
   ```typescript
   import { getLocalizedLabel } from '@/lib/i18n/your-feature';
   ```

3. **直接的な言語判定を避ける**
   ```typescript
   // ❌ 避ける
   const isJapanese = pathname.startsWith('/ja');
   
   // ✅ 推奨
   const { isJapanese } = useLocale();
   ```

### 2. 既存コンポーネントの移行

1. **usePathnameを削除**
   ```typescript
   // ❌ 削除
   import { usePathname } from "next/navigation";
   const pathname = usePathname();
   const isJapanese = pathname.startsWith('/ja');
   ```

2. **LocaleContextに置き換え**
   ```typescript
   // ✅ 追加
   import { useLocale } from '@/contexts/LocaleContext';
   const { isJapanese } = useLocale();
   ```

3. **ヘルパー関数に統一**
   ```typescript
   // ❌ 個別実装
   const label = isJapanese ? "日本語" : "English";
   
   // ✅ ヘルパー関数
   const label = getLocalizedLabel('key', locale);
   ```

### 3. 新しい機能の追加

1. **専用ヘルパー関数を作成**
   ```typescript
   // src/lib/i18n/your-feature.ts
   export function getYourFeatureLabel(key: string, locale: 'ja' | 'en'): string {
     const labels = {
       ja: { key1: "日本語1", key2: "日本語2" },
       en: { key1: "English1", key2: "English2" }
     };
     return labels[locale][key] || key;
   }
   ```

2. **コンポーネントで使用**
   ```typescript
   import { getYourFeatureLabel } from '@/lib/i18n/your-feature';
   
   function YourComponent() {
     const { locale } = useLocale();
     return <span>{getYourFeatureLabel('key1', locale)}</span>;
   }
   ```

## 言語相対表の管理

### 参照ファイル

**メインファイル**: `docs/SSOT/EN_JA_language_SSOT.md`

### 更新フロー

1. **言語相対表を更新**
   - 新しい翻訳を追加
   - 既存の翻訳を修正

2. **ヘルパー関数を更新**
   - 該当する機能のヘルパー関数を更新

3. **コンポーネントを更新**
   - 新しい翻訳を使用するコンポーネントを更新

4. **テスト**
   - 英語ページと日本語ページで動作確認

## プラットフォーム間の一貫性

### Web版

- **LocaleContext**: `src/contexts/LocaleContext.tsx`
- **ヘルパー関数**: `src/lib/i18n/`配下

### iOS版（将来実装）

- **LocaleManager**: 同様のアーキテクチャを採用
- **統一ヘルパー**: 同じデータソースを使用

### Android版（将来実装）

- **LocaleProvider**: 同様のアーキテクチャを採用
- **統一ヘルパー**: 同じデータソースを使用

## トラブルシューティング

### よくある問題

1. **ハイドレーションエラー**
   - `useEffect`や`isInitialized`状態を使用していないか確認
   - SSRとCSRで一貫した初期化を確認

2. **翻訳が表示されない**
   - ヘルパー関数が正しく実装されているか確認
   - LocaleContextが正しく提供されているか確認

3. **パフォーマンス問題**
   - 不要な再レンダリングが発生していないか確認
   - `useMemo`や`useCallback`を適切に使用

### デバッグ方法

```typescript
// デバッグ用ログ
console.log('Current locale:', locale);
console.log('Is Japanese:', isJapanese);
console.log('Label:', getLocalizedLabel('key', locale));
```

## 今後の拡張

### 予定されている機能

1. **動的翻訳読み込み**
   - 必要に応じて翻訳ファイルを読み込み

2. **翻訳キャッシュ**
   - パフォーマンス向上のためのキャッシュ機能

3. **翻訳検証**
   - 翻訳の完全性を自動検証

4. **多言語対応拡張**
   - 他の言語（中国語、韓国語など）への対応

---

**注意**: このガイドは継続的に更新されます。新しいパターンやベストプラクティスが発見された場合は、このドキュメントを更新してください。
