import { Key, Note, Scale } from "tonal";

export type NoteLetter =
  | "A" | "Bb" | "B" | "C" | "C#" | "Db" | "D" | "Eb" | "E" | "F" | "F#" | "Gb" | "G" | "Ab";

export type KeySignature = { tonic: NoteLetter; quality: "major" | "minor" };
export type KeyCandidate = { key: KeySignature; confidence: number; reasons: string[] };

export type ScaleId =
  | "major" | "naturalMinor" | "majorPent" | "minorPent" | "blues"
  | "dorian" | "mixolydian" | "lydian" | "harmonicMinor" | "melodicMinor";

export type ScaleMeta = { id: ScaleId; name: string; tier: "free" | "pro" };
export type ScaleCandidate = { scale: ScaleMeta; score: number };

export type AnalysisResult = {
  keyCandidates: KeyCandidate[];
  recommendedScales: ScaleCandidate[];
  perSection?: SectionAnalysis[];
};

// Phase E-5: Section-weighted analysis
export type SectionName =
  | "Intro" | "Verse" | "PreChorus" | "Chorus" | "PostChorus"
  | "Bridge" | "Solo" | "Interlude" | "Outro" | "Breakdown" | "Custom";

export interface SectionDef {
  name: SectionName;
  start: number;     // inclusive (0-based index in chords[])
  end: number;       // inclusive
  repeat?: number;   // default 1
  weightMul?: number; // optional override
}

export interface SectionAnalysis {
  section: SectionDef;
  best: KeyCandidate;
  ranking: KeyCandidate[];
}

export interface AnalyzeOpts {
  sections?: SectionDef[];
  weights?: Partial<{
    section: Partial<Record<SectionName, number>>;
    songHead: number; // default 1.2
    songTail: number; // default 1.3
    sectionEdge: number; // default 1.1
  }>;
  cadence?: boolean; // enable cadence detection (future)
}

const ALL_TONICS: NoteLetter[] = [
  "C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B",
];

// Phase E-5: Default section weights (based on musical importance)
const DEFAULT_SECTION_WEIGHTS: Record<SectionName, number> = {
  Intro: 0.8,
  Verse: 1.0,
  PreChorus: 1.2,
  Chorus: 1.6,      // サビは最重要
  PostChorus: 1.3,
  Bridge: 0.9,
  Solo: 1.0,
  Interlude: 0.8,
  Outro: 0.9,
  Breakdown: 0.9,
  Custom: 1.0,
};

const DEFAULT_WEIGHTS = {
  songHead: 1.2,  // 既存の先頭重み
  songTail: 1.3,  // 既存の末尾重み
  sectionEdge: 1.1, // セクション先頭/末尾の補正
};

const SCALE_DEFS: Record<ScaleId, ScaleMeta> = {
  major: { id: "major", name: "Major Scale", tier: "free" },
  naturalMinor: { id: "naturalMinor", name: "Natural Minor Scale", tier: "free" },
  majorPent: { id: "majorPent", name: "Major Pentatonic", tier: "free" },
  minorPent: { id: "minorPent", name: "Minor Pentatonic", tier: "free" },
  blues: { id: "blues", name: "Blues Scale", tier: "free" },
  dorian: { id: "dorian", name: "Dorian Mode", tier: "pro" },
  mixolydian: { id: "mixolydian", name: "Mixolydian Mode", tier: "pro" },
  lydian: { id: "lydian", name: "Lydian Mode", tier: "pro" },
  harmonicMinor: { id: "harmonicMinor", name: "Harmonic Minor", tier: "pro" },
  melodicMinor: { id: "melodicMinor", name: "Melodic Minor", tier: "pro" },
};

type ParsedChord = {
  raw: string;
  root: string; // canonical pitch class, e.g., C, C#, Bb
  triad: "maj" | "min" | "dim";
  isDominantLike: boolean; // contains "7" (for V/V detection)
};

function normalizeNote(input: string): string {
  const n = Note.pitchClass(input);
  return n || input;
}

function parseChordToken(token: string): ParsedChord | null {
  if (!token) return null;
  // Remove bass/slash
  const [head] = token.split("/");
  const m = head.match(/^([A-Ga-g])([#b]?)(.*)$/);
  if (!m) return null;
  const root = normalizeNote((m[1] + m[2]).toUpperCase());
  const rest = (m[3] || "").toLowerCase();
  // Order matters: detect maj before generic m
  let triad: ParsedChord["triad"] = "maj";
  if (/(m7b5|ø|dim)/.test(rest)) triad = "dim";
  else if (/maj/.test(rest)) triad = "maj";
  else if (/(^|[^a-z])m(?!aj)/.test(rest)) triad = "min";
  else if (/sus|aug/.test(rest)) triad = "maj"; // treat as functional major
  else triad = "maj";
  const isDominantLike = /(^|[^a-z])7(?![a-z0-9])/.test(rest) || /7/.test(rest);
  return { raw: token, root, triad, isDominantLike };
}

function getDiatonicChords(key: KeySignature): string[] {
  if (key.quality === "major") {
    const mk = Key.majorKey(key.tonic);
    return mk.chords || [];
  }
  const nk = Key.minorKey(key.tonic);
  return nk.natural?.chords || nk.chords || [];
}

function isDiatonicMatch(chord: ParsedChord, diatonic: string[]): boolean {
  const target = chord.root + (chord.triad === "maj" ? "" : chord.triad === "min" ? "m" : "dim");
  return diatonic.includes(target);
}

function fifth(note: string): string {
  const p = Note.transpose(note, "5P");
  return normalizeNote(p);
}

function flat(note: string): string {
  const p = Note.transpose(note, "-1m");
  return normalizeNote(p);
}

function isSecondaryDominant(chord: ParsedChord, key: KeySignature): boolean {
  // very light-weight V/V detector: major triad (or 7) on degree 2's major? We'll approximate as fifth of fifth
  const v = fifth(key.tonic);
  const vOfV = fifth(v);
  return chord.root === vOfV && (chord.triad === "maj" || chord.isDominantLike);
}

function isSubdominantMinorOrbVII(chord: ParsedChord, key: KeySignature): boolean {
  if (key.quality !== "major") return false;
  const mk = Key.majorKey(key.tonic);
  const scale = mk.scale || [];
  const degree4 = scale[3];
  const degree7 = scale[6];
  const ivMinor = degree4 ? normalizeNote(degree4) : "";
  const bVII = degree7 ? normalizeNote(flat(degree7)) : "";
  const isIvMinor = chord.root === ivMinor && chord.triad === "min";
  const isB7 = chord.root === bVII && chord.triad === "maj";
  return !!(isIvMinor || isB7);
}

function scoreForKey(
  chords: ParsedChord[],
  key: KeySignature,
  weights?: number[]
): { score: number; reasons: string[] } {
  const diatonic = getDiatonicChords(key);
  let reasons: string[] = [];
  
  // Phase E-5: Use provided weights or fall back to legacy position weights
  const W = weights || chords.map((_, i) => (i === 0 ? 1.2 : i === chords.length - 1 ? 1.3 : 1));
  const total = W.reduce((a, b) => a + b, 0);
  
  let acc = 0;
  chords.forEach((ch, i) => {
    const w = W[i];
    if (isDiatonicMatch(ch, diatonic)) {
      acc += w * 1.0; // 100%
    } else if (isSecondaryDominant(ch, key)) {
      acc += w * 0.9; // 85-95%
      reasons.push(`Secondary dominant tolerated: ${ch.raw}`);
    } else if (isSubdominantMinorOrbVII(ch, key)) {
      acc += w * 0.8; // 70-85%
      reasons.push(`Borrowed chord tolerated: ${ch.raw}`);
    } else {
      acc += w * 0.5; // potential modulation or out-of-key
    }
  });
  const confidence = Math.round((acc / total) * 100);
  reasons.unshift(`${diatonic.length} diatonic chords in ${key.tonic} ${key.quality}`);
  return { score: confidence, reasons };
}

function recommendScales(topKey: KeySignature, chords: ParsedChord[]): ScaleCandidate[] {
  const list: ScaleMeta[] = [
    SCALE_DEFS.major,
    SCALE_DEFS.naturalMinor,
    SCALE_DEFS.majorPent,
    SCALE_DEFS.minorPent,
    SCALE_DEFS.blues,
    SCALE_DEFS.dorian,
    SCALE_DEFS.mixolydian,
    SCALE_DEFS.lydian,
    SCALE_DEFS.harmonicMinor,
    SCALE_DEFS.melodicMinor,
  ];
  // Build a set of chord roots to approximate note coverage
  const chordRoots = new Set(chords.map((c) => c.root));
  const keyTonic = topKey.tonic;
  const scaleScores = list.map((sm) => {
    const scaleName =
      sm.id === "major" ? "major" :
      sm.id === "naturalMinor" ? "natural minor" :
      sm.id === "majorPent" ? "major pentatonic" :
      sm.id === "minorPent" ? "minor pentatonic" :
      sm.id === "blues" ? "blues" :
      sm.id === "dorian" ? "dorian" :
      sm.id === "mixolydian" ? "mixolydian" :
      sm.id === "lydian" ? "lydian" :
      sm.id === "harmonicMinor" ? "harmonic minor" :
      "melodic minor";
    const sc = Scale.get(`${keyTonic} ${scaleName}`);
    const noteSet = new Set((sc.notes || []).map(normalizeNote));
    const matches = Array.from(chordRoots).filter((r) => noteSet.has(r)).length;
    const score = matches / Math.max(1, chordRoots.size);
    return { scale: sm, score } as ScaleCandidate;
  });
  scaleScores.sort((a, b) => b.score - a.score);
  return scaleScores.slice(0, 5);
}

// Phase E-5: Compute weights for each chord based on sections
function computeWeights(chordCount: number, opts: AnalyzeOpts): number[] {
  const W = new Array(chordCount).fill(1.0);
  const sections = opts.sections || [];
  
  const sectionWeights = { ...DEFAULT_SECTION_WEIGHTS, ...(opts.weights?.section ?? {}) };
  const songHead = opts.weights?.songHead ?? DEFAULT_WEIGHTS.songHead;
  const songTail = opts.weights?.songTail ?? DEFAULT_WEIGHTS.songTail;
  const sectionEdge = opts.weights?.sectionEdge ?? DEFAULT_WEIGHTS.sectionEdge;
  
  // Apply section weights
  for (const s of sections) {
    const repeat = s.repeat ?? 1;
    const base = (s.weightMul ?? sectionWeights[s.name] ?? 1.0) * Math.sqrt(repeat);
    
    for (let i = s.start; i <= s.end && i < chordCount; i++) {
      W[i] *= base;
    }
    
    // Section edge bonus
    if (s.start < chordCount) W[s.start] *= sectionEdge;
    if (s.end < chordCount) W[s.end] *= sectionEdge;
  }
  
  // Song-level head/tail bonus (legacy compatibility)
  if (chordCount > 0) W[0] *= songHead;
  if (chordCount > 1) W[chordCount - 1] *= songTail;
  
  // Normalize (Σ W = 1)
  const sumW = W.reduce((a, b) => a + b, 0) || 1;
  return W.map(w => w / sumW);
}

export function analyzeChordProgression(
  rawTokens: string[],
  opts: AnalyzeOpts = {}
): AnalysisResult {
  const chords = rawTokens
    .map((t) => t.trim())
    .filter(Boolean)
    .map(parseChordToken)
    .filter((c): c is ParsedChord => !!c);

  // Phase E-5: Compute weights with section awareness
  const weights = computeWeights(chords.length, opts);
  
  const candidates: KeyCandidate[] = [];
  for (const tonic of ALL_TONICS) {
    for (const quality of ["major", "minor"] as const) {
      const { score, reasons } = scoreForKey(
        chords,
        { tonic: tonic as NoteLetter, quality },
        weights
      );
      candidates.push({ key: { tonic: tonic as NoteLetter, quality }, confidence: score, reasons });
    }
  }
  candidates.sort((a, b) => b.confidence - a.confidence);
  const keyCandidates = candidates.slice(0, 5); // v3.1: 3→5候補に拡張（iOS UI改善）
  const recommendedScales = recommendScales(keyCandidates[0].key, chords);
  
  // Phase E-5: Per-section analysis (optional)
  let perSection: SectionAnalysis[] | undefined;
  if (opts.sections && opts.sections.length > 0) {
    perSection = opts.sections.map(sec => {
      const slice = rawTokens.slice(sec.start, Math.min(sec.end + 1, rawTokens.length));
      // Analyze section without section weights (just the chords themselves)
      const local = analyzeChordProgression(slice, {
        weights: {
          songHead: 1.0, // No global position bias for local analysis
          songTail: 1.0,
        }
      });
      return {
        section: sec,
        best: local.keyCandidates[0],
        ranking: local.keyCandidates
      };
    });
  }
  
  return { keyCandidates, recommendedScales, perSection };
}

export type DiatonicRequest = {
  tonic: NoteLetter;
  quality: "major" | "minor";
  scale: "major" | "naturalMinor";
};

export type DiatonicResponse = {
  chords: string[];
};

export function getDiatonicChordsFor(
  req: DiatonicRequest
): DiatonicResponse {
  const key: KeySignature = { tonic: req.tonic, quality: req.quality };
  const chords = getDiatonicChords(key);
  return { chords };
}


