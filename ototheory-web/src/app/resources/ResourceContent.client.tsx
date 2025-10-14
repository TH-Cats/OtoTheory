'use client';

import { useState } from 'react';
import Link from 'next/link';

interface ResourceContentProps {
  enContent: string;
  jaContent: string;
  backLink?: string;
}

export default function ResourceContent({ enContent, jaContent, backLink = '/resources' }: ResourceContentProps) {
  const [lang, setLang] = useState<'en' | 'ja'>('en');

  // Simple markdown to HTML conversion
  const convertMarkdownToHtml = (markdown: string) => {
    let html = markdown;
    
    // Remove YAML frontmatter
    html = html.replace(/^---[\s\S]*?---\n/m, '');
    
    // Extract and process headers with anchors
    const headerWithAnchor = /^(#{1,3})\s+(.+?)\s*\{#([\w-]+)\}/gm;
    html = html.replace(headerWithAnchor, (match, hashes, title, id) => {
      const level = hashes.length;
      const classes = level === 1 ? 'text-3xl font-bold mb-6 mt-8' :
                     level === 2 ? 'text-2xl font-bold mt-8 mb-4 border-b pb-2' :
                     'text-lg font-semibold mt-6 mb-3';
      return `<h${level} class="${classes}" id="${id}">${title}</h${level}>`;
    });
    
    // Headers without anchors
    html = html.replace(/^### (.*)$/gm, '<h3 class="text-lg font-semibold mt-6 mb-3">$1</h3>');
    html = html.replace(/^## (.*)$/gm, '<h2 class="text-2xl font-bold mt-8 mb-4 border-b pb-2">$1</h2>');
    html = html.replace(/^# (.*)$/gm, '<h1 class="text-3xl font-bold mb-6">$1</h1>');
    
    // Blockquotes with bold
    html = html.replace(/^> \*\*(.*?)\*\*：(.*)$/gm, '<blockquote class="border-l-4 border-blue-500 pl-4 py-2 my-4 bg-blue-50 dark:bg-blue-900/20"><strong>$1</strong>：$2</blockquote>');
    html = html.replace(/^> \*\*(.*?)\*\*:(.*)$/gm, '<blockquote class="border-l-4 border-blue-500 pl-4 py-2 my-4 bg-blue-50 dark:bg-blue-900/20"><strong>$1</strong>:$2</blockquote>');
    html = html.replace(/^> (.*?)$/gm, '<blockquote class="border-l-4 border-gray-300 pl-4 py-2 my-4 text-gray-700 dark:text-gray-300">$1</blockquote>');
    
    // Bold, italic, inline code
    html = html.replace(/\*\*(.*?)\*\*/g, '<strong class="font-semibold">$1</strong>');
    html = html.replace(/\*(.*?)\*/g, '<em>$1</em>');
    html = html.replace(/`(.*?)`/g, '<code class="px-1.5 py-0.5 bg-gray-100 dark:bg-gray-800 rounded text-sm font-mono">$1</code>');
    
    // Links
    html = html.replace(/\[([^\]]+)\]\(#([^\)]+)\)/g, '<a href="#$2" class="text-blue-600 dark:text-blue-400 hover:underline">$1</a>');
    html = html.replace(/\[([^\]]+)\]\(([^\)]+)\)/g, '<a href="$2" class="text-blue-600 dark:text-blue-400 hover:underline">$1</a>');
    
    // Process line by line for lists and tables
    const lines = html.split('\n');
    const processed: string[] = [];
    let inList = false;
    let inTable = false;
    
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      
      // Table detection
      if (line.trim().startsWith('|') && line.trim().endsWith('|')) {
        if (!inTable) {
          inTable = true;
          const cells = line.split('|').filter(s => s.trim());
          processed.push('<table class="w-full border-collapse my-4 text-sm"><thead><tr>' + 
            cells.map(cell => `<th class="border border-gray-300 dark:border-gray-600 px-3 py-2 bg-gray-100 dark:bg-gray-800 text-left">${cell.trim()}</th>`).join('') + 
            '</tr></thead><tbody>');
          i++; // Skip separator line
        } else {
          const cells = line.split('|').filter(s => s.trim());
          processed.push('<tr>' + 
            cells.map(cell => `<td class="border border-gray-300 dark:border-gray-600 px-3 py-2">${cell.trim()}</td>`).join('') + 
            '</tr>');
        }
        
        // Check if next line is not a table row
        if (!lines[i + 1] || !lines[i + 1].trim().startsWith('|')) {
          processed.push('</tbody></table>');
          inTable = false;
        }
        continue;
      }
      
      // List items
      if (line.match(/^- /)) {
        if (!inList) {
          processed.push('<ul class="list-disc pl-6 space-y-1 mb-4">');
          inList = true;
        }
        processed.push(`<li>${line.substring(2)}</li>`);
      } else {
        if (inList) {
          processed.push('</ul>');
          inList = false;
        }
        
        // Horizontal rule
        if (line.trim() === '---') {
          processed.push('<hr class="my-8 border-gray-300 dark:border-gray-600" />');
        }
        // Empty lines and special tags
        else if (line.trim() === '' || line.startsWith('<')) {
          processed.push(line);
        }
        // Regular paragraphs
        else if (line.trim() && !line.startsWith('#') && !line.startsWith('>')) {
          processed.push(`<p class="mb-4 leading-relaxed">${line}</p>`);
        } else {
          processed.push(line);
        }
      }
    }
    
    if (inList) {
      processed.push('</ul>');
    }
    
    return processed.join('\n');
  };

  const content = lang === 'en' ? enContent : jaContent;
  const htmlContent = convertMarkdownToHtml(content);

  return (
    <div className="ot-page">
      <div className="mb-6 flex items-center justify-between flex-wrap gap-4">
        <Link href={backLink} className="text-sm text-blue-600 dark:text-blue-400 hover:underline">
          ← Back to Resources
        </Link>
        <div className="flex gap-2">
          <button
            className={`px-3 py-1.5 text-sm rounded border transition-colors ${
              lang === 'ja' 
                ? 'bg-blue-600 text-white border-blue-600' 
                : 'hover:bg-gray-100 dark:hover:bg-gray-800'
            }`}
            onClick={() => setLang('ja')}
          >
            日本語
          </button>
          <button
            className={`px-3 py-1.5 text-sm rounded border transition-colors ${
              lang === 'en' 
                ? 'bg-blue-600 text-white border-blue-600' 
                : 'hover:bg-gray-100 dark:hover:bg-gray-800'
            }`}
            onClick={() => setLang('en')}
          >
            English
          </button>
        </div>
      </div>

      <div 
        className="prose prose-sm sm:prose-base max-w-none dark:prose-invert prose-headings:scroll-mt-20 prose-a:no-underline hover:prose-a:underline"
        dangerouslySetInnerHTML={{ __html: htmlContent }} 
      />
    </div>
  );
}



