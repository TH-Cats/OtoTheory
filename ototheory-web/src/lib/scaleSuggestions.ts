export type ScaleId =
  | 'Ionian' | 'Lydian' | 'Aeolian' | 'Dorian' | 'Phrygian'
  | 'Mixolydian' | 'Locrian' | 'DiminishedWholeHalf'
  | 'HarmonicMinor' | 'MelodicMinor' | 'WholeTone' | 'Altered';

export type WhyKey =
  | 'maj_ionian' | 'maj_lydian' | 'maj_mixolydian'
  | 'min_aeolian' | 'min_dorian' | 'min_phrygian' | 'min_harmonic' | 'min_melodic'
  | 'dom_mixolydian' | 'dom_altered' | 'dom_wholetone'
  | 'm7b5_locrian' | 'dim_wh';

export type Suggest = { scales: ScaleId[]; why: WhyKey[] };

export function suggestScalesForChord(quality: 'maj'|'min'|'dom7'|'m7b5'|'dim'|'maj7'|'m7'|'7'): Suggest {
  switch (quality) {
    case 'maj':
    case 'maj7':
      return { scales: ['Ionian','Lydian'], why: ['maj_ionian','maj_lydian'] };
    case 'min':
    case 'm7':
      return { scales: ['Aeolian','Dorian','Phrygian'], why: ['min_aeolian','min_dorian','min_phrygian'] };
    case 'dom7':
    case '7':
      return { scales: ['Mixolydian','Altered'], why: ['dom_mixolydian','dom_altered'] };
    case 'm7b5':
      return { scales: ['Locrian','DiminishedWholeHalf'], why: ['m7b5_locrian','dim_wh'] };
    case 'dim':
      return { scales: ['DiminishedWholeHalf','Locrian'], why: ['dim_wh','m7b5_locrian'] };
  }
}


