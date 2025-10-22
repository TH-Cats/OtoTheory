export type Locale = 'ja' | 'en';
export const DEFAULT_LOCALE: Locale = 'en';

export interface SectionContent {
  vibe: string;
  usage: string;
  try: string;
  theory: string;
}

export interface LocalizedContent<T = SectionContent> {
  ja: T;
  en: T;
}

// 将来のプラットフォーム対応用
export type Platform = 'web' | 'ios' | 'android';

// 将来、LocaleContextValueに追加予定
export interface LocaleContextValue {
  locale: Locale;
  setLocale: (locale: Locale) => void;
  isJapanese: boolean;
  platform?: Platform; // 将来追加
}
