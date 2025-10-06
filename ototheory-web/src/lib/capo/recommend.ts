// Capo recommendation utilities
// Heuristic scoring favoring open-string friendly shapes

export type KeySel = { tonic: number; mode: 'major'|'minor'|'Major'|'Minor' };
export type ScaleSel = { type: string; tonic?: number };

export function classifyScaleFlavor(scaleType: string): 'majorish'|'minorish' {
  const maj = ['Major','Ionian','Lydian','Mixolydian','Major Pentatonic'];
  const t = scaleType.toLowerCase();
  for (const s of maj) if (t.includes(s.toLowerCase())) return 'majorish';
  return 'minorish';
}

// Open-chord ease per family (I..VII)
const MAJOR_FAMILY_SCORES: Record<'C'|'G'|'D'|'A'|'E', number[]> = {
  C: [3,3,3,1,3,3,0],
  G: [3,3,1,3,3,3,0],
  D: [3,3,1,3,3,1,0],
  A: [3,1,1,3,2,1,0],
  E: [3,1,0,3,1,1,0],
};

const MINOR_FAMILY_SCORES: Record<'Am'|'Em'|'Dm', number[]> = {
  Am: [3,0,3,3,3,1,3],
  Em: [3,0,3,3,1,3,3],
  Dm: [3,0,1,0,3,0,3],
};

function fretWeight(n: number) {
  if (n <= 5) return 1.0;
  if (n <= 7) return 0.92;
  if (n <= 9) return 0.82;
  return 0.7;
}

export function transposeDown(pc: number, n: number) {
  return ((pc - n) % 12 + 12) % 12;
}

export type CapoPick = {
  capo: number;
  playAs: string;
  score: number;
  reasons: string[];
};

const NATURAL_NAME: Record<number,string> = {
  0:'C',1:'C#',2:'D',3:'Eb',4:'E',5:'F',6:'F#',7:'G',8:'Ab',9:'A',10:'Bb',11:'B'
};

export function recommendCapos(key: KeySel, scale: ScaleSel, topN = 3, opts: { includeOpen?: boolean } = {}): CapoPick[] {
  const includeOpen = opts.includeOpen ?? true;
  const flavor = classifyScaleFlavor(scale.type);
  const picks: CapoPick[] = [];

  for (let n = 0; n <= 11; n++) {
    if (!includeOpen && n === 0) continue;
    const shapedPc = transposeDown(key.tonic, n);
    const name = NATURAL_NAME[shapedPc];
    if (flavor === 'majorish') {
      const famMap: Record<string, keyof typeof MAJOR_FAMILY_SCORES> = { C:'C', G:'G', D:'D', A:'A', E:'E' };
      const fam = famMap[name];
      if (!fam) continue;
      const base = MAJOR_FAMILY_SCORES[fam].reduce((a,b)=>a+b,0);
      const bonus = (MAJOR_FAMILY_SCORES[fam][0] >= 2 && MAJOR_FAMILY_SCORES[fam][3] >= 2 && MAJOR_FAMILY_SCORES[fam][4] >= 2) ? 2 : 0;
      const score = (base + bonus) * fretWeight(n);
      picks.push({ capo: n, playAs: fam, score, reasons: [ `I–IV–V ${bonus? '◎':'○'}`, `open ${base}/16`, n===0? 'open' : `capo ${n}` ]});
    } else {
      const famMap: Record<string, keyof typeof MINOR_FAMILY_SCORES> = { A:'Am', E:'Em', D:'Dm' };
      const fam = famMap[name];
      if (!fam) continue;
      const base = MINOR_FAMILY_SCORES[fam].reduce((a,b)=>a+b,0);
      const bonus = (MINOR_FAMILY_SCORES[fam][0] >= 2 && MINOR_FAMILY_SCORES[fam][3] >= 2) ? 2 : 0;
      const score = (base + bonus) * fretWeight(n);
      picks.push({ capo: n, playAs: fam, score, reasons: [ `i–iv ${bonus? '◎':'○'}`, `open ${base}/16`, n===0? 'open' : `capo ${n}` ]});
    }
  }

  return picks.sort((a,b)=> b.score-a.score).slice(0, topN);
}


