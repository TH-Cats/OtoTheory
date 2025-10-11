// /components/chords/ChordDiagram.tsx
import React from 'react';
import type { Barre, Fret, Finger } from '@/lib/chord-library';

type Props = {
  frets: [Fret, Fret, Fret, Fret, Fret, Fret];
  fingers?: [Finger, Finger, Finger, Finger, Finger, Finger];
  barres?: Barre[];
  width?: number;
  maxFrets?: number;
};

const PAD = { left: 16, right: 16, top: 16, bottom: 32 };

export function ChordDiagram({ frets, fingers, barres = [], width = 320, maxFrets = 5 }: Props) {
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
  // Strings go top to bottom (6th string at top)
  const yForString = (sIdx:number) => PAD.top + stringH * sIdx;

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
    if (f === 'x') {
      markers.push(<text key={`x${s}`} x={PAD.left-10} y={y+4} fill="#ef4444" fontSize="14" textAnchor="middle">×</text>);
    } else if (f === 0) {
      markers.push(<circle key={`o${s}`} cx={PAD.left-12} cy={y} r={6} fill="none" stroke="#a6a7aa" strokeWidth={1.5} />);
    } else if (typeof f === 'number') {
      const x = xForFret(f);
      markers.push(<circle key={`p${s}`} cx={x} cy={y} r={11} fill="#1f2328" stroke="#3b3f45" />);
      if (finger) markers.push(<text key={`t${s}`} x={x} y={y+4} fontSize="12" fill="#ffffff" textAnchor="middle" fontWeight={700}>{finger}</text>);
    }
  }

  return (
    <svg width={width} height={height} role="img" aria-label="Chord diagram">
      {nut}{grid}{fretNumbers}{barreEls}{markers}
    </svg>
  );
}

