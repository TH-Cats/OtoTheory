"use client";
import AppleIcon from '@/components/ui/AppleIcon';
import { useCtaTracking } from '@/hooks/useCtaTracking';
import { APP_STORE_URL, CTA_MESSAGES } from '@/lib/constants/cta';

/**
 * M3.5: Header CTA component (desktop only)
 * Displays App Store link in the header navigation
 */
export default function HeaderCta() {
  const { trackClick } = useCtaTracking();

  return (
    <a
      href={APP_STORE_URL}
      target="_blank"
      rel="noopener noreferrer"
      className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium bg-blue-600 hover:bg-blue-700 text-white rounded-md transition-colors"
      onClick={() => trackClick('header')}
    >
      <AppleIcon className="w-3.5 h-3.5" />
      {CTA_MESSAGES.header}
    </a>
  );
}

