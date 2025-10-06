import type { Pc, Mode, ChordSym } from "../theory";
import { parseChord } from "../theory";
import { getScalePitches, type ScaleType } from "../scales";

export type ScaleCandidate = {
  root: Pc;
  type: ScaleType;
  score: number; // 0..100
  reasons?: string[];
};

const CANDIDATE_TYPES_MAJOR: ScaleType[] = [
  "Ionian",
  "Lydian",
  "Mixolydian",
  "MajorPentatonic",
];
const CANDIDATE_TYPES_MINOR: ScaleType[] = [
  "Aeolian",
  "Dorian",
  "Phrygian",
  "HarmonicMinor",
  "MelodicMinor",
  "MinorPentatonic",
];

function uniq<T>(arr: T[]): T[] {
  return Array.from(new Set(arr));
}

export function scoreScales(
  prog: ChordSym[],
  key: { root: Pc; mode: Mode }
): ScaleCandidate[] {
  const types = key.mode === "Major" ? CANDIDATE_TYPES_MAJOR : CANDIDATE_TYPES_MINOR;
  const chordPcs = uniq(
    prog.flatMap((ch) => {
      const p = parseChord(ch);
      const thirds = p.qual.includes("m") ? 3 : 4;
      const sevenths = p.qual.includes("7") ? (p.qual.includes("M7") ? 11 : 10) : null;
      const pcs = [p.root % 12, (p.root + thirds) % 12, (p.root + 7) % 12];
      if (sevenths !== null) pcs.push((p.root + sevenths) % 12);
      return pcs;
    })
  );

  const hasV7 = prog.some((ch) => /7\b/.test(ch));

  return types
    .map<ScaleCandidate>((type) => {
      const scale = getScalePitches(key.root, type);
      const hit = chordPcs.filter((pc) => scale.includes(pc)).length;
      const cover = hit / Math.max(1, chordPcs.length);
      // ---- bonuses (max total 0.05) ----
      let bonus = 0;
      if (key.mode === "Major" && type === "Ionian") bonus += 0.02;
      if (key.mode === "Minor" && type === "Aeolian") bonus += 0.02;
      if (hasV7 && (type === "HarmonicMinor" || type === "MelodicMinor")) bonus += 0.03;
      const raw = Math.min(1, cover + bonus);
      const score = Math.round(raw * 100);
      return { root: key.root, type, score };
    })
    .sort((a, b) => b.score - a.score);
}


