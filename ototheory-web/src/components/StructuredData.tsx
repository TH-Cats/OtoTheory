import Script from 'next/script';

interface StructuredDataProps {
  type: 'WebSite' | 'WebPage' | 'SoftwareApplication';
  data: any;
}

export default function StructuredData({ type, data }: StructuredDataProps) {
  const structuredData = {
    '@context': 'https://schema.org',
    '@type': type,
    ...data,
  };

  return (
    <Script
      id="structured-data"
      type="application/ld+json"
      dangerouslySetInnerHTML={{
        __html: JSON.stringify(structuredData, null, 2),
      }}
    />
  );
}

// ホームページ用の構造化データ
export function HomePageStructuredData() {
  return (
    <StructuredData
      type="WebSite"
      data={{
        name: 'OtoTheory',
        description: 'Free guitar chord finder, key analyzer, and music theory tool. Build chord progressions, discover scales, and support composition and guitar improvisation theoretically.',
        url: 'https://www.ototheory.com',
        potentialAction: {
          '@type': 'SearchAction',
          target: 'https://www.ototheory.com/find-chords?q={search_term_string}',
          'query-input': 'required name=search_term_string',
        },
        sameAs: [
          'https://github.com/TH-Cats/OtoTheory',
        ],
      }}
    />
  );
}

// コードライブラリページ用の構造化データ
export function ChordLibraryStructuredData() {
  return (
    <StructuredData
      type="WebPage"
      data={{
        name: 'Guitar Chord Library',
        description: 'Interactive chord diagrams with finger numbers, strum/arpeggio preview, and compare mode for guitarists.',
        url: 'https://www.ototheory.com/chord-library',
        isPartOf: {
          '@type': 'WebSite',
          name: 'OtoTheory',
          url: 'https://www.ototheory.com',
        },
        breadcrumb: {
          '@type': 'BreadcrumbList',
          itemListElement: [
            {
              '@type': 'ListItem',
              position: 1,
              name: 'Home',
              item: 'https://www.ototheory.com',
            },
            {
              '@type': 'ListItem',
              position: 2,
              name: 'Chord Library',
              item: 'https://www.ototheory.com/chord-library',
            },
          ],
        },
      }}
    />
  );
}

// アプリケーション用の構造化データ
export function AppStructuredData() {
  return (
    <StructuredData
      type="SoftwareApplication"
      data={{
        name: 'OtoTheory',
        description: 'Free guitar chord finder, key analyzer, and music theory tool for guitarists.',
        url: 'https://www.ototheory.com',
        applicationCategory: 'MusicApplication',
        operatingSystem: 'Web Browser, iOS',
        offers: {
          '@type': 'Offer',
          price: '0',
          priceCurrency: 'USD',
        },
        aggregateRating: {
          '@type': 'AggregateRating',
          ratingValue: '4.8',
          ratingCount: '150',
        },
      }}
    />
  );
}