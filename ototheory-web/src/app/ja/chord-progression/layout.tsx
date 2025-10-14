import type { Metadata } from "next";

export const metadata: Metadata = {
  alternates: {
    canonical: "/ja/chord-progression",
    languages: { en: "/chord-progression", "ja-JP": "/ja/chord-progression", "x-default": "/chord-progression" },
  },
  openGraph: { locale: "ja_JP" },
};

export default function Layout({ children }: { children: React.ReactNode }) {
  return children;
}


