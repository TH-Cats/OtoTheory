"use client";
import React, { useEffect, useRef, useState } from "react";
import { SCALE_CATALOG } from "@/lib/scaleCatalog";
import { degreeLabelFor, getScalePitches, type ScaleType } from "@/lib/scales";
import { player } from "@/lib/audio/player";
import type { FormShape, Quality } from "@/lib/chordForms";
const PITCHES12 = ['C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B'] as const;

type FretboardProps = {
  strings?: string[]; // high -> low
  frets?: number;
  dotPositions?: number[];
  overlay?: { display: 'degrees'|'names'; viewMode?: 'sounding'; capo: number; notes?: string[]; chordNotes?: string[]; showScaleGhost?: boolean; scaleRootPc?: number; scaleType?: ScaleType; context?: { chordRootPc?: number; quality?: Quality } } | null;
  onRequestForms?: (at:{x:number;y:number}, ctx:{rootPc:number; quality: Quality})=>void;
  formShape?: FormShape | null;
};

// --- Dot visuals (shared for Degrees/Names) ---
const DOT_PX_DESKTOP = 26;
const DOT_PX_MOBILE = 24;
const FONT_PX_DESKTOP = 14;
const FONT_PX_MOBILE = 13;
// Original palette（page base: show degree colours）
const COLOR_ROOT   = "hsl(355 80% 60% / .95)"; // root
const COLOR_DEG3   = "hsl(205 90% 56% / .90)"; // 3rd
const COLOR_DEG5   = "hsl(150 65% 45% / .90)"; // 5th
const COLOR_DEG7   = "hsl(48 95% 55% / .92)";  // 7th
// Preview palette（suggested-scale overlay: chord vs others）
const COLOR_CHORD  = "hsl(0 85% 55% / .95)";   // chord tones (red)
const COLOR_SCALE  = "hsl(210 10% 72% / .70)"; // non-chord scale tones (gray)
const COLOR_OUT    = "hsl(210 6% 38% / .30)";
const COLOR_GHOST  = "hsl(210 12% 58% / .60)"; // unified ghost color (darker)
const LABEL_COLOR = "#0b0b0b";

const dotStyle = (bg: string, isMobile: boolean): React.CSSProperties => {
  const size = isMobile ? DOT_PX_MOBILE : DOT_PX_DESKTOP;
  return {
    width: size,
    height: size,
    borderRadius: size,
    background: bg,
    color: LABEL_COLOR,
    fontWeight: 700,
    fontSize: isMobile ? FONT_PX_MOBILE : FONT_PX_DESKTOP,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    transform: 'translate(-50%, -50%)',
    textShadow: '0 0 1px rgba(0,0,0,.55)',
    WebkitTextStroke: '0.3px rgba(255,255,255,.35)',
    userSelect: 'none',
  };
};

function colorForDegreeLabel(preview: boolean, lbl: string | null, isChordTone: boolean, isInScale: boolean, isRoot: boolean) {
  if (!isInScale) return COLOR_OUT;
  if (preview) {
    return isChordTone ? COLOR_CHORD : COLOR_SCALE;
  }
  if (isRoot) return COLOR_ROOT;
  if (!lbl) return COLOR_SCALE;
  const l = lbl.replace(/\s/g, "");
  if (l.includes("3")) return COLOR_DEG3;
  if (l.includes("5")) return COLOR_DEG5;
  if (l.includes("7")) return COLOR_DEG7;
  return COLOR_SCALE;
}

function ghostFromBaseColor(base: string, alpha = 0.85): string {
  try {
    if (base.includes('/')) {
      return base.replace(/\/(.*?)\)/, `/ ${alpha})`);
    }
    if (base.endsWith(')')) return base.replace(/\)$/, ` / ${alpha})`);
  } catch {}
  return base;
}

export default function Fretboard({
  strings = ['E','B','G','D','A','E'],
  frets = 15,
  dotPositions: _dotPositions = [3,5,7,9,12,15],
  overlay = null,
  onRequestForms,
  formShape = null,
}: FretboardProps) {
  const wrapRef = useRef<HTMLDivElement | null>(null);
  // SSRと初回クライアント描画の一致を保つため、初期値はfalse（デスクトップ想定）
  const [isMobile, setIsMobile] = useState(false);
  const [pressedCell, setPressedCell] = useState<{ r: number; c: number; ver: number } | null>(null);
  useEffect(() => {
    const update = () => {
      try { setIsMobile(window.innerWidth < 380); } catch { /* noop */ }
    };
    update();
    window.addEventListener('resize', update);
    return () => window.removeEventListener('resize', update);
  }, []);
  // ScaleとChordを統合したoverlayオブジェクトを作成
  // 親から `overlay` が渡されている場合はそれを最優先（Find Key などの初期表示用）
  const overlayEff = overlay ?? null;
  // Layout constants
  const LEFT_GUTTER = 44;   // px  // compact gutter (reduced)
  const SPACE_W = 28;       // px  // standard fret min width
  const ROW_H = 28;         // px
  const TOP_BAR_H = 32;     // px
  const OPEN_GAP = 20;      // px additional gap for open column (increased by +8px)
  const ZERO_COL_W = SPACE_W + OPEN_GAP; // widened open column
  const COLS = (f: number) => `${ZERO_COL_W}px repeat(${f}, minmax(${SPACE_W}px, 1fr))`;
  const NUT_WIDTH = 3;      // px

  // --- Chord label long-press (for mouse/touch on the label only) ---
  const PRESS_MS = 400;
  const pressTimer = useRef<number | null>(null);
  const endPress = () => { if (pressTimer.current!==null){ clearTimeout(pressTimer.current); pressTimer.current=null; } };
  const startPress = (e: React.PointerEvent, ctx:{rootPc:number; quality:Quality}) => {
    if (!onRequestForms) return;
    // マウスの長押しは不要だが、統一して実装
    endPress();
    pressTimer.current = window.setTimeout(()=>{
      onRequestForms({ x:e.clientX, y:e.clientY }, ctx);
    }, PRESS_MS);
  };

  useEffect(() => {}, [frets, strings.length]);
  return (
    <div className="rounded-lg border p-3 overflow-x-auto ot-fretboard ot-fb-compact">
      <div className="min-w-[640px]">
        <div ref={wrapRef} className="relative" style={{ height: TOP_BAR_H + strings.length * ROW_H + 16 }}>
          {/* nut line is rendered inside grid below */}
          {/* Fret numbers top bar */}
          <div
            className="pointer-events-none absolute top-1 grid text-[12px] md:text-sm text-foreground/80"
            style={{
              gridTemplateColumns: COLS(frets),
              height: TOP_BAR_H,
              left: LEFT_GUTTER,
              right: 0,
            }}
          >
            {Array.from({ length: frets+1 }).map((_, col) => {
              const show = [0,1,3,5,7,9,12,15].includes(col);
              if (!show) return <div key={col} />;
              return (
                <div key={col} className="flex items-start justify-center">
                  <span className="inline-block px-1 rounded bg-background/80">{col}</span>
                </div>
              );
            })}
          </div>
          {/* chord forms UI removed per spec */}
          {/* Left tuning labels (E B G D A E) */}
          <div
            className="absolute select-none"
            style={{
              left: 0,
              top: TOP_BAR_H,
              width: LEFT_GUTTER,
              height: strings.length * ROW_H,
              display: 'grid',
              gridTemplateRows: `repeat(${strings.length}, ${ROW_H}px)`,
            }}
            aria-hidden="true"
          >
            {strings.map((s, i) => (
              <div key={`lbl-${i}`} className="flex items-center justify-center text-xs md:text-sm leading-none text-muted-foreground">
                {s}
              </div>
            ))}
          </div>
            <div className="absolute right-0 bottom-0 grid" style={{ top: TOP_BAR_H, left: LEFT_GUTTER, width: `calc(100% - ${LEFT_GUTTER}px)`, gridTemplateColumns: COLS(frets), gridTemplateRows: `repeat(${strings.length}, ${ROW_H}px)` }}>
            {strings.map((s, rowIdx) => (
              <React.Fragment key={`row-${rowIdx}`}>
                {/* Open space cell */}
                <div className="relative" key={`open-${rowIdx}`}>{renderOpenMarker({ overlay: overlayEff, strings, rowIdx, isMobile })}</div>
                {Array.from({ length: frets }).map((_, colIdx) => (
                  <div
                    key={`c-${rowIdx}-${colIdx}`}
                    className={`relative ${colIdx===0 ? 'border-l border-transparent' : 'border-l border-black/10 dark:border-white/10'} ${pressedCell && pressedCell.r===rowIdx && pressedCell.c===colIdx ? 'fb-pressed' : ''} cursor-pointer select-none`}
                    onClick={async()=>{
                      // 空白やゴースト領域でもタップで単音を軽く試聴
                      const STRING_OPEN_MIDI = [64, 59, 55, 50, 45, 40];
                      const baseMidi = STRING_OPEN_MIDI[Math.min(rowIdx, STRING_OPEN_MIDI.length - 1)] ?? 64;
                      const midi = baseMidi + (colIdx + 1);
                      // 短い押下エフェクト
                      setPressedCell(prev => ({ r: rowIdx, c: colIdx, ver: (prev?.ver ?? 0) + 1 }));
                      const localVer = (pressedCell?.ver ?? 0) + 1;
                      window.setTimeout(() => {
                        setPressedCell(cur => (cur && cur.r===rowIdx && cur.c===colIdx && cur.ver===localVer) ? null : cur);
                      }, 180);
                      try { await player.resume(); player.playNote(midi, 240); } catch {}
                    }}
                  >
                    {renderMarker({ overlay: overlayEff, strings, rowIdx, colIdx, isMobile })}
                  </div>
                ))}
              </React.Fragment>
            ))}
            {/* Nut line (between 0 and 1) */}
            <div
              aria-hidden
              className="absolute pointer-events-none z-[20] bg-black/60 dark:bg-white/70"
              style={{
                left: ZERO_COL_W - NUT_WIDTH / 2,
                top: 0,
                bottom: 0,
                width: NUT_WIDTH,
                borderRadius: 2,
              }}
            />
          </div>
        </div>
      </div>
      {formShape && renderFormOverlay({ formShape, LEFT_GUTTER, TOP_BAR_H, SPACE_W, ROW_H })}
    </div>
  );
}

const pitchIndexMap: Record<string, number> = {
  C: 0, "C#": 1, Db: 1, D: 2, "D#": 3, Eb: 3, E: 4, F: 5, "F#": 6, Gb: 6,
  G: 7, "G#": 8, Ab: 8, A: 9, "A#": 10, Bb: 10, B: 11,
};
const pitchIndex = (note: string): number => pitchIndexMap[note] ?? 0;
// Fallback degree label map (chromatic → degree text)
function fallbackDegreeLabel(notePc: number, rootPc: number): string {
  const d = (notePc - rootPc + 12) % 12;
  const arr = ["1","b2","2","b3","3","4","#4","5","b6","6","b7","7"] as const;
  return arr[d];
}

function renderMarker({ overlay, strings, rowIdx, colIdx, isMobile }:{ overlay: FretboardProps['overlay']; strings: string[]; rowIdx: number; colIdx: number; isMobile: boolean; }){
  if (!overlay) return null;
  const chordNotes = overlay.chordNotes ?? overlay.notes ?? [];
  const hasChord = (chordNotes?.length ?? 0) > 0;
  const chordRootIdx = hasChord ? pitchIndex(chordNotes[0] ?? "C") : 0;
  const set = new Set((chordNotes || []).map((note) => pitchIndex(note ?? "C")));
  const openPc = pitchIndex(strings[rowIdx] ?? "E");
  // Shaped: treat capo as new nut → subtract capo semitones
  // column index 0 represents fret 1 (fret 0 = open is not drawn as a column)
  const fretN = colIdx + 1;
  const spc = (openPc + fretN) % 12; // shapedは廃止・常にsounding
  // 実音のMIDI（弦の実チューニング＋フレット数）
  const STRING_OPEN_MIDI = [64, 59, 55, 50, 45, 40]; // E4, B3, G3, D3, A2, E2 (high -> low)
  const baseMidi = STRING_OPEN_MIDI[Math.min(rowIdx, STRING_OPEN_MIDI.length - 1)] ?? 64;
  const midi = baseMidi + fretN;
  // scale-aware style & label
  const scaleRoot = overlay.scaleRootPc;
  const scaleType = overlay.scaleType;
  const inScale = ((): boolean => {
    if (typeof scaleRoot !== 'number' || !scaleType) return true;
    const iv = (spc - scaleRoot + 120) % 12;
    const ivs = getScalePitches(scaleRoot, overlay.scaleType as any).map(v => (v - scaleRoot + 120) % 12);
    return ivs.includes(iv);
  })();
  // Optionally draw scale ghost when in scale and not a chord tone
  const hasChordOverlay = (chordNotes?.length ?? 0) > 0;
  const drawGhost = (overlay.showScaleGhost ?? true) && hasChordOverlay && inScale && !set.has(spc);
  // Draw chord tone if provided
  const drawChord = set.has(spc);
  const drawScaleMain = !hasChordOverlay && inScale;
  if (!drawGhost && !drawChord && !drawScaleMain) return null;
  const iv = typeof scaleRoot === 'number' ? (spc - scaleRoot + 120) % 12 : 0;
  const isRoot = iv === 0;
  const isChordTone = set.has(spc) || [0,4,7,10,11].includes(iv); // root/3/5/7 as baseline
  const degreeLbl = !inScale || typeof scaleRoot !== 'number' || !scaleType ? null : (degreeLabelFor(spc, scaleRoot, overlay.scaleType as any) ?? null);
  const baseColor = colorForDegreeLabel(false, degreeLbl, isChordTone, inScale, isRoot);
  const showDegrees = overlay.display === 'degrees';
  const fallbackRoot = (typeof scaleRoot === 'number' ? scaleRoot : chordRootIdx);
  const label = (showDegrees)
    ? (degreeLbl ?? fallbackDegreeLabel(spc, fallbackRoot))
    : PITCHES12[spc];
  const dense = (() => { const def = SCALE_CATALOG.find(s => s.id === (overlay.scaleType as any)); return (def?.degrees?.length ?? 0) > 7; })();
  const fretLabel = colIdx + 1;
  const stringNumber = rowIdx + 1;
  const ariaLabel = `string ${stringNumber}, fret ${fretLabel}, ${label === '1' ? 'root' : label}`;
  return (
    <div className="absolute inset-0" aria-live="polite">
      {drawGhost && (
        <div className={`absolute left-1/2 top-1/2 fret-dot--ghost${dense ? ' ghost--dense' : ''}`} style={{ color: ghostFromBaseColor(baseColor) }} aria-hidden />
      )}
      {drawScaleMain && (
        <button
          type="button"
          onClick={async()=>{ await player.resume(); player.playNote(midi); }}
          style={dotStyle(baseColor, isMobile)}
          className="absolute left-1/2 top-1/2 fret-dot fret-dot--main"
          aria-label={ariaLabel}
        >
          {label}
        </button>
      )}
      {drawChord && (
        <button
          type="button"
          onClick={async()=>{ await player.resume(); player.playNote(midi); }}
          style={dotStyle(baseColor, isMobile)}
          className="absolute left-1/2 top-1/2 fret-dot fret-dot--main fret-dot--chord"
          aria-label={ariaLabel}
        >
          {label}
        </button>
      )}
    </div>
  );
}

function renderOpenMarker({ overlay, strings, rowIdx, isMobile }:{ overlay: FretboardProps['overlay']; strings: string[]; rowIdx: number; isMobile: boolean; }){
  if (!overlay) return null;
  const chordNotes = overlay.chordNotes ?? overlay.notes ?? [];
  const hasChord = (chordNotes?.length ?? 0) > 0;
  const tonicIdx = hasChord ? pitchIndex(chordNotes[0] ?? "C") : 0;
  const set = new Set((chordNotes || []).map((note) => pitchIndex(note ?? "C")));
  const openPc = pitchIndex(strings[rowIdx] ?? "E");
  const spcSounding = openPc; // open = fret 0 sounding
  const spc = spcSounding; // shapedは廃止・常にsounding
  // 実音のMIDI（弦の実チューニングの開放音）
  const STRING_OPEN_MIDI = [64, 59, 55, 50, 45, 40];
  const midi = STRING_OPEN_MIDI[Math.min(rowIdx, STRING_OPEN_MIDI.length - 1)] ?? 64;
  const scaleRoot = overlay.scaleRootPc;
  const scaleType = overlay.scaleType;
  const inScale = ((): boolean => {
    if (typeof scaleRoot !== 'number' || !scaleType) return true;
    const iv = (spc - scaleRoot + 120) % 12;
    const ivs = getScalePitches(scaleRoot, overlay.scaleType as any).map(v => (v - scaleRoot + 120) % 12);
    return ivs.includes(iv);
  })();
  const hasChordOverlay = (chordNotes?.length ?? 0) > 0;
  const drawGhost = (overlay.showScaleGhost ?? true) && hasChordOverlay && inScale && !set.has(spc);
  const drawChord = set.has(spc);
  const drawScaleMain = !hasChordOverlay && inScale;
  if (!drawGhost && !drawChord && !drawScaleMain) return null;
  const iv = typeof scaleRoot === 'number' ? (spc - scaleRoot + 120) % 12 : 0;
  const isRoot = iv === 0;
  const isChordTone = [0,4,7,10,11].includes(iv) && inScale;
  const degreeLbl = !inScale || typeof scaleRoot !== 'number' || !scaleType ? null : (degreeLabelFor(spc, scaleRoot, overlay.scaleType as any) ?? null);
  const bg = colorForDegreeLabel(false, degreeLbl, isChordTone, inScale, isRoot);
  const showDegrees = overlay.display === 'degrees';
  const label = (showDegrees)
    ? (degreeLbl ?? fallbackDegreeLabel(spc, tonicIdx))
    : PITCHES12[spc];
  const dense = (() => { const def = SCALE_CATALOG.find(s => s.id === (overlay.scaleType as any)); return (def?.degrees?.length ?? 0) > 7; })();
  const stringNumber = rowIdx + 1;
  const ariaLabel = `string ${stringNumber}, fret 0, ${label === '1' ? 'root' : label}`;
  return (
    <div className="absolute inset-0">
      {drawGhost && (
        <div className={`absolute left-1/2 top-1/2 fret-dot--ghost${dense ? ' ghost--dense' : ''}`} style={{ color: COLOR_GHOST }} aria-hidden />
      )}
      {drawScaleMain && (
        <button
          type="button"
          onClick={async()=>{ await player.resume(); player.playNote(midi); }}
          style={dotStyle(bg, isMobile)}
          className="absolute left-1/2 top-1/2 fret-dot fret-dot--main"
          aria-label={ariaLabel}
        >
          {label}
        </button>
      )}
      {drawChord && (
        <button
          type="button"
          onClick={async()=>{ await player.resume(); player.playNote(midi); }}
          style={dotStyle(bg, isMobile)}
          className="absolute left-1/2 top-1/2 fret-dot fret-dot--main fret-dot--chord"
          aria-label={ariaLabel}
        >
          {label}
        </button>
      )}
    </div>
  );
}

function renderFormOverlay({ formShape, LEFT_GUTTER, TOP_BAR_H, SPACE_W, ROW_H }:{ formShape: FormShape; LEFT_GUTTER:number; TOP_BAR_H:number; SPACE_W:number; ROW_H:number; }) {
  return formShape.dots.map((dot, idx) => {
    const degree = dot.deg === '1'
      ? 'root'
      : dot.deg
          .replace(/b/g, 'flat ')
          .replace(/#/g, 'sharp ');
    const ariaLabel = `string ${dot.string}, fret ${dot.fret}, ${degree}`;
    const left = `calc(${LEFT_GUTTER}px + ${dot.fret * SPACE_W}px)`;
    const top = `calc(${TOP_BAR_H}px + ${(dot.string - 0.5) * ROW_H}px)`;
    return (
      <div
        key={`form-${idx}`}
        className="absolute"
        role="img"
        aria-label={ariaLabel}
        style={{ left, top, transform:'translate(-50%, -50%)' }}
      >
        <span className="fret-dot--form" aria-hidden />
      </div>
    );
  });
}


