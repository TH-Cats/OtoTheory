"use client";
import React from "react";
import { useAnalysisStore } from "@/store/analysisStore";
import { triadToChordSym } from "@/lib/theory/diatonic";

type Props = {
  withSeventh?: boolean; // reserved, triads for now
};

export default function DiatonicPalette({ withSeventh }: Props) {
  const diatonic = useAnalysisStore((s: any) => s.diatonic);
  const triads = (diatonic?.triads ?? []) as any[];
  const romans = (diatonic?.romans ?? ["I","II","III","IV","V","VI","VII"]) as string[];

  const items = React.useMemo(() => {
    if (!triads?.length) return Array.from({ length: 7 }, () => ({ symbol: "—" }));
    return triads.map((t: any) => ({ symbol: triadToChordSym({ rootPc: t.rootPc, quality: t.quality }) }));
  }, [triads]);

  return (
    <div aria-live="polite" className="grid grid-cols-2 sm:grid-cols-7 gap-2" aria-label="Diatonic palette">
      {items.map((it, idx) => (
        <div key={`dia-${idx}`} className="rounded border p-2 text-center">
          <div className="text-sm leading-tight">{it.symbol}</div>
          <div className="text-xs text-black/60 dark:text-white/60 leading-tight">{romans[idx] ?? ''}</div>
        </div>
      ))}
    </div>
  );
}













