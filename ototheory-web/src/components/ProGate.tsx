"use client";
import React from "react";
import { usePro } from "./ProProvider";

export const ProGate: React.FC<{ title?: string; children?: React.ReactNode }> = ({ title = "Advanced — Pro", children }) => {
  const { upgrade } = usePro();
  return (
    <div className="relative">
      <div className="pointer-events-none opacity-50">{children}</div>
      <div className="absolute inset-0 flex items-center justify-center bg-white/60 backdrop-blur-sm rounded">
        <div className="flex flex-col items-center gap-2">
          <div className="text-sm font-medium">🔒 {title}</div>
          <button className="px-3 py-1 rounded bg-[var(--brand-primary)] text-white" onClick={upgrade}>
            Upgrade to Pro
          </button>
        </div>
      </div>
    </div>
  );
};



