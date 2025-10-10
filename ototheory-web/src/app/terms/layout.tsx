import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Terms of Service – OtoTheory",
  description: "Read OtoTheory's terms of service to understand your rights and responsibilities when using our music theory tool.",
  keywords: ["terms of service", "user agreement", "legal terms", "conditions"],
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
  return children;
}

