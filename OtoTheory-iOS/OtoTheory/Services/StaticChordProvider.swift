//
//  StaticChordProvider.swift
//  OtoTheory
//
//  Static Chord Data Provider (v0)
//  Source: docs/content/GuitarChordList-1.pdf
//  All forms manually transcribed from the PDF
//

import Foundation

@MainActor
class StaticChordProvider: ObservableObject {
    static let shared = StaticChordProvider()
    
    private init() {}
    
    /// All static chords from attached chart
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
            "aug": "aug"       // Augmented
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

// MARK: - Static Chord Data (from PDF)

/// All chord forms from GuitarChordList-1.pdf
/// NOTE: Values must be manually transcribed from the PDF
let STATIC_CHORDS: [StaticChord] = [
    
    // MARK: - sus4 Chords
    
    // Esus4 (Open): 022200
    StaticChord(
        id: "Esus4",
        symbol: "Esus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Esus4-1",
                shapeName: nil,
                frets: [.open, .open, F(2), F(2), F(2), .open],  // 1→6: E-B-E-A-B-E
                fingers: [nil, nil, .two, .three, .four, nil],
                barres: [],
                tips: ["Open-string rich sus4 sound", "All strings played"]
            )
        ]
    ),
    
    // C#m7
    StaticChord(
        id: "C#m7",
        symbol: "C#m7",
        quality: "m7",
        forms: [
            // Open: x42000 (1→6 = 0,0,0,1,2,x)
            StaticForm(
                id: "C#m7-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .open, F(1), F(2), .x],
                fingers: [nil, nil, nil, .one, .two, nil],
                barres: [],
                tips: ["Open C#m7", "Light shimmer"]
            ),
            // Root-6 (9fr): 9-9-9-9-11-9
            StaticForm(
                id: "C#m7-2-Root6",
                shapeName: "Root-6",
                frets: [F(9), F(9), F(9), F(9), F(11), F(9)],
                fingers: [.one, .one, .one, .one, .three, .one],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "m7 E-shape full barre"]
            ),
            // Root-5 (4fr): 4-5-4-6-4-x
            StaticForm(
                id: "C#m7-3-Root5",
                shapeName: "Root-5",
                frets: [F(4), F(5), F(4), F(6), F(4), .x],
                fingers: [.one, .two, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Standard m7 A-shape"]
            ),
            // Root-4 (9-12fr): 12-12-12-9-x-x
            StaticForm(
                id: "C#m7-4-Root4",
                shapeName: "Root-4",
                frets: [F(12), F(12), F(12), F(9), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            )
        ]
    ),
    // G#M7
    StaticChord(
        id: "G#M7",
        symbol: "G#M7",
        quality: "M7",
        forms: [
            // Root-6 (4fr): 4-4-5-5-6-4
            StaticForm(
                id: "G#M7-1-Root6",
                shapeName: "Root-6",
                frets: [F(4), F(4), F(5), F(5), F(6), F(4)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Maj7 E-shape"]
            ),
            // Root-5 (11fr): 11-13-12-13-11-x
            StaticForm(
                id: "G#M7-2-Root5",
                shapeName: "Root-5",
                frets: [F(11), F(13), F(12), F(13), F(11), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Maj7 A-shape"]
            ),
            // Root-4 (5-8fr): 8-8-8-5-x-x
            StaticForm(
                id: "G#M7-3-Root4",
                shapeName: "Root-4",
                frets: [F(8), F(8), F(8), F(5), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            )
        ]
    ),
    // G#7 (Dominant 7th)
    StaticChord(
        id: "G#7",
        symbol: "G#7",
        quality: "7",
        forms: [
            // Root-6 (4fr): 4-4-5-4-6-4
            StaticForm(
                id: "G#7-1-Root6",
                shapeName: "Root-6",
                frets: [F(4), F(4), F(5), F(4), F(6), F(4)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root E-shape", "b7 on 4th, 5th at 6fr"]
            ),
            // Root-5 (11fr): 11-13-11-13-11-x
            StaticForm(
                id: "G#7-2-Root5",
                shapeName: "Root-5",
                frets: [F(11), F(13), F(11), F(13), F(11), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Standard barre"]
            ),
            // Root-4 (6-8fr): 8-7-8-6-x-x
            StaticForm(
                id: "G#7-3-Root4",
                shapeName: "Root-4",
                frets: [F(8), F(7), F(8), F(6), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Compact voicing"]
            )
        ]
    ),
    
    // D#7 (Dominant 7th)
    StaticChord(
        id: "D#7",
        symbol: "D#7",
        quality: "7",
        forms: [
            // Root-6 (11fr): 11-11-12-11-13-11
            StaticForm(
                id: "D#7-1-Root6",
                shapeName: "Root-6",
                frets: [F(11), F(11), F(12), F(11), F(13), F(11)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root E-shape", "b7 on 4th, 5th at 13fr"]
            ),
            // Root-5 (6fr): 6-8-6-8-6-x
            StaticForm(
                id: "D#7-2-Root5",
                shapeName: "Root-5",
                frets: [F(6), F(8), F(6), F(8), F(6), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Barre 1-3-5 strings"]
            ),
            // Root-4 (1-3fr): 3-2-3-1-x-x
            StaticForm(
                id: "D#7-3-Root4",
                shapeName: "Root-4",
                frets: [F(3), F(2), F(3), F(1), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Low position"]
            )
        ]
    ),
    
    // F#7 (Dominant 7th)
    StaticChord(
        id: "F#7",
        symbol: "F#7",
        quality: "7",
        forms: [
            // Open: 0-2-3-4-x-x (upper 4 strings)
            StaticForm(
                id: "F#7-1-Open",
                shapeName: "Open",
                frets: [.open, F(2), F(3), F(4), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Upper strings only", "Bright voicing"]
            ),
            // Root-6 (2fr): 2-2-3-2-4-2
            StaticForm(
                id: "F#7-2-Root6",
                shapeName: "Root-6",
                frets: [F(2), F(2), F(3), F(2), F(4), F(2)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root E-shape", "b7 on 4th, 5th at 4fr"]
            ),
            // Root-5 (9fr): 9-11-9-11-9-x
            StaticForm(
                id: "F#7-3-Root5",
                shapeName: "Root-5",
                frets: [F(9), F(11), F(9), F(11), F(9), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Standard barre"]
            ),
            // Root-4 (4-6fr): 6-5-6-4-x-x
            StaticForm(
                id: "F#7-4-Root4",
                shapeName: "Root-4",
                frets: [F(6), F(5), F(6), F(4), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Compact voicing"]
            )
        ]
    ),
    
    // F#M7
    StaticChord(
        id: "F#M7",
        symbol: "F#M7",
        quality: "M7",
        forms: [
            // Root-6 (2fr): 2-2-3-3-4-2
            StaticForm(
                id: "F#M7-1-Root6",
                shapeName: "Root-6",
                frets: [F(2), F(2), F(3), F(3), F(4), F(2)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Maj7 E-shape"]
            ),
            // Root-5 (9fr): 9-11-10-11-9-x
            StaticForm(
                id: "F#M7-2-Root5",
                shapeName: "Root-5",
                frets: [F(9), F(11), F(10), F(11), F(9), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Maj7 A-shape"]
            ),
            // Root-4 (3-6fr): 6-6-6-3-x-x
            StaticForm(
                id: "F#M7-3-Root4",
                shapeName: "Root-4",
                frets: [F(6), F(6), F(6), F(3), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            )
        ]
    ),
    
    // Asus4 (Open): x02230
    StaticChord(
        id: "Asus4",
        symbol: "Asus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Asus4-1",
                shapeName: nil,
                frets: [.open, F(3), F(2), F(2), .open, .x],  // 1→6: E-D-A-D-A-x
                fingers: [nil, .four, .two, .three, nil, nil],
                barres: [],
                tips: ["Classic A sus4 open", "Mute 6th string"]
            )
        ]
    ),
    
    // Dsus4 (Open): xx0233
    StaticChord(
        id: "Dsus4",
        symbol: "Dsus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Dsus4-1",
                shapeName: nil,
                frets: [F(3), F(3), F(2), .open, .x, .x],  // 1→6: G-G-D-D-x-x
                fingers: [.three, .four, .two, nil, nil, nil],
                barres: [],
                tips: ["Open D sus4", "Mute 5th and 6th strings"]
            )
        ]
    ),
    
    // Gsus4 (Open): 330013
    StaticChord(
        id: "Gsus4",
        symbol: "Gsus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Gsus4-1",
                shapeName: nil,
                frets: [F(3), F(1), .open, .open, .x, F(3)],  // 1→6
                fingers: [.three, .one, nil, nil, nil, .four],
                barres: [],
                tips: ["Folk-style G sus4", "Bright open sound"]
            )
        ]
    ),
    
    // Csus4 (Open): x33011
    StaticChord(
        id: "Csus4",
        symbol: "Csus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Csus4-1",
                shapeName: nil,
                frets: [F(1), F(1), .open, F(3), F(3), .x],  // 1→6
                fingers: [.one, .one, nil, .three, .four, nil],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 2, finger: .one)],
                tips: ["C sus4 open", "Partial barre on 1st fret"]
            )
        ]
    ),
    
    // MARK: - sus2 Chords
    
    // Esus2 (Open): 024400
    StaticChord(
        id: "Esus2",
        symbol: "Esus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Esus2-1",
                shapeName: nil,
                frets: [.open, .open, F(4), F(4), F(2), .open],  // 1→6
                fingers: [nil, nil, .three, .four, .one, nil],
                barres: [],
                tips: ["Wide E sus2 voicing", "Open strings"]
            )
        ]
    ),
    
    // Asus2 (Open): x02200
    StaticChord(
        id: "Asus2",
        symbol: "Asus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Asus2-1",
                shapeName: nil,
                frets: [.open, .open, F(2), F(2), .open, .x],  // 1→6
                fingers: [nil, nil, .one, .two, nil, nil],
                barres: [],
                tips: ["Classic A sus2", "Open 1st, 2nd, 5th strings"]
            )
        ]
    ),
    
    // Dsus2 (Open): xx0230
    StaticChord(
        id: "Dsus2",
        symbol: "Dsus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Dsus2-1",
                shapeName: nil,
                frets: [.open, F(3), F(2), .open, .x, .x],  // 1→6
                fingers: [nil, .two, .one, nil, nil, nil],
                barres: [],
                tips: ["Bright D sus2", "Open 1st and 4th strings"]
            )
        ]
    ),
    
    // MARK: - add9 Chords
    
    // Cadd9 (Open): x32033
    StaticChord(
        id: "Cadd9",
        symbol: "Cadd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Cadd9-1",
                shapeName: nil,
                frets: [F(3), F(3), .open, F(2), F(3), .x],  // 1→6
                fingers: [.three, .four, nil, .one, .two, nil],
                barres: [],
                tips: ["Rich C major with 9th", "Popular open voicing"]
            )
        ]
    ),
    
    // Dadd9 (Open): xx0230 (same as Dsus2 fingering but different context)
    StaticChord(
        id: "Dadd9",
        symbol: "Dadd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Dadd9-1",
                shapeName: nil,
                frets: [.open, F(3), F(2), .open, .x, .x],  // 1→6
                fingers: [nil, .two, .one, nil, nil, nil],
                barres: [],
                tips: ["D major with 9th", "Open 1st string = E (9th)"]
            )
        ]
    ),
    
    // Eadd9 (Open): 024100
    StaticChord(
        id: "Eadd9",
        symbol: "Eadd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Eadd9-1",
                shapeName: nil,
                frets: [.open, .open, F(1), F(4), F(2), .open],  // 1→6
                fingers: [nil, nil, .one, .four, .two, nil],
                barres: [],
                tips: ["E major with 9th", "4th string = F# (9th)"]
            )
        ]
    ),
    
    // MARK: - 7 (Dominant 7th) Chords
    
    
    // G7 (Open): 320001
    StaticChord(
        id: "G7",
        symbol: "G7",
        quality: "7",
        forms: [
            StaticForm(
                id: "G7-1-Open",
                shapeName: "Open",
                frets: [F(1), .open, .open, .open, F(2), F(3)],  // 1→6
                fingers: [.one, nil, nil, nil, .two, .three],
                barres: [],
                tips: ["G7 open", "Full, ringing sound"]
            ),
            // Root-6 (3fr): 3-3-4-3-5-3
            StaticForm(
                id: "G7-2-Root6",
                shapeName: "Root-6",
                frets: [F(3), F(3), F(4), F(3), F(5), F(3)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root E-shape", "b7 on 4th, 5th at 5fr"]
            ),
            // Root-5 (10fr): 10-12-10-12-10-x
            StaticForm(
                id: "G7-3-Root5",
                shapeName: "Root-5",
                frets: [F(10), F(12), F(10), F(12), F(10), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Standard barre"]
            ),
            // Root-4 (5-7fr): 7-6-7-5-x-x
            StaticForm(
                id: "G7-4-Root4",
                shapeName: "Root-4",
                frets: [F(7), F(6), F(7), F(5), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Compact voicing"]
            )
        ]
    ),
    
    // A7
    StaticChord(
        id: "A7",
        symbol: "A7",
        quality: "7",
        forms: [
            // Open: x02020
            StaticForm(
                id: "A7-1-Open",
                shapeName: "Open",
                frets: [.open, F(2), .open, F(2), .open, .x],  // 1→6
                fingers: [nil, .three, nil, .two, nil, nil],
                barres: [],
                tips: ["A7 open", "Ring on 2nd, Middle on 4th"]
            ),
            // Root-6 (5fr): 5-5-6-5-7-5
            StaticForm(
                id: "A7-2-Root6",
                shapeName: "Root-6",
                frets: [F(5), F(5), F(6), F(5), F(7), F(5)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root E-shape", "b7 on 4th, 5th at 7fr"]
            ),
            // Root-5 (10fr): 10-12-10-12-10-x
            StaticForm(
                id: "A7-3-Root5",
                shapeName: "Root-5",
                frets: [F(10), F(12), F(10), F(12), F(10), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Standard barre"]
            ),
            // Root-4 (7-9fr): 9-8-9-7-x-x
            StaticForm(
                id: "A7-4-Root4",
                shapeName: "Root-4",
                frets: [F(9), F(8), F(9), F(7), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Compact voicing"]
            )
        ]
    ),
    
    // Bb7 (A#7 enharmonic) - three forms
    StaticChord(
        id: "Bb7",
        symbol: "Bb7",
        quality: "7",
        forms: [
            // Root-6 (6fr): 6-6-7-6-8-6
            StaticForm(
                id: "Bb7-1-Root6",
                shapeName: "Root-6",
                frets: [F(6), F(6), F(7), F(6), F(8), F(6)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root E-shape", "A#7 enharmonic"]
            ),
            // Root-5 (1fr): 1-3-1-3-1-x
            StaticForm(
                id: "Bb7-2-Root5",
                shapeName: "Root-5",
                frets: [F(1), F(3), F(1), F(3), F(1), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Barre at 1fr"]
            ),
            // Root-4 (6-8fr): 8-7-8-6-x-x
            StaticForm(
                id: "Bb7-3-Root4",
                shapeName: "Root-4",
                frets: [F(8), F(7), F(8), F(6), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Compact voicing"]
            )
        ]
    ),

    // BbM7 (A#M7 enharmonic)
    StaticChord(
        id: "BbM7",
        symbol: "BbM7",
        quality: "M7",
        forms: [
            // Root-6 (1fr): 1-1-2-2-3-1
            StaticForm(
                id: "BbM7-1-Root6",
                shapeName: "Root-6",
                frets: [F(1), F(1), F(2), F(2), F(3), F(1)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["A#maj7 enharmonic", "Maj7 E-shape"]
            ),
            // Root-5 (6fr): 6-8-7-8-6-x
            StaticForm(
                id: "BbM7-2-Root5",
                shapeName: "Root-5",
                frets: [F(6), F(8), F(7), F(8), F(6), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Maj7 A-shape"]
            ),
            // Root-4 (7-10fr): 10-10-10-7-x-x
            StaticForm(
                id: "BbM7-3-Root4",
                shapeName: "Root-4",
                frets: [F(10), F(10), F(10), F(7), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            )
        ]
    ),

    // B7
    StaticChord(
        id: "B7",
        symbol: "B7",
        quality: "7",
        forms: [
            // Open: x21202
            StaticForm(
                id: "B7-1-Open",
                shapeName: "Open",
                frets: [F(2), .open, F(2), F(1), F(2), .x],  // 1→6
                fingers: [.three, nil, .two, .one, .four, nil],
                barres: [],
                tips: ["B7 open", "Ring on 1st, Middle on 3rd"]
            ),
            // Root-6 (7fr): 7-7-8-7-9-7
            StaticForm(
                id: "B7-2-Root6",
                shapeName: "Root-6",
                frets: [F(7), F(7), F(8), F(7), F(9), F(7)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root E-shape", "b7 on 4th, 5th at 9fr"]
            ),
            // Root-5 (9fr): 9-11-9-11-9-x
            StaticForm(
                id: "B7-3-Root5",
                shapeName: "Root-5",
                frets: [F(9), F(11), F(9), F(11), F(9), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Standard barre"]
            ),
            // Root-4 (9-11fr): 11-10-11-9-x-x
            StaticForm(
                id: "B7-4-Root4",
                shapeName: "Root-4",
                frets: [F(11), F(10), F(11), F(9), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Compact voicing"]
            )
        ]
    ),
    
    // BM7
    StaticChord(
        id: "BM7",
        symbol: "BM7",
        quality: "M7",
        forms: [
            // Root-6 (7fr): 7-7-8-8-9-7
            StaticForm(
                id: "BM7-1-Root6",
                shapeName: "Root-6",
                frets: [F(7), F(7), F(8), F(8), F(9), F(7)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Maj7 E-shape"]
            ),
            // Root-5 (2fr): 2-4-3-4-2-x
            StaticForm(
                id: "BM7-2-Root5",
                shapeName: "Root-5",
                frets: [F(2), F(4), F(3), F(4), F(2), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Maj7 A-shape"]
            ),
            // Root-4 (8-11fr): 11-11-11-8-x-x
            StaticForm(
                id: "BM7-3-Root4",
                shapeName: "Root-4",
                frets: [F(11), F(11), F(11), F(8), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            )
        ]
    ),
    
    // MARK: - M7 (Major 7th) Chords
    
    // CM7: Multiple forms
    StaticChord(
        id: "CM7",
        symbol: "CM7",
        quality: "M7",
        forms: [
            // Open form
            StaticForm(
                id: "CM7-1",
                shapeName: nil,
                frets: [.open, .open, .open, F(2), F(3), .x],  // 1→6: x32000
                fingers: [nil, nil, nil, .two, .three, nil],
                barres: [],
                tips: ["Rich C major 7th", "Open strings"]
            ),
            // Root-5 Barre (3fr)
            StaticForm(
                id: "CM7-2",
                shapeName: nil,
                frets: [F(3), F(5), F(4), F(5), F(3), .x],  // 1→6: x35453
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 5, finger: .one)],
                tips: ["Barre form", "5th string root"]
            ),
            // Root-6 Barre (8fr)
            StaticForm(
                id: "CM7-3",
                shapeName: nil,
                frets: [F(8), F(8), F(9), F(9), F(10), F(8)],  // 1→6: 8 8 9 9 10 8
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 6, finger: .one)],
                tips: ["Full barre", "2nd&3rd strings at 8/9"]
            ),
            // Root-4 (12fr): 12-12-12-9-x-x
            StaticForm(
                id: "CM7-4",
                shapeName: nil,
                frets: [F(12), F(12), F(12), F(9), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            )
        ]
    ),
    
    // C#M7
    StaticChord(
        id: "C#M7",
        symbol: "C#M7",
        quality: "M7",
        forms: [
            // Root-6 (9fr): 9-9-10-10-11-9
            StaticForm(
                id: "C#M7-1-Root6",
                shapeName: "Root-6",
                frets: [F(9), F(9), F(10), F(10), F(11), F(9)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Maj7 shape"]
            ),
            // Root-5 (4fr): 4-6-5-6-4-x
            StaticForm(
                id: "C#M7-2-Root5",
                shapeName: "Root-5",
                frets: [F(4), F(6), F(5), F(6), F(4), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Barre"]
            ),
            // Root-4 (10-13fr): 13-13-13-10-x-x
            StaticForm(
                id: "C#M7-3-Root4",
                shapeName: "Root-4",
                frets: [F(13), F(13), F(13), F(10), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            )
        ]
    ),
    
    // DM7 (Open): xx0222
    StaticChord(
        id: "DM7",
        symbol: "DM7",
        quality: "M7",
        forms: [
            // Root-6 (10fr): 10-10-11-11-12-10
            StaticForm(
                id: "DM7-1-Root6",
                shapeName: "Root-6",
                frets: [F(10), F(10), F(11), F(11), F(12), F(10)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Maj7 shape"]
            ),
            // Root-5 (5fr): 5-7-6-7-5-x
            StaticForm(
                id: "DM7-2-Root5",
                shapeName: "Root-5",
                frets: [F(5), F(7), F(6), F(7), F(5), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Barre"]
            ),
            // Root-4 (11-14fr): 14-14-14-11-x-x
            StaticForm(
                id: "DM7-3-Root4",
                shapeName: "Root-4",
                frets: [F(14), F(14), F(14), F(11), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            )
        ]
    ),

    // D#M7
    StaticChord(
        id: "D#M7",
        symbol: "D#M7",
        quality: "M7",
        forms: [
            // Root-4: 3-1-2-1-x-x
            StaticForm(
                id: "D#M7-1-Root4",
                shapeName: "Root-4",
                frets: [F(3), F(1), F(2), F(1), .x, .x],
                fingers: [.three, .one, .two, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Compact voicing"]
            ),
            // Root-5 (6fr): 6-8-7-8-6-x
            StaticForm(
                id: "D#M7-2-Root5",
                shapeName: "Root-5",
                frets: [F(6), F(8), F(7), F(8), F(6), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Maj7 A-shape"]
            ),
            // Root-6 (11fr): 11-11-12-12-13-11
            StaticForm(
                id: "D#M7-3-Root6",
                shapeName: "Root-6",
                frets: [F(11), F(11), F(12), F(12), F(13), F(11)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Maj7 E-shape"]
            )
        ]
    ),
    
    // EM7 (Open): 021100
    StaticChord(
        id: "EM7",
        symbol: "EM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "EM7-1",
                shapeName: nil,
                frets: [.open, .open, F(1), F(1), F(2), .open],  // 1→6
                fingers: [nil, nil, .one, .two, .three, nil],
                barres: [],
                tips: ["E major 7th", "Beautiful open voicing"]
            ),
            // Root-4 small: 4-0-0-2-x-x
            StaticForm(
                id: "EM7-2-Root4Small",
                shapeName: "Root-4",
                frets: [F(4), .open, .open, F(2), .x, .x],
                fingers: [.three, nil, nil, .one, nil, nil],
                barres: [],
                tips: ["Compact 4th-string root", "Open-string shimmer"]
            ),
            // Root-5 (7fr): 7-9-8-9-7-x
            StaticForm(
                id: "EM7-3-Root5",
                shapeName: "Root-5",
                frets: [F(7), F(9), F(8), F(9), F(7), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Maj7 voicing"]
            ),
            // Root-6 (11fr): 11-11-12-12-13-11
            StaticForm(
                id: "EM7-4-Root6",
                shapeName: "Root-6",
                frets: [F(11), F(11), F(12), F(12), F(13), F(11)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root E-shape", "Full barre"]
            )
        ]
    ),
    
    // GM7
    StaticChord(
        id: "GM7",
        symbol: "GM7",
        quality: "M7",
        forms: [
            // Open: 200023
            StaticForm(
                id: "GM7-1-Open",
                shapeName: "Open",
                frets: [F(2), .open, .open, .open, F(2), F(3)],
                fingers: [.one, nil, nil, nil, .two, .three],
                barres: [],
                tips: ["Gmaj7 open", "Bright voicing"]
            ),
            // Root-6 (3fr): 3-3-4-4-5-3
            StaticForm(
                id: "GM7-2-Root6",
                shapeName: "Root-6",
                frets: [F(3), F(3), F(4), F(4), F(5), F(3)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Maj7 E-shape"]
            ),
            // Root-5 (10fr): 10-12-11-12-10-x
            StaticForm(
                id: "GM7-3-Root5",
                shapeName: "Root-5",
                frets: [F(10), F(12), F(11), F(12), F(10), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Maj7 A-shape"]
            ),
            // Root-4 (4-7fr): 7-7-7-4-x-x
            StaticForm(
                id: "GM7-4-Root4",
                shapeName: "Root-4",
                frets: [F(7), F(7), F(7), F(4), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            )
        ]
    ),
    
    // AM7
    StaticChord(
        id: "AM7",
        symbol: "AM7",
        quality: "M7",
        forms: [
            // Open: x02120
            StaticForm(
                id: "AM7-1-Open",
                shapeName: "Open",
                frets: [.open, F(2), F(1), F(2), .open, .x],
                fingers: [nil, .three, .one, .two, nil, nil],
                barres: [],
                tips: ["Amaj7 open", "Mellow sound"]
            ),
            // Root-6 (5fr): 5-5-6-6-7-5
            StaticForm(
                id: "AM7-2-Root6",
                shapeName: "Root-6",
                frets: [F(5), F(5), F(6), F(6), F(7), F(5)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Maj7 E-shape"]
            ),
            // Root-5 (9fr): 9-11-10-11-9-x
            StaticForm(
                id: "AM7-3-Root5",
                shapeName: "Root-5",
                frets: [F(9), F(11), F(10), F(11), F(9), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Maj7 A-shape"]
            ),
            // Root-4 (6-9fr): 9-9-9-6-x-x
            StaticForm(
                id: "AM7-4-Root4",
                shapeName: "Root-4",
                frets: [F(9), F(9), F(9), F(6), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            )
        ]
    ),
    
    // MARK: - m7 (Minor 7th) Chords
    
    // Dm7 (Open): xx0211
    StaticChord(
        id: "Dm7",
        symbol: "Dm7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "Dm7-1",
                shapeName: nil,
                frets: [F(1), F(1), F(2), .open, .x, .x],  // 1→6
                fingers: [.one, .one, .two, nil, nil, nil],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 2, finger: .one)],
                tips: ["D minor 7th", "Compact and easy"]
            )
        ]
    ),
    
    // Em7 (Open): 020000
    StaticChord(
        id: "Em7",
        symbol: "Em7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "Em7-1",
                shapeName: nil,
                frets: [.open, .open, .open, .open, F(2), .open],  // 1→6
                fingers: [nil, nil, nil, nil, .one, nil],
                barres: [],
                tips: ["E minor 7th", "Beautiful open sound"]
            )
        ]
    ),
    
    // Am7 (Open): x02010
    StaticChord(
        id: "Am7",
        symbol: "Am7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "Am7-1",
                shapeName: nil,
                frets: [.open, F(1), .open, F(2), .open, .x],  // 1→6
                fingers: [nil, .one, nil, .two, nil, nil],
                barres: [],
                tips: ["A minor 7th", "Melancholic sound"]
            )
        ]
    ),
    
    // MARK: - Major Chords
    
    // C Major (Open + Barre forms)
    StaticChord(
        id: "C",
        symbol: "C",
        quality: "",
        forms: [
            // Open form (x32010)
            StaticForm(
                id: "C-1-Open",
                shapeName: "Open",
                frets: [.open, F(1), .open, F(2), F(3), .x],
                fingers: [nil, .one, nil, .two, .three, nil],
                barres: [],
                tips: ["With open strings", "Easy and popular"]
            ),
            // Root-6 (8fr) - Full barre
            StaticForm(
                id: "C-2-Root6",
                shapeName: "Root-6",
                frets: [F(8), F(8), F(9), F(10), F(10), F(8)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (3fr) - 5th string barre
            StaticForm(
                id: "C-3-Root5",
                shapeName: "Root-5",
                frets: [F(3), F(5), F(5), F(5), F(3), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Middle position"]
            ),
            // Root-4 (10fr) - 4th string root
            StaticForm(
                id: "C-4-Root4",
                shapeName: "Root-4",
                frets: [F(12), .x, F(12), F(10), .x, .x],
                fingers: [.three, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "C-5-Triad1",
                shapeName: "Triad-1",
                frets: [F(3), F(5), F(5), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Bright sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "C-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(8), F(9), F(10), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Step pattern"]
            )
        ]
    ),
    
    // C# Major (Barre forms)
    StaticChord(
        id: "C#",
        symbol: "C#",
        quality: "",
        forms: [
            // Root-6 (9fr) - Full barre
            StaticForm(
                id: "C#-1-Root6",
                shapeName: "Root-6",
                frets: [F(9), F(9), F(10), F(11), F(11), F(9)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (4fr) - 5th string barre
            StaticForm(
                id: "C#-2-Root5",
                shapeName: "Root-5",
                frets: [F(4), F(6), F(6), F(6), F(4), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Middle position"]
            ),
            // Root-4 (11fr) - 4th string root
            StaticForm(
                id: "C#-3-Root4",
                shapeName: "Root-4",
                frets: [F(13), .x, F(13), F(11), .x, .x],
                fingers: [.three, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "C#-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(4), F(6), F(6), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Bright sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "C#-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(9), F(10), F(11), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Step pattern"]
            )
        ]
    ),
    
    // D Major (Open + Barre forms)
    StaticChord(
        id: "D",
        symbol: "D",
        quality: "",
        forms: [
            // Open form (xx0232)
            StaticForm(
                id: "D-1-Open",
                shapeName: "Open",
                frets: [F(2), F(3), F(2), .open, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["With open strings", "Easy and popular"]
            ),
            // Root-6 (10fr) - Full barre
            StaticForm(
                id: "D-2-Root6",
                shapeName: "Root-6",
                frets: [F(10), F(10), F(11), F(12), F(12), F(10)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (5fr) - 5th string barre
            StaticForm(
                id: "D-3-Root5",
                shapeName: "Root-5",
                frets: [F(5), F(7), F(7), F(7), F(5), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Middle position"]
            ),
            // Root-4 (12fr) - 4th string root
            StaticForm(
                id: "D-4-Root4",
                shapeName: "Root-4",
                frets: [F(14), .x, F(14), F(12), .x, .x],
                fingers: [.three, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "D-5-Triad1",
                shapeName: "Triad-1",
                frets: [F(5), F(7), F(7), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Bright sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "D-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(10), F(11), F(12), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Step pattern"]
            )
        ]
    ),
    
    // D# Major (Barre forms)
    StaticChord(
        id: "D#",
        symbol: "D#",
        quality: "",
        forms: [
            // Root-6 (11fr) - Full barre
            StaticForm(
                id: "D#-1-Root6",
                shapeName: "Root-6",
                frets: [F(11), F(11), F(12), F(13), F(13), F(11)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (6fr) - 5th string barre
            StaticForm(
                id: "D#-2-Root5",
                shapeName: "Root-5",
                frets: [F(6), F(8), F(8), F(8), F(6), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Middle position"]
            ),
            // Root-4 (1fr) - 4th string root
            StaticForm(
                id: "D#-3-Root4",
                shapeName: "Root-4",
                frets: [F(3), .x, F(3), F(1), .x, .x],
                fingers: [.three, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Low position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "D#-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(6), F(8), F(8), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Bright sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "D#-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(11), F(12), F(13), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Step pattern"]
            )
        ]
    ),
    
    
    // MARK: - minor Chords
    
    // C minor (6 forms with Open)
    StaticChord(
        id: "Cm",
        symbol: "Cm",
        quality: "m",
        forms: [
            // Open form (x10130)
            StaticForm(
                id: "Cm-1-Open",
                shapeName: "Open",
                frets: [.x, F(1), .open, F(1), F(3), .x],
                fingers: [nil, .one, nil, .one, .three, nil],
                barres: [],
                tips: ["With open strings", "Low position"]
            ),
            // Root-6 (8fr) - Full barre
            StaticForm(
                id: "Cm-2-Root6",
                shapeName: "Root-6",
                frets: [F(8), F(8), F(8), F(10), F(10), F(8)],
                fingers: [.one, .one, .one, .two, .two, .one],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (3fr) - 5th string barre
            StaticForm(
                id: "Cm-3-Root5",
                shapeName: "Root-5",
                frets: [F(3), F(4), F(5), F(5), F(3), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Standard form"]
            ),
            // Root-4 (10fr) - 4th string root
            StaticForm(
                id: "Cm-4-Root4",
                shapeName: "Root-4",
                frets: [F(11), .x, F(12), F(10), .x, .x],
                fingers: [.two, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "Cm-5-Triad1",
                shapeName: "Triad-1",
                frets: [F(3), F(4), F(5), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Melancholic sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "Cm-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(8), F(8), F(10), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Same fret on 2+3"]
            )
        ]
    ),
    
    // C# minor (5 forms - no open)
    StaticChord(
        id: "C#m",
        symbol: "C#m",
        quality: "m",
        forms: [
            // Root-6 (9fr) - Full barre
            StaticForm(
                id: "C#m-1-Root6",
                shapeName: "Root-6",
                frets: [F(9), F(9), F(9), F(11), F(11), F(9)],
                fingers: [.one, .one, .one, .two, .two, .one],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (4fr) - 5th string barre
            StaticForm(
                id: "C#m-2-Root5",
                shapeName: "Root-5",
                frets: [F(4), F(5), F(6), F(6), F(4), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Standard form"]
            ),
            // Root-4 (11fr) - 4th string root
            StaticForm(
                id: "C#m-3-Root4",
                shapeName: "Root-4",
                frets: [F(12), .x, F(13), F(11), .x, .x],
                fingers: [.two, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "C#m-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(4), F(5), F(6), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Melancholic sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "C#m-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(9), F(9), F(11), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Same fret on 2+3"]
            )
        ]
    ),
    
    // D minor (Open + Barre forms)
    StaticChord(
        id: "Dm",
        symbol: "Dm",
        quality: "m",
        forms: [
            // Open form (xx0231)
            StaticForm(
                id: "Dm-1-Open",
                shapeName: "Open",
                frets: [F(1), F(3), F(2), .open, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["With open strings", "Low position"]
            ),
            // Root-6 (10fr) - Full barre
            StaticForm(
                id: "Dm-2-Root6",
                shapeName: "Root-6",
                frets: [F(10), F(10), F(10), F(12), F(12), F(10)],
                fingers: [.one, .one, .one, .two, .two, .one],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (5fr) - 5th string barre
            StaticForm(
                id: "Dm-3-Root5",
                shapeName: "Root-5",
                frets: [F(5), F(6), F(7), F(7), F(5), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Middle position"]
            ),
            // Root-4 (12fr) - 4th string root
            StaticForm(
                id: "Dm-4-Root4",
                shapeName: "Root-4",
                frets: [F(13), .x, F(14), F(12), .x, .x],
                fingers: [.two, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "Dm-5-Triad1",
                shapeName: "Triad-1",
                frets: [F(5), F(6), F(7), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Melancholic sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "Dm-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(10), F(10), F(12), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Same fret on 2+3"]
            )
        ]
    ),
    
    // D# minor (5 forms)
    StaticChord(
        id: "D#m",
        symbol: "D#m",
        quality: "m",
        forms: [
            // Root-6 (11fr) - Full barre
            StaticForm(
                id: "D#m-1-Root6",
                shapeName: "Root-6",
                frets: [F(11), F(11), F(11), F(13), F(13), F(11)],
                fingers: [.one, .one, .one, .two, .two, .one],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (6fr) - 5th string barre
            StaticForm(
                id: "D#m-2-Root5",
                shapeName: "Root-5",
                frets: [F(6), F(7), F(8), F(8), F(6), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Middle position"]
            ),
            // Root-4 (1fr) - 4th string root
            StaticForm(
                id: "D#m-3-Root4",
                shapeName: "Root-4",
                frets: [F(2), .x, F(3), F(1), .x, .x],
                fingers: [.two, nil, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Low position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "D#m-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(6), F(7), F(8), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Melancholic sound"]
            ),
            // Triad2 (3-5弦)
            StaticForm(
                id: "D#m-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, .x, F(3), F(4), F(6), .x],
                fingers: [nil, nil, .one, .two, .four, nil],
                barres: [],
                tips: ["Strings 3-5", "Low position"]
            )
        ]
    ),
    
    // E minor (Open + Barre forms)
    StaticChord(
        id: "Em",
        symbol: "Em",
        quality: "m",
        forms: [
            // Open form (022000)
            StaticForm(
                id: "Em-1-Open",
                shapeName: "Open",
                frets: [.open, .open, .open, F(2), F(2), .open],
                fingers: [nil, nil, nil, .one, .two, nil],
                barres: [],
                tips: ["With open strings", "Easy and popular"]
            ),
            // Root-6 (12fr) - Full barre
            StaticForm(
                id: "Em-2-Root6",
                shapeName: "Root-6",
                frets: [F(12), F(12), F(12), F(14), F(14), F(12)],
                fingers: [.one, .one, .one, .two, .two, .one],
                barres: [StaticBarre(fret: 12, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (7fr) - 5th string barre
            StaticForm(
                id: "Em-3-Root5",
                shapeName: "Root-5",
                frets: [F(7), F(8), F(9), F(9), F(7), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Middle position"]
            ),
            // Root-4 (14fr) - 4th string root
            StaticForm(
                id: "Em-4-Root4",
                shapeName: "Root-4",
                frets: [F(15), .x, F(16), F(14), .x, .x],
                fingers: [.two, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "Em-5-Triad1",
                shapeName: "Triad-1",
                frets: [F(7), F(8), F(9), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Melancholic sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "Em-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(12), F(12), F(14), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Same fret on 2+3"]
            )
        ]
    ),
    
    // E Major (Open + Barre forms)
    StaticChord(
        id: "E",
        symbol: "E",
        quality: "",
        forms: [
            // Open form (021100)
            StaticForm(
                id: "E-1-Open",
                shapeName: "Open",
                frets: [.open, .open, F(1), F(2), F(2), .open],
                fingers: [nil, nil, .one, .two, .three, nil],
                barres: [],
                tips: ["With open strings", "Easy and popular"]
            ),
            // Root-6 (12fr) - Full barre
            StaticForm(
                id: "E-2-Root6",
                shapeName: "Root-6",
                frets: [F(12), F(12), F(13), F(14), F(14), F(12)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 12, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (7fr) - 5th string barre
            StaticForm(
                id: "E-3-Root5",
                shapeName: "Root-5",
                frets: [F(7), F(9), F(9), F(9), F(7), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Middle position"]
            ),
            // Root-4 (14fr) - 4th string root
            StaticForm(
                id: "E-4-Root4",
                shapeName: "Root-4",
                frets: [F(16), .x, F(16), F(14), .x, .x],
                fingers: [.three, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "E-5-Triad1",
                shapeName: "Triad-1",
                frets: [F(7), F(9), F(9), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Bright sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "E-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(12), F(13), F(14), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Step pattern"]
            )
        ]
    ),
    
    // F minor (Barre forms)
    StaticChord(
        id: "Fm",
        symbol: "Fm",
        quality: "m",
        forms: [
            // Root-6 (1fr) - Full barre
            StaticForm(
                id: "Fm-1-Root6",
                shapeName: "Root-6",
                frets: [F(1), F(1), F(1), F(3), F(3), F(1)],
                fingers: [.one, .one, .one, .two, .two, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (8fr) - 5th string barre
            StaticForm(
                id: "Fm-2-Root5",
                shapeName: "Root-5",
                frets: [F(8), F(9), F(10), F(10), F(8), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Middle position"]
            ),
            // Root-4 (3fr) - 4th string root
            StaticForm(
                id: "Fm-3-Root4",
                shapeName: "Root-4",
                frets: [F(4), .x, F(5), F(3), .x, .x],
                fingers: [.two, nil, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Low position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "Fm-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(8), F(9), F(10), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Melancholic sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "Fm-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(1), F(1), F(3), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Same fret on 2+3"]
            )
        ]
    ),
    
    // F Major (Barre forms)
    StaticChord(
        id: "F",
        symbol: "F",
        quality: "",
        forms: [
            // Root-6 (1fr) - Full barre
            StaticForm(
                id: "F-1-Root6",
                shapeName: "Root-6",
                frets: [F(1), F(1), F(2), F(3), F(3), F(1)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (8fr) - 5th string barre
            StaticForm(
                id: "F-2-Root5",
                shapeName: "Root-5",
                frets: [F(8), F(10), F(10), F(10), F(8), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Middle position"]
            ),
            // Root-4 (3fr) - 4th string root
            StaticForm(
                id: "F-3-Root4",
                shapeName: "Root-4",
                frets: [F(5), .x, F(5), F(3), .x, .x],
                fingers: [.three, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Low position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "F-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(8), F(10), F(10), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Bright sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "F-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(1), F(2), F(3), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Step pattern"]
            )
        ]
    ),
    
    // F# minor (Barre forms)
    StaticChord(
        id: "F#m",
        symbol: "F#m",
        quality: "m",
        forms: [
            // Root-6 (2fr) - Full barre
            StaticForm(
                id: "F#m-1-Root6",
                shapeName: "Root-6",
                frets: [F(2), F(2), F(2), F(4), F(4), F(2)],
                fingers: [.one, .one, .one, .two, .two, .one],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (9fr) - 5th string barre
            StaticForm(
                id: "F#m-2-Root5",
                shapeName: "Root-5",
                frets: [F(9), F(10), F(11), F(11), F(9), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Middle position"]
            ),
            // Root-4 (4fr) - 4th string root
            StaticForm(
                id: "F#m-3-Root4",
                shapeName: "Root-4",
                frets: [F(5), .x, F(6), F(4), .x, .x],
                fingers: [.two, nil, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Low position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "F#m-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(9), F(10), F(11), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Melancholic sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "F#m-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(2), F(2), F(4), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Same fret on 2+3"]
            )
        ]
    ),
    
    // F# Major (Barre forms)
    StaticChord(
        id: "F#",
        symbol: "F#",
        quality: "",
        forms: [
            // Root-6 (2fr) - Full barre
            StaticForm(
                id: "F#-1-Root6",
                shapeName: "Root-6",
                frets: [F(2), F(2), F(3), F(4), F(4), F(2)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (9fr) - 5th string barre
            StaticForm(
                id: "F#-2-Root5",
                shapeName: "Root-5",
                frets: [F(9), F(11), F(11), F(11), F(9), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Middle position"]
            ),
            // Root-4 (4fr) - 4th string root
            StaticForm(
                id: "F#-3-Root4",
                shapeName: "Root-4",
                frets: [F(6), .x, F(6), F(4), .x, .x],
                fingers: [.three, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Low position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "F#-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(9), F(11), F(11), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Bright sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "F#-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(2), F(3), F(4), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Step pattern"]
            )
        ]
    ),
    
    // G minor (Barre forms)
    StaticChord(
        id: "Gm",
        symbol: "Gm",
        quality: "m",
        forms: [
            // Root-6 (3fr) - Full barre
            StaticForm(
                id: "Gm-1-Root6",
                shapeName: "Root-6",
                frets: [F(3), F(3), F(3), F(5), F(5), F(3)],
                fingers: [.one, .one, .one, .two, .two, .one],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (10fr) - 5th string barre
            StaticForm(
                id: "Gm-2-Root5",
                shapeName: "Root-5",
                frets: [F(10), F(11), F(12), F(12), F(10), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "High position"]
            ),
            // Root-4 (5fr) - 4th string root
            StaticForm(
                id: "Gm-3-Root4",
                shapeName: "Root-4",
                frets: [F(6), .x, F(7), F(5), .x, .x],
                fingers: [.two, nil, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Middle position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "Gm-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(10), F(11), F(12), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Melancholic sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "Gm-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(3), F(3), F(5), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Same fret on 2+3"]
            )
        ]
    ),
    
    // G Major (Open + Barre forms)
    StaticChord(
        id: "G",
        symbol: "G",
        quality: "",
        forms: [
            // Open form (320003)
            StaticForm(
                id: "G-1-Open",
                shapeName: "Open",
                frets: [F(3), .open, .open, .open, F(2), F(3)],
                fingers: [.three, nil, nil, nil, .one, .two],
                barres: [],
                tips: ["With open strings", "Easy and popular"]
            ),
            // Root-6 (3fr) - Full barre
            StaticForm(
                id: "G-2-Root6",
                shapeName: "Root-6",
                frets: [F(3), F(3), F(4), F(5), F(5), F(3)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (10fr) - 5th string barre
            StaticForm(
                id: "G-3-Root5",
                shapeName: "Root-5",
                frets: [F(10), F(12), F(12), F(12), F(10), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "High position"]
            ),
            // Root-4 (5fr) - 4th string root
            StaticForm(
                id: "G-4-Root4",
                shapeName: "Root-4",
                frets: [F(7), .x, F(7), F(5), .x, .x],
                fingers: [.three, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Middle position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "G-5-Triad1",
                shapeName: "Triad-1",
                frets: [F(10), F(12), F(12), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Bright sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "G-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(3), F(4), F(5), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Step pattern"]
            )
        ]
    ),
    
    // G# minor (Barre forms)
    StaticChord(
        id: "G#m",
        symbol: "G#m",
        quality: "m",
        forms: [
            // Root-6 (4fr) - Full barre
            StaticForm(
                id: "G#m-1-Root6",
                shapeName: "Root-6",
                frets: [F(4), F(4), F(4), F(6), F(6), F(4)],
                fingers: [.one, .one, .one, .two, .two, .one],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (11fr) - 5th string barre
            StaticForm(
                id: "G#m-2-Root5",
                shapeName: "Root-5",
                frets: [F(11), F(12), F(13), F(13), F(11), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "High position"]
            ),
            // Root-4 (6fr) - 4th string root
            StaticForm(
                id: "G#m-3-Root4",
                shapeName: "Root-4",
                frets: [F(7), .x, F(8), F(6), .x, .x],
                fingers: [.two, nil, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Middle position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "G#m-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(11), F(12), F(13), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Melancholic sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "G#m-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(4), F(4), F(6), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Same fret on 2+3"]
            )
        ]
    ),
    
    // G# Major (Barre forms)
    StaticChord(
        id: "G#",
        symbol: "G#",
        quality: "",
        forms: [
            // Root-6 (4fr) - Full barre
            StaticForm(
                id: "G#-1-Root6",
                shapeName: "Root-6",
                frets: [F(4), F(4), F(5), F(6), F(6), F(4)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (11fr) - 5th string barre
            StaticForm(
                id: "G#-2-Root5",
                shapeName: "Root-5",
                frets: [F(11), F(13), F(13), F(13), F(11), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 11, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "High position"]
            ),
            // Root-4 (6fr) - 4th string root
            StaticForm(
                id: "G#-3-Root4",
                shapeName: "Root-4",
                frets: [F(8), .x, F(8), F(6), .x, .x],
                fingers: [.three, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Middle position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "G#-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(11), F(13), F(13), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Bright sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "G#-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(4), F(5), F(6), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Step pattern"]
            )
        ]
    ),
    
    // A minor (Open + Barre forms)
    StaticChord(
        id: "Am",
        symbol: "Am",
        quality: "m",
        forms: [
            // Open form (x02210)
            StaticForm(
                id: "Am-1-Open",
                shapeName: "Open",
                frets: [.open, F(1), F(2), F(2), .open, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["With open strings", "Common chord"]
            ),
            // Root-6 (5fr) - Full barre
            StaticForm(
                id: "Am-2-Root6",
                shapeName: "Root-6",
                frets: [F(5), F(5), F(5), F(7), F(7), F(5)],
                fingers: [.one, .one, .one, .two, .two, .one],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (12fr) - 5th string barre
            StaticForm(
                id: "Am-3-Root5",
                shapeName: "Root-5",
                frets: [F(12), F(13), F(14), F(14), F(12), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 12, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "High position"]
            ),
            // Root-4 (7fr) - 4th string root
            StaticForm(
                id: "Am-4-Root4",
                shapeName: "Root-4",
                frets: [F(8), .x, F(9), F(7), .x, .x],
                fingers: [.two, nil, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Middle position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "Am-5-Triad1",
                shapeName: "Triad-1",
                frets: [F(12), F(13), F(14), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Melancholic sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "Am-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(5), F(5), F(7), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Same fret on 2+3"]
            )
        ]
    ),
    
    // A Major (Open + Barre forms)
    StaticChord(
        id: "A",
        symbol: "A",
        quality: "",
        forms: [
            // Open form (x02220)
            StaticForm(
                id: "A-1-Open",
                shapeName: "Open",
                frets: [.open, .open, F(2), F(2), F(2), .x],
                fingers: [nil, nil, .one, .two, .three, nil],
                barres: [],
                tips: ["With open strings", "Easy and popular"]
            ),
            // Root-6 (5fr) - Full barre
            StaticForm(
                id: "A-2-Root6",
                shapeName: "Root-6",
                frets: [F(5), F(5), F(6), F(7), F(7), F(5)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (12fr) - 5th string barre
            StaticForm(
                id: "A-3-Root5",
                shapeName: "Root-5",
                frets: [F(12), F(14), F(14), F(14), F(12), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 12, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "High position"]
            ),
            // Root-4 (7fr) - 4th string root
            StaticForm(
                id: "A-4-Root4",
                shapeName: "Root-4",
                frets: [F(9), .x, F(9), F(7), .x, .x],
                fingers: [.three, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Middle position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "A-5-Triad1",
                shapeName: "Triad-1",
                frets: [F(12), F(14), F(14), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Bright sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "A-6-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(5), F(6), F(7), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Step pattern"]
            )
        ]
    ),
    
    // Bb minor (Barre forms)
    StaticChord(
        id: "Bbm",
        symbol: "Bbm",
        quality: "m",
        forms: [
            // Root-6 (6fr) - Full barre
            StaticForm(
                id: "Bbm-1-Root6",
                shapeName: "Root-6",
                frets: [F(6), F(6), F(6), F(8), F(8), F(6)],
                fingers: [.one, .one, .one, .two, .two, .one],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (1fr) - 5th string barre
            StaticForm(
                id: "Bbm-2-Root5",
                shapeName: "Root-5",
                frets: [F(1), F(2), F(3), F(3), F(1), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Low position"]
            ),
            // Root-4 (8fr) - 4th string root
            StaticForm(
                id: "Bbm-3-Root4",
                shapeName: "Root-4",
                frets: [F(9), .x, F(10), F(8), .x, .x],
                fingers: [.two, nil, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Middle position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "Bbm-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(1), F(2), F(3), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Melancholic sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "Bbm-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(6), F(6), F(8), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Same fret on 2+3"]
            )
        ]
    ),
    
    // Bb Major (Barre forms)
    StaticChord(
        id: "Bb",
        symbol: "Bb",
        quality: "",
        forms: [
            // Root-6 (6fr) - Full barre
            StaticForm(
                id: "Bb-1-Root6",
                shapeName: "Root-6",
                frets: [F(6), F(6), F(7), F(8), F(8), F(6)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 6, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (1fr) - 5th string barre
            StaticForm(
                id: "Bb-2-Root5",
                shapeName: "Root-5",
                frets: [F(1), F(3), F(3), F(3), F(1), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Low position"]
            ),
            // Root-4 (8fr) - 4th string root
            StaticForm(
                id: "Bb-3-Root4",
                shapeName: "Root-4",
                frets: [F(10), .x, F(10), F(8), .x, .x],
                fingers: [.three, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Middle position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "Bb-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(1), F(3), F(3), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Bright sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "Bb-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(6), F(7), F(8), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Step pattern"]
            )
        ]
    ),
    
    // B minor (Barre forms)
    StaticChord(
        id: "Bm",
        symbol: "Bm",
        quality: "m",
        forms: [
            // Root-6 (7fr) - Full barre
            StaticForm(
                id: "Bm-1-Root6",
                shapeName: "Root-6",
                frets: [F(7), F(7), F(7), F(9), F(9), F(7)],
                fingers: [.one, .one, .one, .two, .two, .one],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (2fr) - 5th string barre
            StaticForm(
                id: "Bm-2-Root5",
                shapeName: "Root-5",
                frets: [F(2), F(3), F(4), F(4), F(2), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Low position"]
            ),
            // Root-4 (9fr) - 4th string root
            StaticForm(
                id: "Bm-3-Root4",
                shapeName: "Root-4",
                frets: [F(10), .x, F(11), F(9), .x, .x],
                fingers: [.two, nil, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "Bm-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(2), F(3), F(4), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Melancholic sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "Bm-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(7), F(7), F(9), .x, .x],
                fingers: [nil, .one, .one, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Same fret on 2+3"]
            )
        ]
    ),
    
    // B Major (Barre forms)
    StaticChord(
        id: "B",
        symbol: "B",
        quality: "",
        forms: [
            // Root-6 (7fr) - Full barre
            StaticForm(
                id: "B-1-Root6",
                shapeName: "Root-6",
                frets: [F(7), F(7), F(8), F(9), F(9), F(7)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Full barre"]
            ),
            // Root-5 (2fr) - 5th string barre
            StaticForm(
                id: "B-2-Root5",
                shapeName: "Root-5",
                frets: [F(2), F(4), F(4), F(4), F(2), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Low position"]
            ),
            // Root-4 (9fr) - 4th string root
            StaticForm(
                id: "B-3-Root4",
                shapeName: "Root-4",
                frets: [F(11), .x, F(11), F(9), .x, .x],
                fingers: [.three, nil, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            ),
            // Triad1 (1-3弦)
            StaticForm(
                id: "B-4-Triad1",
                shapeName: "Triad-1",
                frets: [F(2), F(4), F(4), .x, .x, .x],
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["Strings 1-3 only", "Bright sound"]
            ),
            // Triad2 (2-4弦)
            StaticForm(
                id: "B-5-Triad2",
                shapeName: "Triad-2",
                frets: [.x, F(7), F(8), F(9), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Strings 2-4", "Step pattern"]
            )
        ]
    ),
    
    // MARK: - 7th Chords
    
    // C7 (Dominant 7th)
    StaticChord(
        id: "C7",
        symbol: "C7",
        quality: "7",
        forms: [
            // Open form: x32310
            StaticForm(
                id: "C7-1-Open",
                shapeName: "Open",
                frets: [.open, F(1), F(3), F(2), F(3), .x],
                fingers: [nil, .one, .three, .two, .four, nil],
                barres: [],
                tips: ["Classic C7 open", "3rd string is b7"]
            ),
            // Root-6 (8fr): 8-8-9-8-10-8 (Full barre per provided diagram)
            StaticForm(
                id: "C7-2-Root6",
                shapeName: "Root-6",
                frets: [F(8), F(8), F(9), F(8), F(10), F(8)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root E-shape", "4th string at 8fr, 5th at 10fr"]
            ),
            // Root-5 (3fr): 3-5-3-5-3-x
            StaticForm(
                id: "C7-3-Root5",
                shapeName: "Root-5",
                frets: [F(3), F(5), F(3), F(5), F(3), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Barre 1-3-5 strings"]
            ),
            // Root-4 (10fr): 12-11-x-10-x-x
            StaticForm(
                id: "C7-4-Root4",
                shapeName: "Root-4",
                frets: [F(12), F(11), F(12), F(10), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Add 3rd on 3rd string"]
            )
        ]
    ),
    
    // D7 (Dominant 7th)
    StaticChord(
        id: "D7",
        symbol: "D7",
        quality: "7",
        forms: [
            // Open form: xx0212
            StaticForm(
                id: "D7-1-Open",
                shapeName: "Open",
                frets: [F(2), F(1), F(2), .open, .x, .x],
                fingers: [.three, .one, .two, nil, nil, nil],
                barres: [],
                tips: ["Classic D7 open", "4th string open D"]
            ),
            // Root-6 (10fr): 10-10-11-12-10-10 (Full barre)
            StaticForm(
                id: "D7-2-Root6",
                shapeName: "Root-6",
                frets: [F(10), F(10), F(11), F(10), F(12), F(10)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [StaticBarre(fret: 10, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root E-shape", "4th=10fr(b7), 5th=12fr(5th)"]
            ),
            // Root-5 (5fr): 5-7-5-7-5-x
            StaticForm(
                id: "D7-3-Root5",
                shapeName: "Root-5",
                frets: [F(5), F(7), F(5), F(7), F(5), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 5, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Barre 1-3-5 strings"]
            ),
            // Root-4 (9-11fr): 10-10-11-9-x-x
            StaticForm(
                id: "D7-4-Root4",
                shapeName: "Root-4",
                frets: [F(13), F(11), F(12), F(10), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position 10-13fr"]
            )
        ]
    ),
    
    // E7 (Dominant 7th)
    StaticChord(
        id: "E7",
        symbol: "E7",
        quality: "7",
        forms: [
            // Open form: 020100
            StaticForm(
                id: "E7-1-Open",
                shapeName: "Open",
                frets: [.open, .open, F(1), .open, F(2), .open],
                fingers: [nil, nil, .one, nil, .two, nil],
                barres: [],
                tips: ["Classic E7 open", "All 6 strings"]
            ),
            // Root-6 (12fr): 12-12-13-12-14-12 (Full barre per spec)
            StaticForm(
                id: "E7-2-Root6",
                shapeName: "Root-6",
                frets: [F(12), F(12), F(13), F(12), F(14), F(12)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [StaticBarre(fret: 12, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root E-shape", "4th=12fr(b7), 5th=14fr(5th)"]
            ),
            // Root-5 (7fr): 7-9-7-9-7-x
            StaticForm(
                id: "E7-3-Root5",
                shapeName: "Root-5",
                frets: [F(7), F(9), F(7), F(9), F(7), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 7, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Barre 1-3-5 strings"]
            ),
            // Root-4 (1-3fr): 3-1-2-0-x-x
            StaticForm(
                id: "E7-4-Root4",
                shapeName: "Root-4",
                frets: [F(3), F(1), F(2), .open, .x, .x],
                fingers: [.three, .one, .two, nil, nil, nil],
                barres: [],
                tips: ["4th string root", "Low open voicing (G on 1st string)"]
            )
        ]
    ),
    
    // C#7 (Dominant 7th)
    StaticChord(
        id: "C#7",
        symbol: "C#7",
        quality: "7",
        forms: [
            // Root-6 (9fr): 9-9-10-9-11-9
            StaticForm(
                id: "C#7-1-Root6",
                shapeName: "Root-6",
                frets: [F(9), F(9), F(10), F(9), F(11), F(9)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [StaticBarre(fret: 9, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root E-shape", "b7 on 4th, 5th at 11fr"]
            ),
            // Root-5 (4fr): 4-6-4-6-4-x
            StaticForm(
                id: "C#7-2-Root5",
                shapeName: "Root-5",
                frets: [F(4), F(6), F(4), F(6), F(4), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 4, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Barre 1-3-5 strings"]
            ),
            // Root-4 (8-10fr): 9-9-10-8-x-x
            StaticForm(
                id: "C#7-3-Root4",
                shapeName: "Root-4",
                frets: [F(13), F(12), F(13), F(11), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position 11-13fr"]
            )
        ]
    ),
    
    // MARK: - dim Chords
    
    // Cdim (6th string root): x3424x
    StaticChord(
        id: "Cdim",
        symbol: "Cdim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "Cdim-1",
                shapeName: nil,
                frets: [.x, F(4), F(2), F(4), F(2), .x],
                fingers: [nil, .three, .one, .four, .two, nil],
                barres: [],
                tips: ["Anxious spice", "Insert for one beat as a bridge"]
            ),
            StaticForm(
                id: "Cdim-2",
                shapeName: nil,
                frets: [F(3), .x, F(4), .x, F(3), .x],
                fingers: [.one, nil, .three, nil, .two, nil],
                barres: [],
                tips: ["Compact dim voicing", "Sparse fingering"]
            )
        ]
    ),
    
    // Ddim
    StaticChord(
        id: "Ddim",
        symbol: "Ddim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "Ddim-1",
                shapeName: nil,
                frets: [.x, F(6), F(4), F(6), F(4), .x],
                fingers: [nil, .three, .one, .four, .two, nil],
                barres: [],
                tips: ["D diminished", "Higher position"]
            )
        ]
    ),
    
    // Edim
    StaticChord(
        id: "Edim",
        symbol: "Edim",
        quality: "dim",
        forms: [
            StaticForm(
                id: "Edim-1",
                shapeName: nil,
                frets: [.x, F(1), .open, F(1), .open, .x],
                fingers: [nil, .one, nil, .two, nil, nil],
                barres: [],
                tips: ["E diminished open", "Low position"]
            )
        ]
    ),
    
    // MARK: - dim7 Chords
    
    // Cdim7: x3424x alternative
    StaticChord(
        id: "Cdim7",
        symbol: "Cdim7",
        quality: "dim7",
        forms: [
            StaticForm(
                id: "Cdim7-1",
                shapeName: nil,
                frets: [.x, F(4), F(2), F(3), F(2), .x],
                fingers: [nil, .four, .one, .three, .two, nil],
                barres: [],
                tips: ["Symmetric tension", "Move by m3 for sequences"]
            ),
            StaticForm(
                id: "Cdim7-2",
                shapeName: nil,
                frets: [F(3), .x, F(4), F(3), F(4), .x],
                fingers: [.one, nil, .two, .one, .three, nil],
                barres: [],
                tips: ["Chromatic leading", "5th string root area"]
            )
        ]
    ),
    
    // Ddim7
    StaticChord(
        id: "Ddim7",
        symbol: "Ddim7",
        quality: "dim7",
        forms: [
            StaticForm(
                id: "Ddim7-1",
                shapeName: nil,
                frets: [.x, F(6), F(4), F(5), F(4), .x],
                fingers: [nil, .four, .one, .three, .two, nil],
                barres: [],
                tips: ["D dim7", "Symmetrical structure"]
            )
        ]
    ),
    
    // Edim7: xx2323
    StaticChord(
        id: "Edim7",
        symbol: "Edim7",
        quality: "dim7",
        forms: [
            StaticForm(
                id: "Edim7-1",
                shapeName: nil,
                frets: [F(3), F(2), F(3), F(2), .x, .x],
                fingers: [.two, .one, .three, .one, nil, nil],
                barres: [],
                tips: ["E dim7", "Upper string voicing"]
            )
        ]
    ),
    
    // MARK: - m7-5 (Half-diminished) Chords
    
    // Cm7-5 (Barre): x3434x
    StaticChord(
        id: "Cm7-5",
        symbol: "Cm7-5",
        quality: "m7-5",
        forms: [
            StaticForm(
                id: "Cm7-5-1",
                shapeName: nil,
                frets: [.x, F(4), F(3), F(4), F(3), .x],
                fingers: [nil, .two, .one, .three, .one, nil],
                barres: [],
                tips: ["Half-diminished", "Jazz voicing"]
            )
        ]
    ),
    
    // Dm7-5: xx0111
    StaticChord(
        id: "Dm7-5",
        symbol: "Dm7-5",
        quality: "m7-5",
        forms: [
            StaticForm(
                id: "Dm7-5-1",
                shapeName: nil,
                frets: [F(1), F(1), F(1), .open, .x, .x],
                fingers: [.one, .one, .one, nil, nil, nil],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 3, finger: .one)],
                tips: ["D half-diminished", "Compact voicing"]
            )
        ]
    ),
    
    // Em7-5: 012020
    StaticChord(
        id: "Em7-5",
        symbol: "Em7-5",
        quality: "m7-5",
        forms: [
            StaticForm(
                id: "Em7-5-1",
                shapeName: nil,
                frets: [.open, F(2), .open, F(1), F(2), .open],
                fingers: [nil, .two, nil, .one, .three, nil],
                barres: [],
                tips: ["E half-diminished", "Open voicing"]
            )
        ]
    ),
    
    // MARK: - 6 Chords
    
    // C6: x32210
    StaticChord(
        id: "C6",
        symbol: "C6",
        quality: "6",
        forms: [
            StaticForm(
                id: "C6-1",
                shapeName: nil,
                frets: [.open, F(1), F(2), F(2), F(3), .x],
                fingers: [nil, .one, .two, .three, .four, nil],
                barres: [],
                tips: ["C sixth chord", "Added 6th degree"]
            )
        ]
    ),
    
    // D6: xx0202
    StaticChord(
        id: "D6",
        symbol: "D6",
        quality: "6",
        forms: [
            StaticForm(
                id: "D6-1",
                shapeName: nil,
                frets: [.open, F(2), .open, F(2), .x, .x],
                fingers: [nil, .one, nil, .two, nil, nil],
                barres: [],
                tips: ["D sixth", "Simple fingering"]
            )
        ]
    ),
    
    // E6: 022120
    StaticChord(
        id: "E6",
        symbol: "E6",
        quality: "6",
        forms: [
            StaticForm(
                id: "E6-1",
                shapeName: nil,
                frets: [.open, F(2), F(1), F(2), F(2), .open],
                fingers: [nil, .two, .one, .three, .four, nil],
                barres: [],
                tips: ["E sixth", "Rich voicing"]
            )
        ]
    ),
    
    // MARK: - 6/9 Chords
    
    // C6/9: x32233
    StaticChord(
        id: "C6/9",
        symbol: "C6/9",
        quality: "6/9",
        forms: [
            StaticForm(
                id: "C6/9-1",
                shapeName: nil,
                frets: [F(3), F(3), F(2), F(2), F(3), .x],
                fingers: [.three, .four, .one, .two, .three, nil],
                barres: [],
                tips: ["C sixth add ninth", "Jazz color"]
            )
        ]
    ),
    
    // MARK: - aug (Augmented) Chords
    
    // Caug: x32110
    StaticChord(
        id: "Caug",
        symbol: "Caug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "Caug-1",
                shapeName: nil,
                frets: [.open, F(1), F(1), F(2), F(3), .x],
                fingers: [nil, .one, .one, .two, .three, nil],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 2, finger: .one)],
                tips: ["Augmented tension", "Symmetrical structure"]
            )
        ]
    ),
    
    // Eaug: 032110
    StaticChord(
        id: "Eaug",
        symbol: "Eaug",
        quality: "aug",
        forms: [
            StaticForm(
                id: "Eaug-1",
                shapeName: nil,
                frets: [.open, F(1), F(1), F(2), F(3), .open],
                fingers: [nil, .one, .one, .two, .three, nil],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 2, finger: .one)],
                tips: ["E augmented", "Raised 5th"]
            )
        ]
    ),
    
    // MARK: - Additional Barre Forms for sus4
    
    // Fsus4 (Barre): 133311
    StaticChord(
        id: "Fsus4",
        symbol: "Fsus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Fsus4-1",
                shapeName: nil,
                frets: [F(1), F(1), F(3), F(3), F(3), F(1)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["F sus4 barre", "Full barre chord"]
            )
        ]
    ),
    
    // Bsus4 (Barre): x24452
    StaticChord(
        id: "Bsus4",
        symbol: "Bsus4",
        quality: "sus4",
        forms: [
            StaticForm(
                id: "Bsus4-1",
                shapeName: nil,
                frets: [F(2), F(4), F(4), F(5), F(2), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 5, finger: .one)],
                tips: ["B sus4 barre", "5th string root"]
            )
        ]
    ),
    
    // MARK: - Additional Barre Forms for sus2
    
    // Fsus2: 133011
    StaticChord(
        id: "Fsus2",
        symbol: "Fsus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Fsus2-1",
                shapeName: nil,
                frets: [F(1), F(1), F(3), .open, F(3), F(1)],
                fingers: [.one, .one, .three, nil, .four, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["F sus2", "Open 4th string"]
            )
        ]
    ),
    
    // Gsus2 (Open): 300233
    StaticChord(
        id: "Gsus2",
        symbol: "Gsus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Gsus2-1",
                shapeName: nil,
                frets: [F(3), F(3), .open, .open, F(2), F(3)],
                fingers: [.three, .four, nil, nil, .one, .two],
                barres: [],
                tips: ["G sus2 open", "Bright, jangly sound"]
            )
        ]
    ),
    
    // Bsus2 (Barre): x24422
    StaticChord(
        id: "Bsus2",
        symbol: "Bsus2",
        quality: "sus2",
        forms: [
            StaticForm(
                id: "Bsus2-1",
                shapeName: nil,
                frets: [F(2), F(2), F(4), F(4), F(2), .x],
                fingers: [.one, .one, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 5, finger: .one)],
                tips: ["B sus2 barre", "5th string root"]
            )
        ]
    ),
    
    // MARK: - Additional add9 Forms
    
    // Fadd9: xx3213
    StaticChord(
        id: "Fadd9",
        symbol: "Fadd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Fadd9-1",
                shapeName: nil,
                frets: [F(3), F(1), F(2), F(3), .x, .x],
                fingers: [.three, .one, .two, .four, nil, nil],
                barres: [],
                tips: ["F add9", "Upper string voicing"]
            )
        ]
    ),
    
    // Gadd9: 320203
    StaticChord(
        id: "Gadd9",
        symbol: "Gadd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Gadd9-1",
                shapeName: nil,
                frets: [F(3), .open, F(2), .open, .x, F(3)],
                fingers: [.three, nil, .one, nil, nil, .four],
                barres: [],
                tips: ["G add9", "Folk style voicing"]
            )
        ]
    ),
    
    // Aadd9: x02420
    StaticChord(
        id: "Aadd9",
        symbol: "Aadd9",
        quality: "add9",
        forms: [
            StaticForm(
                id: "Aadd9-1",
                shapeName: nil,
                frets: [.open, F(2), F(4), F(2), .open, .x],
                fingers: [nil, .one, .four, .two, nil, nil],
                barres: [],
                tips: ["A add9", "9th on 3rd string"]
            )
        ]
    ),
    
    // MARK: - Additional 7 Barre Forms
    
    // F7 Root-6: 131211, Root-5: 8-10-8-10-8-x, Root-4: 4-2-3-1-x-x
    StaticChord(
        id: "F7",
        symbol: "F7",
        quality: "7",
        forms: [
            StaticForm(
                id: "F7-1",
                shapeName: nil,
                frets: [F(1), F(1), F(2), F(1), F(3), F(1)],
                fingers: [.one, .one, .two, .one, .three, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["F7 Root-6 barre", "b7 on 4th, 5th at 3fr"]
            ),
            StaticForm(
                id: "F7-2-Root5",
                shapeName: "Root-5",
                frets: [F(8), F(10), F(8), F(10), F(8), .x],
                fingers: [.one, .four, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root A-shape", "Standard barre"]
            ),
            StaticForm(
                id: "F7-3-Root4",
                shapeName: "Root-4",
                frets: [F(4), F(2), F(3), F(1), .x, .x],
                fingers: [.four, .two, .three, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "Low position"]
            )
        ]
    ),
    
    // MARK: - Additional M7 Barre Forms
    
    // FM7: 133210 or xx3210
    StaticChord(
        id: "FM7",
        symbol: "FM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "FM7-1",
                shapeName: nil,
                frets: [.open, F(1), F(2), F(3), F(3), .x],
                fingers: [nil, .one, .two, .three, .four, nil],
                barres: [],
                tips: ["F major 7th", "Upper string voicing"]
            ),
            // Root-6 (1fr): 1-1-2-2-3-1
            StaticForm(
                id: "FM7-2-Root6",
                shapeName: "Root-6",
                frets: [F(1), F(1), F(2), F(2), F(3), F(1)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "Maj7 E-shape"]
            ),
            // Root-5 (8fr): 8-10-9-10-8-x
            StaticForm(
                id: "FM7-3-Root5",
                shapeName: "Root-5",
                frets: [F(8), F(10), F(9), F(10), F(8), .x],
                fingers: [.one, .four, .two, .three, .one, nil],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Maj7 A-shape"]
            ),
            // Root-4 (2-5fr): 5-5-5-2-x-x
            StaticForm(
                id: "FM7-4-Root4",
                shapeName: "Root-4",
                frets: [F(5), F(5), F(5), F(2), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            )
        ]
    ),
    
    // MARK: - Additional m7 Barre Forms
    
    // Cm7
    StaticChord(
        id: "Cm7",
        symbol: "Cm7",
        quality: "m7",
        forms: [
            // Root-6 (8fr): 8-8-8-8-10-8
            StaticForm(
                id: "Cm7-1-Root6",
                shapeName: "Root-6",
                frets: [F(8), F(8), F(8), F(8), F(10), F(8)],
                fingers: [.one, .one, .one, .one, .three, .one],
                barres: [StaticBarre(fret: 8, fromString: 1, toString: 6, finger: .one)],
                tips: ["6th string root", "m7 E-shape full barre"]
            ),
            // Root-5 (3fr): 3-4-3-5-3-x
            StaticForm(
                id: "Cm7-2-Root5",
                shapeName: "Root-5",
                frets: [F(3), F(4), F(3), F(5), F(3), .x],
                fingers: [.one, .two, .one, .three, .one, nil],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 5, finger: .one)],
                tips: ["5th string root", "Standard m7 A-shape"]
            ),
            // Root-4 (8-11fr): 11-11-11-8-x-x
            StaticForm(
                id: "Cm7-3-Root4",
                shapeName: "Root-4",
                frets: [F(11), F(11), F(11), F(8), .x, .x],
                fingers: [.three, .two, .four, .one, nil, nil],
                barres: [],
                tips: ["4th string root", "High position"]
            )
        ]
    ),
    
    // Fm7: 131111
    StaticChord(
        id: "Fm7",
        symbol: "Fm7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "Fm7-1",
                shapeName: nil,
                frets: [F(1), F(1), F(1), F(3), F(1), F(1)],
                fingers: [.one, .one, .one, .three, .one, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["F minor 7th barre", "Full barre"]
            )
        ]
    ),
    
    // Gm7: 353333
    StaticChord(
        id: "Gm7",
        symbol: "Gm7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "Gm7-1",
                shapeName: nil,
                frets: [F(3), F(3), F(3), F(5), F(3), F(3)],
                fingers: [.one, .one, .one, .four, .one, .one],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["G minor 7th barre", "6th string root"]
            )
        ]
    ),
    
    // Bm7: x24232
    StaticChord(
        id: "Bm7",
        symbol: "Bm7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "Bm7-1",
                shapeName: nil,
                frets: [F(2), F(3), F(2), F(4), F(2), .x],
                fingers: [.one, .two, .one, .four, .one, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 5, finger: .one)],
                tips: ["B minor 7th barre", "5th string root"]
            )
        ]
    )
]

