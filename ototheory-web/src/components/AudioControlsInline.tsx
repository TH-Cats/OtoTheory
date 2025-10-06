"use client";
import { useEffect, useState } from "react";
import { player } from "@/lib/audio/player";

export default function AudioControlsInline(){
  const [enabled,setEnabled] = useState<boolean>(player.isEnabled?.() ?? true);
  const [vol,setVol] = useState<number>(player.getVolume?.() ?? 0.8);
  useEffect(()=>{ player.setVolume?.(vol); },[vol]);
  const toggle = ()=>{ const next=!enabled; setEnabled(next); player.toggleEnabled?.(next); };
  return (
    <div className="ot-audio-inline">
      <div className="ot-audio-ctrl">
        <span className="ot-audio-label" aria-hidden="true">Sound</span>
        <button
          type="button"
          className="ot-switch ot-switch--xs"
          role="switch"
          aria-checked={enabled}
          data-checked={enabled}
          onClick={toggle}
          aria-label={enabled?"Turn sound off":"Turn sound on"}
          title={enabled?"Sound On":"Sound Off"}
        >
          <span className="knob" />
        </button>
      </div>
      <div className="ot-audio-ctrl">
        <span className="ot-audio-label">Volume</span>
        <input
          type="range"
          min={0}
          max={1}
          step={0.01}
          value={vol}
          onChange={(e)=>setVol(parseFloat(e.currentTarget.value))}
          aria-label="Volume"
          disabled={!enabled}
          style={{opacity: enabled?1:.4}}
        />
      </div>
    </div>
  );
}


