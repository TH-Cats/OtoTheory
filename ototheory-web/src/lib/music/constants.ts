/**
 * 音楽理論の共通定数
 */

/** ピッチクラスの名前（0=C, 1=C#, ..., 11=B） */
export const PC_NAMES = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B'] as const;

/** ピッチクラスの総数 */
export const PITCH_CLASS_COUNT = 12;

/** デフォルトのMIDIオクターブ（C4 = MIDI 60） */
export const DEFAULT_MIDI_OCTAVE = 60;

/**
 * ピッチクラスを0-11の範囲に正規化
 */
export function mod12(pc: number): number {
  return ((pc % 12) + 12) % 12;
}

/**
 * ピッチクラス番号を音名に変換
 */
export function pcToName(pc: number): string {
  return PC_NAMES[mod12(pc)];
}

/**
 * 音名をピッチクラス番号に変換
 */
export function nameToPc(name: string): number {
  const index = PC_NAMES.indexOf(name as any);
  return index >= 0 ? index : -1;
}

