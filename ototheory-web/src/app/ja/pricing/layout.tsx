import type { Metadata } from "next";

export const metadata: Metadata = {
  alternates: {
    canonical: "/ja/pricing",
    languages: { en: "/pricing", "ja-JP": "/ja/pricing", "x-default": "/pricing" },
  },
  openGraph: { locale: "ja_JP" },
};

export default function Layout({ children }: { children: React.ReactNode }) {
  return children;
}


