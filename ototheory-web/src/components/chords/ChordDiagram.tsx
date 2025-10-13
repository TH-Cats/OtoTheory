// /components/chords/ChordDiagram.tsx
import React from 'react';
import type { Barre, Fret, Finger, Root } from '@/lib/chord-library';
import type { DisplayMode } from '@/app/resources/chord-library/Client';

type Props = {
  frets: [Fret, Fret, Fret, Fret, Fret, Fret];
  fingers?: [Finger, Finger, Finger, Finger, Finger, Finger];
  barres?: Barre[];
  root: Root;
  displayMode: DisplayMode;
  width?: number;
  maxFrets?: number;
};

const PAD = { left: 28, right: 16, top: 16, bottom: 32 };

// Note names in chromatic order
const NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
const NOTE_INDEX: Record<string, number> = {
  'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5,
  'F#': 6, 'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11
};

// Open strings (E A D G B E)
const OPEN_STRINGS = ['E', 'A', 'D', 'G', 'B', 'E'];

// Get note name for a fret on a string
function getNoteName(stringIdx: number, fret: number): string {
  const openNote = OPEN_STRINGS[stringIdx];
  const openIdx = NOTE_INDEX[openNote];
  const noteIdx = (openIdx + fret) % 12;
  return NOTE_NAMES[noteIdx];
}

// Get Roman numeral for a note relative to root (R = Root instead of I)
function getRoman(noteName: string, root: Root): string {
  const rootIdx = NOTE_INDEX[root];
  const noteIdx = NOTE_INDEX[noteName];
  const interval = (noteIdx - rootIdx + 12) % 12;
  const romans = ['R', '♭II', 'II', '♭III', 'III', 'IV', '♭V', 'V', '#V', 'VI', '♭VII', 'VII'];
  return romans[interval];
}

export function ChordDiagram({ frets, fingers, barres = [], root, displayMode, width = 320, maxFrets = 5 }: Props) {
  const height = 160;
  const innerW = width - PAD.left - PAD.right;
  const innerH = height - PAD.top - PAD.bottom;
  const numStrings = 6;
  const fretW = innerW / maxFrets;
  const stringH = innerH / (numStrings - 1);

  const pos = frets.filter(f => typeof f === 'number' && f > 0) as number[];
  const baseFret = pos.length ? Math.min(...pos) : 1;
  const showNut = baseFret === 1;

  // Horizontal layout: frets go left to right
  const xForFret = (abs:number) => {
    if (abs === 0) return PAD.left - 12;
    const rel = abs - baseFret + 1;
    return PAD.left + fretW * (rel - 0.5);
  };
  // Strings go top to bottom (1st string at top, 6th string at bottom)
  const yForString = (sIdx:number) => PAD.top + stringH * (5 - sIdx);

  const grid: JSX.Element[] = [];
  // Draw strings (horizontal lines)
  for (let s=0; s<numStrings; s++) {
    grid.push(<line key={`s${s}`} x1={PAD.left} y1={yForString(s)} x2={PAD.left+innerW} y2={yForString(s)} stroke="#575a5f" strokeWidth={1} />);
  }
  // Draw frets (vertical lines)
  for (let f=1; f<=maxFrets; f++) {
    grid.push(<line key={`f${f}`} x1={PAD.left+fretW*f} y1={PAD.top} x2={PAD.left+fretW*f} y2={PAD.top+innerH} stroke="#575a5f" strokeWidth={1} />);
  }

  const nut = showNut
    ? <rect x={PAD.left-7} y={PAD.top-1.5} width={7} height={innerH+3} fill="#e7e7ea" rx={3}/>
    : <text x={PAD.left-8} y={PAD.top-6} fontSize="12" textAnchor="end" fill="#9aa0a6">{baseFret}fr</text>;

  // Fret numbers at bottom
  const fretNumbers: JSX.Element[] = [];
  for (let f=1; f<=maxFrets; f++) {
    const displayFret = baseFret + f - 1;
    fretNumbers.push(
      <text key={`fn${f}`} x={PAD.left + fretW * (f - 0.5)} y={height - 8} fontSize="12" textAnchor="middle" fill="#9aa0a6">
        {displayFret}
      </text>
    );
  }

  const barreEls = barres.map((b,i) => {
    const x = xForFret(b.fret);
    const y1 = yForString(6 - b.fromString);
    const y2 = yForString(6 - b.toString);
    const y = Math.min(y1, y2) - 10;
    const h = Math.abs(y2 - y1) + 20;
    return <rect key={`barre${i}`} x={x-10} y={y} width={20} height={h} rx={10} fill="#2dd4bf" opacity={0.3} />;
  });

  const markers: JSX.Element[] = [];
  for (let s=0; s<6; s++) {
    const f = frets[s];
    const finger = fingers?.[s] ?? null;
    const y = yForString(s);
    const openX = PAD.left - 19; // Position for open strings and muted strings
    if (f === 'x') {
      markers.push(<text key={`x${s}`} x={openX} y={y+4} fill="#ef4444" fontSize="14" textAnchor="middle">×</text>);
    } else if (f === 0) {
      // Open string - show circle with optional Roman/Note inside (moved left to avoid overlapping with nut)
      if (displayMode === 'finger') {
        // Just show the circle
        markers.push(<circle key={`o${s}`} cx={openX} cy={y} r={6} fill="none" stroke="#a6a7aa" strokeWidth={1.5} />);
      } else {
        // Show Roman or Note inside the circle
        const noteName = getNoteName(s, 0);
        let displayText = '';
        let fontSize = 9;
        if (displayMode === 'note') {
          displayText = noteName;
          fontSize = 8;
        } else if (displayMode === 'roman') {
          displayText = getRoman(noteName, root);
          fontSize = 7;
        }
        markers.push(<circle key={`o${s}`} cx={openX} cy={y} r={9} fill="#2a2d32" stroke="#a6a7aa" strokeWidth={1.5} />);
        if (displayText) {
          markers.push(
            <text 
              key={`ot${s}`} 
              x={openX} 
              y={y+3} 
              fontSize={fontSize} 
              fill="#e7e7ea" 
              textAnchor="middle" 
              fontWeight={600}
            >
              {displayText}
            </text>
          );
        }
      }
    } else if (typeof f === 'number') {
      const x = xForFret(f);
      markers.push(<circle key={`p${s}`} cx={x} cy={y} r={11} fill="#1f2328" stroke="#3b3f45" />);
      
      // Display content based on mode
      let displayText = '';
      let fontSize = 12;
      if (displayMode === 'finger' && finger) {
        displayText = finger.toString();
      } else if (displayMode === 'note') {
        displayText = getNoteName(s, f);
        fontSize = 10;
      } else if (displayMode === 'roman') {
        const noteName = getNoteName(s, f);
        displayText = getRoman(noteName, root);
        fontSize = 9;
      }
      
      if (displayText) {
        markers.push(
          <text 
            key={`t${s}`} 
            x={x} 
            y={y+4} 
            fontSize={fontSize} 
            fill="#ffffff" 
            textAnchor="middle" 
            fontWeight={700}
          >
            {displayText}
          </text>
        );
      }
    }
  }

  return (
    <svg width={width} height={height} role="img" aria-label="Chord diagram">
      {nut}{grid}{fretNumbers}{barreEls}{markers}
    </svg>
  );
}

