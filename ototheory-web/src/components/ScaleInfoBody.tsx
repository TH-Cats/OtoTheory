"use client";
import { getScaleById, type ScaleId } from "@/lib/scalesMaster";
import { useLocale } from "@/contexts/LocaleContext";

interface ScaleInfoBodyProps {
  scaleId: ScaleId;
}

export default function ScaleInfoBody({ scaleId }: ScaleInfoBodyProps) {
  const scale = getScaleById(scaleId);
  if (!scale) return null;
  
  // 言語判定（LocaleContextベース）
  const { isJapanese } = useLocale();
  const lang = isJapanese ? 'ja' : 'en';
  const c = scale.comments[lang];

  return (
    <div className="space-y-1.5">
      <div>
        <div className="font-semibold text-amber-600 text-sm mb-1">
          {isJapanese ? '構成度数' : 'Degrees'}
        </div>
        <div className="text-zinc-800 dark:text-zinc-200 text-sm">{scale.degrees.join(' - ')}</div>
      </div>
      <div>
        <div className="font-semibold text-amber-600 text-sm mb-1">
          {isJapanese ? '雰囲気' : 'Vibe'}
        </div>
        <div className="text-zinc-800 dark:text-zinc-200 text-sm">{c.vibe}</div>
      </div>
      <div>
        <div className="font-semibold text-amber-600 text-sm mb-1">
          {isJapanese ? '利用シーン' : 'Usage'}
        </div>
        <div className="text-zinc-800 dark:text-zinc-200 text-sm">{c.use}</div>
      </div>
      <div>
        <div className="font-semibold text-amber-600 text-sm mb-1">
          {isJapanese ? '使ってみよう' : 'Try'}
        </div>
        <div className="text-zinc-800 dark:text-zinc-200 text-sm">{c.try}</div>
      </div>
      <div>
        <div className="font-semibold text-amber-600 text-sm mb-1">
          {isJapanese ? '理論' : 'Theory'}
        </div>
        <div className="text-zinc-800 dark:text-zinc-200 text-sm">{c.theory}</div>
      </div>
    </div>
  );
}
