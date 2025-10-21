"use client";
import React, { createContext, useContext, useState, useMemo } from "react";
import { usePathname } from "next/navigation";

type Locale = 'ja' | 'en';

interface LocaleContextValue {
  locale: Locale;
  isJapanese: boolean;
}

const LocaleContext = createContext<LocaleContextValue | null>(null);

interface LocaleProviderProps {
  children: React.ReactNode;
  initialLocale?: Locale;
}

export function LocaleProvider({ children, initialLocale }: LocaleProviderProps) {
  const pathname = usePathname() || "/";
  
  // SSRセーフな実装：サーバーサイドのpathnameから初期化されたuseStateを使用
  // ハイドレーションエラーを避けるため、useEffectやisInitialized状態は使わない
  const [locale] = useState<Locale>(() => {
    // 初期値が提供されている場合はそれを使用（SSR時）
    if (initialLocale) {
      return initialLocale;
    }
    // クライアントサイドではpathnameから判定
    return pathname.startsWith('/ja') ? 'ja' : 'en';
  });

  const isJapanese = locale === 'ja';

  const value = useMemo(() => ({
    locale,
    isJapanese,
  }), [locale, isJapanese]);

  return (
    <LocaleContext.Provider value={value}>
      {children}
    </LocaleContext.Provider>
  );
}

export function useLocale(): LocaleContextValue {
  const context = useContext(LocaleContext);
  if (!context) {
    throw new Error('useLocale must be used within LocaleProvider');
  }
  return context;
}
