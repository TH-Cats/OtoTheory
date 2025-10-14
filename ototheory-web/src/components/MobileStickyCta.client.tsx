"use client";
import { useEffect, useState, useCallback } from 'react';
import { useCtaTracking } from '@/hooks/useCtaTracking';
import { APP_STORE_URL } from '@/lib/constants/cta';
import { useCtaMessages } from '@/hooks/useCtaMessages';

const DISMISS_KEY = 'ot-mobile-cta-dismissed';
const SHOW_DELAY_MS = 3000;
const SCROLL_THRESHOLD = 200;

/**
 * M3.5: Mobile sticky CTA component
 * Displays at the bottom on mobile after scroll/delay
 * Dismissible for the current session
 */
export default function MobileStickyCta() {
  const CTA_MESSAGES = useCtaMessages();
  const [isVisible, setIsVisible] = useState(false);
  const [isDismissed, setIsDismissed] = useState(false);
  const [hasScrolled, setHasScrolled] = useState(false);
  const { trackClick } = useCtaTracking();

  useEffect(() => {
    // Check if dismissed in current session
    const dismissed = sessionStorage.getItem(DISMISS_KEY) === '1';
    setIsDismissed(dismissed);
    
    if (dismissed) return;

    // Show after delay
    const delayTimer = setTimeout(() => setIsVisible(true), SHOW_DELAY_MS);

    // Show after scroll
    const handleScroll = () => {
      if (window.scrollY > SCROLL_THRESHOLD) {
        setHasScrolled(true);
      }
    };
    
    window.addEventListener('scroll', handleScroll);
    
    return () => {
      clearTimeout(delayTimer);
      window.removeEventListener('scroll', handleScroll);
    };
  }, []);

  const handleDismiss = useCallback(() => {
    setIsVisible(false);
    setIsDismissed(true);
    sessionStorage.setItem(DISMISS_KEY, '1');
  }, []);

  const handleClick = useCallback(() => {
    trackClick('sticky');
  }, [trackClick]);

  // Show when either delay passed or user scrolled (and not dismissed)
  const shouldShow = !isDismissed && (isVisible || hasScrolled);

  if (!shouldShow) return null;

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 sm:hidden bg-gradient-to-t from-black/95 to-black/80 backdrop-blur-sm border-t border-white/20 animate-slide-up">
      <div className="container py-3 px-4 flex items-center justify-between gap-3">
        <div className="flex-1 min-w-0">
          <div className="text-xs font-medium text-white/90">{CTA_MESSAGES.sticky.title}</div>
          <div className="text-xs text-white/60 truncate">{CTA_MESSAGES.sticky.subtitle}</div>
        </div>
        <a
          href="/ios-coming-soon"
          className="flex-shrink-0 px-3 py-2 text-xs font-medium bg-gradient-to-r from-purple-600 to-blue-600 hover:opacity-90 text-white rounded-lg transition-opacity relative"
          onClick={handleClick}
        >
          <span className="block">{CTA_MESSAGES.sticky.button}</span>
          <span className="block text-[10px] font-bold text-yellow-400">Soon</span>
        </a>
        <button
          onClick={handleDismiss}
          className="flex-shrink-0 w-6 h-6 flex items-center justify-center text-white/60 hover:text-white/90 transition-colors"
          aria-label="Dismiss"
        >
          ✕
        </button>
      </div>
    </div>
  );
}

