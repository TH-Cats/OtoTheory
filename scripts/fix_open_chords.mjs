#!/usr/bin/env node

import fs from 'fs';

const csvPath = '/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv';

// CSVを読み込み
const csvContent = fs.readFileSync(csvPath, 'utf8');
const lines = csvContent.split('\n');
const header = lines[0];
const dataLines = lines.slice(1).filter(line => line.trim());

// Openコードのフレット配列を1フレットから始まるように修正
const correctedLines = dataLines.map(line => {
  const parts = line.split(',');
  const shapeName = parts[5];
  
  // Openコードの場合のみ修正
  if (shapeName === 'Open') {
    const fret1 = parseInt(parts[6]) || 0;
    const fret2 = parseInt(parts[7]) || 0;
    const fret3 = parseInt(parts[8]) || 0;
    const fret4 = parseInt(parts[9]) || 0;
    const fret5 = parseInt(parts[10]) || 0;
    const fret6 = parseInt(parts[11]) || 0;
    
    // 全てのフレットに+1を適用（0は0のまま、xはxのまま）
    const newFret1 = fret1 === 0 ? 0 : fret1 + 1;
    const newFret2 = fret2 === 0 ? 0 : fret2 + 1;
    const newFret3 = fret3 === 0 ? 0 : fret3 + 1;
    const newFret4 = fret4 === 0 ? 0 : fret4 + 1;
    const newFret5 = fret5 === 0 ? 0 : fret5 + 1;
    const newFret6 = fret6 === 0 ? 0 : fret6 + 1;
    
    // フレット配列を更新
    parts[6] = newFret1.toString();
    parts[7] = newFret2.toString();
    parts[8] = newFret3.toString();
    parts[9] = newFret4.toString();
    parts[10] = newFret5.toString();
    parts[11] = newFret6.toString();
  }
  
  return parts.join(',');
});

// 結果を書き込み
const result = [header, ...correctedLines].join('\n');
fs.writeFileSync(csvPath, result);

console.log('Openコードのフレット配列を1フレットから始まるように修正しました');

