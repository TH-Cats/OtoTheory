import type { Metadata } from "next";

export const metadata: Metadata = {
  alternates: {
    canonical: "/ja/terms",
    languages: { en: "/terms", "ja-JP": "/ja/terms", "x-default": "/terms" },
  },
  openGraph: { locale: "ja_JP" },
};

export default function Layout({ children }: { children: React.ReactNode }) {
  return children;
}


