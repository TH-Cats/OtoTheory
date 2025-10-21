"use client";
import React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useLocale } from "@/contexts/LocaleContext";

export default function FooterNav() {
  const pathname = usePathname() || "/";
  const { isJapanese } = useLocale();
  const base = isJapanese ? '/ja' : '';
  const items = [
    { href: `${base}/about`, label: 'About' },
    { href: `${base}/privacy`, label: 'Privacy' },
    { href: `${base}/terms`, label: 'Terms' },
    { href: `${base}/faq`, label: 'FAQ' },
    { href: `${base}/support`, label: 'Support' },
  ];
  return (
    <nav className="flex items-center justify-center gap-3 flex-wrap">
      {items.map((it, i) => (
        <React.Fragment key={it.href}>
          <Link href={it.href} className="hover:underline">{it.label}</Link>
          {i < items.length - 1 ? <span>•</span> : null}
        </React.Fragment>
      ))}
    </nav>
  );
}



