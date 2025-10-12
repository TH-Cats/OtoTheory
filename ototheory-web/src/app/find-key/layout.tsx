import type { Metadata } from "next";
import { BreadcrumbStructuredData, SoftwareApplicationStructuredData } from "@/components/StructuredData";

export const metadata: Metadata = {
  title: "Chord Progression Builder & Key Analyzer – OtoTheory",
  description: "Build chord progressions and instantly analyze the key. See Roman numeral analysis, diatonic chords, and discover perfect chord sequences.",
  keywords: ["chord progression", "chord builder", "key analyzer", "roman numerals", "diatonic chords", "scales"],
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
  return (
    <>
      <BreadcrumbStructuredData 
        items={[
          { name: "Home", url: "https://www.ototheory.com" },
          { name: "Chord Progression", url: "https://www.ototheory.com/find-key" }
        ]}
      />
      <SoftwareApplicationStructuredData
        name="Chord Progression Builder & Key Analyzer"
        description="Build chord progressions and instantly analyze the key"
        category="Music"
      />
      {children}
    </>
  );
}

