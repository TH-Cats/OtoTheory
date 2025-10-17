import { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: [
          '/_next/',
          '/api/',
          '/admin/',
          '*.json',
          '*.ico',
          '*.woff2',
          '*.woff',
          '*.ttf',
        ],
      },
    ],
    sitemap: 'https://www.ototheory.com/sitemap.xml',
  };
}


