#!/usr/bin/env node

import fs from 'fs';
import path from 'path';

const CSV_PATH = '/Users/nh/App/OtoTheory/docs/content/Chord Library Mastar.csv';
const OUTPUT_PATH = '/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Services/StaticChordProvider.swift';

// Read CSV
const csvContent = fs.readFileSync(CSV_PATH, 'utf8');
const lines = csvContent.split('\n').filter(line => line.trim());

// Parse CSV header
const header = lines[0].split(',');
const chordIndex = header.indexOf('Chord');
const symbolIndex = header.indexOf('Symbol');
const qualityIndex = header.indexOf('Quality');
const formOrderIndex = header.indexOf('FormOrder');
const formIdIndex = header.indexOf('FormID');
const shapeNameIndex = header.indexOf('ShapeName');
const fret1Index = header.indexOf('Fret1');
const fret2Index = header.indexOf('Fret2');
const fret3Index = header.indexOf('Fret3');
const fret4Index = header.indexOf('Fret4');
const fret5Index = header.indexOf('Fret5');
const fret6Index = header.indexOf('Fret6');
const finger1Index = header.indexOf('Finger1');
const finger2Index = header.indexOf('Finger2');
const finger3Index = header.indexOf('Finger3');
const finger4Index = header.indexOf('Finger4');
const finger5Index = header.indexOf('Finger5');
const finger6Index = header.indexOf('Finger6');
const barreFretIndex = header.indexOf('BarreFret');
const barreFromIndex = header.indexOf('BarreFrom');
const barreToIndex = header.indexOf('BarreTo');
const tipsIndex = header.indexOf('Tips');

// Group chords by symbol
const chordGroups = new Map();

for (let i = 1; i < lines.length; i++) {
  const line = lines[i];
  if (!line.trim()) continue;
  
  const fields = line.split(',');
  if (fields.length < 20) continue;
  
  const chord = fields[chordIndex]?.trim();
  const symbol = fields[symbolIndex]?.trim();
  const quality = fields[qualityIndex]?.trim();
  const formOrder = fields[formOrderIndex]?.trim();
  const formId = fields[formIdIndex]?.trim();
  const shapeName = fields[shapeNameIndex]?.trim();
  
  if (!chord || !symbol || !quality) continue;
  
  // Parse frets (1st to 6th string)
  const frets = [
    fields[fret1Index]?.trim() || 'x',
    fields[fret2Index]?.trim() || 'x',
    fields[fret3Index]?.trim() || 'x',
    fields[fret4Index]?.trim() || 'x',
    fields[fret5Index]?.trim() || 'x',
    fields[fret6Index]?.trim() || 'x'
  ];
  
  // Parse fingers (1st to 6th string)
  const fingers = [
    fields[finger1Index]?.trim() || '-',
    fields[finger2Index]?.trim() || '-',
    fields[finger3Index]?.trim() || '-',
    fields[finger4Index]?.trim() || '-',
    fields[finger5Index]?.trim() || '-',
    fields[finger6Index]?.trim() || '-'
  ];
  
  // Parse barre info
  const barreFret = fields[barreFretIndex]?.trim();
  const barreFrom = fields[barreFromIndex]?.trim();
  const barreTo = fields[barreToIndex]?.trim();
  
  // Parse tips
  const tips = fields[tipsIndex]?.trim() || '';
  
  if (!chordGroups.has(symbol)) {
    chordGroups.set(symbol, {
      symbol,
      quality,
      forms: []
    });
  }
  
  const form = {
    formOrder: parseInt(formOrder) || 0,
    formId,
    shapeName,
    frets,
    fingers,
    barreFret,
    barreFrom,
    barreTo,
    tips
  };
  
  chordGroups.get(symbol).forms.push(form);
}

// Convert to iOS Swift format
function convertFretToSwift(fret) {
  if (fret === 'x' || fret === '') return '.x';
  if (fret === '0') return '.open';
  return `.fret(${parseInt(fret)})`;
}

function convertFingerToSwift(finger) {
  if (finger === '-' || finger === '' || !finger) return 'nil';
  const fingerNum = parseInt(finger);
  if (fingerNum >= 1 && fingerNum <= 4) {
    return `.${['', 'one', 'two', 'three', 'four'][fingerNum]}`;
  }
  return 'nil';
}

function generateBarreSwift(barreFret, barreFrom, barreTo, finger) {
  if (!barreFret || !barreFrom || !barreTo) return '';
  
  const fingerStr = convertFingerToSwift(finger);
  if (fingerStr === 'nil') return '';
  return `StaticBarre(fret: ${barreFret}, fromString: ${barreFrom}, toString: ${barreTo}, finger: ${fingerStr})`;
}

// Generate Swift code
let swiftCode = `//
//  StaticChordProvider.swift
//  OtoTheory
//
//  Static Chord Data Provider (v1)
//  Source: docs/content/Chord Library Mastar.csv
//  Generated from master CSV data
//

import Foundation

@MainActor
class StaticChordProvider: ObservableObject {
    static let shared = StaticChordProvider()
    
    private init() {}
    
    /// All static chords from master CSV
    let chords: [StaticChord] = STATIC_CHORDS
    
    /// Get chord by symbol
    func getChord(symbol: String) -> StaticChord? {
        return chords.first { $0.symbol == symbol }
    }
    
    /// Get all symbols
    var allSymbols: [String] {
        return chords.map { $0.symbol }
    }
    
    /// Find chord by root and quality
    func findChord(root: String, quality: String) -> StaticChord? {
        // Quality mapping: ChordLibraryQuality rawValue -> Static data quality
        let qualityMap: [String: String] = [
            "": "M",           // Empty string = Major
            "M": "M",          // Major
            "maj7": "M7",      // Major 7th
            "m": "m",          // minor
            "m7": "m7",        // minor 7th
            "7": "7",          // Dominant 7th
            "dim": "dim",      // Diminished
            "dim7": "dim7",    // Diminished 7th
            "m7b5": "m7-5",    // Half-diminished
            "sus4": "sus4",    // Suspended 4th
            "sus2": "sus2",    // Suspended 2nd
            "add9": "add9",    // Add 9th
            "6": "6",          // Sixth
            "m6": "m6",        // Minor 6th
            "aug": "aug",      // Augmented
            "m9": "m9"         // Minor 9th
        ]
        
        // Map quality to static data format
        let mappedQuality = qualityMap[quality] ?? quality
        
        // Build symbol (e.g., "C" + "M7" = "CM7", "C#" + "" = "C#")
        var symbol: String
        
        // Handle major chord (empty or "M" quality)
        if mappedQuality.isEmpty || mappedQuality == "M" {
            // Just use root (e.g., "C", "C#")
            symbol = root
        } else {
            // For sharps/flats, append quality (e.g., "C#" + "m" = "C#m")
            symbol = root + mappedQuality
        }
        
        // Find chord with matching symbol
        return chords.first(where: { $0.symbol == symbol })
    }
    
    /// Get all available qualities for a given root
    func getQualities(for root: String) -> [String] {
        var qualities: Set<String> = []
        
        for chord in chords {
            // Check if chord symbol starts with root
            if chord.symbol == root {
                // Major chord (no suffix)
                qualities.insert("M")
            } else if chord.symbol.hasPrefix(root) {
                // Extract quality part
                let qualityPart = String(chord.symbol.dropFirst(root.count))
                qualities.insert(qualityPart)
            }
        }
        
        return Array(qualities).sorted()
    }
}

// MARK: - Static Chord Data (from CSV)

/// All chord forms from Chord Library Mastar.csv
let STATIC_CHORDS: [StaticChord] = [
`;

// Sort chords by symbol
const sortedChords = Array.from(chordGroups.values()).sort((a, b) => a.symbol.localeCompare(b.symbol));

for (const chord of sortedChords) {
  // Sort forms by formOrder
  chord.forms.sort((a, b) => a.formOrder - b.formOrder);
  
  swiftCode += `\n    // MARK: - ${chord.symbol} (${chord.quality})\n`;
  swiftCode += `    StaticChord(\n`;
  swiftCode += `        id: "${chord.symbol}",\n`;
  swiftCode += `        symbol: "${chord.symbol}",\n`;
  swiftCode += `        quality: "${chord.quality}",\n`;
  swiftCode += `        forms: [\n`;
  
  for (const form of chord.forms) {
    swiftCode += `            StaticForm(\n`;
    swiftCode += `                id: "${form.formId}",\n`;
    swiftCode += `                shapeName: ${form.shapeName ? `"${form.shapeName}"` : 'nil'},\n`;
    swiftCode += `                frets: [${form.frets.map(convertFretToSwift).join(', ')}],\n`;
    swiftCode += `                fingers: [${form.fingers.map(convertFingerToSwift).join(', ')}],\n`;
    
    // Generate barres
    const barres = [];
    if (form.barreFret && form.barreFrom && form.barreTo) {
      const barreFinger = form.fingers[parseInt(form.barreFrom) - 1];
      barres.push(generateBarreSwift(form.barreFret, form.barreFrom, form.barreTo, barreFinger));
    }
    
    if (barres.length > 0) {
      swiftCode += `                barres: [${barres.join(', ')}],\n`;
    } else {
      swiftCode += `                barres: [],\n`;
    }
    
    // Escape quotes in tips
    const escapedTips = form.tips ? form.tips.replace(/"/g, '\\"') : '';
    swiftCode += `                tips: [${escapedTips ? `"${escapedTips}"` : ''}]\n`;
    swiftCode += `            )`;
    
    if (form !== chord.forms[chord.forms.length - 1]) {
      swiftCode += ',';
    }
    swiftCode += '\n';
  }
  
  swiftCode += `        ]\n`;
  swiftCode += `    )`;
  
  if (chord !== sortedChords[sortedChords.length - 1]) {
    swiftCode += ',';
  }
  swiftCode += '\n';
}

swiftCode += `\n];\n`;

// Write to file
fs.writeFileSync(OUTPUT_PATH, swiftCode);
console.log(`Generated iOS StaticChordProvider.swift with ${sortedChords.length} chords`);
