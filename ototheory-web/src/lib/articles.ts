/**
 * @fileoverview Article Management - Markdown parsing and utilities
 * 
 * SSOT参照:
 * - メイン仕様: /docs/SSOT/v3.2_SSOT.md
 * - 実装仕様: /docs/SSOT/v3.2_Implementation_SSOT.md
 * - リソース仕様: /docs/SSOT/RESOURCES_SSOT_v1.md
 * 
 * 変更時は必ずSSOTとの整合性を確認すること
 */

import fs from 'fs';
import path from 'path';
import matter from 'gray-matter';
import { Article, validateArticle } from './schemas/article.schema';

const BASE_DIR = process.cwd();
const ARTICLES_DIR = path.join(BASE_DIR, 'docs', 'content', 'resources', 'learn');

// デバッグ用ログ（本番環境でのファイル存在確認）
console.log('[articles.ts] process.cwd():', BASE_DIR);
console.log('[articles.ts] ARTICLES_DIR:', ARTICLES_DIR);
try {
  console.log('[articles.ts] Files in process.cwd():', fs.readdirSync(BASE_DIR).slice(0, 10));
  if (fs.existsSync(path.join(BASE_DIR, 'docs'))) {
    console.log('[articles.ts] Files in docs/:', fs.readdirSync(path.join(BASE_DIR, 'docs')));
  } else {
    console.log('[articles.ts] docs/ directory NOT FOUND at root.');
  }
} catch (e) {
  console.error('[articles.ts] Error reading directories:', e);
}

export interface ArticleWithContent extends Article {
  content: string;
  htmlContent: string;
}

export function getAllArticles(lang: 'ja' | 'en' = 'ja'): ArticleWithContent[] {
  const langDir = path.join(ARTICLES_DIR, lang);
  console.log(`[articles.ts] Checking langDir: ${langDir}`);
  
  if (!fs.existsSync(langDir)) {
    console.error(`[articles.ts] Lang directory NOT FOUND: ${langDir}`);
    return [];
  }

  const files = fs.readdirSync(langDir);
  console.log(`[articles.ts] Files found in ${lang}:`, files);
  const articles: ArticleWithContent[] = [];

  for (const file of files) {
    if (!file.endsWith('.md')) continue;

    const filePath = path.join(langDir, file);
    const fileContent = fs.readFileSync(filePath, 'utf-8');
    const { data, content } = matter(fileContent);

    try {
      const article = validateArticle(data);
      articles.push({
        ...article,
        content,
        htmlContent: '', // Will be processed by ArticleRenderer
      });
    } catch (error) {
      console.error(`Error parsing article ${file}:`, error);
    }
  }

  return articles.sort((a, b) => a.order - b.order);
}

export function getArticle(slug: string, lang: 'ja' | 'en' = 'ja'): ArticleWithContent | null {
  const articles = getAllArticles(lang);
  return articles.find(article => article.slug === slug) || null;
}

export function getPublishedArticles(lang: 'ja' | 'en' = 'ja'): ArticleWithContent[] {
  return getAllArticles(lang).filter(article => article.status === 'published');
}

export function getArticleByOrder(order: number, lang: 'ja' | 'en' = 'ja'): ArticleWithContent | null {
  const articles = getAllArticles(lang);
  return articles.find(article => article.order === order) || null;
}

export function getNextArticle(currentOrder: number, lang: 'ja' | 'en' = 'ja'): ArticleWithContent | null {
  const articles = getPublishedArticles(lang);
  return articles.find(article => article.order === currentOrder + 1) || null;
}

export function getPrevArticle(currentOrder: number, lang: 'ja' | 'en' = 'ja'): ArticleWithContent | null {
  const articles = getPublishedArticles(lang);
  return articles.find(article => article.order === currentOrder - 1) || null;
}
