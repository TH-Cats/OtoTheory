/**
 * @fileoverview Resources Learn Section - Article List Page
 * 
 * SSOT参照:
 * - メイン仕様: /docs/SSOT/v3.2_SSOT.md
 * - 言語仕様: /docs/SSOT/EN_JA_language_SSOT.md
 * - 実装仕様: /docs/SSOT/v3.2_Implementation_SSOT.md
 * - リソース仕様: /docs/SSOT/RESOURCES_SSOT_v1.md
 * 
 * 変更時は必ずSSOTとの整合性を確認すること
 */

import Link from 'next/link';
import { getAllArticles } from '@/lib/articles';

export default function LearnPage() {
  const articles = getAllArticles('en');

  return (
    <div className="ot-page ot-stack">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-4">Learn Music Theory</h1>
        <p className="text-lg text-gray-600 dark:text-gray-300 leading-relaxed">
          Turn your musical instinct into understanding. Learn the fundamentals of music theory 
          through practical examples and real-world applications.
        </p>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {articles.map((article) => {
          const isDraft = article.status === 'draft';
          
          if (isDraft) {
            return (
              <div
                key={article.slug}
                className="group block p-6 rounded-lg border border-gray-200 dark:border-gray-700 transition-all bg-white dark:bg-gray-800 opacity-75 cursor-not-allowed"
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
                      <span>Article {article.order}</span>
                    </div>
                  </div>
                </div>
                
                <div className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300">
                  Coming Soon
                </div>
              </div>
            );
          } else {
            return (
              <Link
                key={article.slug}
                href={`/resources/learn/${article.slug}`}
                className="group block p-6 rounded-lg border border-gray-200 dark:border-gray-700 transition-all bg-white dark:bg-gray-800 hover:border-blue-500 dark:hover:border-blue-400 hover:shadow-lg"
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
                      <span>Article {article.order}</span>
                    </div>
                  </div>
                </div>
              </Link>
            );
          }
        })}
      </div>

      <div className="mt-12 p-6 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
        <h3 className="text-lg font-semibold mb-2">Ready to practice?</h3>
        <p className="text-gray-600 dark:text-gray-300 mb-4">
          Apply what you've learned with OtoTheory's interactive tools.
        </p>
        <Link 
          href="/chord-progression"
          className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
        >
          Try Chord Progression Builder
        </Link>
      </div>
    </div>
  );
}
