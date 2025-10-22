/**
 * @fileoverview Article Schema - Front-Matter validation
 * 
 * SSOT参照:
 * - メイン仕様: /docs/SSOT/v3.2_SSOT.md
 * - 実装仕様: /docs/SSOT/v3.2_Implementation_SSOT.md
 * - リソース仕様: /docs/SSOT/RESOURCES_SSOT_v1.md
 * 
 * 変更時は必ずSSOTとの整合性を確認すること
 */

import { z } from 'zod';

export const SourceSchema = z.object({
  type: z.enum(['book', 'interview', 'article', 'website', 'video']),
  title: z.string(),
  author: z.string().optional(),
  year: z.number().optional(),
  url: z.string().url().optional(),
  date: z.string().optional(),
  citation: z.string().optional(),
});

export const ArticleSchema = z.object({
  title: z.string(),
  subtitle: z.string(),
  lang: z.enum(['ja', 'en']),
  slug: z.string(),
  order: z.number().int().min(1).max(8),
  status: z.enum(['draft', 'published', 'scheduled']),
  readingTime: z.string(),
  updated: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  keywords: z.array(z.string()),
  related: z.array(z.string()),
  sources: z.array(SourceSchema),
});

export type Article = z.infer<typeof ArticleSchema>;
export type Source = z.infer<typeof SourceSchema>;

export const validateArticle = (frontMatter: unknown): Article => {
  return ArticleSchema.parse(frontMatter);
};
