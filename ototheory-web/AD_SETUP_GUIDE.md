# Google AdSense 広告設定ガイド

OtoTheory Web版にGoogle AdSense広告を統合するための設定手順です。

## 1. Google AdSenseアカウントの準備

1. [Google AdSense](https://www.google.com/adsense/)にアクセスし、アカウントを作成（既にお持ちの場合はスキップ）
2. サイトを登録し、審査を待つ
3. 審査通過後、以下の情報を取得します：
   - **パブリッシャーID**: `ca-pub-XXXXXXXXXXXXXXXXX` の形式
   - **広告ユニットスロットID**: 各広告枠に対する個別のID

## 2. コード設定

### 2.1 パブリッシャーIDの設定

以下の2つのファイルで `ca-pub-XXXXXXXXXXXXXXXXX` を実際のパブリッシャーIDに置き換えてください：

**ファイル1**: `src/app/layout.tsx` (行54)
```typescript
src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-XXXXXXXXXXXXXXXXX"
```

**ファイル2**: `src/components/AdSlot.client.tsx` (行59)
```typescript
data-ad-client="ca-pub-XXXXXXXXXXXXXXXXX"
```

### 2.2 広告スロットIDの設定（オプション）

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

## 7. テスト手順

1. 開発環境でアプリを起動: `npm run dev`
2. 各ページにアクセスし、広告スロットが表示されることを確認
3. Pro版の状態で広告が非表示になることを確認
4. Google AdSenseの管理画面でインプレッションが記録されることを確認

## 8. 本番環境へのデプロイ

1. パブリッシャーIDと広告スロットIDが正しく設定されていることを確認
2. `npm run build` でビルド
3. `npm start` で本番モードでテスト
4. デプロイ後、Google AdSenseの管理画面で広告の表示を確認

## トラブルシューティング

### 広告が表示されない場合

1. **ブラウザの広告ブロッカーを無効化**
2. **コンソールエラーを確認**
3. **パブリッシャーIDが正しいか確認**
4. **Google AdSenseの審査状況を確認**（審査中は広告が表示されない場合があります）

### レイアウトがずれる場合

- `minHeight`の値を調整してください（`src/components/AdSlot.client.tsx`の50行目）
- 広告フォーマット（`format`プロパティ）を変更してみてください

## 参考リンク

- [Google AdSense ヘルプセンター](https://support.google.com/adsense/)
- [AdSense コード導入ガイド](https://support.google.com/adsense/answer/9274019)

