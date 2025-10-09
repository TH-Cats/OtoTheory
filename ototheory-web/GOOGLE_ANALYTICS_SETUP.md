# Google Analytics セットアップガイド

このプロジェクトには Google Analytics (GA4) が導入されています。

> **注意:** Google タグマネージャー (GTM) も導入されています。GTMを使用する場合は、GTM内でGA4を設定することをお勧めします。詳細は `GTM_SETUP.md` をご覧ください。

## セットアップ手順

### 1. Google Analytics アカウントの準備

1. [Google Analytics](https://analytics.google.com/) にアクセス
2. 新しいプロパティを作成（または既存のものを使用）
3. GA4 測定IDを取得（形式：`G-XXXXXXXXXX`）

### 2. 環境変数の設定

プロジェクトのルートディレクトリ（`ototheory-web`）に `.env.local` ファイルを作成し、以下を追加：

```bash
# Google Analytics
NEXT_PUBLIC_GA_ID=G-XXXXXXXXXX
```

> **注意:** `.env.local` ファイルは `.gitignore` に含まれているため、Gitにコミットされません。本番環境では、デプロイ先のプラットフォーム（Vercel、Netlifyなど）で環境変数を設定してください。

### 3. 動作確認

開発サーバーを起動：

```bash
npm run dev
```

ブラウザのデベロッパーツールで以下を確認：
- Networkタブで `gtag/js` へのリクエストが見える
- Consoleで `dataLayer` が定義されている

### 4. 本番環境での設定

#### Vercelの場合

1. Vercelのプロジェクト設定 > Environment Variables
2. `NEXT_PUBLIC_GA_ID` を追加
3. 値に測定ID（`G-XXXXXXXXXX`）を入力
4. Production、Preview、Developmentの環境を選択

## 実装の詳細

### ファイル構成

- **`src/components/GoogleAnalytics.tsx`**: GA4スクリプトを読み込むクライアントコンポーネント
- **`src/app/layout.tsx`**: ルートレイアウトでGoogleAnalyticsコンポーネントを読み込み

### 特徴

- ✅ Next.js App Routerに最適化
- ✅ `next/script`の`afterInteractive`戦略を使用（パフォーマンス最適化）
- ✅ 環境変数が設定されていない場合は何も読み込まない
- ✅ ページ遷移の自動トラッキング

## トラブルシューティング

### データが表示されない

- `.env.local` ファイルが正しく作成されているか確認
- 測定IDの形式が正しいか確認（`G-`で始まる）
- 開発サーバーを再起動（環境変数の変更後は再起動が必要）

### リアルタイムレポートで確認

Google Analytics の「リアルタイム」レポートで、トラフィックがすぐに確認できます。

---

**作成日:** 2025-10-09

