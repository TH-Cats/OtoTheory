"use client";
import React, { useEffect } from 'react';
import { useSketchStore } from '@/store/sketchStore';
import { Sketch } from '@/types/sketch';
import { track } from '@/lib/telemetry';

interface SketchLibraryProps {
  onLoadSketch?: (sketch: Sketch) => void;
}

export function SketchLibrary({ onLoadSketch }: SketchLibraryProps) {
  const { sketches, currentSketch, loadSketches, loadSketch, deleteSketch } = useSketchStore();

  useEffect(() => {
    loadSketches();
  }, []);

  const handleLoad = (sketch: Sketch) => {
    loadSketch(sketch.id);
    try { track('open_project', { page: 'chord_progression', id: sketch.id }); } catch {}
    onLoadSketch?.(sketch);
  };

  const handleDelete = (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (confirm('このスケッチを削除しますか？')) {
      deleteSketch(id);
      try { track('project_delete', { page: 'chord_progression', id }); } catch {}
    }
  };

  if (sketches.length === 0) {
    return (
      <div className="ot-block">
        <p className="ot-hint">まだスケッチがありません。Progressionを作成して保存してください。</p>
      </div>
    );
  }

  return (
    <div className="ot-block">
      <div className="ot-stack">
        {sketches.map((sketch) => (
          <div
            key={sketch.id}
            className={`ot-card ${currentSketch?.id === sketch.id ? 'ot-card--active' : ''}`}
            onClick={() => handleLoad(sketch)}
            style={{ cursor: 'pointer' }}
          >
            <div className="ot-section-head">
              <div className="ot-block">
                <h4 className="ot-h4">{sketch.name}</h4>
                <p className="ot-hint">
                  {sketch.key.tonic} {sketch.key.scaleId} •
                  Capo {sketch.capo.fret} ({sketch.capo.note}) •
                  {new Date(sketch.updatedAt).toLocaleDateString()}
                </p>
              </div>
              <button
                className="ot-btn-ghost"
                onClick={(e) => handleDelete(sketch.id, e)}
                title="削除"
              >
                🗑️
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
