"use client";
import React, { createContext, useContext, useEffect, useMemo, useState } from "react";

type Ctx = { isPro: boolean; upgrade: () => void; downgrade: () => void };
const ProCtx = createContext<Ctx | null>(null);

export const ProProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // Start from SSR-safe false, then hydrate from localStorage
  const [isPro, setIsPro] = useState(false);
  useEffect(() => {
    try { setIsPro(window.localStorage.getItem("isPro") === "1"); } catch {}
  }, []);
  const upgrade = () => { try { window.localStorage.setItem("isPro", "1"); } catch {}; setIsPro(true); };
  const downgrade = () => { try { window.localStorage.setItem("isPro", "0"); } catch {}; setIsPro(false); };
  const value = useMemo(() => ({ isPro, upgrade, downgrade }), [isPro]);
  return <ProCtx.Provider value={value}>{children}</ProCtx.Provider>;
};

export const usePro = () => {
  const ctx = useContext(ProCtx);
  if (!ctx) throw new Error("usePro must be used inside ProProvider");
  return ctx;
};


