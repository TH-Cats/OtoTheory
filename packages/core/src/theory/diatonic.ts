import { PC_NAMES, mod12 } from '../music-theory/constants';

export interface DiatonicChord {
  degree: number;      // 1-7
  root: string;        // 'C', 'D', ...
  quality: string;     // 'maj', 'min', '7', 'dim', ...
  symbol: string;      // 'C', 'Dm', 'G7', ...
}

/**
 * スケールの間隔（インターバル）を取得
 */
function getScaleIntervals(scaleName: string): number[] | null {
  const scales: Record<string, number[]> = {
    'major': [0, 2, 4, 5, 7, 9, 11],
    'ionian': [0, 2, 4, 5, 7, 9, 11],
    'dorian': [0, 2, 3, 5, 7, 9, 10],
    'phrygian': [0, 1, 3, 5, 7, 8, 10],
    'lydian': [0, 2, 4, 6, 7, 9, 11],
    'mixolydian': [0, 2, 4, 5, 7, 9, 10],
    'minor': [0, 2, 3, 5, 7, 8, 10],
    'aeolian': [0, 2, 3, 5, 7, 8, 10],
    'locrian': [0, 1, 3, 5, 6, 8, 10],
  };
  
  return scales[scaleName.toLowerCase()] || null;
}

/**
 * 3度と5度の間隔からコードのクオリティを判定
 */
function determineQuality(thirdInterval: number, fifthInterval: number): string {
  // Normalize intervals
  const third = mod12(thirdInterval);
  const fifth = mod12(fifthInterval);
  
  // Major 3rd (4 semitones) + Perfect 5th (7 semitones) = maj
  if (third === 4 && fifth === 7) return 'maj';
  
  // Minor 3rd (3 semitones) + Perfect 5th (7 semitones) = min
  if (third === 3 && fifth === 7) return 'min';
  
  // Minor 3rd + Diminished 5th (6 semitones) = dim
  if (third === 3 && fifth === 6) return 'dim';
  
  // Major 3rd + Augmented 5th (8 semitones) = aug
  if (third === 4 && fifth === 8) return 'aug';
  
  // Fallback to major
  return 'maj';
}

/**
 * ルート音とクオリティからコード記号を生成
 */
function formatChordSymbol(root: string, quality: string): string {
  if (quality === 'maj') return root;
  if (quality === 'min') return root + 'm';
  if (quality === 'dim') return root + 'dim';
  if (quality === 'aug') return root + 'aug';
  return root;
}

/**
 * 指定されたキーとスケールのダイアトニックコードを取得
 * 
 * @param key - ルート音 (例: 'C', 'D', 'F#')
 * @param scaleName - スケール名 (例: 'major', 'ionian', 'dorian')
 * @returns ダイアトニックコードの配列
 */
export function getDiatonicChords(key: string, scaleName: string): DiatonicChord[] {
  // 1. key を PC に変換
  const keyPc = PC_NAMES.indexOf(key as any);
  if (keyPc === -1) {
    console.warn(`Invalid key: ${key}`);
    return [];
  }

  // 2. scaleName から intervals を取得
  const intervals = getScaleIntervals(scaleName);
  if (!intervals || intervals.length < 7) {
    console.warn(`Invalid or non-heptatonic scale: ${scaleName}`);
    return [];
  }

  // 3. 各度数でトライアドを構築
  const chords: DiatonicChord[] = [];
  
  for (let i = 0; i < 7; i++) {
    // ルート音のPC
    const rootPc = mod12(keyPc + intervals[i]);
    const root = PC_NAMES[rootPc];
    
    // 3rd (2つ上の音) と 5th (4つ上の音) を取得
    const thirdInterval = intervals[(i + 2) % 7] - intervals[i];
    const fifthInterval = intervals[(i + 4) % 7] - intervals[i];
    
    // quality を判定
    const quality = determineQuality(thirdInterval, fifthInterval);
    const symbol = formatChordSymbol(root, quality);
    
    chords.push({
      degree: i + 1,
      root,
      quality,
      symbol
    });
  }
  
  return chords;
}

/**
 * 簡易版: コード記号の配列のみを返す（互換性のため）
 */
export function getDiatonicChordSymbols(key: string, scaleName: string): string[] {
  return getDiatonicChords(key, scaleName).map(c => c.symbol);
}


