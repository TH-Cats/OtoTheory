// PITCHESは lib/music/constants.ts に統一
import { PC_NAMES as PITCHES } from '../music/constants';
export type Pitch = typeof PITCHES[number];

export type ScaleId =
  | 'major'
  | 'natural_minor'
  | 'mixolydian'
  | 'lydian'
  | 'major_pentatonic'
  | 'minor_pentatonic';

export const SCALE_DEFS: Record<ScaleId, { label: string; intervals: number[] }> = {
  major:            { label: 'Major Scale',       intervals: [0,2,4,5,7,9,11] },
  natural_minor:    { label: 'Minor Scale',       intervals: [0,2,3,5,7,8,10] },
  mixolydian:       { label: 'Mixolydian Mode',   intervals: [0,2,4,5,7,9,10] },
  lydian:           { label: 'Lydian Mode',       intervals: [0,2,4,6,7,9,11] },
  major_pentatonic: { label: 'Major Pentatonic',  intervals: [0,2,4,7,9] },
  minor_pentatonic: { label: 'Minor Pentatonic',  intervals: [0,3,5,7,10] },
};

const canon = (p: string) => {
  const n = p.replace('♭','b').replace('＃','#');
  const enh: Record<string,string> = { 'Db':'C#', 'D#':'Eb', 'Gb':'F#', 'G#':'Ab', 'A#':'Bb' };
  return (enh[n] ?? n) as Pitch;
};

export function scaleNotes(tonic: string, id: ScaleId): Pitch[] {
  const pcIdx = PITCHES.indexOf(canon(tonic));
  const ints = SCALE_DEFS[id].intervals;
  return ints.map(i => PITCHES[(pcIdx + i) % 12]);
}

/** “C Mixolydian Mode 86%” のような表示名から ScaleId を推定（表示のばらつきに耐性） */
export function inferScaleIdFromLabel(label: string): ScaleId | null {
  const s = label.toLowerCase();
  if (s.includes('mixolydian')) return 'mixolydian';
  if (s.includes('lydian')) return 'lydian';
  if (s.includes('major pentatonic')) return 'major_pentatonic';
  if (s.includes('minor pentatonic')) return 'minor_pentatonic';
  if (s.includes('minor')) return 'natural_minor';
  if (s.includes('major')) return 'major';
  return null;
}


