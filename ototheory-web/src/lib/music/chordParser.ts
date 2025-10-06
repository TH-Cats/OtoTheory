/**
 * コード記号のパースとMIDI音への変換
 */

import { nameToPc, DEFAULT_MIDI_OCTAVE } from './constants';

export type ChordIntervals = number[];

export type ParsedChord = {
  rootPc: number;
  quality: string;
  intervals: ChordIntervals;
};

/**
 * コード記号をパースして構成音のインターバルを返す
 * 
 * @param symbol コード記号（例: "Cmaj7", "Am", "G7"）
 * @returns パース結果（ルート音、クオリティ、インターバル）
 */
export function parseChordSymbol(symbol: string): ParsedChord | null {
  // ルート音とクオリティを分離
  const match = symbol.match(/^([A-G](?:#|b)?)(.*)$/);
  if (!match) return null;

  const root = match[1];
  const quality = (match[2] || '').toLowerCase();
  const rootPc = nameToPc(root);
  
  if (rootPc < 0) return null;

  const intervals = getIntervalsForQuality(quality, symbol);
  
  return { rootPc, quality, intervals };
}

/**
 * クオリティ文字列からインターバルを取得
 */
function getIntervalsForQuality(quality: string, originalSymbol: string): ChordIntervals {
  // 基本トライアド
  let base: ChordIntervals;
  
  // マイナーコードの判定（"m" があるが "maj" ではない）
  if (/(^|[^a-z])m(?!aj)/.test(quality)) {
    base = [0, 3, 7]; // Minor
  } else if (/dim|°/.test(quality)) {
    return [0, 3, 6]; // Diminished
  } else if (/aug|\+/.test(quality)) {
    return [0, 4, 8]; // Augmented
  } else {
    base = [0, 4, 7]; // Major (default)
  }

  // 7thコードの処理
  if (/maj7|M7/.test(originalSymbol)) {
    return [...base, 11]; // Major 7th
  } else if (/7/.test(quality)) {
    return [...base, 10]; // Dominant 7th
  }

  // 6thコードの処理
  if (/6/.test(quality)) {
    return [...base.slice(0, 3), 9]; // 6th
  }

  // Suspendedコードの処理
  if (/sus4/.test(quality)) {
    return [0, 5, 7]; // sus4
  } else if (/sus2/.test(quality)) {
    return [0, 2, 7]; // sus2
  }

  // 9thコードの処理（簡易版）
  if (/9/.test(quality)) {
    return [...base, 10, 14]; // Add 9th (2 octaves up)
  }

  return base;
}

/**
 * コード記号からMIDI音番号の配列を生成
 * 
 * @param symbol コード記号
 * @param octave ベースとなるオクターブ（デフォルト: C4 = 60）
 * @returns MIDI音番号の配列、パース失敗時はnull
 */
export function chordToMidi(symbol: string, octave: number = DEFAULT_MIDI_OCTAVE): number[] | null {
  const parsed = parseChordSymbol(symbol);
  if (!parsed) return null;

  const base = octave + parsed.rootPc;
  return parsed.intervals.map(interval => base + interval);
}

