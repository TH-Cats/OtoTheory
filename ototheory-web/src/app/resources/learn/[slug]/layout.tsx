import type { Metadata } from "next";
import { getArticle } from '@/lib/articles';

interface ArticleLayoutProps {
  children: React.ReactNode;
  params: {
    slug: string;
  };
}

export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  const article = getArticle(params.slug, 'en');
  
  if (!article) {
    return {
      title: 'Article Not Found | OtoTheory',
    };
  }

  return {
    title: `${article.title} | OtoTheory`,
    description: article.subtitle,
    keywords: article.keywords,
    alternates: {
      canonical: `/resources/learn/${article.slug}`,
      languages: { 
        en: `/resources/learn/${article.slug}`, 
        'ja-JP': `/ja/resources/learn/${article.slug}`, 
        'x-default': `/resources/learn/${article.slug}` 
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

export default function ArticleLayout({ children }: ArticleLayoutProps) {
  return children;
}
