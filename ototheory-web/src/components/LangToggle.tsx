"use client";
import { usePathname } from "next/navigation";
import Link from "next/link";
import { useLocale } from "@/contexts/LocaleContext";

export default function LangToggle() {
  const pathname = usePathname() || "/";
  const { isJapanese } = useLocale();
  const target = isJapanese
    ? pathname.replace(/^\/ja(\/|$)/, "/")
    : `/ja${pathname === "/" ? "" : pathname}`;
  return (
    <Link
      href={target}
      aria-label={isJapanese ? "Switch to English" : "日本語に切り替え"}
      className="inline-flex items-center justify-center px-2 py-1 text-xs rounded border border-black/10 dark:border-white/10 hover:bg-black/5 dark:hover:bg-white/5"
    >
      {isJapanese ? "EN" : "JA"}
    </Link>
  );
}



