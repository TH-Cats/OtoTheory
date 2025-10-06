"use client";
import { useEffect, useCallback } from 'react';
import { useCtaTracking } from '@/hooks/useCtaTracking';

export type ToastType = 'info' | 'success' | 'warning';
export type ToastCtaPlace = 'limit_toast' | 'png_toast';

export interface ToastProps {
  message: string;
  type?: ToastType;
  ctaText?: string;
  ctaHref?: string;
  ctaPlace?: ToastCtaPlace;
  onClose: () => void;
  duration?: number;
}

const TOAST_COLORS: Record<ToastType, string> = {
  info: 'bg-blue-600',
  success: 'bg-green-600',
  warning: 'bg-orange-600',
};

const DEFAULT_DURATION = 5000;

/**
 * M3.5: Toast notification component
 * Displays temporary notifications with optional CTA
 * Auto-dismisses after duration (default 5s)
 */
export default function Toast({ 
  message, 
  type = 'info', 
  ctaText, 
  ctaHref, 
  ctaPlace,
  onClose, 
  duration = DEFAULT_DURATION 
}: ToastProps) {
  const { trackClick } = useCtaTracking();

  useEffect(() => {
    if (duration > 0) {
      const timer = setTimeout(onClose, duration);
      return () => clearTimeout(timer);
    }
  }, [duration, onClose]);

  const handleCtaClick = useCallback(() => {
    if (ctaPlace) {
      trackClick(ctaPlace);
    }
  }, [ctaPlace, trackClick]);

  const bgColor = TOAST_COLORS[type];

  return (
    <div 
      className="fixed bottom-20 sm:bottom-6 left-1/2 -translate-x-1/2 z-50 animate-slide-up max-w-md w-full mx-4"
      role="alert"
      aria-live="polite"
    >
      <div className={`${bgColor} text-white rounded-lg shadow-2xl p-4 flex items-center justify-between gap-3`}>
        <div className="flex-1 min-w-0">
          <p className="text-sm font-medium">{message}</p>
        </div>
        {ctaText && ctaHref && (
          <a
            href={ctaHref}
            target="_blank"
            rel="noopener noreferrer"
            className="flex-shrink-0 px-3 py-1.5 text-sm font-medium bg-white/20 hover:bg-white/30 rounded transition-colors"
            onClick={handleCtaClick}
          >
            {ctaText}
          </a>
        )}
        <button
          onClick={onClose}
          className="flex-shrink-0 w-6 h-6 flex items-center justify-center hover:bg-white/20 rounded transition-colors"
          aria-label="Close notification"
        >
          ✕
        </button>
      </div>
    </div>
  );
}

