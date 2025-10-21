"use client";
import React, { createContext, useContext, useState, useMemo } from "react";

type Locale = 'ja' | 'en';

interface LocaleContextValue {
  locale: Locale;
  isJapanese: boolean;
}

const LocaleContext = createContext<LocaleContextValue | null>(null);

interface LocaleProviderProps {
  children: React.ReactNode;
  initialLocale: Locale;
}

export function LocaleProvider({ children, initialLocale }: LocaleProviderProps) {
  // サーバーから渡された initialLocale を直接 useState の初期値として使用する
  // これにより、SSRとクライアントの初回レンダリングが必ず一致する
  const [locale] = useState<Locale>(initialLocale);

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
