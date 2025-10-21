"use client";
import { Suspense, useCallback, useEffect, useMemo, useRef, useState } from "react";
import AdSlot from "@/components/AdSlot.client";
import { getDiatonicChordsFor, type NoteLetter } from "@/lib/music-theory";
import { toRoman, type Mode } from "@/lib/theory/roman";
import { useSearchParams } from "next/navigation";
import Fretboard from "@/components/Fretboard";
import DiatonicCapoTable from "@/components/DiatonicCapoTable";
import { getScalePitchesById } from "@/lib/scales";
import { SCALE_CATALOG, type ScaleId } from "@/lib/scaleCatalog";
import { PC_NAMES } from "@/lib/music/constants";
import ScaleTable from "@/components/ScaleTable";
import SubstituteCard from "@/components/SubstituteCard";
import { SCALE_MASTER, getScaleById, getScaleDisplayName, getScalesByCategory, getAllCategories, getCategoryDisplayName, type ScaleId as NewScaleId } from "@/lib/scalesMaster";
import { getCategoryIcon } from "@/lib/scaleCategoryIcons";
import ScaleInfoBody from "@/components/ScaleInfoBody";
import { ChevronDown, ChevronRight } from "lucide-react";
import InfoDot from "@/components/ui/InfoDot";

function FindChordsContentJA() {
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
    // SCALE_CATALOGの型に合わせて変換
    const scaleType = sel.id === 'Aeolian' ? 'minor' : 'major';
    return getDiatonicChordsFor({ tonic: keyTonic, quality, scale: scaleType as any } as any).chords;
  }, [keyTonic, selScaleId]);

  const mode: Mode = useMemo(() => (selScaleId === 'Aeolian' ? 'minor' : 'major'), [selScaleId]);

  type Display = 'degrees'|'names';
  const keyRowRef = useRef<HTMLDivElement | null>(null);
  const fbToggleRef = useRef<HTMLSpanElement | null>(null);
  const [display, setDisplay] = useState<Display>('degrees');
  const [fbCapo, setFbCapo] = useState<number>(0);
  const [overlayNotes, setOverlayNotes] = useState<string[]|null>(null);
  const [previewScaleId, setPreviewScaleId] = useState<ScaleId | null>(null);
  const [selectedCellId, setSelectedCellId] = useState<string | null>(null);
  const [lastPickedPcs, setLastPickedPcs] = useState<number[]|null>(null);

  // Map old scale IDs to new scale IDs to prevent crashes
  const mapOldScaleToNewId = (oldId: string): NewScaleId => {
    const mapping: Record<string, NewScaleId> = {
      'Ionian': 'major',
      'Aeolian': 'naturalMinor',
      'Dorian': 'dorian',
      'Phrygian': 'phrygian',
      'Lydian': 'lydian',
      'Mixolydian': 'mixolydian',
      'Locrian': 'locrian',
      'MajorPentatonic': 'majPent',
      'MinorPentatonic': 'minPent',
      'Blues': 'bluesMinor',
      'HarmonicMinor': 'harmonicMinor',
      'MelodicMinor': 'melodicMinor',
      'DiminishedWH': 'dimWholeHalf',
      'DiminishedHW': 'dimHalfWhole',
      'Lydianb7': 'lydianb7',
      'Mixolydianb6': 'mixolydianb6',
      'PhrygianDominant': 'phrygDominant',
      'Altered': 'altered',
      'WholeTone': 'wholeTone'
    };
    return mapping[oldId] || 'major';
  };

  // Debug quick-check: ensure overlay wiring is correct
  useEffect(() => {}, [display, overlayNotes]);

  const onPickKey = (k: NoteLetter) => {
    setKeyTonic(k);
    const q = (selScaleId === 'Aeolian') ? 'minor' : 'major';
    const modeLabel = q === 'major' ? 'Major' : 'Minor';
    const tonicPc = KEY_OPTIONS.indexOf(k);
    void refreshDiatonicAndOverlay();
  };

  const onPickScale = (id: ScaleId) => {
    const normalized = mapOldScaleToNewId(id as unknown as string) as unknown as ScaleId;
    setSelScaleId(normalized);
    const tonicPc = KEY_OPTIONS.indexOf(keyTonic);
    void refreshDiatonicAndOverlay();
  };

  async function refreshDiatonicAndOverlay() {
    // Recompute store to refresh diatonic/capo table and set a base overlay
    const tonicPc = KEY_OPTIONS.indexOf(keyTonic);
    const uiScale = (selScaleId === 'Aeolian') ? 'minor' : 'major';
    const modeLabel = uiScale === 'major' ? 'Major' : 'Minor';
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
  const scaleTypeForUI = useMemo(()=> {
    // SCALE_CATALOGの型に合わせて変換
    return selScaleId === 'Aeolian' ? 'minor' : 'major';
  }, [selScaleId]);

  const scaleNotesForCurrentKey = () => {
    try {
      const pcs = getScalePitchesById(scaleRootPc as any, scaleTypeForUI as any);
      return pcs.map(pc => PC_NAMES[pc] as string);
    } catch (e) {
      return [];
    }
  };

  // Reset overlay to current scale and clear selection
  const resetToScale = useCallback(() => {
    setDisplay('degrees');
    setFbCapo(0);
    setOverlayNotes(null);
    setPreviewScaleId(null);
    setSelectedCellId(null);
    setLastPickedPcs(null);
  }, [scaleRootPc, scaleTypeForUI]);

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
    <main className="ot-page ot-stack" data-page="find-chords">
      <h1>キー・スケールからコードを探す – ダイアトニックコード検索</h1>
      {/* Select Key & Scale */}
      <section className="ot-card">
        <h2 className="ot-h2">キー・スケールを選択</h2>
        <div className="mt-3 grid sm:grid-cols-2 gap-3">
        <div>
          <label className="block text-sm mb-1">キー</label>
          <div className="flex flex-col gap-2" role="tablist" aria-label="キーを選択" ref={keyRowRef}>
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
                    title={`キー ${k}`}
                  >{k}</button>
                ))}
              </div>
            ))}
          </div>
        </div>
        <div>
          <label htmlFor="scale" className="block text-sm mb-1">
            <span>スケール</span>
            {(() => {
              const cur = UI_SCALES.find(s => s.id === selScaleId)!;
              const notesInC = (() => {
                try {
                  const normalizedId = mapOldScaleToNewId(cur.id);
                  return getScalePitchesById(0, normalizedId as any).map(pc => PC_NAMES[pc]).join(' ');
                } catch (e) {
                  return 'N/A';
                }
              })();
              const defaultAbout = `${cur.group} スケール — ${cur.degrees.length}音パターン。`;
              return (
                <InfoDot title={cur.display?.ja || cur.display?.en || cur.id} className="ml-2" linkHref="/resources/glossary" linkLabel="用語集">
                  <div className="text-sm">
                    <div className="mb-1"><b>度数:</b> {cur.degrees.join(' ')}</div>
                    <div className="mb-1"><b>Cでの音:</b> {notesInC}</div>
                    <div className="mb-1"><b>説明:</b> {cur.info?.oneLiner ?? defaultAbout}</div>
                    {!!cur.info?.examples?.length && (
                      <div className="mt-2">
                        <b className="text-xs">楽曲例</b>
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
          <CategoryBasedScalePickerJA
            selectedScaleId={selScaleId}
            onScaleSelect={onPickScale}
          />
        </div>
        </div>
      </section>

      {/* Result: Diatonic → Fretboard */}
      <section className="ot-card">
        <div className="flex items-center justify-between mb-3">
          <h2 className="ot-h2">ダイアトニックコード</h2>
          <div className="flex items-center gap-2 text-sm text-foreground/70">
            <span>キー {keyTonic} {selScaleId === 'Aeolian' ? 'マイナー' : 'メジャー'}</span>
            {(() => {
              const notes = scaleNotesForCurrentKey();
              return notes.length > 0 && (
                <span className="ml-2">
                  スケール音: {notes.join(' ')}
                </span>
              );
            })()}
          </div>
        </div>
        <div className="space-y-4">
          <div>
            {!isHept && (
              <p className="text-xs text-foreground/70 mt-1">
                このスケールは七音階ではありません。ローマ数字は非表示です。ダイアトニック提案は「Open」行に限定されます。
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
              <span>フレットボード</span>
              <span ref={fbToggleRef} className="flex items-center gap-2" role="tablist" aria-orientation="horizontal" aria-label="フレットボード表記">
              <button role="tab" aria-selected={display==='degrees'} tabIndex={display==='degrees'?0:-1} className={["chip", display==='degrees'?"chip--on":""].join(" ")} data-roving="item" onClick={()=>{ setDisplay('degrees'); }}>度数</button>
              <button role="tab" aria-selected={display==='names'} tabIndex={display==='names'?0:-1} className={["chip", display==='names'?"chip--on":""].join(" ")} data-roving="item" onClick={()=>{ setDisplay('names'); }}>音名</button>
              {selectedCellId && (
                <button role="tab" aria-selected={false} tabIndex={-1} className="chip" onClick={resetToScale} aria-label="リセット">リセット</button>
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
            />
          </div>
        </div>
      </section>

      {/* Ad Placeholder (card participates in page rhythm) */}
      <section className="ot-card ad-placeholder" aria-label="広告">
        <AdSlot page="find_chords" format="horizontal" />
      </section>
      
    </main>
  );
}

function CategoryBasedScalePickerJA({ 
  selectedScaleId, 
  onScaleSelect 
}: { 
  selectedScaleId: ScaleId; 
  onScaleSelect: (scaleId: ScaleId) => void; 
}) {
  const [expandedCategories, setExpandedCategories] = useState<Set<string>>(new Set(['Basic']));
  
  const categories = getAllCategories();
  
  const toggleCategory = (category: string) => {
    setExpandedCategories(prev => {
      const newSet = new Set(prev);
      if (newSet.has(category)) {
        newSet.delete(category);
      } else {
        newSet.add(category);
      }
      return newSet;
    });
  };

  return (
    <div className="space-y-2">
      {categories.map(category => {
        const scales = getScalesByCategory(category);
        const isExpanded = expandedCategories.has(category);
        const categoryIcon = getCategoryIcon(category);
        const IconComponent = categoryIcon.icon;
        
        return (
          <div key={category} className="border rounded-lg">
            <button
              className="w-full flex items-center justify-between p-3 text-left hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
              onClick={() => toggleCategory(category)}
            >
              <div className="flex items-center gap-3">
                <div className={`p-2 rounded-lg ${categoryIcon.bgColor}`}>
                  <IconComponent className={`w-5 h-5 ${categoryIcon.color}`} />
                </div>
                <div>
                  <div className="font-medium">{category}</div>
                  <div className="text-sm text-gray-500">{scales.length} スケール</div>
                </div>
              </div>
              {isExpanded ? <ChevronDown size={20} /> : <ChevronRight size={20} />}
            </button>
            
            {isExpanded && (
              <div className="border-t p-2 space-y-1">
                {scales.map(scale => {
                  const isSelected = selectedScaleId === scale.id as any;
                  
                  return (
                    <div key={scale.id} className="relative inline-block">
                      <button
                        className={`flex-1 text-left px-3 py-2 rounded-lg text-sm transition-colors flex items-center gap-2 ${
                          isSelected 
                            ? 'bg-blue-100 dark:bg-blue-900 text-blue-900 dark:text-blue-100' 
                            : 'hover:bg-gray-100 dark:hover:bg-gray-700'
                        }`}
                        onClick={(e) => {
                          e.stopPropagation();
                          onScaleSelect(scale.id as ScaleId);
                        }}
                      >
                        <span>{scale.display?.ja || scale.display?.en || scale.id}</span>
                      </button>
                      <div className="absolute -top-1 -right-1">
                        <InfoDot
                          title={scale.display?.ja || scale.display?.en || scale.id}
                          linkHref="/resources/glossary"
                          linkLabel="用語集"
                        >
                          {/* <ScaleInfoBody scaleId={scale.id} /> */}
                          <div className="p-2 text-sm text-gray-600">
                            スケール情報を読み込み中...
                          </div>
                        </InfoDot>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}

// --- helpers ---
function detectQualityFromPcs(pcs:number[]): 'maj'|'min'|'dom7'|'m7b5'|'dim' {
  const set = new Set(pcs.map(x => ((x - pcs[0] + 12) % 12)));
  if (set.has(0) && set.has(4) && set.has(7)) return 'maj';
  if (set.has(0) && set.has(3) && set.has(7)) return 'min';
  if (set.has(0) && set.has(4) && set.has(7) && set.has(10)) return 'dom7';
  if (set.has(0) && set.has(3) && set.has(6) && set.has(10)) return 'm7b5';
  if (set.has(0) && set.has(3) && set.has(6)) return 'dim';
  return 'maj';
}

export default FindChordsContentJA;