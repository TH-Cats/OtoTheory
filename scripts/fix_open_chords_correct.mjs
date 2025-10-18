#!/usr/bin/env node

import fs from 'fs';

const csvPath = '/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv';

// CSVを読み込み
const csvContent = fs.readFileSync(csvPath, 'utf8');
const lines = csvContent.split('\n');
const header = lines[0];
const dataLines = lines.slice(1).filter(line => line.trim());

// Openコードの正しいフレット配列を定義
const correctOpenChords = {
  'CM7-1': [0,0,0,2,3,'x'],
  'EM7-1-Open': [0,0,1,1,2,0],
  'AM7-1-Open': [0,2,1,2,0,'x'],
  'FM7': [0,1,2,3,3,'x'],
  'C-1-Open': [0,1,0,2,3,'x'],
  'E-1-Open': [0,0,1,2,2,0],
  'A-1-Open': [0,2,2,2,0,'x'],
  'Am-1-Open': [0,1,2,2,0,'x'],
  'Em-1-Open': [0,0,0,2,2,0],
  'F#7-1-Open': [0,2,3,4,'x','x'],
  'A7-1-Open': [0,2,0,2,0,'x'],
  'C7-1-Open': [0,1,3,2,3,'x'],
  'E7-1-Open': [0,0,1,0,2,0],
  'C#m7-1-Open': [0,0,0,1,2,'x'],
  'Am7-1-Open': [0,1,0,2,0,'x'],
  'Esus4-1-Open': [0,0,2,2,0,0],
  'Cadd9-1-Open': [0,3,0,2,3,'x'],
  'Aadd9-1-Open': [0,2,4,2,0,'x'],
  'Asus4-1-Open': [0,3,2,2,0,'x'],
  'Dsus2-1-Open': [0,3,2,0,'x','x'],
  'Esus2-1-Open': [0,0,4,4,2,0],
  'Asus2-1-Open': [0,0,2,2,0,'x'],
  'C6-1-Open': [0,1,2,2,3,'x'],
  'E6-1-Open': [0,2,1,2,2,0],
  'G6-1-Open': [0,0,0,0,2,3],
  'Bm6-1-Open': [0,0,1,0,2,'x'],
  'Eaug-1-Open': [0,1,1,2,3,0],
  'Em6-1-Open': [0,2,0,2,2,0],
  'Gm6-1-Open': [0,3,0,0,1,3],
  'Am6-1-Open': [0,1,2,2,0,'x'],
  'Bm9-1-Open': [0,0,2,4,2,'x'],
  'Cm9-1-Open': [0,0,3,5,3,'x'],
  'Dm9-1-Open': [0,0,5,7,5,'x'],
  'Em9-1-Open': [0,0,7,9,7,'x'],
  'Fm9-1-Open': [0,0,8,10,8,'x'],
  'Gm9-1-Open': [0,0,10,12,10,'x']
};

// Openコードのフレット配列を正しい値に修正
const correctedLines = dataLines.map(line => {
  const parts = line.split(',');
  const formId = parts[4];
  const shapeName = parts[5];
  
  // Openコードの場合のみ修正
  if (shapeName === 'Open' && correctOpenChords[formId]) {
    const correctFrets = correctOpenChords[formId];
    parts[6] = correctFrets[0].toString();
    parts[7] = correctFrets[1].toString();
    parts[8] = correctFrets[2].toString();
    parts[9] = correctFrets[3].toString();
    parts[10] = correctFrets[4].toString();
    parts[11] = correctFrets[5].toString();
  }
  
  return parts.join(',');
});

// 結果を書き込み
const result = [header, ...correctedLines].join('\n');
fs.writeFileSync(csvPath, result);

console.log('Openコードのフレット配列を正しい値に修正しました');

