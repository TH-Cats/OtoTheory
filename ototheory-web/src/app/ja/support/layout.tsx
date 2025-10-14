import type { Metadata } from "next";

export const metadata: Metadata = {
  alternates: {
    canonical: "/ja/support",
    languages: { en: "/support", "ja-JP": "/ja/support", "x-default": "/support" },
  },
  openGraph: { locale: "ja_JP" },
};

export default function Layout({ children }: { children: React.ReactNode }) {
  return children;
}



