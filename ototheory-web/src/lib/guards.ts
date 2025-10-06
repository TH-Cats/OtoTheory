import { isAdvanced } from "./chords";

export const canUseQuality = (quality: string, isPro: boolean) => {
  if (!isAdvanced(quality)) return true;
  return isPro;
};

export type SimpleChord = { root: string; quality: string; bass?: string | null };
export const stripAdvancedFromProgression = (items: SimpleChord[]) =>
  items.filter((i) => !isAdvanced(i.quality));


