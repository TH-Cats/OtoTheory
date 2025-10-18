#!/usr/bin/env node
// Extract minor7 (m7) Open/Root-6/Root-5/Root-4 from StaticChordProvider.swift and append to CSV
import fs from 'node:fs';
const SWIFT_PATH='/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Services/StaticChordProvider.swift';
const CSV_PATH='/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv';
function read(p){return fs.readFileSync(p,'utf8');}
function parse(sw){
  const formRe=/StaticForm\([\s\S]*?id:\s*"([A-G]#?m7)-(\d+)-(Open|Root6|Root-6|Root5|Root-5|Root4|Root-4)"[\s\S]*?shapeName:\s*"?(Open|Root-6|Root-5|Root-4)"?[\s\S]*?frets:\s*\[(.*?)\][\s\S]*?fingers:\s*\[(.*?)\][\s\S]*?barres:/g;
  const res=[]; let m;
  while((m=formRe.exec(sw))){
    const symbol=m[1]; const seq=m[2];
    const shape=m[4].replace('Root6','Root-6').replace('Root5','Root-5').replace('Root4','Root-4');
    const fretsRaw=m[5]; const fingersRaw=m[6];
    const frets=fretsRaw.split(',').map(s=>s.trim()).map(s=>s==='.x'?'x':s==='.open'?'0':(/F\((\d+)\)/.exec(s)||[])[1]||'');
    const map={'.one':'1','.two':'2','.three':'3','.four':'4'};
    const fingers=fingersRaw.split(',').map(s=>s.trim()).map(s=>map[s]??'-');
    const pad6=a=>{while(a.length<6)a.push('');return a.slice(0,6)};
    res.push({symbol,seq,shape,frets:pad6(frets),fingers:pad6(fingers)});
  }
  return res;
}
function append(csvPath,items){
  const csv=read(csvPath).trimEnd();
  const rows=items.map(it=>[it.symbol,it.symbol,'m7','99',`${it.symbol}-${it.seq}-${it.shape}`,it.shape,...it.frets,...it.fingers,'','','','Minor 7th (extracted)'].join(','));
  fs.writeFileSync(csvPath,csv+'\n'+rows.join('\n')+'\n','utf8');
}
function main(){const sw=read(SWIFT_PATH);const items=parse(sw);append(CSV_PATH,items);console.log(`Appended m7 forms: ${items.length}`);}main();



