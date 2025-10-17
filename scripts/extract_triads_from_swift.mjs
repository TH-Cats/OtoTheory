#!/usr/bin/env node
// Extract Triad-1/2 forms (Major/Minor, all keys) from iOS StaticChordProvider.swift
// Append to the master CSV in the canonical column order.

import fs from 'node:fs';

const SWIFT_PATH = '/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Services/StaticChordProvider.swift';
const CSV_PATH = '/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv';

function read(path){ return fs.readFileSync(path,'utf8'); }

function parseTriads(swift){
  // Regex blocks capturing: id line, shapeName, frets array, fingers array
  const triadRegex = /StaticForm\(\s*id:\s*"([A-G]#?m?)-(\d+)-Triad(1|2)"[\s\S]*?shapeName:\s*"(Triad-1|Triad-2)"[\s\S]*?frets:\s*\[(.*?)\][\s\S]*?fingers:\s*\[(.*?)\][\s\S]*?barres:/g;
  const results = [];
  let m;
  while((m = triadRegex.exec(swift))){
    const symbol = m[1];
    const formSeq = m[2];
    const triadNum = m[3];
    const shapeName = m[4];
    const fretsRaw = m[5];
    const fingersRaw = m[6];
    const quality = symbol.endsWith('m') ? 'm' : 'M';
    const chord = symbol; // keep as is (e.g., C#m, G#)
    const frets = fretsRaw.split(',').map(s=>s.trim()).map(s=>{
      if (s === '.x') return 'x';
      if (s === '.open') return '0';
      const mm = /F\((\d+)\)/.exec(s);
      return mm ? mm[1] : '';
    });
    const fingerMap = { '.one':'1', '.two':'2', '.three':'3', '.four':'4' };
    const fingers = fingersRaw.split(',').map(s=>s.trim()).map(s=>{
      if (s === 'nil') return '-';
      return fingerMap[s] ?? '-';
    });
    // Normalize to 6 entries
    const pad6 = arr => { while(arr.length<6) arr.push(''); return arr.slice(0,6); };
    const frets6 = pad6(frets);
    const fingers6 = pad6(fingers);
    const formId = `${symbol}-${formSeq}-${shapeName.replace('Triad-','Triad')}`; // keep close to source
    results.push({ chord, symbol, quality, shapeName, formId, frets6, fingers6 });
  }
  return results;
}

function appendToCsv(csvPath, triads){
  const header = 'Chord,Symbol,Quality,FormOrder,FormID,ShapeName,Fret1,Fret2,Fret3,Fret4,Fret5,Fret6,Finger1,Finger2,Finger3,Finger4,Finger5,Finger6,BarreFret,BarreFrom,BarreTo,Tips';
  const csv = read(csvPath);
  if(!csv.startsWith('Chord,Symbol')) throw new Error('Unexpected CSV header');
  const lines = csv.trimEnd().split('\n');
  const rows = triads.map(t=>{
    const cols = [
      t.chord, t.symbol, t.quality,
      '99',
      t.formId,
      t.shapeName,
      ...t.frets6,
      ...t.fingers6,
      '', '', '',
      `Triad extracted from iOS (${t.shapeName})`
    ];
    return cols.join(',');
  });
  const out = lines.concat(rows).join('\n') + '\n';
  fs.writeFileSync(csvPath, out, 'utf8');
}

function main(){
  const swift = read(SWIFT_PATH);
  const triads = parseTriads(swift);
  // Filter to Major/Minor only (exclude 7th variants if any)
  const filtered = triads.filter(t => t.quality === 'M' || t.quality === 'm');
  appendToCsv(CSV_PATH, filtered);
  console.log(`Appended triads: ${filtered.length}`);
}

main();


