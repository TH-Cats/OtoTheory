/**
 * Pro feature guard utilities
 * Defines which chord types require Pro subscription for adding to progression
 */

/**
 * Chord quality types that require Pro subscription
 * - Altered Dominant: 7b9, 7#9, 7#11, 7b13, 7alt
 * - 13th extensions: 13, M13, m13
 * - Slash/On-Bass: detected via 'slash' flag
 */
const PRO_ONLY_QUALITIES = new Set([
  // Altered Dominant
  '7b9',
  '7#9',
  '7#11',
  '7b13',
  '7alt',
  // 13th系
  '13',
  'M13',
  'm13',
]);

/**
 * Check if a chord quality can be added to progression
 * @param quality - The chord quality string (e.g., '7b9', 'M13')
 * @param options - Options including isPro status and slash (on-bass) flag
 * @returns true if chord can be added, false if Pro subscription required
 */
export function canAddQuality(
  quality: string,
  options: { isPro: boolean; hasSlash?: boolean }
): boolean {
  const { isPro, hasSlash } = options;
  
  // Pro users can add everything
  if (isPro) return true;
  
  // Slash/On-Bass requires Pro
  if (hasSlash) return false;
  
  // Check if quality is in Pro-only set
  return !PRO_ONLY_QUALITIES.has(quality);
}

/**
 * Check if a chord quality should show Pro badge
 * @param quality - The chord quality string
 * @param hasSlash - Whether slash/on-bass is active
 * @returns true if Pro badge should be shown
 */
export function shouldShowProBadge(quality: string, hasSlash?: boolean): boolean {
  return PRO_ONLY_QUALITIES.has(quality) || !!hasSlash;
}

/**
 * Get the reason why a chord type is Pro-only (for telemetry/debugging)
 * @param quality - The chord quality string
 * @param hasSlash - Whether slash/on-bass is active
 * @returns Reason string or null if not Pro-only
 */
export function getProOnlyReason(quality: string, hasSlash?: boolean): string | null {
  if (hasSlash) return 'slash';
  if (quality.includes('alt')) return 'altered';
  if (quality.includes('13')) return '13th';
  if (PRO_ONLY_QUALITIES.has(quality)) return 'advanced';
  return null;
}


