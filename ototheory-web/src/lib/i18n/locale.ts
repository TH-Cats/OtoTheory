export type Locale = 'en' | 'ja';

export function getLocaleFromPath(pathname: string | null | undefined): Locale {
  if (!pathname) return 'en';
  return pathname.startsWith('/ja') ? 'ja' : 'en';
}

// Client-side locale hook (safe to import in client components)
export function useLocale(): Locale {
  // Dynamic import to avoid forcing client on all consumers
  // Consumers in server files should avoid calling this
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const { usePathname } = require('next/navigation');
  const pathname: string = usePathname?.() || '/';
  return getLocaleFromPath(pathname);
}



