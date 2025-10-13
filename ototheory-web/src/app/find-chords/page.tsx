"use client";
import { Suspense, useCallback, useEffect, useMemo, useRef, useState } from "react";
import AdSlot from "@/components/AdSlot.client";
import { getDiatonicChordsFor, type NoteLetter } from "@/lib/music-theory";
import { toRoman, type Mode } from "@/lib/theory/roman";
import { useSearchParams } from "next/navigation";
import Fretboard from "@/components/Fretboard";
import { OverlayProvider } from "@/state/overlay";
import DiatonicCapoTable from "@/components/DiatonicCapoTable";
import { useRovingTabs } from "@/hooks/useRovingTabs";
import InfoDot from "@/components/ui/InfoDot";
import { useAnalysisStore } from "@/store/analysisStore";
import { getScalePitchesById } from "@/lib/scales";
import { SCALE_CATALOG, type ScaleId } from "@/lib/scaleCatalog";
import { PC_NAMES } from "@/lib/music/constants";
import { track } from "@/lib/telemetry";
import ScaleTable from "@/components/ScaleTable";
import { ChordFormsPopover } from "@/components/ChordFormsPopover";
import { buildForm, type FormKind, type FormShape, type Quality } from "@/lib/chordForms";
import SubstituteCard from "@/components/SubstituteCard";

export default function FindChordsPage() {
  return (
    <Suspense fallback={<div className="ot-page">Loading...</div>}>
      <FindChordsContent />
    </Suspense>
  );
}

function FindChordsContent() {
  const params = useSearchParams();
  const KEY_OPTIONS: NoteLetter[] = useMemo(() => PC_NAMES as unknown as NoteLetter[], []);
  const UI_SCALES = SCALE_CATALOG; // SSOT カタログ

  const [keyTonic, setKeyTonic] = useState<NoteLetter>((params.get('key') as NoteLetter) || 'C');
  const initialMode: ScaleId = (params.get('mode') === 'minor') ? 'Aeolian' : 'Ionian';
  const [selScaleId, setSelScaleId] = useState<ScaleId>(initialMode);
  const isHept = useMemo(() => {
    const def = UI_SCALES.find(s => s.id === selScaleId);
    return (def?.degrees.length ?? 7) === 7;
  }, [selScaleId]);

  const diatonic = useMemo(() => {
    const sel = UI_SCALES.find(s => s.id === selScaleId)!;
    const sevenNote = sel.degrees.length === 7;
    if (!sevenNote) return [] as any[];
    const quality = (sel.id==='Aeolian' ? 'minor' : 'major') as any;
    return getDiatonicChordsFor({ tonic: keyTonic, quality, scale: sel.id as any } as any).chords;
  }, [keyTonic, selScaleId]);

  const mode: Mode = useMemo(() => (selScaleId === 'Aeolian' ? 'minor' : 'major'), [selScaleId]);

  type Display = 'degrees'|'names';
  const keyRowRef = useRef<HTMLDivElement | null>(null);
  useRovingTabs(keyRowRef, { orientation: "horizontal" });
  const fbToggleRef = useRef<HTMLSpanElement | null>(null);
  useRovingTabs(fbToggleRef, { orientation: "horizontal" });
  const [display, setDisplay] = useState<Display>('degrees');
  const [fbCapo, setFbCapo] = useState<number>(0);
  const [overlayNotes, setOverlayNotes] = useState<string[]|null>(null);
  const [previewScaleId, setPreviewScaleId] = useState<ScaleId | null>(null);
  const [selectedCellId, setSelectedCellId] = useState<string | null>(null);
  const [lastPickedPcs, setLastPickedPcs] = useState<number[]|null>(null);
  const [formsPop, setFormsPop] = useState<null | { at:{x:number;y:number}; rootPc:number; quality:Quality }>(null);
  const [formShape, setFormShape] = useState<FormShape | null>(null);
  const resetForms = useCallback(() => { setFormsPop(null); setFormShape(null); }, []);

  // Debug quick-check: ensure overlay wiring is correct
  useEffect(() => {}, [display, overlayNotes]);
  const { selectKey } = useAnalysisStore();
  // auto-refresh; no manual "Show Chords" button

  const onPickKey = (k: NoteLetter) => {
    setKeyTonic(k);
    const q = (selScaleId === 'Aeolian') ? 'minor' : 'major';
    const modeLabel = q === 'major' ? 'Major' : 'Minor';
    const tonicPc = KEY_OPTIONS.indexOf(k);
    selectKey({ tonic: tonicPc as any, mode: modeLabel as any });
    track('key_pick', { page: 'find-chords', key: k, mode: modeLabel });
    // local-only; store scale is not required here
    void refreshDiatonicAndOverlay();
  };

  const onPickScale = (id: ScaleId) => {
    setSelScaleId(id);
    const tonicPc = KEY_OPTIONS.indexOf(keyTonic);
    track('scale_pick', { page: 'find-chords', scale: id, key: keyTonic });
    void refreshDiatonicAndOverlay();
  };

  async function refreshDiatonicAndOverlay() {
    // Recompute store to refresh diatonic/capo table and set a base overlay
    const tonicPc = KEY_OPTIONS.indexOf(keyTonic);
    const uiScale = (selScaleId === 'Aeolian') ? 'minor' : 'major';
    const modeLabel = uiScale === 'major' ? 'Major' : 'Minor';
    selectKey({ tonic: tonicPc as any, mode: modeLabel as any });
    // local-only; store scale is not required here
    // base view: show only page scale; no chord overlay yet
    setOverlayNotes(null);
  }

  useEffect(() => {
    // 初期表示でも現在のKey/Scaleに合わせてベースを反映
    void refreshDiatonicAndOverlay();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const scaleRootPc = useMemo(()=> KEY_OPTIONS.indexOf(keyTonic), [keyTonic]);
  const scaleTypeForUI = useMemo(()=> selScaleId, [selScaleId]);

  const scaleNotesForCurrentKey = () => {
    const pcs = getScalePitchesById(scaleRootPc as any, scaleTypeForUI as any);
    return pcs.map(pc => PC_NAMES[pc] as string);
  };

  // Reset overlay to current scale and clear selection
  const resetToScale = useCallback(() => {
    setDisplay('degrees');
    setFbCapo(0);
    setOverlayNotes(null);
    setPreviewScaleId(null);
    setSelectedCellId(null);
    setLastPickedPcs(null);
    resetForms();
    track('overlay_reset', { page: 'find-chords', scale: selScaleId, key: keyTonic });
  }, [scaleRootPc, scaleTypeForUI, resetForms]);

  // Esc key to reset back to scale view
  useEffect(() => {
    const h = (e: KeyboardEvent) => { if (e.key === 'Escape') resetToScale(); };
    window.addEventListener('keydown', h);
    return () => window.removeEventListener('keydown', h);
  }, [resetToScale]);

  // ---- chord tone helper (minimal triad/7th) ----
  const P = PC_NAMES as unknown as readonly string[];
  const idxNote = (n: string) => P.indexOf(n as any);
  const shift = (n: string, semi: number) => P[(idxNote(n) + semi + 120) % 12];
  function tonesFor(sym: string): string[] {
    const m = (sym || '').trim().match(/^([A-G](?:#|b)?)(.*)$/);
    if (!m) return [];
    const root = m[1]!; const q = (m[2] || '').trim();
    let iv = [0,4,7];
    if (/^m(?!aj)/.test(q)) iv = [0,3,7];
    if (/dim|o/.test(q)) iv = [0,3,6];
    if (/aug|\+/.test(q)) iv = [0,4,8];
    if (/m7b5/.test(q)) iv = [0,3,6,10];
    else if (/maj7|M7/.test(q)) iv = Array.from(new Set([...iv,11]));
    else if (/m7/.test(q)) iv = Array.from(new Set([...iv,10]));
    else if (/7/.test(q)) iv = Array.from(new Set([...iv,10]));
    return iv.map(semi => shift(root, semi));
  }

  return (
    <OverlayProvider>
    <main className="ot-page ot-stack" data-page="find-chords">
      <h1 className="sr-only">Find Chords</h1>
      {/* Select Key & Scale */}
      <section className="ot-card">
        <h2 className="ot-h2">Select Key &amp; Scale</h2>
        <div className="mt-3 grid sm:grid-cols-2 gap-3">
        <div>
          <label className="block text-sm mb-1">Key</label>
          <div className="flex flex-col gap-2" role="tablist" aria-label="Select key" ref={keyRowRef}>
            {[["C","C#","D","Eb","E","F"],["F#","G","Ab","A","Bb","B"]].map((row, ri)=> (
              <div key={`krow-${ri}`} ref={ri===0?keyRowRef as any:undefined} className="flex flex-wrap gap-2">
                {row.map(k => (
                  <button
                    key={k}
                    role="tab"
                    aria-selected={keyTonic === (k as NoteLetter)}
                    tabIndex={keyTonic === (k as NoteLetter) ? 0 : -1}
                    className={["chip","chip--key", keyTonic===k?"chip--active":""].join(" ")}
                    data-roving="item"
                    onClick={()=>{ onPickKey(k as NoteLetter); }}
                    title={`Key ${k}`}
                  >{k}</button>
                ))}
              </div>
            ))}
          </div>
        </div>
        <div>
          <label htmlFor="scale" className="block text-sm mb-1">
            <span>Scale</span>
            {(() => {
              const cur = UI_SCALES.find(s => s.id === selScaleId)!;
              const notesInC = getScalePitchesById(0, cur.id).map(pc => PC_NAMES[pc]).join(' ');
              const defaultAbout = `${cur.group} scale — ${cur.degrees.length}-note pattern.`;
              return (
                <InfoDot title={cur.display.en} className="ml-2" linkHref="/resources/glossary" linkLabel="Glossary">
                  <div className="text-sm">
                    <div className="mb-1"><b>Degrees:</b> {cur.degrees.join(' ')}</div>
                    <div className="mb-1"><b>Notes in C:</b> {notesInC}</div>
                    <div className="mb-1"><b>About:</b> {cur.info?.oneLiner ?? defaultAbout}</div>
                    {!!cur.info?.examples?.length && (
                      <div className="mt-2">
                        <b className="text-xs">Song examples</b>
                        <ul className="text-xs mt-1 space-y-1">
                          {cur.info.examples.map((e,i)=> (
                            <li key={i}>
                              {e.url ? <a href={e.url} target="_blank" rel="noreferrer">{e.title}</a> : e.title}
                              {e.artist ? ` — ${e.artist}` : ''}{e.cue ? ` (${e.cue})` : ''}
                            </li>
                          ))}
                        </ul>
                      </div>
                    )}
                  </div>
                </InfoDot>
              );
            })()}
          </label>
          <select
            id="scale"
            name="scale"
            className="w-full rounded border px-3 py-2 text-sm bg-transparent"
            value={selScaleId}
            onChange={(e) => onPickScale(e.target.value as ScaleId)}
          >
            {UI_SCALES.map((s) => (
              <option key={s.id} value={s.id}>{s.display.en}</option>
            ))}
          </select>
        </div>
        </div>
      </section>
      {/* Result: Diatonic → Fretboard */}
      <section className="ot-card">
        <h2 className="ot-h2">Result</h2>
        <div className="ot-stack">
          <div>
            <h3 className="ot-h3 flex items-center gap-2"><span>Diatonic</span>
              <InfoDot title="Diatonic chords" linkHref="/resources/glossary" linkLabel="Glossary">
                <p className="text-sm">Chords built only from the key’s scale tones (I–ii–iii–IV–V–vi–vii°).</p>
                <p className="text-sm mt-2">Capo rows show the shapes you fret. The sounding chord tones on the fretboard are the same as the Open row.</p>
                <p className="text-xs mt-1">See details in Reference → Capo &amp; Shapes</p>
              </InfoDot>
            </h3>
            {!isHept && (
              <p className="text-xs text-foreground/70 mt-1">
                This scale is not heptatonic; Roman numerals are hidden. Diatonic suggestions are limited to the Open row.
              </p>
            )}
            <div data-testid={isHept ? undefined : "diatonic-open-only"}>
            <DiatonicCapoTable selectedId={selectedCellId} onSelectId={(id)=>{
              // 再クリック（同じセル）は状態を変えない（プレビューはResetを使用）
              if (selectedCellId === id) { return; }
              setSelectedCellId(id);
            }} onPick={({ pcs })=>{
              const mainNotes = pcs.map(pc => PC_NAMES[pc] as string);
              setOverlayNotes(mainNotes);
              setLastPickedPcs(pcs);
              resetForms();
              track('diatonic_pick', { page:'find-chords', id:selectedCellId, scale: selScaleId, key: keyTonic });
            }} />
            </div>
          </div>
          {/* Scale table (MVP): show 2-scale suggestions for the selected chord */}
          {selectedCellId && lastPickedPcs && (
            <div className="mt-2">
              <ScaleTable
                chordQuality={detectQualityFromPcs(lastPickedPcs)}
                rootPc={scaleRootPc as any}
                onPreviewScale={(id)=>{ setPreviewScaleId(id as any); }}
                onResetPreview={()=>{ setPreviewScaleId(null); resetToScale(); }}
                openGlossary={(id)=>{ try{ window.open('/resources/glossary','_blank'); }catch{} }}
                activeScaleId={previewScaleId as any}
              />
            </div>
          )}
          {/* Substitute Chords: show alternative chords */}
          {selectedCellId && lastPickedPcs && (
            <SubstituteCard
              rootPc={scaleRootPc as any}
              quality={detectQualityFromPcs(lastPickedPcs) as any}
              degree={(() => {
                // セルIDから度数を取得 (例: "open-0" → 1, "open-1" → 2)
                const parts = selectedCellId.split('-');
                return parseInt(parts[1] || '0', 10) + 1;
              })()}
              keyContext={{
                tonic: KEY_OPTIONS.indexOf(keyTonic),
                mode: (selScaleId === 'Aeolian' ? 'Minor' : 'Major') as any
              }}
              page="find-chords"
            />
          )}
          <div>
            <h3 className="ot-h3 flex items-center justify-between">
              <span>Fretboard</span>
              <span ref={fbToggleRef} className="flex items-center gap-2" role="tablist" aria-orientation="horizontal" aria-label="Fretboard notation">
              <button role="tab" aria-selected={display==='degrees'} tabIndex={display==='degrees'?0:-1} className={["chip", display==='degrees'?"chip--on":""].join(" ")} data-roving="item" onClick={()=>{ resetForms(); setDisplay('degrees'); }}>Degrees</button>
              <button role="tab" aria-selected={display==='names'} tabIndex={display==='names'?0:-1} className={["chip", display==='names'?"chip--on":""].join(" ")} data-roving="item" onClick={()=>{ resetForms(); setDisplay('names'); }}>Names</button>
              {selectedCellId && (
                <button role="tab" aria-selected={false} tabIndex={-1} className="chip" onClick={resetToScale} aria-label="Reset">Reset</button>
              )}
              </span>
            </h3>
            <Fretboard
              overlay={{
                viewMode: 'sounding' as any,
                capo: fbCapo,
                display: display as any,
                scaleRootPc: scaleRootPc as any,
                scaleType: (previewScaleId ?? scaleTypeForUI) as any,
                showScaleGhost: Boolean(selectedCellId),
                chordNotes: overlayNotes ?? undefined,
                context: {
                  chordRootPc: lastPickedPcs && lastPickedPcs.length ? lastPickedPcs[0] : undefined,
                  quality: (() => {
                    const pcs = lastPickedPcs ?? [];
                    const q = detectQualityFromPcs(pcs.length ? pcs : [scaleRootPc]);
                    return q === 'min' ? 'min' : 'maj';
                  })(),
                },
              }}
              onRequestForms={(at, ctx)=>{
                setFormsPop({ at, rootPc: ctx.rootPc, quality: ctx.quality });
              }}
              formShape={formShape}
            />
          </div>
        </div>
      </section>

      {/* Ad Placeholder (card participates in page rhythm) */}
      <section className="ot-card ad-placeholder" aria-label="Ad">
        <AdSlot page="find_chords" format="horizontal" />
      </section>
      {formsPop && (
        <ChordFormsPopover
          at={formsPop.at}
          quality={formsPop.quality}
          rootPc={formsPop.rootPc}
          page="find-chords"
          onPick={(kind: FormKind)=>{
            const shape = buildForm(kind, formsPop.quality, formsPop.rootPc);
            setFormShape(shape);
          }}
          onClose={()=> setFormsPop(null)}
        />
      )}
    </main>
    </OverlayProvider>
  );
}

// --- helpers ---
function detectQualityFromPcs(pcs:number[]): 'maj'|'min'|'dom7'|'m7b5'|'dim' {
  const set = new Set(pcs.map(x => ((x - pcs[0] + 12) % 12)));
  // simple triad/7th checks (relative to first pc as root)
  if (set.has(0) && set.has(4) && set.has(7)) return 'maj';
  if (set.has(0) && set.has(3) && set.has(7)) return 'min';
  if (set.has(0) && set.has(3) && set.has(6)) return 'dim';
  if (set.has(0) && set.has(4) && set.has(7) && set.has(10)) return 'dom7';
  if (set.has(0) && set.has(3) && set.has(6) && set.has(10)) return 'm7b5';
  return 'maj';
}


