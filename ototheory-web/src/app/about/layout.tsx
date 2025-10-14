import type { Metadata } from "next";
import { BreadcrumbStructuredData } from "@/components/StructuredData";

export const metadata: Metadata = {
  title: "About OtoTheory – Free Guitar Music Theory Tool",
  description: "Learn about OtoTheory, a free web-based music theory tool designed for guitarists. Discover our mission to make music theory accessible to everyone.",
  alternates: {
    canonical: "/about",
    languages: { en: "/about", "ja-JP": "/ja/about", "x-default": "/about" },
  },
  openGraph: {
    title: "About OtoTheory",
    description: "Learn about OtoTheory, a free web-based music theory tool designed for guitarists.",
  },
};

export default function AboutLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <BreadcrumbStructuredData 
        items={[
          { name: "Home", url: "https://www.ototheory.com" },
          { name: "About", url: "https://www.ototheory.com/about" }
        ]}
      />
      {children}
    </>
  );
}


