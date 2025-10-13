//
//  DiatonicChord.swift
//  OtoTheory
//
//  Phase E-2: Data model for Diatonic Table
//

import Foundation

/// Represents a diatonic chord with Roman numeral and quality
struct DiatonicChord: Identifiable {
    let id = UUID()
    let degree: Int              // 1-7 (I-VII)
    let romanNumeral: String     // "I", "ii", "iii", "IV", "V", "vi", "vii°"
    let chordName: String        // "C", "Dm", "Em", "F", "G", "Am", "Bdim"
    let quality: ChordQuality    // Major, Minor, Diminished
    
    enum ChordQuality {
        case major
        case minor
        case diminished
        case augmented
        
        var symbol: String {
            switch self {
            case .major: return ""
            case .minor: return "m"
            case .diminished: return "dim"
            case .augmented: return "aug"
            }
        }
        
        var color: String {
            switch self {
            case .major: return "blue"
            case .minor: return "purple"
            case .diminished: return "gray"
            case .augmented: return "orange"
            }
        }
    }
}

/// Capo suggestion for a specific capo position
struct CapoSuggestion: Identifiable {
    let id = UUID()
    let capoFret: Int            // Capo position (1-7)
    let shapedChord: String      // What you finger (e.g., "C" for Capo 2 = D)
    let soundingChord: String    // What it actually sounds like (e.g., "D")
}

