"use client";
import React from "react";
import { DiatonicTable } from "./DiatonicTable";
import Fretboard from "./Fretboard";
import CapoFold from "./CapoFold";
import { useOverlay } from "@/state/overlay";
import { useAnalysisStore } from "@/store/analysisStore";
import { romanDegreeLabelsForScale, type ScaleType } from "@/lib/scales";

// 非ヘプタ判定関数（scaleCatalogから）
function isHeptatonic(scaleId: string): boolean {
  const SCALE_CATALOG = require("@/lib/scaleCatalog").SCALE_CATALOG;
  return (SCALE_CATALOG.find(s => s.id === scaleId)?.degrees?.length ?? 7) === 7;
}

function isPentOrBlues(scaleId: string): boolean {
  return scaleId === 'Pentatonic' || scaleId === 'Blues';
}

function Header({keyCandidates, currentScaleId}:{keyCandidates:{label:string, conf:number}[], currentScaleId:string}) {
  const romanVisible = isHeptatonic(currentScaleId) || isPentOrBlues(currentScaleId); // 例外含む
  return (
    <header className="ot-stack">
      <div className="ot-h3">
        {keyCandidates.slice(0,3).map(k=>`${k.label} ${Math.round(k.conf)}%`).join(' / ')}
      </div>
      {romanVisible ? <div className="roman">I II III IV V VI VII</div> : null}
    </header>
  );
}

export default function ResultCard({ onAddToProgression }: { onAddToProgression?: (degree: string, quality?: string) => void } = {}) {
  const selectedKey = useAnalysisStore(s => (s as any).selectedKey);
  const selectedScale = useAnalysisStore(s => (s as any).selectedScale);
  const { viewMode, scale, chord, setViewMode, setScale, setChordFromUser, resetChord } = useOverlay();

  // Mock key candidates for display (実際はストアから取得)
  const keyCandidates = selectedKey ? [{ label: `${selectedKey.tonic} ${selectedScale?.name || ''}`, conf: 95 }] : [];

  if (!selectedKey || !selectedScale) {
    return (
      <section className="ot-card">
        <p className="ot-hint">Select a key and scale to see chord suggestions</p>
      </section>
    );
  }

  return (
    <section className="ot-card">
      {/* ヘッダ: Key/Scale（≤3＋%）とRoman（非ヘプタ時は非表示、Pent/Bluesのみ例外） */}
      <Header keyCandidates={keyCandidates} currentScaleId={selectedScale.type} />

      <div className="ot-section">
        {/* Diatonic（Open行のみ選択可） */}
        <div className="ot-block">
          <DiatonicTable
            scaleId={selectedScale.type}
            rows={[
              {
                id: 'Open',
                kind: 'Open' as const,
                notes: [1, 2, 3, 4, 5, 6, 7] // 仮のノート値
              }
            ]}
            onAddToProgression={onAddToProgression}
          />
        </div>

        {/* Fretboard（二層Overlay） */}
        <div className="ot-block">
          <div className="ot-section-head">
            <h3 className="ot-h3">Fretboard</h3>
            <div className="ot-chip" onClick={() => setViewMode(viewMode === 'Degrees' ? 'Names' : 'Degrees')}>
              {viewMode}
            </div>
          </div>
          <Fretboard
            overlay={{
              display: viewMode.toLowerCase() as 'degrees' | 'names',
              scaleRootPc: selectedKey.tonic,
              scaleType: selectedScale.type as ScaleType,
              chordNotes: chord?.notes,
              showScaleGhost: true,
            }}
          />
          <button className="ot-btn-ghost" onClick={resetChord}>
            Reset Chord
          </button>
        </div>

        {/* CapoFold */}
        <CapoFold />
      </div>
    </section>
  );
}



