import type { Metadata } from "next";
import { BreadcrumbStructuredData, SoftwareApplicationStructuredData } from "@/components/StructuredData";

export const metadata: Metadata = {
  title: "Find Chords by Key & Scale – Diatonic Chord Finder",
  description: "Discover all diatonic chords for any key and scale. Perfect tool for guitarists to find the right chords and understand music theory instantly.",
  alternates: {
    canonical: "/find-chords",
  },
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
  return (
    <>
      <BreadcrumbStructuredData 
        items={[
          { name: "Home", url: "https://www.ototheory.com" },
          { name: "Find Chords", url: "https://www.ototheory.com/find-chords" }
        ]}
      />
      <SoftwareApplicationStructuredData
        name="Find Chords by Key & Scale"
        description="Discover all diatonic chords for any key and scale"
        category="Music"
      />
      {children}
    </>
  );
}
