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
    
    // C7 (Open): x32310
    StaticChord(
        id: "C7",
        symbol: "C7",
        quality: "7",
        forms: [
            StaticForm(
                id: "C7-1",
                shapeName: nil,
                frets: [.open, F(1), F(3), F(2), F(3), .x],  // 1→6
                fingers: [nil, .one, .four, .two, .three, nil],
                barres: [],
                tips: ["Classic C7 open", "Bluesy sound"]
            )
        ]
    ),
    
    // D7 (Open): xx0212
    StaticChord(
        id: "D7",
        symbol: "D7",
        quality: "7",
        forms: [
            StaticForm(
                id: "D7-1",
                shapeName: nil,
                frets: [F(2), F(1), F(2), .open, .x, .x],  // 1→6
                fingers: [.two, .one, .three, nil, nil, nil],
                barres: [],
                tips: ["D7 open position", "Compact voicing"]
            )
        ]
    ),
    
    // E7 (Open): 020100
    StaticChord(
        id: "E7",
        symbol: "E7",
        quality: "7",
        forms: [
            StaticForm(
                id: "E7-1",
                shapeName: nil,
                frets: [.open, .open, F(1), .open, F(2), .open],  // 1→6
                fingers: [nil, nil, .one, nil, .two, nil],
                barres: [],
                tips: ["Classic E7", "All strings played"]
            )
        ]
    ),
    
    // G7 (Open): 320001
    StaticChord(
        id: "G7",
        symbol: "G7",
        quality: "7",
        forms: [
            StaticForm(
                id: "G7-1",
                shapeName: nil,
                frets: [F(1), .open, .open, .open, F(2), F(3)],  // 1→6
                fingers: [.one, nil, nil, nil, .two, .three],
                barres: [],
                tips: ["G7 open", "Full, ringing sound"]
            )
        ]
    ),
    
    // A7 (Open): x02020
    StaticChord(
        id: "A7",
        symbol: "A7",
        quality: "7",
        forms: [
            StaticForm(
                id: "A7-1",
                shapeName: nil,
                frets: [.open, F(2), .open, F(2), .open, .x],  // 1→6
                fingers: [nil, .two, nil, .one, nil, nil],
                barres: [],
                tips: ["A7 open", "Easy fingering"]
            )
        ]
    ),
    
    // B7 (Open): x21202
    StaticChord(
        id: "B7",
        symbol: "B7",
        quality: "7",
        forms: [
            StaticForm(
                id: "B7-1",
                shapeName: nil,
                frets: [F(2), .open, F(2), F(1), F(2), .x],  // 1→6
                fingers: [.two, nil, .three, .one, .four, nil],
                barres: [],
                tips: ["B7 open", "Tricky fingering but common"]
            )
        ]
    ),
    
    // MARK: - M7 (Major 7th) Chords
    
    // CM7 (Open): x32000
    StaticChord(
        id: "CM7",
        symbol: "CM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "CM7-1",
                shapeName: nil,
                frets: [.open, .open, .open, F(2), F(3), .x],  // 1→6
                fingers: [nil, nil, nil, .one, .two, nil],
                barres: [],
                tips: ["Rich C major 7th", "Open strings"]
            )
        ]
    ),
    
    // DM7 (Open): xx0222
    StaticChord(
        id: "DM7",
        symbol: "DM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "DM7-1",
                shapeName: nil,
                frets: [F(2), F(2), F(2), .open, .x, .x],  // 1→6
                fingers: [.one, .two, .three, nil, nil, nil],
                barres: [],
                tips: ["D major 7th", "Compact voicing"]
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
            )
        ]
    ),
    
    // GM7 (Open): 320002
    StaticChord(
        id: "GM7",
        symbol: "GM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "GM7-1",
                shapeName: nil,
                frets: [F(2), .open, .open, .open, F(2), F(3)],  // 1→6
                fingers: [.one, nil, nil, nil, .two, .three],
                barres: [],
                tips: ["G major 7th", "Jazz voicing"]
            )
        ]
    ),
    
    // AM7 (Open): x02120
    StaticChord(
        id: "AM7",
        symbol: "AM7",
        quality: "M7",
        forms: [
            StaticForm(
                id: "AM7-1",
                shapeName: nil,
                frets: [.open, F(2), F(1), F(2), .open, .x],  // 1→6
                fingers: [nil, .two, .one, .three, nil, nil],
                barres: [],
                tips: ["A major 7th", "Mellow sound"]
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
    )
    
    // NOTE: More chords (dim, dim7, m7-5, etc.) to be added from PDF
    // This is Phase 1 sample data for testing
]

