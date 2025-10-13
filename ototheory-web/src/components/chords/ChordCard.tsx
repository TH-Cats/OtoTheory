// /components/chords/ChordCard.tsx
import React, { useState } from 'react';
import { ChordDiagram } from './ChordDiagram';
import { ChordAudio } from './ChordAudio';
import type { ChordShape, Root } from '@/lib/chord-library';
import type { DisplayMode } from '@/app/resources/chord-library/Client';
import styles from '@/app/resources/chord-library/chords.module.css';

type Props = { 
  symbol: string; 
  shape: ChordShape; 
  root: Root;
  displayMode: DisplayMode;
};

export function ChordCard({ symbol, shape, root, displayMode }: Props) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const onPlay = async (mode:'strum'|'arp') => {
    setIsPlaying(true); setError(null);
    try { await ChordAudio.playShape(shape.frets, mode); }
    catch (e) { setError('Audio playback failed. Tap again or check browser settings.'); }
    finally { setIsPlaying(false); }
  };

  return (
    <article className={styles['chord-card']}>
      <header className={styles['chord-card__head']}>
        <h3 className={styles['chord-card__title']}>{symbol} — {shape.label}</h3>
        <div className={styles['chord-card__actions']}>
          <button className={styles['btn']} onClick={() => onPlay('strum')} aria-label="Play strum" disabled={isPlaying}>
            {isPlaying ? '…' : '▶'} Play
          </button>
          <button className={`${styles['btn']} ${styles['btn--ghost']}`} onClick={() => onPlay('arp')} aria-label="Play arpeggio" disabled={isPlaying}>
            Arp
          </button>
        </div>
      </header>
      <ChordDiagram 
        frets={shape.frets} 
        fingers={shape.fingers} 
        barres={shape.barres}
        root={root}
        displayMode={displayMode}
      />
      <ul className={styles['chord-card__tips']}>
        {shape.tips.map((t, i) => <li key={i}>• {t}</li>)}
      </ul>
      {error && <p role="alert" style={{color:'#ef4444', marginTop: 6, fontSize: '0.875rem'}}>{error}</p>}
    </article>
  );
}

