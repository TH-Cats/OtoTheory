import type { Metadata } from "next";
import { BreadcrumbStructuredData } from "@/components/StructuredData";

export const metadata: Metadata = {
  title: "Pricing – OtoTheory Pro Features & iOS App",
  description: "Explore OtoTheory Pro features including MIDI export, unlimited sketches, and section editing. Available on iOS app (coming soon).",
  keywords: ["ototheory pricing", "pro features", "music app subscription", "guitar app ios"],
  openGraph: {
    title: "OtoTheory Pricing – Pro Features",
    description: "Explore OtoTheory Pro features including MIDI export, unlimited sketches, and section editing.",
  },
};

export default function PricingLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <BreadcrumbStructuredData 
        items={[
          { name: "Home", url: "https://www.ototheory.com" },
          { name: "Pricing", url: "https://www.ototheory.com/pricing" }
        ]}
      />
      {children}
    </>
  );
}


