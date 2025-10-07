import { useCallback } from 'react';
import { trackCtaClick, type CtaPlace } from '@/lib/telemetry';

/**
 * CTA click tracking hook
 * Provides a memoized tracking function with current page path
 */
export function useCtaTracking() {
  const trackClick = useCallback((place: CtaPlace, extra?: Record<string, unknown>) => {
    if (typeof window !== 'undefined') {
      trackCtaClick(place, { page: window.location.pathname, ...extra });
    }
  }, []);

  return { trackClick };
}


