import Link from "next/link";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "はじめに – OtoTheory",
  description: "OtoTheoryを使ってコード進行を作成し、キーとスケールを見つけ、作品を保存する方法を学びましょう。",
};

export default function GettingStartedPage() {
  return (
    <div className="ot-page ot-stack">
      {/* Header */}
      <section className="ot-card text-center">
        <h1 className="text-2xl font-semibold mb-2">OtoTheoryのはじめ方</h1>
        <p className="leading-relaxed opacity-90">
          OtoTheoryを使えば、音楽理論の知識がなくても、コード進行を作成し、<br />
          コードに合う音をすぐに見つけることができます。
        </p>
      </section>

      {/* 3 Steps */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">🎯 3ステップで始めよう</h2>
        
        {/* Step 1 */}
        <div className="mb-8">
          <h3 className="text-lg font-semibold mb-3">ステップ1️⃣: コード進行を作成する</h3>
          
          <div className="space-y-4 text-sm">
            <div>
              <p className="font-semibold mb-2">方法1: プリセットを使用（推奨）</p>
              <ol className="list-decimal pl-5 space-y-1 opacity-90">
                <li>メニューから「コード進行」をクリック</li>
                <li>「プリセット」セクションを開く</li>
                <li>お気に入りのパターンをタップ（例：「I - V - vi - IV」）</li>
                <li>コードが挿入され、自動再生される</li>
              </ol>
            </div>

            <div>
              <p className="font-semibold mb-2">方法2: 手動で作成</p>
              <ol className="list-decimal pl-5 space-y-1 opacity-90">
                <li>メニューから「コード進行」をクリック</li>
                <li><strong>+ 追加</strong>ボタンをタップ</li>
                <li>お気に入りのコードを選択して追加</li>
              </ol>
            </div>

            <div className="bg-blue-50 dark:bg-blue-950/20 p-3 rounded-lg">
              <p className="font-semibold mb-1">💡 初心者向けのヒント:</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li>まず「<strong>I - V - vi - IV</strong>」のプリセットを試してみてください（とても人気の進行）</li>
                <li>20種類のプリセットから選択（Pro版では50種類）</li>
                <li>音がすぐに再生されるので、どのように聞こえるか確認できます</li>
              </ul>
            </div>

            <div>
              <p className="font-semibold mb-2">結果ボタンでキーとスケールの提案を取得</p>
              <ol className="list-decimal pl-5 space-y-1 opacity-90">
                <li>進行を作成した後、「<strong>結果</strong>」ボタンをタップ</li>
                <li><strong>高い互換性</strong>を持つキーとスケール候補が表示される</li>
                <li>複数の候補から選択</li>
              </ol>
              <p className="mt-2 opacity-80">
                <strong>ポイント</strong>: キーはコード進行から自動的に検出されます。音楽理論の知識は不要です！
              </p>
            </div>
          </div>
        </div>

        {/* Step 2 */}
        <div className="mb-8 pt-6 border-t border-black/10 dark:border-white/10">
          <h3 className="text-lg font-semibold mb-3">ステップ2️⃣: キーとスケールを選択する</h3>
          
          <div className="space-y-4 text-sm">
            <div>
              <p className="font-semibold mb-2">キーを選択</p>
              <ol className="list-decimal pl-5 space-y-1 opacity-90">
                <li><strong>結果</strong>に表示されたキー候補から選択</li>
                <li>選択したキーに基づいて<strong>スケールオプションが変化</strong>する</li>
              </ol>
            </div>

            <div>
              <p className="font-semibold mb-2">スケールを選択</p>
              <ol className="list-decimal pl-5 space-y-1 opacity-90">
                <li>キーに対応するスケール候補から選択</li>
                <li>メジャー（明るい）、マイナー（暗い）などを選択</li>
              </ol>
            </div>

            <div className="bg-blue-50 dark:bg-blue-950/20 p-3 rounded-lg">
              <p className="font-semibold mb-1">💡 ポイント:</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li><strong>互換性の順序</strong>で表示される</li>
                <li>迷ったら、一番上の候補を選択</li>
              </ul>
            </div>

            <div>
              <p className="font-semibold mb-2">フレットボード表示</p>
              <p className="mb-2 opacity-90">キーとスケールを選択すると：</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li><strong>スケールの音がフレットボードに表示</strong>される</li>
                <li>どの音がよく合うかを視覚的に確認できる</li>
                <li>コード進行に合うメロディーやソロを作りやすくなる</li>
              </ul>
              <p className="mt-2 opacity-80">
                <strong>使用場面</strong>: メロディー作成、ソロ音の検索、スケールパターンの学習
              </p>
            </div>
          </div>
        </div>

        {/* Step 3 */}
        <div className="pt-6 border-t border-black/10 dark:border-white/10">
          <h3 className="text-lg font-semibold mb-3">ステップ3️⃣: 保存とエクスポート</h3>
          
          <div className="space-y-4 text-sm">
            <div>
              <p className="font-semibold mb-2">進行の編集（保存前）</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li><strong>ドラッグ＆ドロップ</strong>で並び替え</li>
                <li>コードをタップして削除</li>
                <li>長押しで置き換え</li>
                <li>最大12個のコードまで追加（無料プラン）</li>
              </ul>
            </div>

            <div>
              <p className="font-semibold mb-2">保存（スケッチ）</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li><strong>進行、キー、スケール、フレットボード表示を一緒に保存</strong></li>
                <li>無料版: 最大3個のローカル保存</li>
                <li>Pro版: 無制限のクラウド保存</li>
              </ul>
            </div>

            <div>
              <p className="font-semibold mb-2">エクスポート</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li><strong>PNG画像</strong>: 進行を画像として保存（共有用）</li>
                <li><strong>テキスト</strong>: コード名、キー、スケール情報をコピー＆ペースト</li>
                <li><strong>MIDI</strong>: DAWで編集（Pro版のみ、コードトラック＆マーカー付き）</li>
              </ul>
            </div>

            <div className="bg-blue-50 dark:bg-blue-950/20 p-3 rounded-lg">
              <p className="font-semibold mb-1">💡 初心者向けのヒント:</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li>気に入った進行はすぐに保存</li>
                <li>PNGエクスポートでバンドメンバーと共有</li>
                <li>保存したスケッチは再開して作業を続けられる</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Useful Features */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">🎸 便利な機能</h2>
        
        <div className="space-y-4 text-sm">
          <div>
            <h3 className="font-semibold mb-2">コードを探す（コードエクスプローラー）</h3>
            <p className="mb-2 opacity-90">キーとスケールを選択して、利用可能なコードを詳しく探索。</p>
            <p className="opacity-80">
              <strong>使用場面</strong>: どのコードが一緒に使えるかを学習、運指を確認、スケールを視覚的に理解
            </p>
          </div>

          <div>
            <h3 className="font-semibold mb-2">カポ提案</h3>
            <p className="mb-2 opacity-90">難しいキーを簡単に演奏するための提案を取得。</p>
            <p className="opacity-80">
              <strong>使用場面</strong>: 難しいキーを簡単な形で演奏、より多くのオープンコードを使用
            </p>
          </div>
        </div>
      </section>

      {/* Common Terms */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">📚 よく使う用語</h2>
        
        <div className="space-y-3 text-sm">
          <div>
            <p className="font-semibold">キー</p>
            <p className="opacity-80">曲の中心となる音。例: C、G、Am</p>
          </div>
          <div>
            <p className="font-semibold">スケール</p>
            <p className="opacity-80">曲で使用される音の集合。例: メジャー、マイナー</p>
          </div>
          <div>
            <p className="font-semibold">ダイアトニックコード</p>
            <p className="opacity-80">特定のキー/スケールの基本コード。これらから選択すると自然な響きの進行が作れる。</p>
          </div>
          <div>
            <p className="font-semibold">ローマ数字</p>
            <p className="opacity-80">コードの機能を示す記号（I、V、vi、IV）。大文字=メジャー、小文字=マイナー。</p>
          </div>
          <div>
            <p className="font-semibold">カポ</p>
            <p className="opacity-80">ギターのフレットに取り付けて音程を上げる装置。難しいキーを簡単な形で演奏可能にする。</p>
          </div>
        </div>
      </section>

      {/* Next Steps */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">🎓 次のステップ</h2>
        
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-sm">
          <Link href="/ja/faq" className="underline hover:no-underline">よくある質問</Link>
          <Link href="/ja/resources" className="underline hover:no-underline">リソース</Link>
          <Link href="/ja/about" className="underline hover:no-underline">OtoTheoryについて</Link>
          <Link href="/ja/pricing" className="underline hover:no-underline">料金</Link>
        </div>
      </section>

      {/* CTA */}
      <section className="ot-card text-center">
        <h2 className="text-xl font-semibold mb-4">準備はできましたか？始めましょう！</h2>
        <div className="flex flex-col sm:flex-row gap-3 justify-center items-center">
          <Link 
            href="/ja/chord-progression" 
            className="px-6 py-3 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 text-white font-semibold hover:opacity-90 transition-opacity"
          >
            🌐 Web版を開く（無料）
          </Link>
          <div className="relative">
            <button 
              disabled
              className="px-6 py-3 rounded-lg border-2 border-black/20 dark:border-white/20 font-semibold opacity-50 cursor-not-allowed"
            >
              📱 iOSアプリをダウンロード
            </button>
            <span className="absolute -top-2 -right-2 px-2 py-0.5 text-xs font-bold bg-yellow-400 text-black rounded-full">
              近日公開
            </span>
          </div>
        </div>
        <p className="text-sm opacity-70 mt-4">Web版: 無料、登録不要</p>
      </section>

      {/* Support */}
      <section className="ot-card text-center text-sm opacity-80">
        <p className="mb-2">ヘルプが必要ですか？</p>
        <p>
          <Link href="/ja/faq" className="underline hover:no-underline">よくある質問ページ</Link>を確認するか、{' '}
          <Link href="/ja/support" className="underline hover:no-underline">サポートに連絡</Link>してください
        </p>
      </section>
    </div>
  );
}