"use client";
import Link from 'next/link';
import PhoneIcon from '@/components/ui/PhoneIcon';
import { useCtaMessages } from '@/hooks/useCtaMessages';

/**
 * M3.5: Header CTA component (desktop only)
 * Displays iOS Coming Soon link in the header navigation
 */
export default function HeaderCta() {
  const CTA_MESSAGES = useCtaMessages();
  return (
    <Link
      href="/ios-coming-soon"
      className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium bg-gradient-to-r from-purple-600 to-blue-600 hover:opacity-90 text-white rounded-md transition-opacity relative"
    >
      <PhoneIcon className="w-3.5 h-3.5" />
      <span>{CTA_MESSAGES.header}</span>
      <span className="ml-1 px-1.5 py-0.5 text-[10px] font-bold bg-yellow-400 text-black rounded">
        Soon
      </span>
    </Link>
  );
}

