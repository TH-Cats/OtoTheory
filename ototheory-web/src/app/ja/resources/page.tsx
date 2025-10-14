import Link from 'next/link';

export default function ResourcesPageJa() {
  return (
    <div className="ot-page ot-stack">
      <h1 className="text-xl font-semibold">リソース</h1>
      
      <p className="text-sm text-black/70 dark:text-white/70">
        ギター理論の要点、用語、リファレンスをまとめました。
      </p>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <Link 
          href="/ja/resources/glossary"
          className="group rounded-lg border p-5 hover:border-blue-500 dark:hover:border-blue-400 transition-all hover:shadow-lg"
        >
          <div className="flex items-start gap-3 mb-3">
            <span className="text-2xl">📚</span>
            <h2 className="text-lg font-semibold group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
              用語集
            </h2>
          </div>
          <p className="text-sm text-black/70 dark:text-white/70 leading-relaxed">
            音楽理論の用語を素早く確認。1行の定義＋ギター向けの補足と例を掲載。
          </p>
          <div className="mt-3 text-sm text-blue-600 dark:text-blue-400 group-hover:underline">
            用語を見る →
          </div>
        </Link>

        <Link 
          href="/ja/resources/music-theory"
          className="group rounded-lg border p-5 hover:border-purple-500 dark:hover:border-purple-400 transition-all hover:shadow-lg"
        >
          <div className="flex items-start gap-3 mb-3">
            <span className="text-2xl">🎸</span>
            <h2 className="text-lg font-semibold group-hover:text-purple-600 dark:group-hover:text-purple-400 transition-colors">
              音楽理論ガイド
            </h2>
          </div>
          <p className="text-sm text-black/70 dark:text-white/70 leading-relaxed">
            ギタリストのための体系的ガイド。数字で学び、30秒レシピで即実践。
          </p>
          <div className="mt-3 text-sm text-purple-600 dark:text-purple-400 group-hover:underline">
            理論を学ぶ →
          </div>
        </Link>
      </div>

      <section id="quick-reference" className="rounded-lg border p-4 space-y-3 mt-4">
        <h2 className="text-lg font-semibold">クイックリファレンス</h2>
        
        <div className="space-y-3">
          <div>
            <h3 className="font-medium text-sm mb-2">ローマ数字</h3>
            <p className="text-sm text-black/70 dark:text-white/70">
              大文字＝メジャー三和音、小文字＝マイナー三和音、°＝ディミニッシュ三和音、ø＝ハーフディミニッシュ7（m7♭5）。
            </p>
            <ul className="list-disc pl-5 text-xs space-y-1 text-black/60 dark:text-white/60 mt-2">
              <li>メジャーキーでは triadの <strong>vii°</strong> は7thで <strong>viiø7</strong>（例：CメジャーのBm7♭5）</li>
              <li><strong>VII</strong> は第7音上のメジャー三和音。借用和音としては <strong>♭VII</strong> と書くのが一般的</li>
            </ul>
          </div>

          <div>
            <h3 className="font-medium text-sm mb-2">カデンツ</h3>
            <div className="grid sm:grid-cols-2 gap-2 text-sm">
              <div className="rounded border p-3">
                <strong className="text-xs">完全（V → I）</strong>
                <p className="text-xs text-black/60 dark:text-white/60 mt-1">強い終止感</p>
              </div>
              <div className="rounded border p-3">
                <strong className="text-xs">偽終止（V → vi）</strong>
                <p className="text-xs text-black/60 dark:text-white/60 mt-1">意外な継続</p>
              </div>
              <div className="rounded border p-3">
                <strong className="text-xs">半終止（… → V）</strong>
                <p className="text-xs text-black/60 dark:text-white/60 mt-1">未解決・開放的</p>
              </div>
              <div className="rounded border p-3">
                <strong className="text-xs">プラガル（IV → I）</strong>
                <p className="text-xs text-black/60 dark:text-white/60 mt-1">柔らかい終止</p>
              </div>
            </div>
          </div>

          <div>
            <h3 className="font-medium text-sm mb-2">カポのクイックガイド</h3>
            <p className="text-sm text-black/70 dark:text-white/70 mb-2">
              ボーカルの音域に合わせたり、弾きやすいフォームにするために活用します。
            </p>
            <ul className="list-disc pl-5 text-xs space-y-1 text-black/60 dark:text-white/60">
              <li>メジャー：相性が良いフォームは C / G / D / A / E</li>
              <li>マイナー：相性が良いフォームは Am / Em / Dm</li>
              <li>ローマ数字は常に実音（Sounding）のキー基準</li>
            </ul>
          </div>
        </div>
      </section>

      <div className="rounded-lg border p-4 text-center text-sm opacity-70">Ad Placeholder</div>
    </div>
  );
}
