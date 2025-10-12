# 構造化データ実装ガイド

## 概要

OtoTheoryウェブサイトにJSON-LD形式の構造化データを実装しました。これにより、Googleなどの検索エンジンがサイトの内容をより正確に理解し、検索結果での表示が向上します。

## 実装済みの構造化データ

### 1. WebApplicationスキーマ（トップページ）
- **場所**: `/` (トップページ)
- **用途**: OtoTheoryをウェブアプリケーションとして定義
- **含まれる情報**: 
  - アプリケーション名
  - 説明
  - URL
  - カテゴリ（MusicApplication）
  - 価格情報（無料）
  - 動作環境

### 2. Organizationスキーマ（トップページ）
- **場所**: `/` (トップページ)
- **用途**: OtoTheoryを組織として定義
- **含まれる情報**:
  - 組織名
  - URL
  - ロゴ
  - 説明

### 3. SoftwareApplicationスキーマ（ツールページ）
- **場所**: `/find-chords`, `/find-key`
- **用途**: 各ツールをソフトウェアアプリケーションとして定義
- **含まれる情報**:
  - アプリケーション名
  - 説明
  - カテゴリ
  - 価格情報
  - 評価情報（サンプルデータ）

### 4. BreadcrumbListスキーマ（全ページ）
- **場所**: すべての主要ページ
- **用途**: パンくずリストの定義
- **効果**: 検索結果にパンくずリストが表示される
- **実装ページ**:
  - Find Chords
  - Chord Progression (Find Key)
  - Reference
  - About
  - Pricing
  - FAQ
  - Support
  - Privacy Policy
  - Terms of Service

### 5. FAQPageスキーマ（FAQページ）
- **場所**: `/faq`
- **用途**: よくある質問とその回答を構造化
- **効果**: 検索結果に「よくある質問」が表示される可能性

## 実装コンポーネント

### `/src/components/StructuredData.tsx`

以下の5つのコンポーネントが含まれています：

1. **WebApplicationStructuredData**
   ```tsx
   <WebApplicationStructuredData 
     name="OtoTheory"
     description="..."
     url="https://www.ototheory.com"
   />
   ```

2. **OrganizationStructuredData**
   ```tsx
   <OrganizationStructuredData />
   ```

3. **SoftwareApplicationStructuredData**
   ```tsx
   <SoftwareApplicationStructuredData
     name="Find Chords"
     description="..."
     category="Music"
   />
   ```

4. **BreadcrumbStructuredData**
   ```tsx
   <BreadcrumbStructuredData 
     items={[
       { name: "Home", url: "https://www.ototheory.com" },
       { name: "FAQ", url: "https://www.ototheory.com/faq" }
     ]}
   />
   ```

5. **FAQStructuredData**
   ```tsx
   <FAQStructuredData 
     faqs={[
       { question: "...", answer: "..." }
     ]}
   />
   ```

## 確認方法

### 1. Google Search Console
1. [Google Search Console](https://search.google.com/search-console) にアクセス
2. 「拡張」セクションを確認
3. 「構造化データ」レポートを確認

### 2. リッチリザルトテスト
1. [リッチリザルトテスト](https://search.google.com/test/rich-results) にアクセス
2. URLまたはコードを入力してテスト
3. 検出された構造化データを確認

### 3. Schema.org Validator
1. [Schema.org Validator](https://validator.schema.org/) にアクセス
2. URLを入力してバリデーション
3. エラーや警告がないか確認

### 4. ブラウザで確認
ページのソースを表示し、以下のようなJSON-LDスクリプトを探します：

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebApplication",
  "name": "OtoTheory",
  ...
}
</script>
```

## SEO効果

### 短期的効果（1-2週間）
- パンくずリストが検索結果に表示される
- FAQ情報が検索結果に表示される可能性

### 中期的効果（1-2ヶ月）
- 検索エンジンがサイトの内容をより正確に理解
- クリック率（CTR）の向上
- 関連するクエリでの順位向上

### 長期的効果（3-6ヶ月）
- ナレッジグラフへの表示可能性
- 音楽理論ツールとしての認知度向上
- オーガニックトラフィックの増加

## メンテナンス

### 新しいページを追加する場合
1. `layout.tsx` を作成
2. 適切な構造化データコンポーネントをインポート
3. ページの内容に応じたスキーマを実装

### データを更新する場合
1. `/src/components/StructuredData.tsx` のコンポーネントを編集
2. または各ページの `layout.tsx` で渡すプロパティを更新

## 今後の改善案

### 1. VideoObjectスキーマ
チュートリアル動画を追加する場合、VideoObjectスキーマを実装

### 2. Reviewスキーマ
ユーザーレビュー機能を実装する場合、Reviewスキーマを追加

### 3. HowToスキーマ
使い方ガイドページに実装し、ステップバイステップの説明を構造化

### 4. MusicCompositionスキーマ
ユーザーが作成したコード進行をMusicCompositionとして定義

### 5. 評価データの実際値
現在はサンプルデータ（4.8/5.0, 127件）を使用しているため、実際のユーザーレビューがある場合は更新

## 参考リンク

- [Schema.org Documentation](https://schema.org/)
- [Google Search Central - Structured Data](https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data)
- [JSON-LD Playground](https://json-ld.org/playground/)

## 更新履歴

| 日付 | 内容 |
|------|------|
| 2025-10-12 | 初回実装：WebApplication, Organization, SoftwareApplication, BreadcrumbList, FAQPage |

