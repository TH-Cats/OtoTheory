import { create } from "zustand";
import { type Pc, type Mode, type ChordSym, scoreKeyCandidates } from "@/lib/theory";
import { scoreScales, type ScaleCandidate } from "@/lib/analysis/scoreScales";
import { progressionToRoman } from "@/lib/roman";
import { SCALE_INTERVALS, type ScaleType, parentModeOf } from "@/lib/scales";
import { diatonicTriads, romanOfTriad } from "@/lib/theory/diatonic";
import type { CapoOption } from "@/lib/theory/capo";
import { recommendCapos, type CapoPick } from "@/lib/capo/recommend";
// Type-only import for ScaleId; using relative alias path per tsconfig
// Avoid type import resolution issue in some toolchains by using a relative path string literal type
type ScaleId = 'major'|'natural_minor'|'mixolydian'|'lydian'|'major_pentatonic'|'minor_pentatonic';

export type Candidate = { tonic: Pc; mode: Mode; confidence: number; reasons: string[] };
export type FitTag = "diatonic"|"secondary"|"borrowed"|"outside";
export type ViewMode = "sounding"|"shaped"|"compare";

type AnalysisState = {
  keyCandidates: Candidate[];
  selectedKey?: { tonic: Pc; mode: Mode };
  analysis?: { cadence?: string; perChordFit?: FitTag[] };
  capo: { capo: number; shapedKey: string } | null;
  viewMode: ViewMode;
  scaleCandidates: ScaleCandidate[];
  selectedScale: ScaleCandidate | null;
  lastProg?: ChordSym[];
  analyze: (prog: ChordSym[]) => void;
  selectKey: (key: {tonic: Pc; mode: Mode}) => void;
  selectScale: (s: ScaleCandidate) => void;
  chooseCapo: (option: CapoOption) => void;
  setViewMode: (v: ViewMode) => void;
  reset: () => void;
  romanTokens: string[];
  romanText: string;
  diatonic: { triads: ReturnType<typeof diatonicTriads>; romans: string[] } | null;
  recommendedCapos: CapoPick[];
};

export const useAnalysisStore = create<AnalysisState>((set, get) => ({
  keyCandidates: [],
  capo: null,
  viewMode: "sounding",
  scaleCandidates: [],
  selectedScale: null,
  romanTokens: [],
  romanText: "",
  diatonic: null,
  recommendedCapos: [],
  analyze: (prog) => {
    set((state)=>{
      const cands = scoreKeyCandidates(prog);
      // 既存選択がある場合でも、トップ候補と±4pt以上差があればトップへ切替（誤維持防止）
      const top = cands[0];
      const keep = state.selectedKey && cands.find(c=> c.tonic===state.selectedKey!.tonic && c.mode===state.selectedKey!.mode);
      const shouldKeep = (()=>{
        if (!keep || !top) return false;
        const diff = Math.abs((keep.confidence||0) - (top.confidence||0));
        return diff < 4; // 近差のみ維持
      })();
      const nextSel = (shouldKeep && state.selectedKey) ? state.selectedKey : (top ? { tonic: top.tonic, mode: top.mode } : undefined);
      const sc = nextSel ? scoreScales(prog, { root: nextSel.tonic, mode: nextSel.mode }) : [];
      const selScale = sc[0] ?? null;
      const romanTokens = nextSel && selScale ? progressionToRoman(prog, nextSel.tonic, selScale.type) : [];
      const diatonic = (()=>{
        if (!nextSel || !selScale) return null;
        const tonic = nextSel.tonic;
        let st = selScale.type as ScaleType;
        let intervals = SCALE_INTERVALS[st] ?? [];
        if (intervals.length < 7) {
          const parent = parentModeOf(st);
          if (parent) { st = parent; intervals = SCALE_INTERVALS[parent] ?? []; }
        }
        if (!intervals.length) return null;
        const triads = diatonicTriads({ tonicPc: tonic, scaleIntervals: intervals });
        const romans = triads.map(t => romanOfTriad(t.degree, t.quality, { case: 'upper' }));
        return { triads, romans };
      })();
      const recommendedCapos = nextSel && selScale ? recommendCapos({ tonic: nextSel.tonic as any, mode: nextSel.mode as any }, { type: selScale.type as any }, 3, { includeOpen: false }) : [];
      return { keyCandidates: cands, selectedKey: nextSel, scaleCandidates: sc, selectedScale: selScale, lastProg: prog, romanTokens, romanText: romanTokens.join(" – "), diatonic, recommendedCapos } as Partial<AnalysisState> as AnalysisState;
    });
  },
  selectKey: (key) => set((state)=>{
    const prog = state.lastProg ?? [];
    const sc = scoreScales(prog, { root: key.tonic, mode: key.mode });
    const selScale = sc[0] ?? null;
    const romanTokens = selScale ? progressionToRoman(prog, key.tonic, selScale.type) : [];
    const diatonic = (()=>{
      if (!selScale) return null;
      let st = selScale.type as ScaleType;
      let intervals = SCALE_INTERVALS[st] ?? [];
      if (intervals.length < 7) {
        const parent = parentModeOf(st);
        if (parent) { st = parent; intervals = SCALE_INTERVALS[parent] ?? []; }
      }
      if (!intervals.length) return null;
      const triads = diatonicTriads({ tonicPc: key.tonic, scaleIntervals: intervals });
      const romans = triads.map(t => romanOfTriad(t.degree, t.quality, { case: 'upper' }));
      return { triads, romans };
    })();
    const recommendedCapos = selScale ? recommendCapos({ tonic: key.tonic as any, mode: key.mode as any }, { type: selScale.type as any }, 3, { includeOpen: false }) : [];
    return { selectedKey: key, scaleCandidates: sc, selectedScale: selScale, romanTokens, romanText: romanTokens.join(" – "), diatonic, recommendedCapos };
  }),
  selectScale: (s) => set((state)=>{
    const prog = state.lastProg ?? [];
    const key = state.selectedKey;
    const tokens = prog.length && key ? progressionToRoman(prog, key.tonic, s.type) : [];
    const diatonic = (()=>{
      if (!key) return null;
      let st = s.type as ScaleType;
      let intervals = SCALE_INTERVALS[st] ?? [];
      if (intervals.length < 7) {
        const parent = parentModeOf(st);
        if (parent) { st = parent; intervals = SCALE_INTERVALS[parent] ?? []; }
      }
      if (!intervals.length) return null;
      const triads = diatonicTriads({ tonicPc: key.tonic, scaleIntervals: intervals });
      const romans = triads.map(t => romanOfTriad(t.degree, t.quality, { case: 'upper' }));
      return { triads, romans };
    })();
    const recommendedCapos = key ? recommendCapos({ tonic: key.tonic as any, mode: key.mode as any }, { type: s.type as any }, 3, { includeOpen: false }) : [];
    return { selectedScale: s, romanTokens: tokens, romanText: tokens.join(" – "), diatonic, recommendedCapos };
  }),
  chooseCapo: (option) => set({ capo: { capo: option.capo, shapedKey: option.shapedKey } }),
  setViewMode: (v) => set({ viewMode: v }),
  reset: () => set({ keyCandidates: [], selectedKey: undefined, analysis: undefined, capo: null, viewMode: "sounding", scaleCandidates: [], selectedScale: null, lastProg: [] }),
}));


