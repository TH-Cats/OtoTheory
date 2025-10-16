export type Pc = number; // 0..11
import { SCALE_CATALOG, type DegreeToken, type ScaleId as CatalogScaleId } from './scaleCatalog';

export type ScaleType =
  | 'Ionian'
  | 'Dorian'
  | 'Phrygian'
  | 'Lydian'
  | 'Mixolydian'
  | 'Aeolian'
  | 'Locrian'
  | 'HarmonicMinor'
  | 'MelodicMinor'
  | 'MajorPentatonic'
  | 'MinorPentatonic'
  | 'Blues'
  | 'DiminishedWholeHalf'
  | 'DiminishedHalfWhole';

export const SCALE_INTERVALS: Record<ScaleType, number[]> = {
  Ionian:          [0,2,4,5,7,9,11],
  Dorian:          [0,2,3,5,7,9,10],
  Phrygian:        [0,1,3,5,7,8,10],
  Lydian:          [0,2,4,6,7,9,11],
  Mixolydian:      [0,2,4,5,7,9,10],
  Aeolian:         [0,2,3,5,7,8,10],
  Locrian:         [0,1,3,5,6,8,10],
  HarmonicMinor:   [0,2,3,5,7,8,11],
  MelodicMinor:    [0,2,3,5,7,9,11],
  MajorPentatonic: [0,2,4,7,9],
  MinorPentatonic: [0,3,5,7,10],
  Blues:           [0,3,5,6,7,10],
  DiminishedWholeHalf: [0,2,3,5,6,8,9,11],
  DiminishedHalfWhole: [0,1,3,4,6,7,9,10],
};

export type ScaleId = CatalogScaleId;

export function getScalePitches(root: Pc, type: ScaleId): Pc[] {
  // Prefer catalog-driven calculation when possible
  try {
    return getScalePitchesById(root, type as unknown as CatalogScaleId);
  } catch {}
  const ints = SCALE_INTERVALS[type as unknown as ScaleType];
  if (!ints || ints.length === 0) {
    throw new Error(`Unknown scale id: ${String(type)}`);
  }
  return ints.map((iv) => (root + iv + 120) % 12);
}

export function scaleTypeLabel(t: ScaleId | ScaleType): string {
  const map: Record<ScaleType,string> = {
    Ionian: 'major scale',
    Dorian: 'Dorian',
    Phrygian: 'Phrygian',
    Lydian: 'Lydian',
    Mixolydian: 'Mixolydian',
    Aeolian: 'natural minor scale',
    Locrian: 'Locrian',
    HarmonicMinor: 'Harmonic Minor',
    MelodicMinor: 'Melodic Minor',
    MajorPentatonic: 'Major Pentatonic',
    MinorPentatonic: 'Minor Pentatonic',
  };
  // Mapを既定とし、未定義はカタログのdisplay.enを利用
  const short = map[t as ScaleType];
  if (short) return short;
  const cat = SCALE_CATALOG.find(s => s.id === (t as any));
  return (cat?.display.en || String(t)).replace(/\s*\(.*\)$/,'');
}

// === Degree labels (with accidentals) per scale type ===
export const DEGREE_LABELS: Record<ScaleType, string[]> = {
  Ionian:          ["1","2","3","4","5","6","7"],
  Dorian:          ["1","2","♭3","4","5","6","♭7"],
  Phrygian:        ["1","♭2","♭3","4","5","♭6","♭7"],
  Lydian:          ["1","2","3","♯4","5","6","7"],
  Mixolydian:      ["1","2","3","4","5","6","♭7"],
  Aeolian:         ["1","2","♭3","4","5","♭6","♭7"],
  Locrian:         ["1","♭2","♭3","4","♭5","♭6","♭7"],
  HarmonicMinor:   ["1","2","♭3","4","5","♭6","7"],
  MelodicMinor:    ["1","2","♭3","4","5","6","7"],
  MajorPentatonic: ["1","2","3","5","6"],
  MinorPentatonic: ["1","♭3","4","5","♭7"],
  Blues:           ["1","♭3","4","♭5","5","♭7"],
};

// pc to degree label for given scale; returns null if pc not in scale
export function degreeLabelFor(pc: Pc, root: Pc, type: ScaleId | ScaleType): string | null {
  const iv = (pc - root + 120) % 12;
  // Prefer catalog degrees → semitone offsets
  const cat = SCALE_CATALOG.find(s => s.id === (type as any));
  const ivs = (cat ? cat.degrees.map(d => DEGREE_TO_SEMITONE[d]) : undefined)
    ?? (SCALE_INTERVALS[type as ScaleType] ?? []);
  const idx = ivs.indexOf(iv);
  if (idx === -1) return null;
  const labels = (cat?.degrees as string[] | undefined)
    ?? (DEGREE_LABELS[type as ScaleType] ?? undefined);
  if (!labels) return null;
  return labels[idx] ?? null;
}

// Parent mode mapping (e.g., pentatonic → its diatonic parent)
export function parentModeOf(t: ScaleId | ScaleType): ScaleType | null {
  switch (t) {
    case 'MajorPentatonic':
      return 'Ionian';
    case 'MinorPentatonic':
      return 'Aeolian';
    default:
      return null;
  }
}


// === Roman degree labels per scale type (vs Ionian baseline) ===
const IONIAN_INTERVALS = [0,2,4,5,7,9,11];
const ROMAN_BASE = ['I','II','III','IV','V','VI','VII'] as const;

export function romanDegreeLabelsForScale(scaleType: ScaleType): string[] {
  const ints = SCALE_INTERVALS[scaleType];
  // Fallback for non-7-note scales
  if (!ints || ints.length !== 7) return [...ROMAN_BASE];
  return ints.map((semi, i) => {
    const base = ROMAN_BASE[i];
    const diff = semi - IONIAN_INTERVALS[i];
    if (diff === 0) return base;
    if (diff > 0) return '#'.repeat(diff) + base;
    return 'b'.repeat(-diff) + base;
  });
}

// === Catalog-driven semitone mapping and API (SSOT; supports 5/7/8 notes) ===
export const DEGREE_TO_SEMITONE: Record<DegreeToken, number> = {
  '1': 0,
  'b2': 1,
  '2': 2,
  'b3': 3,
  '3': 4,
  '4': 5,
  '#4': 6,
  'b5': 6,
  '5': 7,
  '#5': 8,
  'b6': 8,
  '6': 9,
  'bb7': 9,
  'b7': 10,
  '7': 11,
};

export function getScalePitchesById(rootPc: number, id: CatalogScaleId): number[] {
  const s = SCALE_CATALOG.find(x => x.id === id);
  if (!s) throw new Error(`Scale not found in catalog: ${String(id)}`);
  return s.degrees.map(d => (rootPc + DEGREE_TO_SEMITONE[d] + 120) % 12);
}

// Dev helper: expose minimal API for console checks
if (typeof window !== 'undefined') {
  (window as any).__SCALES_API__ = {
    getScalePitchesById,
  };
}


