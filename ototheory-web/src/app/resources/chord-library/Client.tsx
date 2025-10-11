'use client';

import React, { useMemo, useState, useRef } from 'react';
import styles from './chords.module.css';
import { ROOTS, QUALITIES, type Root, type Quality, getCachedChord } from '@/lib/chord-library';
import { ChordCard } from '@/components/chords/ChordCard';

export default function Client() {
  const [root, setRoot] = useState<Root>('C');
  const [quality, setQuality] = useState<Quality>('Major');

  const entry = useMemo(() => getCachedChord(root, quality), [root, quality]);

  const rootIdx = ROOTS.indexOf(root);
  const qualIdx = QUALITIES.indexOf(quality);
  const rootWrapRef = useRef<HTMLDivElement>(null);
  const qualWrapRef = useRef<HTMLDivElement>(null);

  const moveRoot = (dir: -1 | 1) => {
    const next = (rootIdx + dir + ROOTS.length) % ROOTS.length;
    setRoot(ROOTS[next]);
  };
  const moveQuality = (dir: -1 | 1) => {
    const next = (qualIdx + dir + QUALITIES.length) % QUALITIES.length;
    setQuality(QUALITIES[next]);
  };

  return (
    <main className={styles['chord-page']}>
      <header className={styles['chord-page__header']}>
        <h1>Chord Library</h1>
        <p className={styles['sub']}>
          Choose a Root and Quality to see <strong>3 chord forms side by side</strong> with horizontal fretboard layout. 
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
          {QUALITIES.map((q) => (
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

        <div className={styles['sel']}>
          <div className={styles['sel__symbol']}>{entry.display}</div>
        </div>
      </header>

      <section key={`${root}-${quality}`} className={styles['grid-3']} aria-label="Chord forms">
        {entry.shapes.map((shape, index) => (
          <div className={styles['grid-3__col']} key={`${root}-${quality}-${index}`}>
            <ChordCard symbol={entry.symbol} shape={shape} />
          </div>
        ))}
      </section>

      <footer className={styles['chord-page__footer']}>
        <p className={styles['hint']}>
          Tip: Forms with <strong>×</strong> on 1st or 6th string should not be strummed there, or lightly muted with your fretting hand.
        </p>
      </footer>
    </main>
  );
}

