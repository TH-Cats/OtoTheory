# Logo Assets

このフォルダには OtoTheory のロゴとブランドアセットを格納します。

## ファイル一覧

### og.png (Open Graph Image)
- **サイズ:** 1200×630 px
- **用途:** SNSシェア時の表示画像（Facebook, X, LinkedIn など）
- **配置:** \`/public/logo/og.png\` または \`/public/og.png\`（推奨）

### 今後追加予定
- favicon.ico (32×32, 16×16)
- apple-touch-icon.png (180×180)
- android-chrome-192x192.png
- android-chrome-512x512.png
- logo.svg（サイト内使用）

## 使用方法

### og.png の参照
Next.js の metadata で参照する場合：

\`\`\`typescript
// public 直下の場合（推奨）
openGraph: {
  images: [{ url: "/og.png", width: 1200, height: 630 }]
}

// logo フォルダの場合
openGraph: {
  images: [{ url: "/logo/og.png", width: 1200, height: 630 }]
}
\`\`\`

---

**最終更新:** 2025-10-13
