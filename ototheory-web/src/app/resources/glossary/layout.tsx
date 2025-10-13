import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Guitar Glossary – Quick Music Theory Terms | OtoTheory",
  description: "Quick reference glossary for guitarists. One-line definitions + guitar-specific notes + examples. Covering scale degrees, chords, progressions, and practical techniques.",
  keywords: ["guitar glossary", "music terms", "scale degrees", "chord terminology", "music theory glossary", "guitar terms", "interval definitions"],
  openGraph: {
    title: "Guitar Glossary – Quick Music Theory Terms",
    description: "Quick reference glossary with guitar-focused definitions and practical examples.",
  },
};

export default function GlossaryLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}


