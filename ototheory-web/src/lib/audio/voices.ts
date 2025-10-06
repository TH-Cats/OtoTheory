/* eslint-disable @typescript-eslint/no-explicit-any */

export const MAX_VOICES = 6;
export const ATTACK_SEC = 0.005;
export const RELEASE_SEC = 0.12;
export const STRUM_STEP_SEC = 0.02;

type Voice = {
  source: OscillatorNode;
  gain: GainNode;
  stopAt: number;
};

const voices: Voice[] = [];

type VoiceMode = "sine" | "triangle" | "pluck";
let VOICE_MODE: VoiceMode = "pluck"; // ギター風プラックを既定
export function setVoiceMode(mode: VoiceMode){ VOICE_MODE = mode; }
export function getVoiceMode(): VoiceMode { return VOICE_MODE; }

function midiToHz(midi: number){
  return 440 * Math.pow(2, (midi - 69) / 12);
}

function cleanupVoice(voice: Voice){
  try { voice.source.onended = null; } catch {}
  try { voice.source.disconnect(); } catch {}
  try { voice.gain.disconnect(); } catch {}
}

function voiceSteal(startAt: number){
  if (voices.length < MAX_VOICES) return;
  voices.sort((a, b) => a.stopAt - b.stopAt);
  const victim = voices.shift();
  if (!victim) return;
  try { victim.source.stop(startAt); } catch {}
  cleanupVoice(victim);
}

function registerVoice(ctx: AudioContext, voice: Voice){
  voices.push(voice);
  voice.source.onended = () => {
    const idx = voices.indexOf(voice);
    if (idx >= 0) voices.splice(idx, 1);
    cleanupVoice(voice);
  };
}

function playPluckVoice(
  ctx: AudioContext,
  master: GainNode,
  freqHz: number,
  startAt: number,
  holdSec: number,
  peak: number,
){
  const period = Math.max(1/880, Math.min(1/55, 1/Math.max(1, freqHz)));
  const noiseDur = Math.min(0.025, Math.max(0.008, ATTACK_SEC * 2));
  const stopAt = startAt + Math.max(RELEASE_SEC + 0.02, holdSec + 0.02);

  const noise = ctx.createBufferSource();
  const buf = ctx.createBuffer(1, Math.max(1, Math.floor(ctx.sampleRate * noiseDur)), ctx.sampleRate);
  const ch0 = buf.getChannelData(0);
  for (let i=0;i<ch0.length;i++) ch0[i] = (Math.random()*2-1);
  noise.buffer = buf;
  noise.start(startAt);
  noise.stop(startAt + noiseDur);

  const delay = ctx.createDelay();
  delay.delayTime.setValueAtTime(period, startAt);
  const feedback = ctx.createGain();
  feedback.gain.setValueAtTime(0.82, startAt); // 残響感（ダンピング前）
  const damp = ctx.createBiquadFilter();
  damp.type = "lowpass";
  damp.frequency.setValueAtTime(Math.min(6000, Math.max(1200, freqHz*6)), startAt);
  damp.Q.setValueAtTime(0.5, startAt);

  // 出力用エンベロープ
  const outGain = ctx.createGain();
  const attackEnd = startAt + ATTACK_SEC;
  const sustainEnd = startAt + Math.max(RELEASE_SEC, holdSec);
  const releaseStart = Math.max(attackEnd, sustainEnd - RELEASE_SEC);
  outGain.gain.setValueAtTime(0, startAt);
  outGain.gain.linearRampToValueAtTime(Math.max(0.0001, peak), attackEnd);
  outGain.gain.setValueAtTime(Math.max(0.0001, peak), releaseStart);
  outGain.gain.linearRampToValueAtTime(0.0001, sustainEnd);

  // フィードバックループ（Karplus–Strongの簡易近似）
  noise.connect(damp);
  damp.connect(delay);
  delay.connect(feedback).connect(damp);
  delay.connect(outGain).connect(master);

  // 疑似オシレータとして扱うためのダミーOscillatorNode（管理用）
  const dummyOsc = ctx.createOscillator();
  try { dummyOsc.connect(ctx.destination); } catch {}
  dummyOsc.start(startAt);
  dummyOsc.stop(stopAt);

  registerVoice(ctx, { source: dummyOsc, gain: outGain, stopAt: sustainEnd });
}

export function playVoice(
  ctx: AudioContext,
  master: GainNode,
  midi: number,
  startAt: number,
  holdSec: number,
  peak: number = 1,
){
  voiceSteal(startAt);
  const freqHz = midiToHz(midi);
  if (VOICE_MODE === "pluck") {
    playPluckVoice(ctx, master, freqHz, startAt, holdSec, peak);
    return;
  }
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();
  osc.type = (VOICE_MODE === "triangle") ? "triangle" : "sine";
  osc.frequency.value = freqHz;

  const attackEnd = startAt + ATTACK_SEC;
  const sustainEnd = startAt + Math.max(RELEASE_SEC, holdSec);
  const releaseStart = Math.max(attackEnd, sustainEnd - RELEASE_SEC);

  gain.gain.setValueAtTime(0, startAt);
  gain.gain.linearRampToValueAtTime(Math.max(0.0001, peak), attackEnd);
  gain.gain.setValueAtTime(Math.max(0.0001, peak), releaseStart);
  gain.gain.linearRampToValueAtTime(0.0001, sustainEnd);

  osc.connect(gain).connect(master);
  osc.start(startAt);
  osc.stop(sustainEnd + 0.01);

  registerVoice(ctx, { source: osc, gain, stopAt: sustainEnd });
}

export function playNote(
  ctx: AudioContext,
  master: GainNode,
  midi: number,
  holdSec: number,
){
  const startAt = ctx.currentTime;
  // 単音はやや控えめのピーク
  playVoice(ctx, master, midi, startAt, holdSec, 0.7);
}

export function playChord(
  ctx: AudioContext,
  master: GainNode,
  midis: number[],
  holdSec: number,
  strumStepSec: number,
){
  const base = ctx.currentTime;
  const n = Math.max(1, Math.min(midis.length, MAX_VOICES));
  // 同時発音数に応じてピークを正規化（歪み防止）
  const perVoicePeak = Math.max(0.22, Math.min(0.42, 0.95 / Math.sqrt(n)));
  midis.forEach((midi, index) => {
    const startAt = base + Math.max(0, strumStepSec) * index;
    playVoice(ctx, master, midi, startAt, holdSec, perVoicePeak);
  });
}

export function stopAll(ctx: AudioContext){
  voices.splice(0).forEach(voice => {
    try { voice.source.stop(ctx.currentTime); } catch {}
    cleanupVoice(voice);
  });
}
