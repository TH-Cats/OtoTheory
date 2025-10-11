import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Guitar Resources – Theory, Glossary & Chord Library | OtoTheory",
  description: "Comprehensive guitar resources: music theory guide, terminology glossary, and chord library. Learn theory by numbers with practical recipes and quick reference tools.",
  keywords: ["guitar resources", "music theory", "guitar glossary", "chord library", "guitar theory guide", "music terms", "guitar reference"],
  openGraph: {
    title: "Guitar Resources – Theory, Glossary & Chord Library",
    description: "Complete guitar resources hub with theory, terminology, and chord references.",
  },
};

export default function ResourcesLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}

