import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Guitar Chord Reference – 30 Essential Chords with Diagrams",
  description: "Visual reference guide for 30 essential guitar chords. Perfect for beginners and intermediate players. Includes chord diagrams and finger positions.",
  keywords: ["guitar chords", "chord diagrams", "chord reference", "guitar fingering", "chord shapes", "beginner chords"],
  openGraph: {
    title: "Guitar Chord Reference – 30 Essential Chords",
    description: "Visual reference guide for 30 essential guitar chords. Perfect for beginners and intermediate players.",
  },
};

export default function ReferenceLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}

