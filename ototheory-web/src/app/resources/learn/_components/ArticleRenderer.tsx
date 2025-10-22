'use client';

import { ArticleWithContent } from '@/lib/articles';
import FACTCard from './FACTCard';

interface ArticleRendererProps {
  article: ArticleWithContent;
}

export default function ArticleRenderer({ article }: ArticleRendererProps) {
  // Simple markdown to HTML conversion with custom blocks
  const convertMarkdownToHtml = (markdown: string) => {
    let html = markdown;
    
    // Process FACT cards
    const factCardRegex = /:::fact source="([^"]+)"\n([\s\S]*?)\n:::/g;
    html = html.replace(factCardRegex, (match, source, content) => {
      return `<div class="fact-card" data-source="${source}" data-content="${content.trim()}"></div>`;
    });
    
    // Headers
    html = html.replace(/^### (.*)$/gm, '<h3 class="text-lg font-semibold mt-6 mb-3">$1</h3>');
    html = html.replace(/^## (.*)$/gm, '<h2 class="text-2xl font-bold mt-8 mb-4 border-b pb-2">$1</h2>');
    html = html.replace(/^# (.*)$/gm, '<h1 class="text-3xl font-bold mb-6">$1</h1>');
    
    // Bold, italic, inline code
    html = html.replace(/\*\*(.*?)\*\*/g, '<strong class="font-semibold">$1</strong>');
    html = html.replace(/\*(.*?)\*/g, '<em>$1</em>');
    html = html.replace(/`(.*?)`/g, '<code class="px-1.5 py-0.5 bg-gray-100 dark:bg-gray-800 rounded text-sm font-mono">$1</code>');
    
    // Links
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

  const htmlContent = convertMarkdownToHtml(article.content);

  // Extract FACT cards from HTML
  const factCards: Array<{ source: string; content: string }> = [];
  const factCardRegex = /<div class="fact-card" data-source="([^"]+)" data-content="([^"]+)"><\/div>/g;
  let match;
  while ((match = factCardRegex.exec(htmlContent)) !== null) {
    factCards.push({
      source: match[1],
      content: match[2],
    });
  }

  // Replace FACT card placeholders with actual components
  let processedHtml = htmlContent;
  factCards.forEach((card, index) => {
    const placeholder = `<div class="fact-card" data-source="${card.source}" data-content="${card.content}"></div>`;
    const componentId = `fact-card-${index}`;
    processedHtml = processedHtml.replace(placeholder, `<div id="${componentId}"></div>`);
  });

  return (
    <div className="prose prose-sm sm:prose-base max-w-none dark:prose-invert prose-headings:scroll-mt-20 prose-a:no-underline hover:prose-a:underline">
      <div dangerouslySetInnerHTML={{ __html: processedHtml }} />
      
      {/* Render FACT cards */}
      {factCards.map((card, index) => (
        <FACTCard key={index} source={card.source}>
          {card.content}
        </FACTCard>
      ))}
    </div>
  );
}
