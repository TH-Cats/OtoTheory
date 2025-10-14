import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Guitar Music Theory – Learn by Numbers | OtoTheory",
  description: "Complete music theory guide for guitarists. Learn degrees, chord construction, progressions, voicings, and advanced techniques. Each section includes practical 30-second recipes.",
  alternates: {
    canonical: "/resources/music-theory",
    languages: { en: "/resources/music-theory", "ja-JP": "/ja/resources/music-theory", "x-default": "/resources/music-theory" },
  },
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


