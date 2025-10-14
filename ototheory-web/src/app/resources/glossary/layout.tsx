import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Guitar Glossary – Quick Music Theory Terms | OtoTheory",
  description: "Quick reference glossary for guitarists. One-line definitions + guitar-specific notes + examples. Covering scale degrees, chords, progressions, and practical techniques.",
  alternates: {
    canonical: "/resources/glossary",
    languages: { en: "/resources/glossary", "ja-JP": "/ja/resources/glossary", "x-default": "/resources/glossary" },
  },
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


