"use client";
import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { messages, type Locale } from "@/lib/i18n/messages";
import { Bars3Icon, XMarkIcon } from "@heroicons/react/24/outline";

export default function MobileNav() {
  const [isOpen, setIsOpen] = useState(false);
  const pathname = usePathname();
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
    <>
      {/* Mobile menu button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="sm:hidden p-2 rounded-md text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-gray-100"
        aria-label="Toggle navigation menu"
      >
        {isOpen ? (
          <XMarkIcon className="h-6 w-6" />
        ) : (
          <Bars3Icon className="h-6 w-6" />
        )}
      </button>

      {/* Mobile menu overlay */}
      {isOpen && (
        <div className="fixed inset-0 z-50 sm:hidden">
          <div className="fixed inset-0 bg-black bg-opacity-50" onClick={() => setIsOpen(false)} />
          <div className="fixed top-0 right-0 h-full w-64 bg-white dark:bg-gray-900 shadow-xl">
            <div className="flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-700">
              <h2 className="text-lg font-semibold text-gray-900 dark:text-white">Menu</h2>
              <button
                onClick={() => setIsOpen(false)}
                className="p-2 rounded-md text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-gray-100"
                aria-label="Close navigation menu"
              >
                <XMarkIcon className="h-6 w-6" />
              </button>
            </div>
            <nav className="p-4 space-y-4">
              {links.map((l) => (
                <Link
                  key={l.href}
                  href={l.href}
                  onClick={() => setIsOpen(false)}
                  className={`block px-3 py-2 rounded-md text-base font-medium transition-colors ${
                    isActive(l.href)
                      ? 'bg-[var(--brand-primary)] text-white'
                      : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'
                  }`}
                  aria-label={l.aria}
                >
                  {l.label}
                </Link>
              ))}
            </nav>
          </div>
        </div>
      )}
    </>
  );
}
