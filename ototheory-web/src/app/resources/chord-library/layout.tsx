import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Guitar Chord Library – Forms & Voicings | OtoTheory",
  description: "Comprehensive guitar chord library with diagrams, voicings, and fingering patterns. Find the perfect chord shape for any progression.",
  alternates: {
    canonical: "/resources/chord-library",
  },
  openGraph: {
    title: "Guitar Chord Library – Forms & Voicings",
    description: "Complete chord library with diagrams and fingering patterns for every situation.",
  },
};

export default function ChordLibraryLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}


