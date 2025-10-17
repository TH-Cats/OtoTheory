#!/usr/bin/env node

import fs from 'fs';
import path from 'path';

const CSV_PATH = '/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv';
const OUTPUT_PATH = '/Users/nh/App/OtoTheory/ototheory-web/src/lib/chord-library-static.ts';

// Read CSV
const csvContent = fs.readFileSync(CSV_PATH, 'utf8');
const lines = csvContent.split('\n').filter(line => line.trim());

// Parse CSV header
const header = lines[0].split(',');
const chordIndex = header.indexOf('Chord');
const symbolIndex = header.indexOf('Symbol');
const qualityIndex = header.indexOf('Quality');
const formOrderIndex = header.indexOf('FormOrder');
const formIdIndex = header.indexOf('FormID');
const shapeNameIndex = header.indexOf('ShapeName');
const fret1Index = header.indexOf('Fret1');
const fret2Index = header.indexOf('Fret2');
const fret3Index = header.indexOf('Fret3');
const fret4Index = header.indexOf('Fret4');
const fret5Index = header.indexOf('Fret5');
const fret6Index = header.indexOf('Fret6');
const finger1Index = header.indexOf('Finger1');
const finger2Index = header.indexOf('Finger2');
const finger3Index = header.indexOf('Finger3');
const finger4Index = header.indexOf('Finger4');
const finger5Index = header.indexOf('Finger5');
const finger6Index = header.indexOf('Finger6');
const barreFretIndex = header.indexOf('BarreFret');
const barreFromIndex = header.indexOf('BarreFrom');
const barreToIndex = header.indexOf('BarreTo');
const tipsIndex = header.indexOf('Tips');

// Group chords by symbol
const chordGroups = new Map();

for (let i = 1; i < lines.length; i++) {
  const line = lines[i];
  if (!line.trim()) continue;
  
  const fields = line.split(',');
  if (fields.length < 20) continue;
  
  const chord = fields[chordIndex]?.trim();
  const symbol = fields[symbolIndex]?.trim();
  const quality = fields[qualityIndex]?.trim();
  const formOrder = fields[formOrderIndex]?.trim();
  const formId = fields[formIdIndex]?.trim();
  const shapeName = fields[shapeNameIndex]?.trim();
  
  if (!chord || !symbol || !quality) continue;
  
  // Parse frets (1st to 6th string)
  const frets = [
    fields[fret1Index]?.trim() || 'x',
    fields[fret2Index]?.trim() || 'x',
    fields[fret3Index]?.trim() || 'x',
    fields[fret4Index]?.trim() || 'x',
    fields[fret5Index]?.trim() || 'x',
    fields[fret6Index]?.trim() || 'x'
  ];
  
  // Parse fingers (1st to 6th string)
  const fingers = [
    fields[finger1Index]?.trim() || '-',
    fields[finger2Index]?.trim() || '-',
    fields[finger3Index]?.trim() || '-',
    fields[finger4Index]?.trim() || '-',
    fields[finger5Index]?.trim() || '-',
    fields[finger6Index]?.trim() || '-'
  ];
  
  // Parse barre info
  const barreFret = fields[barreFretIndex]?.trim();
  const barreFrom = fields[barreFromIndex]?.trim();
  const barreTo = fields[barreToIndex]?.trim();
  
  // Parse tips
  const tips = fields[tipsIndex]?.trim() || '';
  
  if (!chordGroups.has(symbol)) {
    chordGroups.set(symbol, {
      symbol,
      quality,
      forms: []
    });
  }
  
  const form = {
    formOrder: parseInt(formOrder) || 0,
    formId,
    shapeName,
    frets,
    fingers,
    barreFret,
    barreFrom,
    barreTo,
    tips
  };
  
  chordGroups.get(symbol).forms.push(form);
}

// Convert to TypeScript format
function convertFretToTS(fret) {
  if (fret === 'x' || fret === '') return "'x'";
  if (fret === '0') return '0';
  return parseInt(fret);
}

function convertFingerToTS(finger) {
  if (finger === '-' || finger === '' || !finger) return 'null';
  return parseInt(finger);
}

function generateBarreTS(barreFret, barreFrom, barreTo, finger) {
  if (!barreFret || !barreFrom || !barreTo) return null;
  
  const fingerStr = convertFingerToTS(finger);
  return `{ fret: ${barreFret}, fromString: ${barreFrom}, toString: ${barreTo}, finger: ${fingerStr} }`;
}

// Generate TypeScript code
let tsCode = `// Static chord library data for Web version
// Based on Chord Library Mastar.csv
// Array order: 1st string (high E) to 6th string (low E)

export type StaticFret = number | 0 | 'x';
export type StaticFinger = 1 | 2 | 3 | 4 | null;

export interface StaticBarre {
  fret: number;
  fromString: number; // 1 = high E, 6 = low E
  toString: number;
  finger?: StaticFinger;
}

export interface StaticForm {
  id: string;
  shapeName: string | null; // null = infer from data
  frets: [StaticFret, StaticFret, StaticFret, StaticFret, StaticFret, StaticFret]; // 1→6
  fingers: [StaticFinger, StaticFinger, StaticFinger, StaticFinger, StaticFinger, StaticFinger]; // 1→6
  barres: StaticBarre[];
  tips: string[];
}

export interface StaticChord {
  id: string;
  symbol: string;
  quality: string;
  forms: StaticForm[];
}

// Helper function to create fret notation
const F = (n: number): number => n;

// All static chords from master CSV
export const ALL_STATIC_CHORDS: StaticChord[] = [
`;

// Sort chords by symbol
const sortedChords = Array.from(chordGroups.values()).sort((a, b) => a.symbol.localeCompare(b.symbol));

for (const chord of sortedChords) {
  // Sort forms by formOrder
  chord.forms.sort((a, b) => a.formOrder - b.formOrder);
  
  tsCode += `  // ${chord.symbol} (${chord.quality})\n`;
  tsCode += `  {\n`;
  tsCode += `    id: '${chord.symbol}',\n`;
  tsCode += `    symbol: '${chord.symbol}',\n`;
  tsCode += `    quality: '${chord.quality}',\n`;
  tsCode += `    forms: [\n`;
  
  for (const form of chord.forms) {
    tsCode += `      {\n`;
    tsCode += `        id: '${form.formId}',\n`;
    tsCode += `        shapeName: ${form.shapeName ? `'${form.shapeName}'` : 'null'},\n`;
    tsCode += `        frets: [${form.frets.map(convertFretToTS).join(', ')}],\n`;
    tsCode += `        fingers: [${form.fingers.map(convertFingerToTS).join(', ')}],\n`;
    
    // Generate barres
    const barres = [];
    if (form.barreFret && form.barreFrom && form.barreTo) {
      const barreFinger = form.fingers[parseInt(form.barreFrom) - 1];
      const barre = generateBarreTS(form.barreFret, form.barreFrom, form.barreTo, barreFinger);
      if (barre) barres.push(barre);
    }
    
    if (barres.length > 0) {
      tsCode += `        barres: [${barres.join(', ')}],\n`;
    } else {
      tsCode += `        barres: [],\n`;
    }
    
    tsCode += `        tips: [${form.tips ? `'${form.tips}'` : ''}]\n`;
    tsCode += `      }`;
    
    if (form !== chord.forms[chord.forms.length - 1]) {
      tsCode += ',';
    }
    tsCode += '\n';
  }
  
  tsCode += `    ]\n`;
  tsCode += `  }`;
  
  if (chord !== sortedChords[sortedChords.length - 1]) {
    tsCode += ',';
  }
  tsCode += '\n';
}

tsCode += `\n];

// Helper to find chord by symbol
export function getStaticChord(symbol: string): StaticChord | undefined {
  return ALL_STATIC_CHORDS.find(c => c.symbol === symbol);
}
`;

// Write to file
fs.writeFileSync(OUTPUT_PATH, tsCode);
console.log(`Generated Web chord-library-static.ts with ${sortedChords.length} chords`);
