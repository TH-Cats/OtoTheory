// src/components/PresetsBar.tsx
import { playProgression } from '@/lib/progression/player';
import * as t from '@/lib/telemetry';

const presets = [
  { id:'p1', name:'I–V–vi–IV', roman:['I','V','vi','IV'] },
  { id:'p2', name:'ii–V–I', roman:['ii','V','I'] },
];

export default function PresetsBar({ toFreqs }:{ toFreqs:(roman:string)=>number[] }) {
  return (
    <div className="ot-card">
      <h3 className="ot-h3">Presets</h3>
      <div className="ot-chip-row">
        {presets.map(p=>(
          <button key={p.id} className="ot-chip" onClick={()=>{
            const seq = p.roman.map(r => ({ freqs: toFreqs(r) }));
            playProgression(seq);
            t.track('preset_inserted', { page: 'chord_progression', id: p.id });
          }}>
            {p.name}
          </button>
        ))}
      </div>
    </div>
  );
}
