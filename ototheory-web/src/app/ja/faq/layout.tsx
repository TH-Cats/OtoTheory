import type { Metadata } from "next";
import { BreadcrumbStructuredData, FAQStructuredData } from "@/components/StructuredData";

export const metadata: Metadata = {
  alternates: {
    canonical: "/ja/faq",
    languages: { en: "/faq", "ja-JP": "/ja/faq", "x-default": "/faq" },
  },
  openGraph: { locale: "ja_JP" },
};

const faqs = [
  { question: "解約方法は？", answer: "Apple ID > サブスクリプション > OtoTheory から解約できます。課金期間の終了までは利用可能です。" },
  { question: "アカウント削除は？", answer: "アプリ内の設定 > アカウント削除 から申請できます。クラウドデータは30日以内に完全削除されます。" },
  { question: "データの保持期間は？", answer: "スケッチはアカウント削除まで保持。利用ログ/診断データは90日で削除または匿名化します。" },
];

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <BreadcrumbStructuredData
        lang="ja"
        items={[
          { name: "Home", url: "https://www.ototheory.com/ja" },
          { name: "FAQ", url: "https://www.ototheory.com/ja/faq" },
        ]}
      />
      <FAQStructuredData faqs={faqs} lang="ja" />
      {children}
    </>
  );
}


