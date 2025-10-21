"use client";
import { useOverlay } from '@/state/overlay';
import * as t from '@/lib/telemetry';
import { isHeptatonic, isPentOrBlues } from '@/lib/scaleCatalog';
import { player } from '@/lib/audio/player';
import { useLocale } from '@/contexts/LocaleContext';
import { getDiatonicLabel, getDiatonicTooltip } from '@/lib/i18n/diatonic';

export function DiatonicTable({scaleId, rows, onAddToProgression}:{scaleId:string, rows:{id:string, kind:'Open'|'Capo', notes:number[]}[], onAddToProgression?: (degree: string, quality?: string) => void}) {
  const { setChordFromUser, resetChord } = useOverlay();
  const { locale } = useLocale();
  const hepta = isHeptatonic(scaleId);
  // Triad interval tables（簡易）
  const TRIAD_MAJOR = [0,4,7] as const;
  const TRIAD_MINOR = [0,3,7] as const;
  const TRIAD_DIM   = [0,3,6] as const;
  const triadFor = (degreeIdx: number): readonly number[] => {
    const d = degreeIdx % 7;
    if (/aeolian/i.test(scaleId)) {
      // natural minor: i, ii°, III, iv, v, VI, VII
      return [TRIAD_MINOR, TRIAD_DIM, TRIAD_MAJOR, TRIAD_MINOR, TRIAD_MINOR, TRIAD_MAJOR, TRIAD_MAJOR][d];
    }
    // default: ionian major: I, ii, iii, IV, V, vi, vii°
    return [TRIAD_MAJOR, TRIAD_MINOR, TRIAD_MINOR, TRIAD_MAJOR, TRIAD_MAJOR, TRIAD_MINOR, TRIAD_DIM][d];
  };
  return (
    <div className="ot-dia-wrap">
      <div className="ot-dia" role="table" aria-label="Diatonic chords">
        <div className="ot-dia-row" role="row">
          <div className="ot-dia-th" role="columnheader" aria-hidden></div>
          {[1,2,3,4,5,6,7].map(degree => (
            <div 
              key={degree} 
              className="ot-dia-th" 
              role="columnheader"
              title={getDiatonicTooltip(degree, locale)}
            >
              {getDiatonicLabel(degree, locale)}
            </div>
          ))}
        </div>
        {rows.map(r=>{
          const disabled = r.kind==='Capo' || (!hepta && r.kind!=='Open');
          return (
            <div key={r.id} className="ot-dia-row" role="row">
              <div className="ot-dia-th" role="rowheader">{r.id}</div>
              {r.notes.map((note, cIdx) => (
                <div key={cIdx} className="ot-dia-cell">
                  <div className="ot-chip-row">
                    <button
                      type="button"
                      className={`ot-dia-chip ${disabled?'opacity-50':'cursor-pointer'}`}
                      disabled={disabled}
                      onClick={async ()=>{
                        if (disabled) return;
                        // 同じセルを再選択でリセット
                        if ((window as any).__OT_LAST_CHORD_ID__ === r.id && (window as any).__OT_LAST_CHORD_NOTE__ === note) {
                          resetChord();
                          (window as any).__OT_LAST_CHORD_ID__ = null;
                          (window as any).__OT_LAST_CHORD_NOTE__ = null;
                          return;
                        }
                        setChordFromUser({ chordId: r.id, notes: [note] });
                        (window as any).__OT_LAST_CHORD_ID__ = r.id;
                        (window as any).__OT_LAST_CHORD_NOTE__ = note;
                        t.track('diatonic_pick', { page:'chord_progression', value: r.id });
                        // 和音再生（3和音・軽ストラム）
                        await player.resume();
                        const base = 60 + note; // C4=60基準
                        const intervals = triadFor(cIdx);
                        const midis = intervals.map(iv => base + iv);
                        player.playChord(midis, 'lightStrum', 260);
                      }}
                      aria-label={`Chord ${r.id}`}
                    >
                      {note}
                    </button>
                    {!disabled && onAddToProgression && (
                      <button
                        type="button"
                        className="ot-btn-ghost ot-chip-add"
                        onClick={() => onAddToProgression(`I${cIdx + 1}`, note.toString())}
                        aria-label={`Add ${r.id} to progression`}
                        title="Add to progression"
                      >
                        +
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          );
        })}
      </div>
    </div>
  );
}


