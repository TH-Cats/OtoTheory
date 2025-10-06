const NAME_TO_PC: Record<string, number> = { C:0,'C#':1,D:2,Eb:3,E:4,F:5,'F#':6,G:7,Ab:8,A:9,Bb:10,B:11 };

export function midiFromChordSym(sym: string, base: number = 60): number[] | null {
  const m = sym.match(/^([A-G](?:#|b)?)(maj7|m7|m|dim7|dim|\+|7)?/);
  if (!m) return null;
  const rootPc = NAME_TO_PC[m[1]] ?? 0;
  const root = base + rootPc;
  const q = m[2] || '';
  switch (q) {
    case 'm': return [root, root+3, root+7];
    case 'm7': return [root, root+3, root+7, root+10];
    case 'dim': return [root, root+3, root+6];
    case 'dim7': return [root, root+3, root+6, root+9];
    case '+': return [root, root+4, root+8];
    case 'maj7': return [root, root+4, root+7, root+11];
    case '7': return [root, root+4, root+7, root+10];
    default: return [root, root+4, root+7];
  }
}

// PITCHESは共通モジュールに統一
import { PC_NAMES as PITCHES } from '../music/constants';

export function namesFromMidis(midis: number[]): string[] {
  return Array.from(new Set(midis.map(m => PITCHES[((m%12)+12)%12])));
}





