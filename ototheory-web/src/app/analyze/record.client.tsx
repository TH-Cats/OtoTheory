"use client";
import React, { useEffect, useMemo, useRef, useState } from "react";
import { ProgressBar } from "@/components/ProgressBar";
import { isFeatureEnabled } from "@/lib/feature";
import { track } from "@/lib/telemetry";
import type { OtEvent } from "@/lib/telemetry";
import { listScales, getScaleMask12 } from "@/lib/scaleCatalog";
import type { AnalyzeData } from "@/components/ResultCard";

export default function RecordPanel({ onResult, onReset, onAnalyzeData }:{ onResult:(cands:{keyPc:number;mode:'major'|'minor';confidence:number;why?:string}[])=>void; onReset?():void; onAnalyzeData?(data: AnalyzeData): void }){
  const enabled = isFeatureEnabled('audioSuggest');
  const [recState, setRecState] = useState<'idle'|'recording'|'processing'|'playback'|'error'>("idle");
  const [msg, setMsg] = useState<string>("");
  const mediaRef = useRef<MediaRecorder|null>(null);
  const chunks = useRef<BlobPart[]>([]);
  const startAt = useRef<number>(0);
  const [elapsedMs, setElapsedMs] = useState<number>(0);
  const [maxSec, setMaxSec] = useState<number>(()=>{
    const env = (process.env.NEXT_PUBLIC_AUDIO_MAX_SEC||'').trim();
    const n = Number(env||20);
    return Number.isFinite(n) ? Math.max(4, Math.min(30, n)) : 20;
  });
  const rafRef = useRef<number|undefined>(undefined);
  const lastBlobRef = useRef<Blob|null>(null);
  const audioUrlRef = useRef<string|undefined>(undefined);
  const audioCtxRef = useRef<AudioContext|null>(null);
  const sourceRef = useRef<AudioBufferSourceNode|null>(null);
  const playDurMsRef = useRef<number>(0);
  const [lastDurMs, setLastDurMs] = useState<number>(0);
  const processingStartRef = useRef<number>(0);
  const [procMs, setProcMs] = useState<number>(0); // Analyzing の疑似プログレス
  const PROC_TOTAL_MS = 5000; // 見せ方用の全体尺（5s）

  useEffect(()=>{ return () => { if (mediaRef.current && mediaRef.current.state !== 'inactive') mediaRef.current.stop(); if (rafRef.current) cancelAnimationFrame(rafRef.current); }; },[]);

  // ticker for recording/playback
  useEffect(()=>{
    if (recState!== 'recording' && recState !== 'playback') return;
    const tick = () => {
      const ms = performance.now() - startAt.current;
      setElapsedMs(ms);
      if (recState === 'playback' && ms >= playDurMsRef.current) { setRecState('idle'); return; }
      rafRef.current = requestAnimationFrame(tick);
    };
    rafRef.current = requestAnimationFrame(tick);
    return () => { if (rafRef.current) cancelAnimationFrame(rafRef.current); };
  }, [recState]);

  // ticker for processing (pseudo progress bar)
  useEffect(()=>{
    if (recState !== 'processing') return;
    let raf: number;
    const tick = () => {
      const ms = performance.now() - processingStartRef.current;
      // 解析完了までは 92% で頭打ち → 完了時に100%へ
      const cap = PROC_TOTAL_MS * 0.92;
      setProcMs(Math.min(ms, cap));
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => { cancelAnimationFrame(raf); };
  }, [recState]);

  if (!enabled) return null;

  const start = async () => {
    try {
      const types = [ 'audio/webm;codecs=opus', 'audio/mp4;codecs=mp4a.40.2', 'audio/aac' ];
      const mimeType = types.find(t => (window as any).MediaRecorder?.isTypeSupported?.(t)) || 'audio/webm;codecs=opus';
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          noiseSuppression: false,
          echoCancellation: false,
          autoGainControl: false
        } as MediaTrackConstraints
      });
      const mr = new MediaRecorder(stream, { mimeType });
      mediaRef.current = mr;
      chunks.current = [];
      startAt.current = performance.now();
      mr.ondataavailable = (ev) => { if (ev.data && ev.data.size > 0) chunks.current.push(ev.data); };
      mr.onstop = async () => {
        setRecState('processing');
        processingStartRef.current = performance.now();
        setProcMs(0);
        track('audio_record_stop', { page:'analyze' });
        try {
          const blob = new Blob(chunks.current, { type: mimeType });
          lastBlobRef.current = blob;
          const arr = await blob.arrayBuffer();
          const ctx = new (window.AudioContext || (window as any).webkitAudioContext)();
          const buf = await ctx.decodeAudioData(arr.slice(0));
          // downmix mono
          const ch0 = buf.getChannelData(0);
          let mono: Float32Array;
          if (buf.numberOfChannels > 1) {
            const ch1 = buf.getChannelData(1);
            mono = new Float32Array(buf.length);
            for (let i=0;i<buf.length;i++) mono[i] = (ch0[i] + ch1[i]) * 0.5;
          } else mono = ch0;
          // length guard
          const dur = buf.duration;
          if (dur < 4) { setRecState('error'); setMsg('Recording too short (<4s)'); return; }
          setLastDurMs(Math.round(dur*1000));
          // worker (essentia-js) or inline fallback
          const runInline = () => {
            try {
              // --- inline analyze (minimal, same as worker) ---
              const hann = (n:number,N:number)=>0.5*(1-Math.cos(2*Math.PI*n/(N-1)));
              const midiToFreq = (m:number)=>440*Math.pow(2,(m-69)/12);
              const goertzel = (frame:Float32Array,sr:number,freq:number)=>{
                const N=frame.length; const k=Math.round(0.5+(N*freq)/sr); const w=(2*Math.PI/N)*k; const cosine=Math.cos(w); const coeff=2*cosine; let s_prev=0,s_prev2=0; for(let i=0;i<N;i++){ const s=frame[i]+coeff*s_prev-s_prev2; s_prev2=s_prev; s_prev=s; } return s_prev2*s_prev2+s_prev*s_prev - coeff*s_prev*s_prev2; };
              const frameSize=Math.max(1024,Math.min(8192,Math.round(buf.sampleRate*0.1)));
              const hop=Math.max(512,Math.round(frameSize/2));
              const pcp=new Array(12).fill(0);
              const votes=new Array(12).fill(0); // temporal consensus (weighted votes per short frame)
              const tmp=new Float32Array(frameSize);
              const startMidi=40,endMidi=88; // HPF: include low E (~82Hz)
              for(let off=0; off+frameSize<=mono.length; off+=hop){
                let energy=0; for(let i=0;i<frameSize;i++){ const v=mono[off+i]*hann(i,frameSize); tmp[i]=v; energy+=v*v; }
                if(energy<1e-6) continue;
                // cadence weighting: last ~1.2s gets ×3.0
                const frameEndSec = (off + frameSize) / buf.sampleRate;
                const remaining = Math.max(0, buf.duration - frameEndSec);
                const w = remaining <= 1.2 ? 3.2 : 1.0;
                const pcpF = new Array(12).fill(0);
                // セント許容：各半音の ±50c も併合して堅牢化
                for(let m= startMidi; m<=endMidi; m++){
                  const f0=midiToFreq(m); if(f0>buf.sampleRate/2) break;
                  const fL=midiToFreq(m-0.5); const fH=midiToFreq(m+0.5);
                  const e0=goertzel(tmp,buf.sampleRate,f0);
                  const eL=goertzel(tmp,buf.sampleRate,fL);
                  const eH=goertzel(tmp,buf.sampleRate,fH);
                  const add = (e0*1.0 + eL*0.6 + eH*0.6);
                  pcp[m%12]+= w * add;
                  pcpF[m%12]+= add;
                }
                // 短時間コンセンサス：この短窓のPCPで最良rootに投票
                const sumF = pcpF.reduce((a,b)=>a+b,0)||1; const pcpFn = pcpF.map(v=>v/sumF);
                const foldH = (arr:number[])=>{
                  const r = arr.map((v,i)=> v + 0.60*(arr[(i+7)%12]||0) + 0.35*(arr[(i+4)%12]||0) + 0.25*(arr[(i+3)%12]||0));
                  const s = r.reduce((a,b)=>a+b,0)||1; return r.map(x=>x/s);
                };
                const pf = foldH(pcpFn);
                const KS_MAJ = [6.35,2.23,3.48,2.33,4.38,4.09,2.52,5.19,2.39,3.66,2.29,2.88];
                const KS_MIN = [6.33,2.68,3.52,5.38,2.60,3.53,2.54,4.75,3.98,2.69,3.34,3.17];
                const rot=(a:number[],n:number)=>a.map((_,i)=>a[(i-n+12)%12]);
                const dot=(a:number[],b:number[])=>a.reduce((s,v,i)=>s+v*b[i],0);
                let br=0,bs=-Infinity; for(let r=0;r<12;r++){ const pr=rot(pf,r); const sc=Math.max(dot(pr,KS_MAJ), dot(pr,KS_MIN)); if(sc>bs){ bs=sc;br=r; } }
                votes[br]+= w;
              }
              const sum=pcp.reduce((a,b)=>a+b,0)||1; for(let i=0;i<12;i++) pcp[i]/=sum;
              // HPCP-style folding: project strong harmonics back to the root
              function foldHPCP(arr:number[]):number[]{
                const r = arr.map((v,i)=> (
                  v
                  + 0.60*(arr[(i+7)%12]||0)   // perfect fifth → root
                  + 0.35*(arr[(i+4)%12]||0)   // major third → root
                  + 0.25*(arr[(i+3)%12]||0)   // minor third → root
                ));
                const s = r.reduce((a,b)=>a+b,0)||1;
                return r.map(v=> v/s);
              }
              const pcpFolded = foldHPCP(pcp);
              // ---- POST to server API with PCP12 JSON (Phase1) ----
              (async () => {
                const res = await fetch('/api/analyze', {
                  method: 'POST',
                  headers: { 'content-type': 'application/json' },
                  body: JSON.stringify({ pcp12: Array.from(pcpFolded), lengthSec: dur })
                });
                const jd = await res.json();
                if (!res.ok) throw new Error(String(jd?.error||'analyze_failed'));
                try {
                  (window as any).__OT_LAST_ORIGIN__ = 'record';
                  (window as any).__OT_LAST_PCP12__ = Array.from(pcpFolded);
                  (window as any).__OT_LAST_CONF__ = jd?.conf;
                } catch {}
                const kcs = (jd?.keyCandidates ?? []) as { keyPc:number; mode:'major'|'minor'; confidence:number }[];
                onResult(kcs);
                onAnalyzeData?.(jd as AnalyzeData);
              })().catch((e)=>{ setRecState('error'); setMsg(String(e?.message||e)); });
              setProcMs(PROC_TOTAL_MS);
              const elapsed=performance.now()-processingStartRef.current; const hold=Math.max(0,1400-elapsed); setTimeout(()=> setRecState('idle'), hold);
            } catch (e:any) {
              setRecState('error'); setMsg(String(e?.message||e));
            }
          };

          // Dev環境のTurbopack HMRがWorkerを解決できない場合があるため、
          // 本番ビルド時のみWorkerを使う（開発時は常にinlineへフォールバック）
          const useEss = (process.env.NEXT_PUBLIC_FEATURE_KEY_ENGINE||'').trim()==='essentia-js' && process.env.NODE_ENV==='production';
          if (useEss) {
            try {
              (window as any).__OT_LAST_ENGINE__ = 'ess-js';
              const worker = new Worker(new URL('../../workers/essAudio.worker.ts', import.meta.url), { type: 'module' });
              worker.onmessage = (e: MessageEvent<any>) => {
                const res = e.data;
                try {
                  (window as any).__OT_LAST_CONF__ = res?.conf;
                  (window as any).__OT_LAST_PCP12__ = res?.pcp12;
                } catch {}
                const top = [{ keyPc: res.keyPc, mode: res.mode, confidence: Math.max(0, Math.min(1, res.conf)) }];
                onResult(top as any);
                track('audio_analyze_conf' as OtEvent, { engine:'ess-js', conf: res.conf, keyPc: res.keyPc, mode: res.mode });
                setProcMs(PROC_TOTAL_MS);
                const elapsed=performance.now()-processingStartRef.current; const hold=Math.max(0,1400-elapsed); setTimeout(()=> setRecState('idle'), hold);
                worker.terminate();
              };
              // assemble mono pcm for worker
              const ctx2 = new (window.AudioContext || (window as any).webkitAudioContext)();
              const buf2 = await ctx2.decodeAudioData(arr.slice(0));
              const ch = buf2.getChannelData(0);
              worker.postMessage({ type:'analyze', pcm: ch, sampleRate: buf2.sampleRate }, [ch.buffer]);
            } catch {
              runInline();
            }
          } else {
            runInline();
          }
        } catch (err: any) {
          setRecState('error'); setMsg(String(err?.message||err));
        }
      };
      mr.start();
      setElapsedMs(0);
      setLastDurMs(0);
      setRecState('recording');
      track('audio_record_start', { page:'analyze' });
      // progress ticker (<=250ms)
      const tick = () => {
        const ms = performance.now() - startAt.current;
        setElapsedMs(ms);
        if (mediaRef.current && mediaRef.current.state === 'recording') rafRef.current = requestAnimationFrame(tick);
      };
      rafRef.current = requestAnimationFrame(tick);
      // auto-stop at maxSec
      setTimeout(() => { if (mediaRef.current && mediaRef.current.state === 'recording') mediaRef.current.stop(); }, maxSec*1000);
    } catch (err: any) {
      setRecState('error'); setMsg(String(err?.message||err));
    }
  };

  const stop = () => { try { mediaRef.current?.stop(); } catch {} };

  // last-take playback
  const playLast = async () => {
    try {
      if (!lastBlobRef.current) return;
      const arr = await lastBlobRef.current.arrayBuffer();
      const ctx = audioCtxRef.current ?? new (window.AudioContext || (window as any).webkitAudioContext)();
      audioCtxRef.current = ctx;
      const buf = await ctx.decodeAudioData(arr.slice(0));
      if (sourceRef.current) { try { sourceRef.current.stop(); } catch {} }
      const src = ctx.createBufferSource();
      src.buffer = buf;
      src.connect(ctx.destination);
      try { await ctx.resume(); } catch {}
      src.start();
      sourceRef.current = src;
      playDurMsRef.current = Math.round(buf.duration*1000);
      startAt.current = performance.now();
      setElapsedMs(0);
      setRecState('playback');
      src.onended = () => { setRecState('idle'); };
      track('audio_playback_last_take', { page:'analyze', ms: Math.round(buf.duration*1000) });
    } catch {}
  };
  const stopPlay = () => { try { sourceRef.current?.stop(); } catch {} };

  return (
    <div className="mt-2">
      <div className="ot-recbar" aria-label="Record controls">
        <button
          type="button"
          className={`ot-btn-rec ${recState==='recording' ? 'ot-btn-rec--active' : 'ot-btn-rec--idle'}`}
          onClick={recState==='recording' ? undefined : start}
          aria-pressed={recState==='recording'}
          aria-disabled={recState==='recording' || recState==='processing'}
          disabled={recState==='recording' || recState==='processing'}
          title={recState==='recording' ? 'Recording…' : `録音を開始（最大 ${maxSec}s）`}
        >
          <span className="dot" aria-hidden />
          REC
        </button>

        {recState==='recording' && (
          <button type="button" className="ot-btn-stop" onClick={stop} title="録音を停止">■ Stop</button>
        )}

        {/* 残時間や状態のテキストはProgressBar側に集約（ここでは表示しない） */}
      </div>
      {recState==='recording' && (
        <div className="mt-2" style={{minWidth:240, maxWidth:'min(480px, 100%)'}}>
          <ProgressBar valueMs={elapsedMs} totalMs={maxSec*1000} label="Recording" ariaLive="polite" color="#ff2d55" />
        </div>
      )}
      {(recState!=='recording' && recState!=='processing' && lastBlobRef.current) && (
        <div className="mt-0.5" style={{minWidth:240, maxWidth:'min(480px, 100%)', marginTop: '4px'}}>
          <ProgressBar
            valueMs={recState==='playback' ? Math.min(elapsedMs, lastDurMs) : 0}
            totalMs={lastDurMs||1}
            label={recState==='playback' ? 'Playback (Last take)' : 'Last take'}
            color={recState==='playback' ? '#ff2d55' : '#e5e7eb'}
          />
        </div>
      )}
      {recState==='processing' && (
        <div className="ot-analyzing">
          <div className="ot-spinner" aria-hidden />
          <div className="ot-anlz-title">Analyzing</div>
          <div className="ot-ai-scan" aria-hidden>
            <div className="ot-ai-bars" role="progressbar" aria-label="Analyzing">
              {Array.from({length:12}).map((_,i)=> (
                <span key={i} style={{ animationDelay: `${i*90}ms` }} />
              ))}
            </div>
          </div>
        </div>
      )}
      {/* placeholder spacing: processing=24px (avoid jump) / otherwise=8px */}
      <div style={{height: recState==='processing' ? 24 : 8}} aria-hidden />
      {recState==='error' && <span className="ml-2 text-xs text-red-500">{msg}</span>}
      {/* last take controls */}
      {lastBlobRef.current && recState!=='recording' && (
        <span className="text-xs" style={{display:'inline-flex', gap:12, marginTop: 2}}>
          <button className="btn-ghost" onClick={playLast}>▶︎ Last take</button>
          <button className="btn-ghost" onClick={stopPlay}>⏹︎ Stop</button>
          <button className="btn-ghost" onClick={()=>{ lastBlobRef.current=null; setLastDurMs(0); setElapsedMs(0); try{ (window as any).__OT_LAST_ORIGIN__='manual'; (window as any).__OT_LAST_PCP12__=null; }catch{}; onReset?.(); }}>⟲ Reset</button>
        </span>
      )}
    </div>
  );
}


