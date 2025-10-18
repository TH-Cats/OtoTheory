"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { messages, type Locale } from "@/lib/i18n/messages";

export default function Nav() {
  const pathname = usePathname();
  // M3.5: Analyze (録音) メニュー撤去
  const isJa = pathname?.startsWith('/ja');
  const base = isJa ? '/ja' : '';
  const locale: Locale = isJa ? 'ja' : 'en';
  const t = messages[locale];
  const links = [
    { href: `${base}/chord-progression`, label: t.nav.chordProgression, aria: "Build Chord Progressions" },
    { href: `${base}/find-chords`, label: t.nav.findChords, aria: "Find Chord" },
    { href: `${base}/chord-library`, label: t.nav.chordLibrary, aria: "Chord Library" },
    { href: `${base}/resources`, label: t.nav.resources, aria: "Resources" },
  ];
  const isActive = (href: string) => pathname?.startsWith(href);

  return (
    <nav className="flex text-sm ml-6 sm:ml-14 md:ml-20 gap-5 sm:gap-10">
      {links.map((l) => (
        <div key={l.href} className="relative">
          <Link prefetch href={l.href} aria-label={l.aria} className="hover:underline whitespace-pre md:whitespace-nowrap">
            {l.href === `${base}/chord-progression` ? (
              <>
                <span className="block leading-none md:inline">{isJa ? 'コード' : 'Chord'} </span>
                <span className="block leading-tight md:inline">{isJa ? '進行' : 'Progression'}</span>
              </>
            ) : l.href === `${base}/find-chords` ? (
              <>
                <span className="block leading-none md:inline">{isJa ? 'コードを' : 'Find '}</span>
                <span className="block leading-tight md:inline">{isJa ? '探す' : 'Chords'}</span>
              </>
            ) : l.href === `${base}/chord-library` ? (
              <>
                <span className="block leading-none md:inline">{isJa ? 'コード' : 'Chord '}</span>
                <span className="block leading-tight md:inline">{isJa ? '辞典' : 'Library'}</span>
              </>
            ) : (
              l.label
            )}
          </Link>
          {isActive(l.href) ? (
            <span className="absolute left-1/2 -translate-x-1/2 -bottom-2 w-1.5 h-1.5 rounded-full bg-[var(--brand-primary)]" />
          ) : null}
        </div>
      ))}
    </nav>
  );
}



