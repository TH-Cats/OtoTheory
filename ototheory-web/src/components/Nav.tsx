"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Nav() {
  const pathname = usePathname();
  // M3.5: Analyze (録音) メニュー撤去
  const links = [
    { href: "/chord-progression", label: "Chord Progression", aria: "Build Chord Progressions" },
    { href: "/find-chords", label: "Find Chords", aria: "Find Chord" },
    { href: "/resources/chord-library", label: "Chord Library", aria: "Chord Library" },
    { href: "/resources", label: "Resources", aria: "Resources" },
  ];
  const isActive = (href: string) => pathname?.startsWith(href);

  return (
    <nav className="flex text-sm ml-6 sm:ml-14 md:ml-20 gap-5 sm:gap-10">
      {links.map((l) => (
        <div key={l.href} className="relative">
          <Link prefetch href={l.href} aria-label={l.aria} className="hover:underline whitespace-pre md:whitespace-nowrap">
            {l.href === '/chord-progression' ? (
              <>
                <span className="block leading-none md:inline">Chord </span>
                <span className="block leading-tight md:inline">Progression</span>
              </>
            ) : l.href === '/find-chords' ? (
              <>
                <span className="block leading-tight md:inline">Find Chords</span>
              </>
            ) : l.href === '/resources/chord-library' ? (
              <>
                <span className="block leading-none md:inline">Chord </span>
                <span className="block leading-tight md:inline">Library</span>
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



