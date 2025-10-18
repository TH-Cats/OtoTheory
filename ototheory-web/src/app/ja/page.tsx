import { WebApplicationStructuredData, OrganizationStructuredData } from "@/components/StructuredData";
import AdSlot from "@/components/AdSlot.client";
import FeatureCard from "@/components/FeatureCard";
import { 
  MusicalNoteIcon, 
  MagnifyingGlassIcon, 
  BookOpenIcon, 
  AcademicCapIcon, 
  DocumentTextIcon 
} from "@heroicons/react/24/outline";

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
        <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {/* Top row - 3 cards */}
          <div className="lg:col-span-1">
            <FeatureCard
              href="/ja/chord-progression"
              icon={<MusicalNoteIcon />}
              title="コード進行"
              catchphrase="作るたびに、理論がわかる。"
              description={[
                "コード進行を分析して、より良い展開を見つけよう。",
                "スケールやコードの響きを確かめながら、理論を体で理解。",
                "作曲やギター練習が、音楽理論の学びに変わる。"
              ]}
            />
          </div>
          
          <div className="lg:col-span-1">
            <FeatureCard
              href="/ja/find-chords"
              icon={<MagnifyingGlassIcon />}
              title="コードを探す"
              catchphrase="スケールからコードを見つける。耳で覚える理論。"
              description={[
                "キーとスケールを選ぶと、使えるコードがすぐ見える。",
                "フレットボードと一緒に確認して、音を聴きながら理解。",
                "スケール理論とコード構成を、感覚で覚えられる。"
              ]}
            />
          </div>

          <div className="lg:col-span-1">
            <FeatureCard
              href="/ja/chord-library"
              icon={<BookOpenIcon />}
              title="コード辞典"
              catchphrase="弾いて、見て、わかるコード辞典。"
              description={[
                "メジャー・マイナー・セブンスなど主要コードを網羅。",
                "押さえ方と度数が見えるフォーム図で指の感覚を磨こう。",
                "ギターコードの響きを、視覚と音で学べる。"
              ]}
            />
          </div>

          {/* Bottom row - 2 cards centered */}
          <div className="lg:col-start-2 lg:col-span-1">
            <FeatureCard
              href="/ja/resources"
              icon={<AcademicCapIcon />}
              title="参考"
              catchphrase="理論を、1分で復習できる。"
              description={[
                "ダイアトニック、モード、カデンツなどを図で整理。",
                "音楽理論の要点をすぐ確認できるガイドと用語集。",
                "作曲・編曲のインスピレーションを支える基礎リソース。"
              ]}
            />
          </div>

          <div className="lg:col-span-1">
            <FeatureCard
              href="/ja/chord-progression"
              icon={<DocumentTextIcon />}
              title="My進行"
              catchphrase="思いついた進行を、すぐ形に。"
              description={[
                "作ったコード進行をスケッチとして保存。",
                "Freeは3件までローカル、Proならクラウドで無制限。",
                "開けばすぐループ再生、アイデアを逃さない。"
              ]}
            />
          </div>
        </section>
        <div className="ot-card">
          <AdSlot page="home" format="horizontal" />
        </div>
      </main>
    </>
  );
}


