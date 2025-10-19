"use client";
import React, { createContext, useContext, useEffect, useMemo, useState } from "react";

type Ctx = { isPro: boolean; upgrade: () => void; downgrade: () => void };
const ProCtx = createContext<Ctx | null>(null);

export const ProProvider: React.FC<{ children: React.ReactNode; initialIsPro?: boolean }> = ({ children, initialIsPro = false }) => {
  // Use initial value from SSR (Cookie), then hydrate from localStorage
  const [isPro, setIsPro] = useState(initialIsPro);
  useEffect(() => {
    try {
      const v = window.localStorage.getItem("isPro") === "1";
      if (v !== isPro) setIsPro(v); // Sync if different
    } catch {}
  }, [isPro]);
  
  const upgrade = () => { 
    try { 
      window.localStorage.setItem("isPro", "1");
      document.cookie = "isPro=1; path=/; max-age=31536000"; // Update cookie for SSR
    } catch {}; 
    setIsPro(true); 
  };
  
  const downgrade = () => { 
    try { 
      window.localStorage.setItem("isPro", "0");
      document.cookie = "isPro=0; path=/; max-age=31536000"; // Update cookie for SSR
    } catch {}; 
    setIsPro(false); 
  };
  
  const value = useMemo(() => ({ isPro, upgrade, downgrade }), [isPro]);
  return <ProCtx.Provider value={value}>{children}</ProCtx.Provider>;
};

export const usePro = () => {
  const ctx = useContext(ProCtx);
  if (!ctx) throw new Error("usePro must be used inside ProProvider");
  return ctx;
};


