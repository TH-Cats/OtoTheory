/**
 * @fileoverview Article Navigation - Previous/Next article links
 * 
 * SSOT参照:
 * - メイン仕様: /docs/SSOT/v3.2_SSOT.md
 * - 実装仕様: /docs/SSOT/v3.2_Implementation_SSOT.md
 * - リソース仕様: /docs/SSOT/RESOURCES_SSOT_v1.md
 * 
 * 変更時は必ずSSOTとの整合性を確認すること
 */

'use client';

import Link from 'next/link';
import { ArticleWithContent } from '@/lib/articles';

interface ArticleNavigationProps {
  currentArticle: ArticleWithContent;
  prevArticle: ArticleWithContent | null;
  nextArticle: ArticleWithContent | null;
  lang: 'ja' | 'en';
}

export default function ArticleNavigation({ 
  currentArticle, 
  prevArticle, 
  nextArticle, 
  lang 
}: ArticleNavigationProps) {
  const basePath = lang === 'ja' ? '/ja/resources/learn' : '/resources/learn';

  return (
    <nav className="mt-12 pt-8 border-t border-gray-200 dark:border-gray-700">
      <div className="flex justify-between items-center">
        {prevArticle ? (
          <Link 
            href={`${basePath}/${prevArticle.slug}`}
            className="group flex items-center gap-2 text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 transition-colors"
          >
            <svg className="w-4 h-4 transform group-hover:-translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
            <div>
              <div className="text-sm text-gray-500 dark:text-gray-400">
                {lang === 'ja' ? '前の記事' : 'Previous'}
              </div>
              <div className="font-medium">{prevArticle.title}</div>
            </div>
          </Link>
        ) : (
          <div></div>
        )}

        {nextArticle && (
          <Link 
            href={`${basePath}/${nextArticle.slug}`}
            className="group flex items-center gap-2 text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 transition-colors"
          >
            <div className="text-right">
              <div className="text-sm text-gray-500 dark:text-gray-400">
                {lang === 'ja' ? '次の記事' : 'Next'}
              </div>
              <div className="font-medium">{nextArticle.title}</div>
            </div>
            <svg className="w-4 h-4 transform group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
            </svg>
          </Link>
        )}
      </div>
    </nav>
  );
}
