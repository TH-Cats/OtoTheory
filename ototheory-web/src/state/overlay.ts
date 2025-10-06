import React, {createContext, useContext, useRef, useState, useCallback} from 'react';
import * as t from '@/lib/telemetry';

type ViewMode = 'Degrees' | 'Names';
type ScaleOverlay = { scaleId: string; notes: number[] } | null;
type ChordOverlay = { chordId: string; notes: number[] } | null;

interface OverlayContextType {
  viewMode: ViewMode;
  scale: ScaleOverlay;
  chord: ChordOverlay;
  setViewMode: (m: ViewMode) => void;
  setScale: (s: ScaleOverlay) => void;
  setChordFromUser: (c: ChordOverlay) => void;
  resetChord: () => void;
  // backward-compat aliases (zustand-like naming)
  setScaleLayer: (s: ScaleOverlay) => void;
  resetChordLayer: () => void;
}

const OverlayContext = createContext<OverlayContextType | null>(null);

export const OverlayProvider: React.FC<React.PropsWithChildren> = ({children}) => {
  const [viewMode, setViewMode] = useState<ViewMode>('Degrees');
  const [scale, setScale] = useState<ScaleOverlay>(null);
  const [chord, setChord] = useState<ChordOverlay>(null);
  const shownOnceRef = useRef(false);

  const setChordFromUser = useCallback((c: ChordOverlay) => {
    setChord(prev => {
      if (!shownOnceRef.current && !prev && c) {
        t.track('overlay_shown', { page: 'chord_progression', control: 'chord' });
        shownOnceRef.current = true;
      }
      return c;
    });
  }, []);

  const resetChord = useCallback(() => {
    setChord(null);
    t.track('overlay_reset', { page: 'chord_progression' });
  }, []);

  const contextValue: OverlayContextType = {
    viewMode,
    scale,
    chord,
    setViewMode: (m) => {
      if (m !== viewMode) {
        setViewMode(m);
        t.track('fb_toggle', { page: 'chord_progression', value: m });
      }
    },
    setScale,
    setChordFromUser,
    resetChord,
    // aliases
    setScaleLayer: (s) => setScale(s),
    resetChordLayer: () => resetChord(),
  };

  return React.createElement(
    OverlayContext.Provider,
    { value: contextValue },
    children
  );
};

// Accept optional selector for backward compatibility with zustand-like calls
export const useOverlay = <T = OverlayContextType>(selector?: (c: OverlayContextType) => T): T => {
  const ctx = useContext(OverlayContext);
  if (!ctx) {
    // Provider未設置時でもクラッシュさせないフェイルセーフ
    const fallback: OverlayContextType = {
      viewMode: 'Degrees',
      scale: null,
      chord: null,
      setViewMode: () => {},
      setScale: () => {},
      setChordFromUser: () => {},
      resetChord: () => {},
      setScaleLayer: () => {},
      resetChordLayer: () => {},
    };
    return (selector ? selector(fallback) : (fallback as unknown as T));
  }
  return (selector ? selector(ctx) : (ctx as unknown as T));
};