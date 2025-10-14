export type Locale = 'en' | 'ja';

export function getLocaleFromPath(pathname: string | null | undefined): Locale {
  if (!pathname) return 'en';
  return pathname.startsWith('/ja') ? 'ja' : 'en';
}



