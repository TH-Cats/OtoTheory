import fs from 'fs';
import path from 'path';
import matter from 'gray-matter';
import { Article, validateArticle } from './schemas/article.schema';

const ARTICLES_DIR = path.join(process.cwd(), '..', 'docs', 'content', 'resources', 'learn');

export interface ArticleWithContent extends Article {
  content: string;
  htmlContent: string;
}

export function getAllArticles(lang: 'ja' | 'en' = 'ja'): ArticleWithContent[] {
  const langDir = path.join(ARTICLES_DIR, lang);
  
  if (!fs.existsSync(langDir)) {
    return [];
  }

  const files = fs.readdirSync(langDir);
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
