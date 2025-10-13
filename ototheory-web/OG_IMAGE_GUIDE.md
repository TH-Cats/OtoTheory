# OG画像作成ガイド

**目的:** SNSシェア時の表示最適化、ブランド認知向上  
**優先度:** 🔴 高（404エラーを解消）  
**必要時間:** 30分〜1時間

---

## 📐 仕様

| 項目 | 仕様 |
|------|------|
| **サイズ** | 1200 × 630 px（固定） |
| **ファイル形式** | PNG または JPG |
| **ファイル名** | `og.png` |
| **配置先** | `/ototheory-web/public/og.png` |
| **最大ファイルサイズ** | 推奨: < 300KB |

---

## 🎨 デザインガイドライン

### **A. レイアウト構成（推奨）**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│                                                 │
│              ♪ OtoTheory ♪                     │
│                                                 │
│      Guitar Music Theory Made Easy             │
│                                                 │
│   🎸 Chord Finder • Progression Builder •       │
│      Music Theory Tools for Guitarists         │
│                                                 │
│                                                 │
│                www.ototheory.com                │
│                                                 │
└─────────────────────────────────────────────────┘
```

### **B. 必須要素**

1. **ブランド名**: "OtoTheory"（大きく、目立つフォント）
2. **キャッチコピー**: "Guitar Music Theory Made Easy"
3. **キーワード**: chord finder, progression builder, music theory
4. **URL**: www.ototheory.com（小さく、下部）

### **C. デザイン推奨事項**

**✅ 推奨:**
- シンプルで読みやすいレイアウト
- 高コントラスト（背景と文字）
- ブランドカラーを使用（青系・音楽的な色）
- ギターやコードのアイコン・イラスト
- 余白を十分に確保

**❌ 避ける:**
- 文字が小さすぎる（モバイルで読めない）
- 情報過多（ごちゃごちゃしている）
- 低コントラスト（グレー文字など）
- 著作権のある画像・フォント

---

## 🛠️ 作成方法（3つのオプション）

### **オプション1: Canva（推奨・無料）**

1. [Canva](https://www.canva.com) にアクセス
2. 「カスタムサイズ」→ 1200 × 630 px
3. テンプレート検索: "og image" または "social media"
4. テキスト・色・アイコンを編集
5. ダウンロード → PNG形式

**所要時間:** 15〜30分

---

### **オプション2: Figma（デザイナー向け）**

1. [Figma](https://www.figma.com) でプロジェクト作成
2. フレームサイズ: 1200 × 630 px
3. デザイン作成（テキスト、図形、アイコン）
4. Export → PNG @ 1x

**所要時間:** 30分〜1時間

---

### **オプション3: Next.js の動的OG画像生成（開発者向け）**

Vercelの `@vercel/og` ライブラリを使用して、コードで画像を生成。

#### **実装例:**

```typescript
// src/app/api/og/route.tsx
import { ImageResponse } from '@vercel/og';

export const runtime = 'edge';

export async function GET() {
  return new ImageResponse(
    (
      <div
        style={{
          fontSize: 60,
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          width: '100%',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          color: 'white',
          fontFamily: 'sans-serif',
        }}
      >
        <div style={{ fontSize: 80, fontWeight: 'bold' }}>♪ OtoTheory ♪</div>
        <div style={{ fontSize: 40, marginTop: 20 }}>Guitar Music Theory Made Easy</div>
        <div style={{ fontSize: 30, marginTop: 40, opacity: 0.9 }}>
          🎸 Chord Finder • Progression Builder
        </div>
        <div style={{ fontSize: 24, marginTop: 60, opacity: 0.7 }}>
          www.ototheory.com
        </div>
      </div>
    ),
    {
      width: 1200,
      height: 630,
    }
  );
}
```

#### **使い方:**
```typescript
// src/app/layout.tsx
export const metadata: Metadata = {
  openGraph: {
    images: [
      { url: '/api/og', width: 1200, height: 630, alt: 'OtoTheory' },
    ],
  },
};
```

**メリット:**
- ページごとに動的生成可能
- テキスト変更が簡単
- メンテナンスしやすい

**デメリット:**
- 実装に時間がかかる
- 初回アクセス時の生成コスト

**所要時間:** 1〜2時間

**参考:** [Vercel OG Image Generation](https://vercel.com/docs/functions/edge-functions/og-image-generation)

---

## ✅ 配置手順

1. 画像を作成（1200×630 px, PNG形式）
2. ファイル名を `og.png` に変更
3. 以下に配置:
   ```
   /ototheory-web/public/og.png
   ```
4. ブラウザで確認:
   ```
   https://www.ototheory.com/og.png
   ```
5. デプロイ後、SNSシェアで確認（Facebook/X/LinkedIn）

---

## 🧪 テスト・検証

### **1. ローカル確認**
```bash
cd /Users/nh/App/OtoTheory/ototheory-web
npm run dev
# ブラウザで http://localhost:3000/og.png にアクセス
```

### **2. SNSプレビュー確認**

**Facebook:**
- [Facebook Sharing Debugger](https://developers.facebook.com/tools/debug/)
- URL入力: `https://www.ototheory.com`
- 「新しい情報を取得」クリック

**X (Twitter):**
- [Twitter Card Validator](https://cards-dev.twitter.com/validator)
- URL入力: `https://www.ototheory.com`

**LinkedIn:**
- [LinkedIn Post Inspector](https://www.linkedin.com/post-inspector/)

### **3. 正しく表示されるか確認**
- ✅ 画像が表示される
- ✅ テキストが読みやすい
- ✅ ブランド名が目立つ
- ✅ URLが正しい

---

## 📊 期待される効果

| 指標 | 改善見込み |
|------|-----------|
| **SNSシェア時のCTR** | +20〜50% |
| **ブランド認知** | 向上 |
| **信頼性** | 向上（404エラー解消） |
| **プロフェッショナル感** | 大幅向上 |

---

## 🔗 参考リンク

- [Open Graph Protocol](https://ogp.me/)
- [Meta for Developers - Sharing Best Practices](https://developers.facebook.com/docs/sharing/webmasters)
- [Twitter Cards](https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/abouts-cards)
- [Vercel OG Image](https://vercel.com/docs/functions/edge-functions/og-image-generation)

---

## ⚠️ 注意事項

1. **著作権:** フリー素材またはオリジナルの画像のみ使用
2. **文字サイズ:** スマホでも読めるサイズ（最小40px推奨）
3. **ファイルサイズ:** 300KB以下を推奨（読み込み速度）
4. **キャッシュ:** SNSはキャッシュするため、変更後は各SNSのデバッガーで強制更新

---

**最終更新:** 2025-10-13  
**次のステップ:** 画像作成 → `/public/og.png` に配置 → デプロイ → SNSで確認

