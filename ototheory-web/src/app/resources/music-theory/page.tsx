import fs from 'fs';
import path from 'path';
import ResourceContent from '../ResourceContent.client';

export default async function MusicTheoryPage() {
  const docsPath = path.join(process.cwd(), '..', 'docs', 'content');
  
  let enContent = '';
  let jaContent = '';
  
  try {
    enContent = fs.readFileSync(path.join(docsPath, 'resources_music_theory_en.md'), 'utf-8');
    jaContent = fs.readFileSync(path.join(docsPath, 'resources_music_theory_ja.md'), 'utf-8');
  } catch (error) {
    console.error('Error reading music theory files:', error);
    enContent = '# Music Theory\n\nContent is being loaded...';
    jaContent = '# 理論解説\n\nコンテンツを読み込んでいます...';
  }

  return <ResourceContent enContent={enContent} jaContent={jaContent} backLink="/resources" />;
}



