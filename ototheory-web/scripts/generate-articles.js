/**
 * 記事データ静的生成スクリプト
 * 
 * このスクリプトはビルド時に実行され、Markdownファイルから
 * TypeScriptファイルを生成します。これによりVercelでの
 * ファイルシステムアクセス問題を解決します。
 */

const fs = require('fs');
const path = require('path');
const matter = require('gray-matter');

const CONTENT_DIR = path.join(process.cwd(), 'docs', 'content', 'resources', 'learn');
const OUTPUT_FILE = path.join(process.cwd(), 'src', 'lib', 'articlesData.ts');

// 出力ディレクトリが存在しない場合は作成
const outputDir = path.dirname(OUTPUT_FILE);
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

function escapeContent(content) {
  // TypeScriptの文字列として安全にエスケープ
  return content
    .replace(/\\/g, '\\\\')
    .replace(/`/g, '\\`')
    .replace(/\$/g, '\\$');
}

function generateArticlesData() {
  const languages = ['ja', 'en'];
  const articlesData = {};
  
  console.log('🔍 Generating articles data...');
  console.log(`📁 Content directory: ${CONTENT_DIR}`);
  
  // コンテンツディレクトリが存在するか確認
  if (!fs.existsSync(CONTENT_DIR)) {
    console.error(`❌ Content directory not found: ${CONTENT_DIR}`);
    console.log('Creating empty articlesData...');
    
    // 空のデータを生成
    const emptyOutput = `
// This file is auto-generated. Do not edit manually.
// Generated at: ${new Date().toISOString()}
// ⚠️ No articles found - content directory missing

export const articlesData = {
  ja: [],
  en: []
} as const;

export type ArticleData = typeof articlesData;
`;
    fs.writeFileSync(OUTPUT_FILE, emptyOutput);
    return;
  }

  languages.forEach(lang => {
    const langDir = path.join(CONTENT_DIR, lang);
    console.log(`\n📂 Processing ${lang} articles from: ${langDir}`);
    
    if (!fs.existsSync(langDir)) {
      console.warn(`⚠️  Language directory not found: ${langDir}`);
      articlesData[lang] = [];
      return;
    }

    const files = fs.readdirSync(langDir);
    console.log(`📄 Found ${files.length} files`);
    articlesData[lang] = [];

    files.forEach(file => {
      if (!file.endsWith('.md')) {
        console.log(`⏩ Skipping non-markdown file: ${file}`);
        return;
      }
      
      console.log(`✅ Processing: ${file}`);
      const filePath = path.join(langDir, file);
      const fileContent = fs.readFileSync(filePath, 'utf-8');
      const { data, content } = matter(fileContent);
      
      // Zodスキーマと同じ構造を保持
      const article = {
        title: data.title || '',
        subtitle: data.subtitle || '',
        lang: data.lang || lang,
        slug: data.slug || file.replace('.md', ''),
        order: data.order || 1,
        status: data.status || 'draft',
        readingTime: data.readingTime || '5min',
        updated: data.updated || new Date().toISOString().split('T')[0],
        keywords: data.keywords || [],
        related: data.related || [],
        sources: data.sources || [],
        content: content,
        htmlContent: '',
      };
      
      articlesData[lang].push(article);
    });
    
    console.log(`✨ Processed ${articlesData[lang].length} ${lang} articles`);
  });

  // TypeScriptファイルとして出力
  const output = `
// This file is auto-generated. Do not edit manually.
// Generated at: ${new Date().toISOString()}
// Source: ${CONTENT_DIR}

import { Article } from './schemas/article.schema';

export interface ArticleWithContent extends Article {
  content: string;
  htmlContent: string;
}

export const articlesData: Record<'ja' | 'en', ArticleWithContent[]> = {
  ja: [${articlesData.ja?.map(article => `
    {
      title: ${JSON.stringify(article.title)},
      subtitle: ${JSON.stringify(article.subtitle)},
      lang: ${JSON.stringify(article.lang)},
      slug: ${JSON.stringify(article.slug)},
      order: ${article.order},
      status: ${JSON.stringify(article.status)},
      readingTime: ${JSON.stringify(article.readingTime)},
      updated: ${JSON.stringify(article.updated)},
      keywords: ${JSON.stringify(article.keywords)},
      related: ${JSON.stringify(article.related)},
      sources: ${JSON.stringify(article.sources)},
      content: \`${escapeContent(article.content)}\`,
      htmlContent: ''
    }`).join(',') || ''}
  ],
  en: [${articlesData.en?.map(article => `
    {
      title: ${JSON.stringify(article.title)},
      subtitle: ${JSON.stringify(article.subtitle)},
      lang: ${JSON.stringify(article.lang)},
      slug: ${JSON.stringify(article.slug)},
      order: ${article.order},
      status: ${JSON.stringify(article.status)},
      readingTime: ${JSON.stringify(article.readingTime)},
      updated: ${JSON.stringify(article.updated)},
      keywords: ${JSON.stringify(article.keywords)},
      related: ${JSON.stringify(article.related)},
      sources: ${JSON.stringify(article.sources)},
      content: \`${escapeContent(article.content)}\`,
      htmlContent: ''
    }`).join(',') || ''}
  ]
};

export type ArticleData = typeof articlesData;
`;

  fs.writeFileSync(OUTPUT_FILE, output);
  console.log(`\n✅ Generated ${OUTPUT_FILE}`);
  console.log(`📊 Total articles: ${articlesData.ja?.length || 0} (ja) + ${articlesData.en?.length || 0} (en)`);
}

// スクリプトを実行
try {
  generateArticlesData();
  console.log('\n🎉 Article data generation completed successfully!');
} catch (error) {
  console.error('\n❌ Error generating articles data:', error);
  process.exit(1);
}
