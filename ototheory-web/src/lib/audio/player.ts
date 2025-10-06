/* eslint-disable @typescript-eslint/no-explicit-any */
import { track } from "../telemetry";
import {
  playNote as playVoiceNote,
  playChord as playVoiceChord,
  STRUM_STEP_SEC,
} from "./voices";
import Soundfont from "soundfont-player";
type SoundfontName =
  | "acoustic_guitar_nylon"
  | "acoustic_guitar_steel"
  | "electric_guitar_clean"
  | "electric_guitar_jazz"
  | "electric_guitar_muted"
  | "overdriven_guitar"
  | "distortion_guitar"
  | "acoustic_grand_piano";

type PlayerState = { enabled: boolean; volume: number };
export type PlayStyle = "hit" | "lightStrum";

const isBrowser = typeof window !== "undefined";
function midiToHz(midi: number){ return 440 * Math.pow(2, (midi - 69) / 12); }

type Sub = (s: PlayerState) => void;

export type AudioPlayer = {
  resume(): Promise<void>;
  toggleEnabled(next?: boolean): Promise<void>;
  setVolume(v: number): void;
  getState(): PlayerState;
  subscribe(cb: Sub): () => void;
  playNote(midi: number, durMs?: number): void;
  playChord(midis: number[], style?: PlayStyle, durMs?: number): void;
  setInstrument(name: SoundfontName): Promise<void>;
  getInstrument(): SoundfontName;
};

function createNoop(): AudioPlayer {
  const s: PlayerState = { enabled: false, volume: 0.8 };
  return {
    async resume(){},
    async toggleEnabled(){},
    setVolume(){},
    getState(){ return s; },
    subscribe(){ return () => {}; },
    playNote(){},
    playChord(){},
  };
}

export const player: AudioPlayer = isBrowser ? (() => {
  // lazy context / graph
  let ctx: AudioContext | null = null;
  let master: GainNode | null = null;
  let sfGuitar: any | null = null;
  const VALID_INSTR: Set<string> = new Set([
    "acoustic_guitar_nylon",
    "acoustic_guitar_steel",
    "electric_guitar_clean",
    "electric_guitar_jazz",
    "electric_guitar_muted",
    "overdriven_guitar",
    "distortion_guitar",
    "acoustic_grand_piano",
  ]);
  let currentInstr: SoundfontName = (() => {
    try {
      const saved = (typeof localStorage !== "undefined" ? localStorage.getItem("ot-instrument") : null) as SoundfontName | null;
      return (saved && VALID_INSTR.has(saved)) ? saved : "acoustic_guitar_steel";
    } catch { return "acoustic_guitar_steel" as const; }
  })();
  const storedEnabled = (typeof localStorage !== "undefined") ? localStorage.getItem("ot-audio-enabled") : null;
  const storedVolume = (typeof localStorage !== "undefined") ? localStorage.getItem("ot-audio-volume") : null;
  const state: PlayerState = {
    enabled: storedEnabled === null ? true : storedEnabled === "true",
    volume: storedVolume ? Number(storedVolume) : 0.8,
  };
  const subs = new Set<Sub>();

  function notify(){ subs.forEach(f => f(state)); }
  function ensureCtx(){
    if (!ctx) {
      const AC: any = (window as any).AudioContext || (window as any).webkitAudioContext;
      ctx = new AC();
      master = ctx.createGain();
      master!.gain.value = state.enabled ? state.volume : 0;
      master!.connect(ctx.destination);
      // do not resume automatically here; must happen after user gesture
    }
    return ctx!;
  }

  function setMasterVolume(){
    if (!ctx || !master) return;
    master.gain.cancelScheduledValues(ctx.currentTime);
    master.gain.setValueAtTime(master.gain.value, ctx.currentTime);
    master.gain.linearRampToValueAtTime(state.enabled ? state.volume : 0, ctx.currentTime + 0.02);
  }

  async function resume(){
    const c = ensureCtx();
    if (c.state === "suspended") await c.resume();
    // lazy-load guitar soundfont
    if (!sfGuitar) {
      try {
        sfGuitar = await Soundfont.instrument(c as any, currentInstr);
      } catch {}
    }
    if (process.env.NEXT_PUBLIC_AUDIO_UNLOCK_PING === "true" && ctx) {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      gain.gain.setValueAtTime(0, ctx.currentTime);
      osc.connect(gain).connect(ctx.destination);
      osc.start();
      osc.stop(ctx.currentTime + 0.01);
      osc.onended = () => {
        try { osc.disconnect(); gain.disconnect(); } catch {}
      };
    }
  }

  async function toggleEnabled(next?: boolean){
    ensureCtx();
    state.enabled = (typeof next === "boolean") ? next : !state.enabled;
    try { localStorage.setItem("ot-audio-enabled", String(state.enabled)); } catch {}
    setMasterVolume();
    notify();
    track("fb_toggle", { page:"analyze", control:"audio", value: state.enabled });
  }

  function setVolume(v: number){
    ensureCtx();
    state.volume = Math.max(0, Math.min(1, v));
    try { localStorage.setItem("ot-audio-volume", String(state.volume)); } catch {}
    setMasterVolume();
    notify();
  }

  async function setInstrument(name: SoundfontName){
    ensureCtx();
    if (!VALID_INSTR.has(name)) return;
    currentInstr = name;
    try { localStorage.setItem("ot-instrument", name); } catch {}
    try {
      sfGuitar = await Soundfont.instrument(ctx as any, currentInstr);
    } catch { sfGuitar = null; }
    track("instrument_change", { page: "analyze", instrument: name });
    notify();
  }

  function playNote(midi: number, durMs = 320){
    const c = ensureCtx();
    void resume();
    if (!state.enabled) return;
    const durSec = Math.max(0.12, durMs / 1000);
    if (sfGuitar) { try { sfGuitar.play(midi, 0, { duration: durSec }); } catch { playVoiceNote(c, master!, midi, durSec); } }
    else { playVoiceNote(c, master!, midi, durSec); }
    track("play_note", { page:"analyze", value:midi });
  }

  function playChord(midis: number[], style: PlayStyle = "hit", durMs = 420){
    const c = ensureCtx();
    void resume();
    if (!state.enabled) return;
    const step = style === "lightStrum" ? STRUM_STEP_SEC : 0;
    const holdSec = Math.max(0.18, durMs/1000);
    if (sfGuitar) {
      try {
        midis.slice(0,6).forEach((m, i) => { sfGuitar.play(m, i*step, { duration: holdSec }); });
      } catch { playVoiceChord(c, master!, midis, holdSec, step); }
    } else {
      playVoiceChord(c, master!, midis, holdSec, step);
    }
    track("play_chord", { page:"analyze", value: midis.slice(0,6).join(",") });
  }

  // defer context/resume until first user gesture

  return {
    resume, toggleEnabled, setVolume,
    getState: () => ({ ...state }),
    subscribe(cb){ subs.add(cb); return () => subs.delete(cb); },
    playNote, playChord,
    setInstrument,
    getInstrument: () => currentInstr,
  };
})() : createNoop();



