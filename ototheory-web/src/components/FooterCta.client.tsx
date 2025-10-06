"use client";
import AppleIcon from '@/components/ui/AppleIcon';
import { useCtaTracking } from '@/hooks/useCtaTracking';
import { APP_STORE_URL, CTA_MESSAGES } from '@/lib/constants/cta';

/**
 * M3.5: Footer CTA component
 * Displays App Store link with QR code area in the footer
 */
export default function FooterCta() {
  const { trackClick } = useCtaTracking();

  return (
    <div className="mb-6 flex flex-col items-center gap-3">
      <div className="text-sm font-medium text-black/80 dark:text-white/80">
        {CTA_MESSAGES.footer.title}
      </div>
      <a
        href={APP_STORE_URL}
        target="_blank"
        rel="noopener noreferrer"
        className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
        onClick={() => trackClick('qr')}
      >
        <AppleIcon />
        {CTA_MESSAGES.footer.button}
      </a>
      <div className="text-xs opacity-60">
        {CTA_MESSAGES.footer.features}
      </div>
    </div>
  );
}

