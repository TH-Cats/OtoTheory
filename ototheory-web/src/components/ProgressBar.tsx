"use client";
import { useEffect, useRef } from "react";

export function ProgressBar({ valueMs, totalMs, label, ariaLive = "off", color }:{ valueMs:number; totalMs:number; label?:string; ariaLive?:"off"|"polite"|"assertive"; color?:string; }){
  const pct = Math.max(0, Math.min(100, (valueMs / Math.max(1, totalMs)) * 100));
  const remain = Math.max(0, Math.ceil((totalMs - valueMs) / 1000));
  const liveRef = useRef<HTMLDivElement>(null);
  useEffect(()=>{ if (ariaLive !== 'off' && liveRef.current) liveRef.current.textContent = `${remain}s`; }, [remain, ariaLive]);
  return (
    <div className="ot-prog">
      <div className="ot-prog-head">
        <span>{label ?? 'Progress'}</span>
        <span className="ot-prog-nums">{Math.floor(valueMs/1000)}s / {Math.floor(totalMs/1000)}s</span>
      </div>
      <div className="ot-prog-rail" aria-label={label ?? 'Progress'}>
        <div className="ot-prog-fill" style={{ width: `${pct}%`, background: color ?? 'var(--primary)' }} />
      </div>
      <div aria-live={ariaLive} className="sr-only" ref={liveRef} />
    </div>
  );
}



