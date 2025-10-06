"use client";
import React, { useRef, useCallback } from "react";
import { useAnalysisStore } from "@/store/analysisStore";
import { diatonicTriads, triadToChordSym } from "@/lib/theory/diatonic";
import { romanDegreeLabelsForScale, SCALE_INTERVALS, type ScaleType, parentModeOf } from "@/lib/scales";
import { recommendCapos } from "@/lib/capo/recommend";
import { PITCHES } from "@/lib/theory/capo";

export type OnPickArgs = { id: string; row: 'open' | `capo${number}`; degree: number; pcs: number[]; capo: number; isRightClick?: boolean };
export default function DiatonicCapoTable({ onPick, selectedId, onSelectId }: { onPick?: (p: OnPickArgs) => void; selectedId?: string | null; onSelectId?: (id: string) => void }) {
  const selectedKey = useAnalysisStore(s => (s as any).selectedKey);
  const selectedScale = useAnalysisStore(s => (s as any).selectedScale);
  const degreeLabels = romanDegreeLabelsForScale(selectedScale?.type ?? 'Ionian');
  const toFancy = (s: string) => s.replaceAll('b','♭').replaceAll('#','♯');
  const cellBase = "px-2 py-1 text-center border rounded-[var(--chip-br)]";
  const cellNeutral = "border-neutral-300 dark:border-neutral-700";
  const cellOpen = "bg-emerald-50 border-emerald-200 text-emerald-900 dark:bg-emerald-800/25 dark:border-emerald-700 dark:text-emerald-100";

  // Mobile long-press support
  const longPressTimerRef = useRef<NodeJS.Timeout | null>(null);
  const longPressTriggeredRef = useRef(false);

  const handleTouchStart = useCallback((i: number, sym: string, pcs: number[]) => {
    longPressTriggeredRef.current = false;
    longPressTimerRef.current = setTimeout(() => {
      longPressTriggeredRef.current = true;
      const confirmed = window.confirm(`Add "${sym}" to progression?`);
      if (confirmed) {
        const id = `open-${i}`;
        onSelectId?.(id);
        onPick?.({ id, row: 'open', degree: i, pcs, capo: 0, isRightClick: true });
      }
    }, 500); // 500ms long press
  }, [onPick, onSelectId]);

  const handleTouchEnd = useCallback(() => {
    if (longPressTimerRef.current) {
      clearTimeout(longPressTimerRef.current);
      longPressTimerRef.current = null;
    }
  }, []);

  const openCells = React.useMemo(() => {
    if (!selectedKey || !selectedScale) return Array(7).fill({ sym:'—', pcs:[] as number[] });
    let st = selectedScale.type as ScaleType;
    let ivs = SCALE_INTERVALS[st] ?? [];
    if (ivs.length !== 7) {
      const parent = parentModeOf(st);
      if (parent) ivs = SCALE_INTERVALS[parent] ?? [];
    }
    if (ivs.length !== 7) return Array(7).fill({ sym:'—', pcs:[] as number[] });
    const tris = diatonicTriads({ tonicPc: selectedKey.tonic, scaleIntervals: ivs });
    return tris.map(t => ({ sym: triadToChordSym({ rootPc: t.rootPc, quality: t.quality }), pcs: t.pcs }));
  }, [selectedKey, selectedScale]);

  const capoRows = React.useMemo(() => {
    if (!selectedKey || !selectedScale) return [] as Array<{ capo:number; label:string; cells:string[]; cellsPcs:number[][]; tooltip?:string }>;
    const modeLabel = (selectedKey.mode === 'Major' || selectedKey.mode === 'Minor') ? selectedKey.mode : ((selectedKey.mode as any) === 'major' ? 'Major' : 'Minor');
    const picks = recommendCapos({ tonic: selectedKey.tonic, mode: modeLabel as any }, { type: selectedScale.type as any }, 3, { includeOpen: true });
    const nonZero = picks.filter(p => p.capo !== 0).sort((a,b)=> a.capo - b.capo).slice(0,2);
    return nonZero.map(p => {
      const playAs = p.playAs; // e.g., G or Am
      const isMinor = /m$/.test(playAs);
      const name = isMinor ? playAs.replace(/m$/,'') : playAs;
      const pc = PITCHES.indexOf(name as any);
      let st = selectedScale.type as ScaleType;
      let ivs = SCALE_INTERVALS[st] ?? [];
      if (ivs.length !== 7) {
        const parent = parentModeOf(st);
        if (parent) ivs = SCALE_INTERVALS[parent] ?? [];
      }
      const tris = ivs.length===7 ? diatonicTriads({ tonicPc: pc, scaleIntervals: ivs }) : [];
      const cells = (tris.length? tris : Array(7).fill(null)).map((t:any)=> t ? triadToChordSym({ rootPc: t.rootPc, quality: t.quality }) : '—');
      const cellsPcs = (tris.length? tris : Array(7).fill(null)).map((t:any)=> t ? (t.pcs as number[]) : []);
      return { capo: p.capo, label: `Capo ${p.capo}`, cells, cellsPcs, tooltip: `Play as ${playAs}${(p.reasons&&p.reasons.length? ' · ' + p.reasons.join(' · ') : '')}` };
    });
  }, [selectedKey, selectedScale]);

  const header = degreeLabels.map(toFancy);

  return (
    <div className="overflow-x-auto capo-compact capo-compact--tight" aria-live="polite" aria-labelledby="diatonic-title">
      <table className="w-full border-separate rounded-xl border text-sm md:text-[0.95rem]" style={{ borderSpacing: '6px' }}>
        <colgroup>
          <col className="w-12 sm:w-14 md:w-18" />
          <col span={7} />
        </colgroup>
        <thead>
          <tr>
            <th scope="col" className="px-1 py-0 text-center text-sm font-medium border-none bg-transparent rounded-none"></th>
            {header.map((d,i)=> (
              <th key={`hdr-${i}`} scope="col" className="px-1 py-0 text-center text-sm font-medium border-none bg-transparent rounded-none">{d}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          <tr data-row="open">
            <th scope="row" className="px-1 py-0 text-center text-xs font-normal border-none bg-transparent rounded-none text-foreground/70" title="Open (no capo)">Open</th>
            {openCells.map((c, i)=> (
              // cell id unique: open-<degreeIndex>
              <td
                key={`open-${i}`}
                className={[cellBase, cellOpen, onPick ? 'cursor-pointer select-none tapfx' : '', (selectedId === `open-${i}` ? 'ring-2 ring-emerald-400/60 dia-cell--active' : 'dia-cell--idle')].join(' ')}
                onClick={(e) => {
                  if ((e as unknown as MouseEvent).button === 2) return; // 右クリックは無視
                  if (longPressTriggeredRef.current) { longPressTriggeredRef.current = false; return; } // 長押し後のクリックを無視
                  const id = `open-${i}`; onSelectId?.(id); onPick?.({ id, row: 'open', degree: i, pcs: c.pcs, capo: 0 });
                }}
                onContextMenu={(e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  const confirmed = window.confirm(`Add "${c.sym}" to progression?`);
                  if (confirmed) {
                    const id = `open-${i}`;
                    onSelectId?.(id);
                    onPick?.({ id, row: 'open', degree: i, pcs: c.pcs, capo: 0, isRightClick: true });
                  }
                }}
                onTouchStart={() => handleTouchStart(i, c.sym, c.pcs)}
                onTouchEnd={handleTouchEnd}
                onTouchCancel={handleTouchEnd}
                role={onPick ? 'button' : undefined}
                aria-label={onPick ? `Open ${c.sym}` : undefined}
                aria-pressed={selectedId === `open-${i}`}
              >{c.sym}</td>
            ))}
          </tr>
          {capoRows.map((r)=> (
            <tr key={`capo-${r.capo}`}>
              <th scope="row" className="px-1 py-0 text-center text-xs font-normal border-none bg-transparent rounded-none text-foreground/70" title={r.tooltip}>{r.label}</th>
              {r.cells.map((c, i)=> (
                <td
                  key={`capo-${r.capo}-${i}`}
                  className={[cellBase, cellNeutral, 'opacity-65 cursor-default pointer-events-none', (selectedId === `capo${r.capo}-${i}` ? 'dia-cell--active' : 'dia-cell--idle')].join(' ')}
                  role="button"
                  tabIndex={-1}
                  aria-disabled="true"
                  aria-label={`${r.label} ${c}`}
                >{c}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}


