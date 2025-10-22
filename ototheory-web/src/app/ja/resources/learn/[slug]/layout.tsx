import type { Metadata } from "next";
import { getArticle } from '@/lib/articles';

interface ArticleLayoutProps {
  children: React.ReactNode;
  params: {
    slug: string;
  };
}

export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  const article = getArticle(params.slug, 'ja');
  
  if (!article) {
    return {
      title: '記事が見つかりません | OtoTheory',
    };
  }

  return {
    title: `${article.title} | OtoTheory`,
    description: article.subtitle,
    keywords: article.keywords,
    alternates: {
      canonical: `/ja/resources/learn/${article.slug}`,
      languages: { 
        en: `/resources/learn/${article.slug}`, 
        'ja-JP': `/ja/resources/learn/${article.slug}`, 
        'x-default': `/ja/resources/learn/${article.slug}` 
      },
    },
    openGraph: {
      title: article.title,
      description: article.subtitle,
      type: 'article',
      publishedTime: article.updated,
      authors: ['OtoTheory Team'],
      tags: article.keywords,
    },
    twitter: {
      card: 'summary_large_image',
      title: article.title,
      description: article.subtitle,
    },
  };
}

export default function ArticleLayoutJa({ children }: ArticleLayoutProps) {
  return children;
}
