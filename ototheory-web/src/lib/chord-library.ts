// /lib/chord-library.ts
export type Fret = number | 0 | 'x';
export type Finger = 1 | 2 | 3 | 4 | null;

export interface Barre {
  fret: number;
  fromString: number;
  toString: number;
  finger?: Finger;
}

export interface ChordShape {
  id: string;
  label: string;
  frets: [Fret, Fret, Fret, Fret, Fret, Fret];
  fingers?: [Finger, Finger, Finger, Finger, Finger, Finger];
  barres?: Barre[];
  tips: string[];
}

export interface ChordEntry {
  symbol: string;
  display: string;
  shapes: [ChordShape, ChordShape, ChordShape];
}

export type Root =
  | 'C'|'C#'|'D'|'D#'|'E'|'F'|'F#'|'G'|'G#'|'A'|'A#'|'B';
export type Quality = 'Major'|'m'|'M7'|'dim'|'aug'|'sus4';

const NOTE_INDEX: Record<Root, number> = {
  C:0,'C#':1,D:2,'D#':3,E:4,F:5,'F#':6,G:7,'G#':8,A:9,'A#':10,B:11
};
const OPEN_IDX = [4,9,2,7,11,4];

function baseFretFor(root: Root, stringIdx: 0|1|2|3|4|5): number {
  const want = NOTE_INDEX[root];
  const open = OPEN_IDX[stringIdx];
  const f = (want - open + 12) % 12;
  return f;
}

function placeForWindow(requiredFrets: number[], prefer: 'low'|'mid'|'hi'='mid') {
  const min = Math.min(...requiredFrets);
  const max = Math.max(...requiredFrets);
  let bestShift = 0, bestScore=-1;
  const best = (shift: number) => {
    const sMin = min + shift;
    const sMax = max + shift;
    let score = 0;
    if (sMin >= 1) score += 2;
    if (sMax <= 15) score += 2;
    const center = (sMin + sMax) / 2;
    const target = prefer==='low'?4:prefer==='hi'?12:8;
    score += 2 - Math.abs(center - target) / 6;
    return {score, sMin, sMax};
  };
  for (let k=-1; k<=2; k++) {
    const {score} = best(12*k);
    if (score > bestScore) { bestScore = score; bestShift = 12*k; }
  }
  return bestShift;
}

function shapeE_Major(r:number): ChordShape {
  const frets: [Fret,Fret,Fret,Fret,Fret,Fret] = [r, r+2, r+2, r+1, r, r];
  const fingers: [Finger, Finger, Finger, Finger, Finger, Finger] = [1,3,4,2,1,1];
  return {
    id:`e-major-${r}`, label:'Barre (E-shape)',
    frets, fingers, barres:[{fret:r, fromString:6, toString:1, finger:1}],
    tips:['Versatile barre form for any key.', 'Light muting on 6th string with distortion.', 'Release grip briefly between measures to reduce fatigue.']
  };
}

function shapeE_Minor(r:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = [r, r+2, r+2, r, r, r];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [1,3,4,1,1,1];
  return {
    id:`e-minor-${r}`, label:'Barre (E-shape, m)',
    frets, fingers, barres:[{fret:r, fromString:6, toString:1, finger:1}],
    tips:['Dark, tight minor sound.', 'Balance low end with bass.', 'Thin mid-high focus lifts vocals.']
  };
}

function shapeE_Sus4(r:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = [r, r+2, r+2, r+2, r, r];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [1,3,4,2,1,1];
  return {
    id:`e-sus4-${r}`, label:'Barre (E-shape, sus4)',
    frets, fingers, barres:[{fret:r, fromString:6, toString:1, finger:1}],
    tips:['Tension → resolution pattern.', 'Use briefly in fast songs for impact.']
  };
}

function shapeE_Aug(r:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = [r, r+3, r+2, r+1, r, r];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [1,4,3,2,1,1];
  return {
    id:`e-aug-${r}`, label:'Barre (E-shape, aug)',
    frets, fingers, barres:[{fret:r, fromString:6, toString:1, finger:1}],
    tips:['Floating feel (#5).', 'Perfect for short accent moments.']
  };
}

function shapeE_Dim(r:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = [r, r+1, r+1, r, r, r];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [1,3,4,1,1,1];
  return {
    id:`e-dim-${r}`, label:'Barre (E-shape, dim triad)',
    frets, fingers, barres:[{fret:r, fromString:6, toString:1, finger:1}],
    tips:['Anxious spice.', 'Insert for just one beat as bridge.']
  };
}

function shapeA_Major(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x', s, s+2, s+2, s+2, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,1,3,4,2,1];
  return {
    id:`a-major-${s}`, label:'Barre (A-shape)',
    frets, fingers, barres:[{fret:s, fromString:5, toString:1, finger:1}],
    tips:['Bright highs, great for arpeggios.','1st string can be muted (x-?-?-?-?-x).']
  };
}

function shapeA_Minor(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x', s, s+2, s+2, s+1, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,1,3,4,2,1];
  return {
    id:`a-minor-${s}`, label:'Barre (A-shape, m)',
    frets, fingers, barres:[{fret:s, fromString:5, toString:1, finger:1}],
    tips:['Subtle depth and calm.', 'Won\'t interfere with melody.']
  };
}

function shapeA_Maj7(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x', s, s+2, s+1, s+2, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,1,3,2,4,1];
  return {
    id:`a-maj7-${s}`, label:'Barre (A-shape, M7)',
    frets, fingers, barres:[{fret:s, fromString:5, toString:1, finger:1}],
    tips:['Soft dissolve M7.', 'Perfect for ballads and city pop.']
  };
}

function shapeA_Sus4(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x', s, s+2, s+2, s+3, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,1,3,4,4,1];
  return {
    id:`a-sus4-${s}`, label:'Barre (A-shape, sus4)',
    frets, fingers, barres:[{fret:s, fromString:5, toString:1, finger:1}],
    tips:['Build tension.', 'Return to 3rd for clean resolution.']
  };
}

function shapeA_Aug(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x', s, s+3, s+2, s+2, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,1,4,3,2,1];
  return {
    id:`a-aug-${s}`, label:'Barre (A-shape, aug)',
    frets, fingers, barres:[{fret:s, fromString:5, toString:1, finger:1}],
    tips:['#5 for floating feel.', 'Short accent moments.']
  };
}

function shapeA_Dim(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x', s, s+1, s+2, s+1, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,1,2,4,3,1];
  return {
    id:`a-dim-${s}`, label:'Barre (A-shape, dim triad)',
    frets, fingers, barres:[{fret:s, fromString:5, toString:1, finger:1}],
    tips:['One-beat bridge.', 'Arpeggio passage sounds elegant.']
  };
}

function shapeCompactMajorFromA(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x','x', s+2, s+2, s+1, 'x'];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,null,3,4,2,null];
  return {
    id:`compact-major-${s}`, label:'Compact (Top 4)',
    frets, fingers,
    tips:['Top-note design friendly.', 'Mini form that won\'t muddy vocals.', 'Mute 5th & 6th strings.']
  };
}

const OPEN_PRESETS: Record<string, {frets:[Fret,Fret,Fret,Fret,Fret,Fret]; fingers:[Finger, Finger, Finger, Finger, Finger, Finger]; tips:string[]}> = {
  'C':      { frets:['x',3,2,0,1,0], fingers:[null,3,2,null,1,null], tips:['Mute 6th string.','Open 1st rings beautifully.'] },
  'G':      { frets:[3,2,0,0,0,3],  fingers:[2,1,null,null,null,3], tips:['Thick low end.','3rd fret on 1st can be muted if needed.'] },
  'D':      { frets:['x','x',0,2,3,2], fingers:[null,null,null,1,3,2], tips:['Top 3 strings cut through.'] },
  'A':      { frets:['x',0,2,2,2,0], fingers:[null,null,1,2,3,null], tips:['Full strumming power.'] },
  'E':      { frets:[0,2,2,1,0,0], fingers:[null,2,3,1,null,null], tips:['Rock foundation bright E.'] },
  'Am':     { frets:['x',0,2,2,1,0], fingers:[null,null,2,3,1,null], tips:['Fingerpicking friendly.'] },
  'Dm':     { frets:['x','x',0,2,3,1], fingers:[null,null,null,2,3,1], tips:['Top 3 string calm depth.'] },
  'F-mini': { frets:['x','x',3,2,1,1], fingers:[null,null,3,2,1,1], tips:['Gentle F (partial barre).'] },
  'Cmaj7':  { frets:['x',3,2,0,0,0], fingers:[null,3,2,null,null,null], tips:['Soft dissolve.'] },
  'Dmaj7':  { frets:['x','x',0,2,2,2], fingers:[null,null,null,1,2,3], tips:['Top 3 bright afterglow.'] }
};

export function buildSymbol(root: Root, quality: Quality): {symbol:string, display:string} {
  switch (quality) {
    case 'Major': return { symbol: root, display: `${root} Major` };
    case 'm':     return { symbol: `${root}m`, display: `${root} m` };
    case 'M7':    return { symbol: `${root}maj7`, display: `${root} M7` };
    case 'dim':   return { symbol: `${root}dim`, display: `${root} dim` };
    case 'aug':   return { symbol: `${root}aug`, display: `${root} aug` };
    case 'sus4':  return { symbol: `${root}sus4`, display: `${root} sus4` };
  }
}

export function generateChord(root: Root, quality: Quality): ChordEntry {
  const {symbol, display} = buildSymbol(root, quality);

  let r = baseFretFor(root, 0);
  let s = baseFretFor(root, 1);

  const eShift = placeForWindow([r, r+3]);
  const aShift = placeForWindow([s, s+3]);
  r += eShift; s += aShift;

  let first: ChordShape | null = null;
  const openKey = symbol in OPEN_PRESETS ? symbol : (symbol==='F' ? 'F-mini' : '');
  if (openKey && OPEN_PRESETS[openKey]) {
    const p = OPEN_PRESETS[openKey];
    first = {
      id:`open-${symbol}`, label:'Open',
      frets:p.frets, fingers:p.fingers, tips:p.tips
    };
  } else {
    first = shapeCompactMajorFromA(s);
  }

  let second: ChordShape;
  switch (quality) {
    case 'Major': second = shapeE_Major(r); break;
    case 'm':     second = shapeE_Minor(r); break;
    case 'M7':    second = shapeA_Maj7(s); break;
    case 'sus4':  second = shapeE_Sus4(r); break;
    case 'aug':   second = shapeE_Aug(r); break;
    case 'dim':   second = shapeE_Dim(r); break;
  }

  let third: ChordShape;
  switch (quality) {
    case 'Major': third = shapeA_Major(s); break;
    case 'm':     third = shapeA_Minor(s); break;
    case 'M7':    third = shapeA_Major(s); third.label='Barre (A-shape alt)'; break;
    case 'sus4':  third = shapeA_Sus4(s); break;
    case 'aug':   third = shapeA_Aug(s); break;
    case 'dim':   third = shapeA_Dim(s); break;
  }

  return { symbol, display, shapes:[first, second, third] as [ChordShape,ChordShape,ChordShape] };
}

const CHORD_CACHE = new Map<string, ChordEntry>();
export function getCachedChord(root: Root, quality: Quality): ChordEntry {
  const key = `${root}-${quality}`;
  let hit = CHORD_CACHE.get(key);
  if (!hit) {
    hit = generateChord(root, quality);
    CHORD_CACHE.set(key, hit);
  }
  return hit;
}

export const ROOTS: Root[] = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];
export const QUALITIES: Quality[] = ['Major','m','M7','dim','aug','sus4'];

