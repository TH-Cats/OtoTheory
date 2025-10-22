import Link from 'next/link';
import { getPublishedArticles } from '@/lib/articles';

export default function LearnPageJa() {
  const articles = getPublishedArticles('ja');

  return (
    <div className="ot-page ot-stack">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-4">音楽理論を学ぶ</h1>
        <p className="text-lg text-gray-600 dark:text-gray-300 leading-relaxed">
          感覚で作るを言葉にできるようになる。実践的な例と実際の応用を通じて、
          音楽理論の基礎を学びましょう。
        </p>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {articles.map((article) => (
          <Link
            key={article.slug}
            href={`/ja/resources/learn/${article.slug}`}
            className="group block p-6 rounded-lg border border-gray-200 dark:border-gray-700 hover:border-blue-500 dark:hover:border-blue-400 transition-all hover:shadow-lg bg-white dark:bg-gray-800"
          >
            <div className="flex items-start gap-4 mb-4">
              <div className="w-12 h-12 bg-blue-100 dark:bg-blue-900/30 rounded-lg flex items-center justify-center text-2xl">
                {article.order === 1 && '🎵'}
                {article.order === 2 && '📏'}
                {article.order === 3 && '🎨'}
                {article.order === 4 && '🧲'}
                {article.order === 5 && '🗺️'}
                {article.order === 6 && '👨‍👩‍👧‍👦'}
                {article.order === 7 && '👂'}
                {article.order === 8 && '🎸'}
              </div>
              <div className="flex-1">
                <h2 className="text-xl font-semibold group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors mb-2">
                  {article.title}
                </h2>
                <p className="text-sm text-gray-600 dark:text-gray-400 mb-2">
                  {article.subtitle}
                </p>
                <div className="flex items-center gap-4 text-xs text-gray-500 dark:text-gray-500">
                  <span>{article.readingTime}</span>
                  <span>•</span>
                  <span>記事 {article.order}</span>
                </div>
              </div>
            </div>
            
            {article.status === 'draft' && (
              <div className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300">
                近日公開
              </div>
            )}
          </Link>
        ))}
      </div>

      <div className="mt-12 p-6 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
        <h3 className="text-lg font-semibold mb-2">実践してみませんか？</h3>
        <p className="text-gray-600 dark:text-gray-300 mb-4">
          学んだことをOtoTheoryのインタラクティブツールで実践してみましょう。
        </p>
        <Link 
          href="/ja/chord-progression"
          className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
        >
          コード進行ビルダーを試す
        </Link>
      </div>
    </div>
  );
}
