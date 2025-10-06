import { type Pc } from "@/lib/theory";

export type TriadQuality = 'maj'|'min'|'dim'|'aug';

export type DiatonicTriad = {
  degree: 1|2|3|4|5|6|7;
  rootPc: Pc;
  pcs: [Pc, Pc, Pc]; // root, third, fifth (0..11)
  quality: TriadQuality;
};

// Build 7 diatonic triads from scale intervals (e.g. Ionian [0,2,4,5,7,9,11])
export function diatonicTriads({ tonicPc, scaleIntervals }:{ tonicPc: Pc; scaleIntervals: number[] }): DiatonicTriad[] {
  const pcs = scaleIntervals.map(iv => (tonicPc + iv + 120) % 12);
  const triads: DiatonicTriad[] = [];
  for (let i = 0; i < 7; i++) {
    const deg = (i % 7) as 0|1|2|3|4|5|6;
    const r = pcs[deg];
    const t = pcs[(deg + 2) % 7];
    const f = pcs[(deg + 4) % 7];
    const q = qualityOfTriad(r, t, f);
    triads.push({ degree: (i+1) as 1|2|3|4|5|6|7, rootPc: r, pcs: [r,t,f], quality: q });
  }
  return triads;
}

function qualityOfTriad(r: number, t: number, f: number): TriadQuality {
  // intervals from root in semitones (mod 12)
  const third = (t - r + 12) % 12;
  const fifth = (f - r + 12) % 12;
  if (third === 4 && fifth === 7) return 'maj';
  if (third === 3 && fifth === 7) return 'min';
  if (third === 3 && fifth === 6) return 'dim';
  if (third === 4 && fifth === 8) return 'aug';
  // fallback: closest common qualities
  if (fifth === 6) return 'dim';
  if (fifth === 8) return 'aug';
  return third < 4 ? 'min' : 'maj';
}

const ROMAN_UP = ["I","II","III","IV","V","VI","VII"] as const;

export function romanOfTriad(degree: 1|2|3|4|5|6|7, quality: TriadQuality, opts?: { case?: 'upper'|'quality' }): string {
  const base = ROMAN_UP[degree - 1];
  const mode = opts?.case ?? 'upper';
  if (mode === 'upper') {
    // Always uppercase; add dimin./aug symbols
    if (quality === 'dim') return base + '°';
    if (quality === 'aug') return base + '+';
    return base;
  }
  // case: 'quality' → major uppercase, minor lowercase, diminished lowercase+°
  if (quality === 'min') return base.toLowerCase();
  if (quality === 'dim') return base.toLowerCase() + '°';
  if (quality === 'aug') return base + '+';
  return base; // maj
}

// Convert a triad (rootPc + quality) to a simple chord symbol (e.g., C, Cm, Cdim, C+)
const PC_TO_NAME = ['C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B'] as const;
export function triadToChordSym(t: { rootPc: Pc; quality: TriadQuality }): string {
  const root = PC_TO_NAME[t.rootPc % 12];
  if (t.quality === 'maj') return root;
  if (t.quality === 'min') return root + 'm';
  if (t.quality === 'dim') return root + 'dim';
  return root + '+'; // aug
}


