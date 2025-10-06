"use client";

import React, { useRef, useEffect, useMemo, useCallback } from "react";
import { getSubstitutes, type SubstituteChord, type ChordContext } from "@/lib/chords/substitute.refactored";
import { player } from "@/lib/audio/player";
import { track } from "@/lib/telemetry";
import { useRovingTabs } from "@/hooks/useRovingTabs";
import { chordToMidi } from "@/lib/music/chordParser";

type Props = {
  rootPc: number; // 0=C, 1=C#, ..., 11=B
  quality: 'maj' | 'min' | 'dom7' | 'dim';
  degree: number; // 1=I, 2=II, ..., 7=VII
  keyContext: { tonic: number; mode: 'Major' | 'Minor' };
  onAdd?: (chord: string) => void; // Chord Progression への追加
  page?: string;
};

export function SubstituteCard({ 
  rootPc, 
  quality, 
  degree, 
  keyContext, 
  onAdd, 
  page = 'find-chords' 
}: Props) {
  const listRef = useRef<HTMLDivElement | null>(null);
  useRovingTabs(listRef, { orientation: "horizontal" });

  // コンテキストをメモ化
  const context = useMemo<ChordContext>(() => ({
    rootPc,
    quality,
    degree,
    key: keyContext
  }), [rootPc, quality, degree, keyContext]);

  // 代理コード候補を計算
  const substitutes = useMemo(() => {
    return getSubstitutes(context);
  }, [context]);

  // Telemetry: 表示時に1回だけ送信
  useEffect(() => {
    if (substitutes.length > 0) {
      track('substitute_shown', { 
        page, 
        rootPc, 
        quality, 
        degree, 
        count: substitutes.length 
      });
    }
  }, [substitutes, page, rootPc, quality, degree]);

  // 試聴機能
  const playSubstitute = useCallback(async (sub: SubstituteChord) => {
    try {
      await player.resume();
      
      const midis = chordToMidi(sub.chord);
      if (!midis || midis.length === 0) {
        console.warn(`Failed to parse chord: ${sub.chord}`);
        return;
      }

      player.playChord(midis, 'lightStrum', 300);
      track('play_chord', { 
        page, 
        source: 'substitute_preview', 
        chord: sub.chord 
      });
    } catch (error) {
      console.error('Failed to play substitute chord:', error);
    }
  }, [page]);

  // 追加機能
  const handleAdd = useCallback((sub: SubstituteChord) => {
    if (onAdd) {
      onAdd(sub.chord);
      track('substitute_add', { 
        page, 
        rootPc, 
        originalQuality: quality, 
        substituteChord: sub.chord 
      });
    }
  }, [onAdd, page, rootPc, quality]);

  // 代理コードがない場合は非表示
  if (substitutes.length === 0) {
    return null;
  }

  return (
    <details className="rounded border p-2 bg-background/40 mt-2">
      <summary className="text-sm cursor-pointer select-none font-medium">
        Substitute Chords ({substitutes.length})
      </summary>
      <div className="mt-2">
        <p className="text-xs opacity-70 mb-3 px-1">
          Alternative chords with similar harmonic function
        </p>
        <div className="space-y-2" ref={listRef}>
          {substitutes.map((sub, idx) => (
            <SubstituteChordItem
              key={`${sub.chord}-${idx}`}
              substitute={sub}
              onPlay={playSubstitute}
              onAdd={onAdd ? handleAdd : undefined}
            />
          ))}
        </div>
      </div>
    </details>
  );
}

/**
 * 個別の代理コードアイテムコンポーネント
 */
type SubstituteChordItemProps = {
  substitute: SubstituteChord;
  onPlay: (sub: SubstituteChord) => void;
  onAdd?: (sub: SubstituteChord) => void;
};

function SubstituteChordItem({ substitute, onPlay, onAdd }: SubstituteChordItemProps) {
  return (
    <div className="rounded border p-2 bg-white dark:bg-neutral-900/50 hover:bg-emerald-50 dark:hover:bg-emerald-900/20 transition-colors">
      <div className="flex items-start justify-between gap-2 mb-1">
        <div className="flex-1">
          <div className="font-medium text-base">{substitute.chord}</div>
          <div className="text-sm opacity-80 mt-0.5">{substitute.reason}</div>
        </div>
        <div className="flex items-center gap-1">
          <button
            type="button"
            onClick={() => onPlay(substitute)}
            className="w-8 h-8 flex items-center justify-center rounded border hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
            aria-label={`Preview ${substitute.chord}`}
            title="Preview sound"
            data-roving="item"
          >
            ▶
          </button>
          {onAdd && (
            <button
              type="button"
              onClick={() => onAdd(substitute)}
              className="px-2 py-1 text-xs rounded border bg-emerald-50 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-300 hover:bg-emerald-100 dark:hover:bg-emerald-900/50 transition-colors"
              aria-label={`Add ${substitute.chord} to progression`}
              title="Add to progression"
            >
              + Add
            </button>
          )}
        </div>
      </div>
      {substitute.examples && substitute.examples.length > 0 && (
        <div className="text-xs opacity-60 mt-1 flex items-center gap-1">
          <span className="opacity-70">Examples:</span>
          <span>{substitute.examples.join(' · ')}</span>
        </div>
      )}
    </div>
  );
}

export default SubstituteCard;

