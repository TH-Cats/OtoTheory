import Script from 'next/script';

interface WebApplicationSchema {
  name: string;
  description: string;
  url: string;
  applicationCategory?: string;
  offers?: {
    price: string;
    priceCurrency: string;
  };
}

interface BreadcrumbItem {
  name: string;
  url: string;
}

export function WebApplicationStructuredData({ 
  name, 
  description, 
  url,
  applicationCategory = "MusicApplication",
  offers = { price: "0", priceCurrency: "USD" },
  lang = 'en',
}: WebApplicationSchema & { lang?: 'en'|'ja' }) {
  const schema = {
    "@context": "https://schema.org",
    "@type": "WebApplication",
    "name": name,
    "url": url,
    "description": description,
    "inLanguage": lang === 'ja' ? 'ja-JP' : 'en-US',
    "applicationCategory": applicationCategory,
    "operatingSystem": "Web Browser",
    "offers": {
      "@type": "Offer",
      "price": offers.price,
      "priceCurrency": offers.priceCurrency
    },
    "creator": {
      "@type": "Organization",
      "name": "OtoTheory"
    },
    "browserRequirements": "Requires JavaScript. Requires HTML5.",
    "softwareVersion": "3.1",
    "keywords": "guitar, music theory, chords, scales, chord progression"
  };

  return (
    <Script
      id="structured-data-webapp"
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}

export function BreadcrumbStructuredData({ items, lang = 'en' }: { items: BreadcrumbItem[]; lang?: 'en'|'ja' }) {
  const schema = {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "inLanguage": lang === 'ja' ? 'ja-JP' : 'en-US',
    "itemListElement": items.map((item, index) => ({
      "@type": "ListItem",
      "position": index + 1,
      "name": item.name,
      "item": item.url
    }))
  };

  return (
    <Script
      id="structured-data-breadcrumb"
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}

export function FAQStructuredData({ faqs, lang = 'en' }: { 
  faqs: Array<{ question: string; answer: string }>, lang?: 'en'|'ja' 
}) {
  const schema = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "inLanguage": lang === 'ja' ? 'ja-JP' : 'en-US',
    "mainEntity": faqs.map(faq => ({
      "@type": "Question",
      "name": faq.question,
      "acceptedAnswer": {
        "@type": "Answer",
        "text": faq.answer
      }
    }))
  };

  return (
    <Script
      id="structured-data-faq"
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}

export function OrganizationStructuredData({ lang = 'en' }: { lang?: 'en'|'ja' } = {}) {
  const schema = {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "OtoTheory",
    "url": "https://www.ototheory.com",
    "logo": "https://www.ototheory.com/og.png",
    "description": "Free guitar music theory tool for chord progressions, key analysis, and scale exploration",
    "inLanguage": lang === 'ja' ? 'ja-JP' : 'en-US',
    "sameAs": [
      // 将来的にSNSアカウントを追加
    ]
  };

  return (
    <Script
      id="structured-data-organization"
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}

export function SoftwareApplicationStructuredData({
  name,
  description,
  category = "Music",
  lang = 'en',
}: {
  name: string;
  description: string;
  category?: string;
  lang?: 'en'|'ja';
}) {
  const schema = {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    "name": name,
    "description": description,
    "applicationCategory": category,
    "operatingSystem": "Any",
    "inLanguage": lang === 'ja' ? 'ja-JP' : 'en-US',
    "offers": {
      "@type": "Offer",
      "price": "0",
      "priceCurrency": "USD"
    }
    // aggregateRating removed: Only include when real user reviews exist
    // per Google's structured data policy
  };

  return (
    <Script
      id="structured-data-software"
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
    />
  );
}

