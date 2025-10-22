import { notFound } from 'next/navigation';
import Link from 'next/link';
import { getArticle, getNextArticle, getPrevArticle, getPublishedArticles } from '@/lib/articles';
import ArticleRenderer from '../_components/ArticleRenderer';
import ArticleNavigation from '../_components/ArticleNavigation';

interface ArticlePageProps {
  params: {
    slug: string;
  };
}

export default function ArticlePage({ params }: ArticlePageProps) {
  const article = getArticle(params.slug, 'en');
  
  if (!article) {
    notFound();
  }

  const prevArticle = getPrevArticle(article.order, 'en');
  const nextArticle = getNextArticle(article.order, 'en');

  return (
    <article className="ot-page">
      <div className="mb-6">
        <Link 
          href="/resources/learn" 
          className="text-sm text-blue-600 dark:text-blue-400 hover:underline mb-4 inline-block"
        >
          ← Back to Learn
        </Link>
        
        <div className="mb-4">
          <h1 className="text-3xl font-bold mb-2">{article.title}</h1>
          <p className="text-lg text-gray-600 dark:text-gray-300">{article.subtitle}</p>
        </div>
        
        <div className="flex items-center gap-4 text-sm text-gray-500 dark:text-gray-400 mb-6">
          <span>{article.readingTime}</span>
          <span>•</span>
          <span>Updated {article.updated}</span>
          <span>•</span>
          <span>Article {article.order}</span>
        </div>
      </div>

      <ArticleRenderer article={article} />

      <ArticleNavigation 
        currentArticle={article}
        prevArticle={prevArticle}
        nextArticle={nextArticle}
        lang="en"
      />
    </article>
  );
}

export function generateStaticParams() {
  const articles = getPublishedArticles('en');
  return articles.map((article) => ({
    slug: article.slug,
  }));
}
