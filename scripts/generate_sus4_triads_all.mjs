#!/usr/bin/env node
// Generate sus4 Triad-1/2 for all keys by transposing Csus4 patterns
import fs from 'node:fs';

const CSV_PATH = '/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv';

function readCsv(path){ return fs.readFileSync(path,'utf8').trimEnd().split('\n'); }
function parseRow(line){
  const cols=[]; let cur=''; let inQ=false;
  for(let i=0;i<line.length;i++){
    const ch=line[i];
    if(inQ){
      if(ch==='"') { if(line[i+1]==='"'){cur+='"'; i++;} else inQ=false; }
      else cur+=ch;
    } else {
      if(ch==='"') inQ=true; else if(ch===','){ cols.push(cur); cur=''; } else cur+=ch;
    }
  }
  cols.push(cur); return cols;
}
function toLine(cols){
  return cols.map(c=>{ const s=String(c??''); return /[",\n\r]/.test(s)? '"'+s.replaceAll('"','""')+'"' : s; }).join(',');
}

const KEYS = ['Csus4','C#sus4','Dsus4','D#sus4','Esus4','Fsus4','F#sus4','Gsus4','G#sus4','Asus4','A#sus4','Bsus4'];
const keyToDelta = { 'Csus4':0,'C#sus4':1,'Dsus4':2,'D#sus4':3,'Esus4':4,'Fsus4':5,'F#sus4':6,'Gsus4':7,'G#sus4':8,'Asus4':9,'A#sus4':10,'Bsus4':11 };

function transposeFrets(frets, delta){
  return frets.map(v=>{ if(v==='x'||v==='') return v; const n=Number(v); return String(n+delta); });
}

function main(){
  const lines = readCsv(CSV_PATH);
  const header = lines[0];
  const body = lines.slice(1);
  let triad1=null, triad2=null;
  const existingBySymbolTriad = new Map();

  for(const ln of body){
    if(!ln) continue; const c=parseRow(ln);
    const symbol=c[1], shape=c[5];
    if(symbol==='Csus4' && shape==='Triad-1') triad1 = c;
    if(symbol==='Csus4' && shape==='Triad-2') triad2 = c;
    if(!existingBySymbolTriad.has(symbol)) existingBySymbolTriad.set(symbol, new Set());
    existingBySymbolTriad.get(symbol).add(shape);
  }
  if(!triad1 || !triad2){
    console.error('Csus4 Triad-1/2 patterns not found'); process.exit(1);
  }
  const patt1Frets = triad1.slice(6,12); const patt1Fingers = triad1.slice(12,18);
  const patt2Frets = triad2.slice(6,12); const patt2Fingers = triad2.slice(12,18);

  const out=[header, ...body];
  for(const sym of KEYS){
    const delta = keyToDelta[sym]; if(delta==null) continue;
    const existing = existingBySymbolTriad.get(sym) || new Set();
    const addTriad = (shapeName, pattFrets, pattFingers, order, idTag) => {
      if(existing.has(shapeName)) return; // already present
      const fretsT = transposeFrets(pattFrets, delta);
      const cols=[sym,sym,'sus4',String(order),`${sym}-${idTag}`,shapeName,
        ...fretsT, ...pattFingers, '', '', '', `${sym} ${shapeName} (auto from Csus4 +${delta})`];
      out.push(toLine(cols));
    };
    addTriad('Triad-1', patt1Frets, patt1Fingers, 5, '5-Triad1');
    addTriad('Triad-2', patt2Frets, patt2Fingers, 6, '6-Triad2');
  }

  fs.writeFileSync(CSV_PATH, out.join('\n')+'\n','utf8');
  console.log('Generated sus4 Triad-1/2 for all keys');
}

main();



