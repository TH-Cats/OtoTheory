"use client";
import React from "react";
import { useAnalysisStore } from "@/store/analysisStore";
import { recommendCapos, type CapoPick } from "@/lib/capo/recommend";

type Props = {
  shapedKey?: { tonic: number; mode: 'major'|'minor'|'Major'|'Minor' };
  chords?: string[];
  includeOpen?: boolean;
  max?: number;
  onPick?: (capo: number) => void;
};

export default function CapoStrip({ shapedKey, includeOpen = true, max = 3, onPick }: Props) {
  const selectedKey = useAnalysisStore((s: any) => s.selectedKey);
  const selectedScale = useAnalysisStore((s: any) => s.selectedScale);

  const keyForCalc = shapedKey ?? selectedKey;

  const picks: CapoPick[] = React.useMemo(() => {
    if (!keyForCalc || !selectedScale) return [];
    const mode = (keyForCalc.mode === 'Major' || keyForCalc.mode === 'Minor')
      ? (keyForCalc.mode as 'Major'|'Minor')
      : ((keyForCalc.mode as any) === 'major' ? 'Major' : 'Minor');
    return recommendCapos({ tonic: keyForCalc.tonic, mode }, { type: selectedScale.type }, max, { includeOpen });
  }, [keyForCalc, selectedScale, includeOpen, max]);

  const btnRefs = React.useRef<Array<HTMLButtonElement|null>>([]);
  const onKey = (idx: number, e: React.KeyboardEvent) => {
    if (e.key === 'ArrowRight') {
      e.preventDefault();
      const next = btnRefs.current[(idx + 1) % btnRefs.current.length];
      next?.focus();
    } else if (e.key === 'ArrowLeft') {
      e.preventDefault();
      const prev = btnRefs.current[(idx - 1 + btnRefs.current.length) % btnRefs.current.length];
      prev?.focus();
    }
  };

  if (!picks.length) return null;

  return (
    <div role="list" aria-live="polite" className="flex flex-wrap items-center gap-2">
      {picks.map((p, i) => {
        const label = p.capo === 0
          ? `Open (no capo) · Play as ${p.playAs}`
          : `Capo ${p.capo} · ${p.playAs}`;
        return (
          <span key={`capo-${p.capo}`} role="listitem">
            <button
              ref={(el)=> (btnRefs.current[i] = el)}
              className="rounded-xl border px-3 py-2 text-sm hover:bg-black/5 dark:hover:bg-white/10"
              aria-label={`Capo ${p.capo === 0 ? 'Open (no capo)' : p.capo}, play as ${p.playAs}`}
              title={(p.reasons||[]).join(' · ')}
              onKeyDown={(e)=>onKey(i,e)}
              onClick={()=> onPick?.(p.capo)}
            >
              {label}
            </button>
          </span>
        );
      })}
    </div>
  );
}


