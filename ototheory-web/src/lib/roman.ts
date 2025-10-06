import { degreeLabelFor, parentModeOf, getScalePitches, type ScaleType } from "@/lib/scales";
import { parseChord, type ChordSym } from "@/lib/theory";

const ROMAN_UPPER = ["I","II","III","IV","V","VI","VII"] as const;

function baseRomanFromDegreeLabel(lbl: string | null): string {
  if (!lbl) return "I";
  const n = Number(lbl.replace(/[♭#]/g, ""));
  const idx = isFinite(n) ? Math.max(1, Math.min(7, n)) - 1 : 0;
  return ROMAN_UPPER[idx];
}

function qualitySuffix(qual: string): string { return /7/.test(qual) ? "7" : ""; }
function diminishedSymbol(qual: string): string { return /dim|o/.test(qual) ? "°" : ""; }

export function romanizeChord(
  chord: ChordSym,
  tonicPc: number,
  scaleType: ScaleType
): string {
  const { root, qual } = parseChord(chord);
  const effectiveType = parentModeOf(scaleType) ?? scaleType;
  // try exact degree label first
  let lbl = degreeLabelFor(root, tonicPc, effectiveType);
  let accidental = lbl?.startsWith("♭") ? "♭" : lbl?.startsWith("#") ? "♯" : "";
  // if null, try ±1 semitone nearest mapping
  if (!lbl) {
    const pcs = getScalePitches(tonicPc, effectiveType); // absolute pcs
    const minus = (root + 12 - 1) % 12;
    const plus = (root + 1) % 12;
    const idxMinus = pcs.indexOf(minus);
    const idxPlus = pcs.indexOf(plus);
    if (idxMinus !== -1) {
      lbl = degreeLabelFor(minus, tonicPc, effectiveType); // e.g., "3"
      accidental = "♭";
    } else if (idxPlus !== -1) {
      lbl = degreeLabelFor(plus, tonicPc, effectiveType);
      accidental = "♯";
    }
  }
  const base = baseRomanFromDegreeLabel(lbl);
  const sym = diminishedSymbol(qual);
  const suf = qualitySuffix(qual);
  return `${accidental}${base}${sym}${suf}`;
}

export function progressionToRoman(
  chords: ChordSym[],
  tonicPc: number,
  scaleType: ScaleType
): string[] {
  return chords.map((c) => romanizeChord(c, tonicPc, scaleType));
}


