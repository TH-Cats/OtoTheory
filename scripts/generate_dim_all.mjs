#!/usr/bin/env node
// Generate diminished chord forms for all keys by transposing Cdim patterns
import fs from 'node:fs';

const CSV_PATH = '/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv';

function readCsv(path){ return fs.readFileSync(path,'utf8').trimEnd().split('\n'); }

function parseRow(line){
  const cols = [];
  let cur = ''; let inQ = false;
  for (let i=0;i<line.length;i++){
    const ch=line[i];
    if (inQ){
      if (ch==='"'){
        if (line[i+1]==='"'){ cur+='"'; i++; }
        else inQ=false;
      } else cur+=ch;
    } else {
      if (ch==='"') inQ=true;
      else if (ch===','){ cols.push(cur); cur=''; }
      else cur+=ch;
    }
  }
  cols.push(cur);
  return cols;
}

function toLine(cols){
  return cols.map(c=>{
    const s=String(c??'');
    return /[",\n\r]/.test(s)? '"'+s.replaceAll('"','""')+'"' : s;
  }).join(',');
}

function getExistingSymbols(lines){
  const set=new Set();
  for(const ln of lines.slice(1)){
    if(!ln) continue;
    const c=parseRow(ln);
    if(c[2]==='dim') set.add(c[1]);
  }
  return set;
}

function getCdimPatterns(lines){
  const out={};
  for(const ln of lines){
    if(ln.startsWith('Cdim,')){
      const c=parseRow(ln);
      const id=c[4]; const shape=c[5];
      const frets=c.slice(6,12); const fingers=c.slice(12,18);
      if(shape==='Root-6') out.root6={frets,fingers,idFmt:'{sym}-1-Root6', shape};
      else if(shape==='Root-5') out.root5={frets,fingers,idFmt:'{sym}-2', shape};
      else if(shape==='Root-4') out.root4={frets,fingers,idFmt:'{sym}-3-Root-4', shape};
      else if(shape==='Triad-1') out.triad1={frets,fingers,idFmt:'{sym}-4-Triad-1', shape};
      else if(shape==='Triad-2') out.triad2={frets,fingers,idFmt:'{sym}-5-Triad-2', shape};
    }
  }
  return out;
}

const KEYS = ['Cdim','C#dim','Ddim','D#dim','Edim','Fdim','F#dim','Gdim','G#dim','Adim','A#dim','Bdim'];
const keyToDelta = {
  'Cdim':0,'C#dim':1,'Ddim':2,'D#dim':3,'Edim':4,'Fdim':5,'F#dim':6,'Gdim':7,'G#dim':8,'Adim':9,'A#dim':10,'Bdim':11
};

function transposeFrets(frets, delta){
  return frets.map(v=>{
    if(v==='x' || v==='') return v;
    const n = Number(v); if(!Number.isFinite(n)) return v;
    return String(n + delta);
  });
}

function main(){
  const lines=readCsv(CSV_PATH);
  const header=lines[0];
  const exists=getExistingSymbols(lines);
  const pat=getCdimPatterns(lines);
  const pieces=[header, ...lines.slice(1)];

  for(const sym of KEYS){
    if(exists.has(sym)) continue; // already present
    const delta=keyToDelta[sym];
    const add = entry => {
      const fretsT=transposeFrets(entry.frets, delta);
      const cols=[sym,sym,'dim','99',entry.idFmt.replace('{sym}', sym),entry.shape,
        ...fretsT, ...entry.fingers, '', '', '', `Diminished (auto from Cdim +${delta})`];
      pieces.push(toLine(cols));
    };
    if(pat.root6) add(pat.root6);
    if(pat.root5) add(pat.root5);
    if(pat.root4) add(pat.root4);
    if(pat.triad1) add(pat.triad1);
    if(pat.triad2) add(pat.triad2);
  }

  fs.writeFileSync(CSV_PATH, pieces.join('\n')+'\n','utf8');
  console.log('Generated dim forms for all keys');
}

main();



