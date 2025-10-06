import { PITCHES } from "./capo";

export type Pitch = typeof PITCHES[number];

const ENHARMONIC: Record<string, Pitch> = {
  'Db': 'C#',
  'D#': 'Eb',
  'Gb': 'F#',
  'G#': 'Ab',
  'A#': 'Bb',
} as any;

export function canonPitch(p: string): Pitch {
  const n = p.replace('♭','b').replace('＃','#');
  const head = n.match(/^([A-Ga-g])([#b]?)/);
  const root = head ? (head[1].toUpperCase() + (head[2] || '')) : n;
  const canon = (ENHARMONIC[root] || root) as Pitch;
  return canon;
}

function idx(p: string){
  const c = canonPitch(p);
  return PITCHES.indexOf(c);
}

function transposePc(pc: string, semis: number): Pitch {
  const i = idx(pc);
  if (i < 0) return canonPitch(pc);
  return PITCHES[(i + semis + 12) % 12];
}

// Very light-weight chord symbol transposer: transposes only root and bass part
function transposeSymbol(symbol: string, semis: number): string {
  const [head, bass] = symbol.split('/');
  const m = head.match(/^([A-Ga-g])([#b]?)(.*)$/);
  if (!m) return symbol;
  const root = transposePc(m[1].toUpperCase() + (m[2]||''), semis);
  const rest = m[3] || '';
  const transBass = bass ? transposePc(bass, semis) : '';
  return transBass ? `${root}${rest}/${transBass}` : `${root}${rest}`;
}

export function shapedToSoundingChordSymbol(symbol: string, capo: number): string {
  if (!capo) return symbol;
  return transposeSymbol(symbol, capo);
}

export function soundingToShapedChordSymbol(symbol: string, capo: number): string {
  if (!capo) return symbol;
  return transposeSymbol(symbol, -capo);
}

export function displayKeyName(selKey: {tonic:string, mode:'major'|'minor'}, viewMode: 'sounding'|'shaped', capo?: number): string {
  const t = viewMode === 'shaped' ? transposePc(selKey.tonic, -(capo||0)) : canonPitch(selKey.tonic);
  const modeLabel = selKey.mode === 'major' ? 'Major' : 'Minor';
  return `${t} ${modeLabel}`;
}


