import type { Metadata } from "next";

export const metadata: Metadata = {
  alternates: {
    canonical: "/ja/privacy",
    languages: { en: "/privacy", "ja-JP": "/ja/privacy", "x-default": "/privacy" },
  },
  openGraph: { locale: "ja_JP" },
};

export default function Layout({ children }: { children: React.ReactNode }) {
  return children;
}


