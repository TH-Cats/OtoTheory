import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "FAQ – Frequently Asked Questions | OtoTheory",
  description: "Find answers to common questions about OtoTheory. Learn how to use chord progression builder, find chords, and more.",
  keywords: ["ototheory faq", "how to use", "help", "guitar tool questions"],
  openGraph: {
    title: "OtoTheory FAQ",
    description: "Find answers to common questions about OtoTheory.",
  },
};

export default function FaqLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}

