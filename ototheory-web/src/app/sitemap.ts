import { MetadataRoute } from 'next';

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = 'https://www.ototheory.com';
  const lastModified = new Date('2025-10-14'); // Chord Library 独立化

  const pages = [
    { path: '/', changeFrequency: 'weekly' as const, priority: 1.0 },
    { path: '/chord-progression', changeFrequency: 'weekly' as const, priority: 0.95 },
    { path: '/find-chords', changeFrequency: 'weekly' as const, priority: 0.95 },
    { path: '/chord-library', changeFrequency: 'weekly' as const, priority: 0.95 },
    { path: '/resources', changeFrequency: 'monthly' as const, priority: 0.8 },
    { path: '/resources/music-theory', changeFrequency: 'monthly' as const, priority: 0.75 },
    { path: '/resources/glossary', changeFrequency: 'monthly' as const, priority: 0.75 },
    { path: '/getting-started', changeFrequency: 'monthly' as const, priority: 0.7 },
    { path: '/about', changeFrequency: 'monthly' as const, priority: 0.6 },
    { path: '/pricing', changeFrequency: 'monthly' as const, priority: 0.65 },
    { path: '/faq', changeFrequency: 'monthly' as const, priority: 0.6 },
    { path: '/support', changeFrequency: 'monthly' as const, priority: 0.5 },
    { path: '/privacy', changeFrequency: 'yearly' as const, priority: 0.3 },
    { path: '/terms', changeFrequency: 'yearly' as const, priority: 0.3 },
  ];

  return pages.flatMap(p => ([
    {
      url: `${baseUrl}${p.path}`,
      lastModified,
      changeFrequency: p.changeFrequency,
      priority: p.priority,
    },
    {
      url: `${baseUrl}/ja${p.path === '/' ? '' : p.path}`,
      lastModified,
      changeFrequency: p.changeFrequency,
      priority: p.priority,
    },
  ]));
}

