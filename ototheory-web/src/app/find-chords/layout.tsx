import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Find Chords by Key & Scale – Diatonic Chord Finder",
  description: "Discover all diatonic chords for any key and scale. Perfect tool for guitarists to find the right chords and understand music theory instantly.",
  keywords: ["find chords", "diatonic chords", "chord finder", "guitar chords by key", "music scale chords"],
  openGraph: {
    title: "Find Chords by Key & Scale",
    description: "Discover all diatonic chords for any key and scale. Perfect tool for guitarists to find the right chords and understand music theory instantly.",
  },
};

export default function FindChordsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}

