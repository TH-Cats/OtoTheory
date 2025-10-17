#!/usr/bin/env node
// Extract Dominant 7th (quality '7') Open/Root-6/Root-5/Root-4 from StaticChordProvider.swift
// Append to master CSV.

import fs from 'node:fs';

const SWIFT_PATH = '/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Services/StaticChordProvider.swift';
const CSV_PATH = '/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv';

function read(p){ return fs.readFileSync(p,'utf8'); }

function parse7(sw){
  // Simpler global scan: find any StaticForm whose id begins with [A-G]#?7-
  const formRe = /StaticForm\([\s\S]*?id:\s*"([A-G]#?7)-(\d+)-(Open|Root6|Root-6|Root5|Root-5|Root4|Root-4)"[\s\S]*?shapeName:\s*"?(Open|Root-6|Root-5|Root-4|Open)"?[\s\S]*?frets:\s*\[(.*?)\][\s\S]*?fingers:\s*\[(.*?)\][\s\S]*?barres:/g;
  const res=[]; let fm;
  while((fm = formRe.exec(sw))){
    const symbol = fm[1];
    const seq = fm[2];
    const shape = fm[4].replace('Root6','Root-6').replace('Root5','Root-5').replace('Root4','Root-4');
    const fretsRaw = fm[5];
    const fingersRaw = fm[6];
    const frets = fretsRaw.split(',').map(s=>s.trim()).map(s=>{
      if (s === '.x') return 'x';
      if (s === '.open') return '0';
      const mm = /F\((\d+)\)/.exec(s);
      return mm ? mm[1] : '';
    });
    const map={'.one':'1','.two':'2','.three':'3','.four':'4'};
    const fingers = fingersRaw.split(',').map(s=>s.trim()).map(s=> map[s] ?? '-');
    const pad6=a=>{while(a.length<6)a.push('');return a.slice(0,6)};
    res.push({ symbol, shape, seq, frets: pad6(frets), fingers: pad6(fingers) });
  }
  return res;
}

function append(csvPath, items){
  const csv = read(csvPath).trimEnd();
  const rows = items.map(it=>{
    const chord = it.symbol;
    const cols=[
      chord, chord, '7', '99', `${chord}-${it.seq}-${it.shape}`, it.shape,
      ...it.frets, ...it.fingers, '', '', '', 'Dominant 7th (extracted)'
    ];
    return cols.join(',');
  });
  fs.writeFileSync(csvPath, csv+'\n'+rows.join('\n')+'\n','utf8');
}

function main(){
  const sw = read(SWIFT_PATH);
  const items = parse7(sw);
  append(CSV_PATH, items);
  console.log(`Appended dominant7 forms: ${items.length}`);
}

main();


