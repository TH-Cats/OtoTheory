import fs from 'fs';
import path from 'path';
import ResourceContent from '../ResourceContent.client';

export default async function GlossaryPage() {
  const docsPath = path.join(process.cwd(), '..', 'docs', 'content');
  
  let enContent = '';
  let jaContent = '';
  
  try {
    enContent = fs.readFileSync(path.join(docsPath, 'resources_glossary_en.md'), 'utf-8');
    jaContent = fs.readFileSync(path.join(docsPath, 'resources_glossary_ja.md'), 'utf-8');
  } catch (error) {
    console.error('Error reading glossary files:', error);
    enContent = '# Glossary\n\nContent is being loaded...';
    jaContent = '# 用語解説\n\nコンテンツを読み込んでいます...';
  }

  return <ResourceContent enContent={enContent} jaContent={jaContent} backLink="/resources" />;
}


