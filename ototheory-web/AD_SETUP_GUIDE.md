# Google AdSense 広告設定ガイド

**最終更新: 2025年10月13日**

OtoTheory Web版にGoogle AdSense広告を統合するための設定手順です。

## 1. Google AdSenseアカウントの準備

1. [Google AdSense](https://www.google.com/adsense/)にアクセスし、アカウントを作成（既にお持ちの場合はスキップ）
2. サイトを登録し、審査を待つ
3. 審査通過後、以下の情報を取得します：
   - **パブリッシャーID**: `ca-pub-XXXXXXXXXXXXXXXXX` の形式
   - **広告ユニットスロットID**: 各広告枠に対する個別のID

## 2. コード設定

### 2.1 パブリッシャーIDの設定 ✅ 完了（2025-10-13）

パブリッシャーID `ca-pub-9662479821167655` は既に以下のファイルに設定済みです：

**ファイル1**: `src/app/layout.tsx` (行54)
```typescript
src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-9662479821167655"
```

**ファイル2**: `src/components/AdSlot.client.tsx` (行59)
```typescript
data-ad-client="ca-pub-9662479821167655"
```

### 2.2 認証メタタグの設定 ✅ 完了（2025-10-13）

サイト所有権確認のため、以下のメタタグを`src/app/layout.tsx`の`metadata`オブジェクトに追加済みです：

```typescript
export const metadata: Metadata = {
  // ... その他の設定
  other: {
    "google-adsense-account": "ca-pub-9662479821167655",
  },
  // ...
};
```

このメタタグは、すべてのページの`<head>`セクションに自動的に挿入されます：
```html
<meta name="google-adsense-account" content="ca-pub-9662479821167655">
```

### 2.3 ads.txtファイルの設定 ✅ 完了（2025-10-13）

Google AdSenseの要件として、`public/ads.txt`ファイルを作成済みです：

**ファイル**: `public/ads.txt`
```
google.com, pub-9662479821167655, DIRECT, f08c47fec0942fa0
```

このファイルは、デプロイ後に以下のURLでアクセス可能です：
- https://www.ototheory.com/ads.txt

### 2.4 広告スロットIDの設定（オプション）

各ページで異なる広告ユニットを使用する場合は、`src/components/AdSlot.client.tsx`の各呼び出しで`slot`プロパティを指定できます：

```typescript
<AdSlot page="home" format="horizontal" slot="1234567890" />
```

デフォルトでは、すべてのページで同じ広告ユニットが使用されます。

## 3. 広告配置箇所

現在、以下のページに広告が配置されています：

1. **ホームページ** (`src/app/page.tsx`)
   - ページ下部に横長フォーマット

2. **Chord Progressionページ** (`src/app/chord-progression/page.tsx`)
   - Toolsセクションの下に横長フォーマット

3. **Find Chordsページ** (`src/app/find-chords/page.tsx`)
   - メインコンテンツの下に横長フォーマット

4. **Chord Libraryページ** (`src/app/resources/chord-library/Client.tsx`)
   - フッターの下に横長フォーマット
   - カスタムスタイリング（ダークテーマに合わせたパネルデザイン）

## 4. Pro版での広告非表示機能

`AdSlot.client.tsx`コンポーネントは、ProProviderを使用してPro版ユーザーには自動的に広告を非表示にします：

```typescript
const { isPro } = usePro();

if (isPro) {
  return null;
}
```

## 5. CLS（Cumulative Layout Shift）対策

広告読み込み時のレイアウトシフトを防ぐため、以下の対策が実装されています：

- `minHeight: 110px` でコンテナの最小高さを確保
- 広告がロードされるまでスペースを確保
- `data-full-width-responsive="true"` でレスポンシブ対応

## 6. テレメトリー

広告が表示されると、以下のイベントが自動的に送信されます：

```typescript
track("ad_shown", { page: "home" | "chord_progression" | "find_chords" });
```

## 7. デプロイ履歴

### 2025年10月13日
- ✅ AdSenseスクリプトの統合（layout.tsx）
- ✅ AdSlotコンポーネントの実装
- ✅ 4ページへの広告配置（home, chord-progression, find-chords, chord-library）
- ✅ ads.txtファイルの作成と配置
- ✅ 認証メタタグの追加（google-adsense-account）
- ✅ Pro版での広告非表示機能
- ✅ GitHubへのプッシュとデプロイ完了

## 8. テスト手順

1. 開発環境でアプリを起動: `npm run dev`
2. 各ページにアクセスし、広告スロットが表示されることを確認
3. Pro版の状態で広告が非表示になることを確認
4. Google AdSenseの管理画面でインプレッションが記録されることを確認

## 9. 本番環境での確認

### 9.1 デプロイ後の確認項目

1. **ads.txtファイルの確認**
   - URL: https://www.ototheory.com/ads.txt
   - 内容: `google.com, pub-9662479821167655, DIRECT, f08c47fec0942fa0`

2. **認証メタタグの確認**
   - ブラウザで https://www.ototheory.com にアクセス
   - デベロッパーツール（F12）を開く
   - `<head>`セクションで以下を確認：
     ```html
     <meta name="google-adsense-account" content="ca-pub-9662479821167655">
     ```

3. **AdSenseスクリプトの確認**
   - ページのソースで以下のスクリプトが読み込まれていることを確認：
     ```html
     <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-9662479821167655"></script>
     ```

4. **広告スロットの確認**
   - 各ページ（/, /chord-progression, /find-chords, /resources/chord-library）で広告スロットが表示されることを確認

### 9.2 Google AdSenseでの審査手順

1. [Google AdSense](https://www.google.com/adsense/)にログイン
2. 「サイト」→「サイトの確認」を実行
3. 所有権確認が完了すると審査が開始される（通常1〜2週間）
4. 審査通過後、自動的に広告が表示される

## 10. トラブルシューティング

### 広告が表示されない場合

1. **ブラウザの広告ブロッカーを無効化**
2. **コンソールエラーを確認**
3. **パブリッシャーIDが正しいか確認**
4. **Google AdSenseの審査状況を確認**（審査中は広告が表示されない場合があります）
5. **ads.txtファイルが正しく配置されているか確認**
   - https://www.ototheory.com/ads.txt にアクセス
   - 404エラーの場合は、再デプロイが必要

### 所有権確認エラーが出る場合

1. **認証メタタグの確認**
   - ページのソースに`<meta name="google-adsense-account" content="ca-pub-9662479821167655">`が含まれているか確認
2. **ads.txtファイルの確認**
   - 正しいパブリッシャーIDが記載されているか確認
3. **デプロイの確認**
   - 最新のコードが本番環境にデプロイされているか確認

### レイアウトがずれる場合

- `minHeight`の値を調整してください（`src/components/AdSlot.client.tsx`の51行目）
- 広告フォーマット（`format`プロパティ）を変更してみてください

## 11. 設定ファイル一覧

### 変更されたファイル（2025-10-13）

1. **`src/app/layout.tsx`**
   - AdSenseスクリプトの追加
   - 認証メタタグの追加

2. **`src/components/AdSlot.client.tsx`**
   - 広告スロットコンポーネントの実装
   - Pro版非表示ロジック

3. **`src/app/page.tsx`**
   - ホームページに広告スロット追加

4. **`src/app/chord-progression/page.tsx`**
   - Chord Progressionページに広告スロット追加

5. **`src/app/find-chords/page.tsx`**
   - Find Chordsページに広告スロット追加

6. **`src/app/resources/chord-library/Client.tsx`**
   - Chord Libraryページに広告スロット追加

7. **`src/app/resources/chord-library/chords.module.css`**
   - 広告スロット用のスタイリング追加

8. **`public/ads.txt`**
   - Google AdSense認証ファイル

9. **`AD_SETUP_GUIDE.md`**
   - セットアップガイドドキュメント

## 12. 参考リンク

- [Google AdSense ヘルプセンター](https://support.google.com/adsense/)
- [AdSense コード導入ガイド](https://support.google.com/adsense/answer/9274019)
- [ads.txt について](https://support.google.com/adsense/answer/7532444)
- [サイトの所有権確認](https://support.google.com/adsense/answer/9190028)

