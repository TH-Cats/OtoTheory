import type { Metadata } from "next";
import { BreadcrumbStructuredData, SoftwareApplicationStructuredData } from "@/components/StructuredData";

export const metadata: Metadata = {
  alternates: {
    canonical: "/ja/find-chords",
    languages: { en: "/find-chords", "ja-JP": "/ja/find-chords", "x-default": "/find-chords" },
  },
  openGraph: { locale: "ja_JP" },
};

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <BreadcrumbStructuredData
        lang="ja"
        items={[
          { name: "Home", url: "https://www.ototheory.com/ja" },
          { name: "Find Chords", url: "https://www.ototheory.com/ja/find-chords" },
        ]}
      />
      <SoftwareApplicationStructuredData
        name="Find Chords by Key & Scale"
        description="Discover all diatonic chords for any key and scale"
        category="Music"
        lang="ja"
      />
      {children}
    </>
  );
}


