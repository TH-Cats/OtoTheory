//
//  StaticChord.swift
//  OtoTheory
//
//  Static Chord Library Data Model (v0)
//  Source: docs/content/GuitarChordList-1.pdf
//

import Foundation

// MARK: - Fret Value

enum FretVal: Equatable, Codable {
    case x          // muted
    case open       // 0
    case fret(Int)  // 1-15
    
    var displayValue: String {
        switch self {
        case .x: return "x"
        case .open: return "0"
        case .fret(let n): return "\(n)"
        }
    }
    
    var midiOffset: Int? {
        switch self {
        case .x: return nil
        case .open: return 0
        case .fret(let n): return n
        }
    }
}

// MARK: - Finger Number

enum FingerNum: Int, Codable {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    
    var displayValue: String { "\(rawValue)" }
}

// MARK: - Static Barre

struct StaticBarre: Equatable, Codable {
    let fret: Int
    let fromString: Int  // 1-6 (1=high E, 6=low E)
    let toString: Int
    let finger: FingerNum
}

// MARK: - Static Form

struct StaticForm: Identifiable, Equatable, Codable {
    let id: String              // "{symbol}-{index}" e.g. "Csus4-1"
    var shapeName: String?      // Reserved for future (currently nil)
    let frets: [FretVal]        // 1→6 strings (high E → low E)
    let fingers: [FingerNum?]   // 1→6 strings
    let barres: [StaticBarre]
    let tips: [String]          // Tips in English (iOS is EN only for now)
    let source: String          // "attached-chart-v1"
    
    init(
        id: String,
        shapeName: String? = nil,
        frets: [FretVal],
        fingers: [FingerNum?],
        barres: [StaticBarre] = [],
        tips: [String] = [],
        source: String = "attached-chart-v1"
    ) {
        self.id = id
        self.shapeName = shapeName
        self.frets = frets
        self.fingers = fingers
        self.barres = barres
        self.tips = tips
        self.source = source
    }
    
    /// Convert to MIDI notes using 1→6 order
    func toMIDINotes(rootSemitone: Int) -> [UInt8] {
        // Open strings (1st to 6th): E4, B3, G3, D3, A2, E2
        let openStrings = [64, 59, 55, 50, 45, 40]
        var notes: [UInt8] = []
        
        for (index, fretVal) in frets.enumerated() {
            guard let offset = fretVal.midiOffset else { continue }
            let midiNote = openStrings[index] + offset
            notes.append(UInt8(midiNote))
        }
        
        return notes.sorted()
    }
}

// MARK: - Static Chord

struct StaticChord: Identifiable, Equatable, Codable {
    let id: String           // = symbol
    let symbol: String       // e.g. "Csus4", "B7", "Cm7-5", "Cdim7"
    let quality: String      // e.g. "sus4", "7", "m7-5", "dim7"
    let forms: [StaticForm]  // Forms from attached chart
    
    init(id: String, symbol: String, quality: String, forms: [StaticForm]) {
        self.id = id
        self.symbol = symbol
        self.quality = quality
        self.forms = forms
    }
}

// MARK: - Helper Function

/// Convenience function for creating fret values
func F(_ n: Int) -> FretVal { .fret(n) }

