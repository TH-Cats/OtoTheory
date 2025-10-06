"use client";

import React, { useEffect, useRef } from "react";
import { createPortal } from "react-dom";
import type { FormKind, Quality } from "@/lib/chordForms";
import { trackOverlayShown, track } from "@/lib/telemetry";
import { useRovingTabs } from "@/hooks/useRovingTabs";
import { player } from "@/lib/audio/player";

type Props = {
  at: { x: number; y: number };
  quality: Quality;
  rootPc: number; // 追加: ルート音のピッチクラス
  onPick: (kind: FormKind) => void;
  onClose: () => void;
  page?: string;
};

export function ChordFormsPopover({ at, quality, rootPc, onPick, onClose, page = "analyze" }: Props) {
  const ref = useRef<HTMLDivElement>(null);
  const closeRef = useRef(onClose);
  closeRef.current = onClose;
  const sentOpenRef = useRef(false);
  const pickedRef = useRef(false);
  const buttonsRef = useRef<HTMLDivElement | null>(null);
  useRovingTabs(buttonsRef, { orientation: "horizontal" });

  useEffect(() => {
    if (!sentOpenRef.current) {
      sentOpenRef.current = true;
      trackOverlayShown({ control: "forms", open: true, page });
    }

    const firstButton = ref.current?.querySelector<HTMLButtonElement>("button");
    firstButton?.focus({ preventScroll: true });

    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") closeRef.current();
    }
    function onClickOutside(e: MouseEvent) {
      if (!ref.current) return;
      if (!ref.current.contains(e.target as Node)) closeRef.current();
    }

    document.addEventListener("keydown", onKey);
    document.addEventListener("mousedown", onClickOutside);
    return () => {
      document.removeEventListener("keydown", onKey);
      document.removeEventListener("mousedown", onClickOutside);
    };
  }, [page]);

  const style: React.CSSProperties = {
    position: "fixed",
    left: at.x,
    top: at.y,
    zIndex: 2147483647,
    pointerEvents: "auto",
  };

  const choose = (kind: FormKind) => {
    if (pickedRef.current) return;
    pickedRef.current = true;
    trackOverlayShown({ control: "forms", value: kind, page });
    onPick(kind);
    onClose();
  };

  const playFormPreview = async (kind: FormKind) => {
    try {
      await player.resume();
      // 基本的な3和音を再生（ルート、3度、5度）
      const intervals = quality === 'maj' ? [0, 4, 7] : [0, 3, 7];
      const midis = intervals.map(iv => 60 + rootPc + iv);
      player.playChord(midis, 'lightStrum', 300);
      track('play_chord', { page, source: 'form_preview', kind });
    } catch {}
  };

  const node = (
    <div
      role="dialog"
      aria-modal="true"
      aria-label="Chord forms"
      ref={ref}
      style={style}
      className="ot-pop"
    >
      <div className="flex items-center justify-between mb-2">
        <p className="ot-h3" style={{ margin: 0 }}>
          Chord Forms
        </p>
        <button
          type="button"
          onClick={onClose}
          className="text-xs opacity-60 hover:opacity-100 px-2 py-1 rounded hover:bg-black/5 dark:hover:bg-white/10"
          aria-label="Close"
        >
          ✕
        </button>
      </div>
      <p className="text-xs opacity-70 mb-3">
        Select a fingering pattern for {quality === 'maj' ? 'major' : 'minor'} chord
      </p>
      <div className="flex flex-col gap-2" ref={buttonsRef}>
        <div className="flex items-center gap-2">
          <button
            type="button"
            data-roving="item"
            onClick={() => choose("open")}
            className="flex-1 px-3 py-2 rounded border text-left hover:bg-emerald-50 dark:hover:bg-emerald-900/20 transition-colors"
          >
            <div className="font-medium">Open Position</div>
            <div className="text-xs opacity-70">Uses open strings</div>
          </button>
          <button
            type="button"
            onClick={() => playFormPreview("open")}
            className="w-8 h-8 flex items-center justify-center rounded border hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
            aria-label="Preview open position"
            title="Preview sound"
          >
            ▶
          </button>
        </div>
        <div className="flex items-center gap-2">
          <button
            type="button"
            data-roving="item"
            onClick={() => choose("barreE")}
            className="flex-1 px-3 py-2 rounded border text-left hover:bg-emerald-50 dark:hover:bg-emerald-900/20 transition-colors"
          >
            <div className="font-medium">Barre (E-shape)</div>
            <div className="text-xs opacity-70">6th string root</div>
          </button>
          <button
            type="button"
            onClick={() => playFormPreview("barreE")}
            className="w-8 h-8 flex items-center justify-center rounded border hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
            aria-label="Preview E-shape barre"
            title="Preview sound"
          >
            ▶
          </button>
        </div>
        <div className="flex items-center gap-2">
          <button
            type="button"
            data-roving="item"
            onClick={() => choose("barreA")}
            className="flex-1 px-3 py-2 rounded border text-left hover:bg-emerald-50 dark:hover:bg-emerald-900/20 transition-colors"
          >
            <div className="font-medium">Barre (A-shape)</div>
            <div className="text-xs opacity-70">5th string root</div>
          </button>
          <button
            type="button"
            onClick={() => playFormPreview("barreA")}
            className="w-8 h-8 flex items-center justify-center rounded border hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
            aria-label="Preview A-shape barre"
            title="Preview sound"
          >
            ▶
          </button>
        </div>
      </div>
      <p className="ot-hint mt-3">Right-click or long-press a chord to open.</p>
    </div>
  );

  if (typeof document !== "undefined") {
    return createPortal(node, document.body);
  }
  return node;
}

export default ChordFormsPopover;
 