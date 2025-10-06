export type Plan = 'free' | 'pro';
export type NotationStyle = 'english' | 'compact' | 'jazz';

export type Family = 'maj'|'min'|'dom'|'sus'|'dim'|'aug'|'power';
export type Seventh = 'none'|'6'|'maj7'|'7'|'m7'|'m7b5'|'dim7';
export type ExtMode = 'add'|'tension';

export type Extensions = {
  add9?: boolean; add11?: boolean; add13?: boolean;
  nine?: boolean; eleven?: boolean; thirteen?: boolean;
};

export type Alterations = { b9?:boolean; s9?:boolean; s11?:boolean; b13?:boolean; alt?:boolean; };

export type ChordSpec = {
  root: string;
  family: Family;
  seventh: Seventh;
  extMode: ExtMode;
  ext: Extensions;
  alt: Alterations;
  sus?: 'sus2'|'sus4'|null;
  slash?: string|null; // /bass
};

export type ChordContext = {
  plan: Plan;
  notationStyle: NotationStyle; // default: 'english'
};

export const DEFAULT_CONTEXT: ChordContext = { plan: 'free', notationStyle: 'english' };



