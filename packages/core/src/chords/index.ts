/**
 * Chord Module
 * コード解析・正規化
 */

export * from './types';
import { getDiatonicChordSymbols } from '../theory/diatonic';

/**
 * 簡易コードパーサー（iOS Bridge用）
 * @param symbol コード記号（例: "Cmaj7", "Am", "G7"）
 */
export function parseChord(symbol: string): { root: string; quality: string; bass?: string } | null {
  // ルート音とクオリティを分離（スラッシュコード対応）
  const parts = symbol.split('/');
  const mainChord = parts[0];
  const bass = parts[1] || undefined;
  
  const match = mainChord.match(/^([A-G](?:#|b)?)(.*)$/);
  if (!match) return null;

  const root = match[1];
  const quality = match[2] || 'major';

  return { root, quality, bass };
}

/**
 * ダイアトニックコード生成
 * @param key キー（例: "C"）
 * @param scale スケール（例: "ionian", "major", "dorian"）
 */
export function getDiatonicChords(key: string, scale: string): string[] {
  return getDiatonicChordSymbols(key, scale);
}

