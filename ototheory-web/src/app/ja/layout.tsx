import type { Metadata } from "next";
import { Noto_Sans_JP } from "next/font/google";

const noto = Noto_Sans_JP({ subsets: ["latin"], weight: ["400","500","700"] });

export const metadata: Metadata = {
  alternates: {
    languages: { en: "/", "ja-JP": "/ja", "x-default": "/" },
  },
  openGraph: { locale: "ja_JP" },
};

export default function JaLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className={noto.className}>{children}</div>
  );
}


