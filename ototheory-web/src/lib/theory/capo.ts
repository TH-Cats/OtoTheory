// Simple capo advisor based on friendly open-chord shapes
// PITCHESは lib/music/constants.ts に統一
import { PC_NAMES } from '../music/constants';
type Pitch = typeof PC_NAMES[number];
export type Mode = 'major'|'minor';
// 外部で使用するためにエクスポート
export const PITCHES = PC_NAMES;

const SHAPES_MAJOR: {key: Pitch, label: string, weight: number}[] = [
  { key: 'C', label: 'C', weight: 1.0 },
  { key: 'G', label: 'G', weight: 1.0 },
  { key: 'D', label: 'D', weight: 0.95 },
  { key: 'A', label: 'A', weight: 0.9 },
  { key: 'E', label: 'E', weight: 0.9 },
];
const SHAPES_MINOR: {key: Pitch, label: string, weight: number}[] = [
  { key: 'A', label: 'Am', weight: 1.0 },
  { key: 'E', label: 'Em', weight: 1.0 },
  { key: 'D', label: 'Dm', weight: 0.8 },
];

function idx(p: string){ const n = p.replace('♭','b').replace('＃','#'); 
  const map: Record<string, Pitch> = { 'Db':'C#','D#':'Eb','Gb':'F#','G#':'Ab','A#':'Bb' } as any;
  const canon = (map[n as Pitch] || n);
  return PC_NAMES.indexOf(canon as Pitch);
}
const dist = (from:number,to:number)=> (to-from+12)%12;

export type CapoOption = {
  capo: number;
  shapedKey: string;
  sounding: { tonic: Pitch, mode: Mode };
  score: number;
  notes: string[];
};

export function suggestCapoOptions(target: { tonic: string, mode: Mode }): CapoOption[] {
  const targetIdx = idx(target.tonic);
  const shapes = target.mode === 'minor' ? SHAPES_MINOR : SHAPES_MAJOR;
  const options = shapes.map(s => {
    const capo = dist(idx(s.key), targetIdx);
    const capoPenalty = capo <= 2 ? 0 : capo <= 4 ? 0.1 : capo <= 6 ? 0.25 : 0.4;
    const score = s.weight - capoPenalty;
    const notes: string[] = [];
    if (capo <= 2) notes.push('Low position');
    if (capo >= 6) notes.push('Higher position (thinner tone)');
    if (/^(E|A|C|G)/.test(s.label)) notes.push('Many open strings');
    return {
      capo,
      shapedKey: target.mode === 'minor' ? s.label : s.label,
      sounding: { tonic: PC_NAMES[targetIdx], mode: target.mode },
      score,
      notes
    } as CapoOption;
  }).sort((a,b)=> b.score-a.score);
  const picked: CapoOption[] = [];
  for (const o of options) if (!picked.some(p=>p.capo===o.capo)) picked.push(o);
  return picked.slice(0,3);
}











