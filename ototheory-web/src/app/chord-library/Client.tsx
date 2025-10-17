'use client';

import React, { useMemo, useState, useRef } from 'react';
import styles from './chords.module.css';
import { messages } from '@/lib/i18n/messages';
import { 
  ROOTS, QUALITIES, ADVANCED_QUALITIES, 
  type Root, type Quality, type AdvancedQuality,
  getCachedChord, getIntervals, getChordNotes, getVoicingNote 
} from '@/lib/chord-library';
import { getStaticChord, type StaticChord, type StaticForm } from '@/lib/chord-library-static';
import { ChordCard } from '@/components/chords/ChordCard';
import AdSlot from '@/components/AdSlot.client';
import { tTip, tLabel } from '@/lib/i18n/chordLibrary';
import { useLocale } from '@/lib/i18n/locale';
import InfoDot from '@/components/ui/InfoDot';

export type DisplayMode = 'finger' | 'roman' | 'note';

// Helper to convert static form to old ChordShape format
function convertToChordShape(form: StaticForm): any {
  return {
    id: form.id,
    label: form.shapeName || 'Unknown',
    frets: form.frets,
    fingers: form.fingers,
    barres: form.barres,
    tips: form.tips
  };
}

export default function Client() {
  const [root, setRoot] = useState<Root>('C');
  const [quality, setQuality] = useState<Quality | AdvancedQuality>('M');
  const [displayMode, setDisplayMode] = useState<DisplayMode>('finger');
  const [showAdvanced, setShowAdvanced] = useState(false);
  const locale = useLocale();
  const t = messages[locale].chordLibrary;

  const helpText = useMemo(() => {
    const m = messages[locale].chordLibrary;
    return {
      finger: m.info.fingerHelp,
      roman: m.info.romanHelp,
      note: m.info.noteHelp,
      summary: m.detailsSummary,
      benefits: m.benefits,
      tryNow: m.tryNow,
      details: m.details,
    } as const;
  }, [locale]);

  // Try to get static chord first, fallback to generated
  const staticChord = useMemo(() => {
    const symbol = quality === 'M' ? root : `${root}${quality}`;
    return getStaticChord(symbol);
  }, [root, quality]);

  const entry = useMemo(() => {
    if (staticChord) {
      // Convert static chord to old format
      return {
        symbol: staticChord.symbol,
        display: staticChord.symbol,
        shapes: staticChord.forms.slice(0, 3).map(convertToChordShape) as [any, any, any]
      };
    }
    return getCachedChord(root, quality);
  }, [root, quality, staticChord]);

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
      <div className="container">
      <header className={styles['chord-page__header']}>
        <h1>{t.title}</h1>
        <p className={styles['sub']}>
          {t.sub}
        </p>

        {/* Benefit strip: concise value props */}
        <div className={styles['benefit-strip']} role="list" aria-label={locale==='ja' ? 'このページでできること' : 'What you can do here'}>
          {helpText.benefits.map((b, i) => (
            <div role="listitem" key={i} className={styles['benefit-item']}>{b}</div>
          ))}
          {helpText.tryNow && (
            <a href="#forms" className={styles['benefit-cta']} aria-label={helpText.tryNow}>{helpText.tryNow}</a>
          )}
        </div>

        {/* Collapsible long description for SEO, default closed */}
        <details className={styles['details-card']}>
          <summary>{helpText.summary}</summary>
          <div className={styles['details-body']}>
            <div className={styles['details-grid']}>
              <section>
                <h4>{helpText.details.how.title}</h4>
                <ul>
                  {helpText.details.how.bullets.map((b, i) => (
                    <li key={`how-${i}`}>
                      {b}
                      {i === 1 && (
                        <span className={styles['inline-help']}> <InfoDot text={helpText.finger} ariaLabel={locale==='ja' ? '指番号の説明' : 'About finger numbers'} /> </span>
                      )}
                    </li>
                  ))}
                </ul>
              </section>
              <section>
                <h4>{helpText.details.forms.title}</h4>
                <ul>
                  {helpText.details.forms.bullets.map((b, i) => (<li key={`forms-${i}`}>{b}</li>))}
                </ul>
              </section>
              <section>
                <h4>{helpText.details.visual.title}</h4>
                <ul>
                  {helpText.details.visual.bullets.map((b, i) => (<li key={`visual-${i}`}>{b}</li>))}
                </ul>
              </section>
              <section>
                <h4>{helpText.details.more.title}</h4>
                <ul>
                  {helpText.details.more.bullets.map((b, i) => (<li key={`more-${i}`}>{b}</li>))}
                </ul>
              </section>
            </div>
          </div>
        </details>

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
                aria-label={locale==='ja' ? '指番号を表示' : 'Show finger numbers'}
              >
                {t.finger}
              </button>
              <button
                className={`${styles['mode-btn']} ${displayMode === 'roman' ? styles['mode-btn--active'] : ''}`}
                onClick={() => setDisplayMode('roman')}
                aria-pressed={displayMode === 'roman'}
                aria-label={locale==='ja' ? '度数を表示' : 'Show intervals'}
              >
                {t.roman}
              </button>
              <button
                className={`${styles['mode-btn']} ${displayMode === 'note' ? styles['mode-btn--active'] : ''}`}
                onClick={() => setDisplayMode('note')}
                aria-pressed={displayMode === 'note'}
                aria-label={locale==='ja' ? '音名を表示' : 'Show note names'}
              >
                {t.note}
              </button>
              <span className={styles['mode-help']}>
                <InfoDot
                  text={displayMode === 'finger' ? helpText.finger : displayMode === 'roman' ? helpText.roman : helpText.note}
                  ariaLabel={locale==='ja' ? '表示モードの説明' : 'About display modes'}
                />
              </span>
            </div>
          </div>
        </div>
      </header>

      <section id="forms" key={`${root}-${quality}`} className={styles['grid-3']} aria-label="Chord forms">
        {entry.shapes.map((shape, index) => (
          <div className={styles['grid-3__col']} key={`${root}-${quality}-${index}`}>
            <ChordCard 
              symbol={entry.symbol} 
              shape={{...shape, tips: shape.tips.map(t=>tTip(t, locale)), label: tLabel(shape.label, locale)}} 
              root={root} 
              displayMode={displayMode} 
            />
          </div>
        ))}
      </section>

      {/* footer hint removed per JP UX: avoid extra message at bottom */}

      <section className={styles['chord-page__ad']} aria-label="Advertisement">
        <AdSlot page="chord_library" format="horizontal" />
      </section>
      </div>
    </main>
  );
}

