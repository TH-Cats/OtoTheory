"use client";
import React, { useState, useEffect, useCallback } from 'react';
import { player, type PlayStyle } from '@/lib/audio/player';
import { track } from '@/lib/telemetry';

interface ProgressionPlayerProps {
  progression?: { items: { id: string; degree: string; quality?: string }[] };
  keyInfo?: { tonic: string; scaleId: string };
  isPlaying?: boolean;
  onPlayStateChange?: (playing: boolean) => void;
}

export function ProgressionPlayer({
  progression = { items: [] },
  keyInfo,
  isPlaying: externalIsPlaying,
  onPlayStateChange
}: ProgressionPlayerProps) {
  const [internalIsPlaying, setInternalIsPlaying] = useState(false);
  const [currentIndex, setCurrentIndex] = useState(0);

  const isPlaying = externalIsPlaying ?? internalIsPlaying;

  // 単音再生（Attack≈3–5ms／Release≈80–150ms、最大6声）
  const playNote = useCallback(async (midi: number) => {
    await player.resume();
    player.playNote(midi, 100); // 100ms duration
  }, []);

  // 和音再生（同時or軽ストラム、10–20ms）
  const playChord = useCallback(async (midis: number[], style: PlayStyle = 'lightStrum') => {
    await player.resume();
    if (style === 'lightStrum') {
      player.playChord(midis, style, 200);
    } else {
      player.playChord(midis, style);
    }
  }, []);

  // 進行全体の再生
  const playProgression = useCallback(async () => {
    if (!progression.items.length) return;

    setInternalIsPlaying(true);
    onPlayStateChange?.(true);
    track('progression_play', { page: 'chord_progression' });

    try {
      for (let i = 0; i < progression.items.length; i++) {
        if (!isPlaying) break;

        setCurrentIndex(i);

        // 実際のMIDI生成ロジック（簡易版）
        const midi = 60 + (i * 2); // 仮のMIDI値
        await playNote(midi);

        // コード間の間隔（調整可能）
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    } finally {
      setInternalIsPlaying(false);
      setCurrentIndex(0);
      onPlayStateChange?.(false);
    }
  }, [progression.items, isPlaying, playNote, onPlayStateChange]);

  useEffect(() => {
    if (isPlaying && progression.items.length > 0) {
      playProgression();
    } else {
      setInternalIsPlaying(false);
      setCurrentIndex(0);
      onPlayStateChange?.(false);
    }
  }, [isPlaying, progression.items.length, playProgression, onPlayStateChange]);

  const handleTogglePlay = useCallback(() => {
    if (isPlaying) {
      setInternalIsPlaying(false);
      onPlayStateChange?.(false);
    } else if (progression.items.length > 0) {
      playProgression();
    }
  }, [isPlaying, progression.items.length, playProgression, onPlayStateChange]);

  return (
    <div className="ot-block">
      <div className="ot-section-head">
        <h3 className="ot-h3">Playback</h3>
        <button
          className={`ot-chip ${isPlaying ? 'ot-chip--on' : ''}`}
          onClick={handleTogglePlay}
          disabled={progression.items.length === 0}
        >
          {isPlaying ? '⏸️ Stop' : '▶️ Play'}
        </button>
      </div>

      {progression.items.length > 0 && (
        <div className="ot-block">
          <div className="ot-chip-row">
            {progression.items.map((item, index) => (
              <span
                key={item.id}
                className={`ot-chip ${index === currentIndex && isPlaying ? 'ot-chip--on' : ''}`}
              >
                {item.degree}{item.quality ? `(${item.quality})` : ''}
              </span>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
