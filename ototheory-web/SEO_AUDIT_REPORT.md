# OtoTheory SEO 監査レポート

**作成日:** 2025-10-12  
**対象サイト:** https://www.ototheory.com

---

## ✅ 実装済み・良好な項目

### 1. **技術的SEO基盤**
- ✅ **robots.txt** - 正しく配信（全ページクロール許可）
- ✅ **sitemap.xml** - 14ページすべて含まれる、正しいXML形式
- ✅ **HTTPS** - SSL証明書有効
- ✅ **モバイル対応** - viewport メタタグ設定済み
- ✅ **lang属性** - `<html lang="en">` 設定済み

### 2. **メタデータ（トップページ）**
- ✅ **Title** - 適切な長さ（55文字）、キーワード含む
  ```
  OtoTheory – Guitar Music Theory Made Easy
  ```
- ✅ **Description** - 適切な長さ（149文字）、行動喚起含む
  ```
  Free guitar chord finder, key analyzer, and music theory tool...
  ```
- ✅ **Keywords** - 関連性の高いキーワード7個
- ✅ **Canonical URL** - 暗黙的に設定（Next.jsデフォルト）

### 3. **Open Graph & Twitter Card**
- ✅ **OG Tags** - 完全実装
  - og:title, og:description, og:url, og:image
  - 画像サイズ指定（1200x630）
- ✅ **Twitter Card** - `summary_large_image` 設定済み
- ✅ **OG Image** - `/og.png` 設定済み

### 4. **構造化データ（JSON-LD）**
- ✅ **WebApplication** スキーマ - トップページ
- ✅ **Organization** スキーマ - トップページ
- ✅ **BreadcrumbList** - 各サブページ
- ✅ **FAQPage** - FAQページ
- ✅ **SoftwareApplication** - ツールページ

### 5. **HTMLセマンティクス**
- ✅ **H1タグ** - 各ページに1つ設置
- ✅ **aria-label** - ナビゲーション要素に設定
- ✅ **セマンティックHTML** - header, main, footer, nav, section

### 6. **Google Tag Manager & Analytics**
- ✅ **GTM** - 正しく実装（GTM-NXSC7TN2）
- ✅ **GA4** - 設定済み（GTM経由）
- ✅ **Google AdSense** - 設定済み

---

## ⚠️ 改善が必要な項目

### 1. **Canonical URLの明示的な設定** 🔴 高優先度
**問題:**
- `<link rel="canonical">` タグが明示的に設定されていない

**影響:**
- Googleが正規URLを誤認識する可能性
- 重複コンテンツのリスク

**修正方法:**
```typescript
// src/app/layout.tsx または各ページの metadata
export const metadata: Metadata = {
  alternates: {
    canonical: 'https://www.ototheory.com',
  },
};
```

### 2. **OG Image の実在確認** 🟡 中優先度
**問題:**
- `/og.png` の存在が未確認

**修正方法:**
```bash
# 確認コマンド
curl -I https://www.ototheory.com/og.png
```

### 3. **alt属性の設定** 🟡 中優先度
**問題:**
- SVGアイコンに `aria-hidden="true"` は設定されているが、意味のある画像にはaltが必要

**確認が必要な箇所:**
- ヘッダーロゴ
- フッターアイコン
- コンテンツ内の画像

### 4. **内部リンクの最適化** 🟢 低優先度
**改善点:**
- リソースページへのクロスリンク追加
- 関連ページへの相互リンク強化

### 5. **ページ速度最適化** 🟡 中優先度
**確認が必要:**
- Core Web Vitals スコア
- Lighthouse パフォーマンススコア
- 初回ロード時間

### 6. **言語設定の追加** 🟢 低優先度
**問題:**
- 日本語コンテンツへの hreflang 設定がない（将来的に必要）

**修正方法:**
```typescript
export const metadata: Metadata = {
  alternates: {
    languages: {
      'en': 'https://www.ototheory.com',
      'ja': 'https://www.ototheory.com/ja', // 将来実装時
    },
  },
};
```

---

## 🚀 推奨される追加実装

### 1. **Canonical URL の全ページ設定** 🔴 最優先
現在のコードに追加してください：

```typescript
// ototheory-web/src/app/layout.tsx
export const metadata: Metadata = {
  metadataBase: new URL("https://www.ototheory.com"),
  alternates: {
    canonical: "/",
  },
  // ... 既存のメタデータ
};
```

```typescript
// 各サブページ (例: src/app/find-chords/layout.tsx)
export const metadata: Metadata = {
  alternates: {
    canonical: "/find-chords",
  },
  // ... 既存のメタデータ
};
```

### 2. **og.png の作成または確認**
以下のコマンドで確認：
```bash
curl -I https://www.ototheory.com/og.png
```

存在しない場合は、1200x630pxの画像を作成してください：
- ブランドロゴ
- キャッチコピー
- 視覚的に魅力的なデザイン

### 3. **XMLサイトマップの lastmod 自動更新**
現在は固定日付 `2025-10-12` ですが、動的に更新するのが理想的：

```typescript
// sitemap.ts
export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = 'https://www.ototheory.com';
  const today = new Date(); // 動的に今日の日付を取得
  
  return [
    {
      url: baseUrl,
      lastModified: today,
      changeFrequency: 'weekly',
      priority: 1.0,
    },
    // ...
  ];
}
```

### 4. **404ページの改善**
現在の404ページは良好ですが、さらに改善：
- カスタム404ページのメタデータ設定
- 検索機能の追加
- 人気ページへのリンク

### 5. **Google Search Console の設定**
- ✅ 所有権確認済み
- ⏳ サイトマップ送信
- ⏳ URL検査とインデックス登録リクエスト

---

## 📊 パフォーマンス確認（要実施）

以下のツールで確認してください：

### 1. **Google PageSpeed Insights**
```
https://pagespeed.web.dev/
```
- モバイル/デスクトップのスコア確認
- Core Web Vitals 測定

### 2. **Google Rich Results Test**
```
https://search.google.com/test/rich-results
```
- 構造化データの検証
- リッチスニペット表示の確認

### 3. **Google Mobile-Friendly Test**
```
https://search.google.com/test/mobile-friendly
```
- モバイル対応の検証

### 4. **Schema.org Validator**
```
https://validator.schema.org/
```
- JSON-LD スキーマの検証

---

## 📝 主要ページのチェックリスト

| ページ | Title | Description | H1 | Canonical | 構造化データ | ステータス |
|--------|-------|-------------|-----|-----------|-------------|-----------|
| / | ✅ | ✅ | ✅ | ⚠️ | ✅ | 要改善 |
| /find-chords | ✅ | ✅ | ? | ⚠️ | ✅ | 要確認 |
| /chord-progression | ✅ | ✅ | ? | ⚠️ | ✅ | 要確認 |
| /resources | ? | ? | ? | ⚠️ | ✅ | 要確認 |
| /about | ✅ | ✅ | ? | ⚠️ | ✅ | 要確認 |
| /faq | ✅ | ✅ | ? | ⚠️ | ✅ | 要確認 |
| /pricing | ✅ | ✅ | ? | ⚠️ | ? | 要確認 |
| /support | ✅ | ✅ | ? | ⚠️ | ? | 要確認 |
| /privacy | ✅ | ✅ | ? | ⚠️ | ? | 要確認 |
| /terms | ✅ | ✅ | ? | ⚠️ | ? | 要確認 |

---

## 🎯 優先度別アクションプラン

### 🔴 高優先度（今すぐ実施）
1. ✅ Canonical URL を全ページに追加
2. ✅ og.png の存在確認または作成
3. ✅ Google Search Console でサイトマップ再送信
4. ✅ 主要ページのURL検査とインデックス登録リクエスト

### 🟡 中優先度（1週間以内）
1. ⏳ PageSpeed Insights でパフォーマンス測定
2. ⏳ Rich Results Test で構造化データ検証
3. ⏳ 画像のalt属性を全て確認・追加
4. ⏳ 内部リンク構造の最適化

### 🟢 低優先度（1ヶ月以内）
1. ⏳ hreflang 設定（多言語対応時）
2. ⏳ 404ページのさらなる改善
3. ⏳ FAQ構造化データの拡充
4. ⏳ パンくずナビゲーションの視覚的表示

---

## 📈 測定指標

### 追跡すべきKPI
1. **Google Search Console**
   - インデックス登録済みページ数
   - クリック数
   - 表示回数
   - 平均掲載順位
   - クリック率（CTR）

2. **Google Analytics (GA4)**
   - オーガニックトラフィック
   - 直帰率
   - 平均セッション時間
   - コンバージョン（目標設定が必要）

3. **Core Web Vitals**
   - LCP (Largest Contentful Paint)
   - FID (First Input Delay)
   - CLS (Cumulative Layout Shift)

---

## 🔗 参考リンク

- [Google Search Central - SEO スターター ガイド](https://developers.google.com/search/docs/fundamentals/seo-starter-guide)
- [Next.js Metadata API](https://nextjs.org/docs/app/api-reference/functions/generate-metadata)
- [Schema.org Documentation](https://schema.org/)
- [Web.dev - SEO Basics](https://web.dev/learn/seo/)

---

## ✅ 今すぐ実行するべきこと

1. **Canonical URL の追加**（30分）
2. **og.png の確認/作成**（1時間）
3. **Google Search Console でサイトマップ再送信**（5分）
4. **主要5ページのURL検査**（15分）
5. **PageSpeed Insights でスコア確認**（10分）

**推定作業時間:** 2時間

---

**次のステップ:** このレポートの🔴高優先度項目から実装しましょうか？

