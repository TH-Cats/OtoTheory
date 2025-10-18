//
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

    // MARK: - A (M)
    StaticChord(
        id: "A",
        symbol: "A",
        quality: "M",
        forms: [
            StaticForm(
                id: "A-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(3), .fret(3), .fret(3), .open, .open],
                fingers: [nil, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["\"A major open | Powerful sound\""]
            ),
            StaticForm(
                id: "A-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(5), .fret(5), .fret(6), .fret(7), .fret(7), .fret(5)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "A-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(9), .fret(10), .fret(11), .fret(12), .x],
                fingers: [nil, .one, .two, .three, .four, nil],
                barres: [],
                tips: ["\"A major root-5 | Barre at 9th fret\""]
            ),
            StaticForm(
                id: "A-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(5), .fret(5), .fret(6), .fret(7), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "A-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(12), .fret(14), .fret(14), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "A-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(5), .fret(6), .fret(7), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - A# (M)
    StaticChord(
        id: "A#",
        symbol: "A#",
        quality: "M",
        forms: [
            StaticForm(
                id: "A#-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(6), .fret(6), .fret(7), .fret(8), .fret(8), .fret(6)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "A#-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(1), .fret(3), .fret(3), .fret(3), .fret(1), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "A#-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(6), .fret(6), .fret(7), .fret(8), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "A#-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(1), .fret(3), .fret(3), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "A#-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(6), .fret(7), .fret(8), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - A#add9 (add9)
    StaticChord(
        id: "A#add9",
        symbol: "A#add9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "A#add9-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(5), .fret(3), .fret(5), .fret(6)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"A# add9 root-6 (x-x-5-3-5-6)\""]
            ),
            StaticForm(
                id: "A#add9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(13), .fret(10), .fret(12), .fret(13), .x],
                fingers: [nil, .four, .one, .two, .three, nil],
                barres: [StaticBarre(fret: 10, fromString: 2, toString: 5, finger: .four)],
                tips: ["\"A# add9 root-5 (x-13-10-12-13-x) barre@10(2-5)\""]
            ),
            StaticForm(
                id: "A#add9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(8), .fret(6), .fret(7), .fret(8), .x, .x],
                fingers: [.four, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"A# add9 root-4 (8-6-7-8-x-x)\""]
            )
        ]
    ),

    // MARK: - A#aug (aug)
    StaticChord(
        id: "A#aug",
        symbol: "A#aug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "A#aug-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(19), .fret(19), .fret(20), .x, .fret(18)],
                fingers: [nil, .three, .two, .four, nil, .one],
                barres: [],
                tips: ["\"A# augmented root-6 (x-19-19-20-x-18)\""]
            ),
            StaticForm(
                id: "A#aug-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(13), .fret(12), .fret(11), .fret(11), .x],
                fingers: [nil, .three, .two, .one, .one, nil],
                barres: [StaticBarre(fret: 11, fromString: 2, toString: 3, finger: .three)],
                tips: ["\"A# augmented root-5 (x-13-12-11-11-x) barre@11(2-3)\""]
            ),
            StaticForm(
                id: "A#aug-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(18), .fret(19), .fret(19), .fret(20), .x, .x],
                fingers: [.one, .two, .three, .four, nil, nil],
                barres: [],
                tips: ["\"A# augmented root-4 (18-19-19-20-x-x)\""]
            ),
            StaticForm(
                id: "A#aug-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(14), .fret(15), .fret(15), .x, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"A# augmented Triad-1 (14-15-15-x-x-x)\""]
            ),
            StaticForm(
                id: "A#aug-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(19), .fret(19), .fret(20), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 19, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"A# augmented Triad-2 (x-19-19-20-x-x) barre@19(2-3)\""]
            )
        ]
    ),

    // MARK: - A#dim (dim)
    StaticChord(
        id: "A#dim",
        symbol: "A#dim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "A#dim-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(18), .fret(17), .fret(18), .x, .x, .fret(18)],
                fingers: [.four, .one, .three, nil, nil, .two],
                barres: [],
                tips: ["Diminished (auto from Cdim +10)"]
            ),
            StaticForm(
                id: "A#dim-2",
                shapeName: "Root-5",
                frets: [.x, .fret(14), .fret(15), .fret(14), .fret(13), .x],
                fingers: [nil, .three, .four, .two, .one, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +10)"]
            ),
            StaticForm(
                id: "A#dim-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(18), .fret(17), .fret(18), .fret(20), .x, .x],
                fingers: [.three, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +10)"]
            ),
            StaticForm(
                id: "A#dim-4-Triad-1",
                shapeName: "Triad-1",
                frets: [.fret(12), .fret(14), .fret(15), .x, .x, .x],
                fingers: [.one, .three, .four, nil, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +10)"]
            ),
            StaticForm(
                id: "A#dim-5-Triad-2",
                shapeName: "Triad-2",
                frets: [.x, .fret(17), .fret(18), .fret(20), .x, .x],
                fingers: [nil, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +10)"]
            )
        ]
    ),

    // MARK: - A#m (m)
    StaticChord(
        id: "A#m",
        symbol: "A#m",
        quality: "m",
        forms: [
            StaticForm(
                id: "A#m-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(6), .fret(6), .fret(6), .fret(8), .fret(8), .fret(6)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "A#m-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(1), .fret(2), .fret(3), .fret(3), .fret(1)],
                fingers: [nil, nil, .one, .two, .four, .three],
                barres: [],
                tips: ["1"]
            ),
            StaticForm(
                id: "A#m-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(6), .fret(6), .fret(6), .fret(8), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "A#m-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(1), .fret(2), .fret(3), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "A#m-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(6), .fret(6), .fret(8), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - A#sus4 (sus4)
    StaticChord(
        id: "A#sus4",
        symbol: "A#sus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "A#sus4-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(13), .fret(15), .fret(15), .fret(15), .fret(13), .fret(13)],
                fingers: [.one, .three, .four, .four, .one, .two],
                barres: [StaticBarre(fret: 13, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"A# sus4 root-6 (13-15-15-15-13-13)\""]
            ),
            StaticForm(
                id: "A#sus4-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(18), .fret(20), .fret(20), .fret(20), .fret(18), .x],
                fingers: [.one, .three, .four, .four, .one, nil],
                barres: [StaticBarre(fret: 18, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"A# sus4 root-5 (18-20-20-20-18-x)\""]
            ),
            StaticForm(
                id: "A#sus4-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(18), .fret(18), .fret(20), .fret(20), .x, .x],
                fingers: [.one, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"A# sus4 root-4 (18-18-20-20-x-x)\""]
            ),
            StaticForm(
                id: "A#sus4-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(13), .fret(16), .fret(15), .x, .x, .x],
                fingers: [.one, .four, .three, nil, nil, nil],
                barres: [],
                tips: ["A#sus4 Triad-1 (auto from Csus4 +10)"]
            ),
            StaticForm(
                id: "A#sus4-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(18), .fret(20), .fret(20), .x, .x],
                fingers: [nil, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["A#sus4 Triad-2 (auto from Csus4 +10)"]
            )
        ]
    ),

    // MARK: - A6 (6)
    StaticChord(
        id: "A6",
        symbol: "A6",
        quality: "6",
        forms: [
            StaticForm(
                id: "A6-1-Open",
                shapeName: "Open",
                frets: [.fret(3), .fret(3), .fret(3), .fret(3), .open, .open],
                fingers: [.one, .one, .one, .one, nil, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 4, finger: .one)],
                tips: ["\"A 6 open (x-0-2-2-2-2) barre@2(1-4)\""]
            ),
            StaticForm(
                id: "A6-1-Open",
                shapeName: "Open",
                frets: [.fret(3), .fret(3), .fret(3), .fret(3), .open, .open],
                fingers: [.one, .one, .one, .one, nil, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 4, finger: .one)],
                tips: ["\"A 6 open (x-0-2-2-2-2) barre@2(1-4)\""]
            ),
            StaticForm(
                id: "A6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(7), .fret(6), .fret(7), .x, .fret(5)],
                fingers: [nil, .four, .two, .three, nil, .one],
                barres: [],
                tips: ["\"A 6 root-6 (x-7-6-7-x-5)\""]
            ),
            StaticForm(
                id: "A6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(7), .fret(6), .fret(7), .x, .fret(5)],
                fingers: [nil, .four, .two, .three, nil, .one],
                barres: [],
                tips: ["\"A 6 root-6 (x-7-6-7-x-5)\""]
            )
        ]
    ),

    // MARK: - A7 (7)
    StaticChord(
        id: "A7",
        symbol: "A7",
        quality: "7",
        forms: [
            StaticForm(
                id: "A7-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(3), .open, .fret(3), .open, .open],
                fingers: [nil, .three, nil, .two, nil, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "A7-2-Root-6",
                shapeName: "Root-6",
                frets: [.fret(5), .fret(5), .fret(6), .fret(5), .fret(7), .fret(5)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "A7-3-Root-5",
                shapeName: "Root-5",
                frets: [.x, .fret(10), .fret(12), .fret(11), .fret(12), .x],
                fingers: [nil, .one, .three, .two, .four, nil],
                barres: [],
                tips: ["\"Compact A7 (x-10-12-11-12-x)\""]
            ),
            StaticForm(
                id: "A7-4-Root-4",
                shapeName: "Root-4",
                frets: [.fret(9), .fret(8), .fret(9), .fret(7), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            )
        ]
    ),

    // MARK: - Aadd9 (add9)
    StaticChord(
        id: "Aadd9",
        symbol: "Aadd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Aadd9-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(3), .fret(5), .fret(3), .open, .open],
                fingers: [nil, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["\"A add9 open (0-2-4-2-0-x)\""]
            ),
            StaticForm(
                id: "Aadd9-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(4), .fret(2), .fret(4), .fret(5)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"A add9 root-6 (x-x-4-2-4-5)\""]
            ),
            StaticForm(
                id: "Aadd9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(12), .fret(9), .fret(11), .fret(12), .x],
                fingers: [nil, .four, .one, .two, .three, nil],
                barres: [StaticBarre(fret: 9, fromString: 2, toString: 5, finger: .four)],
                tips: ["\"A add9 root-5 (x-12-9-11-12-x) barre@9(2-5)\""]
            ),
            StaticForm(
                id: "Aadd9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(7), .fret(5), .fret(6), .fret(7), .x, .x],
                fingers: [.four, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"A add9 root-4 (7-5-6-7-x-x)\""]
            )
        ]
    ),

    // MARK: - Aaug (aug)
    StaticChord(
        id: "Aaug",
        symbol: "Aaug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "Aaug-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(18), .fret(18), .fret(19), .x, .fret(17)],
                fingers: [nil, .three, .two, .four, nil, .one],
                barres: [],
                tips: ["\"A augmented root-6 (x-18-18-19-x-17)\""]
            ),
            StaticForm(
                id: "Aaug-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(12), .fret(11), .fret(10), .fret(10), .x],
                fingers: [nil, .three, .two, .one, .one, nil],
                barres: [StaticBarre(fret: 10, fromString: 2, toString: 3, finger: .three)],
                tips: ["\"A augmented root-5 (x-12-11-10-10-x) barre@10(2-3)\""]
            ),
            StaticForm(
                id: "Aaug-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(17), .fret(18), .fret(18), .fret(19), .x, .x],
                fingers: [.one, .two, .three, .four, nil, nil],
                barres: [],
                tips: ["\"A augmented root-4 (17-18-18-19-x-x)\""]
            ),
            StaticForm(
                id: "Aaug-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(13), .fret(14), .fret(14), .x, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"A augmented Triad-1 (13-14-14-x-x-x)\""]
            ),
            StaticForm(
                id: "Aaug-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(18), .fret(18), .fret(19), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 18, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"A augmented Triad-2 (x-18-18-19-x-x) barre@18(2-3)\""]
            )
        ]
    ),

    // MARK: - Adim (dim)
    StaticChord(
        id: "Adim",
        symbol: "Adim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "Adim-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(17), .fret(16), .fret(17), .x, .x, .fret(17)],
                fingers: [.four, .one, .three, nil, nil, .two],
                barres: [],
                tips: ["Diminished (auto from Cdim +9)"]
            ),
            StaticForm(
                id: "Adim-2",
                shapeName: "Root-5",
                frets: [.x, .fret(13), .fret(14), .fret(13), .fret(12), .x],
                fingers: [nil, .three, .four, .two, .one, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +9)"]
            ),
            StaticForm(
                id: "Adim-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(17), .fret(16), .fret(17), .fret(19), .x, .x],
                fingers: [.three, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +9)"]
            ),
            StaticForm(
                id: "Adim-4-Triad-1",
                shapeName: "Triad-1",
                frets: [.fret(11), .fret(13), .fret(14), .x, .x, .x],
                fingers: [.one, .three, .four, nil, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +9)"]
            ),
            StaticForm(
                id: "Adim-5-Triad-2",
                shapeName: "Triad-2",
                frets: [.x, .fret(16), .fret(17), .fret(19), .x, .x],
                fingers: [nil, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +9)"]
            )
        ]
    ),

    // MARK: - Am (m)
    StaticChord(
        id: "Am",
        symbol: "Am",
        quality: "m",
        forms: [
            StaticForm(
                id: "Am-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(2), .fret(3), .fret(3), .open, .open],
                fingers: [nil, .one, .three, .two, nil, nil],
                barres: [],
                tips: ["\"A minor open | Melancholic\""]
            ),
            StaticForm(
                id: "Am-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(5), .fret(5), .fret(5), .fret(7), .fret(7), .fret(5)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "Am-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(9), .fret(10), .fret(10), .fret(12), .x],
                fingers: [nil, .one, .two, .three, .four, nil],
                barres: [],
                tips: ["\"A minor root-5 | Barre at 9th fret\""]
            ),
            StaticForm(
                id: "Am-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(5), .fret(5), .fret(5), .fret(7), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "Am-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(12), .fret(13), .fret(14), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "Am-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(5), .fret(5), .fret(7), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - Am6 (m6)
    StaticChord(
        id: "Am6",
        symbol: "Am6",
        quality: "m6",
        forms: [
            StaticForm(
                id: "Am6-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(2), .fret(3), .fret(3), .open, .open],
                fingers: [nil, .one, .three, .two, nil, nil],
                barres: [],
                tips: ["\"A minor 6 open (x-0-2-2-1-0)\""]
            ),
            StaticForm(
                id: "Am6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(7), .fret(7), .fret(6), .x, .fret(7)],
                fingers: [nil, .three, .four, .one, nil, .two],
                barres: [],
                tips: ["\"A minor 6 root-6 (x-7-7-6-x-7)\""]
            ),
            StaticForm(
                id: "Am6-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(10), .fret(11), .fret(10), .fret(12), .x],
                fingers: [nil, .one, .three, .two, .four, nil],
                barres: [],
                tips: ["\"A minor 6 root-5 (x-12-10-11-10-x)\""]
            ),
            StaticForm(
                id: "Am6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(5), .fret(7), .fret(5), .fret(7), .x, .x],
                fingers: [.one, .four, .two, .three, nil, nil],
                barres: [],
                tips: ["\"A minor 6 root-4 (5-7-5-7-x-x)\""]
            )
        ]
    ),

    // MARK: - Am7 (m7)
    StaticChord(
        id: "Am7",
        symbol: "Am7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "Am7-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(2), .open, .fret(3), .open, .open],
                fingers: [nil, .one, nil, .two, nil, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "Am7-2-Root-6",
                shapeName: "Root-6",
                frets: [.fret(5), .fret(5), .fret(5), .fret(5), .fret(7), .fret(5)],
                fingers: [.one, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "Am7-3-Root-5",
                shapeName: "Root-5",
                frets: [.x, .fret(10), .fret(12), .fret(12), .fret(10), .x],
                fingers: [nil, .one, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 10, fromString: 2, toString: 5, finger: .one)],
                tips: ["\"A minor 7 (x-10-12-12-10-x)\""]
            ),
            StaticForm(
                id: "Am7-4-Root-4",
                shapeName: "Root-4",
                frets: [.fret(8), .fret(8), .fret(9), .fret(7), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            )
        ]
    ),

    // MARK: - AM7 (M7)
    StaticChord(
        id: "AM7",
        symbol: "AM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "AM7-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(3), .fret(2), .fret(3), .open, .open],
                fingers: [nil, .three, .one, .two, nil, nil],
                barres: [],
                tips: ["\"Amaj7 open | Mellow sound\""]
            ),
            StaticForm(
                id: "AM7-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(5), .fret(5), .fret(6), .fret(6), .fret(7), .fret(5)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | Maj7 E-shape\""]
            ),
            StaticForm(
                id: "AM7-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(9), .fret(9), .fret(9), .fret(11), .fret(12), .x],
                fingers: [.one, .one, .one, .three, .four, nil],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 3, finger: .one)],
                tips: ["\"5th string root | Maj7 (barre 1–3 @ 9f)\""]
            ),
            StaticForm(
                id: "AM7-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(9), .fret(9), .fret(9), .fret(7), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            )
        ]
    ),

    // MARK: - Am9 (m9)
    StaticChord(
        id: "Am9",
        symbol: "Am9",
        quality: "m9",
        forms: [
            StaticForm(
                id: "Am9-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(7), .fret(5), .fret(5), .fret(5), .fret(7), .fret(5)],
                fingers: [.four, .one, .one, .one, .three, .one],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 6, finger: .four)],
                tips: ["\"A minor 9 root-6 (7-5-5-5-7-5) barre@5(1-6)\""]
            ),
            StaticForm(
                id: "Am9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(12), .fret(12), .fret(10), .fret(12), .x],
                fingers: [nil, .one, .one, .three, .four, nil],
                barres: [StaticBarre(fret: 12, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"A minor 9 root-5 (x-12-12-10-12-x) barre@12(2-3)\""]
            ),
            StaticForm(
                id: "Am9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(7), .fret(8), .fret(7), .fret(5), .x, .x],
                fingers: [.three, .four, .two, .one, nil, nil],
                barres: [],
                tips: ["\"A minor 9 root-4 (7-8-7-5-x-x)\""]
            )
        ]
    ),

    // MARK: - Asus2 (sus2)
    StaticChord(
        id: "Asus2",
        symbol: "Asus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Asus2-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(3), .fret(3), .open, .open],
                fingers: [nil, nil, .one, .two, nil, nil],
                barres: [],
                tips: ["\"A sus2 open (x-0-2-2-0-0)\""]
            )
        ]
    ),

    // MARK: - Asus4 (sus4)
    StaticChord(
        id: "Asus4",
        symbol: "Asus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Asus4-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(4), .fret(3), .fret(3), .open, .open],
                fingers: [nil, .three, .two, .one, nil, nil],
                barres: [],
                tips: ["\"A sus4 open (x-0-2-2-3-0)\""]
            ),
            StaticForm(
                id: "Asus4-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(4), .fret(3), .fret(3), .open, .open],
                fingers: [nil, .three, .two, .one, nil, nil],
                barres: [],
                tips: ["\"A sus4 open (x-0-2-2-3-0)\""]
            ),
            StaticForm(
                id: "Asus4-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(12), .fret(14), .fret(14), .fret(14), .fret(12), .fret(12)],
                fingers: [.one, .three, .four, .four, .one, .two],
                barres: [StaticBarre(fret: 12, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"A sus4 root-6 (12-14-14-14-12-12)\""]
            ),
            StaticForm(
                id: "Asus4-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(10), .fret(9), .fret(12), .fret(12), .x],
                fingers: [nil, .two, .one, .four, .four, nil],
                barres: [StaticBarre(fret: 10, fromString: 2, toString: 5, finger: .two)],
                tips: ["\"A sus4 root-5 (x-10-9-12-12-x)\""]
            ),
            StaticForm(
                id: "Asus4-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(17), .fret(17), .fret(19), .fret(19), .x, .x],
                fingers: [.one, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"A sus4 root-4 (17-17-19-19-x-x)\""]
            ),
            StaticForm(
                id: "Asus4-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(12), .fret(15), .fret(14), .x, .x, .x],
                fingers: [.one, .four, .three, nil, nil, nil],
                barres: [],
                tips: ["Asus4 Triad-1 (auto from Csus4 +9)"]
            ),
            StaticForm(
                id: "Asus4-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(17), .fret(19), .fret(19), .x, .x],
                fingers: [nil, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["Asus4 Triad-2 (auto from Csus4 +9)"]
            )
        ]
    ),

    // MARK: - B (M)
    StaticChord(
        id: "B",
        symbol: "B",
        quality: "M",
        forms: [
            StaticForm(
                id: "B-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(7), .fret(7), .fret(8), .fret(9), .fret(9), .fret(7)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "B-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(2), .fret(4), .fret(4), .fret(4), .fret(2), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "B-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(7), .fret(7), .fret(8), .fret(9), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "B-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(2), .fret(4), .fret(4), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "B-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(7), .fret(8), .fret(9), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - B6 (6)
    StaticChord(
        id: "B6",
        symbol: "B6",
        quality: "6",
        forms: [
            StaticForm(
                id: "B6-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(4), .fret(4), .fret(4), .fret(2), .x],
                fingers: [nil, .three, .four, .four, .one, nil],
                barres: [],
                tips: ["\"B 6 root-5 (x-2-4-4-4-x)\""]
            ),
            StaticForm(
                id: "B6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(7), .fret(9), .fret(8), .fret(9), .x, .x],
                fingers: [.one, .four, .two, .three, nil, nil],
                barres: [],
                tips: ["\"B 6 root-4 (7-9-8-9-x-x)\""]
            )
        ]
    ),

    // MARK: - B7 (7)
    StaticChord(
        id: "B7",
        symbol: "B7",
        quality: "7",
        forms: [
            StaticForm(
                id: "B7-1-Open",
                shapeName: "Open",
                frets: [.fret(3), .open, .fret(3), .fret(2), .fret(3), .open],
                fingers: [.three, nil, .two, .one, .four, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "B7-2-Root-6",
                shapeName: "Root-6",
                frets: [.fret(7), .fret(7), .fret(8), .fret(7), .fret(9), .fret(7)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "B7-3-Root-5",
                shapeName: "Root-5",
                frets: [.fret(9), .fret(11), .fret(9), .fret(11), .fret(9), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "B7-4-Root-4",
                shapeName: "Root-4",
                frets: [.fret(11), .fret(10), .fret(11), .fret(9), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            )
        ]
    ),

    // MARK: - Badd9 (add9)
    StaticChord(
        id: "Badd9",
        symbol: "Badd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Badd9-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(18), .fret(16), .fret(18), .fret(19)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"B add9 root-6 (x-x-18-16-18-19)\""]
            ),
            StaticForm(
                id: "Badd9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(14), .fret(11), .fret(13), .fret(14), .x],
                fingers: [nil, .four, .one, .two, .three, nil],
                barres: [StaticBarre(fret: 11, fromString: 2, toString: 5, finger: .four)],
                tips: ["\"B add9 root-5 (x-14-11-13-14-x) barre@11(2-5)\""]
            ),
            StaticForm(
                id: "Badd9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(21), .fret(19), .fret(20), .fret(21), .x, .x],
                fingers: [.four, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"B add9 root-4 (21-19-20-21-x-x)\""]
            )
        ]
    ),

    // MARK: - Baug (aug)
    StaticChord(
        id: "Baug",
        symbol: "Baug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "Baug-1-Open",
                shapeName: "Open",
                frets: [.fret(4), .open, .open, .fret(2), .fret(3), .open],
                fingers: [.four, nil, nil, .one, .three, nil],
                barres: [],
                tips: ["\"B augmented open (x-2-1-0-0-3)\""]
            ),
            StaticForm(
                id: "Baug-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(20), .fret(20), .fret(21), .x, .fret(19)],
                fingers: [nil, .three, .two, .four, nil, .one],
                barres: [],
                tips: ["\"B augmented root-6 (x-20-20-21-x-19)\""]
            ),
            StaticForm(
                id: "Baug-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(14), .fret(13), .fret(12), .fret(12), .x],
                fingers: [nil, .three, .two, .one, .one, nil],
                barres: [StaticBarre(fret: 12, fromString: 2, toString: 3, finger: .three)],
                tips: ["\"B augmented root-5 (x-14-13-12-12-x) barre@12(2-3)\""]
            ),
            StaticForm(
                id: "Baug-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(19), .fret(20), .fret(20), .fret(21), .x, .x],
                fingers: [.one, .two, .three, .four, nil, nil],
                barres: [],
                tips: ["\"B augmented root-4 (19-20-20-21-x-x)\""]
            ),
            StaticForm(
                id: "Baug-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(15), .fret(16), .fret(16), .x, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"B augmented Triad-1 (15-16-16-x-x-x)\""]
            ),
            StaticForm(
                id: "Baug-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(20), .fret(20), .fret(21), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 20, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"B augmented Triad-2 (x-20-20-21-x-x) barre@20(2-3)\""]
            )
        ]
    ),

    // MARK: - Bb (M)
    StaticChord(
        id: "Bb",
        symbol: "Bb",
        quality: "M",
        forms: [
            StaticForm(
                id: "Bb-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(6), .fret(6), .fret(7), .fret(8), .fret(8), .fret(6)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "Bb-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(1), .fret(3), .fret(3), .fret(3), .fret(1), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "Bb-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(6), .fret(6), .fret(7), .fret(8), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "Bb-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(1), .fret(3), .fret(3), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "Bb-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(6), .fret(7), .fret(8), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - Bbm (m)
    StaticChord(
        id: "Bbm",
        symbol: "Bbm",
        quality: "m",
        forms: [
            StaticForm(
                id: "Bbm-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(6), .fret(6), .fret(6), .fret(8), .fret(8), .fret(6)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "Bbm-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(1), .fret(2), .fret(3), .fret(3), .fret(1)],
                fingers: [nil, nil, .one, .two, .four, .three],
                barres: [],
                tips: ["1"]
            ),
            StaticForm(
                id: "Bbm-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(6), .fret(6), .fret(6), .fret(8), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "Bbm-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(1), .fret(2), .fret(3), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "Bbm-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(6), .fret(6), .fret(8), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - BbM7 (M7)
    StaticChord(
        id: "BbM7",
        symbol: "BbM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "BbM7-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(6), .fret(6), .fret(7), .fret(7), .fret(8), .fret(6)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"A#maj7 enharmonic | Maj7 E-shape\""]
            ),
            StaticForm(
                id: "BbM7-2-Root5",
                shapeName: "Root-5",
                frets: [.fret(1), .fret(3), .fret(2), .fret(3), .fret(1), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | Maj7 A-shape\""]
            ),
            StaticForm(
                id: "BbM7-3-Root4",
                shapeName: "Root-4",
                frets: [.fret(10), .fret(10), .fret(10), .fret(8), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            )
        ]
    ),

    // MARK: - Bdim (dim)
    StaticChord(
        id: "Bdim",
        symbol: "Bdim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "Bdim-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(19), .fret(18), .fret(19), .x, .x, .fret(19)],
                fingers: [.four, .one, .three, nil, nil, .two],
                barres: [],
                tips: ["Diminished (auto from Cdim +11)"]
            ),
            StaticForm(
                id: "Bdim-2",
                shapeName: "Root-5",
                frets: [.x, .fret(15), .fret(16), .fret(15), .fret(14), .x],
                fingers: [nil, .three, .four, .two, .one, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +11)"]
            ),
            StaticForm(
                id: "Bdim-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(19), .fret(18), .fret(19), .fret(21), .x, .x],
                fingers: [.three, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +11)"]
            ),
            StaticForm(
                id: "Bdim-4-Triad-1",
                shapeName: "Triad-1",
                frets: [.fret(13), .fret(15), .fret(16), .x, .x, .x],
                fingers: [.one, .three, .four, nil, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +11)"]
            ),
            StaticForm(
                id: "Bdim-5-Triad-2",
                shapeName: "Triad-2",
                frets: [.x, .fret(18), .fret(19), .fret(21), .x, .x],
                fingers: [nil, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +11)"]
            )
        ]
    ),

    // MARK: - Bm (m)
    StaticChord(
        id: "Bm",
        symbol: "Bm",
        quality: "m",
        forms: [
            StaticForm(
                id: "Bm-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(7), .fret(7), .fret(7), .fret(9), .fret(9), .fret(7)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "Bm-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(2), .fret(3), .fret(4), .fret(4), .fret(2)],
                fingers: [nil, nil, .one, .two, .four, .three],
                barres: [],
                tips: ["1"]
            ),
            StaticForm(
                id: "Bm-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(7), .fret(7), .fret(7), .fret(9), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "Bm-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(2), .fret(3), .fret(4), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "Bm-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(7), .fret(7), .fret(9), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - Bm6 (m6)
    StaticChord(
        id: "Bm6",
        symbol: "Bm6",
        quality: "m6",
        forms: [
            StaticForm(
                id: "Bm6-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(2), .open, .fret(3), .open],
                fingers: [nil, nil, .one, nil, .two, nil],
                barres: [],
                tips: ["\"B minor 6 open (x-2-0-1-0-0)\""]
            ),
            StaticForm(
                id: "Bm6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(19), .fret(19), .fret(18), .x, .fret(19)],
                fingers: [nil, .three, .four, .one, nil, .two],
                barres: [],
                tips: ["\"B minor 6 root-6 (x-19-19-18-x-19)\""]
            ),
            StaticForm(
                id: "Bm6-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(12), .fret(13), .fret(12), .fret(14), .x],
                fingers: [nil, .one, .three, .two, .four, nil],
                barres: [],
                tips: ["\"B minor 6 root-5 (x-14-12-13-12-x)\""]
            ),
            StaticForm(
                id: "Bm6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(7), .fret(9), .fret(7), .fret(9), .x, .x],
                fingers: [.one, .four, .two, .three, nil, nil],
                barres: [],
                tips: ["\"B minor 6 root-4 (7-9-7-9-x-x)\""]
            )
        ]
    ),

    // MARK: - BM7 (M7)
    StaticChord(
        id: "BM7",
        symbol: "BM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "BM7-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(7), .fret(7), .fret(8), .fret(8), .fret(9), .fret(7)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | Maj7 E-shape\""]
            ),
            StaticForm(
                id: "BM7-2-Root5",
                shapeName: "Root-5",
                frets: [.fret(2), .fret(4), .fret(3), .fret(4), .fret(2), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | Maj7 A-shape\""]
            ),
            StaticForm(
                id: "BM7-3-Root4",
                shapeName: "Root-4",
                frets: [.fret(11), .fret(11), .fret(11), .fret(9), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            )
        ]
    ),

    // MARK: - Bm9 (m9)
    StaticChord(
        id: "Bm9",
        symbol: "Bm9",
        quality: "m9",
        forms: [
            StaticForm(
                id: "Bm9-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(3), .fret(5), .fret(3), .open],
                fingers: [nil, nil, .one, .three, .two, nil],
                barres: [],
                tips: ["\"B minor 9 open (x-2-4-2-0-0)\""]
            ),
            StaticForm(
                id: "Bm9-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(7), .fret(5), .fret(5), .fret(5), .fret(7), .fret(5)],
                fingers: [.four, .one, .one, .one, .three, .one],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 6, finger: .four)],
                tips: ["\"B minor 9 root-6 (7-5-5-5-7-5) barre@5(1-6)\""]
            ),
            StaticForm(
                id: "Bm9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(14), .fret(14), .fret(12), .fret(14), .x],
                fingers: [nil, .one, .one, .three, .four, nil],
                barres: [StaticBarre(fret: 14, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"B minor 9 root-5 (x-14-14-12-14-x)\""]
            ),
            StaticForm(
                id: "Bm9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(12), .fret(12), .fret(10), .fret(7), .x, .x],
                fingers: [.four, .four, .two, .one, nil, nil],
                barres: [],
                tips: ["\"B minor 9 root-4 (12-12-10-7-x-x)\""]
            )
        ]
    ),

    // MARK: - Bsus2 (sus2)
    StaticChord(
        id: "Bsus2",
        symbol: "Bsus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Bsus2-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(2), .fret(2), .fret(4), .fret(4), .fret(2), .x],
                fingers: [.one, .one, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"B sus2 root-5 (x-2-4-4-2-2) barre@2(1-5)\""]
            )
        ]
    ),

    // MARK: - Bsus4 (sus4)
    StaticChord(
        id: "Bsus4",
        symbol: "Bsus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Bsus4-1-Open",
                shapeName: "Open",
                frets: [.fret(3), .open, .open, .fret(3), .fret(3), .open],
                fingers: [.four, nil, nil, .three, .two, nil],
                barres: [],
                tips: ["\"B sus4 open (x-2-2-0-2-2 pattern)\""]
            ),
            StaticForm(
                id: "Bsus4-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(14), .fret(16), .fret(16), .fret(16), .fret(14), .fret(14)],
                fingers: [.one, .three, .four, .four, .one, .two],
                barres: [StaticBarre(fret: 14, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"B sus4 root-6 (14-16-16-16-14-14)\""]
            ),
            StaticForm(
                id: "Bsus4-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(12), .fret(11), .fret(14), .fret(14), .x],
                fingers: [nil, .two, .one, .four, .four, nil],
                barres: [StaticBarre(fret: 12, fromString: 2, toString: 5, finger: .two)],
                tips: ["\"B sus4 root-5 (x-12-11-14-14-x)\""]
            ),
            StaticForm(
                id: "Bsus4-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(19), .fret(19), .fret(21), .fret(21), .x, .x],
                fingers: [.one, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"B sus4 root-4 (19-19-21-21-x-x)\""]
            ),
            StaticForm(
                id: "Bsus4-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(14), .fret(17), .fret(16), .x, .x, .x],
                fingers: [.one, .four, .three, nil, nil, nil],
                barres: [],
                tips: ["Bsus4 Triad-1 (auto from Csus4 +11)"]
            ),
            StaticForm(
                id: "Bsus4-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(19), .fret(21), .fret(21), .x, .x],
                fingers: [nil, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["Bsus4 Triad-2 (auto from Csus4 +11)"]
            )
        ]
    ),

    // MARK: - C (M)
    StaticChord(
        id: "C",
        symbol: "C",
        quality: "M",
        forms: [
            StaticForm(
                id: "C-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(2), .open, .fret(3), .fret(4), .open],
                fingers: [nil, .one, nil, .two, .three, nil],
                barres: [],
                tips: ["\"C major open | Beginner-friendly\""]
            ),
            StaticForm(
                id: "C-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(8), .fret(8), .fret(9), .fret(10), .fret(10), .fret(8)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "C-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(3), .fret(5), .fret(5), .fret(5), .fret(3), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "C-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(8), .fret(8), .fret(9), .fret(10), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "C-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(3), .fret(5), .fret(5), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "C-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(8), .fret(9), .fret(10), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - C# (M)
    StaticChord(
        id: "C#",
        symbol: "C#",
        quality: "M",
        forms: [
            StaticForm(
                id: "C#-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(9), .fret(9), .fret(10), .fret(11), .fret(11), .fret(9)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "C#-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(4), .fret(6), .fret(6), .fret(6), .fret(4), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "C#-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(9), .fret(9), .fret(10), .fret(11), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "C#-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(4), .fret(6), .fret(6), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "C#-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(9), .fret(10), .fret(11), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - C#7 (7)
    StaticChord(
        id: "C#7",
        symbol: "C#7",
        quality: "7",
        forms: [
            StaticForm(
                id: "C#7-1-Root-6",
                shapeName: "Root-6",
                frets: [.fret(9), .fret(9), .fret(10), .fret(9), .fret(11), .fret(9)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "C#7-2-Root-5",
                shapeName: "Root-5",
                frets: [.fret(4), .fret(6), .fret(4), .fret(6), .fret(4), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "C#7-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(13), .fret(12), .fret(13), .fret(11), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            )
        ]
    ),

    // MARK: - C#add9 (add9)
    StaticChord(
        id: "C#add9",
        symbol: "C#add9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "C#add9-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(8), .fret(6), .fret(8), .fret(9)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"C# add9 root-6 (x-x-8-6-8-9)\""]
            ),
            StaticForm(
                id: "C#add9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(4), .fret(1), .fret(3), .fret(4), .x],
                fingers: [nil, .four, .one, .two, .three, nil],
                barres: [],
                tips: ["\"C# add9 root-5 (x-4-1-3-4-x) barre@1(1-5)\""]
            ),
            StaticForm(
                id: "C#add9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(11), .fret(9), .fret(10), .fret(11), .x, .x],
                fingers: [.four, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"C# add9 root-4 (11-9-10-11-x-x)\""]
            )
        ]
    ),

    // MARK: - C#aug (aug)
    StaticChord(
        id: "C#aug",
        symbol: "C#aug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "C#aug-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(10), .fret(10), .fret(11), .x, .fret(9)],
                fingers: [nil, .three, .two, .four, nil, .one],
                barres: [],
                tips: ["\"C# augmented root-6 (x-10-10-11-x-9)\""]
            ),
            StaticForm(
                id: "C#aug-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(4), .fret(3), .fret(2), .fret(2), .x],
                fingers: [nil, .three, .two, .one, .one, nil],
                barres: [StaticBarre(fret: 2, fromString: 2, toString: 3, finger: .three)],
                tips: ["\"C# augmented root-5 (x-4-3-2-2-x) barre@2(2-3)\""]
            ),
            StaticForm(
                id: "C#aug-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(9), .fret(10), .fret(10), .fret(11), .x, .x],
                fingers: [.one, .two, .three, .four, nil, nil],
                barres: [],
                tips: ["\"C# augmented root-4 (9-10-10-11-x-x)\""]
            ),
            StaticForm(
                id: "C#aug-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(5), .fret(6), .fret(6), .x, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"C# augmented Triad-1 (5-6-6-x-x-x)\""]
            ),
            StaticForm(
                id: "C#aug-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(10), .fret(10), .fret(11), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 10, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"C# augmented Triad-2 (x-10-10-11-x-x) barre@10(2-3)\""]
            )
        ]
    ),

    // MARK: - C#dim (dim)
    StaticChord(
        id: "C#dim",
        symbol: "C#dim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "C#dim-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(9), .fret(8), .fret(9), .x, .x, .fret(9)],
                fingers: [.four, .one, .three, nil, nil, .two],
                barres: [],
                tips: ["Diminished (auto from Cdim +1)"]
            ),
            StaticForm(
                id: "C#dim-2",
                shapeName: "Root-5",
                frets: [.x, .fret(5), .fret(6), .fret(5), .fret(4), .x],
                fingers: [nil, .three, .four, .two, .one, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +1)"]
            ),
            StaticForm(
                id: "C#dim-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(9), .fret(8), .fret(9), .fret(11), .x, .x],
                fingers: [.three, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +1)"]
            ),
            StaticForm(
                id: "C#dim-4-Triad-1",
                shapeName: "Triad-1",
                frets: [.fret(3), .fret(5), .fret(6), .x, .x, .x],
                fingers: [.one, .three, .four, nil, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +1)"]
            ),
            StaticForm(
                id: "C#dim-5-Triad-2",
                shapeName: "Triad-2",
                frets: [.x, .fret(8), .fret(9), .fret(11), .x, .x],
                fingers: [nil, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +1)"]
            )
        ]
    ),

    // MARK: - C#m (m)
    StaticChord(
        id: "C#m",
        symbol: "C#m",
        quality: "m",
        forms: [
            StaticForm(
                id: "C#m-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(9), .fret(9), .fret(9), .fret(11), .fret(11), .fret(9)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "C#m-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(4), .fret(4), .fret(6), .fret(4), .x],
                fingers: [nil, .one, .one, .three, .one, nil],
                barres: [],
                tips: ["\"C# minor root-5 | Barre at 4th fret\""]
            ),
            StaticForm(
                id: "C#m-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(9), .fret(9), .fret(9), .fret(11), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "C#m-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(4), .fret(5), .fret(6), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "C#m-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(9), .fret(9), .fret(11), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - C#m7 (m7)
    StaticChord(
        id: "C#m7",
        symbol: "C#m7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "C#m7-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .open, .fret(2), .fret(3), .open],
                fingers: [nil, nil, nil, .one, .two, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "C#m7-2-Root-6",
                shapeName: "Root-6",
                frets: [.fret(9), .fret(9), .fret(9), .fret(9), .fret(11), .fret(9)],
                fingers: [.one, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "C#m7-3-Root-5",
                shapeName: "Root-5",
                frets: [.fret(4), .fret(5), .fret(4), .fret(6), .fret(4), .x],
                fingers: [.one, .two, .one, .three, .one, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "C#m7-4-Root-4",
                shapeName: "Root-4",
                frets: [.fret(12), .fret(12), .fret(13), .fret(11), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            )
        ]
    ),

    // MARK: - C#M7 (M7)
    StaticChord(
        id: "C#M7",
        symbol: "C#M7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "C#M7-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(9), .fret(9), .fret(10), .fret(10), .fret(11), .fret(9)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | Maj7 shape\""]
            ),
            StaticForm(
                id: "C#M7-2-Root5",
                shapeName: "Root-5",
                frets: [.fret(4), .fret(6), .fret(5), .fret(6), .fret(4), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | Barre\""]
            ),
            StaticForm(
                id: "C#M7-3-Root4",
                shapeName: "Root-4",
                frets: [.fret(13), .fret(13), .fret(13), .fret(11), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            )
        ]
    ),

    // MARK: - C#sus4 (sus4)
    StaticChord(
        id: "C#sus4",
        symbol: "C#sus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "C#sus4-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(4), .fret(6), .fret(6), .fret(6), .fret(4), .fret(4)],
                fingers: [.one, .three, .four, .four, .one, .two],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"C# sus4 root-6 (4-6-6-6-4-4)\""]
            ),
            StaticForm(
                id: "C#sus4-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(9), .fret(11), .fret(11), .fret(11), .fret(9), .x],
                fingers: [.one, .three, .four, .four, .one, nil],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"C# sus4 root-5 (9-11-11-11-9-x)\""]
            ),
            StaticForm(
                id: "C#sus4-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(9), .fret(9), .fret(11), .fret(11), .x, .x],
                fingers: [.one, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"C# sus4 root-4 (9-9-11-11-x-x)\""]
            ),
            StaticForm(
                id: "C#sus4-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(4), .fret(7), .fret(6), .x, .x, .x],
                fingers: [.one, .four, .three, nil, nil, nil],
                barres: [],
                tips: ["\"C# sus4 Triad-1 (4-7-6 on 1-3)\""]
            ),
            StaticForm(
                id: "C#sus4-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(9), .fret(11), .fret(11), .x, .x],
                fingers: [nil, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"C# sus4 Triad-2 (x-9-11-11-x-x)\""]
            )
        ]
    ),

    // MARK: - C6 (6)
    StaticChord(
        id: "C6",
        symbol: "C6",
        quality: "6",
        forms: [
            StaticForm(
                id: "C6-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(2), .fret(3), .fret(3), .fret(4), .open],
                fingers: [nil, .one, .three, .two, .four, nil],
                barres: [],
                tips: ["\"C 6 open (x-3-2-2-1-0)\""]
            ),
            StaticForm(
                id: "C6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(8), .fret(9), .fret(7), .x, .fret(8)],
                fingers: [nil, .three, .four, .one, nil, .two],
                barres: [],
                tips: ["\"C 6 root-6 (x-8-9-7-x-8)\""]
            ),
            StaticForm(
                id: "C6-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(5), .fret(5), .fret(5), .fret(5), .fret(3), .x],
                fingers: [.three, .three, .three, .three, .one, nil],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 4, finger: .three)],
                tips: ["\"C 6 root-5 (5-5-5-5-3-x) barre@5(1-4)\""]
            ),
            StaticForm(
                id: "C6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(8), .fret(10), .fret(9), .fret(10), .x, .x],
                fingers: [.one, .four, .two, .three, nil, nil],
                barres: [],
                tips: ["\"C 6 root-4 (8-10-9-10-x-x)\""]
            )
        ]
    ),

    // MARK: - C7 (7)
    StaticChord(
        id: "C7",
        symbol: "C7",
        quality: "7",
        forms: [
            StaticForm(
                id: "C7-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(2), .fret(4), .fret(3), .fret(4), .open],
                fingers: [nil, .one, .three, .two, .four, nil],
                barres: [],
                tips: ["\"Classic C7 open\""]
            ),
            StaticForm(
                id: "C7-2-Root-6",
                shapeName: "Root-6",
                frets: [.fret(8), .fret(8), .fret(9), .fret(8), .fret(10), .fret(8)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "C7-3-Root-5",
                shapeName: "Root-5",
                frets: [.fret(3), .fret(5), .fret(3), .fret(5), .fret(3), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "C7-4-Root-4",
                shapeName: "Root-4",
                frets: [.fret(12), .fret(11), .fret(12), .fret(10), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            )
        ]
    ),

    // MARK: - Cadd9 (add9)
    StaticChord(
        id: "Cadd9",
        symbol: "Cadd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Cadd9-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(4), .open, .fret(3), .fret(4), .open],
                fingers: [nil, .four, nil, .one, .three, nil],
                barres: [],
                tips: ["\"C add9 open (x-3-2-0-3-0)\""]
            ),
            StaticForm(
                id: "Cadd9-4-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(7), .fret(5), .fret(7), .fret(8)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"C add9 root-6 (x-x-7-5-7-8)\""]
            ),
            StaticForm(
                id: "Cadd9-4-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(7), .fret(5), .fret(7), .fret(8)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"C add9 root-6 (x-x-7-5-7-8)\""]
            ),
            StaticForm(
                id: "Cadd9-4-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(7), .fret(5), .fret(7), .fret(8)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"C add9 root-6 (x-x-7-5-7-8)\""]
            ),
            StaticForm(
                id: "Cadd9-4-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(7), .fret(5), .fret(7), .fret(8)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"C add9 root-6 (x-x-7-5-7-8)\""]
            ),
            StaticForm(
                id: "Cadd9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(5), .fret(7), .fret(5), .fret(3), .x],
                fingers: [nil, .one, .four, .two, .three, nil],
                barres: [],
                tips: ["\"C add9 root-5 (x-3-5-7-5-x)\""]
            ),
            StaticForm(
                id: "Cadd9-2-Root4",
                shapeName: "Root-4",
                frets: [.fret(10), .fret(8), .fret(9), .fret(10), .x, .x],
                fingers: [.four, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"C add9 root-4 (10-8-9-10-x-x)\""]
            )
        ]
    ),

    // MARK: - Caug (aug)
    StaticChord(
        id: "Caug",
        symbol: "Caug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "Caug-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(9), .fret(9), .fret(10), .x, .fret(8)],
                fingers: [nil, .three, .two, .four, nil, .one],
                barres: [],
                tips: ["\"C augmented root-6 (x-9-9-10-x-8)\""]
            ),
            StaticForm(
                id: "Caug-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(3), .fret(2), .fret(1), .fret(1), .x],
                fingers: [nil, .three, .two, .one, .one, nil],
                barres: [StaticBarre(fret: 1, fromString: 2, toString: 3, finger: .three)],
                tips: ["\"C augmented root-5 (x-3-2-1-1-x) barre@1(2-3)\""]
            ),
            StaticForm(
                id: "Caug-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(8), .fret(9), .fret(9), .fret(10), .x, .x],
                fingers: [.one, .two, .three, .four, nil, nil],
                barres: [],
                tips: ["\"C augmented root-4 (8-9-9-10-x-x)\""]
            ),
            StaticForm(
                id: "Caug-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(4), .fret(5), .fret(5), .x, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"C augmented Triad-1 (4-5-5-x-x-x)\""]
            ),
            StaticForm(
                id: "Caug-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(9), .fret(9), .fret(10), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 9, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"C augmented Triad-2 (x-9-9-10-x-x) barre@9(2-3)\""]
            )
        ]
    ),

    // MARK: - Cdim (dim)
    StaticChord(
        id: "Cdim",
        symbol: "Cdim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "Cdim-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(8), .fret(7), .fret(8), .x, .x, .fret(8)],
                fingers: [.four, .one, .three, nil, nil, .two],
                barres: [],
                tips: ["\"Cdim Root-6 (x-?-? pattern; 5th string mute)\""]
            ),
            StaticForm(
                id: "Cdim-2",
                shapeName: "Root-5",
                frets: [.x, .fret(4), .fret(5), .fret(4), .fret(3), .x],
                fingers: [nil, .three, .four, .two, .one, nil],
                barres: [],
                tips: ["\"Cdim Root-5 (x-4-5-4-3-x)\""]
            ),
            StaticForm(
                id: "Cdim-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(8), .fret(7), .fret(8), .fret(10), .x, .x],
                fingers: [.three, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["\"Cdim Root-4 (8-7-8-10-x-x)\""]
            ),
            StaticForm(
                id: "Cdim-4-Triad-1",
                shapeName: "Triad-1",
                frets: [.fret(2), .fret(4), .fret(5), .x, .x, .x],
                fingers: [.one, .three, .four, nil, nil, nil],
                barres: [],
                tips: ["\"Cdim Triad-1 (2-4-5 on 1-3)\""]
            ),
            StaticForm(
                id: "Cdim-5-Triad-2",
                shapeName: "Triad-2",
                frets: [.x, .fret(7), .fret(8), .fret(10), .x, .x],
                fingers: [nil, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["\"Cdim Triad-2 (x-7-8-10-x-x)\""]
            )
        ]
    ),

    // MARK: - Cm (m)
    StaticChord(
        id: "Cm",
        symbol: "Cm",
        quality: "m",
        forms: [
            StaticForm(
                id: "Cm-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(8), .fret(8), .fret(8), .fret(10), .fret(10), .fret(8)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "Cm-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(3), .fret(3), .fret(5), .fret(3), .x],
                fingers: [nil, .one, .one, .three, .one, nil],
                barres: [],
                tips: ["\"C minor root-5 | Barre at 3rd fret\""]
            ),
            StaticForm(
                id: "Cm-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(8), .fret(8), .fret(8), .fret(10), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "Cm-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(3), .fret(4), .fret(5), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "Cm-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(8), .fret(8), .fret(10), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - Cm6 (m6)
    StaticChord(
        id: "Cm6",
        symbol: "Cm6",
        quality: "m6",
        forms: [
            StaticForm(
                id: "Cm6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(8), .fret(8), .fret(7), .x, .fret(8)],
                fingers: [nil, .three, .four, .one, nil, .two],
                barres: [],
                tips: ["\"C minor 6 root-6 (x-8-8-7-x-8)\""]
            ),
            StaticForm(
                id: "Cm6-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(3), .fret(4), .fret(2), .x, .fret(3), .x],
                fingers: [.four, .three, .one, nil, .two, nil],
                barres: [],
                tips: ["\"C minor 6 root-5 (3-4-2-x-3-x)\""]
            ),
            StaticForm(
                id: "Cm6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(8), .fret(10), .fret(8), .fret(10), .x, .x],
                fingers: [.one, .four, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 3, finger: .one)],
                tips: ["\"C minor 6 root-4 (8-10-8-10-x-x) barre@8(1-3)\""]
            )
        ]
    ),

    // MARK: - Cm7 (m7)
    StaticChord(
        id: "Cm7",
        symbol: "Cm7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "Cm7-1-Root-6",
                shapeName: "Root-6",
                frets: [.fret(8), .fret(8), .fret(8), .fret(8), .fret(10), .fret(8)],
                fingers: [.one, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "Cm7-2-Root-5",
                shapeName: "Root-5",
                frets: [.fret(3), .fret(4), .fret(3), .fret(5), .fret(3), .x],
                fingers: [.one, .two, .one, .three, .one, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "Cm7-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(11), .fret(11), .fret(12), .fret(10), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            )
        ]
    ),

    // MARK: - CM7 (M7)
    StaticChord(
        id: "CM7",
        symbol: "CM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "CM7-1",
                shapeName: "Open",
                frets: [.open, .open, .open, .fret(3), .fret(4), .open],
                fingers: [nil, nil, nil, .two, .three, nil],
                barres: [],
                tips: ["\"Rich C major 7th | Open strings\""]
            ),
            StaticForm(
                id: "CM7-2",
                shapeName: "Root-6",
                frets: [.fret(8), .fret(8), .fret(9), .fret(9), .fret(10), .fret(8)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"Full barre | 2nd&3rd strings at 8/9\""]
            ),
            StaticForm(
                id: "CM7-3",
                shapeName: "Root-5",
                frets: [.fret(3), .fret(5), .fret(4), .fret(5), .fret(3), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"Barre form | 5th string root\""]
            ),
            StaticForm(
                id: "CM7-4",
                shapeName: "Root-4",
                frets: [.fret(12), .fret(12), .fret(12), .fret(10), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            )
        ]
    ),

    // MARK: - Cm9 (m9)
    StaticChord(
        id: "Cm9",
        symbol: "Cm9",
        quality: "m9",
        forms: [
            StaticForm(
                id: "Cm9-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(4), .fret(6), .fret(4), .open],
                fingers: [nil, nil, .one, .four, .two, nil],
                barres: [],
                tips: ["\"C minor 9 open (x-3-5-3-0-0)\""]
            ),
            StaticForm(
                id: "Cm9-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(8), .fret(6), .fret(6), .fret(6), .fret(8), .fret(6)],
                fingers: [nil, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["\"C minor 9 root-6 (8-6-6-6-8-6) barre@6(1-6)\""]
            ),
            StaticForm(
                id: "Cm9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(15), .fret(15), .fret(13), .fret(15), .x],
                fingers: [nil, .one, .one, .three, .four, nil],
                barres: [StaticBarre(fret: 15, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"C minor 9 root-5 (x-15-15-13-15-x)\""]
            ),
            StaticForm(
                id: "Cm9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(13), .fret(13), .fret(11), .fret(8), .x, .x],
                fingers: [.four, .four, .two, .one, nil, nil],
                barres: [],
                tips: ["\"C minor 9 root-4 (13-13-11-8-x-x)\""]
            )
        ]
    ),

    // MARK: - Csus2 (sus2)
    StaticChord(
        id: "Csus2",
        symbol: "Csus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Csus2-1-Open",
                shapeName: "Open",
                frets: [.fret(4), .fret(4), .open, .open, .fret(4), .open],
                fingers: [.four, .three, nil, nil, .one, nil],
                barres: [],
                tips: ["\"C sus2 open (x-3-0-0-3-3)\""]
            )
        ]
    ),

    // MARK: - Csus4 (sus4)
    StaticChord(
        id: "Csus4",
        symbol: "Csus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Csus4-1-Open",
                shapeName: "Open",
                frets: [.fret(2), .fret(2), .open, .fret(4), .fret(4), .open],
                fingers: [.one, .one, nil, .four, .three, nil],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 2, finger: .one)],
                tips: ["\"C sus4 open (x-3-3-0-1-1)\""]
            ),
            StaticForm(
                id: "Csus4-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(3), .fret(5), .fret(5), .fret(5), .fret(3), .fret(3)],
                fingers: [.one, .three, .four, .four, .one, .two],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"C sus4 root-6 (3-5-5-5-3-3)\""]
            ),
            StaticForm(
                id: "Csus4-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(3), .fret(6), .fret(5), .fret(5), .fret(3), .x],
                fingers: [.one, .four, .three, .two, .one, nil],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"C sus4 root-5 (3-6-5-5-3-x)\""]
            ),
            StaticForm(
                id: "Csus4-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(8), .fret(8), .fret(10), .fret(10), .x, .x],
                fingers: [.one, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"C sus4 root-4 (8-8-10-10-x-x)\""]
            ),
            StaticForm(
                id: "Csus4-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(3), .fret(6), .fret(5), .x, .x, .x],
                fingers: [.one, .four, .three, nil, nil, nil],
                barres: [],
                tips: ["\"C sus4 Triad-1 (3-6-5 on 1-3)\""]
            ),
            StaticForm(
                id: "Csus4-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(8), .fret(10), .fret(10), .x, .x],
                fingers: [nil, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"C sus4 Triad-2 (x-8-10-10-x-x)\""]
            )
        ]
    ),

    // MARK: - D (M)
    StaticChord(
        id: "D",
        symbol: "D",
        quality: "M",
        forms: [
            StaticForm(
                id: "D-1-Open",
                shapeName: "Open",
                frets: [.fret(3), .fret(4), .fret(3), .open, .open, .open],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"D major open | Bright sound\""]
            ),
            StaticForm(
                id: "D-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(10), .fret(10), .fret(11), .fret(12), .fret(12), .fret(10)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "D-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(5), .fret(7), .fret(7), .fret(7), .fret(5), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "D-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(10), .fret(10), .fret(11), .fret(12), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "D-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(5), .fret(7), .fret(7), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "D-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(10), .fret(11), .fret(12), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - D# (M)
    StaticChord(
        id: "D#",
        symbol: "D#",
        quality: "M",
        forms: [
            StaticForm(
                id: "D#-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(11), .fret(11), .fret(12), .fret(13), .fret(13), .fret(11)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "D#-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(6), .fret(8), .fret(8), .fret(8), .fret(6), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "D#-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(11), .fret(11), .fret(12), .fret(13), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "D#-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(6), .fret(8), .fret(8), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "D#-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(11), .fret(12), .fret(13), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - D#7 (7)
    StaticChord(
        id: "D#7",
        symbol: "D#7",
        quality: "7",
        forms: [
            StaticForm(
                id: "D#7-1-Root-6",
                shapeName: "Root-6",
                frets: [.fret(11), .fret(11), .fret(12), .fret(11), .fret(13), .fret(11)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "D#7-2-Root-5",
                shapeName: "Root-5",
                frets: [.fret(6), .fret(8), .fret(6), .fret(8), .fret(6), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "D#7-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(3), .fret(2), .fret(3), .fret(1), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            )
        ]
    ),

    // MARK: - D#add9 (add9)
    StaticChord(
        id: "D#add9",
        symbol: "D#add9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "D#add9-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(10), .fret(8), .fret(10), .fret(11)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"D# add9 root-6 (x-x-10-8-10-11)\""]
            ),
            StaticForm(
                id: "D#add9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(6), .fret(3), .fret(5), .fret(6), .x],
                fingers: [nil, .four, .one, .two, .three, nil],
                barres: [],
                tips: ["\"D# add9 root-5 (x-6-3-5-6-x) barre@3(1-5)\""]
            ),
            StaticForm(
                id: "D#add9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(13), .fret(11), .fret(12), .fret(13), .x, .x],
                fingers: [.four, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"D# add9 root-4 (13-11-12-13-x-x)\""]
            )
        ]
    ),

    // MARK: - D#aug (aug)
    StaticChord(
        id: "D#aug",
        symbol: "D#aug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "D#aug-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(12), .fret(12), .fret(13), .x, .fret(11)],
                fingers: [nil, .three, .two, .four, nil, .one],
                barres: [],
                tips: ["\"D# augmented root-6 (x-12-12-13-x-11)\""]
            ),
            StaticForm(
                id: "D#aug-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(6), .fret(5), .fret(4), .fret(4), .x],
                fingers: [nil, .three, .two, .one, .one, nil],
                barres: [StaticBarre(fret: 4, fromString: 2, toString: 3, finger: .three)],
                tips: ["\"D# augmented root-5 (x-6-5-4-4-x) barre@4(2-3)\""]
            ),
            StaticForm(
                id: "D#aug-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(11), .fret(12), .fret(12), .fret(13), .x, .x],
                fingers: [.one, .two, .three, .four, nil, nil],
                barres: [],
                tips: ["\"D# augmented root-4 (11-12-12-13-x-x)\""]
            ),
            StaticForm(
                id: "D#aug-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(7), .fret(8), .fret(8), .x, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"D# augmented Triad-1 (7-8-8-x-x-x)\""]
            ),
            StaticForm(
                id: "D#aug-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(12), .fret(12), .fret(13), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 12, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"D# augmented Triad-2 (x-12-12-13-x-x) barre@12(2-3)\""]
            )
        ]
    ),

    // MARK: - D#dim (dim)
    StaticChord(
        id: "D#dim",
        symbol: "D#dim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "D#dim-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(11), .fret(10), .fret(11), .x, .x, .fret(11)],
                fingers: [.four, .one, .three, nil, nil, .two],
                barres: [],
                tips: ["Diminished (auto from Cdim +3)"]
            ),
            StaticForm(
                id: "D#dim-2",
                shapeName: "Root-5",
                frets: [.x, .fret(7), .fret(8), .fret(7), .fret(6), .x],
                fingers: [nil, .three, .four, .two, .one, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +3)"]
            ),
            StaticForm(
                id: "D#dim-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(11), .fret(10), .fret(11), .fret(13), .x, .x],
                fingers: [.three, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +3)"]
            ),
            StaticForm(
                id: "D#dim-4-Triad-1",
                shapeName: "Triad-1",
                frets: [.fret(5), .fret(7), .fret(8), .x, .x, .x],
                fingers: [.one, .three, .four, nil, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +3)"]
            ),
            StaticForm(
                id: "D#dim-5-Triad-2",
                shapeName: "Triad-2",
                frets: [.x, .fret(10), .fret(11), .fret(13), .x, .x],
                fingers: [nil, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +3)"]
            )
        ]
    ),

    // MARK: - D#m (m)
    StaticChord(
        id: "D#m",
        symbol: "D#m",
        quality: "m",
        forms: [
            StaticForm(
                id: "D#m-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(11), .fret(11), .fret(11), .fret(13), .fret(13), .fret(11)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "D#m-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(6), .fret(7), .fret(8), .fret(8), .fret(6)],
                fingers: [nil, nil, .one, .two, .four, .three],
                barres: [],
                tips: ["1"]
            ),
            StaticForm(
                id: "D#m-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(11), .fret(11), .fret(11), .fret(13), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "D#m-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(6), .fret(7), .fret(8), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "D#m-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(11), .fret(11), .fret(13), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - D#m7 (m7)
    StaticChord(
        id: "D#m7",
        symbol: "D#m7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "D#m7-2-Root-6",
                shapeName: "Root-6",
                frets: [.fret(11), .fret(11), .fret(11), .fret(11), .fret(13), .fret(11)],
                fingers: [.one, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "D#m7-1-Root-5",
                shapeName: "Root-5",
                frets: [.fret(6), .fret(7), .fret(6), .fret(8), .fret(6), .x],
                fingers: [.one, .two, .one, .three, .one, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "D#m7-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(14), .fret(14), .fret(15), .fret(13), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            )
        ]
    ),

    // MARK: - D#M7 (M7)
    StaticChord(
        id: "D#M7",
        symbol: "D#M7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "D#M7-3-Root6",
                shapeName: "Root-6",
                frets: [.fret(11), .fret(11), .fret(12), .fret(12), .fret(13), .fret(11)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | Maj7 E-shape\""]
            ),
            StaticForm(
                id: "D#M7-2-Root5",
                shapeName: "Root-5",
                frets: [.fret(6), .fret(8), .fret(7), .fret(8), .fret(6), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | Maj7 A-shape\""]
            ),
            StaticForm(
                id: "D#M7-1-Root4",
                shapeName: "Root-4",
                frets: [.fret(3), .fret(3), .fret(3), .fret(1), .x, .x],
                fingers: [.three, .one, .two, .one, nil, nil],
                barres: [],
                tips: ["\"4th string root | Compact voicing\""]
            )
        ]
    ),

    // MARK: - D#sus4 (sus4)
    StaticChord(
        id: "D#sus4",
        symbol: "D#sus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "D#sus4-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(6), .fret(8), .fret(8), .fret(8), .fret(6), .fret(6)],
                fingers: [.one, .three, .four, .four, .one, .two],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"D# sus4 root-6 (6-8-8-8-6-6)\""]
            ),
            StaticForm(
                id: "D#sus4-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(11), .fret(13), .fret(13), .fret(13), .fret(11), .x],
                fingers: [.one, .three, .four, .four, .one, nil],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"D# sus4 root-5 (11-13-13-13-11-x)\""]
            ),
            StaticForm(
                id: "D#sus4-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(11), .fret(11), .fret(13), .fret(13), .x, .x],
                fingers: [.one, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"D# sus4 root-4 (11-11-13-13-x-x)\""]
            ),
            StaticForm(
                id: "D#sus4-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(6), .fret(9), .fret(8), .x, .x, .x],
                fingers: [.one, .four, .three, nil, nil, nil],
                barres: [],
                tips: ["D#sus4 Triad-1 (auto from Csus4 +3)"]
            ),
            StaticForm(
                id: "D#sus4-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(11), .fret(13), .fret(13), .x, .x],
                fingers: [nil, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["D#sus4 Triad-2 (auto from Csus4 +3)"]
            )
        ]
    ),

    // MARK: - D6 (6)
    StaticChord(
        id: "D6",
        symbol: "D6",
        quality: "6",
        forms: [
            StaticForm(
                id: "D6-1-Open",
                shapeName: "Open",
                frets: [.fret(3), .open, .fret(3), .open, .open, .open],
                fingers: [.three, nil, .two, nil, nil, nil],
                barres: [],
                tips: ["\"D 6 open (x-x-0-2-0-2)\""]
            ),
            StaticForm(
                id: "D6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(10), .fret(11), .fret(9), .fret(10), .x],
                fingers: [nil, .three, .four, .one, .two, nil],
                barres: [],
                tips: ["\"D 6 root-6 (x-10-11-9-10-x)\""]
            ),
            StaticForm(
                id: "D6-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(7), .fret(7), .fret(7), .fret(7), .fret(5), .x],
                fingers: [.three, .three, .three, .three, .one, nil],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 4, finger: .three)],
                tips: ["\"D 6 root-5 (x-5-7-7-7-7) barre@7(1-4)\""]
            ),
            StaticForm(
                id: "D6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(10), .fret(12), .fret(11), .fret(12), .x, .x],
                fingers: [.one, .four, .two, .three, nil, nil],
                barres: [],
                tips: ["\"D 6 root-4 (10-12-11-12-x-x)\""]
            )
        ]
    ),

    // MARK: - D7 (7)
    StaticChord(
        id: "D7",
        symbol: "D7",
        quality: "7",
        forms: [
            StaticForm(
                id: "D7-1-Open",
                shapeName: "Open",
                frets: [.fret(3), .fret(2), .fret(3), .open, .open, .open],
                fingers: [.three, .one, .two, nil, nil, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "D7-2-Root-6",
                shapeName: "Root-6",
                frets: [.fret(10), .fret(10), .fret(11), .fret(10), .fret(12), .fret(10)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "D7-3-Root-5",
                shapeName: "Root-5",
                frets: [.fret(5), .fret(7), .fret(5), .fret(7), .fret(5), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "D7-4-Root-4",
                shapeName: "Root-4",
                frets: [.fret(10), .fret(10), .fret(11), .fret(12), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | Alt voicing\""]
            )
        ]
    ),

    // MARK: - Dadd9 (add9)
    StaticChord(
        id: "Dadd9",
        symbol: "Dadd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Dadd9-4-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(9), .fret(7), .fret(9), .fret(10)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"D add9 root-6 (x-x-9-7-9-10)\""]
            ),
            StaticForm(
                id: "Dadd9-2-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(5), .fret(2), .fret(4), .fret(5), .x],
                fingers: [nil, .four, .one, .two, .three, nil],
                barres: [],
                tips: ["\"D add9 root-5 (x-5-2-4-5-x) barre@2(1-5)\""]
            ),
            StaticForm(
                id: "Dadd9-3-Root4",
                shapeName: "Root-4",
                frets: [.fret(12), .fret(10), .fret(11), .fret(12), .x, .x],
                fingers: [.four, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"D add9 root-4 (12-10-11-12-x-x)\""]
            )
        ]
    ),

    // MARK: - Daug (aug)
    StaticChord(
        id: "Daug",
        symbol: "Daug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "Daug-1-Open",
                shapeName: "Open",
                frets: [.fret(3), .fret(4), .fret(4), .open, .open, .open],
                fingers: [.one, .three, .four, nil, nil, nil],
                barres: [],
                tips: ["\"D augmented open (x-x-0-3-3-2)\""]
            ),
            StaticForm(
                id: "Daug-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(11), .fret(11), .fret(12), .x, .fret(10)],
                fingers: [nil, .three, .two, .four, nil, .one],
                barres: [],
                tips: ["\"D augmented root-6 (x-11-11-12-x-10)\""]
            ),
            StaticForm(
                id: "Daug-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(5), .fret(4), .fret(3), .fret(3), .x],
                fingers: [nil, .three, .two, .one, .one, nil],
                barres: [StaticBarre(fret: 3, fromString: 2, toString: 3, finger: .three)],
                tips: ["\"D augmented root-5 (x-5-4-3-3-x) barre@3(2-3)\""]
            ),
            StaticForm(
                id: "Daug-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(10), .fret(11), .fret(11), .fret(12), .x, .x],
                fingers: [.one, .two, .three, .four, nil, nil],
                barres: [],
                tips: ["\"D augmented root-4 (10-11-11-12-x-x)\""]
            ),
            StaticForm(
                id: "Daug-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(6), .fret(7), .fret(7), .x, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"D augmented Triad-1 (6-7-7-x-x-x)\""]
            ),
            StaticForm(
                id: "Daug-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(11), .fret(11), .fret(12), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 11, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"D augmented Triad-2 (x-11-11-12-x-x) barre@11(2-3)\""]
            )
        ]
    ),

    // MARK: - Ddim (dim)
    StaticChord(
        id: "Ddim",
        symbol: "Ddim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "Ddim-1",
                shapeName: nil,
                frets: [.x, .fret(6), .fret(4), .fret(6), .fret(4), .x],
                fingers: [nil, .three, .one, .four, .two, nil],
                barres: [],
                tips: ["Diminished (extracted)"]
            )
        ]
    ),

    // MARK: - Dm (m)
    StaticChord(
        id: "Dm",
        symbol: "Dm",
        quality: "m",
        forms: [
            StaticForm(
                id: "Dm-1-Open",
                shapeName: "Open",
                frets: [.fret(2), .fret(4), .fret(3), .open, .open, .open],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"D minor open | Compact\""]
            ),
            StaticForm(
                id: "Dm-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(10), .fret(10), .fret(10), .fret(12), .fret(12), .fret(10)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "Dm-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(5), .fret(6), .fret(7), .fret(7), .fret(5), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape minor barre\""]
            ),
            StaticForm(
                id: "Dm-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(10), .fret(10), .fret(10), .fret(12), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "Dm-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(5), .fret(6), .fret(7), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "Dm-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(10), .fret(10), .fret(12), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - Dm6 (m6)
    StaticChord(
        id: "Dm6",
        symbol: "Dm6",
        quality: "m6",
        forms: [
            StaticForm(
                id: "Dm6-1-Open",
                shapeName: "Open",
                frets: [.fret(2), .open, .fret(3), .open, .open, .open],
                fingers: [.one, nil, .two, nil, nil, nil],
                barres: [],
                tips: ["\"D minor 6 open (x-x-0-2-0-1)\""]
            ),
            StaticForm(
                id: "Dm6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(10), .fret(10), .fret(9), .x, .fret(10)],
                fingers: [nil, .three, .four, .one, nil, .two],
                barres: [],
                tips: ["\"D minor 6 root-6 (x-10-10-9-x-10)\""]
            ),
            StaticForm(
                id: "Dm6-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(5), .fret(6), .fret(4), .x, .fret(5), .x],
                fingers: [.four, .three, .one, nil, .two, nil],
                barres: [],
                tips: ["\"D minor 6 root-5 (5-6-4-x-5-x)\""]
            ),
            StaticForm(
                id: "Dm6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(10), .fret(12), .fret(10), .fret(12), .x, .x],
                fingers: [.one, .four, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 3, finger: .one)],
                tips: ["\"D minor 6 root-4 (10-12-10-12-x-x) barre@10(1-3)\""]
            )
        ]
    ),

    // MARK: - Dm7 (m7)
    StaticChord(
        id: "Dm7",
        symbol: "Dm7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "Dm7-1-Open",
                shapeName: "Open",
                frets: [.fret(2), .fret(2), .fret(3), .open, .open, .open],
                fingers: [.one, .one, .two, nil, nil, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "Dm7-2-Root-6",
                shapeName: "Root-6",
                frets: [.fret(10), .fret(10), .fret(10), .fret(10), .fret(12), .fret(10)],
                fingers: [.one, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "Dm7-3-Root-5",
                shapeName: "Root-5",
                frets: [.fret(5), .fret(6), .fret(5), .fret(7), .fret(5), .x],
                fingers: [.one, .two, .one, .three, .one, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "Dm7-4-Root-4",
                shapeName: "Root-4",
                frets: [.fret(13), .fret(13), .fret(14), .fret(12), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            )
        ]
    ),

    // MARK: - DM7 (M7)
    StaticChord(
        id: "DM7",
        symbol: "DM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "DM7-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(10), .fret(10), .fret(11), .fret(11), .fret(12), .fret(10)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | Maj7 shape\""]
            ),
            StaticForm(
                id: "DM7-2-Root5",
                shapeName: "Root-5",
                frets: [.fret(5), .fret(7), .fret(6), .fret(7), .fret(5), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | Barre\""]
            ),
            StaticForm(
                id: "DM7-3-Root4",
                shapeName: "Root-4",
                frets: [.fret(14), .fret(14), .fret(14), .fret(12), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            )
        ]
    ),

    // MARK: - Dm9 (m9)
    StaticChord(
        id: "Dm9",
        symbol: "Dm9",
        quality: "m9",
        forms: [
            StaticForm(
                id: "Dm9-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(6), .fret(8), .fret(6), .open],
                fingers: [nil, nil, .one, .four, .two, nil],
                barres: [],
                tips: ["\"D minor 9 open (x-5-7-5-0-0)\""]
            ),
            StaticForm(
                id: "Dm9-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(10), .fret(8), .fret(8), .fret(8), .fret(10), .fret(8)],
                fingers: [nil, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["\"D minor 9 root-6 (10-8-8-8-10-8) barre@8(1-6)\""]
            ),
            StaticForm(
                id: "Dm9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(17), .fret(17), .fret(15), .fret(17), .x],
                fingers: [nil, .one, .one, .three, .four, nil],
                barres: [StaticBarre(fret: 17, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"D minor 9 root-5 (x-17-17-15-17-x)\""]
            ),
            StaticForm(
                id: "Dm9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(15), .fret(15), .fret(13), .fret(10), .x, .x],
                fingers: [.four, .four, .two, .one, nil, nil],
                barres: [],
                tips: ["\"D minor 9 root-4 (15-15-13-10-x-x)\""]
            )
        ]
    ),

    // MARK: - Dsus2 (sus2)
    StaticChord(
        id: "Dsus2",
        symbol: "Dsus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Dsus2-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(4), .fret(3), .open, .open, .open],
                fingers: [nil, .three, .one, nil, nil, nil],
                barres: [],
                tips: ["\"D sus2 open (x-x-0-2-3-0)\""]
            )
        ]
    ),

    // MARK: - Dsus4 (sus4)
    StaticChord(
        id: "Dsus4",
        symbol: "Dsus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Dsus4-1-Open",
                shapeName: "Open",
                frets: [.fret(4), .fret(4), .fret(3), .open, .open, .open],
                fingers: [.four, .three, .one, nil, nil, nil],
                barres: [],
                tips: ["\"D sus4 open (x-x-0-2-3-3)\""]
            ),
            StaticForm(
                id: "Dsus4-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(5), .fret(7), .fret(7), .fret(7), .fret(5), .fret(5)],
                fingers: [.one, .three, .four, .four, .one, .two],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"D sus4 root-6 (5-7-7-7-5-5)\""]
            ),
            StaticForm(
                id: "Dsus4-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(10), .fret(12), .fret(12), .fret(12), .fret(10), .x],
                fingers: [.one, .three, .four, .four, .one, nil],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"D sus4 root-5 (10-12-12-12-10-x)\""]
            ),
            StaticForm(
                id: "Dsus4-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(10), .fret(10), .fret(12), .fret(12), .x, .x],
                fingers: [.one, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"D sus4 root-4 (10-10-12-12-x-x)\""]
            ),
            StaticForm(
                id: "Dsus4-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(5), .fret(8), .fret(7), .x, .x, .x],
                fingers: [.one, .four, .three, nil, nil, nil],
                barres: [],
                tips: ["Dsus4 Triad-1 (auto from Csus4 +2)"]
            ),
            StaticForm(
                id: "Dsus4-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(10), .fret(12), .fret(12), .x, .x],
                fingers: [nil, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["Dsus4 Triad-2 (auto from Csus4 +2)"]
            )
        ]
    ),

    // MARK: - E (M)
    StaticChord(
        id: "E",
        symbol: "E",
        quality: "M",
        forms: [
            StaticForm(
                id: "E-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(2), .fret(3), .fret(3), .open],
                fingers: [nil, nil, .one, .three, .two, nil],
                barres: [],
                tips: ["\"E major open | Full"]
            ),
            StaticForm(
                id: "E-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(12), .fret(13), .fret(14), .x, .fret(12)],
                fingers: [nil, .two, .three, .four, nil, .one],
                barres: [],
                tips: []
            ),
            StaticForm(
                id: "E-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(7), .fret(9), .fret(9), .fret(9), .fret(7), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "E-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(12), .fret(12), .fret(13), .fret(14), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "E-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(7), .fret(9), .fret(9), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "E-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(12), .fret(13), .fret(14), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - E6 (6)
    StaticChord(
        id: "E6",
        symbol: "E6",
        quality: "6",
        forms: [
            StaticForm(
                id: "E6-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(3), .fret(2), .fret(3), .fret(3), .open],
                fingers: [nil, .four, .one, .three, .two, nil],
                barres: [],
                tips: ["\"E 6 open (0-2-2-1-2-0)\""]
            ),
            StaticForm(
                id: "E6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(12), .fret(13), .fret(11), .x, .fret(12)],
                fingers: [nil, .three, .four, .one, nil, .two],
                barres: [],
                tips: ["\"E 6 root-6 (x-12-13-11-x-12)\""]
            ),
            StaticForm(
                id: "E6-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(9), .fret(9), .fret(9), .fret(9), .fret(7), .x],
                fingers: [.three, .three, .three, .three, .one, nil],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 4, finger: .three)],
                tips: ["\"E 6 root-5 (x-7-9-9-9-9) barre@9(1-4)\""]
            ),
            StaticForm(
                id: "E6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(4), .fret(2), .fret(4), .fret(2), .x, .x],
                fingers: [.four, .one, .three, .one, nil, nil],
                barres: [StaticBarre(fret: 2, fromString: 2, toString: 4, finger: .one)],
                tips: ["\"E 6 root-4 (4-2-4-2-x-x) partial barre@2(2-4)\""]
            )
        ]
    ),

    // MARK: - E7 (7)
    StaticChord(
        id: "E7",
        symbol: "E7",
        quality: "7",
        forms: [
            StaticForm(
                id: "E7-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(2), .open, .fret(3), .open],
                fingers: [nil, nil, .one, nil, .two, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "E7-2-Root-6",
                shapeName: "Root-6",
                frets: [.x, .fret(12), .fret(13), .fret(12), .x, .fret(12)],
                fingers: [nil, .one, .two, .one, nil, .one],
                barres: [StaticBarre(fret: 12, fromString: 2, toString: 4, finger: .one)],
                tips: ["\"Shell voicing at 12F (E7)\""]
            ),
            StaticForm(
                id: "E7-3-Root-5",
                shapeName: "Root-5",
                frets: [.fret(7), .fret(9), .fret(7), .fret(9), .fret(7), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "E7-4-Root-4",
                shapeName: "Root-4",
                frets: [.open, .fret(3), .fret(1), .fret(2), .x, .x],
                fingers: [nil, .three, .one, .two, nil, nil],
                barres: [],
                tips: ["\"4th string root | Low open voicing\""]
            )
        ]
    ),

    // MARK: - Eadd9 (add9)
    StaticChord(
        id: "Eadd9",
        symbol: "Eadd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Eadd9-1-Open",
                shapeName: "Open",
                frets: [.fret(3), .open, .fret(2), .fret(3), .fret(3), .open],
                fingers: [.four, nil, .one, .three, .two, nil],
                barres: [],
                tips: ["\"E add9 open (2-0-1-2-2-0)\""]
            ),
            StaticForm(
                id: "Eadd9-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(11), .fret(9), .fret(11), .fret(12)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"E add9 root-6 (x-x-11-9-11-12)\""]
            ),
            StaticForm(
                id: "Eadd9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(7), .fret(4), .fret(6), .fret(7), .x],
                fingers: [nil, .four, .one, .two, .three, nil],
                barres: [],
                tips: ["\"E add9 root-5 (x-7-4-6-7-x) barre@4(1-5)\""]
            ),
            StaticForm(
                id: "Eadd9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(14), .fret(12), .fret(13), .fret(14), .x, .x],
                fingers: [.four, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"E add9 root-4 (14-12-13-14-x-x)\""]
            )
        ]
    ),

    // MARK: - Eaug (aug)
    StaticChord(
        id: "Eaug",
        symbol: "Eaug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "Eaug-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(2), .fret(2), .fret(3), .fret(4), .open],
                fingers: [nil, .two, .one, .three, .four, nil],
                barres: [],
                tips: ["\"E augmented open (0-3-2-1-1-0)\""]
            ),
            StaticForm(
                id: "Eaug-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(13), .fret(13), .fret(14), .x, .fret(12)],
                fingers: [nil, .three, .two, .four, nil, .one],
                barres: [],
                tips: ["\"E augmented root-6 (x-13-13-14-x-12)\""]
            ),
            StaticForm(
                id: "Eaug-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(7), .fret(6), .fret(5), .fret(5), .x],
                fingers: [nil, .three, .two, .one, .one, nil],
                barres: [StaticBarre(fret: 5, fromString: 2, toString: 3, finger: .three)],
                tips: ["\"E augmented root-5 (x-7-6-5-5-x) barre@5(2-3)\""]
            ),
            StaticForm(
                id: "Eaug-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(12), .fret(13), .fret(13), .fret(14), .x, .x],
                fingers: [.one, .two, .three, .four, nil, nil],
                barres: [],
                tips: ["\"E augmented root-4 (12-13-13-14-x-x)\""]
            ),
            StaticForm(
                id: "Eaug-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(8), .fret(9), .fret(9), .x, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"E augmented Triad-1 (8-9-9-x-x-x)\""]
            ),
            StaticForm(
                id: "Eaug-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(13), .fret(13), .fret(14), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 13, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"E augmented Triad-2 (x-13-13-14-x-x) barre@13(2-3)\""]
            )
        ]
    ),

    // MARK: - Eb (M)
    StaticChord(
        id: "Eb",
        symbol: "Eb",
        quality: "M",
        forms: [
            StaticForm(
                id: "Eb-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(11), .fret(11), .fret(12), .fret(13), .fret(13), .fret(11)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "Eb-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(6), .fret(8), .fret(8), .fret(8), .fret(6), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "Eb-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(11), .fret(11), .fret(12), .fret(13), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "Eb-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(6), .fret(8), .fret(8), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "Eb-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(11), .fret(12), .fret(13), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - Ebm (m)
    StaticChord(
        id: "Ebm",
        symbol: "Ebm",
        quality: "m",
        forms: [
            StaticForm(
                id: "Ebm-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(11), .fret(11), .fret(11), .fret(13), .fret(13), .fret(11)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "Ebm-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(6), .fret(7), .fret(8), .fret(8), .fret(6)],
                fingers: [nil, nil, .one, .two, .four, .three],
                barres: [],
                tips: ["1"]
            ),
            StaticForm(
                id: "Ebm-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(11), .fret(11), .fret(11), .fret(13), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "Ebm-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(6), .fret(7), .fret(8), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "Ebm-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(11), .fret(11), .fret(13), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - EbM7 (M7)
    StaticChord(
        id: "EbM7",
        symbol: "EbM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "EbM7-3-Root6",
                shapeName: "Root-6",
                frets: [.fret(11), .fret(11), .fret(12), .fret(12), .fret(13), .fret(11)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | Maj7 E-shape\""]
            ),
            StaticForm(
                id: "EbM7-2-Root5",
                shapeName: "Root-5",
                frets: [.fret(6), .fret(8), .fret(7), .fret(8), .fret(6), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | Maj7 A-shape\""]
            ),
            StaticForm(
                id: "EbM7-1-Root4",
                shapeName: "Root-4",
                frets: [.fret(3), .fret(3), .fret(3), .fret(1), .x, .x],
                fingers: [.three, .one, .two, .one, nil, nil],
                barres: [],
                tips: ["\"4th string root | Compact voicing\""]
            )
        ]
    ),

    // MARK: - Edim (dim)
    StaticChord(
        id: "Edim",
        symbol: "Edim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "Edim-1",
                shapeName: nil,
                frets: [.x, .fret(1), .open, .fret(1), .open, .x],
                fingers: [nil, .one, nil, .two, nil, nil],
                barres: [],
                tips: ["Diminished (extracted)"]
            )
        ]
    ),

    // MARK: - Em (m)
    StaticChord(
        id: "Em",
        symbol: "Em",
        quality: "m",
        forms: [
            StaticForm(
                id: "Em-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .open, .fret(3), .fret(3), .open],
                fingers: [nil, nil, nil, .two, .three, nil],
                barres: [],
                tips: ["\"E minor open | Beautiful resonance\""]
            ),
            StaticForm(
                id: "Em-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(9), .fret(9), .fret(10), .fret(12)],
                fingers: [nil, nil, .one, .one, .two, .four],
                barres: [StaticBarre(fret: 9, fromString: 3, toString: 4, finger: .one)],
                tips: ["\"Compact Em (x-x-9-9-10-12)\""]
            ),
            StaticForm(
                id: "Em-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(7), .fret(8), .fret(9), .fret(9), .fret(7), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape minor barre\""]
            ),
            StaticForm(
                id: "Em-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(12), .fret(12), .fret(12), .fret(14), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "Em-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(7), .fret(8), .fret(9), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "Em-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(12), .fret(12), .fret(14), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - Em6 (m6)
    StaticChord(
        id: "Em6",
        symbol: "Em6",
        quality: "m6",
        forms: [
            StaticForm(
                id: "Em6-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(3), .open, .fret(3), .fret(3), .open],
                fingers: [nil, .two, nil, .three, .four, nil],
                barres: [],
                tips: ["\"E minor 6 open (0-2-2-0-2-0)\""]
            ),
            StaticForm(
                id: "Em6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(12), .fret(12), .fret(11), .x, .fret(12)],
                fingers: [nil, .three, .four, .one, nil, .two],
                barres: [],
                tips: ["\"E minor 6 root-6 (x-12-12-11-x-12)\""]
            ),
            StaticForm(
                id: "Em6-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(7), .fret(8), .fret(6), .x, .fret(7), .x],
                fingers: [.four, .three, .one, nil, .two, nil],
                barres: [],
                tips: ["\"E minor 6 root-5 (7-8-6-x-7-x)\""]
            ),
            StaticForm(
                id: "Em6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(12), .fret(14), .fret(12), .fret(14), .x, .x],
                fingers: [.one, .four, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 12, fromString: 1, toString: 3, finger: .one)],
                tips: ["\"E minor 6 root-4 (12-14-12-14-x-x) barre@12(1-3)\""]
            )
        ]
    ),

    // MARK: - Em7 (m7)
    StaticChord(
        id: "Em7",
        symbol: "Em7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "Em7-4-Root-6",
                shapeName: "Root-6",
                frets: [.fret(12), .fret(12), .fret(12), .fret(12), .fret(14), .fret(12)],
                fingers: [.one, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "Em7-3-Root-5",
                shapeName: "Root-5",
                frets: [.fret(7), .fret(8), .fret(7), .fret(9), .fret(7), .x],
                fingers: [.one, .two, .one, .three, .one, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "Em7-2-Root-4",
                shapeName: "Root-4",
                frets: [.fret(3), .fret(3), .fret(4), .fret(2), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            )
        ]
    ),

    // MARK: - EM7 (M7)
    StaticChord(
        id: "EM7",
        symbol: "EM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "EM7-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(2), .fret(2), .fret(3), .open],
                fingers: [nil, nil, .one, .two, .three, nil],
                barres: [],
                tips: ["\"E major 7th | Beautiful open voicing\""]
            ),
            StaticForm(
                id: "EM7-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(12), .fret(13), .fret(13), .x, .fret(12)],
                fingers: [nil, .one, .three, .two, nil, .one],
                barres: [StaticBarre(fret: 12, fromString: 2, toString: 4, finger: .one)],
                tips: ["\"Shell voicing at 12F (avoid duplicating Open at +12)\""]
            ),
            StaticForm(
                id: "EM7-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(7), .fret(9), .fret(8), .fret(9), .fret(7), .x],
                fingers: [.one, .three, .two, .four, .one, nil],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | Standard M7 A-shape\""]
            ),
            StaticForm(
                id: "EM7-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(11), .fret(12), .fret(13), .fret(14), .x, .x],
                fingers: [.one, .three, .two, .four, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            )
        ]
    ),

    // MARK: - Em9 (m9)
    StaticChord(
        id: "Em9",
        symbol: "Em9",
        quality: "m9",
        forms: [
            StaticForm(
                id: "Em9-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(8), .fret(10), .fret(8), .open],
                fingers: [nil, nil, .one, .four, .two, nil],
                barres: [],
                tips: ["\"E minor 9 open (x-7-9-7-0-0)\""]
            ),
            StaticForm(
                id: "Em9-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(12), .fret(10), .fret(10), .fret(10), .fret(12), .fret(10)],
                fingers: [nil, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["\"E minor 9 root-6 (12-10-10-10-12-10) barre@10(1-6)\""]
            ),
            StaticForm(
                id: "Em9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(19), .fret(19), .fret(17), .fret(19), .x],
                fingers: [nil, .one, .one, .three, .four, nil],
                barres: [StaticBarre(fret: 19, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"E minor 9 root-5 (x-19-19-17-19-x)\""]
            ),
            StaticForm(
                id: "Em9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(17), .fret(17), .fret(15), .fret(12), .x, .x],
                fingers: [.four, .four, .two, .one, nil, nil],
                barres: [],
                tips: ["\"E minor 9 root-4 (17-17-15-12-x-x)\""]
            )
        ]
    ),

    // MARK: - Esus2 (sus2)
    StaticChord(
        id: "Esus2",
        symbol: "Esus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Esus2-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(5), .fret(5), .fret(3), .open],
                fingers: [nil, nil, .three, .four, .one, nil],
                barres: [],
                tips: ["\"E sus2 open (0-2-4-4-0-0)\""]
            )
        ]
    ),

    // MARK: - Esus4 (sus4)
    StaticChord(
        id: "Esus4",
        symbol: "Esus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Esus4-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(3), .fret(3), .open, .open],
                fingers: [nil, nil, .three, .four, nil, nil],
                barres: [],
                tips: ["\"E sus4 open (0-0-2-2-0-0)\""]
            ),
            StaticForm(
                id: "Esus4-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(10), .open, .fret(9), .x, .fret(12)],
                fingers: [nil, .two, nil, .one, nil, .four],
                barres: [],
                tips: ["\"E sus4 root-6 (x-10-0-9-x-12)\""]
            ),
            StaticForm(
                id: "Esus4-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(12), .fret(14), .fret(14), .fret(14), .fret(12), .x],
                fingers: [.one, .three, .four, .four, .one, nil],
                barres: [StaticBarre(fret: 12, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"E sus4 root-5 (12-14-14-14-12-x)\""]
            ),
            StaticForm(
                id: "Esus4-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(12), .fret(12), .fret(14), .fret(14), .x, .x],
                fingers: [.one, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"E sus4 root-4 (12-12-14-14-x-x)\""]
            ),
            StaticForm(
                id: "Esus4-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(7), .fret(10), .fret(9), .x, .x, .x],
                fingers: [.one, .four, .three, nil, nil, nil],
                barres: [],
                tips: ["Esus4 Triad-1 (auto from Csus4 +4)"]
            ),
            StaticForm(
                id: "Esus4-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(12), .fret(14), .fret(14), .x, .x],
                fingers: [nil, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["Esus4 Triad-2 (auto from Csus4 +4)"]
            )
        ]
    ),

    // MARK: - F (M)
    StaticChord(
        id: "F",
        symbol: "F",
        quality: "M",
        forms: [
            StaticForm(
                id: "F-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(1), .fret(1), .fret(2), .fret(3), .fret(3), .fret(1)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "F-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(8), .fret(10), .fret(10), .fret(10), .fret(8), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "F-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(3), .fret(3), .fret(4), .fret(5), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "F-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(8), .fret(10), .fret(10), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "F-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(1), .fret(2), .fret(3), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - F# (M)
    StaticChord(
        id: "F#",
        symbol: "F#",
        quality: "M",
        forms: [
            StaticForm(
                id: "F#-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(2), .fret(2), .fret(3), .fret(4), .fret(4), .fret(2)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "F#-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(9), .fret(11), .fret(11), .fret(11), .fret(9), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "F#-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(2), .fret(2), .fret(3), .fret(4), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "F#-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(9), .fret(11), .fret(11), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "F#-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(2), .fret(3), .fret(4), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - F#7 (7)
    StaticChord(
        id: "F#7",
        symbol: "F#7",
        quality: "7",
        forms: [
            StaticForm(
                id: "F#7-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(3), .fret(4), .fret(5), .open, .open],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "F#7-2-Root-6",
                shapeName: "Root-6",
                frets: [.fret(2), .fret(2), .fret(3), .fret(2), .fret(4), .fret(2)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "F#7-3-Root-5",
                shapeName: "Root-5",
                frets: [.fret(9), .fret(11), .fret(9), .fret(11), .fret(9), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "F#7-4-Root-4",
                shapeName: "Root-4",
                frets: [.fret(6), .fret(5), .fret(6), .fret(4), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            )
        ]
    ),

    // MARK: - F#add9 (add9)
    StaticChord(
        id: "F#add9",
        symbol: "F#add9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "F#add9-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(13), .fret(11), .fret(13), .fret(14)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"F# add9 root-6 (x-x-13-11-13-14)\""]
            ),
            StaticForm(
                id: "F#add9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(9), .fret(6), .fret(8), .fret(9), .x],
                fingers: [nil, .four, .one, .two, .three, nil],
                barres: [],
                tips: ["\"F# add9 root-5 (x-9-6-8-9-x) barre@6(1-5)\""]
            ),
            StaticForm(
                id: "F#add9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(16), .fret(14), .fret(15), .fret(16), .x, .x],
                fingers: [.four, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"F# add9 root-4 (16-14-15-16-x-x)\""]
            )
        ]
    ),

    // MARK: - F#aug (aug)
    StaticChord(
        id: "F#aug",
        symbol: "F#aug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "F#aug-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(15), .fret(15), .fret(16), .x, .fret(14)],
                fingers: [nil, .three, .two, .four, nil, .one],
                barres: [],
                tips: ["\"F# augmented root-6 (x-15-15-16-x-14)\""]
            ),
            StaticForm(
                id: "F#aug-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(9), .fret(8), .fret(7), .fret(7), .x],
                fingers: [nil, .three, .two, .one, .one, nil],
                barres: [StaticBarre(fret: 7, fromString: 2, toString: 3, finger: .three)],
                tips: ["\"F# augmented root-5 (x-9-8-7-7-x) barre@7(2-3)\""]
            ),
            StaticForm(
                id: "F#aug-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(14), .fret(15), .fret(15), .fret(16), .x, .x],
                fingers: [.one, .two, .three, .four, nil, nil],
                barres: [],
                tips: ["\"F# augmented root-4 (14-15-15-16-x-x)\""]
            ),
            StaticForm(
                id: "F#aug-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(10), .fret(11), .fret(11), .x, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"F# augmented Triad-1 (10-11-11-x-x-x)\""]
            ),
            StaticForm(
                id: "F#aug-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(15), .fret(15), .fret(16), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 15, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"F# augmented Triad-2 (x-15-15-16-x-x) barre@15(2-3)\""]
            )
        ]
    ),

    // MARK: - F#dim (dim)
    StaticChord(
        id: "F#dim",
        symbol: "F#dim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "F#dim-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(14), .fret(13), .fret(14), .x, .x, .fret(14)],
                fingers: [.four, .one, .three, nil, nil, .two],
                barres: [],
                tips: ["Diminished (auto from Cdim +6)"]
            ),
            StaticForm(
                id: "F#dim-2",
                shapeName: "Root-5",
                frets: [.x, .fret(10), .fret(11), .fret(10), .fret(9), .x],
                fingers: [nil, .three, .four, .two, .one, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +6)"]
            ),
            StaticForm(
                id: "F#dim-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(14), .fret(13), .fret(14), .fret(16), .x, .x],
                fingers: [.three, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +6)"]
            ),
            StaticForm(
                id: "F#dim-4-Triad-1",
                shapeName: "Triad-1",
                frets: [.fret(8), .fret(10), .fret(11), .x, .x, .x],
                fingers: [.one, .three, .four, nil, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +6)"]
            ),
            StaticForm(
                id: "F#dim-5-Triad-2",
                shapeName: "Triad-2",
                frets: [.x, .fret(13), .fret(14), .fret(16), .x, .x],
                fingers: [nil, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +6)"]
            )
        ]
    ),

    // MARK: - F#m (m)
    StaticChord(
        id: "F#m",
        symbol: "F#m",
        quality: "m",
        forms: [
            StaticForm(
                id: "F#m-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(2), .fret(2), .fret(2), .fret(4), .fret(4), .fret(2)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "F#m-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(9), .fret(10), .fret(11), .fret(11), .fret(9)],
                fingers: [nil, nil, .one, .two, .four, .three],
                barres: [],
                tips: ["1"]
            ),
            StaticForm(
                id: "F#m-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(2), .fret(2), .fret(2), .fret(4), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "F#m-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(9), .fret(10), .fret(11), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "F#m-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(2), .fret(2), .fret(4), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - F#m7 (m7)
    StaticChord(
        id: "F#m7",
        symbol: "F#m7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "F#m7-1-Root-6",
                shapeName: "Root-6",
                frets: [.fret(2), .fret(2), .fret(2), .fret(2), .fret(4), .fret(2)],
                fingers: [.one, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "F#m7-2-Root-5",
                shapeName: "Root-5",
                frets: [.fret(9), .fret(10), .fret(9), .fret(11), .fret(9), .x],
                fingers: [.one, .two, .one, .three, .one, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "F#m7-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(5), .fret(5), .fret(6), .fret(4), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            )
        ]
    ),

    // MARK: - F#M7 (M7)
    StaticChord(
        id: "F#M7",
        symbol: "F#M7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "F#M7-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(2), .fret(2), .fret(3), .fret(3), .fret(4), .fret(2)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | Maj7 E-shape\""]
            ),
            StaticForm(
                id: "F#M7-2-Root5",
                shapeName: "Root-5",
                frets: [.fret(9), .fret(11), .fret(10), .fret(11), .fret(9), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | Maj7 A-shape\""]
            ),
            StaticForm(
                id: "F#M7-3-Root4",
                shapeName: "Root-4",
                frets: [.fret(6), .fret(6), .fret(6), .fret(4), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            )
        ]
    ),

    // MARK: - F#sus4 (sus4)
    StaticChord(
        id: "F#sus4",
        symbol: "F#sus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "F#sus4-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(9), .fret(11), .fret(11), .fret(11), .fret(9), .fret(9)],
                fingers: [.one, .three, .four, .four, .one, .two],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"F# sus4 root-6 (9-11-11-11-9-9)\""]
            ),
            StaticForm(
                id: "F#sus4-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(14), .fret(16), .fret(16), .fret(16), .fret(14), .x],
                fingers: [.one, .three, .four, .four, .one, nil],
                barres: [StaticBarre(fret: 14, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"F# sus4 root-5 (14-16-16-16-14-x)\""]
            ),
            StaticForm(
                id: "F#sus4-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(14), .fret(14), .fret(16), .fret(16), .x, .x],
                fingers: [.one, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"F# sus4 root-4 (14-14-16-16-x-x)\""]
            ),
            StaticForm(
                id: "F#sus4-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(9), .fret(12), .fret(11), .x, .x, .x],
                fingers: [.one, .four, .three, nil, nil, nil],
                barres: [],
                tips: ["F#sus4 Triad-1 (auto from Csus4 +6)"]
            ),
            StaticForm(
                id: "F#sus4-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(14), .fret(16), .fret(16), .x, .x],
                fingers: [nil, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["F#sus4 Triad-2 (auto from Csus4 +6)"]
            )
        ]
    ),

    // MARK: - F6 (6)
    StaticChord(
        id: "F6",
        symbol: "F6",
        quality: "6",
        forms: [
            StaticForm(
                id: "F6-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(2), .fret(3), .open, .open, .fret(2)],
                fingers: [nil, .two, .three, nil, nil, .one],
                barres: [],
                tips: ["\"F 6 open (1-x-0-2-1-x)\""]
            ),
            StaticForm(
                id: "F6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(3), .fret(2), .fret(3), .x, .fret(1)],
                fingers: [nil, .four, .two, .three, nil, .one],
                barres: [],
                tips: ["\"F 6 root-6 (x-3-2-3-x-1)\""]
            ),
            StaticForm(
                id: "F6-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(10), .fret(10), .fret(10), .fret(10), .fret(8), .x],
                fingers: [.four, .four, .four, .four, .one, nil],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 4, finger: .four)],
                tips: ["\"F 6 root-5 (10-10-10-10-8-x) barre@10(1-4)\""]
            ),
            StaticForm(
                id: "F6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(1), .fret(3), .fret(2), .fret(3), .x, .x],
                fingers: [.one, .four, .two, .three, nil, nil],
                barres: [],
                tips: ["\"F 6 root-4 (1-3-2-3-x-x)\""]
            )
        ]
    ),

    // MARK: - F7 (7)
    StaticChord(
        id: "F7",
        symbol: "F7",
        quality: "7",
        forms: [
            StaticForm(
                id: "F7-2-Root-5",
                shapeName: "Root-5",
                frets: [.fret(8), .fret(10), .fret(8), .fret(10), .fret(8), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "F7-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(1), .fret(1), .fret(2), .open, .x, .x],
                fingers: [.one, .one, .two, nil, nil, nil],
                barres: [],
                tips: ["\"4th string root | Low position\""]
            )
        ]
    ),

    // MARK: - Fadd9 (add9)
    StaticChord(
        id: "Fadd9",
        symbol: "Fadd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Fadd9-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(12), .fret(10), .fret(12), .fret(13)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"F add9 root-6 (x-x-12-10-12-13)\""]
            ),
            StaticForm(
                id: "Fadd9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(8), .fret(5), .fret(7), .fret(8), .x],
                fingers: [nil, .four, .one, .two, .three, nil],
                barres: [],
                tips: ["\"F add9 root-5 (x-8-5-7-8-x) barre@5(1-5)\""]
            ),
            StaticForm(
                id: "Fadd9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(15), .fret(13), .fret(14), .fret(15), .x, .x],
                fingers: [.four, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"F add9 root-4 (15-13-14-15-x-x)\""]
            )
        ]
    ),

    // MARK: - Faug (aug)
    StaticChord(
        id: "Faug",
        symbol: "Faug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "Faug-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(14), .fret(14), .fret(15), .x, .fret(13)],
                fingers: [nil, .three, .two, .four, nil, .one],
                barres: [],
                tips: ["\"F augmented root-6 (x-14-14-15-x-13)\""]
            ),
            StaticForm(
                id: "Faug-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(8), .fret(7), .fret(6), .fret(6), .x],
                fingers: [nil, .three, .two, .one, .one, nil],
                barres: [StaticBarre(fret: 6, fromString: 2, toString: 3, finger: .three)],
                tips: ["\"F augmented root-5 (x-8-7-6-6-x) barre@6(2-3)\""]
            ),
            StaticForm(
                id: "Faug-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(13), .fret(14), .fret(14), .fret(15), .x, .x],
                fingers: [.one, .two, .three, .four, nil, nil],
                barres: [],
                tips: ["\"F augmented root-4 (13-14-14-15-x-x)\""]
            ),
            StaticForm(
                id: "Faug-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(9), .fret(10), .fret(10), .x, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"F augmented Triad-1 (9-10-10-x-x-x)\""]
            ),
            StaticForm(
                id: "Faug-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(14), .fret(14), .fret(15), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 14, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"F augmented Triad-2 (x-14-14-15-x-x) barre@14(2-3)\""]
            )
        ]
    ),

    // MARK: - Fdim (dim)
    StaticChord(
        id: "Fdim",
        symbol: "Fdim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "Fdim-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(13), .fret(12), .fret(13), .x, .x, .fret(13)],
                fingers: [.four, .one, .three, nil, nil, .two],
                barres: [],
                tips: ["Diminished (auto from Cdim +5)"]
            ),
            StaticForm(
                id: "Fdim-2",
                shapeName: "Root-5",
                frets: [.x, .fret(9), .fret(10), .fret(9), .fret(8), .x],
                fingers: [nil, .three, .four, .two, .one, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +5)"]
            ),
            StaticForm(
                id: "Fdim-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(13), .fret(12), .fret(13), .fret(15), .x, .x],
                fingers: [.three, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +5)"]
            ),
            StaticForm(
                id: "Fdim-4-Triad-1",
                shapeName: "Triad-1",
                frets: [.fret(7), .fret(9), .fret(10), .x, .x, .x],
                fingers: [.one, .three, .four, nil, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +5)"]
            ),
            StaticForm(
                id: "Fdim-5-Triad-2",
                shapeName: "Triad-2",
                frets: [.x, .fret(12), .fret(13), .fret(15), .x, .x],
                fingers: [nil, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +5)"]
            )
        ]
    ),

    // MARK: - Fm (m)
    StaticChord(
        id: "Fm",
        symbol: "Fm",
        quality: "m",
        forms: [
            StaticForm(
                id: "Fm-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(1), .fret(1), .fret(1), .fret(3), .fret(3), .fret(1)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "Fm-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(8), .fret(9), .fret(10), .fret(10), .fret(8)],
                fingers: [nil, nil, .one, .two, .four, .three],
                barres: [],
                tips: ["1"]
            ),
            StaticForm(
                id: "Fm-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(1), .fret(1), .fret(1), .fret(3), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "Fm-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(8), .fret(9), .fret(10), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "Fm-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(1), .fret(1), .fret(3), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - Fm6 (m6)
    StaticChord(
        id: "Fm6",
        symbol: "Fm6",
        quality: "m6",
        forms: [
            StaticForm(
                id: "Fm6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(13), .fret(13), .fret(12), .x, .fret(13)],
                fingers: [nil, .three, .four, .one, nil, .two],
                barres: [],
                tips: ["\"F minor 6 root-6 (x-13-13-12-x-13)\""]
            ),
            StaticForm(
                id: "Fm6-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(8), .fret(9), .fret(7), .x, .fret(8), .x],
                fingers: [.four, .three, .one, nil, .two, nil],
                barres: [],
                tips: ["\"F minor 6 root-5 (8-9-7-x-8-x)\""]
            ),
            StaticForm(
                id: "Fm6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(13), .fret(15), .fret(13), .fret(15), .x, .x],
                fingers: [.one, .four, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 13, fromString: 1, toString: 3, finger: .one)],
                tips: ["\"F minor 6 root-4 (13-15-13-15-x-x) barre@13(1-3)\""]
            )
        ]
    ),

    // MARK: - FM7 (M7)
    StaticChord(
        id: "FM7",
        symbol: "FM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "FM7",
                shapeName: "Open",
                frets: [.open, .fret(2), .fret(3), .fret(4), .fret(4), .open],
                fingers: [.one, .one, .two, .four, .three, .one],
                barres: [],
                tips: ["\"F major 7th | Upper string voicing\""]
            ),
            StaticForm(
                id: "FM7-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(1), .fret(1), .fret(2), .fret(2), .fret(3), .fret(1)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | Maj7 E-shape\""]
            ),
            StaticForm(
                id: "FM7-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(8), .fret(10), .fret(9), .fret(10), .fret(8), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | Maj7 A-shape\""]
            ),
            StaticForm(
                id: "FM7-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(5), .fret(5), .fret(5), .fret(3), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            )
        ]
    ),

    // MARK: - Fm9 (m9)
    StaticChord(
        id: "Fm9",
        symbol: "Fm9",
        quality: "m9",
        forms: [
            StaticForm(
                id: "Fm9-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(9), .fret(11), .fret(9), .open],
                fingers: [nil, nil, .one, .four, .two, nil],
                barres: [],
                tips: ["\"F minor 9 open (x-8-10-8-0-0)\""]
            ),
            StaticForm(
                id: "Fm9-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(13), .fret(11), .fret(11), .fret(11), .fret(13), .fret(11)],
                fingers: [nil, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["\"F minor 9 root-6 (13-11-11-11-13-11) barre@11(1-6)\""]
            ),
            StaticForm(
                id: "Fm9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(20), .fret(20), .fret(18), .fret(20), .x],
                fingers: [nil, .one, .one, .three, .four, nil],
                barres: [StaticBarre(fret: 20, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"F minor 9 root-5 (x-20-20-18-20-x)\""]
            ),
            StaticForm(
                id: "Fm9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(18), .fret(18), .fret(16), .fret(13), .x, .x],
                fingers: [.four, .four, .two, .one, nil, nil],
                barres: [],
                tips: ["\"F minor 9 root-4 (18-18-16-13-x-x)\""]
            )
        ]
    ),

    // MARK: - Fsus2 (sus2)
    StaticChord(
        id: "Fsus2",
        symbol: "Fsus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Fsus2-1-Open",
                shapeName: "Open",
                frets: [.fret(4), .fret(2), .open, .fret(4), .open, .open],
                fingers: [.four, .one, nil, .three, nil, nil],
                barres: [],
                tips: ["\"F sus2 open (x-x-3-0-1-3)\""]
            )
        ]
    ),

    // MARK: - Fsus4 (sus4)
    StaticChord(
        id: "Fsus4",
        symbol: "Fsus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Fsus4-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(8), .fret(10), .fret(10), .fret(10), .fret(8), .fret(8)],
                fingers: [.one, .three, .four, .four, .one, .two],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"F sus4 root-6 (8-10-10-10-8-8)\""]
            ),
            StaticForm(
                id: "Fsus4-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(13), .fret(15), .fret(15), .fret(15), .fret(13), .x],
                fingers: [.one, .three, .four, .four, .one, nil],
                barres: [StaticBarre(fret: 13, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"F sus4 root-5 (13-15-15-15-13-x)\""]
            ),
            StaticForm(
                id: "Fsus4-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(13), .fret(13), .fret(15), .fret(15), .x, .x],
                fingers: [.one, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"F sus4 root-4 (13-13-15-15-x-x)\""]
            ),
            StaticForm(
                id: "Fsus4-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(8), .fret(11), .fret(10), .x, .x, .x],
                fingers: [.one, .four, .three, nil, nil, nil],
                barres: [],
                tips: ["Fsus4 Triad-1 (auto from Csus4 +5)"]
            ),
            StaticForm(
                id: "Fsus4-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(13), .fret(15), .fret(15), .x, .x],
                fingers: [nil, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["Fsus4 Triad-2 (auto from Csus4 +5)"]
            )
        ]
    ),

    // MARK: - G (M)
    StaticChord(
        id: "G",
        symbol: "G",
        quality: "M",
        forms: [
            StaticForm(
                id: "G-1-Open",
                shapeName: "Open",
                frets: [.fret(4), .open, .open, .open, .fret(3), .fret(4)],
                fingers: [.three, nil, nil, nil, .one, .two],
                barres: [],
                tips: []
            ),
            StaticForm(
                id: "G-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(3), .fret(3), .fret(4), .fret(5), .fret(5), .fret(3)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "G-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(10), .fret(12), .fret(12), .fret(12), .fret(10), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "G-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(3), .fret(3), .fret(4), .fret(5), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "G-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(10), .fret(12), .fret(12), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "G-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(3), .fret(4), .fret(5), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - G# (M)
    StaticChord(
        id: "G#",
        symbol: "G#",
        quality: "M",
        forms: [
            StaticForm(
                id: "G#-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(4), .fret(4), .fret(5), .fret(6), .fret(6), .fret(4)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape barre\""]
            ),
            StaticForm(
                id: "G#-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(11), .fret(13), .fret(13), .fret(13), .fret(11), .x],
                fingers: [.one, .three, .four, .two, .one, nil],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | A-shape barre\""]
            ),
            StaticForm(
                id: "G#-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(4), .fret(4), .fret(5), .fret(6), .x, .x],
                fingers: [.one, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "G#-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(11), .fret(13), .fret(13), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "G#-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(4), .fret(5), .fret(6), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - G#7 (7)
    StaticChord(
        id: "G#7",
        symbol: "G#7",
        quality: "7",
        forms: [
            StaticForm(
                id: "G#7-1-Root-6",
                shapeName: "Root-6",
                frets: [.fret(4), .fret(4), .fret(5), .fret(4), .fret(6), .fret(4)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "G#7-2-Root-5",
                shapeName: "Root-5",
                frets: [.fret(11), .fret(13), .fret(11), .fret(13), .fret(11), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "G#7-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(8), .fret(7), .fret(8), .fret(6), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            )
        ]
    ),

    // MARK: - G#add9 (add9)
    StaticChord(
        id: "G#add9",
        symbol: "G#add9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "G#add9-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(15), .fret(13), .fret(15), .fret(16)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"G# add9 root-6 (x-x-15-13-15-16)\""]
            ),
            StaticForm(
                id: "G#add9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(11), .fret(8), .fret(10), .fret(11), .x],
                fingers: [nil, .four, .one, .two, .three, nil],
                barres: [],
                tips: ["\"G# add9 root-5 (x-11-8-10-11-x) barre@8(1-5)\""]
            ),
            StaticForm(
                id: "G#add9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(18), .fret(16), .fret(17), .fret(18), .x, .x],
                fingers: [.four, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"G# add9 root-4 (18-16-17-18-x-x)\""]
            )
        ]
    ),

    // MARK: - G#aug (aug)
    StaticChord(
        id: "G#aug",
        symbol: "G#aug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "G#aug-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(17), .fret(17), .fret(18), .x, .fret(16)],
                fingers: [nil, .three, .two, .four, nil, .one],
                barres: [],
                tips: ["\"G# augmented root-6 (x-17-17-18-x-16)\""]
            ),
            StaticForm(
                id: "G#aug-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(11), .fret(10), .fret(9), .fret(9), .x],
                fingers: [nil, .three, .two, .one, .one, nil],
                barres: [StaticBarre(fret: 9, fromString: 2, toString: 3, finger: .three)],
                tips: ["\"G# augmented root-5 (x-11-10-9-9-x) barre@9(2-3)\""]
            ),
            StaticForm(
                id: "G#aug-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(16), .fret(17), .fret(17), .fret(18), .x, .x],
                fingers: [.one, .two, .three, .four, nil, nil],
                barres: [],
                tips: ["\"G# augmented root-4 (16-17-17-18-x-x)\""]
            ),
            StaticForm(
                id: "G#aug-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(12), .fret(13), .fret(13), .x, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"G# augmented Triad-1 (12-13-13-x-x-x)\""]
            ),
            StaticForm(
                id: "G#aug-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(17), .fret(17), .fret(18), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 17, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"G# augmented Triad-2 (x-17-17-18-x-x) barre@17(2-3)\""]
            )
        ]
    ),

    // MARK: - G#dim (dim)
    StaticChord(
        id: "G#dim",
        symbol: "G#dim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "G#dim-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(16), .fret(15), .fret(16), .x, .x, .fret(16)],
                fingers: [.four, .one, .three, nil, nil, .two],
                barres: [],
                tips: ["Diminished (auto from Cdim +8)"]
            ),
            StaticForm(
                id: "G#dim-2",
                shapeName: "Root-5",
                frets: [.x, .fret(12), .fret(13), .fret(12), .fret(11), .x],
                fingers: [nil, .three, .four, .two, .one, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +8)"]
            ),
            StaticForm(
                id: "G#dim-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(16), .fret(15), .fret(16), .fret(18), .x, .x],
                fingers: [.three, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +8)"]
            ),
            StaticForm(
                id: "G#dim-4-Triad-1",
                shapeName: "Triad-1",
                frets: [.fret(10), .fret(12), .fret(13), .x, .x, .x],
                fingers: [.one, .three, .four, nil, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +8)"]
            ),
            StaticForm(
                id: "G#dim-5-Triad-2",
                shapeName: "Triad-2",
                frets: [.x, .fret(15), .fret(16), .fret(18), .x, .x],
                fingers: [nil, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +8)"]
            )
        ]
    ),

    // MARK: - G#m (m)
    StaticChord(
        id: "G#m",
        symbol: "G#m",
        quality: "m",
        forms: [
            StaticForm(
                id: "G#m-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(4), .fret(4), .fret(4), .fret(6), .fret(6), .fret(4)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "G#m-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(11), .fret(12), .fret(13), .fret(13), .fret(11)],
                fingers: [nil, nil, .one, .two, .four, .three],
                barres: [],
                tips: ["1"]
            ),
            StaticForm(
                id: "G#m-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(4), .fret(4), .fret(4), .fret(6), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "G#m-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(11), .fret(12), .fret(13), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "G#m-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(4), .fret(4), .fret(6), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - G#m7 (m7)
    StaticChord(
        id: "G#m7",
        symbol: "G#m7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "G#m7-1-Root-6",
                shapeName: "Root-6",
                frets: [.fret(4), .fret(4), .fret(4), .fret(4), .fret(6), .fret(4)],
                fingers: [.one, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "G#m7-2-Root-5",
                shapeName: "Root-5",
                frets: [.fret(11), .fret(12), .fret(11), .fret(13), .fret(11), .x],
                fingers: [.one, .two, .one, .three, .one, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "G#m7-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(7), .fret(7), .fret(8), .fret(6), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            )
        ]
    ),

    // MARK: - G#M7 (M7)
    StaticChord(
        id: "G#M7",
        symbol: "G#M7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "G#M7-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(4), .fret(4), .fret(5), .fret(5), .fret(6), .fret(4)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | Maj7 E-shape\""]
            ),
            StaticForm(
                id: "G#M7-2-Root5",
                shapeName: "Root-5",
                frets: [.fret(11), .fret(13), .fret(12), .fret(13), .fret(11), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | Maj7 A-shape\""]
            ),
            StaticForm(
                id: "G#M7-3-Root4",
                shapeName: "Root-4",
                frets: [.fret(8), .fret(8), .fret(8), .fret(6), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            )
        ]
    ),

    // MARK: - G#sus4 (sus4)
    StaticChord(
        id: "G#sus4",
        symbol: "G#sus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "G#sus4-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(11), .fret(13), .fret(13), .fret(13), .fret(11), .fret(11)],
                fingers: [.one, .three, .four, .four, .one, .two],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"G# sus4 root-6 (11-13-13-13-11-11)\""]
            ),
            StaticForm(
                id: "G#sus4-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(16), .fret(18), .fret(18), .fret(18), .fret(16), .x],
                fingers: [.one, .three, .four, .four, .one, nil],
                barres: [StaticBarre(fret: 16, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"G# sus4 root-5 (16-18-18-18-16-x)\""]
            ),
            StaticForm(
                id: "G#sus4-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(16), .fret(16), .fret(18), .fret(18), .x, .x],
                fingers: [.one, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"G# sus4 root-4 (16-16-18-18-x-x)\""]
            ),
            StaticForm(
                id: "G#sus4-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(11), .fret(14), .fret(13), .x, .x, .x],
                fingers: [.one, .four, .three, nil, nil, nil],
                barres: [],
                tips: ["G#sus4 Triad-1 (auto from Csus4 +8)"]
            ),
            StaticForm(
                id: "G#sus4-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(16), .fret(18), .fret(18), .x, .x],
                fingers: [nil, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["G#sus4 Triad-2 (auto from Csus4 +8)"]
            )
        ]
    ),

    // MARK: - G6 (6)
    StaticChord(
        id: "G6",
        symbol: "G6",
        quality: "6",
        forms: [
            StaticForm(
                id: "G6-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .open, .open, .fret(3), .fret(4)],
                fingers: [nil, nil, nil, nil, .two, .three],
                barres: [],
                tips: ["\"G 6 open (0-0-0-0-2-3)\""]
            ),
            StaticForm(
                id: "G6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(5), .fret(4), .fret(5), .x, .fret(3)],
                fingers: [nil, .four, .two, .three, nil, .one],
                barres: [],
                tips: ["\"G 6 root-6 (x-5-4-5-x-3)\""]
            ),
            StaticForm(
                id: "G6-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(12), .fret(12), .fret(12), .fret(12), .fret(10), .x],
                fingers: [.three, .three, .three, .three, .one, nil],
                barres: [StaticBarre(fret: 12, fromString: 1, toString: 4, finger: .three)],
                tips: ["\"G 6 root-5 (12-12-12-12-10-x) barre@12(1-4)\""]
            ),
            StaticForm(
                id: "G6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(3), .fret(5), .fret(4), .fret(5), .x, .x],
                fingers: [.one, .four, .two, .three, nil, nil],
                barres: [],
                tips: ["\"G 6 root-4 (3-5-4-5-x-x)\""]
            )
        ]
    ),

    // MARK: - G7 (7)
    StaticChord(
        id: "G7",
        symbol: "G7",
        quality: "7",
        forms: [
            StaticForm(
                id: "G7-1-Open",
                shapeName: "Open",
                frets: [.fret(2), .open, .open, .open, .fret(3), .fret(4)],
                fingers: [.one, nil, nil, nil, .two, .three],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "G7-2-Root-6",
                shapeName: "Root-6",
                frets: [.fret(3), .fret(3), .fret(4), .fret(3), .fret(5), .fret(3)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "G7-3-Root-5",
                shapeName: "Root-5",
                frets: [.fret(10), .fret(12), .fret(10), .fret(12), .fret(10), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            ),
            StaticForm(
                id: "G7-4-Root-4",
                shapeName: "Root-4",
                frets: [.fret(7), .fret(6), .fret(7), .fret(5), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["Dominant 7th (extracted)"]
            )
        ]
    ),

    // MARK: - Gadd9 (add9)
    StaticChord(
        id: "Gadd9",
        symbol: "Gadd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Gadd9-1-Open",
                shapeName: "Open",
                frets: [.fret(4), .open, .fret(3), .open, .open, .fret(4)],
                fingers: [.four, nil, .one, nil, nil, .two],
                barres: [],
                tips: ["\"G add9 open (3-0-2-0-x-3)\""]
            ),
            StaticForm(
                id: "Gadd9-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .x, .fret(14), .fret(12), .fret(14), .fret(15)],
                fingers: [nil, nil, .three, .one, .two, .four],
                barres: [],
                tips: ["\"G add9 root-6 (x-x-14-12-14-15)\""]
            ),
            StaticForm(
                id: "Gadd9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(10), .fret(7), .fret(9), .fret(10), .x],
                fingers: [nil, .four, .one, .two, .three, nil],
                barres: [],
                tips: ["\"G add9 root-5 (x-10-7-9-10-x) barre@7(1-5)\""]
            ),
            StaticForm(
                id: "Gadd9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(17), .fret(15), .fret(16), .fret(17), .x, .x],
                fingers: [.four, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["\"G add9 root-4 (17-15-16-17-x-x)\""]
            )
        ]
    ),

    // MARK: - Gaug (aug)
    StaticChord(
        id: "Gaug",
        symbol: "Gaug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "Gaug-1-Open",
                shapeName: "Open",
                frets: [.fret(4), .open, .open, .fret(2), .fret(3), .fret(4)],
                fingers: [.four, nil, nil, .one, .three, .two],
                barres: [],
                tips: ["\"G augmented open (3-2-1-0-0-3)\""]
            ),
            StaticForm(
                id: "Gaug-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(16), .fret(16), .fret(17), .x, .fret(15)],
                fingers: [nil, .three, .two, .four, nil, .one],
                barres: [],
                tips: ["\"G augmented root-6 (x-16-16-17-x-15)\""]
            ),
            StaticForm(
                id: "Gaug-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(10), .fret(9), .fret(8), .fret(8), .x],
                fingers: [nil, .three, .two, .one, .one, nil],
                barres: [StaticBarre(fret: 8, fromString: 2, toString: 3, finger: .three)],
                tips: ["\"G augmented root-5 (x-10-9-8-8-x) barre@8(2-3)\""]
            ),
            StaticForm(
                id: "Gaug-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(15), .fret(16), .fret(16), .fret(17), .x, .x],
                fingers: [.one, .two, .three, .four, nil, nil],
                barres: [],
                tips: ["\"G augmented root-4 (15-16-16-17-x-x)\""]
            ),
            StaticForm(
                id: "Gaug-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(11), .fret(12), .fret(12), .x, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["\"G augmented Triad-1 (11-12-12-x-x-x)\""]
            ),
            StaticForm(
                id: "Gaug-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(16), .fret(16), .fret(17), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 16, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"G augmented Triad-2 (x-16-16-17-x-x) barre@16(2-3)\""]
            )
        ]
    ),

    // MARK: - Gdim (dim)
    StaticChord(
        id: "Gdim",
        symbol: "Gdim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "Gdim-1-Root6",
                shapeName: "Root-6",
                frets: [.fret(15), .fret(14), .fret(15), .x, .x, .fret(15)],
                fingers: [.four, .one, .three, nil, nil, .two],
                barres: [],
                tips: ["Diminished (auto from Cdim +7)"]
            ),
            StaticForm(
                id: "Gdim-2",
                shapeName: "Root-5",
                frets: [.x, .fret(11), .fret(12), .fret(11), .fret(10), .x],
                fingers: [nil, .three, .four, .two, .one, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +7)"]
            ),
            StaticForm(
                id: "Gdim-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(15), .fret(14), .fret(15), .fret(17), .x, .x],
                fingers: [.three, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +7)"]
            ),
            StaticForm(
                id: "Gdim-4-Triad-1",
                shapeName: "Triad-1",
                frets: [.fret(9), .fret(11), .fret(12), .x, .x, .x],
                fingers: [.one, .three, .four, nil, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +7)"]
            ),
            StaticForm(
                id: "Gdim-5-Triad-2",
                shapeName: "Triad-2",
                frets: [.x, .fret(14), .fret(15), .fret(17), .x, .x],
                fingers: [nil, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["Diminished (auto from Cdim +7)"]
            )
        ]
    ),

    // MARK: - Gm (m)
    StaticChord(
        id: "Gm",
        symbol: "Gm",
        quality: "m",
        forms: [
            StaticForm(
                id: "Gm-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(3), .fret(3), .fret(3), .fret(5), .fret(5), .fret(3)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | E-shape minor barre\""]
            ),
            StaticForm(
                id: "Gm-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(10), .fret(11), .fret(12), .fret(12), .fret(10)],
                fingers: [nil, nil, .one, .two, .four, .three],
                barres: [],
                tips: ["1"]
            ),
            StaticForm(
                id: "Gm-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(3), .fret(3), .fret(3), .fret(5), .x, .x],
                fingers: [.one, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            ),
            StaticForm(
                id: "Gm-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(10), .fret(11), .fret(12), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-1)"]
            ),
            StaticForm(
                id: "Gm-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(3), .fret(3), .fret(5), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Triad extracted from iOS (Triad-2)"]
            )
        ]
    ),

    // MARK: - Gm6 (m6)
    StaticChord(
        id: "Gm6",
        symbol: "Gm6",
        quality: "m6",
        forms: [
            StaticForm(
                id: "Gm6-1-Open",
                shapeName: "Open",
                frets: [.open, .fret(4), .open, .open, .fret(2), .fret(4)],
                fingers: [nil, .three, nil, nil, .one, .two],
                barres: [],
                tips: ["\"G minor 6 open (3-1-0-0-3-0 pattern)\""]
            ),
            StaticForm(
                id: "Gm6-2-Root6",
                shapeName: "Root-6",
                frets: [.x, .fret(15), .fret(15), .fret(14), .x, .fret(15)],
                fingers: [nil, .three, .four, .one, nil, .two],
                barres: [],
                tips: ["\"G minor 6 root-6 (x-15-15-14-x-15)\""]
            ),
            StaticForm(
                id: "Gm6-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(10), .fret(11), .fret(9), .x, .fret(10), .x],
                fingers: [.four, .three, .one, nil, .two, nil],
                barres: [],
                tips: ["\"G minor 6 root-5 (10-11-9-x-10-x)\""]
            ),
            StaticForm(
                id: "Gm6-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(15), .fret(17), .fret(15), .fret(17), .x, .x],
                fingers: [.one, .four, .one, .three, nil, nil],
                barres: [StaticBarre(fret: 15, fromString: 1, toString: 3, finger: .one)],
                tips: ["\"G minor 6 root-4 (15-17-15-17-x-x) barre@15(1-3)\""]
            )
        ]
    ),

    // MARK: - Gm7 (m7)
    StaticChord(
        id: "Gm7",
        symbol: "Gm7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "Gm7-1-Root-6",
                shapeName: "Root-6",
                frets: [.fret(3), .fret(3), .fret(3), .fret(3), .fret(5), .fret(3)],
                fingers: [.one, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "Gm7-2-Root-5",
                shapeName: "Root-5",
                frets: [.fret(10), .fret(11), .fret(10), .fret(12), .fret(10), .x],
                fingers: [.one, .two, .one, .three, .one, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            ),
            StaticForm(
                id: "Gm7-3-Root-4",
                shapeName: "Root-4",
                frets: [.fret(6), .fret(6), .fret(7), .fret(5), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["Minor 7th (extracted)"]
            )
        ]
    ),

    // MARK: - GM7 (M7)
    StaticChord(
        id: "GM7",
        symbol: "GM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "GM7-1-Open",
                shapeName: "Open",
                frets: [.fret(3), .open, .open, .open, .fret(3), .fret(4)],
                fingers: [.one, nil, nil, nil, .two, .three],
                barres: [],
                tips: ["\"Gmaj7 open | Bright voicing\""]
            ),
            StaticForm(
                id: "GM7-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(3), .fret(3), .fret(4), .fret(4), .fret(5), .fret(3)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"6th string root | Maj7 E-shape\""]
            ),
            StaticForm(
                id: "GM7-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(10), .fret(12), .fret(11), .fret(12), .fret(10), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"5th string root | Maj7 A-shape\""]
            ),
            StaticForm(
                id: "GM7-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(7), .fret(7), .fret(7), .fret(5), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["\"4th string root | High position\""]
            )
        ]
    ),

    // MARK: - Gm9 (m9)
    StaticChord(
        id: "Gm9",
        symbol: "Gm9",
        quality: "m9",
        forms: [
            StaticForm(
                id: "Gm9-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .fret(11), .fret(13), .fret(11), .open],
                fingers: [nil, nil, .one, .four, .two, nil],
                barres: [],
                tips: ["\"G minor 9 open (x-10-12-10-0-0)\""]
            ),
            StaticForm(
                id: "Gm9-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(15), .fret(13), .fret(13), .fret(13), .fret(15), .fret(13)],
                fingers: [nil, .one, .one, .one, .three, .one],
                barres: [],
                tips: ["\"G minor 9 root-6 (15-13-13-13-15-13) barre@13(1-6)\""]
            ),
            StaticForm(
                id: "Gm9-3-Root5",
                shapeName: "Root-5",
                frets: [.x, .fret(22), .fret(22), .fret(20), .fret(22), .x],
                fingers: [nil, .one, .one, .three, .four, nil],
                barres: [StaticBarre(fret: 22, fromString: 2, toString: 3, finger: .one)],
                tips: ["\"G minor 9 root-5 (x-22-22-20-22-x)\""]
            ),
            StaticForm(
                id: "Gm9-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(20), .fret(20), .fret(18), .fret(15), .x, .x],
                fingers: [.four, .four, .two, .one, nil, nil],
                barres: [],
                tips: ["\"G minor 9 root-4 (20-20-18-15-x-x)\""]
            )
        ]
    ),

    // MARK: - Gsus2 (sus2)
    StaticChord(
        id: "Gsus2",
        symbol: "Gsus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Gsus2-1-Open",
                shapeName: "Open",
                frets: [.fret(4), .fret(4), .fret(3), .open, .open, .fret(4)],
                fingers: [.four, .three, .one, nil, nil, .two],
                barres: [],
                tips: ["\"G sus2 open (3-x-0-2-3-3)\""]
            )
        ]
    ),

    // MARK: - Gsus4 (sus4)
    StaticChord(
        id: "Gsus4",
        symbol: "Gsus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Gsus4-1-Open",
                shapeName: "Open",
                frets: [.fret(4), .fret(2), .open, .open, .fret(4), .fret(4)],
                fingers: [.four, .one, nil, nil, .three, .two],
                barres: [],
                tips: ["\"G sus4 open (3-1-0-0-3-3)\""]
            ),
            StaticForm(
                id: "Gsus4-2-Root6",
                shapeName: "Root-6",
                frets: [.fret(10), .fret(12), .fret(12), .fret(12), .fret(10), .fret(10)],
                fingers: [.one, .three, .four, .four, .one, .two],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 6, finger: .one)],
                tips: ["\"G sus4 root-6 (10-12-12-12-10-10)\""]
            ),
            StaticForm(
                id: "Gsus4-3-Root5",
                shapeName: "Root-5",
                frets: [.fret(15), .fret(17), .fret(17), .fret(17), .fret(15), .x],
                fingers: [.one, .three, .four, .four, .one, nil],
                barres: [StaticBarre(fret: 15, fromString: 1, toString: 5, finger: .one)],
                tips: ["\"G sus4 root-5 (15-17-17-17-15-x)\""]
            ),
            StaticForm(
                id: "Gsus4-4-Root4",
                shapeName: "Root-4",
                frets: [.fret(15), .fret(15), .fret(17), .fret(17), .x, .x],
                fingers: [.one, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["\"G sus4 root-4 (15-15-17-17-x-x)\""]
            ),
            StaticForm(
                id: "Gsus4-5-Triad1",
                shapeName: "Triad-1",
                frets: [.fret(10), .fret(13), .fret(12), .x, .x, .x],
                fingers: [.one, .four, .three, nil, nil, nil],
                barres: [],
                tips: ["Gsus4 Triad-1 (auto from Csus4 +7)"]
            ),
            StaticForm(
                id: "Gsus4-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .fret(15), .fret(17), .fret(17), .x, .x],
                fingers: [nil, .one, .three, .four, nil, nil],
                barres: [],
                tips: ["Gsus4 Triad-2 (auto from Csus4 +7)"]
            )
        ]
    )

];
