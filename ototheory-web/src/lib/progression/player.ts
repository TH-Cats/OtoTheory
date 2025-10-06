// src/lib/progression/player.ts
import { player } from '@/lib/audio/player';
import * as t from '@/lib/telemetry';

let loopTimer: number | null = null;

export const playProgression = (chords: { freqs: number[] }[], bpm = 84) => {
  stop();
  const beat = 60 / bpm;
  chords.forEach((c, i) => {
    const when = i * 2 * beat; // 2拍/コードの簡易
    setTimeout(() => player.playChord(c.freqs, 'lightStrum'), when * 1000);
  });
  t.track('progression_play', { page: 'chord_progression' });
  // 単純ループ
  loopTimer = window.setTimeout(() => playProgression(chords, bpm), chords.length * 2 * beat * 1000);
};

export const stop = () => { if (loopTimer) window.clearTimeout(loopTimer); loopTimer = null; };
