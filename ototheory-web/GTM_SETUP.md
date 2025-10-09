# Google タグマネージャー セットアップガイド

このプロジェクトには Google タグマネージャー (GTM) が導入されています。

## セットアップ手順

### 1. Google タグマネージャー アカウントの準備

1. [Google Tag Manager](https://tagmanager.google.com/) にアクセス
2. 新しいコンテナを作成（または既存のものを使用）
3. コンテナIDを取得（形式：`GTM-XXXXXXX`）

### 2. 環境変数の設定

プロジェクトのルートディレクトリ（`ototheory-web`）に `.env.local` ファイルを作成（または追加）：

```bash
# Google Tag Manager
NEXT_PUBLIC_GTM_ID=GTM-XXXXXXX

# Google Analytics (GTMを使う場合は、GTM内でGA4を設定することを推奨)
# NEXT_PUBLIC_GA_ID=G-XXXXXXXXXX
```

> **注意:** GTMを使用する場合、Google AnalyticsタグはGTM内で管理することをお勧めします。その場合、`GoogleAnalytics`コンポーネントは削除しても構いません。

### 3. 動作確認

開発サーバーを起動：

```bash
npm run dev
```

ブラウザのデベロッパーツールで以下を確認：
- Networkタブで `gtm.js` へのリクエストが見える
- Consoleで `dataLayer` が定義されている
- GTMのプレビューモードで接続できる

### 4. GTMプレビューモードでのテスト

1. Google Tag Managerのコンソールで「プレビュー」をクリック
2. ウェブサイトのURL（例：`http://localhost:3000`）を入力
3. Tag Assistantで接続を確認
4. ページ遷移やイベントが正しく記録されているか確認

### 5. 本番環境での設定

#### Vercelの場合

1. Vercelのプロジェクト設定 > Environment Variables
2. `NEXT_PUBLIC_GTM_ID` を追加
3. 値にコンテナID（`GTM-XXXXXXX`）を入力
4. Production、Preview、Developmentの環境を選択

## 実装の詳細

### ファイル構成

- **`src/components/GoogleTagManager.tsx`**: GTMスクリプトを読み込むコンポーネント
  - `GoogleTagManagerHead`: `<head>` 内に配置するスクリプト
  - `GoogleTagManagerBody`: `<body>` 直後に配置する `<noscript>` フォールバック
- **`src/app/layout.tsx`**: ルートレイアウトでGTMコンポーネントを読み込み

### 特徴

- ✅ Next.js App Routerに最適化
- ✅ `next/script`の`afterInteractive`戦略を使用
- ✅ 環境変数が設定されていない場合は何も読み込まない
- ✅ JavaScriptが無効な環境でも動作（noscriptフォールバック）
- ✅ ページ遷移の自動トラッキング

## GTMで推奨される設定

### 1. Google Analytics 4 (GA4) タグの設定

GTM内でGA4を設定する場合：

1. GTMコンソールで「タグ」>「新規」
2. タグタイプ：「Google アナリティクス: GA4 設定」
3. 測定ID：GA4の測定ID（`G-XXXXXXXXXX`）を入力
4. トリガー：「All Pages」
5. 保存して公開

### 2. カスタムイベントの追加例

```typescript
// 例：ボタンクリックイベント
window.dataLayer = window.dataLayer || [];
window.dataLayer.push({
  event: 'button_click',
  button_name: 'cta_button',
  page_path: window.location.pathname
});
```

GTM側でこのイベントをトリガーとして使用できます。

## トラブルシューティング

### GTMが読み込まれない

- `.env.local` ファイルが正しく作成されているか確認
- コンテナIDの形式が正しいか確認（`GTM-`で始まる）
- 開発サーバーを再起動（環境変数の変更後は再起動が必要）

### プレビューモードで接続できない

- ブラウザのCookieが有効になっているか確認
- 広告ブロッカーが無効になっているか確認
- HTTPSでない場合、ブラウザのセキュリティ設定を確認

### dataLayerが定義されていない

- GTMスクリプトが正しく読み込まれているか、ブラウザのNetworkタブで確認
- コンソールエラーがないか確認

## GTM vs Google Analytics直接実装

### GTMを使うメリット

- ✅ コードを変更せずにタグを追加・削除・変更できる
- ✅ 複数のマーケティングツール（GA、Facebook Pixel、広告タグなど）を一元管理
- ✅ カスタムイベント、トリガー、変数を柔軟に設定可能
- ✅ バージョン管理とロールバック機能

### Google Analytics直接実装を使う場合

- シンプルでGA4のみ使用する場合
- 軽量な実装を優先する場合

現在、両方が実装されていますが、**GTMを使用する場合は、`GoogleAnalytics`コンポーネントを削除し、GTM内でGA4を設定することをお勧めします。**

---

**作成日:** 2025-10-09
**GTM ID例:** GTM-NXSC7TN2

