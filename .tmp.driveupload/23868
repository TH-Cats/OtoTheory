import Link from 'next/link';

export default function ResourcesPageJa() {
  return (
    <div className="ot-page ot-stack">
      <h1 className="text-xl font-semibold">リソース</h1>
      
      <p className="text-sm text-black/70 dark:text-white/70">
        ギター理論の要点、用語、リファレンスをまとめました。
      </p>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {/* Learn Music Theory */}
        <Link 
          href="/ja/resources/learn"
          className="group rounded-lg border p-5 hover:border-blue-500 dark:hover:border-blue-400 transition-all hover:shadow-lg"
        >
          <div className="flex items-start gap-3 mb-3">
            <span className="text-2xl">🎵</span>
            <h2 className="text-lg font-semibold group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
              音楽理論を学ぶ
            </h2>
          </div>
          <p className="text-sm text-black/70 dark:text-white/70 leading-relaxed">
            感覚で作るを言葉にできるようになる。実践的な例と実際の応用を通じて、音楽理論の基礎を学びましょう。
          </p>
          <div className="mt-3 text-sm text-blue-600 dark:text-blue-400 group-hover:underline">
            学習を始める →
          </div>
        </Link>

        {/* Coming Soon - Artist Lab */}
        <div 
          className="group rounded-lg border p-5 border-gray-300 dark:border-gray-600 opacity-75"
        >
          <div className="flex items-start gap-3 mb-3">
            <span className="text-2xl">🎸</span>
            <h2 className="text-lg font-semibold text-gray-600 dark:text-gray-400">
              アーティストラボ
            </h2>
          </div>
          <p className="text-sm text-gray-500 dark:text-gray-500 leading-relaxed">
            有名曲を音楽理論で分析。ビートルズ、ローリング・ストーンズなどから学びます。
          </p>
          <div className="mt-3 text-sm text-gray-500 dark:text-gray-500">
            近日公開
          </div>
        </div>

        {/* Coming Soon - Training */}
        <div 
          className="group rounded-lg border p-5 border-gray-300 dark:border-gray-600 opacity-75"
        >
          <div className="flex items-start gap-3 mb-3">
            <span className="text-2xl">🏃‍♂️</span>
            <h2 className="text-lg font-semibold text-gray-600 dark:text-gray-400">
              トレーニング
            </h2>
          </div>
          <p className="text-sm text-gray-500 dark:text-gray-500 leading-relaxed">
            耳コピ、度数認識、アドリブ練習のための10分ドリル。
          </p>
          <div className="mt-3 text-sm text-gray-500 dark:text-gray-500">
            近日公開
          </div>
        </div>
      </div>
    </div>
  );
}
