// Minimal Essentia.js-based audio analyzer worker (stub implementation)
// NOTE: This is a scaffold. We dynamically import essentia-wasm when available.

export type EssKeyResult = {
  engine: 'ess-js';
  keyPc: number;               // 0..11 (C=0)
  mode: 'major'|'minor';
  conf: number;                // 0..1
  pcp12: number[];             // folded PCP (12)
  chordBeats: { beat: number; rootPc: number; quality: 'maj'|'min' }[];
};

type AnalyzeMsg = {
  type: 'analyze';
  pcm: Float32Array;           // mono
  sampleRate: number;
};

type ReadyMsg = { type: 'ready' };

let essentia: any | null = null;

async function ensureEssentia() {
  if (essentia) return essentia;
  try {
    // Lazy import. In a real implementation we would import 'essentia-wasm' bundle.
    // Here we provide a light fallback that returns a simple PCP via goertzel.
    essentia = { __placeholder: true };
  } catch (e) {
    console.error('[essAudio.worker] Failed to import Essentia.js', e);
    essentia = { __placeholder: true };
  }
  return essentia;
}

function hann(n: number, N: number){ return 0.5*(1-Math.cos((2*Math.PI*n)/(N-1))); }
function midiToFreq(m:number){ return 440*Math.pow(2,(m-69)/12); }
function goertzel(frame:Float32Array, sr:number, f:number){
  const N=frame.length; const k=Math.round(0.5+(N*f)/sr); const w=(2*Math.PI/N)*k; const cos=Math.cos(w); const coeff=2*cos; let s1=0,s2=0; for(let i=0;i<N;i++){ const s=frame[i]+coeff*s1-s2; s2=s1; s1=s; } return s2*s2 + s1*s1 - coeff*s1*s2; }

function computePCP(pcm:Float32Array, sampleRate:number): number[]{
  const frameSize = Math.max(1024, Math.min(8192, Math.round(sampleRate*0.1)));
  const hop = Math.max(512, Math.round(frameSize/2));
  const pcp = new Array(12).fill(0);
  const votes = new Array(12).fill(0);
  const tmp = new Float32Array(frameSize);
  const startMidi=40, endMidi=88; // E2..E6
  const totalDur = pcm.length / sampleRate;
  for(let off=0; off+frameSize<=pcm.length; off+=hop){
    let energy=0; for(let i=0;i<frameSize;i++){ const v=pcm[off+i]*hann(i,frameSize); tmp[i]=v; energy+=v*v; }
    if (energy<1e-6) continue;
    // cadence weighting (last ~1.2s emphasized ×3.0)
    const frameEndSec = (off + frameSize) / sampleRate;
    const remaining = Math.max(0, totalDur - frameEndSec);
    const w = remaining <= 1.2 ? 3.2 : 1.0;
    const pcpF = new Array(12).fill(0);
    for(let m=startMidi;m<=endMidi;m++){
      const f0=midiToFreq(m); if (f0>sampleRate/2) break;
      const fL=midiToFreq(m-0.5), fH=midiToFreq(m+0.5);
      const e0=goertzel(tmp,sampleRate,f0), eL=goertzel(tmp,sampleRate,fL), eH=goertzel(tmp,sampleRate,fH);
      const add = (e0 + 0.6*(eL+eH));
      pcp[m%12] += w * add;
      pcpF[m%12] += add;
    }
    // temporal consensus vote per short frame
    const sumF=pcpF.reduce((a,b)=>a+b,0)||1; const pN=pcpF.map(v=>v/sumF);
    const fold=(arr:number[])=>{ const r=arr.map((v,i)=> v + 0.60*(arr[(i+7)%12]||0) + 0.30*(arr[(i+4)%12]||0) + 0.25*(arr[(i+3)%12]||0)); const t=r.reduce((a,b)=>a+b,0)||1; return r.map(x=>x/t); };
    const pf=fold(pN);
    const KS_MAJ=[6.35,2.23,3.48,2.33,4.38,4.09,2.52,5.19,2.39,3.66,2.29,2.88];
    const KS_MIN=[6.33,2.68,3.52,5.38,2.60,3.53,2.54,4.75,3.98,2.69,3.34,3.17];
    const rot=(a:number[],n:number)=>a.map((_,i)=>a[(i-n+12)%12]); const dot=(a:number[],b:number[])=>a.reduce((s,v,i)=>s+v*b[i],0);
    let br=0,bs=-Infinity; for(let r=0;r<12;r++){ const pr=rot(pf,r); const sc=Math.max(dot(pr,KS_MAJ),dot(pr,KS_MIN)); if(sc>bs){bs=sc;br=r;} }
    votes[br]+= w;
  }
  const s = pcp.reduce((a,b)=>a+b,0)||1; for(let i=0;i<12;i++) pcp[i]/=s;
  // simple fold: add 5th/3rd back to root color
  const r = pcp.map((v,i)=> v + 0.60*(pcp[(i+7)%12]||0) + 0.30*(pcp[(i+4)%12]||0) + 0.25*(pcp[(i+3)%12]||0));
  const t = r.reduce((a,b)=>a+b,0)||1; return r.map(v=>v/t);
}

function decideKeyFromPCP(pcp:number[]): { keyPc:number; mode:'major'|'minor'; conf:number }{
  // Rotate to all roots and score with KS profiles + root heuristics
  const KS_MAJ=[6.35,2.23,3.48,2.33,4.38,4.09,2.52,5.19,2.39,3.66,2.29,2.88];
  const KS_MIN=[6.33,2.68,3.52,5.38,2.60,3.53,2.54,4.75,3.98,2.69,3.34,3.17];
  const rot=(a:number[],n:number)=>a.map((_,i)=>a[(i-n+12)%12]);
  const dot=(a:number[],b:number[])=>a.reduce((s,v,i)=>s+v*b[i],0);
  const scores:number[]=[]; const modes:('major'|'minor')[]=[]; const roots:number[]=[];
  const voteMax = Math.max(...votes, 1);
  for(let r=0;r<12;r++){
    const pr=rot(pcp,r);
    const maj=dot(pr,KS_MAJ), min=dot(pr,KS_MIN);
    const ks=Math.max(maj,min); const mode= maj>=min?'major':'minor';
    modes[r]=mode;
    const thirdBlend = 0.6*pr[4] + 0.6*pr[3];
    const rootScore = 4.2*pr[0] + 2.15*pr[7] + 1.35*thirdBlend + 0.45*pr[10] + 0.20*pr[11]
                    - 0.70*pr[2] - 0.55*pr[6] - 0.20*pr[1] - 0.28*pr[5] - 0.15*pr[9]
                    + 0.9*(votes[r]/voteMax);
    roots[r]=rootScore;
    scores[r]= 0.20*ks + 0.42*rootScore + 0.22*(100*pr[0]) + 0.16*(votes[r]/voteMax*100);
  }
  let best=-Infinity,bestIdx=0; for(let i=0;i<12;i++){ if(scores[i]>best){ best=scores[i]; bestIdx=i; } }
  const sorted=[...scores].sort((a,b)=>b-a); const second=sorted[1]||-Infinity; const conf = Number.isFinite(best)&&best>0? (best-second)/best : 0.0;
  return { keyPc: bestIdx, mode: modes[bestIdx], conf: Math.max(0, Math.min(1, conf)) };
}

self.onmessage = async (ev: MessageEvent<AnalyzeMsg|ReadyMsg>) => {
  const data = ev.data as any;
  if (data?.type === 'ready') return;
  if (data?.type === 'analyze'){
    await ensureEssentia();
    const pcp = computePCP(data.pcm, data.sampleRate);
    const key = decideKeyFromPCP(pcp);
    const res: EssKeyResult = { engine:'ess-js', keyPc:key.keyPc, mode:key.mode, conf:key.conf, pcp12:pcp, chordBeats:[] };
    (self as any).postMessage(res);
  }
};


