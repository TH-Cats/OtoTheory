// Web Worker: Melody → Key/Mode (PCP via Goertzel, Krumhansl correlation)

export type AnalyzeInput = { pcm: Float32Array; sampleRate: number };
export type KeyCandidate = { keyPc: number; mode: 'major'|'minor'; confidence: number; why?: string };
export type AnalyzeOutput = { ok: true; pcp: number[]; candidates: KeyCandidate[] } | { ok: false; error: string };

const MAJOR_PROFILE = [6.35,2.23,3.48,2.33,4.38,4.09,2.52,5.19,2.39,3.66,2.29,2.88];
const MINOR_PROFILE = [6.33,2.68,3.52,5.38,2.60,3.53,2.54,4.75,3.98,2.69,3.34,3.17];

function hann(n: number, N: number): number { return 0.5 * (1 - Math.cos(2*Math.PI*n/(N-1))); }

// Goertzel for specific frequency
function goertzel(frame: Float32Array, sampleRate: number, freq: number): number {
  const N = frame.length;
  const k = Math.round(0.5 + (N * freq) / sampleRate);
  const w = (2 * Math.PI / N) * k;
  const cosine = Math.cos(w);
  const coeff = 2 * cosine;
  let s_prev = 0, s_prev2 = 0;
  for (let i = 0; i < N; i++) {
    const s = frame[i] + coeff * s_prev - s_prev2;
    s_prev2 = s_prev; s_prev = s;
  }
  const power = s_prev2*s_prev2 + s_prev*s_prev - coeff*s_prev*s_prev2;
  return power;
}

function midiToFreq(m: number): number { return 440 * Math.pow(2, (m - 69) / 12); }

function computePCP(pcm: Float32Array, sr: number): number[] {
  // frame 0.1s, hop 50%
  const frameSize = Math.max(1024, Math.min(8192, Math.round(sr * 0.1)));
  const hop = Math.max(512, Math.round(frameSize / 2));
  const pcp = new Array(12).fill(0);
  const tmp = new Float32Array(frameSize);
  const startMidi = 40; // E2≈40.2 → use 40
  const endMidi = 88;   // ~E6
  for (let off = 0; off + frameSize <= pcm.length; off += hop) {
    // windowed copy
    let energy = 0;
    for (let i = 0; i < frameSize; i++) { const v = pcm[off+i] * hann(i, frameSize); tmp[i] = v; energy += v*v; }
    if (energy < 1e-6) continue;
    // accumulate Goertzel energies per pitch class across octaves
    for (let m = startMidi; m <= endMidi; m++) {
      const freq = midiToFreq(m);
      if (freq > sr/2) break;
      const e = goertzel(tmp, sr, freq);
      pcp[m % 12] += e;
    }
  }
  // normalize
  const sum = pcp.reduce((a,b)=>a+b,0) || 1;
  for (let i = 0; i < 12; i++) pcp[i] = pcp[i] / sum;
  return pcp;
}

function rotate(arr: number[], n: number): number[] { return arr.map((_,i)=>arr[(i - n + arr.length) % arr.length]); }
function dot(a: number[], b: number[]): number { let s=0; for (let i=0;i<a.length;i++) s+=a[i]*b[i]; return s; }

function analyze(pcm: Float32Array, sr: number): AnalyzeOutput {
  if (!pcm || pcm.length < sr * 2) return { ok:false, error:'audio too short' };
  const pcp = computePCP(pcm, sr);
  const results: KeyCandidate[] = [];
  for (let mode of ['major','minor'] as const) {
    const profile = mode==='major'? MAJOR_PROFILE: MINOR_PROFILE;
    for (let rot = 0; rot < 12; rot++) {
      const tpl = rotate(profile, rot);
      const score = dot(pcp, tpl);
      results.push({ keyPc: rot, mode, confidence: score });
    }
  }
  // pick top 3, normalize
  results.sort((a,b)=> b.confidence - a.confidence);
  const top = results.slice(0, 3);
  const max = top[0]?.confidence || 1;
  const min = Math.max(1e-6, results[results.length-1]?.confidence || 1e-6);
  // scale to 0..1 by dividing by sum of top or by max
  const sumTop = top.reduce((a,b)=>a+b.confidence,0) || 1;
  top.forEach(t => t.confidence = Math.max(0, Math.min(1, t.confidence / sumTop)));
  // add why when close
  if (top.length>=2 && Math.abs(top[0].confidence - top[1].confidence) < 0.08) {
    top[0].why = 'Close contenders due to shared pitch classes';
  }
  return { ok:true, pcp, candidates: top };
}

self.onmessage = (e: MessageEvent) => {
  try {
    const { pcm, sampleRate } = e.data as AnalyzeInput;
    const out = analyze(pcm, sampleRate);
    (self as any).postMessage(out);
  } catch (err: any) {
    (self as any).postMessage({ ok:false, error: String(err?.message||err) } as AnalyzeOutput);
  }
};









