/**
 * @fileoverview Article Management - Static data version for Vercel
 * 
 * この修正版はファイルシステムアクセスを使用せず、
 * ビルド時に生成された静的データを使用します。
 * 
 * SSOT参照:
 * - メイン仕様: /docs/SSOT/v3.2_SSOT.md
 * - 実装仕様: /docs/SSOT/v3.2_Implementation_SSOT.md
 * - リソース仕様: /docs/SSOT/RESOURCES_SSOT_v1.md
 */

import { Article, validateArticle } from './schemas/article.schema';
import { articlesData } from './articlesData';

export interface ArticleWithContent extends Article {
  content: string;
  htmlContent: string;
}

/**
 * すべての記事を取得（静的データから）
 */
export function getAllArticles(lang: 'ja' | 'en' = 'ja'): ArticleWithContent[] {
  console.log(`[articles.ts] Getting articles for ${lang}`);
  console.log(`[articles.ts] articlesData keys:`, Object.keys(articlesData));
  console.log(`[articles.ts] articlesData[${lang}] length:`, articlesData[lang]?.length || 0);
  
  const articles = articlesData[lang] || [];
  console.log(`[articles.ts] Found ${articles.length} ${lang} articles from static data`);
  
  // バリデーションとソート
  return articles
    .map(article => {
      try {
        // Zodスキーマでバリデーション
        const validated = validateArticle({
          title: article.title,
          subtitle: article.subtitle,
          lang: article.lang,
          slug: article.slug,
          order: article.order,
          status: article.status,
          readingTime: article.readingTime,
          updated: article.updated,
          keywords: article.keywords,
          related: article.related,
          sources: article.sources,
        });
        
        return {
          ...validated,
          content: article.content || '',
          htmlContent: article.htmlContent || '',
        };
      } catch (error) {
        console.error(`[articles.ts] Error validating article ${article.slug}:`, error);
        return null;
      }
    })
    .filter((article): article is ArticleWithContent => article !== null)
    .sort((a, b) => a.order - b.order);
}

/**
 * スラッグから記事を取得
 */
export function getArticle(slug: string, lang: 'ja' | 'en' = 'ja'): ArticleWithContent | null {
  const articles = getAllArticles(lang);
  return articles.find(article => article.slug === slug) || null;
}

/**
 * 公開済み記事のみ取得
 */
export function getPublishedArticles(lang: 'ja' | 'en' = 'ja'): ArticleWithContent[] {
  return getAllArticles(lang).filter(article => article.status === 'published');
}

/**
 * 順番から記事を取得
 */
export function getArticleByOrder(order: number, lang: 'ja' | 'en' = 'ja'): ArticleWithContent | null {
  const articles = getAllArticles(lang);
  return articles.find(article => article.order === order) || null;
}

/**
 * 次の記事を取得
 */
export function getNextArticle(currentOrder: number, lang: 'ja' | 'en' = 'ja'): ArticleWithContent | null {
  const articles = getPublishedArticles(lang);
  return articles.find(article => article.order === currentOrder + 1) || null;
}

/**
 * 前の記事を取得
 */
export function getPrevArticle(currentOrder: number, lang: 'ja' | 'en' = 'ja'): ArticleWithContent | null {
  const articles = getPublishedArticles(lang);
  return articles.find(article => article.order === currentOrder - 1) || null;
}

/**
 * デバッグ用: 記事データの状態を確認
 */
export function debugArticleData(): void {
  console.log('=== Article Data Debug Info ===');
  console.log('Japanese articles:', articlesData.ja?.length || 0);
  console.log('English articles:', articlesData.en?.length || 0);
  
  if (articlesData.ja?.length > 0) {
    console.log('Japanese article titles:');
    articlesData.ja.forEach(a => console.log(`  - ${a.order}. ${a.title} (${a.status})`));
  }
  
  if (articlesData.en?.length > 0) {
    console.log('English article titles:');
    articlesData.en.forEach(a => console.log(`  - ${a.order}. ${a.title} (${a.status})`));
  }
  console.log('===============================');
}