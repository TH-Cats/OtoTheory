"use client";
import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";
import Nav from "@/components/Nav";
import MobileNav from "@/components/MobileNav";
import HeaderCta from "@/components/HeaderCta.client";
import LangToggle from "@/components/LangToggle";

export default function Header() {
  const pathname = usePathname();
  const isJa = pathname?.startsWith('/ja');
  const homeHref = isJa ? '/ja' : '/';

  return (
    <header className="border-b border-black/10 dark:border-white/10">
      <div className="container flex items-center justify-between h-16 sm:h-20 md:h-24">
        <Link href={homeHref} className="flex items-center gap-2 flex-shrink-0">
          {/* Light mode logo - hidden in dark mode */}
          <Image 
            src="/logo/logo-horizontal-light.png" 
            alt="OtoTheory" 
            width={280} 
            height={84}
            className="h-12 sm:h-16 md:h-20 w-auto dark:hidden max-w-[200px] sm:max-w-[240px] md:max-w-none"
            priority
          />
          {/* Dark mode logo - hidden in light mode */}
          <Image 
            src="/logo/logo-horizontal.png" 
            alt="OtoTheory" 
            width={280} 
            height={84}
            className="h-12 sm:h-16 md:h-20 w-auto hidden dark:block max-w-[200px] sm:max-w-[240px] md:max-w-none"
            priority
          />
        </Link>
        <div className="flex items-center gap-2 sm:gap-4">
          <Nav />
          <MobileNav />
          <HeaderCta />
          <LangToggle />
        </div>
      </div>
    </header>
  );
}
