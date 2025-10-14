import Link from "next/link";
import { WebApplicationStructuredData, OrganizationStructuredData } from "@/components/StructuredData";

export const metadata = {
  title: "OtoTheory – ギター音楽理論をもっと簡単に",
  description: "無料のギター向け音楽理論ツール。コード進行の作成、キー判定、スケール探索をサポート。",
  alternates: {
    canonical: "/ja",
    languages: { en: "/", "ja-JP": "/ja", "x-default": "/" },
  },
  openGraph: {
    title: "OtoTheory – ギター音楽理論をもっと簡単に",
    description: "無料のギター向け音楽理論ツール。コード進行の作成、キー判定、スケール探索をサポート。",
    url: "https://www.ototheory.com/ja",
    siteName: "OtoTheory",
    images: [
      { url: "/og.png", width: 1200, height: 630, alt: "OtoTheory" },
    ],
    locale: "ja_JP",
    type: "website",
  },
} as const;

export default function HomeJa() {
  return (
    <>
      <WebApplicationStructuredData 
        name="OtoTheory"
        description="無料のギター向け音楽理論ツール。コード進行の作成、キー判定、スケール探索をサポート。"
        url="https://www.ototheory.com/ja"
        lang="ja"
      />
      <OrganizationStructuredData lang="ja" />
      <main className="ot-page ot-stack">
        <section className="ot-card text-white" style={{background: 'linear-gradient(90deg, var(--brand-primary), var(--brand-secondary))'}}>
          <h1 className="text-2xl font-semibold">OtoTheory</h1>
          <p className="opacity-90">涙なしで理論を使う</p>
        </section>
        <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
          <Link href="/ja/chord-progression" className="ot-card hover:bg-black/5 dark:hover:bg-white/5">
            <h2 className="font-semibold mb-1">コード進行ビルダー</h2>
            <p className="text-sm opacity-80">コード進行を作る</p>
          </Link>
          <Link href="/ja/find-chords" className="ot-card hover:bg-black/5 dark:hover:bg-white/5">
            <h2 className="font-semibold mb-1">Find Chords</h2>
            <p className="text-sm opacity-80">キーとスケールからコードを見る</p>
          </Link>
          <Link href="/ja/resources" className="ot-card hover:bg-black/5 dark:hover:bg-white/5">
            <h2 className="font-semibold mb-1">リソース</h2>
            <p className="text-sm opacity-80">理論ガイドと用語集</p>
          </Link>
        </section>
      </main>
    </>
  );
}


