'use client';

import React, { useMemo, useState, useRef } from 'react';
import styles from './chords.module.css';
import { usePathname } from 'next/navigation';
import { messages, type Locale } from '@/lib/i18n/messages';
import { 
  ROOTS, QUALITIES, ADVANCED_QUALITIES, 
  type Root, type Quality, type AdvancedQuality,
  getCachedChord, getIntervals, getChordNotes, getVoicingNote 
} from '@/lib/chord-library';
import { ChordCard } from '@/components/chords/ChordCard';
import AdSlot from '@/components/AdSlot.client';

export type DisplayMode = 'finger' | 'roman' | 'note';

export default function Client() {
  const pathname = usePathname() || '/';
  const isJa = pathname.startsWith('/ja');
  const locale: Locale = isJa ? 'ja' : 'en';
  const t = messages[locale].chordLibrary;
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
        <h1>{t.title}</h1>
        <p className={styles['sub']}>
          {t.sub}
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
            <span className={styles['quality-label']}>{t.quality}</span>
            <button
              className={`${styles['advanced-toggle']} ${showAdvanced ? styles['advanced-toggle--on'] : ''}`}
              onClick={() => setShowAdvanced(!showAdvanced)}
              aria-pressed={showAdvanced}
            >
              {showAdvanced ? t.hideAdvanced : t.showAdvanced}
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
            <span className={styles['display-mode__label']}>{t.display}</span>
            <div className={styles['display-mode__buttons']}>
              <button
                className={`${styles['mode-btn']} ${displayMode === 'finger' ? styles['mode-btn--active'] : ''}`}
                onClick={() => setDisplayMode('finger')}
                aria-pressed={displayMode === 'finger'}
              >
                {t.finger}
              </button>
              <button
                className={`${styles['mode-btn']} ${displayMode === 'roman' ? styles['mode-btn--active'] : ''}`}
                onClick={() => setDisplayMode('roman')}
                aria-pressed={displayMode === 'roman'}
              >
                {t.roman}
              </button>
              <button
                className={`${styles['mode-btn']} ${displayMode === 'note' ? styles['mode-btn--active'] : ''}`}
                onClick={() => setDisplayMode('note')}
                aria-pressed={displayMode === 'note'}
              >
                {t.note}
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
          {t.tip}
        </p>
      </footer>

      <section className={styles['chord-page__ad']} aria-label="Advertisement">
        <AdSlot page="chord_library" format="horizontal" />
      </section>
    </main>
  );
}

