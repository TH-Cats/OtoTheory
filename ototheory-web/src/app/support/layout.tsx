import type { Metadata } from "next";
import { BreadcrumbStructuredData } from "@/components/StructuredData";

export const metadata: Metadata = {
  title: "Contact & Support – OtoTheory Help Center",
  description: "Get help with OtoTheory. Contact our support team for questions, feedback, or technical issues. We're here to help!",
  alternates: {
    canonical: "/support",
  },
  openGraph: {
    title: "OtoTheory Support",
    description: "Get help with OtoTheory. Contact our support team for questions, feedback, or technical issues.",
  },
};

export default function SupportLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <BreadcrumbStructuredData 
        items={[
          { name: "Home", url: "https://www.ototheory.com" },
          { name: "Support", url: "https://www.ototheory.com/support" }
        ]}
      />
      {children}
    </>
  );
}


