#!/usr/bin/env node
// Extract diminished (dim) forms from StaticChordProvider.swift and append to CSV
import fs from 'node:fs';
const SWIFT_PATH='/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Services/StaticChordProvider.swift';
const CSV_PATH='/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv';
function read(p){return fs.readFileSync(p,'utf8');}
function parse(sw){
  const formRe=/StaticForm\([\s\S]*?id:\s*"([A-G]#?dim)-(\d+)"[\s\S]*?frets:\s*\[(.*?)\][\s\S]*?fingers:\s*\[(.*?)\][\s\S]*?barres:/g;
  const res=[]; let m;
  while((m=formRe.exec(sw))){
    const symbol=m[1]; const seq=m[2];
    const fretsRaw=m[3]; const fingersRaw=m[4];
    const frets=fretsRaw.split(',').map(s=>s.trim()).map(s=>s==='.x'?'x':s==='.open'?'0':(/F\((\d+)\)/.exec(s)||[])[1]||'');
    const map={'.one':'1','.two':'2','.three':'3','.four':'4'};
    const fingers=fingersRaw.split(',').map(s=>s.trim()).map(s=>s==='nil'?'-':map[s]??'-');
    const pad6=a=>{while(a.length<6)a.push('');return a.slice(0,6)};
    res.push({symbol,seq,frets:pad6(frets),fingers:pad6(fingers)});
  }
  return res;
}
function append(csvPath,items){
  const csv=read(csvPath).trimEnd();
  const rows=items.map(it=>[it.symbol,it.symbol,'dim','99',`${it.symbol}-${it.seq}`,'',...it.frets,...it.fingers,'','','','Diminished (extracted)'].join(','));
  fs.writeFileSync(csvPath,csv+'\n'+rows.join('\n')+'\n','utf8');
}
function main(){const sw=read(SWIFT_PATH);const items=parse(sw);append(CSV_PATH,items);console.log(`Appended dim forms: ${items.length}`);}main();


