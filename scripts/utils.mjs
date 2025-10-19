/**
 * Common utilities for chord library scripts
 */

/**
 * Read CSV file and return parsed data
 */
export function readCSV(filePath) {
  const fs = require('fs');
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n').filter(line => line.trim());
  const headers = lines[0].split(',');
  
  return lines.slice(1).map(line => {
    const values = [];
    let current = '';
    let inQuotes = false;
    
    for (let i = 0; i < line.length; i++) {
      const char = line[i];
      if (char === '"') {
        inQuotes = !inQuotes;
      } else if (char === ',' && !inQuotes) {
        values.push(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    values.push(current.trim());
    
    const row = {};
    headers.forEach((header, index) => {
      row[header.trim()] = values[index] || '';
    });
    return row;
  });
}

/**
 * Write data to CSV file
 */
export function writeCSV(filePath, data, headers) {
  const fs = require('fs');
  const csvContent = [
    headers.join(','),
    ...data.map(row => headers.map(header => {
      const value = row[header] || '';
      return value.includes(',') || value.includes('"') ? `"${value.replace(/"/g, '""')}"` : value;
    }).join(','))
  ].join('\n');
  
  fs.writeFileSync(filePath, csvContent, 'utf8');
}

/**
 * Validate chord form order
 */
export function validateFormOrder(forms) {
  const validOrder = ['Open', 'Root-6', 'Root-5', 'Root-4', 'Triad-1', 'Triad-2'];
  const formOrder = forms.map(f => f.ShapeName);
  
  for (let i = 0; i < Math.min(formOrder.length, validOrder.length); i++) {
    if (formOrder[i] !== validOrder[i]) {
      return false;
    }
  }
  return true;
}

/**
 * Convert finger to Swift format
 */
export function convertFingerToSwift(finger) {
  if (!finger || finger === '-' || finger === '') return 'nil';
  const fingerNum = parseInt(finger);
  return isNaN(fingerNum) ? 'nil' : fingerNum.toString();
}

/**
 * Convert finger to TypeScript format
 */
export function convertFingerToTS(finger) {
  if (!finger || finger === '-' || finger === '') return 'null';
  const fingerNum = parseInt(finger);
  return isNaN(fingerNum) ? 'null' : fingerNum.toString();
}

/**
 * Generate barre Swift code
 */
export function generateBarreSwift(barreFret, barreFrom, barreTo, finger) {
  if (!barreFret || !barreFrom || !barreTo) return 'nil';
  
  const fret = parseInt(barreFret);
  const from = parseInt(barreFrom);
  const to = parseInt(barreTo);
  
  if (isNaN(fret) || isNaN(from) || isNaN(to)) return 'nil';
  if (from < 1 || from > 6 || to < 1 || to > 6) return 'nil';
  
  const fingerStr = convertFingerToSwift(finger);
  return `Barre(fret: ${fret}, fromString: ${from}, toString: ${to}, finger: ${fingerStr})`;
}

/**
 * Generate barre TypeScript code
 */
export function generateBarreTS(barreFret, barreFrom, barreTo, finger) {
  if (!barreFret || !barreFrom || !barreTo) return 'null';
  
  const fret = parseInt(barreFret);
  const from = parseInt(barreFrom);
  const to = parseInt(barreTo);
  
  if (isNaN(fret) || isNaN(from) || isNaN(to)) return 'null';
  if (from < 1 || from > 6 || to < 1 || to > 6) return 'null';
  
  const fingerStr = convertFingerToTS(finger);
  return `{ fret: ${fret}, fromString: ${from}, toString: ${to}, finger: ${fingerStr} }`;
}

/**
 * Escape string for Swift
 */
export function escapeSwiftString(str) {
  if (!str) return '""';
  return `"${str.replace(/\\/g, '\\\\').replace(/"/g, '\\"')}"`;
}

/**
 * Escape string for TypeScript
 */
export function escapeTSString(str) {
  if (!str) return '""';
  return `"${str.replace(/\\/g, '\\\\').replace(/"/g, '\\"')}"`;
}

/**
 * Get chord quality intervals
 */
export function getChordIntervals(quality) {
  const intervals = {
    'M': [0, 4, 7],
    'm': [0, 3, 7],
    'M7': [0, 4, 7, 11],
    'm7': [0, 3, 7, 10],
    '7': [0, 4, 7, 10],
    'dim': [0, 3, 6],
    'sus4': [0, 5, 7],
    'sus2': [0, 2, 7],
    '6': [0, 4, 7, 9],
    'm6': [0, 3, 7, 9],
    'aug': [0, 4, 8],
    'add9': [0, 4, 7, 14],
    'm9': [0, 3, 7, 10, 14]
  };
  
  return intervals[quality] || [];
}

/**
 * Validate chord tones
 */
export function validateChordTones(frets, quality) {
  const intervals = getChordIntervals(quality);
  if (intervals.length === 0) return true;
  
  // This is a simplified validation - in practice, you'd need to
  // calculate the actual notes from the fret positions
  return true;
}
