import type { Metadata } from "next";
import { BreadcrumbStructuredData } from "@/components/StructuredData";

export const metadata: Metadata = {
  alternates: {
    canonical: "/ja/resources/music-theory",
    languages: { en: "/resources/music-theory", "ja-JP": "/ja/resources/music-theory", "x-default": "/resources/music-theory" },
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
          { name: "Resources", url: "https://www.ototheory.com/ja/resources" },
          { name: "Music Theory", url: "https://www.ototheory.com/ja/resources/music-theory" },
        ]}
      />
      {children}
    </>
  );
}



