import { notFound } from 'next/navigation';
import Link from 'next/link';
import { getArticle, getNextArticle, getPrevArticle, getPublishedArticles } from '@/lib/articles';
import ArticleRenderer from '../../../../resources/learn/_components/ArticleRenderer';
import ArticleNavigation from '../../../../resources/learn/_components/ArticleNavigation';

interface ArticlePageProps {
  params: {
    slug: string;
  };
}

export default function ArticlePageJa({ params }: ArticlePageProps) {
  const article = getArticle(params.slug, 'ja');
  
  if (!article) {
    notFound();
  }

  const prevArticle = getPrevArticle(article.order, 'ja');
  const nextArticle = getNextArticle(article.order, 'ja');

  return (
    <article className="ot-page">
      <div className="mb-6">
        <Link 
          href="/ja/resources/learn" 
          className="text-sm text-blue-600 dark:text-blue-400 hover:underline mb-4 inline-block"
        >
          ← 学習ページに戻る
        </Link>
        
        <div className="mb-4">
          <h1 className="text-3xl font-bold mb-2">{article.title}</h1>
          <p className="text-lg text-gray-600 dark:text-gray-300">{article.subtitle}</p>
        </div>
        
        <div className="flex items-center gap-4 text-sm text-gray-500 dark:text-gray-400 mb-6">
          <span>{article.readingTime}</span>
          <span>•</span>
          <span>更新日 {article.updated}</span>
          <span>•</span>
          <span>記事 {article.order}</span>
        </div>
      </div>

      <ArticleRenderer article={article} />

      <ArticleNavigation 
        currentArticle={article}
        prevArticle={prevArticle}
        nextArticle={nextArticle}
        lang="ja"
      />
    </article>
  );
}

export function generateStaticParams() {
  const articles = getPublishedArticles('ja');
  return articles.map((article) => ({
    slug: article.slug,
  }));
}
