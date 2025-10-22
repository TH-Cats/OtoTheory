import Link from "next/link";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "料金プラン – OtoTheory",
  description: "OtoTheoryは無料で始められます。より高度な機能が必要な時にProにアップグレード。Web版は無料、iOS版は月額¥490でPro機能を利用可能。",
};

export default function PricingPage() {
  return (
    <div className="ot-page ot-stack">
      {/* Header */}
      <section className="ot-card text-center">
        <h1 className="text-2xl font-semibold mb-2">料金プラン</h1>
        <p className="leading-relaxed opacity-90">
          OtoTheoryは無料で始められます。<br />
          より高度な機能が必要な時にProにアップグレードしてください。
        </p>
      </section>

      {/* Plan Comparison */}
      <section className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Free Plan */}
        <div className="ot-card">
          <div className="mb-4">
            <h2 className="text-xl font-semibold mb-1">🆓 無料プラン</h2>
            <p className="text-sm opacity-70">Web & iOSで利用可能</p>
          </div>
          
          <div className="mb-4">
            <p className="text-3xl font-bold">¥0</p>
            <p className="text-sm opacity-70">永続無料</p>
          </div>

          <div className="space-y-2 mb-6 text-sm">
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>任意のキーとスケールからコードを探す</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>ビジュアルフレットボードオーバーレイ</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>カポ提案（上位2つ）</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>コード進行を作る（最大12コード）</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span><strong>基本コードのみ</strong></span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>20プリセットパターン</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>3スケッチ保存（ローカル）</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>PNG & テキストエクスポート</span>
            </div>
          </div>

          <Link 
            href="/ja/chord-progression" 
            className="block w-full text-center px-4 py-3 rounded-lg border-2 border-black/20 dark:border-white/20 font-semibold hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
          >
            Web版をお試し
          </Link>
        </div>

        {/* Pro Plan */}
        <div className="ot-card bg-gradient-to-br from-purple-50 to-blue-50 dark:from-purple-950/20 dark:to-blue-950/20 border-2 border-purple-200 dark:border-purple-800">
          <div className="mb-4">
            <div className="flex items-center gap-2 mb-1">
              <h2 className="text-xl font-semibold">💎 Proプラン</h2>
              <span className="text-xs px-2 py-0.5 rounded-full bg-purple-600 text-white font-medium">人気</span>
            </div>
            <p className="text-sm opacity-70">iOSのみ</p>
          </div>
          
          <div className="mb-4">
            <p className="text-3xl font-bold">¥490<span className="text-lg font-normal">/月</span></p>
            <p className="text-sm opacity-70">7日間無料トライアル</p>
          </div>

          <div className="space-y-2 mb-6 text-sm">
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>無料版のすべての機能</strong></span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>高度なコード選択</strong>（テンション、スラッシュコード）</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>50プリセットパターン</strong>（無料20 + Pro30）</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>セクション編集</strong>（Verse/Chorus/Bridge）</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>MIDIエクスポート</strong>（コードトラック & マーカー付き）</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>無制限クラウド保存</strong></span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>優先サポート</strong></span>
            </div>
          </div>

          <div className="relative">
            <button 
              disabled
              className="block w-full text-center px-4 py-3 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 text-white font-semibold opacity-50 cursor-not-allowed"
            >
              iOSでダウンロード
            </button>
            <span className="absolute -top-2 -right-2 px-2 py-0.5 text-xs font-bold bg-yellow-400 text-black rounded-full">
              近日公開
            </span>
          </div>
        </div>
      </section>

      {/* Detailed Comparison Table */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">📊 詳細機能比較</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-black/10 dark:border-white/10">
                <th className="text-left py-3 pr-4 font-semibold">機能</th>
                <th className="text-center py-3 px-2 font-semibold">無料</th>
                <th className="text-center py-3 px-2 font-semibold">Pro</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-black/5 dark:divide-white/5">
              <tr>
                <td className="py-3 pr-4">コードを探す</td>
                <td className="text-center py-3 px-2">✅</td>
                <td className="text-center py-3 px-2">✅</td>
              </tr>
              <tr>
                <td className="py-3 pr-4">ビジュアルフレットボード</td>
                <td className="text-center py-3 px-2">✅</td>
                <td className="text-center py-3 px-2">✅</td>
              </tr>
              <tr>
                <td className="py-3 pr-4">カポ提案</td>
                <td className="text-center py-3 px-2">上位2つ</td>
                <td className="text-center py-3 px-2">上位2つ</td>
              </tr>
              <tr>
                <td className="py-3 pr-4">コード進行を作る</td>
                <td className="text-center py-3 px-2">最大12</td>
                <td className="text-center py-3 px-2">最大12</td>
              </tr>
              <tr className="bg-purple-50/50 dark:bg-purple-950/10">
                <td className="py-3 pr-4 font-medium">コード選択</td>
                <td className="text-center py-3 px-2">基本のみ</td>
                <td className="text-center py-3 px-2"><strong className="text-purple-600 dark:text-purple-400">複雑 & スラッシュ</strong></td>
              </tr>
              <tr>
                <td className="py-3 pr-4">プリセットパターン</td>
                <td className="text-center py-3 px-2">20</td>
                <td className="text-center py-3 px-2"><strong>50</strong></td>
              </tr>
              <tr className="bg-purple-50/50 dark:bg-purple-950/10">
                <td className="py-3 pr-4 font-medium">セクション編集</td>
                <td className="text-center py-3 px-2">❌</td>
                <td className="text-center py-3 px-2"><strong className="text-purple-600 dark:text-purple-400">✅</strong></td>
              </tr>
              <tr>
                <td className="py-3 pr-4">スケッチ保存</td>
                <td className="text-center py-3 px-2">3（ローカル）</td>
                <td className="text-center py-3 px-2"><strong>無制限</strong></td>
              </tr>
              <tr>
                <td className="py-3 pr-4">PNGエクスポート</td>
                <td className="text-center py-3 px-2">✅</td>
                <td className="text-center py-3 px-2">✅</td>
              </tr>
              <tr>
                <td className="py-3 pr-4">テキストエクスポート</td>
                <td className="text-center py-3 px-2">✅</td>
                <td className="text-center py-3 px-2">✅</td>
              </tr>
              <tr className="bg-purple-50/50 dark:bg-purple-950/10">
                <td className="py-3 pr-4 font-medium">MIDIエクスポート</td>
                <td className="text-center py-3 px-2">❌</td>
                <td className="text-center py-3 px-2"><strong className="text-purple-600 dark:text-purple-400">✅</strong></td>
              </tr>
              <tr className="bg-purple-50/50 dark:bg-purple-950/10">
                <td className="py-3 pr-4 font-medium">クラウド同期</td>
                <td className="text-center py-3 px-2">❌</td>
                <td className="text-center py-3 px-2"><strong className="text-purple-600 dark:text-purple-400">✅</strong></td>
              </tr>
              <tr>
                <td className="py-3 pr-4">優先サポート</td>
                <td className="text-center py-3 px-2">❌</td>
                <td className="text-center py-3 px-2">✅</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      {/* 7-Day Trial */}
      <section className="ot-card text-center">
        <h2 className="text-xl font-semibold mb-3">🎁 7日間無料トライアル</h2>
        <div className="max-w-2xl mx-auto space-y-2 text-sm opacity-90 mb-4">
          <p>Proを7日間、完全無料でお試しください。</p>
          <ul className="space-y-1">
            <li>✓ すべてのPro機能にフルアクセス</li>
            <li>✓ クレジットカードが必要ですが、トライアル期間中はいつでもキャンセル可能</li>
            <li>✓ トライアル終了の24時間前にキャンセルして料金を回避</li>
          </ul>
        </div>
        <div className="relative inline-block">
          <button 
            disabled
            className="px-6 py-3 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 text-white font-semibold opacity-50 cursor-not-allowed"
          >
            無料トライアルを開始
          </button>
          <span className="absolute -top-2 -right-2 px-2 py-0.5 text-xs font-bold bg-yellow-400 text-black rounded-full whitespace-nowrap">
            近日公開
          </span>
        </div>
      </section>

      {/* Which Plan */}
      <section className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="ot-card">
          <h3 className="font-semibold mb-3">無料プランがおすすめな方：</h3>
          <ul className="space-y-2 text-sm opacity-90">
            <li className="flex items-start gap-2">
              <span>🎸</span>
              <span>音楽理論を学んでいる</span>
            </li>
            <li className="flex items-start gap-2">
              <span>📝</span>
              <span>コード進行を実験したい</span>
            </li>
            <li className="flex items-start gap-2">
              <span>🌐</span>
              <span>まずは試してから決めたい</span>
            </li>
            <li className="flex items-start gap-2">
              <span>💻</span>
              <span>Web版で十分なニーズ</span>
            </li>
          </ul>
        </div>

        <div className="ot-card">
          <h3 className="font-semibold mb-3">Proプランがおすすめな方：</h3>
          <ul className="space-y-2 text-sm opacity-90">
            <li className="flex items-start gap-2">
              <span>✍️</span>
              <span>本格的に音楽を作曲している</span>
            </li>
            <li className="flex items-start gap-2">
              <span>🎹</span>
              <span>MIDIファイルが必要（DAW編集用）</span>
            </li>
            <li className="flex items-start gap-2">
              <span>📚</span>
              <span>多くのスケッチを保存したい</span>
            </li>
            <li className="flex items-start gap-2">
              <span>🎵</span>
              <span>セクション構造管理が必要</span>
            </li>
            <li className="flex items-start gap-2">
              <span>🔄</span>
              <span>デバイス間で同期したい</span>
            </li>
          </ul>
        </div>
      </section>

      {/* FAQ */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">❓ よくある質問</h2>
        <div className="space-y-4 text-sm">
          <div>
            <p className="font-semibold mb-1">Q. WebでPro機能を使えますか？</p>
            <p className="opacity-80">A. いいえ、ProはiOSのみです。Web版は無料機能のみ提供しています。</p>
          </div>
          <div>
            <p className="font-semibold mb-1">Q. トライアル期間中にキャンセルできますか？</p>
            <p className="opacity-80">A. はい、いつでもキャンセル可能です。料金を避けるため、トライアル終了の24時間前にキャンセルしてください。</p>
          </div>
          <div>
            <p className="font-semibold mb-1">Q. 年額プランはありますか？</p>
            <p className="opacity-80">A. 現在、月額サブスクリプションのみです。年額プランは検討中です。</p>
          </div>
          <div>
            <p className="font-semibold mb-1">Q. 無料版からProにアップグレードした時、データは移行されますか？</p>
            <p className="opacity-80">A. はい、ローカルスケッチ（最大3つ）はアップグレード時に保持されます。</p>
          </div>
        </div>
        <div className="mt-4 pt-4 border-t border-black/10 dark:border-white/10 text-center">
          <p className="text-sm opacity-80">他に質問がありますか？</p>
          <Link href="/ja/faq" className="text-sm underline hover:no-underline">
            FAQページを見る →
          </Link>
        </div>
      </section>

      {/* Subscription Details */}
      <section className="ot-card text-sm opacity-80">
        <h3 className="font-semibold mb-2 opacity-100">💳 サブスクリプション詳細</h3>
        <ul className="space-y-1">
          <li>• App Store（Apple ID）経由で支払い</li>
          <li>• 期間終了の24時間前にキャンセルしない限り自動更新</li>
          <li>• 設定 &gt; Apple ID &gt; サブスクリプションからいつでもキャンセル可能</li>
          <li>• 返金は<a href="https://support.apple.com/ja-jp/HT204084" target="_blank" rel="noopener noreferrer" className="underline hover:no-underline">Appleの返金ポリシー</a>に従います</li>
        </ul>
      </section>

      {/* Contact */}
      <section className="ot-card text-center text-sm opacity-80">
        <p>料金やプランについて質問がありますか？</p>
        <p>
          <Link href="/ja/support" className="underline hover:no-underline">サポートに連絡</Link> または{' '}
          <a href="mailto:support@ototheory.com" className="underline hover:no-underline">support@ototheory.com</a> までメール
        </p>
      </section>
    </div>
  );
}