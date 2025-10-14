'use client';

import React, { useMemo, useState, useRef } from 'react';
import styles from './chords.module.css';
import { 
  ROOTS, QUALITIES, ADVANCED_QUALITIES, 
  type Root, type Quality, type AdvancedQuality,
  getCachedChord, getIntervals, getChordNotes, getVoicingNote 
} from '@/lib/chord-library';
import { ChordCard } from '@/components/chords/ChordCard';
import AdSlot from '@/components/AdSlot.client';

export type DisplayMode = 'finger' | 'roman' | 'note';

export default function Client() {
  const [root, setRoot] = useState<Root>('C');
  const [quality, setQuality] = useState<Quality | AdvancedQuality>('M');
  const [displayMode, setDisplayMode] = useState<DisplayMode>('finger');
  const [showAdvanced, setShowAdvanced] = useState(false);

  const entry = useMemo(() => getCachedChord(root, quality), [root, quality]);
  const intervals = useMemo(() => getIntervals(quality), [quality]);
  const notes = useMemo(() => getChordNotes(root, quality), [root, quality]);
  const voicingNote = useMemo(() => getVoicingNote(quality), [quality]);

  const allQualitiesDisplay = showAdvanced ? [...QUALITIES, ...ADVANCED_QUALITIES] : QUALITIES;
  const rootIdx = ROOTS.indexOf(root);
  const qualIdx = allQualitiesDisplay.indexOf(quality as Quality | AdvancedQuality);
  const rootWrapRef = useRef<HTMLDivElement>(null);
  const qualWrapRef = useRef<HTMLDivElement>(null);

  const moveRoot = (dir: -1 | 1) => {
    const next = (rootIdx + dir + ROOTS.length) % ROOTS.length;
    setRoot(ROOTS[next]);
  };
  const moveQuality = (dir: -1 | 1) => {
    const next = (qualIdx + dir + allQualitiesDisplay.length) % allQualitiesDisplay.length;
    setQuality(allQualitiesDisplay[next]);
  };

  return (
    <main className={styles['chord-page']}>
      <header className={styles['chord-page__header']}>
        <h1>Chord Library</h1>
        <p className={styles['sub']}>
          Choose a Root and Quality to see <strong>3 chord forms side by side</strong> with horizontal fretboard layout. 
          Supports <strong>Eb, Ab, Bb</strong> and other practical keys. 
          Hear them with <strong>▶ Play</strong> (strum) and <strong>Arp</strong> (arpeggio).
        </p>

        <div
          ref={rootWrapRef}
          className={`${styles['row']} ${styles['row--scroll']}`}
          role="radiogroup"
          aria-label="Choose root"
          onKeyDown={(e) => {
            if (e.key === 'ArrowRight') moveRoot(1);
            if (e.key === 'ArrowLeft') moveRoot(-1);
          }}
        >
          {ROOTS.map((r) => (
            <button
              key={r}
              role="radio"
              aria-checked={root === r}
              tabIndex={root === r ? 0 : -1}
              className={`${styles['chip']} ${root === r ? styles['chip--on'] : ''}`}
              onClick={() => setRoot(r)}
            >
              {r}
            </button>
          ))}
        </div>

        <div className={styles['quality-section']}>
          <div className={styles['quality-header']}>
            <span className={styles['quality-label']}>Quality:</span>
            <button
              className={`${styles['advanced-toggle']} ${showAdvanced ? styles['advanced-toggle--on'] : ''}`}
              onClick={() => setShowAdvanced(!showAdvanced)}
              aria-pressed={showAdvanced}
            >
              {showAdvanced ? 'Hide Advanced' : 'Show Advanced'}
            </button>
          </div>
          <div
            ref={qualWrapRef}
            className={`${styles['row']} ${styles['row--scroll']}`}
            role="radiogroup"
            aria-label="Choose quality"
            onKeyDown={(e) => {
              if (e.key === 'ArrowRight' || e.key === 'ArrowDown') moveQuality(1);
              if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') moveQuality(-1);
            }}
          >
            {allQualitiesDisplay.map((q) => (
              <button
                key={q}
                role="radio"
                aria-checked={quality === q}
                tabIndex={quality === q ? 0 : -1}
                className={`${styles['chip']} ${quality === q ? styles['chip--on'] : ''}`}
                onClick={() => setQuality(q)}
              >
                {q}
              </button>
            ))}
          </div>
        </div>

        <div className={styles['sel']}>
          <div className={styles['sel__left']}>
            <div className={styles['sel__symbol']}>{entry.display}</div>
            <div className={styles['sel__notes']}>
              <span className={styles['sel__notes-intervals']}>
                {intervals.join(' · ')}
              </span>
              <span className={styles['sel__notes-separator']}>|</span>
              <span className={styles['sel__notes-actual']}>
                {notes.join(' · ')}
              </span>
            </div>
            {voicingNote && (
              <div className={styles['voicing-note']}>
                <span className={styles['voicing-note__icon']}>ⓘ</span>
                <span className={styles['voicing-note__text']}>{voicingNote}</span>
              </div>
            )}
          </div>
          <div className={styles['display-mode']}>
            <span className={styles['display-mode__label']}>Display:</span>
            <div className={styles['display-mode__buttons']}>
              <button
                className={`${styles['mode-btn']} ${displayMode === 'finger' ? styles['mode-btn--active'] : ''}`}
                onClick={() => setDisplayMode('finger')}
                aria-pressed={displayMode === 'finger'}
              >
                Finger
              </button>
              <button
                className={`${styles['mode-btn']} ${displayMode === 'roman' ? styles['mode-btn--active'] : ''}`}
                onClick={() => setDisplayMode('roman')}
                aria-pressed={displayMode === 'roman'}
              >
                Roman
              </button>
              <button
                className={`${styles['mode-btn']} ${displayMode === 'note' ? styles['mode-btn--active'] : ''}`}
                onClick={() => setDisplayMode('note')}
                aria-pressed={displayMode === 'note'}
              >
                Note
              </button>
            </div>
          </div>
        </div>
      </header>

      <section key={`${root}-${quality}`} className={styles['grid-3']} aria-label="Chord forms">
        {entry.shapes.map((shape, index) => (
          <div className={styles['grid-3__col']} key={`${root}-${quality}-${index}`}>
            <ChordCard symbol={entry.symbol} shape={shape} root={root} displayMode={displayMode} />
          </div>
        ))}
      </section>

      <footer className={styles['chord-page__footer']}>
        <p className={styles['hint']}>
          Tip: Forms with <strong>×</strong> on 1st or 6th string should not be strummed there, or lightly muted with your fretting hand.
        </p>
      </footer>

      <section className={styles['chord-page__ad']} aria-label="Advertisement">
        <AdSlot page="chord_library" format="horizontal" />
      </section>
    </main>
  );
}

