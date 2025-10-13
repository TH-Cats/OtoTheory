import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Guitar Music Theory – Learn by Numbers | OtoTheory",
  description: "Complete music theory guide for guitarists. Learn degrees, chord construction, progressions, voicings, and advanced techniques. Each section includes practical 30-second recipes.",
  keywords: ["guitar music theory", "scale degrees", "chord theory", "progressions", "voicings", "music theory for guitar", "practical theory", "guitar harmony"],
  openGraph: {
    title: "Guitar Music Theory – Learn by Numbers",
    description: "Complete theory guide with practical recipes for immediate application on guitar.",
  },
};

export default function MusicTheoryLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}


