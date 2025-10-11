import { Key } from "tonal";
// PITCHESは lib/music/constants.ts に移行しました
export { PC_NAMES as PITCHES, PC_NAMES } from './music/constants';
// 内部で使用するためにインポート
import { PC_NAMES as PITCHES_INTERNAL } from './music/constants';
export type Pc = number; // 0..11
export type Mode = "Major" | "Minor";

export const SCALESETS = {
  ionian:     [0,2,4,5,7,9,11],
  dorian:     [0,2,3,5,7,9,10],
  phrygian:   [0,1,3,5,7,8,10],
  lydian:     [0,2,4,6,7,9,11],
  mixolydian: [0,2,4,5,7,9,10],
  aeolian:    [0,2,3,5,7,8,10],
  locrian:    [0,1,3,5,6,8,10],
  majPent:    [0,2,4,7,9],
  minPent:    [0,3,5,7,10],
  bluesMin:   [0,3,5,6,7,10],
} as const;

export const QUALITY_TONES: Record<string, number[]> = {
  M:   [0,4,7],    m: [0,3,7],
  "7": [0,4,7,10], M7:[0,4,7,11], m7:[0,3,7,10],
  sus4:[0,5,7],    dim:[0,3,6],
  add9:[0,4,7,2],  "6":[0,4,7,9], m6:[0,3,7,9],
};

export const noteToPc = (n: string): Pc => {
  const i = PITCHES_INTERNAL.indexOf(n as any);
  if (i >= 0) return i;
  const flatMap: Record<string,string> = {Db:"C#",Gb:"F#",Ab:"G#",Bb:"A#",Eb:"D#",Cb:"B",Fb:"E"};
  const up = flatMap[n] ?? n;
  return PITCHES_INTERNAL.indexOf(up as any) as number;
};

export const transpose = (pc: Pc, by: number) => (pc + by + 12) % 12;

export type ChordSym = string; // e.g. "C", "Am", "G7", "F#m7", "C/E"
export type ParsedChord = { root: Pc; qual: string; bass?: Pc; tones: Pc[] };

export function parseChord(sym: ChordSym): ParsedChord {
  const slash = sym.split("/");
  const main = slash[0];
  const m = main.match(/^([A-G](#|b)?)(.*)$/);
  if (!m) throw new Error("bad chord: "+sym);
  const root = noteToPc(m[1]!);
  const qual = (m[3] || "M").trim() || "M";
  const tonesRel = QUALITY_TONES[qual] ?? QUALITY_TONES.M;
  const tones = tonesRel.map(iv => transpose(root, iv));
  const bass = slash[1] ? noteToPc(slash[1]!) : undefined;
  return { root, qual, bass, tones };
}

const DEG_QUAL_MAJOR: Record<number, string[]> = {
  0:["M","M7"], 2:["m","m7"], 4:["m","m7"], 5:["M","M7"], 7:["M","7"], 9:["m","m7"], 11:["dim","m7b5"],
};
const DEG_QUAL_MINOR: Record<number, string[]> = {
  0:["m","m7"], 2:["dim","m7b5"], 3:["M","M7"], 5:["m","m7"],
  7:["m","7","M","7"],
  8:["M","M7"], 10:["M"],
};

type RankItem = { keyRoot: Pc; mode: Mode; label: string; score: number; pct: number };

export function rankKeys(chords: ChordSym[]): RankItem[] {
  const parsed = chords.map(parseChord);
  const candidates: {root:Pc; mode:Mode}[] = [];
  for (let r=0;r<12;r++) candidates.push({root:r,mode:"Major"},{root:r,mode:"Minor"});

  const maxPerChord = 3;
  const bonuses = 3;
  const denom = parsed.length * maxPerChord + bonuses;

  const res = candidates.map(({root,mode})=>{
    const table = mode==="Major" ? DEG_QUAL_MAJOR : DEG_QUAL_MINOR;
    let s = 0;
    parsed.forEach((c,idx)=>{
      const deg = (c.root - root + 12) % 12;
      const expected = table[deg];
      if (expected) {
        if (expected.includes(c.qual)) s += 3; else s += 2;
      } else {
        const scale = mode==="Major" ? SCALESETS.ionian : SCALESETS.aeolian;
        const inScale = c.tones.every(t => scale.includes((t - root + 12)%12));
        if (inScale) s += 1;
      }
      if (idx>0) {
        const prevDeg = (parsed[idx-1].root - root + 12) % 12;
        if ((prevDeg===7 && deg===0) || (prevDeg===2 && deg===7)) s += 1;
      }
    });
    const firstDeg = (parsed[0].root - root + 12) % 12;
    if (mode==="Major" && (firstDeg===0 || firstDeg===9)) s += 2;
    if (mode==="Minor" && (firstDeg===0 || firstDeg===3)) s += 2;
    const pct = Math.round((s / Math.max(denom,1)) * 100);
    const label = `${PITCHES_INTERNAL[root]} ${mode}`;
    return { keyRoot:root, mode, label, score:s, pct };
  });
  return res.sort((a,b)=> b.score - a.score);
}

export type ScaleRank = { keyRoot: Pc; name: string; label: string; pct: number; set: number[] };

export function rankScales(chords: ChordSym[], baseKey: {root:Pc; mode:Mode}): ScaleRank[] {
  const tones = Array.from(new Set(chords.map(parseChord).flatMap(c=>c.tones)));
  const root = baseKey.root;
  const defs = baseKey.mode==="Major"
    ? [["Major Scale","ionian"],["Major Pentatonic","majPent"],["Mixolydian Mode","mixolydian"],["Lydian Mode","lydian"]]
    : [["Minor Scale","aeolian"],["Minor Pentatonic","minPent"],["Dorian Mode","dorian"],["Phrygian Mode","phrygian"],["Blues (min)","bluesMin"]];
  return defs.map(([disp, key])=>{
    const set = SCALESETS[key as keyof typeof SCALESETS].map(iv => transpose(root, iv));
    const cover = tones.filter(t => set.includes(t)).length;
    const pct = Math.round(100 * cover / Math.max(tones.length,1));
    return { keyRoot:root, name: disp as string, label: `${PITCHES_INTERNAL[root]} ${disp}`, pct, set };
  }).sort((a,b)=> b.pct - a.pct);
}


// --- P2-3: Analyzer utilities ---
export type KeyCandidate = { tonic: Pc; mode: Mode; confidence: number; reasons: string[] };

const DEGREE_MAP_MAJOR = {0:"I",2:"II",4:"III",5:"IV",7:"V",9:"VI",11:"VII"} as const;
const DEGREE_MAP_MINOR = {0:"i",2:"ii",3:"III",5:"iv",7:"v",8:"VI",10:"VII"} as const;

export function scoreKeyCandidates(prog: ChordSym[]): KeyCandidate[] {
  const ranked = rankKeys(prog);
  const top = ranked.slice(0,5);  // v3.1: 3→5候補に拡張（iOS UI改善）
  return top.map((r)=>{
    const key = { tonic: r.keyRoot, mode: r.mode } as const;
    const cad = detectCadence(prog, key);
    const reasons: string[] = [];
    if (cad === "perfect") reasons.push("Cadence: V→I");
    if (cad === "deceptive") reasons.push("Cadence: V→vi");
    if (cad === "half") reasons.push("Cadence: …→V");
    reasons.unshift(`diatonic fit ${r.pct}%`);
    return { tonic: r.keyRoot, mode: r.mode, confidence: r.pct, reasons };
  });
}

export function classifyChord(chord: ParsedChord, key: {tonic: Pc; mode: Mode}): "diatonic"|"secondary"|"borrowed"|"outside" {
  const diatonic = ((): string[] => {
    const tonicName = PITCHES_INTERNAL[key.tonic];
    if (key.mode === "Major") {
      const mk = (Key as any)?.majorKey ? (Key as any).majorKey(tonicName) : null;
      return mk?.chords || [];
    } else {
      const nk = (Key as any)?.minorKey ? (Key as any).minorKey(tonicName) : null;
      return nk?.natural?.chords || nk?.chords || [];
    }
  })();
  const target = chord.root + (chord.triad === "maj" ? "" : chord.triad === "min" ? "m" : "dim");
  if (diatonic.includes(target)) return "diatonic";
  // secondary dominant: X7 targeting a diatonic
  const isDomLike = chord.triad === "maj" || chord.isDominantLike;
  if (isDomLike) {
    for (let r=0;r<12;r++){
      const deg = (r - key.tonic + 12) % 12;
      const table = key.mode === "Major" ? DEG_QUAL_MAJOR : DEG_QUAL_MINOR;
      if (table[deg]){
        const fifth = transpose(r, 7 as any);
        if (chord.root === fifth) return "secondary";
      }
    }
  }
  // simple borrowed detection in major: iv, bVII, bVI roots
  if (key.mode === "Major"){
    const deg = (chord.root - key.tonic + 12) % 12;
    if (deg === 5 && chord.triad === "min") return "borrowed"; // iv
    if (deg === 10 || deg === 8) return "borrowed"; // bVII, bVI
  }
  return "outside";
}

export function detectCadence(prog: ChordSym[], key: {tonic: Pc; mode: Mode}): "perfect"|"deceptive"|"half"|null {
  if (prog.length < 2) return null;
  const last = parseChord(prog[prog.length-1]);
  const prev = parseChord(prog[prog.length-2]);
  const degLast = (last.root - key.tonic + 12) % 12;
  const degPrev = (prev.root - key.tonic + 12) % 12;
  if (degPrev === 7 && degLast === 0) return "perfect"; // V→I
  if (degPrev === 7 && (degLast === 9)) return "deceptive"; // V→vi
  if (degLast === 7) return "half"; // …→V
  return null;
}



