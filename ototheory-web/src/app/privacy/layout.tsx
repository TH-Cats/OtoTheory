import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Privacy Policy – OtoTheory",
  description: "Read OtoTheory's privacy policy to understand how we collect, use, and protect your personal information.",
  keywords: ["privacy policy", "data protection", "user privacy", "terms"],
  openGraph: {
    title: "OtoTheory Privacy Policy",
    description: "Read OtoTheory's privacy policy to understand how we collect, use, and protect your personal information.",
  },
};

export default function PrivacyLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}

