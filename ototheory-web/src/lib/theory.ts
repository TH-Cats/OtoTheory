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

// Quality aliases: シンボルの表記ゆれを正規化キーへ統一
export const QUALITY_ALIASES: Record<string, string> = {
  // Major family
  'maj': 'M', 'major': 'M', '': 'M',
  'maj7': 'M7', 'M7': 'M7', 'Δ': 'M7', 'Δ7': 'M7',
  'maj9': 'M9', 'M9': 'M9', 'Δ9': 'M9',
  'maj11': 'M11', 'M11': 'M11',
  'maj13': 'M13', 'M13': 'M13',
  // Minor family
  'min': 'm', 'mi': 'm', '-': 'm',
  'min7': 'm7', 'mi7': 'm7', '-7': 'm7',
  'min9': 'm9', 'mi9': 'm9',
  'min11': 'm11', 'mi11': 'm11',
  'min13': 'm13', 'mi13': 'm13',
  'mM7': 'mMaj7', 'mMaj7': 'mMaj7', 'minMaj7': 'mMaj7',
  // Diminished family
  'dim': 'dim', '°': 'dim', 'o': 'dim',
  'dim7': 'dim7', '°7': 'dim7', 'o7': 'dim7',
  'm7b5': 'm7b5', 'm7♭5': 'm7b5', 'ø': 'm7b5', 'ø7': 'm7b5',
  // Augmented family
  'aug': 'aug', '+': 'aug',
  'aug7': '7#5', '7#5': '7#5', '7+5': '7#5', '7♯5': '7#5',
  // Suspended
  'sus2': 'sus2', 'sus4': 'sus4', 'sus': 'sus4',
  '7sus4': '7sus4', '7sus': '7sus4',
  // Sixth chords
  '6': '6', 'm6': 'm6', 'min6': 'm6',
  '6/9': '6/9', '69': '6/9',
  // Altered/extensions
  '7b5': '7b5', '7♭5': '7b5', '7-5': '7b5',
  '7b9': '7b9', '7♭9': '7b9', '7-9': '7b9',
  '7#9': '7#9', '7♯9': '7#9', '7+9': '7#9',
  '7b13': '7b13', '7♭13': '7b13',
  '7#11': '7#11', '7♯11': '7#11',
  '7(9)': '9', '7(11)': '11', '7(13)': '13', // 統一: 7(9)→9
  'm7(9)': 'm9', 'm7(11)': 'm11',
  'M7(9)': 'M9', 'M7(13)': 'M13',
  '7alt': '7alt', '7altered': '7alt',
} as const;

// Quality resolver: QUALITY_ALIASESを通して正規化
export function resolveQuality(qual: string): string {
  return QUALITY_ALIASES[qual] ?? qual;
}

// QUALITY_TONES: Chord Libraryの全40+品質を網羅
export const QUALITY_TONES: Record<string, number[]> = {
  // Basic triads (Core)
  M:     [0,4,7],
  m:     [0,3,7],
  aug:   [0,4,8],
  dim:   [0,3,6],
  // Suspended (Core)
  sus2:  [0,2,7],
  sus4:  [0,5,7],
  // Sixth chords (Core)
  "6":   [0,4,7,9],
  m6:    [0,3,7,9],
  "6/9": [0,4,7,9,14], // 6/9 = R,3,5,6,9
  // Seventh chords (Core)
  "7":   [0,4,7,10],   // Dominant 7th
  M7:    [0,4,7,11],   // Major 7th
  m7:    [0,3,7,10],   // Minor 7th
  dim7:  [0,3,6,9],    // Diminished 7th (修正: [0,3,6,10]→[0,3,6,9])
  m7b5:  [0,3,6,10],   // Half-diminished 7th
  mMaj7: [0,3,7,11],   // Minor-major 7th
  // Ninth chords (Core)
  "9":   [0,4,7,10,14],  // Dominant 9th
  M9:    [0,4,7,11,14],  // Major 9th
  m9:    [0,3,7,10,14],  // Minor 9th
  add9:  [0,4,7,14],     // Add 9 (no 7th)
  madd9: [0,3,7,14],     // Minor add 9
  // Extended chords (Advanced)
  "11":  [0,4,7,10,14,17], // 11th (理論上は3rdを省略すべきだが、音度表示は完全形)
  M11:   [0,4,7,11,14,17], // Major 11th (実務上は#11が一般的だが、ここは理論形)
  m11:   [0,3,7,10,14,17], // Minor 11th
  "13":  [0,4,7,10,14,21], // 13th (理論上は11thを省略すべき)
  M13:   [0,4,7,11,14,21], // Major 13th
  m13:   [0,3,7,10,14,21], // Minor 13th
  // Altered/Sus7 (Core & Advanced)
  "7sus4": [0,5,7,10],     // Dominant 7 sus4
  "7b5":   [0,4,6,10],     // Dominant 7 flat 5
  "7#5":   [0,4,8,10],     // Dominant 7 sharp 5 (aug7)
  "7b9":   [0,4,7,10,13],  // Dominant 7 flat 9
  "7#9":   [0,4,7,10,15],  // Dominant 7 sharp 9
  "7#11":  [0,4,7,10,18],  // Dominant 7 sharp 11 (Lydian dominant)
  "7b13":  [0,4,7,10,20],  // Dominant 7 flat 13
  "7alt":  [0,4,7,10,13,15,18,20], // Altered (上限集合: ♭9,#9,#11,♭13)
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
  const rawQual = (m[3] || "").trim() || "";
  const qual = resolveQuality(rawQual || "M"); // エイリアス正規化を通す
  const tonesRel = QUALITY_TONES[qual] ?? QUALITY_TONES.M;
  const tones = tonesRel.map(iv => transpose(root, iv % 12)); // mod12で正規化
  const bass = slash[1] ? noteToPc(slash[1]!) : undefined;
  return { root, qual, bass, tones };
}

// Diatonic quality tables: 各度数に対する典型的な品質（第1候補が既定）
export const DEG_QUAL_MAJOR: Record<number, string[]> = {
  0:["M","M7"], 2:["m","m7"], 4:["m","m7"], 5:["M","M7"], 7:["M","7"], 9:["m","m7"], 11:["dim","m7b5"],
};
export const DEG_QUAL_MINOR: Record<number, string[]> = {
  0:["m","m7"], 2:["dim","m7b5"], 3:["M","M7"], 5:["m","m7"],
  7:["m","7","M","7"], // v と V の両方を許容
  8:["M","M7"], 10:["M","7"],
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
        // 五度下行（循環）を一般的に評価: a→b が完全5度下行（-7半音＝+5半音）
        const fifthsDown = ((prevDeg - deg + 12) % 12) === 7;
        if (fifthsDown) s += 1; // 五度下行ボーナス（ii→V, V→I, vi→ii, etc.）
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

// --- Roman Numeral to Chord Symbol Conversion ---

// Roman numeral mapping: Roman表記から度数（0-11）と明示的品質を解析
const ROMAN_MAP: Record<string, {offset: number}> = {
  'Ⅰ': {offset: 0}, 'ⅰ': {offset: 0},
  'Ⅱ': {offset: 2}, 'ⅱ': {offset: 2},
  '♭Ⅱ': {offset: 1}, '♭ⅱ': {offset: 1},
  'Ⅲ': {offset: 4}, 'ⅲ': {offset: 4},
  '♭Ⅲ': {offset: 3}, '♭ⅲ': {offset: 3},
  'Ⅳ': {offset: 5}, 'ⅳ': {offset: 5},
  '♯Ⅳ': {offset: 6}, '♯ⅳ': {offset: 6},
  'Ⅴ': {offset: 7}, 'ⅴ': {offset: 7},
  '♭Ⅵ': {offset: 8}, '♭ⅵ': {offset: 8},
  'Ⅵ': {offset: 9}, 'ⅵ': {offset: 9},
  '♭Ⅶ': {offset: 10}, '♭ⅶ': {offset: 10},
  'Ⅶ': {offset: 11}, 'ⅶ': {offset: 11},
};

/**
 * parseRomanNumeral: Roman numeral表記から度数と明示的品質を分離
 * 例: "Ⅱm7" → {deg: 2, explicitQual: "m7"}
 *     "Ⅴ" → {deg: 7, explicitQual: null}
 *     "♭Ⅶ" → {deg: 10, explicitQual: null}
 */
function parseRomanNumeral(roman: string): {deg: number; explicitQual: string | null} {
  // Roman表記の本体と接尾辞を分離
  // 例: "Ⅱm7" → base="Ⅱ", suffix="m7"
  let base = roman;
  let suffix = "";
  
  // Roman表記のパターンをチェック
  for (const [romanKey, {offset}] of Object.entries(ROMAN_MAP)) {
    if (roman.startsWith(romanKey)) {
      base = romanKey;
      suffix = roman.slice(romanKey.length).trim();
      return {deg: offset, explicitQual: suffix || null};
    }
  }
  
  // マッチしない場合はエラー（または警告）
  console.warn(`Unknown Roman numeral: ${roman}`);
  return {deg: 0, explicitQual: null}; // デフォルトは I（tonic）
}

/**
 * defaultQualityForDegree: 度数とモードに基づいてダイアトニック品質を返す
 * 例: Major key の deg=2 → "m"（ii）
 *     Major key の deg=11 → "dim"（vii°）
 */
function defaultQualityForDegree(deg: number, mode: Mode): string {
  const table = mode === "Major" ? DEG_QUAL_MAJOR : DEG_QUAL_MINOR;
  const candidates = table[deg];
  if (!candidates || candidates.length === 0) {
    // ダイアトニックにない度数（借用和音など）は空（Major triad）をデフォルトに
    return "";
  }
  // 第1候補（三和音）を返す
  return candidates[0];
}

/**
 * romanToChordSymbol: Roman numeral → 実コードシンボル変換（文脈化版）
 * @param roman - Roman numeral表記（例: "Ⅱm7", "♭Ⅶ", "Ⅴ7"）
 * @param keyRoot - キーのルート（Pc: 0-11）
 * @param mode - Major or Minor
 * @returns コードシンボル（例: "Dm7", "Bb", "G7"）
 */
export function romanToChordSymbol(roman: string, keyRoot: Pc, mode: Mode): string {
  const {deg, explicitQual} = parseRomanNumeral(roman);
  
  // 明示的品質がない場合、ダイアトニック品質を補完
  const quality = explicitQual !== null ? explicitQual : defaultQualityForDegree(deg, mode);
  
  // ルート音を計算
  const rootPc = (keyRoot + deg) % 12;
  const rootName = PITCHES_INTERNAL[rootPc];
  
  // コードシンボルを組み立て
  return `${rootName}${quality}`;
}



