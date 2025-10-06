"use client";
import React, { useRef } from "react";
import { suggestScalesForChord } from "@/lib/scaleSuggestions";
import { SCALE_CATALOG } from "@/lib/scaleCatalog";
import { track as tel } from "@/lib/telemetry";
import { player } from "@/lib/audio/player";
import { useRovingTabs } from "@/hooks/useRovingTabs";

export function ScaleTable({
  chordQuality, rootPc, onPreviewScale, onResetPreview, openGlossary, activeScaleId
}: {
  chordQuality: 'maj'|'min'|'dom7'|'m7b5'|'dim';
  rootPc: number; // 0=C,...11=B
  onPreviewScale: (scaleId: string)=>void; // 下地だけ切替（プレビュー）
  onResetPreview: ()=>void;                // Reset（プレビュー解除）
  openGlossary: (scaleId: string)=>void; // /reference#scales
  activeScaleId?: string | null;          // 現在プレビュー中のスケール
}) {
  const { scales } = suggestScalesForChord(chordQuality);
  const listRef = useRef<HTMLDivElement | null>(null);
  useRovingTabs(listRef, { orientation: "horizontal" });
  return (
    <div className="ot-scale-table" data-testid="scale-chips" aria-label="Suggested scales">
      {/* Active scale chip is visually highlighted; no extra label needed */}
      <details className="rounded border p-2 bg-background/40">
        <summary className="text-sm cursor-pointer select-none">Suggested scales for this chord</summary>
        <div className="mt-2 flex items-center justify-between gap-2">
          <div role="tablist" aria-label="Preview scale" className="flex flex-wrap gap-2" ref={listRef}>
          {scales.map((id, idx) => (
            <div key={id} className="inline-flex items-center gap-1">
              <button
                role="tab" className={["chip", (activeScaleId===id? "chip--active" : "")].join(" ")}
                onClick={() => { onPreviewScale(id); tel('overlay_shown', { control:'scale', scaleId:id }); void playArpShort(rootPc, id); }}
                aria-describedby={`why-${id}`}
                data-roving="item"
              >
                {labelFor(id, chordQuality, idx)}
              </button>
              <button
                type="button"
                className="inline-flex items-center justify-center w-5 h-5 rounded-full text-xs opacity-60 hover:opacity-100 hover:bg-black/5 dark:hover:bg-white/10 transition-opacity"
                onClick={()=> openGlossary(id)}
                aria-label={`Learn more about ${id}`}
                title="Learn more in Glossary"
              >
                ⓘ
              </button>
            </div>
          ))}
          </div>
          <button className="btn-ghost text-xs ml-auto" onClick={onResetPreview}>Reset</button>
        </div>
        <div className="mt-2 flex flex-wrap gap-x-4 gap-y-1 items-center text-xs opacity-80">
          {scales.map((id)=> (
            <span key={`why-${id}`} id={`why-${id}`}>{getWhyText(id)}</span>
          ))}
        </div>
      </details>
    </div>
  );
}

// 短いアルペジオ（上昇→下降パターン）
async function playArpShort(rootPc:number, scaleId:string){
  try {
    // @ts-ignore SSOT API exposed in window
    const api = (window as any).__SCALES_API__;
    if (!api?.getScalePitchesById) return;
    const pcs: number[] = api.getScalePitchesById(rootPc, scaleId);
    const steps = pcs.slice(0, Math.min(5, pcs.length)); // 最大5音
    const ascending = steps.slice();
    const descending = steps.slice().reverse().slice(1); // ルート音は重複させない
    const pattern = [...ascending, ...descending];
    const dur = 100; // 各音100ms
    await player.resume();
    for (const pc of pattern) {
      player.playNote(60 + pc, dur);
      await wait(dur);
    }
    tel('scale_arpeggio_play', { page: 'find-chords', scaleId, rootPc });
  } catch {}
}
function wait(ms:number){ return new Promise(r=>setTimeout(r, ms)); }

function getWhyText(scaleId:string){
  const map:Record<string,string> = {
    Ionian:'maj_ionian',
    Lydian:'maj_lydian',
    Aeolian:'min_aeolian',
    Dorian:'min_dorian',
    Phrygian:'min_phrygian',
    Mixolydian:'dom_mixolydian',
    Locrian:'m7b5_locrian',
    DiminishedWholeHalf:'dim_wh',
    Altered:'dom_altered',
    HarmonicMinor:'min_harmonic',
    MelodicMinor:'min_melodic',
    WholeTone:'dom_wholetone'
  };
  const t:Record<string,string> = {
    maj_ionian:"Foundation for major chords – fits all diatonic tones",
    maj_lydian:"Bright color with raised 4th (#11) – jazz/modern sound",
    maj_mixolydian:"Dominant-like major – contains the b7 for blues flavor",
    min_aeolian:"Natural minor foundation – matches all minor scale tones",
    min_dorian:"Brighter minor with natural 6th – popular in jazz and funk",
    min_phrygian:"Dark minor with flat 2nd – Spanish/flamenco character",
    min_harmonic:"Dramatic minor with raised 7th – classical and exotic sound",
    min_melodic:"Jazz minor – ascending melodic scale with natural 6th and 7th",
    dom_mixolydian:"Perfect for dominant 7th – contains the b7 tension",
    dom_altered:"Maximum tension – all alterations (b9, #9, #11, b13)",
    dom_wholetone:"Symmetrical whole-tone pattern – dreamy, unresolved quality",
    m7b5_locrian:"Outlines half-diminished chord – starts on the 7th degree",
    dim_wh:"Symmetrical whole-half pattern – creates tension over diminished chords"
  };
  return t[map[scaleId]] || '';
}

function labelFor(id:string, q:'maj'|'min'|'dom7'|'m7b5'|'dim'|'maj7'|'m7'|'7', idx:number){
  if (q==='maj' || q==='maj7') {
    if (idx===0) return 'Ionian (Major Scale)';
    if (idx===1) return 'Lydian (#4 Color)';
  }
  if (q==='min' || q==='m7') {
    if (idx===0) return 'Aeolian (Natural Minor)';
    if (idx===1) return 'Dorian (Bright Minor)';
    if (idx===2) return 'Phrygian (Dark Minor)';
  }
  if (q==='dom7' || q==='7') {
    if (idx===0) return 'Mixolydian (Dominant)';
    if (idx===1) return 'Altered (Tension)';
  }
  if (q==='m7b5') {
    if (idx===0) return 'Locrian (Half-Dim)';
    if (idx===1) return 'Whole–Half Dim';
  }
  if (q==='dim') {
    if (idx===0) return 'Whole–Half Dim';
    if (idx===1) return 'Locrian';
  }
  return id;
}

export default ScaleTable;


