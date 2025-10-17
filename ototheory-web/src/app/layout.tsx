import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import Link from "next/link";
import Image from "next/image";
import Nav from "@/components/Nav";
import { ProProvider } from "@/components/ProProvider";
import AudioUnlocker from "./AudioUnlocker.client";
import MobileStickyCta from "@/components/MobileStickyCta.client";
import HeaderCta from "@/components/HeaderCta.client";
import FooterCta from "@/components/FooterCta.client";
import GoogleAnalytics from "@/components/GoogleAnalytics";
import { GoogleTagManagerHead, GoogleTagManagerBody } from "@/components/GoogleTagManager";
import Script from "next/script";
import LangToggle from "@/components/LangToggle";
import FooterNav from "@/components/FooterNav.client";
import { HomePageStructuredData, AppStructuredData } from "@/components/StructuredData";

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
  metadataBase: new URL("https://www.ototheory.com"),
  alternates: {
    canonical: "/",
    languages: { en: "/", "ja-JP": "/ja", "x-default": "/" },
  },
  icons: {
    icon: [
      { url: "/favicon.ico", sizes: "any" },
      { url: "/favicon-32x32.png", sizes: "32x32", type: "image/png" },
      { url: "/favicon-16x16.png", sizes: "16x16", type: "image/png" },
    ],
    apple: [
      { url: "/apple-touch-icon.png", sizes: "180x180", type: "image/png" },
    ],
  },
  other: {
    "google-adsense-account": "ca-pub-9662479821167655",
  },
  openGraph: {
    title: "OtoTheory – Guitar Music Theory Made Easy",
    description: "Free guitar chord finder, key analyzer, and music theory tool. Build chord progressions, discover scales, and support composition and guitar improvisation.",
    url: "https://www.ototheory.com",
    siteName: "OtoTheory",
    images: [
      { url: "/og.png", width: 1200, height: 630, alt: "OtoTheory – Guitar Music Theory Made Easy" },
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
          <div className="container flex items-center justify-between h-24">
            <Link href="/" className="flex items-center gap-2">
              {/* Light mode logo - hidden in dark mode */}
              <Image 
                src="/logo/logo-horizontal-light.png" 
                alt="OtoTheory" 
                width={280} 
                height={84}
                className="h-20 w-auto dark:hidden"
                priority
              />
              {/* Dark mode logo - hidden in light mode */}
              <Image 
                src="/logo/logo-horizontal.png" 
                alt="OtoTheory" 
                width={280} 
                height={84}
                className="h-20 w-auto hidden dark:block"
                priority
              />
            </Link>
            <div className="flex items-center gap-4">
              <Nav />
              <HeaderCta />
              <LangToggle />
            </div>
          </div>
        </header>
        <main className="pt-1 pb-4 sm:pt-2 sm:pb-6">
          {children}
        </main>
        <footer className="mt-16 py-8 text-center text-xs text-black/60 dark:text-white/60 border-t border-black/10 dark:border-white/10">
          <div className="container space-y-3">
            <FooterCta />
            <FooterNav />
            <div>© {new Date().getFullYear()} OtoTheory</div>
          </div>
        </footer>

        <GoogleAnalytics />
        <HomePageStructuredData />
        <AppStructuredData />
        </ProProvider>
      </body>
    </html>
  );
}
