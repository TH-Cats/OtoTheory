#!/usr/bin/env node

import fs from 'fs';
import path from 'path';

const csvPath = '/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv';

// CSVを読み込み
const csvContent = fs.readFileSync(csvPath, 'utf8');
const lines = csvContent.split('\n');
const header = lines[0];
const dataLines = lines.slice(1).filter(line => line.trim());

// コードごとにグループ化
const chordGroups = {};
dataLines.forEach(line => {
  const [chord, symbol, quality] = line.split(',');
  const key = `${chord}-${quality}`;
  if (!chordGroups[key]) {
    chordGroups[key] = [];
  }
  chordGroups[key].push(line);
});

// 各コードグループのフォーム順序を修正
const correctedLines = [];
Object.values(chordGroups).forEach(group => {
  // フォーム順序でソート
  group.sort((a, b) => {
    const orderA = parseInt(a.split(',')[3]) || 999;
    const orderB = parseInt(b.split(',')[3]) || 999;
    return orderA - orderB;
  });
  
  // フォーム順序を正しく再割り当て
  group.forEach((line, index) => {
    const parts = line.split(',');
    const shapeName = parts[5];
    
    // 正しい順序を決定
    let correctOrder;
    if (shapeName === 'Open') {
      correctOrder = 1;
    } else if (shapeName === 'Root-6') {
      correctOrder = 2;
    } else if (shapeName === 'Root-5') {
      correctOrder = 3;
    } else if (shapeName === 'Root-4') {
      correctOrder = 4;
    } else if (shapeName === 'Triad-1') {
      correctOrder = 5;
    } else if (shapeName === 'Triad-2') {
      correctOrder = 6;
    } else {
      correctOrder = index + 1;
    }
    
    // FormOrderを更新
    parts[3] = correctOrder.toString();
    correctedLines.push(parts.join(','));
  });
});

// 結果を書き込み
const result = [header, ...correctedLines].join('\n');
fs.writeFileSync(csvPath, result);

console.log('フォーム順序の修正が完了しました');
console.log(`修正されたコード数: ${Object.keys(chordGroups).length}`);

