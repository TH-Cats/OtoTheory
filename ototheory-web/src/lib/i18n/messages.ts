export const messages = {
  en: {
    nav: { findKey: 'Find Key & Scale', findChords: 'Find Chords', reference: 'Chord Reference' },
    actions: { analyze: 'Analyze' },
  },
} as const;

export type Locale = keyof typeof messages;

