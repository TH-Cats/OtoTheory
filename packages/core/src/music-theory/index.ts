/**
 * Music Theory Core Module
 * 音楽理論の基礎機能
 */

export * from './constants';
import { mod12 } from './constants';

/**
 * 移調: ピッチクラスを半音単位で移動
 */
export function transpose(pc: number, semitones: number): number {
  return mod12(pc + semitones);
}

/**
 * 音程計算: 2つのピッチクラス間の半音数
 */
export function interval(from: number, to: number): number {
  return mod12(to - from);
}

/**
 * コード記号の正規化（基本版）
 */
export function normalizeChordSymbol(symbol: string): string {
  return symbol
    .replace(/maj7/i, 'maj7')
    .replace(/min7/i, 'm7')
    .replace(/min/i, 'm')
    .replace(/dim/i, 'dim')
    .replace(/aug/i, 'aug')
    .trim();
}

