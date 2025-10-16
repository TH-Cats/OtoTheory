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
    ),
    
    // MARK: - Major Chords (Open)
    
    // C (Open): x32010
    StaticChord(
        id: "C",
        symbol: "C",
        quality: "M",
        forms: [
            StaticForm(
                id: "C-1",
                shapeName: nil,
                frets: [.open, F(1), .open, F(2), F(3), .x],
                fingers: [nil, .one, nil, .two, .three, nil],
                barres: [],
                tips: ["Classic C major", "Mute 6th string"]
            )
        ]
    ),
    
    // D (Open): xx0232
    StaticChord(
        id: "D",
        symbol: "D",
        quality: "M",
        forms: [
            StaticForm(
                id: "D-1",
                shapeName: nil,
                frets: [F(2), F(3), F(2), .open, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["Classic D major", "Mute 5th and 6th strings"]
            )
        ]
    ),
    
    // E (Open): 022100
    StaticChord(
        id: "E",
        symbol: "E",
        quality: "M",
        forms: [
            StaticForm(
                id: "E-1",
                shapeName: nil,
                frets: [.open, .open, F(1), F(2), F(2), .open],
                fingers: [nil, nil, .one, .two, .three, nil],
                barres: [],
                tips: ["Classic E major", "All strings played"]
            )
        ]
    ),
    
    // F (Barre): 133211
    StaticChord(
        id: "F",
        symbol: "F",
        quality: "M",
        forms: [
            StaticForm(
                id: "F-1",
                shapeName: nil,
                frets: [F(1), F(1), F(2), F(3), F(3), F(1)],
                fingers: [.one, .one, .two, .three, .four, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["F major barre", "Full barre on 1st fret"]
            )
        ]
    ),
    
    // G (Open): 320003
    StaticChord(
        id: "G",
        symbol: "G",
        quality: "M",
        forms: [
            StaticForm(
                id: "G-1",
                shapeName: nil,
                frets: [F(3), .open, .open, .open, F(2), F(3)],
                fingers: [.two, nil, nil, nil, .one, .three],
                barres: [],
                tips: ["Classic G major", "Full, rich sound"]
            )
        ]
    ),
    
    // A (Open): x02220
    StaticChord(
        id: "A",
        symbol: "A",
        quality: "M",
        forms: [
            StaticForm(
                id: "A-1",
                shapeName: nil,
                frets: [.open, F(2), F(2), F(2), .open, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["Classic A major", "Mute 6th string"]
            )
        ]
    ),
    
    // B (Barre): x24442
    StaticChord(
        id: "B",
        symbol: "B",
        quality: "M",
        forms: [
            StaticForm(
                id: "B-1",
                shapeName: nil,
                frets: [F(2), F(4), F(4), F(4), F(2), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 5, finger: .one)],
                tips: ["B major barre", "5th string root"]
            )
        ]
    ),
    
    // MARK: - minor Chords (Open)
    
    // Cm (Barre): x35543
    StaticChord(
        id: "Cm",
        symbol: "Cm",
        quality: "m",
        forms: [
            StaticForm(
                id: "Cm-1",
                shapeName: nil,
                frets: [F(3), F(4), F(5), F(5), F(3), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 5, finger: .one)],
                tips: ["C minor barre", "5th string root"]
            )
        ]
    ),
    
    // Dm (Open): xx0231
    StaticChord(
        id: "Dm",
        symbol: "Dm",
        quality: "m",
        forms: [
            StaticForm(
                id: "Dm-1",
                shapeName: nil,
                frets: [F(1), F(3), F(2), .open, .x, .x],
                fingers: [.one, .three, .two, nil, nil, nil],
                barres: [],
                tips: ["D minor open", "Melancholic sound"]
            )
        ]
    ),
    
    // Em (Open): 022000
    StaticChord(
        id: "Em",
        symbol: "Em",
        quality: "m",
        forms: [
            StaticForm(
                id: "Em-1",
                shapeName: nil,
                frets: [.open, .open, .open, F(2), F(2), .open],
                fingers: [nil, nil, nil, .one, .two, nil],
                barres: [],
                tips: ["E minor open", "Easy and popular"]
            )
        ]
    ),
    
    // Fm (Barre): 133111
    StaticChord(
        id: "Fm",
        symbol: "Fm",
        quality: "m",
        forms: [
            StaticForm(
                id: "Fm-1",
                shapeName: nil,
                frets: [F(1), F(1), F(1), F(3), F(3), F(1)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["F minor barre", "Full barre chord"]
            )
        ]
    ),
    
    // Gm (Barre): 355333
    StaticChord(
        id: "Gm",
        symbol: "Gm",
        quality: "m",
        forms: [
            StaticForm(
                id: "Gm-1",
                shapeName: nil,
                frets: [F(3), F(3), F(3), F(5), F(5), F(3)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["G minor barre", "6th string root"]
            )
        ]
    ),
    
    // Am (Open): x02210
    StaticChord(
        id: "Am",
        symbol: "Am",
        quality: "m",
        forms: [
            StaticForm(
                id: "Am-1",
                shapeName: nil,
                frets: [.open, F(1), F(2), F(2), .open, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["A minor open", "Common chord"]
            )
        ]
    ),
    
    // Bm (Barre): x24432
    StaticChord(
        id: "Bm",
        symbol: "Bm",
        quality: "m",
        forms: [
            StaticForm(
                id: "Bm-1",
                shapeName: nil,
                frets: [F(2), F(3), F(4), F(4), F(2), .x],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [StaticBarre(fret: 2, fromString: 1, toString: 5, finger: .one)],
                tips: ["B minor barre", "5th string root"]
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
    
    // F7: 131211
    StaticChord(
        id: "F7",
        symbol: "F7",
        quality: "7",
        forms: [
            StaticForm(
                id: "F7-1",
                shapeName: nil,
                frets: [F(1), F(1), F(2), F(1), F(3), F(1)],
                fingers: [.one, .one, .two, .one, .four, .one],
                barres: [StaticBarre(fret: 1, fromString: 1, toString: 6, finger: .one)],
                tips: ["F7 barre", "6th string root"]
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
                frets: [.open, F(1), F(2), F(3), .x, .x],
                fingers: [nil, .one, .two, .three, nil, nil],
                barres: [],
                tips: ["F major 7th", "Upper string voicing"]
            )
        ]
    ),
    
    // MARK: - Additional m7 Barre Forms
    
    // Cm7: x35343
    StaticChord(
        id: "Cm7",
        symbol: "Cm7",
        quality: "m7",
        forms: [
            StaticForm(
                id: "Cm7-1",
                shapeName: nil,
                frets: [F(3), F(4), F(3), F(5), F(3), .x],
                fingers: [.one, .two, .one, .four, .one, nil],
                barres: [StaticBarre(fret: 3, fromString: 1, toString: 5, finger: .one)],
                tips: ["C minor 7th barre", "5th string root"]
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

