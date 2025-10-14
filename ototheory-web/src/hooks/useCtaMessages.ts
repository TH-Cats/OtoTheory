"use client";
import { usePathname } from "next/navigation";
import { CTA_MESSAGES, type CtaMessages } from "@/lib/constants/cta";
import { CTA_MESSAGES_JA } from "@/lib/constants/cta.ja";

export function useCtaMessages(): CtaMessages {
  const pathname = usePathname() || "/";
  const isJa = pathname.startsWith('/ja');
  return isJa ? (CTA_MESSAGES_JA as unknown as CtaMessages) : CTA_MESSAGES;
}



