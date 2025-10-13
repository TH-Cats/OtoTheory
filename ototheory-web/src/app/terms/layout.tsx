import type { Metadata } from "next";
import { BreadcrumbStructuredData } from "@/components/StructuredData";

export const metadata: Metadata = {
  title: "Terms of Service – OtoTheory",
  description: "Read OtoTheory's terms of service to understand your rights and responsibilities when using our music theory tool.",
  keywords: ["terms of service", "user agreement", "legal terms", "conditions"],
  alternates: {
    canonical: "/terms",
  },
  openGraph: {
    title: "OtoTheory Terms of Service",
    description: "Read OtoTheory's terms of service to understand your rights and responsibilities when using our music theory tool.",
  },
};

export default function TermsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <BreadcrumbStructuredData 
        items={[
          { name: "Home", url: "https://www.ototheory.com" },
          { name: "Terms of Service", url: "https://www.ototheory.com/terms" }
        ]}
      />
      {children}
    </>
  );
}


