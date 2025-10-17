export const QUICK_QUALITIES = ["M","m","7","M7","m7","sus4","dim"] as const;

// Advanced categories
export const ADV_EXTENSIONS = [
  "6","m6","9","m9","11","M11","13","M13"
] as const;

export const ADV_ALTERED_DOM = [
  "7b5","7#5","7b9","7#9","7#11","7b13","7alt"
] as const;

export const ADV_DIM_VARIANTS = [
  "dim7","m7b5"
] as const;

export const ADV_SUS_ADDS = [
  "sus2","add9","add11","add13","6/9"
] as const;

export const ADV_AUG_MAJMIN = [
  "aug","mM7"
] as const;

export const ADVANCED_QUALITIES = [
  ...ADV_EXTENSIONS,
  ...ADV_ALTERED_DOM,
  ...ADV_DIM_VARIANTS,
  ...ADV_SUS_ADDS,
  ...ADV_AUG_MAJMIN,
  "/bass",
] as const;

export type Quality = typeof QUICK_QUALITIES[number] | typeof ADVANCED_QUALITIES[number];

export const isAdvanced = (q: string): boolean => (ADVANCED_QUALITIES as readonly string[]).includes(q);
export const isQuick = (q: string): boolean => (QUICK_QUALITIES as readonly string[]).includes(q);

export const BASS_NOTES = ["C","C#","D","Eb","E","F","F#","G","Ab","A","Bb","B"] as const;
export type BassNote = typeof BASS_NOTES[number];


