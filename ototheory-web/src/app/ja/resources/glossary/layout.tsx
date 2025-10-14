import type { Metadata } from "next";
import { BreadcrumbStructuredData } from "@/components/StructuredData";

export const metadata: Metadata = {
  alternates: {
    canonical: "/ja/resources/glossary",
    languages: { en: "/resources/glossary", "ja-JP": "/ja/resources/glossary", "x-default": "/resources/glossary" },
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
          { name: "Glossary", url: "https://www.ototheory.com/ja/resources/glossary" },
        ]}
      />
      {children}
    </>
  );
}



