import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Chord Progression Builder & Key Analyzer – OtoTheory",
  description: "Build chord progressions and instantly analyze the key. See Roman numeral analysis, diatonic chords, and discover perfect chord sequences.",
  alternates: {
    canonical: "/chord-progression",
  },
  openGraph: {
    title: "Chord Progression Builder & Key Analyzer",
    description: "Build chord progressions and instantly analyze the key. See Roman numeral analysis, diatonic chords, and discover perfect chord sequences.",
  },
};

export default function FindKeyLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}

