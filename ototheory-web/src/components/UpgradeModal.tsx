"use client";
import React from "react";
import { usePro } from "./ProProvider";

export default function UpgradeModal({
  open, onClose,
  title = "Go Pro to unlock Advanced chords",
  body = "Advanced chord qualities (aug, add9, tensions, and slash chords) are available in Pro.",
}: { open: boolean; onClose: () => void; title?: string; body?: string; }) {
  const { upgrade } = usePro();
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="w-full max-w-md rounded-2xl bg-white p-5 shadow-xl">
        <h3 className="text-lg font-semibold mb-2">{title}</h3>
        <p className="text-sm text-gray-600 mb-4">{body}</p>
        <div className="flex gap-2 justify-end">
          <button className="px-3 py-1.5 rounded border" onClick={onClose}>Maybe later</button>
          <button className="px-3 py-1.5 rounded bg-[var(--brand-primary)] text-white" onClick={upgrade}>
            Upgrade to Pro
          </button>
        </div>
      </div>
    </div>
  );
}



