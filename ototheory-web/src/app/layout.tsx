import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import Link from "next/link";
import Nav from "@/components/Nav";
import { ProProvider } from "@/components/ProProvider";
import AudioUnlocker from "./AudioUnlocker.client";
import MobileStickyCta from "@/components/MobileStickyCta.client";
import HeaderCta from "@/components/HeaderCta.client";
import FooterCta from "@/components/FooterCta.client";
import GoogleAnalytics from "@/components/GoogleAnalytics";
import { GoogleTagManagerHead, GoogleTagManagerBody } from "@/components/GoogleTagManager";
import Script from "next/script";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "OtoTheory – Guitar Music Theory Made Easy",
  description: "Free guitar chord finder, key analyzer, and music theory tool. Build chord progressions, discover scales, and support composition and guitar improvisation theoretically.",
  keywords: ["guitar chords", "chord finder", "music theory", "chord progression", "scales", "composition", "guitar improvisation"],
  metadataBase: new URL("https://www.ototheory.com"),
  openGraph: {
    title: "OtoTheory – Guitar Music Theory Made Easy",
    description: "Free guitar chord finder, key analyzer, and music theory tool. Build chord progressions, discover scales, and support composition and guitar improvisation.",
    url: "https://www.ototheory.com",
    siteName: "OtoTheory",
    images: [
      { url: "/og.png", width: 1200, height: 630, alt: "OtoTheory" },
    ],
    locale: "en_US",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <GoogleTagManagerHead />
      {/* Google AdSense */}
      <Script
        async
        src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-9662479821167655"
        crossOrigin="anonymous"
        strategy="afterInteractive"
      />
      <body className={`${geistSans.variable} ${geistMono.variable} antialiased`}>
        <GoogleTagManagerBody />
        <AudioUnlocker />
        <MobileStickyCta />
        <ProProvider>
        <header className="border-b border-black/10 dark:border-white/10">
          <div className="container flex items-center justify-between h-14">
            <Link href="/" className="font-semibold tracking-tight">OtoTheory</Link>
            <div className="flex items-center gap-4">
              <Nav />
              <HeaderCta />
            </div>
          </div>
        </header>
        <main className="pt-1 pb-4 sm:pt-2 sm:pb-6">
          {children}
        </main>
        <footer className="mt-16 py-8 text-center text-xs text-black/60 dark:text-white/60 border-t border-black/10 dark:border-white/10">
          <div className="container space-y-3">
            <FooterCta />
            <nav className="flex items-center justify-center gap-3 flex-wrap">
              <Link href="/about" className="hover:underline">About</Link>
              <span>•</span>
              <Link href="/privacy" className="hover:underline">Privacy</Link>
              <span>•</span>
              <Link href="/terms" className="hover:underline">Terms</Link>
              <span>•</span>
              <Link href="/faq" className="hover:underline">FAQ</Link>
              <span>•</span>
              <Link href="/support" className="hover:underline">Support</Link>
            </nav>
            <div>© {new Date().getFullYear()} OtoTheory</div>
          </div>
        </footer>

        <GoogleAnalytics />
        </ProProvider>
      </body>
    </html>
  );
}
