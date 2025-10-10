import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Contact & Support – OtoTheory Help Center",
  description: "Get help with OtoTheory. Contact our support team for questions, feedback, or technical issues. We're here to help!",
  keywords: ["ototheory support", "contact", "help", "customer service", "technical support"],
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
  return children;
}

