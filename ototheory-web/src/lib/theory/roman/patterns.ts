export type RomanToken = string; // e.g., 'I','vi','IV','V','bVII','vii°'

export type Pattern = {
  id: string;
  name: string;
  mode: 'major' | 'minor' | 'any';
  seq: RomanToken[];
  variants?: RomanToken[][];
  summary: string;
  tags?: string[];
};

export const PATTERNS: Pattern[] = [
  {
    id: 'doo-wop',
    name: 'Doo‑Wop (I–vi–IV–V)',
    mode: 'major',
    seq: ['I','vi','IV','V'],
    summary: "50s/60s loop: I→vi→IV→V back to I.",
  },
  {
    id: 'axis',
    name: 'Axis (I–V–vi–IV)',
    mode: 'major',
    seq: ['I','V','vi','IV'],
    summary: 'Modern pop four‑chords loop.',
  },
  {
    id: 'canon',
    name: "Pachelbel's Canon",
    mode: 'major',
    seq: ['I','V','vi','iii','IV','I','IV','V'],
    variants: [['I','V','vi','IV']],
    summary: 'Pachelbel‑style ground; long loop back to I.',
  },
  {
    id: 'ii-V-I',
    name: 'ii–V–I',
    mode: 'any',
    seq: ['ii','V','I'],
    summary: 'The classic resolution run‑up.',
  },
  {
    id: 'turnaround',
    name: 'Turnaround (I–vi–ii–V)',
    mode: 'any',
    seq: ['I','vi','ii','V'],
    summary: 'Quick loop returning to the top.',
  },
  {
    id: 'andalusian',
    name: 'Andalusian (i–VII–VI–V)',
    mode: 'minor',
    seq: ['i','VII','VI','V'],
    summary: 'Classic minor descent; flamenco/Latin flavor.',
  },
  {
    id: 'authentic',
    name: 'Authentic cadence (V–I)',
    mode: 'any',
    seq: ['V','I'],
    summary: 'Perfect cadence V→I.',
  },
  {
    id: 'plagal',
    name: 'Plagal cadence (IV–I)',
    mode: 'any',
    seq: ['IV','I'],
    summary: 'Gentle IV→I resolution.',
  },
  {
    id: 'deceptive',
    name: 'Deceptive cadence (V–vi)',
    mode: 'major',
    seq: ['V','vi'],
    summary: 'Deceptive V→vi keeps motion going.',
  },
];

// --- English microcopy for pattern tooltips ------------------------------
export type RomanPatternId =
  | "dooWop"
  | "axis"
  | "canon"
  | "twoFiveOne"
  | "turnaround"
  | "andalusian"
  | "authentic"   // perfect V→I
  | "plagal"      // IV→I
  | "deceptive";  // V→vi

export const PATTERN_LABEL_EN: Record<RomanPatternId, string> = {
  dooWop: "Doo‑Wop (I–VI–IV–V)",
  axis: "Axis (I–V–vi–IV)",
  canon: "Canon (I–V–vi–iii–IV–I–IV–V)",
  twoFiveOne: "ii–V–I",
  turnaround: "Turnaround",
  andalusian: "Andalusian cadence",
  authentic: "Perfect cadence (V → I)",
  plagal: "Plagal cadence (IV → I)",
  deceptive: "Deceptive cadence (V → vi)",
};

export const PATTERN_SUMMARY_EN: Record<RomanPatternId, string> = {
  dooWop:
    "’50s progression. Nostalgic loop: tonic → relative minor → subdominant → dominant. Try adding 7ths for color.",
  axis:
    "Modern pop staple. A catchy loop that feels forward yet stable. Swap to ii–V at the end for a stronger landing.",
  canon:
    "Pachelbel‑style ground. Persistent bass motion with rotating functions; great for variations and melodies.",
  twoFiveOne:
    "The classic run‑up then land. Link by guide tones (3rd↔7th). Works anywhere you want a clear resolution.",
  turnaround:
    "Short cycle that brings you back to the top (e.g., I–VI7–ii7–V7). Use at phrase ends or between sections.",
  andalusian:
    "Descending minor flavor (e.g., i–♭VII–♭VI–V). Adds drama; land clearly on the target chord.",
  authentic:
    "Strong homecoming: dominant pulls into tonic. Extend V with 7/9/13; keep the landing clean on I.",
  plagal:
    "Gentler IV → I resolution. Use to soften endings or after a bright Lydian moment.",
  deceptive:
    "Twist the expectation: V → vi instead of I. Keeps energy moving; return to I later for closure.",
};

export function patternInfoEN(id: RomanPatternId) {
  return { label: PATTERN_LABEL_EN[id], summary: PATTERN_SUMMARY_EN[id] };
}

