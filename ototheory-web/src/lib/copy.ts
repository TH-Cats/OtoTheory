export const copy = {
  progression: {
    heading: "Section flow",
    oneLiner:
      "Just enter the first 8 chords of the chorus. Repeats are OK. (Verse works too)",
    example: "e.g. C → G → Am → F → C → G → Am → F",
    tooltip: [
      "• You don’t need the whole song.",
      "• Chorus is recommended, but a verse is fine too.",
      "• Repeated chords help show what’s important.",
    ].join("\n"),
  },
} as const;

// 英語UIに合わせる場合の雛形（未使用）
export const copy_en = {
  progression: {
    heading: "One section of chords",
    oneLiner:
      "Enter the first 8 chords of the chorus. Repeats are fine. (A-verse works too)",
    example: "Ex: C → G → Am → F → C → G → Am → F",
    tooltip: [
      "• You don't need the whole song.",
      "• A-verse only is OK.",
      "• Repeated chords are fine.",
    ].join("\n"),
  },
} as const;


