// Single Source of Truth for scale catalog (English-first)

export type DegreeToken =
  | '1' | 'b2' | '2' | 'b3' | '3' | '4' | '#4' | 'b5' | '5' | '#5' | 'b6' | '6' | 'bb7' | 'b7' | '7';

export type ScaleId =
  | 'Ionian' | 'Dorian' | 'Phrygian' | 'Lydian' | 'Mixolydian' | 'Aeolian' | 'Locrian'
  | 'MajorPentatonic' | 'MinorPentatonic' | 'Blues'
  | 'HarmonicMinor' | 'MelodicMinor' | 'Dorianb2'
  | 'DiminishedWholeHalf' | 'DiminishedHalfWhole';

export type ScaleCatalogItem = {
  id: ScaleId;
  display: { en: string; ja?: string };
  degrees: DegreeToken[];
  group: 'Diatonic' | 'Pentatonic' | 'Minor' | 'Other';
  info?: {
    oneLiner?: string;
    examples?: Array<{ title: string; artist: string; url?: string; cue?: string }>;
  };
  enabled?: boolean; // future feature flag (defaults true)
};

// NOTE: These entries follow common definitions. Please align with Excel (EN) if it differs.
export const SCALE_CATALOG: ScaleCatalogItem[] = [
  // Use English names per Excel (avoid modal names for major/minor)
  { id: 'Ionian', display: { en: 'Major Scale' }, group: 'Diatonic',
    degrees: ['1','2','3','4','5','6','7'],
    info: { oneLiner: 'Major scale; bright and stable.',
      examples: [
        { title: 'Let It Be', artist: 'The Beatles' },
        { title: 'Do-Re-Mi', artist: 'Richard Rodgers' }
      ] } },
  { id: 'Dorian', display: { en: 'Dorian Scale' }, group: 'Diatonic',
    degrees: ['1','2','b3','4','5','6','b7'],
    info: { oneLiner: 'Minor with a natural 6th; cool, modal colour.',
      examples: [
        { title: 'So What', artist: 'Miles Davis' }
      ] } },
  { id: 'Phrygian', display: { en: 'Phrygian Scale' }, group: 'Diatonic',
    degrees: ['1','b2','b3','4','5','b6','b7'],
    info: { oneLiner: 'Dark, Spanish/Arabic flavour with flat 2.' } },
  { id: 'Lydian', display: { en: 'Lydian Scale' }, group: 'Diatonic',
    degrees: ['1','2','3','#4','5','6','7'],
    info: { oneLiner: 'Dreamy major with raised 4th (♯4).',
      examples: [ { title: 'The Simpsons Theme', artist: 'Danny Elfman' } ] } },
  { id: 'Mixolydian', display: { en: 'Mixolydian Scale' }, group: 'Diatonic',
    degrees: ['1','2','3','4','5','6','b7'],
    info: { oneLiner: 'Major with flat 7; dominant, bluesy feel.',
      examples: [
        { title: 'Sweet Home Alabama', artist: 'Lynyrd Skynyrd' }
      ] } },
  { id: 'Aeolian', display: { en: 'Natural Minor Scale' }, group: 'Diatonic',
    degrees: ['1','2','b3','4','5','b6','b7'],
    info: { oneLiner: 'Natural minor; sad or moody colour.',
      examples: [ { title: 'House of the Rising Sun', artist: 'Traditional' } ] } },
  { id: 'Locrian', display: { en: 'Locrian Scale' }, group: 'Diatonic',
    degrees: ['1','b2','b3','4','b5','b6','b7'],
    info: { oneLiner: 'Diminished 5th; unstable, rarely used as a key.' } },

  { id: 'MajorPentatonic', display: { en: 'Major Pentatonic' }, group: 'Pentatonic',
    degrees: ['1','2','3','5','6'],
    info: { oneLiner: 'Five-note, open and melodic; fits many chords.',
      examples: [ { title: 'My Girl', artist: 'The Temptations' } ] } },
  { id: 'MinorPentatonic', display: { en: 'Minor Pentatonic' }, group: 'Pentatonic',
    degrees: ['1','b3','4','5','b7'],
    info: { oneLiner: 'Five-note minor staple for rock/blues solos.',
      examples: [ { title: 'Purple Haze', artist: 'Jimi Hendrix' } ] } },
  { id: 'Blues', display: { en: 'Blues Scale (minor)' }, group: 'Pentatonic',
    degrees: ['1','b3','4','b5','5','b7'],
    info: { oneLiner: 'Minor pentatonic plus blue note (♭5).',
      examples: [ { title: 'Smoke on the Water', artist: 'Deep Purple' } ] } },

  { id: 'HarmonicMinor', display: { en: 'Harmonic Minor' }, group: 'Minor',
    degrees: ['1','2','b3','4','5','b6','7'],
    info: { oneLiner: 'Minor with raised 7th; exotic dominant pull.',
      examples: [ { title: 'Misirlou', artist: 'Traditional' } ] } },
  { id: 'MelodicMinor', display: { en: 'Melodic Minor Scale' }, group: 'Minor',
    degrees: ['1','2','b3','4','5','6','7'],
    info: { oneLiner: 'Jazz minor (ascending); smooth minor/major blend.' } },

  // Diminished scales (symmetric) — added per Excel list
  { id: 'DiminishedWholeHalf', display: { en: 'Diminished Scale (Whole–Half)' }, group: 'Other',
    degrees: ['1','2','b3','4','b5','b6','6','7'],
    info: { oneLiner: 'Symmetric 8-note (whole–half) scale; over dim7.' } },
  { id: 'DiminishedHalfWhole', display: { en: 'Diminished Scale (Half–Whole)' }, group: 'Other',
    degrees: ['1','b2','b3','3','#4','5','6','b7'],
    info: { oneLiner: 'Symmetric 8-note (half–whole); over 7♭9 chords.' } },
];

// Dev helper: expose catalog for quick inspection in console (no filtering)
if (typeof window !== 'undefined') {
  (window as any).__SCALES_EN__ = SCALE_CATALOG;
}


// Build 12-bit mask from degree tokens (C-root relative)
export function getScaleMask12(id: ScaleId): number[] {
  const item = SCALE_CATALOG.find(s => s.id === id);
  if (!item) return Array(12).fill(0);
  const DEGREE_TO_SEMITONE: Record<DegreeToken, number> = {
    '1': 0, 'b2': 1, '2': 2, 'b3': 3, '3': 4, '4': 5, '#4': 6, 'b5': 6, '5': 7, '#5': 8, 'b6': 8, '6': 9, 'bb7': 9, 'b7': 10, '7': 11
  };
  const mask = Array(12).fill(0);
  for (const d of item.degrees) {
    const s = DEGREE_TO_SEMITONE[d];
    if (typeof s === 'number') mask[(s + 120) % 12] = 1;
  }
  return mask;
}

export function listScales(): { id: ScaleId; label: string }[] {
  return SCALE_CATALOG.map(s => ({ id: s.id, label: s.display.en }));
}

// 非ヘプタ判定とPent/Blues例外のヘルパー関数
export const isHeptatonic = (scaleId: string): boolean => {
  const item = SCALE_CATALOG.find(s => s.id === scaleId as ScaleId);
  return item ? item.degrees.length === 7 : false;
};

export const isPentOrBlues = (scaleId: string): boolean => {
  return scaleId === 'MajorPentatonic' || scaleId === 'MinorPentatonic' || scaleId === 'Blues';
};


