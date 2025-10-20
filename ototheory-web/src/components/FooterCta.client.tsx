"use client";
import Link from 'next/link';
import PhoneIcon from '@/components/ui/PhoneIcon';
import { useCtaMessages } from '@/hooks/useCtaMessages';

/**
 * M3.5: Footer CTA component
 * Displays iOS Coming Soon link in the footer
 */
export default function FooterCta() {
  const CTA_MESSAGES = useCtaMessages();
  return (
    <div className="mb-6 flex flex-col items-center gap-3">
      <div className="text-sm font-medium text-black/80 dark:text-white/80">
        {CTA_MESSAGES.footer.title}
      </div>
      <Link
        href="/ios-coming-soon"
        className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium bg-gradient-to-r from-purple-600 to-blue-600 hover:opacity-90 text-white rounded-lg transition-opacity relative"
      >
        <PhoneIcon />
        <span>{CTA_MESSAGES.footer.button}</span>
        <span className="ml-1 px-2 py-0.5 text-xs font-bold bg-yellow-400 text-black rounded">
          Coming Soon
        </span>
      </Link>
      <div className="text-xs opacity-60">
        {CTA_MESSAGES.footer.features}
      </div>
    </div>
  );
}

