import Link from "next/link";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "お問い合わせ・サポート – OtoTheory",
  description: "OtoTheoryのサポートページ。よくある質問、お問い合わせ方法、トラブルシューティング情報をご確認ください。",
};

export default function SupportPage() {
  return (
    <div className="ot-page ot-stack">
      {/* Header */}
      <section className="ot-card">
        <h1 className="text-2xl font-semibold mb-2">お問い合わせ・サポート</h1>
        <p className="leading-relaxed opacity-90">
          OtoTheoryをご利用いただき、ありがとうございます。<br />
          ご質問やお困りのことがございましたら、お気軽にお問い合わせください。
        </p>
      </section>

      {/* Contact Information */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-3">📧 お問い合わせ先</h2>
        <div className="space-y-2">
          <p>
            <strong>メールアドレス</strong>：{' '}
            <a href="mailto:support@ototheory.com" className="underline hover:no-underline">
              support@ototheory.com
            </a>
          </p>
          <p className="text-sm opacity-80">
            <strong>回答時間</strong>：通常2営業日以内に回答いたします。<br />
            （土日祝日を除く）
          </p>
        </div>
      </section>

      {/* Before You Contact Us */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-3">🔍 お問い合わせ前に</h2>
        <h3 className="font-semibold mb-2">よくある質問（FAQ）</h3>
        <p className="mb-3 leading-relaxed opacity-90">
          多くの一般的なご質問は<Link href="/ja/faq" className="underline hover:no-underline">FAQページ</Link>で回答しています。
          以下をご確認ください：
        </p>
        <ul className="list-disc pl-5 space-y-1 text-sm opacity-90 mb-3">
          <li>サブスクリプションのキャンセル方法</li>
          <li>アカウントの削除方法</li>
          <li>データ保持期間</li>
          <li>「Shaped」と「Sounding」の違い</li>
          <li>エクスポート機能</li>
          <li>オフライン利用</li>
        </ul>
        <Link 
          href="/ja/faq" 
          className="inline-block px-4 py-2 rounded-lg border border-black/20 dark:border-white/20 text-sm font-medium hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
        >
          FAQページを見る →
        </Link>
      </section>

      {/* Common Inquiries */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">💬 よくあるお問い合わせ</h2>
        <div className="space-y-4">
          {/* Features */}
          <div>
            <h3 className="font-semibold mb-2">🎵 機能について</h3>
            <div className="text-sm space-y-2 opacity-90">
              <div>
                <p className="font-medium">Q. どの機能が無料/Proですか？</p>
                <p>→ 詳細な比較表は<Link href="/ja/pricing" className="underline hover:no-underline">料金ページ</Link>をご覧ください。</p>
              </div>
            </div>
          </div>

          {/* Billing */}
          <div>
            <h3 className="font-semibold mb-2">💳 料金・サブスクリプション</h3>
            <div className="text-sm space-y-2 opacity-90">
              <div>
                <p className="font-medium">Q. サブスクリプションをキャンセルしたい</p>
                <p>→ Apple ID &gt; サブスクリプション &gt; OtoTheoryでキャンセルしてください。</p>
              </div>
              <div>
                <p className="font-medium">Q. 返金したい</p>
                <p>
                  → App Storeの購入はAppleの返金ポリシーに従います。{' '}
                  <a 
                    href="https://support.apple.com/ja-jp/HT204084" 
                    target="_blank" 
                    rel="noopener noreferrer"
                    className="underline hover:no-underline"
                  >
                    Appleのサポートページ
                  </a>をご覧ください。
                </p>
              </div>
            </div>
          </div>

          {/* Account & Data */}
          <div>
            <h3 className="font-semibold mb-2">🔐 アカウント・データ</h3>
            <div className="text-sm space-y-2 opacity-90">
              <div>
                <p className="font-medium">Q. アカウントを削除したい</p>
                <p>→ アプリ内で設定 &gt; アカウント削除に移動するか、support@ototheory.comまでメールでお問い合わせください。</p>
              </div>
              <div>
                <p className="font-medium">Q. データをバックアップできますか？</p>
                <p>→ Pro版には自動クラウド同期バックアップが含まれています。無料版はローカル保存のみです。</p>
              </div>
            </div>
          </div>

          {/* Troubleshooting */}
          <div>
            <h3 className="font-semibold mb-2">🐛 問題・トラブルシューティング</h3>
            <div className="text-sm space-y-2 opacity-90">
              <div>
                <p className="font-medium">Q. アプリが起動しない・クラッシュする</p>
                <p>→ 以下をお試しください：</p>
                <ol className="list-decimal pl-5 mt-1 space-y-0.5">
                  <li>アプリを強制終了して再起動</li>
                  <li>デバイスを再起動</li>
                  <li>App Storeから最新版に更新</li>
                  <li>問題が続く場合はsupport@ototheory.comまでお問い合わせください</li>
                </ol>
              </div>
              <div>
                <p className="font-medium">Q. 音が出ない</p>
                <p>→ 以下をご確認ください：</p>
                <ol className="list-decimal pl-5 mt-1 space-y-0.5">
                  <li>デバイスの音量レベル</li>
                  <li>サイレントモードがオフになっているか</li>
                  <li>他のアプリで音が鳴るか</li>
                  <li>アプリを再起動</li>
                </ol>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Information to Include */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-3">📝 お問い合わせ時にご提供いただきたい情報</h2>
        <p className="mb-3 leading-relaxed opacity-90">
          より迅速なサポートのために、以下をご提供ください：
        </p>
        <ul className="list-disc pl-5 space-y-1 text-sm opacity-90">
          <li><strong>プラットフォーム</strong>：iOSアプリ / Web版</li>
          <li><strong>バージョン</strong>：アプリのバージョン番号（設定で確認可能）</li>
          <li><strong>デバイス</strong>：iPhone/iPadのモデル、OSバージョン</li>
          <li><strong>問題の詳細</strong>：いつから始まったか、どの操作で発生するか</li>
          <li><strong>スクリーンショット</strong>：可能であれば添付してください</li>
        </ul>
      </section>

      {/* Other Resources */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-3">🌐 その他のリソース</h2>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
          <Link href="/ja/about" className="text-sm underline hover:no-underline">OtoTheoryについて</Link>
          <Link href="/ja/faq" className="text-sm underline hover:no-underline">よくある質問</Link>
          <Link href="/ja/privacy" className="text-sm underline hover:no-underline">プライバシーポリシー</Link>
          <Link href="/ja/terms" className="text-sm underline hover:no-underline">利用規約</Link>
        </div>
      </section>

      {/* Feedback */}
      <section className="ot-card text-center">
        <h2 className="text-xl font-semibold mb-2">💌 フィードバック・機能要望</h2>
        <p className="mb-4 leading-relaxed opacity-90">
          OtoTheoryをより良くするためのご意見やご提案をお待ちしています。<br />
          機能要望、UI改善、その他のアイデアをお聞かせください。
        </p>
        <a 
          href="mailto:support@ototheory.com" 
          className="inline-block px-6 py-3 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 text-white font-semibold hover:opacity-90 transition-opacity"
        >
          メールを送る
        </a>
      </section>

      {/* Company Info */}
      <section className="ot-card text-center text-sm opacity-70">
        <p>
          <strong>事業者</strong>：TH Quest<br />
          <strong>所在地</strong>：神奈川県鎌倉市<br />
          <strong>メール</strong>：<a href="mailto:support@ototheory.com" className="underline">support@ototheory.com</a>
        </p>
      </section>
    </div>
  );
}