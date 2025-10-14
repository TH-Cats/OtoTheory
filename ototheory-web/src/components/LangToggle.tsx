"use client";
import { usePathname } from "next/navigation";
import Link from "next/link";

export default function LangToggle() {
  const pathname = usePathname() || "/";
  const isJa = pathname.startsWith("/ja");
  const target = isJa
    ? pathname.replace(/^\/ja(\/|$)/, "/")
    : `/ja${pathname === "/" ? "" : pathname}`;
  return (
    <Link
      href={target}
      aria-label={isJa ? "Switch to English" : "日本語に切り替え"}
      className="inline-flex items-center justify-center px-2 py-1 text-xs rounded border border-black/10 dark:border-white/10 hover:bg-black/5 dark:hover:bg-white/5"
    >
      {isJa ? "EN" : "JA"}
    </Link>
  );
}


