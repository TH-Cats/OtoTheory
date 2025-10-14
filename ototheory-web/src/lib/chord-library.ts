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
  | 'C'|'C#'|'D'|'Eb'|'E'|'F'|'F#'|'G'|'Ab'|'A'|'Bb'|'B';

// Core set of practical chord qualities (15-20 types)
export type Quality = 
  | 'M' | 'm'  // Basic triads
  | 'aug' | 'dim'  // Altered triads
  | 'sus2' | 'sus4'  // Suspended
  | '6' | 'm6'  // Sixth chords
  | '7' | 'M7' | 'm7'  // Essential sevenths
  | 'dim7' | 'm7b5'  // Diminished sevenths
  | '9' | 'M9' | 'm9'  // Ninths
  | 'add9' | '6/9' | '7sus4';  // Added notes & suspensions

// Advanced extensions (optional, can be toggled)
export type AdvancedQuality = 
  | '7b9' | '7#9'  // Altered ninths
  | '7b5' | '7#5'  // Altered fifths
  | '11' | '13';  // Upper extensions

const NOTE_INDEX: Record<Root, number> = {
  C:0,'C#':1,D:2,'Eb':3,E:4,F:5,'F#':6,G:7,'Ab':8,A:9,'Bb':10,B:11
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

function shapeE_6th(r:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = [r, r+2, r+2, r+1, r+2, r];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [1,3,4,2,4,1];
  return {
    id:`e-6th-${r}`, label:'Barre (E-shape, 6)',
    frets, fingers, barres:[{fret:r, fromString:6, toString:1, finger:1}],
    tips:['Bright 6th sound.', 'Jazz and vintage pop.', 'Sweet resolution chord.']
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

function shapeE_Maj7(r:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = [r, r+2, r+1, r+1, r, r];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [1,3,2,2,1,1];
  return {
    id:`e-maj7-${r}`, label:'Barre (E-shape, M7)',
    frets, fingers, barres:[{fret:r, fromString:6, toString:1, finger:1}],
    tips:['Jazzy, sophisticated M7 sound.', 'Common in R&B and neo-soul.', 'Add light vibrato on high E for shimmer.']
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

function shapeA_6th(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x', s, s+2, s+2, s+2, s+2];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,1,2,3,4,4];
  return {
    id:`a-6th-${s}`, label:'Barre (A-shape, 6)',
    frets, fingers,
    tips:['Bright 6th chord.', 'All high strings = barre.', 'Great for ending phrases.']
  };
}

function shapeA_Minor6(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x', s, s+2, s+2, s+1, s+2];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,1,2,3,1,4];
  return {
    id:`a-minor6-${s}`, label:'Barre (A-shape, m6)',
    frets, fingers, barres:[{fret:s, fromString:5, toString:2, finger:1}],
    tips:['Sophisticated minor sound.', 'Bossa nova classic.', 'Melancholic beauty.']
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

// Compact shapes for each quality (top 3-4 strings only)
function shapeCompactMajor(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x','x', s+2, s+2, s+2, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,null,2,3,4,1];
  return {
    id:`compact-major-${s}`, label:'Compact (Top 4)',
    frets, fingers,
    tips:['Bright highs, clear voicing.', 'Mini form that won\'t muddy vocals.', 'Mute 5th & 6th strings.']
  };
}

function shapeCompactMinor(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x','x', s+2, s+2, s+1, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,null,2,4,3,1];
  return {
    id:`compact-minor-${s}`, label:'Compact (Top 4, m)',
    frets, fingers,
    tips:['Sweet minor sound.', 'Easy fingering.', 'Mute 5th & 6th strings.']
  };
}

function shapeCompact6th(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x','x', s+2, s+2, s+2, s+2];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,null,1,1,1,1];
  return {
    id:`compact-6th-${s}`, label:'Compact (Top 4, 6)',
    frets, fingers, barres:[{fret:s+2, fromString:4, toString:1, finger:1}],
    tips:['Simple 6th voicing.', 'Easy barre on top 4 strings.', 'Mute 5th & 6th strings.']
  };
}

function shapeCompactMinor6(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x','x', s+2, s+2, s+1, s+2];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,null,1,2,1,3];
  return {
    id:`compact-minor6-${s}`, label:'Compact (Top 4, m6)',
    frets, fingers, barres:[{fret:s+2, fromString:4, toString:2, finger:1}],
    tips:['Sophisticated m6.', 'Bossa nova feel.', 'Mute 5th & 6th strings.']
  };
}

function shapeCompactDom7(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x','x', s+2, s, s+2, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,null,2,1,3,1];
  return {
    id:`compact-dom7-${s}`, label:'Compact (Top 4, 7)',
    frets, fingers, barres:[{fret:s, fromString:4, toString:1, finger:1}],
    tips:['Compact 7th voicing.', 'Easy barre form.', 'Mute 5th & 6th strings.']
  };
}

function shapeCompactMinor7(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x','x', s+2, s, s+1, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,null,3,1,2,1];
  return {
    id:`compact-minor7-${s}`, label:'Compact (Top 4, m7)',
    frets, fingers, barres:[{fret:s, fromString:4, toString:1, finger:1}],
    tips:['Mellow m7 sound.', 'Jazz-friendly voicing.', 'Mute 5th & 6th strings.']
  };
}

function shapeCompactMaj7(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x','x', s+2, s+1, s+2, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,null,2,1,3,1];
  return {
    id:`compact-maj7-${s}`, label:'Compact (Top 4, M7)',
    frets, fingers, barres:[{fret:s, fromString:4, toString:1, finger:1}],
    tips:['Soft M7 voicing.', 'Dreamy atmosphere.', 'Mute 5th & 6th strings.']
  };
}

function shapeCompactSus4(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x','x', s, s+2, s+3, s];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,null,1,2,4,1];
  return {
    id:`compact-sus4-${s}`, label:'Compact (Top 4, sus4)',
    frets, fingers, barres:[{fret:s, fromString:4, toString:1, finger:1}],
    tips:['Suspended tension.', 'Wants to resolve.', 'Mute 5th & 6th strings.']
  };
}

function shapeCompactAug(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x','x', s+3, s+2, s+2, s+1];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,null,4,2,3,1];
  return {
    id:`compact-aug-${s}`, label:'Compact (Top 4, aug)',
    frets, fingers,
    tips:['Floating #5 feel.', 'Short accent moments.', 'Mute 5th & 6th strings.']
  };
}

function shapeCompactDim(s:number): ChordShape {
  const frets:[Fret,Fret,Fret,Fret,Fret,Fret] = ['x','x', s+1, s+2, s+1, s-1];
  const fingers:[Finger, Finger, Finger, Finger, Finger, Finger] = [null,null,2,4,3,1];
  return {
    id:`compact-dim-${s}`, label:'Compact (Top 4, dim)',
    frets, fingers,
    tips:['Anxious diminished.', 'One-beat bridge.', 'Mute 5th & 6th strings.']
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

// Get intervals for each quality (R = Root)
// Note: Extended chords (11, 13) typically omit certain notes in practical voicings
export function getIntervals(quality: Quality | AdvancedQuality): string[] {
  const intervalMap: Partial<Record<Quality | AdvancedQuality, string[]>> = {
    // Basic triads
    'M': ['R', 'III', 'V'],
    'm': ['R', '♭III', 'V'],
    'aug': ['R', 'III', '#V'],
    'dim': ['R', '♭III', '♭V'],
    // Suspended
    'sus2': ['R', 'II', 'V'],
    'sus4': ['R', 'IV', 'V'],
    // Sixth chords
    '6': ['R', 'III', 'V', 'VI'],
    'm6': ['R', '♭III', 'V', 'VI'],
    // Essential sevenths
    '7': ['R', 'III', 'V', '♭VII'],
    'M7': ['R', 'III', 'V', 'VII'],
    'm7': ['R', '♭III', 'V', '♭VII'],
    // Diminished sevenths
    'dim7': ['R', '♭III', '♭V', '♭♭VII'],
    'm7b5': ['R', '♭III', '♭V', '♭VII'],
    // Ninths
    '9': ['R', 'III', 'V', '♭VII', 'IX'],
    'M9': ['R', 'III', 'V', 'VII', 'IX'],
    'm9': ['R', '♭III', 'V', '♭VII', 'IX'],
    // Added notes & suspensions
    'add9': ['R', 'III', 'V', 'IX'],
    '6/9': ['R', 'III', 'V', 'VI', 'IX'],
    '7sus4': ['R', 'IV', 'V', '♭VII'],
    // Advanced: Altered ninths
    '7b9': ['R', 'III', 'V', '♭VII', '♭IX'],
    '7#9': ['R', 'III', 'V', '♭VII', '#IX'],
    // Advanced: Altered fifths
    '7b5': ['R', 'III', '♭V', '♭VII'],
    '7#5': ['R', 'III', '#V', '♭VII'],
    // Advanced: Upper extensions (note: practical voicings omit 3rd for 11, omit 11 for 13)
    '11': ['R', '(III)', 'V', '♭VII', 'IX', 'XI'],  // 3rd typically omitted
    '13': ['R', 'III', 'V', '♭VII', 'IX', '(XI)', 'XIII']  // 11th typically omitted
  };
  return intervalMap[quality] || ['R', 'III', 'V'];
}

// Get voicing notes (what's actually commonly played)
export function getVoicingNote(quality: Quality | AdvancedQuality): string | null {
  const voicingNotes: Partial<Record<Quality | AdvancedQuality, string>> = {
    '11': 'Guitar voicing: 3rd usually omitted (sounds sus4-like)',
    '13': 'Guitar voicing: 11th usually omitted, often 5th too'
  };
  return voicingNotes[quality] || null;
}

// Convert interval string to semitones from root
function intervalToSemitones(interval: string): number {
  const cleaned = interval.replace(/[()]/g, ''); // Remove parentheses for optional notes
  const map: Record<string, number> = {
    'R': 0,
    '♭II': 1, 'II': 2,
    '♭III': 3, 'III': 4,
    'IV': 5, '#IV': 6,
    '♭V': 6, 'V': 7, '#V': 8,
    '♭VI': 8, 'VI': 9,
    '♭VII': 10, 'VII': 11, '♭♭VII': 9,
    'IX': 2, '♭IX': 1, '#IX': 3,
    'XI': 5, '#XI': 6,
    'XIII': 9
  };
  return map[cleaned] ?? 0;
}

// Get actual note names for a chord (using ♭-preferred notation)
export function getChordNotes(root: Root, quality: Quality | AdvancedQuality): string[] {
  // Use ♭-preferred notation (Eb, Ab, Bb instead of D#, G#, A#)
  const notes = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B'];
  const rootIdx = notes.indexOf(root);
  const intervals = getIntervals(quality);
  
  return intervals
    .filter(interval => !interval.includes('(')) // Skip optional notes in display
    .map(interval => {
      const semitones = intervalToSemitones(interval);
      return notes[(rootIdx + semitones) % 12];
    });
}

export function buildSymbol(root: Root, quality: Quality | AdvancedQuality): {symbol:string, display:string} {
  const symbolMap: Partial<Record<Quality | AdvancedQuality, {symbol: string, display: string}>> = {
    // Basic triads
    'M': { symbol: root, display: `${root}` },
    'm': { symbol: `${root}m`, display: `${root}m` },
    'aug': { symbol: `${root}aug`, display: `${root}aug` },
    'dim': { symbol: `${root}dim`, display: `${root}dim` },
    // Suspended
    'sus2': { symbol: `${root}sus2`, display: `${root}sus2` },
    'sus4': { symbol: `${root}sus4`, display: `${root}sus4` },
    // Sixth chords
    '6': { symbol: `${root}6`, display: `${root}6` },
    'm6': { symbol: `${root}m6`, display: `${root}m6` },
    // Essential sevenths
    '7': { symbol: `${root}7`, display: `${root}7` },
    'M7': { symbol: `${root}maj7`, display: `${root}M7` },
    'm7': { symbol: `${root}m7`, display: `${root}m7` },
    // Diminished sevenths
    'dim7': { symbol: `${root}dim7`, display: `${root}dim7` },
    'm7b5': { symbol: `${root}m7♭5`, display: `${root}m7♭5` },
    // Ninths
    '9': { symbol: `${root}9`, display: `${root}9` },
    'M9': { symbol: `${root}M9`, display: `${root}M9` },
    'm9': { symbol: `${root}m9`, display: `${root}m9` },
    // Added notes & suspensions
    'add9': { symbol: `${root}add9`, display: `${root}add9` },
    '6/9': { symbol: `${root}6/9`, display: `${root}6/9` },
    '7sus4': { symbol: `${root}7sus4`, display: `${root}7sus4` },
    // Advanced: Altered ninths
    '7b9': { symbol: `${root}7♭9`, display: `${root}7♭9` },
    '7#9': { symbol: `${root}7#9`, display: `${root}7#9` },
    // Advanced: Altered fifths
    '7b5': { symbol: `${root}7♭5`, display: `${root}7♭5` },
    '7#5': { symbol: `${root}7#5`, display: `${root}7#5` },
    // Advanced: Upper extensions
    '11': { symbol: `${root}11`, display: `${root}11` },
    '13': { symbol: `${root}13`, display: `${root}13` }
  };
  return symbolMap[quality] || { symbol: `${root}${quality}`, display: `${root}${quality}` };
}

export function generateChord(root: Root, quality: Quality | AdvancedQuality): ChordEntry {
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
    // Choose compact shape based on quality
    const majorFamily = ['M', 'add9'];
    const sixthFamily = ['6', '6/9'];
    const minorFamily = ['m'];
    const minorSixthFamily = ['m6'];
    const domSevenFamily = ['7', '7b9', '7#9', '7b5', '7#5'];
    const minorSevenFamily = ['m7'];
    const majSevenFamily = ['M7', 'M9'];
    const susFamily = ['sus2', 'sus4', '7sus4'];
    const augFamily = ['aug'];
    const dimFamily = ['dim', 'dim7', 'm7b5'];
    const extensionFamily = ['9', 'm9', '11', '13'];

    if (majorFamily.includes(quality)) {
      first = shapeCompactMajor(s);
    } else if (sixthFamily.includes(quality)) {
      first = shapeCompact6th(s);
    } else if (minorFamily.includes(quality)) {
      first = shapeCompactMinor(s);
    } else if (minorSixthFamily.includes(quality)) {
      first = shapeCompactMinor6(s);
    } else if (domSevenFamily.includes(quality) || extensionFamily.includes(quality)) {
      first = shapeCompactDom7(s);
    } else if (minorSevenFamily.includes(quality)) {
      first = shapeCompactMinor7(s);
    } else if (majSevenFamily.includes(quality)) {
      first = shapeCompactMaj7(s);
    } else if (susFamily.includes(quality)) {
      first = shapeCompactSus4(s);
    } else if (augFamily.includes(quality)) {
      first = shapeCompactAug(s);
    } else if (dimFamily.includes(quality)) {
      first = shapeCompactDim(s);
    } else {
      first = shapeCompactMajor(s); // Default fallback
    }
    first.id = `compact-${root}-${quality}`;
  }

  // For second shape, prefer E-form barre variants
  let second: ChordShape;
  const majorFamilyE = ['M', 'add9'];
  const sixthFamilyE = ['6', '6/9'];
  const minorFamilyE = ['m'];
  const minorSixthFamilyE = ['m6'];
  const majSevenFamilyE = ['M7', 'M9'];
  const domSevenFamilyE = ['7', '9', '7b9', '7#9', '7b5', '7#5', '11', '13'];
  const minorSevenFamilyE = ['m7', 'm9'];
  const susFamilyE = ['sus2', 'sus4', '7sus4'];
  const augFamilyE = ['aug'];
  const dimFamilyE = ['dim', 'dim7', 'm7b5'];
  
  if (majorFamilyE.includes(quality)) {
    second = shapeE_Major(r);
  } else if (sixthFamilyE.includes(quality)) {
    second = shapeE_6th(r);
  } else if (minorFamilyE.includes(quality)) {
    second = shapeE_Minor(r);
  } else if (minorSixthFamilyE.includes(quality)) {
    second = shapeE_Minor(r); // Use minor shape for m6 (no dedicated E-shape m6)
  } else if (domSevenFamilyE.includes(quality)) {
    second = shapeE_Dom7(r);
  } else if (minorSevenFamilyE.includes(quality)) {
    second = shapeE_Minor7(r);
  } else if (majSevenFamilyE.includes(quality)) {
    second = shapeE_Maj7(r);
  } else if (susFamilyE.includes(quality)) {
    second = shapeE_Sus4(r);
  } else if (augFamilyE.includes(quality)) {
    second = shapeE_Aug(r);
  } else if (dimFamilyE.includes(quality)) {
    second = shapeE_Dim(r);
  } else {
    // Default fallback
    second = shapeE_Major(r);
    second.label = `Barre (E-shape, ${quality})`;
  }
  second.id = `e-${root}-${quality}`;

  // For third shape, prefer A-form barre variants
  let third: ChordShape;
  const majorFamilyA = ['M', 'add9'];
  const sixthFamilyA = ['6', '6/9'];
  const minorFamilyA = ['m'];
  const minorSixthFamilyA = ['m6'];
  const majSevenFamilyA = ['M7', 'M9'];
  const domSevenFamilyA = ['7', '9', '7b9', '7#9', '7b5', '7#5', '11', '13'];
  const minorSevenFamilyA = ['m7', 'm9'];
  const susFamilyA = ['sus2', 'sus4', '7sus4'];
  const augFamilyA = ['aug'];
  const dimFamilyA = ['dim', 'dim7', 'm7b5'];
  
  if (majorFamilyA.includes(quality)) {
    third = shapeA_Major(s);
  } else if (sixthFamilyA.includes(quality)) {
    third = shapeA_6th(s);
  } else if (minorFamilyA.includes(quality)) {
    third = shapeA_Minor(s);
  } else if (minorSixthFamilyA.includes(quality)) {
    third = shapeA_Minor6(s);
  } else if (domSevenFamilyA.includes(quality)) {
    third = shapeA_Dom7(s);
  } else if (minorSevenFamilyA.includes(quality)) {
    third = shapeA_Minor7(s);
  } else if (majSevenFamilyA.includes(quality)) {
    third = shapeA_Maj7(s);
  } else if (susFamilyA.includes(quality)) {
    third = shapeA_Sus4(s);
  } else if (augFamilyA.includes(quality)) {
    third = shapeA_Aug(s);
  } else if (dimFamilyA.includes(quality)) {
    third = shapeA_Dim(s);
  } else {
    // Default fallback
    third = shapeA_Major(s);
    third.label = `Barre (A-shape, ${quality})`;
  }
  third.id = `a-${root}-${quality}`;

  return { symbol, display, shapes:[first, second, third] as [ChordShape,ChordShape,ChordShape] };
}

const CHORD_CACHE = new Map<string, ChordEntry>();
export function getCachedChord(root: Root, quality: Quality | AdvancedQuality): ChordEntry {
  const key = `${root}-${quality}`;
  let hit = CHORD_CACHE.get(key);
  if (!hit) {
    hit = generateChord(root, quality);
    CHORD_CACHE.set(key, hit);
  }
  return hit;
}

// Roots in ♭-preferred notation (matching real-world usage)
export const ROOTS: Root[] = ['C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B'];

// Core practical qualities (18 types) - optimized for guitarists
export const QUALITIES: Quality[] = [
  'M', 'm', 'aug', 'dim',  // Basic triads (4)
  'sus2', 'sus4',  // Suspended (2)
  '6', 'm6',  // Sixth chords (2)
  '7', 'M7', 'm7',  // Essential sevenths (3)
  'dim7', 'm7b5',  // Diminished sevenths (2)
  '9', 'M9', 'm9',  // Ninths (3)
  'add9', '6/9', '7sus4'  // Added notes & suspensions (3)
];

// Advanced qualities (6 types) - for experienced players
export const ADVANCED_QUALITIES: AdvancedQuality[] = [
  '7b9', '7#9',  // Altered ninths (2)
  '7b5', '7#5',  // Altered fifths (2)
  '11', '13'  // Upper extensions (2)
];

// Combined list for compatibility
export const ALL_QUALITIES: (Quality | AdvancedQuality)[] = [
  ...QUALITIES,
  ...ADVANCED_QUALITIES
];


