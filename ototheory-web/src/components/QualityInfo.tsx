"use client";
import { useState } from "react";

type QualityInfoProps = {
  title: string;
  body: string;
  isOpen: boolean;
  onClose: () => void;
};

export default function QualityInfo({ title, body, isOpen, onClose }: QualityInfoProps) {
  if (!isOpen) return null;

  // Parse sections from the body text
  const parseSections = (text: string) => {
    const lines = text.split('\n');
    const sections: { title: string; content: string }[] = [];
    let currentTitle = '';
    let currentContent = '';

    for (const line of lines) {
      const trimmed = line.trim();
      
      // Check if this line is a section header (contains colon)
      if (trimmed.includes(':') && (
        trimmed.startsWith('Vibe:') ||
        trimmed.startsWith('Usage:') ||
        trimmed.startsWith('Try:') ||
        trimmed.startsWith('Theory:')
      )) {
        // Save previous section
        if (currentTitle && currentContent) {
          sections.push({ title: currentTitle, content: currentContent.trim() });
        }
        
        // Start new section
        const colonIndex = trimmed.indexOf(':');
        currentTitle = trimmed.substring(0, colonIndex);
        currentContent = trimmed.substring(colonIndex + 1).trim();
      } else if (trimmed) {
        // Add content to current section
        if (currentContent) {
          currentContent += '\n' + line;
        } else {
          currentContent = line;
        }
      }
    }

    // Add final section
    if (currentTitle && currentContent) {
      sections.push({ title: currentTitle, content: currentContent.trim() });
    }

    return sections;
  };

  const sections = parseSections(body);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-md w-full mx-4 max-h-[80vh] overflow-hidden">
        <div className="flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-700">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white">{title}</h3>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        
        <div className="p-4 overflow-y-auto max-h-[60vh]">
          {sections.length > 0 ? (
            <div className="space-y-4">
              {sections.map((section, index) => (
                <div key={index} className="space-y-2">
                  <div className="flex items-center gap-2">
                    <span className="text-orange-500 font-bold text-lg">•</span>
                    <h4 className="font-bold text-orange-500 text-lg">{section.title}</h4>
                  </div>
                  <p className="text-gray-700 dark:text-gray-300 leading-relaxed pl-6">
                    {section.content}
                  </p>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-700 dark:text-gray-300">{body}</p>
          )}
        </div>
      </div>
    </div>
  );
}
