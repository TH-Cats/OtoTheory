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
export type Quality = 
  | 'M' | 'm'  // Basic triads
  | '6' | 'm6'  // Sixth chords
  | '7' | 'M7' | 'm7' | 'mM7'  // Seventh chords
  | 'dim' | 'dim7' | 'm7b5' | 'm7♭5'  // Diminished variants
  | 'aug' | 'aug7'  // Augmented
  | 'sus2' | 'sus4'  // Suspended
  | '7sus4'  // Dominant suspended
  | '9' | 'M9' | 'm9'  // Ninths
  | '7b9' | '7#9' | '7(♭9)' | '7(9)' | '7(#9)'  // Altered ninths
  | '7b5' | '7#5' | '7(♭5)' | '7(#5)'  // Altered fifths
  | 'm7(#5)'  // Minor altered
  | 'add9' | 'madd9'  // Added ninths
  | '6/9'  // Six-nine
  | '7(11)' | '7(13)'  // Dominant extensions
  | 'M7(9)' | 'M7(13)'  // Major extensions
  | 'm6(9)' | 'm7(9)' | 'm7(11)' | 'mM7(9)'  // Minor extensions
  | '11' | 'M11'  // Elevenths
  | '13' | 'M13';  // Thirteenths

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

function shapeE_Minor7(r:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = [r, r+2, r, r, r, r];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [1,3,1,1,1,1];
  return {
    id:`e-minor7-${r}`, label:'Barre (E-shape, m7)',
    frets, fingers, barres:[{fret:r, fromString:6, toString:1, finger:1}],
    tips:['Smooth minor 7th.', 'Jazz and soul foundation.', 'Relaxed, mellow vibe.']
  };
}

function shapeE_Dom7(r:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = [r, r+2, r, r+1, r, r];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [1,3,1,2,1,1];
  return {
    id:`e-dom7-${r}`, label:'Barre (E-shape, 7)',
    frets, fingers, barres:[{fret:r, fromString:6, toString:1, finger:1}],
    tips:['Classic dominant 7th sound.', 'Tension that wants to resolve.', 'Blues and jazz staple.']
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

function shapeA_Minor7(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x', s, s+2, s, s+1, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,1,3,1,2,1];
  return {
    id:`a-minor7-${s}`, label:'Barre (A-shape, m7)',
    frets, fingers, barres:[{fret:s, fromString:5, toString:1, finger:1}],
    tips:['Sweet minor 7th.', 'R&B and neo-soul favorite.', 'Easy to transition from.']
  };
}

function shapeA_Dom7(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x', s, s+2, s, s+2, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,1,3,1,4,1];
  return {
    id:`a-dom7-${s}`, label:'Barre (A-shape, 7)',
    frets, fingers, barres:[{fret:s, fromString:5, toString:1, finger:1}],
    tips:['Bright dominant 7th.', 'Great for blues and funk.', 'Easier fingering than E-shape.']
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
  'Dmaj7':  { frets:['x','x',0,2,2,2], fingers:[null,null,null,1,2,3], tips:['Top 3 bright afterglow.'] },
  'C7':     { frets:['x',3,2,3,1,0], fingers:[null,3,2,4,1,null], tips:['Classic blues sound.','Wants to resolve to F.'] },
  'D7':     { frets:['x','x',0,2,1,2], fingers:[null,null,null,2,1,3], tips:['Bright dominant 7th.','Top 3 strings ring clearly.'] },
  'E7':     { frets:[0,2,0,1,0,0], fingers:[null,2,null,1,null,null], tips:['Easy open E7.','Blues standard.'] },
  'G7':     { frets:[3,2,0,0,0,1], fingers:[3,2,null,null,null,1], tips:['Full-bodied dominant.','Adds tension.'] },
  'A7':     { frets:['x',0,2,0,2,0], fingers:[null,null,2,null,3,null], tips:['Fingerpicking-friendly 7th.','Open strings resonate.'] },
  'Am7':    { frets:['x',0,2,0,1,0], fingers:[null,null,2,null,1,null], tips:['Smooth minor 7th.','Jazz and soul staple.'] },
  'Dm7':    { frets:['x','x',0,2,1,1], fingers:[null,null,null,2,1,1], tips:['Mellow depth.','Easy barre on 1st fret.'] },
  'Em7':    { frets:[0,2,0,0,0,0], fingers:[null,2,null,null,null,null], tips:['One-finger wonder.','Dreamy resonance.'] }
};

export function buildSymbol(root: Root, quality: Quality): {symbol:string, display:string} {
  const symbolMap: Partial<Record<Quality, {symbol: string, display: string}>> = {
    'M': { symbol: root, display: `${root}` },
    'm': { symbol: `${root}m`, display: `${root}m` },
    '6': { symbol: `${root}6`, display: `${root}6` },
    'm6': { symbol: `${root}m6`, display: `${root}m6` },
    '7': { symbol: `${root}7`, display: `${root}7` },
    'M7': { symbol: `${root}maj7`, display: `${root}M7` },
    'm7': { symbol: `${root}m7`, display: `${root}m7` },
    'mM7': { symbol: `${root}mM7`, display: `${root}mM7` },
    'dim': { symbol: `${root}dim`, display: `${root}dim` },
    'dim7': { symbol: `${root}dim7`, display: `${root}dim7` },
    'm7b5': { symbol: `${root}m7♭5`, display: `${root}m7♭5` },
    'm7♭5': { symbol: `${root}m7♭5`, display: `${root}m7♭5` },
    'aug': { symbol: `${root}aug`, display: `${root}aug` },
    'aug7': { symbol: `${root}aug7`, display: `${root}aug7` },
    'sus2': { symbol: `${root}sus2`, display: `${root}sus2` },
    'sus4': { symbol: `${root}sus4`, display: `${root}sus4` },
    '7sus4': { symbol: `${root}7sus4`, display: `${root}7sus4` },
    '9': { symbol: `${root}9`, display: `${root}9` },
    'M9': { symbol: `${root}M9`, display: `${root}M9` },
    'm9': { symbol: `${root}m9`, display: `${root}m9` },
    '7b9': { symbol: `${root}7♭9`, display: `${root}7♭9` },
    '7(♭9)': { symbol: `${root}7♭9`, display: `${root}7(♭9)` },
    '7(9)': { symbol: `${root}7(9)`, display: `${root}7(9)` },
    '7#9': { symbol: `${root}7#9`, display: `${root}7#9` },
    '7(#9)': { symbol: `${root}7#9`, display: `${root}7(#9)` },
    '7b5': { symbol: `${root}7♭5`, display: `${root}7♭5` },
    '7(♭5)': { symbol: `${root}7♭5`, display: `${root}7(♭5)` },
    '7#5': { symbol: `${root}7#5`, display: `${root}7#5` },
    '7(#5)': { symbol: `${root}7#5`, display: `${root}7(#5)` },
    'm7(#5)': { symbol: `${root}m7#5`, display: `${root}m7(#5)` },
    'add9': { symbol: `${root}add9`, display: `${root}add9` },
    'madd9': { symbol: `${root}madd9`, display: `${root}madd9` },
    '6/9': { symbol: `${root}6/9`, display: `${root}6/9` },
    '7(11)': { symbol: `${root}7(11)`, display: `${root}7(11)` },
    '7(13)': { symbol: `${root}7(13)`, display: `${root}7(13)` },
    'M7(9)': { symbol: `${root}M7(9)`, display: `${root}M7(9)` },
    'M7(13)': { symbol: `${root}M7(13)`, display: `${root}M7(13)` },
    'm6(9)': { symbol: `${root}m6(9)`, display: `${root}m6(9)` },
    'm7(9)': { symbol: `${root}m7(9)`, display: `${root}m7(9)` },
    'm7(11)': { symbol: `${root}m7(11)`, display: `${root}m7(11)` },
    'mM7(9)': { symbol: `${root}mM7(9)`, display: `${root}mM7(9)` },
    '11': { symbol: `${root}11`, display: `${root}11` },
    'M11': { symbol: `${root}M11`, display: `${root}M11` },
    '13': { symbol: `${root}13`, display: `${root}13` },
    'M13': { symbol: `${root}M13`, display: `${root}M13` }
  };
  return symbolMap[quality] || { symbol: `${root}${quality}`, display: `${root}${quality}` };
}

export function generateChord(root: Root, quality: Quality): ChordEntry {
  const {symbol, display} = buildSymbol(root, quality);

  let r = baseFretFor(root, 0);
  let s = baseFretFor(root, 1);

  const eShift = placeForWindow([r, r+3]);
  const aShift = placeForWindow([s, s+3]);
  r += eShift; s += aShift;

  // First shape: Open or Compact
  const openKey = symbol in OPEN_PRESETS ? symbol : (symbol==='F' ? 'F-mini' : '');
  let first: ChordShape;
  if (openKey && OPEN_PRESETS[openKey]) {
    const p = OPEN_PRESETS[openKey];
    first = {
      id:`open-${root}-${quality}`, label:'Open',
      frets:p.frets, fingers:p.fingers, tips:p.tips
    };
  } else {
    first = shapeCompactMajorFromA(s);
    first.id = `compact-${root}-${quality}`;
  }

  // For second shape, prefer E-form barre variants
  let second: ChordShape;
  const majorFamily = ['M', '6', 'add9', '6/9', 'M7(9)', 'M7(13)'];
  const minorFamily = ['m', 'm6', 'madd9', 'm6(9)'];
  const majSevenFamily = ['M7', 'M9', 'M11', 'M13', 'mM7', 'mM7(9)'];
  const domSevenFamily = ['7', '7(9)', '7(11)', '7(13)'];
  const minorSevenFamily = ['m7', 'm7(9)', 'm7(11)'];
  const susFamily = ['sus2', 'sus4', '7sus4'];
  const augFamily = ['aug', 'aug7', '7#5', '7(#5)'];
  const dimFamily = ['dim', 'dim7', 'm7b5', 'm7♭5', '7b5', '7(♭5)'];
  
  if (majorFamily.includes(quality)) {
    second = shapeE_Major(r);
  } else if (minorFamily.includes(quality)) {
    second = shapeE_Minor(r);
  } else if (domSevenFamily.includes(quality)) {
    second = shapeE_Dom7(r);
  } else if (minorSevenFamily.includes(quality)) {
    second = shapeE_Minor7(r);
  } else if (majSevenFamily.includes(quality)) {
    second = shapeA_Maj7(s);
  } else if (susFamily.includes(quality)) {
    second = shapeE_Sus4(r);
  } else if (augFamily.includes(quality)) {
    second = shapeE_Aug(r);
  } else if (dimFamily.includes(quality)) {
    second = shapeE_Dim(r);
  } else {
    // Default for 9, extended chords
    second = shapeE_Major(r);
    second.label = `Barre (E-shape, ${quality})`;
  }
  second.id = `e-${root}-${quality}`;

  // For third shape, prefer A-form barre variants
  let third: ChordShape;
  if (majorFamily.includes(quality)) {
    third = shapeA_Major(s);
  } else if (minorFamily.includes(quality)) {
    third = shapeA_Minor(s);
  } else if (domSevenFamily.includes(quality)) {
    third = shapeA_Dom7(s);
  } else if (minorSevenFamily.includes(quality)) {
    third = shapeA_Minor7(s);
  } else if (majSevenFamily.includes(quality)) {
    third = shapeA_Maj7(s);
  } else if (susFamily.includes(quality)) {
    third = shapeA_Sus4(s);
  } else if (augFamily.includes(quality)) {
    third = shapeA_Aug(s);
  } else if (dimFamily.includes(quality)) {
    third = shapeA_Dim(s);
  } else {
    // Default for 9, extended chords
    third = shapeA_Major(s);
    third.label = `Barre (A-shape, ${quality})`;
  }
  third.id = `a-${root}-${quality}`;

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
export const QUALITIES: Quality[] = [
  'M', 'm', 'aug', 'dim', 'sus4',  // Basic
  '6', '7', 'M7', 'm6', 'm7', 'mM7',  // Sixths & Sevenths
  'aug7', 'dim7', '7sus4', '7(♭5)', '7(#5)',  // Extended dominants
  'm7♭5', 'm7(#5)', '6/9',  // Altered sevenths
  '7(♭9)', '7(9)', '7(#9)', '7(11)', '7(13)',  // Dominant extensions
  'M7(9)', 'M7(13)', 'm6(9)', 'm7(9)', 'm7(11)',  // Other extensions
  'mM7(9)', 'add9', 'madd9',  // Added notes
  'sus2', '9', 'M9', 'm9',  // Ninths
  '11', 'M11', '13', 'M13'  // Elevenths & Thirteenths
];


