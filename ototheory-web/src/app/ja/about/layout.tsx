import type { Metadata } from "next";
import { BreadcrumbStructuredData } from "@/components/StructuredData";

export const metadata: Metadata = {
  alternates: {
    canonical: "/ja/about",
    languages: { en: "/about", "ja-JP": "/ja/about", "x-default": "/about" },
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
          { name: "About", url: "https://www.ototheory.com/ja/about" },
        ]}
      />
      {children}
    </>
  );
}


