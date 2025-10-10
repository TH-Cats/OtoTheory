import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "About OtoTheory – Free Guitar Music Theory Tool",
  description: "Learn about OtoTheory, a free web-based music theory tool designed for guitarists. Discover our mission to make music theory accessible to everyone.",
  keywords: ["about ototheory", "music theory tool", "guitar learning", "free music app"],
  openGraph: {
    title: "About OtoTheory",
    description: "Learn about OtoTheory, a free web-based music theory tool designed for guitarists.",
  },
};

export default function AboutLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}

