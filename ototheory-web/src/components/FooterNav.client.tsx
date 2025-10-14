"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function FooterNav() {
  const pathname = usePathname() || "/";
  const isJa = pathname.startsWith('/ja');
  const base = isJa ? '/ja' : '';
  const items = [
    { href: `${base}/about`, label: isJa ? 'About' : 'About' },
    { href: `${base}/privacy`, label: isJa ? 'Privacy' : 'Privacy' },
    { href: `${base}/terms`, label: isJa ? 'Terms' : 'Terms' },
    { href: `${base}/faq`, label: isJa ? 'FAQ' : 'FAQ' },
    { href: `${base}/support`, label: isJa ? 'Support' : 'Support' },
  ];
  return (
    <nav className="flex items-center justify-center gap-3 flex-wrap">
      {items.map((it, i) => (
        <>
          <Link key={it.href} href={it.href} className="hover:underline">{it.label}</Link>
          {i < items.length - 1 ? <span key={`${it.href}-sep`}>•</span> : null}
        </>
      ))}
    </nav>
  );
}



