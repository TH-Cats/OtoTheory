export type BaseKind = "major" | "minor" | "dominant" | "diminished" | "augmented" | "unknown";

export const getBaseKind = (q: string): BaseKind => {
  if (q.startsWith("M") || q === "M") return "major";
  if (q.startsWith("m")) return "minor";
  if (q === "7" || /^7/.test(q) || ["9","11","13"].includes(q)) return "dominant";
  if (q.startsWith("dim") || q === "m7b5") return "diminished";
  if (q === "aug") return "augmented";
  return "unknown";
};

export const preferredBase = (candidate: string): BaseKind | "any" => {
  if (["M9","M11","M13","6"].includes(candidate)) return "major";
  if (["m6","m9"].includes(candidate)) return "minor";
  if (["7b5","7#5","7b9","7#9","7#11","7b13","7alt","9","11","13"].includes(candidate)) return "dominant";
  if (["dim7","m7b5"].includes(candidate)) return "diminished";
  if (["add9","add11","add13","sus2","6/9"].includes(candidate)) return "any";
  if (candidate === "aug" || candidate === "mM7") return "any";
  return "any";
};

export const isCompatible = (currentBase: BaseKind, candidate: string): boolean => {
  const pref = preferredBase(candidate);
  if (pref === "any") return true;
  if (currentBase === "unknown") return true;
  if (currentBase === "major" && pref === "minor") return false;
  if (currentBase === "minor" && pref === "major") return false;
  if (currentBase !== "dominant" && ["7b5","7#5","7b9","7#9","7#11","7b13","7alt","9","11","13"].includes(candidate)) {
    return false;
  }
  if (currentBase !== "diminished" && ["dim7","m7b5"].includes(candidate)) return false;
  return true;
};



