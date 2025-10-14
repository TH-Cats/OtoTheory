import type { Metadata } from "next";

export const metadata: Metadata = {
  alternates: {
    canonical: "/ja/resources",
    languages: { en: "/resources", "ja-JP": "/ja/resources", "x-default": "/resources" },
  },
  openGraph: { locale: "ja_JP" },
};

export default function Layout({ children }: { children: React.ReactNode }) {
  return children;
}


