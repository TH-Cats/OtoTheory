"use client";
import React, { useState } from "react";
import { useAnalysisStore } from "@/store/analysisStore";
import { recommendCapos } from "@/lib/capo/recommend";

export default function CapoFold({keySig, progression}:{keySig:any, progression:any}) {
  const [isOpen, setIsOpen] = useState(false);
  const selectedKey = useAnalysisStore(s => (s as any).selectedKey);
  const selectedScale = useAnalysisStore(s => (s as any).selectedScale);

  const items = React.useMemo(() => {
    if (!selectedKey || !selectedScale) return [];
    const modeLabel = (selectedKey.mode === 'Major' || selectedKey.mode === 'Minor') ? selectedKey.mode : ((selectedKey.mode as any) === 'major' ? 'Major' : 'Minor');
    return recommendCapos({ tonic: selectedKey.tonic, mode: modeLabel as any }, { type: selectedScale.type as any }, 2, { includeOpen: false });
  }, [selectedKey, selectedScale]);

  if (!selectedKey || !selectedScale || items.length === 0) {
    return null;
  }

  return (
    <details className="ot-card" data-silent>
      <summary className="ot-adv-toggle cursor-pointer">
        Capo Suggestions (Top 2)
      </summary>
      <div className="mt-2">
        <p className="text-xs opacity-70 mb-3 px-1">
          <strong>Note:</strong> Shaped = fingered position / Sounding = actual pitch
        </p>
        <ul className="ot-stack space-y-2">
          {items.map((it, i) => (
            <li key={i} className="ot-row rounded border p-2 bg-background/40">
              <div className="flex items-center justify-between mb-1">
                <div className="font-medium">
                  Capo {it.capo}
                  <span className="ml-2 text-xs px-2 py-0.5 rounded-full bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-300">
                    Shaped
                  </span>
                </div>
                <div className="text-xs opacity-70">
                  {Math.round(it.score * 100)}% open chords
                </div>
              </div>
              <div className="text-sm opacity-80">
                Play as <strong>{it.playAs}</strong>
              </div>
              {it.reasons && it.reasons.length > 0 && (
                <div className="text-xs opacity-60 mt-1">
                  {it.reasons.join(' · ')}
                </div>
              )}
            </li>
          ))}
        </ul>
      </div>
    </details>
  );
}
