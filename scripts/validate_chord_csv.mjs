#!/usr/bin/env node
/**
 * OtoTheory — Chord Library CSV Validator/Reorder (Static v0)
 *
 * Features:
 * - Validate shape order per chord: Open -> Root-6 -> Root-5 -> Root-4
 * - Recompute FormOrder as 1..N in the canonical shape order
 * - Validate chord tones for M7 quality (R, 3, 5, 7) against MIDI tuning
 * - Warn unknown/missing ShapeName
 * - Output report (JSON) and optionally write a reordered CSV (non-destructive)
 *
 * Usage:
 *   node scripts/validate_chord_csv.mjs \
 *     --input "/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv" \
 *     [--write]
 *
 * Outputs (alongside input file):
 *   - <input>.report.json
 *   - <input>.reordered.csv   (only when --write)
 */

import fs from 'node:fs';
import path from 'node:path';

// ------------------------- Config -------------------------
const DEFAULT_INPUT =
  '/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv';

// MIDI tuning for standard guitar (strings 1..6)
const MIDI_TUNING = [64, 59, 55, 50, 45, 40]; // E4, B3, G3, D3, A2, E2

// Canonical order of shapes
const SHAPE_ORDER = ['Open', 'Root-6', 'Root-5', 'Root-4', 'Triad-1', 'Triad-2'];

// Supported qualities and expected intervals (semitones from root)
const QUALITY_INTERVALS = {
  'M7': [0, 4, 7, 11],
  'maj': [0, 4, 7],
  'M': [0, 4, 7],
  'Major': [0, 4, 7],
  'm': [0, 3, 7],
  'min': [0, 3, 7],
  'Minor': [0, 3, 7],
  '7': [0, 4, 7, 10],
};

// ------------------------- CLI Args -------------------------
function parseArgs(argv) {
  const args = { input: DEFAULT_INPUT, write: false };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--input' && i + 1 < argv.length) {
      args.input = argv[++i];
    } else if (a === '--write') {
      args.write = true;
    } else if (a === '-h' || a === '--help') {
      console.log('Usage: node scripts/validate_chord_csv.mjs --input <file> [--write]');
      process.exit(0);
    }
  }
  return args;
}

// ------------------------- CSV Utils -------------------------
function parseCSV(text) {
  const rows = [];
  let row = [];
  let field = '';
  let inQuotes = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (inQuotes) {
      if (ch === '"') {
        if (text[i + 1] === '"') { // escaped quote
          field += '"';
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field += ch;
      }
    } else {
      if (ch === '"') {
        inQuotes = true;
      } else if (ch === ',') {
        row.push(field);
        field = '';
      } else if (ch === '\n') {
        row.push(field);
        rows.push(row);
        row = [];
        field = '';
      } else if (ch === '\r') {
        // ignore CR; handle CRLF by letting \n commit the row
      } else {
        field += ch;
      }
    }
  }
  // last field
  if (field.length > 0 || row.length > 0) {
    row.push(field);
    rows.push(row);
  }
  return rows;
}

function toCSV(rows) {
  return rows
    .map(cols => cols.map(cell => {
      const needsQuote = /[",\n\r]/.test(cell ?? '');
      const safe = String(cell ?? '').replaceAll('"', '""');
      return needsQuote ? `"${safe}"` : safe;
    }).join(','))
    .join('\n') + '\n';
}

// ------------------------- Theory Utils -------------------------
const NOTE_TO_PC = new Map([
  ['C', 0], ['B#', 0],
  ['C#', 1], ['Db', 1],
  ['D', 2],
  ['D#', 3], ['Eb', 3],
  ['E', 4], ['Fb', 4],
  ['F', 5], ['E#', 5],
  ['F#', 6], ['Gb', 6],
  ['G', 7],
  ['G#', 8], ['Ab', 8],
  ['A', 9],
  ['A#', 10], ['Bb', 10],
  ['B', 11], ['Cb', 11],
]);

function parseRoot(symbol) {
  // Extract leading note with optional accidental, e.g., Bb, C#, F
  const m = /^(?:([A-G])([#b]?))/i.exec(symbol);
  if (!m) return null;
  const letter = m[1].toUpperCase();
  const acc = m[2] ?? '';
  const key = letter + acc;
  return NOTE_TO_PC.get(key);
}

function getExpectedPcs(rootPc, quality) {
  const intervals = QUALITY_INTERVALS[quality];
  if (!intervals) return null;
  return new Set(intervals.map(semi => (rootPc + semi) % 12));
}

function fretToMidi(stringIndex /*1..6*/, fret) {
  const base = MIDI_TUNING[stringIndex - 1];
  return base + fret;
}

function collectChordPcs(row, headerIndex) {
  // Fret columns: Fret1..Fret6
  const pcs = new Set();
  for (let s = 1; s <= 6; s++) {
    const val = row[headerIndex[`Fret${s}`]]?.trim();
    if (!val || val.toLowerCase() === 'x') continue;
    const fret = Number(val);
    if (!Number.isFinite(fret)) continue;
    const midi = fretToMidi(s, fret);
    pcs.add(midi % 12);
  }
  return pcs;
}

// ------------------------- Main Logic -------------------------
function indexHeader(headerRow) {
  const idx = {};
  headerRow.forEach((h, i) => idx[h] = i);
  const required = ['Chord','Symbol','Quality','FormOrder','FormID','ShapeName',
    'Fret1','Fret2','Fret3','Fret4','Fret5','Fret6',
    'Finger1','Finger2','Finger3','Finger4','Finger5','Finger6',
    'BarreFret','BarreFrom','BarreTo','Tips'];
  for (const r of required) {
    if (!(r in idx)) {
      throw new Error(`Missing required column: ${r}`);
    }
  }
  return idx;
}

function shapeSortKey(shapeName) {
  const k = SHAPE_ORDER.indexOf(shapeName);
  return k === -1 ? 999 : k;
}

function groupByChord(rows, idx) {
  const map = new Map();
  for (const row of rows) {
    const key = row[idx['Chord']] || row[idx['Symbol']];
    if (!map.has(key)) map.set(key, []);
    map.get(key).push(row);
  }
  return map;
}

function reorderFormsPerChord(rows, idx) {
  // Stable sort: by shape order, then existing FormOrder (numeric), then FormID
  const withKeys = rows.map((r, i) => {
    const shape = r[idx['ShapeName']];
    const order = Number(r[idx['FormOrder']]) || 999;
    const id = r[idx['FormID']];
    return { r, i, key: [shapeSortKey(shape), order, id] };
  });
  withKeys.sort((a, b) => {
    for (let i = 0; i < a.key.length; i++) {
      if (a.key[i] < b.key[i]) return -1;
      if (a.key[i] > b.key[i]) return 1;
    }
    return a.i - b.i; // stable by original index
  });
  // Renumber FormOrder as 1..N
  withKeys.forEach((wk, idxOrder) => {
    wk.r[idx['FormOrder']] = String(idxOrder + 1);
  });
  return withKeys.map(wk => wk.r);
}

function validateChordTones(rows, idx) {
  const issues = [];
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    const quality = row[idx['Quality']];
    if (!(quality in QUALITY_INTERVALS)) continue; // only validate supported qualities
    const symbol = row[idx['Symbol']] || row[idx['Chord']];
    const rootPc = parseRoot(symbol);
    if (rootPc == null) {
      issues.push({ line: i + 2, type: 'root_parse_error', symbol });
      continue;
    }
    const expected = getExpectedPcs(rootPc, quality);
    if (!expected) continue;
    const pcs = collectChordPcs(row, idx);
    // Missing required tones
    const missing = [...expected].filter(pc => !pcs.has(pc));
    // Foreign tones (not expected)
    const foreign = [...pcs].filter(pc => !expected.has(pc));
    if (missing.length > 0 || foreign.length > 0) {
      issues.push({
        line: i + 2, // +1 header, +1 1-based
        chord: row[idx['Chord']],
        symbol,
        quality,
        shape: row[idx['ShapeName']],
        formId: row[idx['FormID']],
        type: 'tone_mismatch',
        missing,
        foreign,
      });
    }
  }
  return issues;
}

function validateShapes(rows, idx) {
  const issues = [];
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    const shape = (row[idx['ShapeName']] || '').trim();
    if (!SHAPE_ORDER.includes(shape)) {
      issues.push({
        line: i + 2,
        chord: row[idx['Chord']],
        symbol: row[idx['Symbol']],
        formId: row[idx['FormID']],
        shape,
        type: 'unknown_shape',
      });
    }
  }
  return issues;
}

function isOpenPlus12(openFrets, rootFrets) {
  // openFrets/rootFrets: array of 6 values (string1..6), 'x' or number
  for (let s = 0; s < 6; s++) {
    const o = openFrets[s];
    const r = rootFrets[s];
    if (o === 'x' && r === 'x') continue;
    if (o === 'x' || r === 'x') return false;
    const on = Number(o); const rn = Number(r);
    if (!Number.isFinite(on) || !Number.isFinite(rn)) return false;
    const expected = on === 0 ? 12 : on + 12;
    if (rn !== expected) return false;
  }
  return true;
}

function parseFretRow(row, idx) {
  const vals = [];
  for (let s = 1; s <= 6; s++) {
    const v = (row[idx[`Fret${s}`]] ?? '').trim().toLowerCase();
    vals.push(v === 'x' ? 'x' : Number(v));
  }
  return vals;
}

function detectOpenPlus12Duplicates(rows, idx) {
  // rows for a single chord (already grouped) expected
  const open = rows.find(r => r[idx['ShapeName']] === 'Open');
  if (!open) return [];
  const openFrets = parseFretRow(open, idx);
  const issues = [];
  for (const r of rows) {
    const shape = r[idx['ShapeName']];
    if (shape !== 'Root-6' && shape !== 'Root-5') continue;
    const frets = parseFretRow(r, idx);
    if (isOpenPlus12(openFrets, frets)) {
      const suggestedShell = shape === 'Root-6' ? ['x',12,13,13,'x',12] : ['x', 'x', 9, 9, 'x', 7];
      issues.push({
        formId: r[idx['FormID']],
        shape,
        type: 'duplicate_open_plus_12',
        suggestedShell,
      });
    }
  }
  return issues;
}

function run() {
  const { input, write } = parseArgs(process.argv);
  const csvText = fs.readFileSync(input, 'utf8');
  const rows = parseCSV(csvText);
  if (rows.length === 0) throw new Error('CSV is empty');
  const header = rows[0];
  const idx = indexHeader(header);
  const body = rows.slice(1).filter(r => r.length && r.some(c => (c ?? '').trim() !== ''));

  // Group by chord, reorder per group
  const byChord = groupByChord(body, idx);
  const reorderedBody = [];
  let groupsWithChanges = 0;
  for (const [chord, groupRows] of byChord.entries()) {
    const before = groupRows.map(r => r[idx['FormID']]);
    const afterRows = reorderFormsPerChord(groupRows.slice(), idx);
    const after = afterRows.map(r => r[idx['FormID']]);
    reorderedBody.push(...afterRows);
    if (JSON.stringify(before) !== JSON.stringify(after)) groupsWithChanges++;
  }

  // Validate shape names and chord tones
  const shapeIssues = validateShapes(reorderedBody, idx);
  const toneIssues = validateChordTones(reorderedBody, idx);

  // Duplicate Open+12 detection
  let duplicateIssues = [];
  for (const [chord, groupRows] of byChord.entries()) {
    const det = detectOpenPlus12Duplicates(groupRows, idx);
    duplicateIssues.push(...det.map(o => ({ chord, ...o })));
  }

  // Compose report
  const report = {
    input,
    timestamp: new Date().toISOString(),
    totals: {
      rows: body.length,
      chords: byChord.size,
      groupsWithReorder: groupsWithChanges,
      shapeIssueCount: shapeIssues.length,
      toneIssueCount: toneIssues.length,
      duplicates: duplicateIssues.length,
    },
    issues: [...shapeIssues, ...toneIssues, ...duplicateIssues],
  };

  const reportPath = input + '.report.json';
  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2), 'utf8');

  // Optionally write reordered CSV (non-destructive)
  if (write) {
    const outPath = input.replace(/\.csv$/i, '.reordered.csv');
    const outRows = [header, ...reorderedBody];
    fs.writeFileSync(outPath, toCSV(outRows), 'utf8');
  }

  // Console summary
  console.log(`Validated: ${input}`);
  console.log(`- Total rows: ${report.totals.rows}`);
  console.log(`- Total chords: ${report.totals.chords}`);
  console.log(`- Groups requiring reorder: ${report.totals.groupsWithReorder}`);
  console.log(`- Shape issues: ${report.totals.shapeIssueCount}`);
  console.log(`- Tone issues: ${report.totals.toneIssueCount}`);
  console.log(`Report: ${reportPath}`);
}

run();


