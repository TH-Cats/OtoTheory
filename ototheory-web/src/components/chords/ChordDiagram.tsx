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

const PAD = { left: 28, right: 16, top: 26, bottom: 16 };

export function ChordDiagram({ frets, fingers, barres = [], width = 300, maxFrets = 5 }: Props) {
  const height = 220;
  const innerW = width - PAD.left - PAD.right;
  const innerH = height - PAD.top - PAD.bottom;
  const cols = 6, rows = maxFrets;
  const colW = innerW / (cols - 1);
  const rowH = innerH / rows;

  const pos = frets.filter(f => typeof f === 'number' && f > 0) as number[];
  const baseFret = pos.length ? Math.min(...pos) : 1;
  const showNut = baseFret === 1;

  const xFor = (sIdx:number) => PAD.left + colW * sIdx;
  const yForFret = (abs:number) => {
    if (abs === 0) return PAD.top - 12;
    const rel = abs - baseFret + 1;
    return PAD.top + rowH * (rel - 0.5);
  };

  const grid: JSX.Element[] = [];
  for (let i=0;i<cols;i++) grid.push(<line key={`v${i}`} x1={xFor(i)} y1={PAD.top} x2={xFor(i)} y2={PAD.top+innerH} stroke="#575a5f" strokeWidth={1} />);
  for (let r=1;r<=rows;r++) grid.push(<line key={`h${r}`} x1={PAD.left} y1={PAD.top+rowH*r} x2={PAD.left+innerW} y2={PAD.top+rowH*r} stroke="#575a5f" strokeWidth={1} />);

  const nut = showNut
    ? <rect x={PAD.left-1.5} y={PAD.top-7} width={innerW+3} height={7} fill="#e7e7ea" rx={3}/>
    : <text x={PAD.left-6} y={PAD.top-8} fontSize="12" textAnchor="end" fill="#9aa0a6">{baseFret}fr</text>;

  const barreEls = barres.map((b,i) => {
    const y = yForFret(b.fret);
    const x1 = xFor(6 - b.fromString);
    const x2 = xFor(6 - b.toString);
    const x = Math.min(x1, x2) - 10;
    const w = Math.abs(x2 - x1) + 20;
    return <rect key={`barre${i}`} x={x} y={y-10} width={w} height={20} rx={10} fill="#2dd4bf" opacity={0.3} />;
  });

  const markers: JSX.Element[] = [];
  for (let s=0; s<6; s++) {
    const f = frets[s];
    const finger = fingers?.[s] ?? null;
    const x = xFor(s);
    if (f === 'x') {
      markers.push(<text key={`x${s}`} x={x} y={PAD.top-10} fill="#ef4444" fontSize="14" textAnchor="middle">×</text>);
    } else if (f === 0) {
      markers.push(<circle key={`o${s}`} cx={x} cy={PAD.top-12} r={6} fill="none" stroke="#a6a7aa" strokeWidth={1.5} />);
    } else if (typeof f === 'number') {
      const y = yForFret(f);
      markers.push(<circle key={`p${s}`} cx={x} cy={y} r={11} fill="#1f2328" stroke="#3b3f45" />);
      if (finger) markers.push(<text key={`t${s}`} x={x} y={y+4} fontSize="12" fill="#ffffff" textAnchor="middle" fontWeight={700}>{finger}</text>);
    }
  }

  return (
    <svg width={width} height={height} role="img" aria-label="Chord diagram">
      {nut}{grid}{barreEls}{markers}
    </svg>
  );
}

