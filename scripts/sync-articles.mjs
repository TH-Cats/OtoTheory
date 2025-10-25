#!/usr/bin/env node

/**
 * sync-articles.mjs
 * 
 * OtoTheory記事同期スクリプト
 * マスター記事からWeb版とiOS版に自動配信
 * 
 * 使い方:
 *   npm run sync:articles           # 通常実行
 *   npm run sync:articles:dry       # dry-run（実際には変更しない）
 *   npm run sync:articles:force     # 警告を無視して強制実行
 * 
 * 機能:
 *   - マスター記事の読み込み
 *   - 言語混在チェック
 *   - Web版への同期（articlesData.ts生成）
 *   - iOS版への同期（Markdownファイルコピー）
 *   - 自動バックアップとロールバック
 */

import fs from 'fs/promises';
import fsSync from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import matter from 'gray-matter';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// パス設定
const MASTER_DIR = path.join(__dirname, '../docs/content/resources/learn');
const WEB_OUTPUT = path.join(__dirname, '../ototheory-web/src/lib/articlesData.ts');
const IOS_OUTPUT = path.join(__dirname, '../OtoTheory-iOS/OtoTheory/Articles');

// 固有名詞リスト（言語チェックで除外）
const PROPER_NOUNS = [
  'Beatles', 'Paul', 'McCartney', 'John', 'Lennon',
  'George', 'Harrison', 'Ringo', 'Starr',
  'Rolling', 'Stones', 'Eric', 'Clapton',
  'FACT', 'OtoTheory'
];

// コマンドライン引数の解析
const args = process.argv.slice(2);
const options = {
  dryRun: args.includes('--dry-run'),
  force: args.includes('--force'),
  verbose: args.includes('--verbose') || args.includes('-v')
};

// MARK: - メイン関数

async function main() {
  console.log('🚀 Starting article sync...');
  console.log(`   Mode: ${options.dryRun ? 'DRY RUN' : 'LIVE'}`);
  console.log(`   Master: ${MASTER_DIR}`);
  console.log(`   Web: ${WEB_OUTPUT}`);
  console.log(`   iOS: ${IOS_OUTPUT}`);
  console.log('');
  
  // バックアップを保存
  const backup = {
    webFile: null,
    iosDir: null
  };
  
  try {
    // Step 1: バックアップ
    if (!options.dryRun) {
      console.log('📦 Creating backups...');
      backup.webFile = await createBackup(WEB_OUTPUT);
      backup.iosDir = await createBackup(IOS_OUTPUT);
      console.log('✅ Backups created');
      console.log('');
    }
    
    // Step 2: マスター記事の読み込み
    console.log('📖 Loading master articles...');
    const articles = await loadMasterArticles(MASTER_DIR);
    console.log(`✅ Loaded ${articles.length} articles from master`);
    console.log(`   - ja: ${articles.filter(a => a.lang === 'ja').length} articles`);
    console.log(`   - en: ${articles.filter(a => a.lang === 'en').length} articles`);
    console.log('');
    
    // Step 3: 言語混在チェック
    console.log('🔍 Checking language purity...');
    const languageIssues = checkLanguagePurity(articles);
    
    if (languageIssues.length > 0) {
      console.error('❌ Language purity issues found:');
      languageIssues.forEach(issue => console.error(`   - ${issue}`));
      console.log('');
      
      if (!options.force) {
        throw new Error('Language purity check failed. Use --force to proceed anyway.');
      } else {
        console.log('⚠️  Continuing with --force option...');
        console.log('');
      }
    } else {
      console.log('✅ All articles have correct language separation');
      console.log('');
    }
    
    // Step 4: Web版への同期
    console.log('🌐 Syncing to Web...');
    if (!options.dryRun) {
      await syncToWeb(articles, WEB_OUTPUT);
      console.log(`✅ Synced to Web: ${WEB_OUTPUT}`);
    } else {
      console.log(`   [DRY RUN] Would sync to Web: ${WEB_OUTPUT}`);
    }
    console.log('');
    
    // Step 5: iOS版への同期
    console.log('📱 Syncing to iOS...');
    if (!options.dryRun) {
      await syncToIOS(articles, IOS_OUTPUT);
      console.log(`✅ Synced to iOS: ${IOS_OUTPUT}`);
    } else {
      console.log(`   [DRY RUN] Would sync to iOS: ${IOS_OUTPUT}`);
    }
    console.log('');
    
    // Step 6: 検証
    if (!options.dryRun) {
      console.log('🔍 Validating sync...');
      const webValid = await validateWebSync(WEB_OUTPUT);
      const iosValid = await validateIOSSync(IOS_OUTPUT, articles);
      
      if (!webValid || !iosValid) {
        throw new Error('Sync validation failed');
      }
      
      console.log('✅ Validation passed');
      console.log('');
    }
    
    console.log('🎉 Sync completed successfully!');
    
  } catch (error) {
    console.error('');
    console.error('❌ Sync failed:', error.message);
    console.error('');
    
    // ロールバック
    if (!options.dryRun && (backup.webFile || backup.iosDir)) {
      console.log('🔄 Rolling back...');
      
      if (backup.webFile) {
        await restoreBackup(backup.webFile, WEB_OUTPUT);
        console.log('   ✅ Web version restored');
      }
      
      if (backup.iosDir) {
        await restoreBackup(backup.iosDir, IOS_OUTPUT);
        console.log('   ✅ iOS version restored');
      }
      
      console.log('🎉 Rollback completed');
    }
    
    process.exit(1);
  }
}

// MARK: - マスター記事の読み込み

async function loadMasterArticles(masterDir) {
  const articles = [];
  const languages = ['ja', 'en'];
  
  for (const lang of languages) {
    const langDir = path.join(masterDir, lang);
    
    try {
      const files = await fs.readdir(langDir);
      const mdFiles = files.filter(f => f.endsWith('.md'));
      
      if (options.verbose) {
        console.log(`   Reading ${lang} directory: ${mdFiles.length} files`);
      }
      
      for (const file of mdFiles) {
        const filePath = path.join(langDir, file);
        const content = await fs.readFile(filePath, 'utf-8');
        const { data: frontmatter, content: markdown } = matter(content);
        
        // front-matterの検証
        if (!frontmatter.title) {
          console.warn(`   ⚠️  Skipping ${file}: missing title`);
          continue;
        }
        
        if (!frontmatter.slug) {
          console.warn(`   ⚠️  Skipping ${file}: missing slug`);
          continue;
        }
        
        articles.push({
          lang: frontmatter.lang || lang,
          slug: frontmatter.slug,
          title: frontmatter.title,
          subtitle: frontmatter.subtitle || '',
          order: frontmatter.order || 0,
          status: frontmatter.status || 'draft',
          readingTime: frontmatter.readingTime || '5min',
          updated: frontmatter.updated || new Date().toISOString().split('T')[0],
          keywords: frontmatter.keywords || [],
          related: frontmatter.related || [],
          sources: frontmatter.sources || [],
          content: markdown,
          filename: file
        });
      }
    } catch (error) {
      console.warn(`   ⚠️  Could not read ${lang} directory: ${error.message}`);
    }
  }
  
  return articles.sort((a, b) => a.order - b.order);
}

// MARK: - 言語混在チェック

function checkLanguagePurity(articles) {
  const issues = [];
  
  for (const article of articles) {
    const { lang, content, slug } = article;
    
    if (lang === 'ja') {
      // 日本語記事に英語が多すぎる場合
      const englishRatio = countEnglish(content) / content.length;
      if (englishRatio > 0.3) {  // 30%以上が英語
        issues.push(`${slug} (ja): Too much English content (${(englishRatio * 100).toFixed(1)}%)`);
      }
    } else if (lang === 'en') {
      // 英語記事に日本語が含まれる場合
      const japaneseCount = countJapanese(content);
      if (japaneseCount > 50) {  // 50文字以上の日本語
        issues.push(`${slug} (en): Japanese content found (${japaneseCount} characters)`);
      }
    }
  }
  
  return issues;
}

function countJapanese(text) {
  // ひらがな、カタカナ、漢字をカウント
  const japaneseRegex = /[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]/g;
  const matches = text.match(japaneseRegex);
  return matches ? matches.length : 0;
}

function countEnglish(text) {
  // アルファベットをカウント（固有名詞を除外）
  const englishRegex = /[a-zA-Z]+/g;
  const matches = text.match(englishRegex);
  if (!matches) return 0;
  
  // 固有名詞を除外
  const filtered = matches.filter(word => {
    return !PROPER_NOUNS.some(noun => 
      word.toLowerCase().includes(noun.toLowerCase())
    );
  });
  
  return filtered.join('').length;
}

// MARK: - Web版への同期

async function syncToWeb(articles, outputPath) {
  const outputDir = path.dirname(outputPath);
  
  // 出力ディレクトリが存在しない場合は作成
  try {
    await fs.access(outputDir);
  } catch {
    await fs.mkdir(outputDir, { recursive: true });
  }
  
  // TypeScriptファイルとして生成
  const tsContent = generateWebArticlesData(articles);
  await fs.writeFile(outputPath, tsContent, 'utf-8');
  
  if (options.verbose) {
    console.log(`   Generated ${outputPath}`);
    console.log(`   Total: ${articles.length} articles`);
  }
}

function generateWebArticlesData(articles) {
  const jaArticles = articles.filter(a => a.lang === 'ja');
  const enArticles = articles.filter(a => a.lang === 'en');
  
  const escapeContent = (content) => {
    return content
      .replace(/\\/g, '\\\\')
      .replace(/`/g, '\\`')
      .replace(/\$/g, '\\$');
  };
  
  const articleToTS = (article) => {
    return `    {
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
    }`;
  };
  
  return `// This file is auto-generated by sync-articles.mjs
// Generated at: ${new Date().toISOString()}
// DO NOT EDIT MANUALLY

import type { Article } from './schemas/article.schema';

export interface ArticleWithContent extends Article {
  content: string;
  htmlContent: string;
}

export const articlesData: Record<'ja' | 'en', ArticleWithContent[]> = {
  ja: [
${jaArticles.map(articleToTS).join(',\n')}
  ],
  en: [
${enArticles.map(articleToTS).join(',\n')}
  ]
};

export type ArticleData = typeof articlesData;
`;
}

// MARK: - iOS版への同期

async function syncToIOS(articles, outputDir) {
  // 出力ディレクトリが存在しない場合は作成
  try {
    await fs.access(outputDir);
  } catch {
    await fs.mkdir(outputDir, { recursive: true });
  }
  
  // 既存のMarkdownファイルを削除
  const existingFiles = await fs.readdir(outputDir);
  for (const file of existingFiles) {
    if (file.endsWith('.md')) {
      await fs.unlink(path.join(outputDir, file));
      if (options.verbose) {
        console.log(`   Removed old file: ${file}`);
      }
    }
  }
  
  // 各記事をMarkdownファイルとして保存
  for (const article of articles) {
    const filename = `${article.slug}_${article.lang}.md`;
    const filePath = path.join(outputDir, filename);
    const content = generateIOSMarkdown(article);
    await fs.writeFile(filePath, content, 'utf-8');
    
    if (options.verbose) {
      console.log(`   Created: ${filename}`);
    }
  }
}

function generateIOSMarkdown(article) {
  // YAML front-matter + Markdown content
  const frontmatter = {
    title: article.title,
    subtitle: article.subtitle,
    lang: article.lang,
    slug: article.slug,
    order: article.order,
    status: article.status,
    readingTime: article.readingTime,
    updated: article.updated,
    keywords: article.keywords,
    related: article.related,
    sources: article.sources
  };
  
  return `---
title: "${frontmatter.title}"
subtitle: "${frontmatter.subtitle}"
lang: "${frontmatter.lang}"
slug: "${frontmatter.slug}"
order: ${frontmatter.order}
status: "${frontmatter.status}"
readingTime: "${frontmatter.readingTime}"
updated: "${frontmatter.updated}"
keywords: ${JSON.stringify(frontmatter.keywords)}
related: ${JSON.stringify(frontmatter.related)}
sources: ${JSON.stringify(frontmatter.sources)}
---

${article.content}
`;
}

// MARK: - バックアップとリストア

async function createBackup(target) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const backupPath = `${target}.backup-${timestamp}`;
  
  try {
    const stats = await fs.stat(target);
    
    if (stats.isDirectory()) {
      // ディレクトリの場合
      await fs.cp(target, backupPath, { recursive: true });
    } else {
      // ファイルの場合
      await fs.copyFile(target, backupPath);
    }
    
    if (options.verbose) {
      console.log(`   Created backup: ${backupPath}`);
    }
    
    return backupPath;
  } catch (error) {
    // ファイルが存在しない場合はバックアップ不要
    return null;
  }
}

async function restoreBackup(backupPath, target) {
  try {
    const stats = await fs.stat(backupPath);
    
    if (stats.isDirectory()) {
      // 既存を削除してからリストア
      try {
        await fs.rm(target, { recursive: true, force: true });
      } catch {}
      await fs.cp(backupPath, target, { recursive: true });
    } else {
      await fs.copyFile(backupPath, target);
    }
    
    if (options.verbose) {
      console.log(`   Restored from backup: ${backupPath}`);
    }
  } catch (error) {
    console.error(`   ⚠️  Could not restore backup: ${error.message}`);
  }
}

// MARK: - 検証

async function validateWebSync(webOutput) {
  try {
    // articlesData.tsの構文チェック
    const content = await fs.readFile(webOutput, 'utf-8');
    
    // TypeScriptとして有効かチェック（簡易）
    if (!content.includes('export const articlesData')) {
      return false;
    }
    
    // 記事数のチェック
    const jaCount = (content.match(/lang: "ja"/g) || []).length;
    const enCount = (content.match(/lang: "en"/g) || []).length;
    
    console.log(`   📊 Web sync validation: ${jaCount} ja, ${enCount} en articles`);
    
    return jaCount > 0 && enCount > 0;
  } catch (error) {
    console.error(`   ❌ Web validation failed: ${error.message}`);
    return false;
  }
}

async function validateIOSSync(iosOutput, articles) {
  try {
    // iOS版のMarkdownファイルをチェック
    const files = await fs.readdir(iosOutput);
    const mdFiles = files.filter(f => f.endsWith('.md'));
    
    // 期待されるファイル数と一致するか
    const expectedCount = articles.length;
    
    console.log(`   📊 iOS sync validation: ${mdFiles.length}/${expectedCount} .md files`);
    
    return mdFiles.length === expectedCount;
  } catch (error) {
    console.error(`   ❌ iOS validation failed: ${error.message}`);
    return false;
  }
}

// MARK: - 実行

main();
