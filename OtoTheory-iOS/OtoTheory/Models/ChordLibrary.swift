//
//  ChordLibrary.swift
//  OtoTheory
//
//  Chord Library Data Models
//  v3.1.1: 5-form expansion (Open / E-shape / A-shape / Compact / Color)
//

import Foundation

// MARK: - Chord Root (12 notes)

enum ChordRoot: String, CaseIterable, Identifiable {
    case C, Cs = "C#", D, Eb, E, F, Fs = "F#", G, Ab, A, Bb, B
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var semitone: Int {
        switch self {
        case .C: return 0
        case .Cs: return 1
        case .D: return 2
        case .Eb: return 3
        case .E: return 4
        case .F: return 5
        case .Fs: return 6
        case .G: return 7
        case .Ab: return 8
        case .A: return 9
        case .Bb: return 10
        case .B: return 11
        }
    }
    
    static func from(semitone: Int) -> ChordRoot {
        let normalized = ((semitone % 12) + 12) % 12
        return ChordRoot.allCases.first { $0.semitone == normalized } ?? .C
    }
}

// MARK: - Chord Library Quality (40+ types)

enum ChordLibraryQuality: String, CaseIterable, Identifiable {
    // Basic triads
    case M = ""
    case m
    case aug
    case dim
    
    // Suspended
    case sus2
    case sus4
    
    // 6th chords
    case six = "6"
    case m6
    case sixNine = "6/9"
    
    // 7th chords
    case seven = "7"
    case M7 = "maj7"
    case m7
    case dim7
    case m7b5
    
    // 9th chords
    case nine = "9"
    case M9 = "maj9"
    case m9
    case add9
    
    // 11th chords
    case eleven = "11"
    case M11 = "maj11"
    case add11
    
    // 13th chords
    case thirteen = "13"
    case M13 = "maj13"
    case m13
    case add13
    
    // Altered dominant
    case sevenSus4 = "7sus4"
    case sevenb9 = "7b9"
    case sevenSharp9 = "7#9"
    case sevenb5 = "7b5"
    case sevenSharp5 = "7#5"
    case sevenSharp11 = "7#11"
    case sevenb13 = "7b13"
    case sevenAlt = "7alt"
    
    // Other
    case mM7 = "m(maj7)"
    
    var id: String { rawValue }
    
    var displayName: String {
        // Display "M" for empty string (Major)
        rawValue.isEmpty ? "M" : rawValue
    }
    
    /// Pro-only qualities (for Progression Add restriction)
    var isProOnly: Bool {
        switch self {
        case .thirteen, .M13, .m13,  // 13th系
             .sevenb9, .sevenSharp9, .sevenSharp11, .sevenb13, .sevenAlt:  // Altered
            return true
        default:
            return false
        }
    }
    
    /// Returns intervals for this quality
    var intervals: [Int] {
        switch self {
        case .M: return [0, 4, 7]
        case .m: return [0, 3, 7]
        case .aug: return [0, 4, 8]
        case .dim: return [0, 3, 6]
        case .sus2: return [0, 2, 7]
        case .sus4: return [0, 5, 7]
        case .six: return [0, 4, 7, 9]
        case .m6: return [0, 3, 7, 9]
        case .sixNine: return [0, 4, 7, 9, 14]
        case .seven: return [0, 4, 7, 10]
        case .M7: return [0, 4, 7, 11]
        case .m7: return [0, 3, 7, 10]
        case .dim7: return [0, 3, 6, 9]
        case .m7b5: return [0, 3, 6, 10]
        case .nine: return [0, 4, 7, 10, 14]
        case .M9: return [0, 4, 7, 11, 14]
        case .m9: return [0, 3, 7, 10, 14]
        case .add9: return [0, 4, 7, 14]
        case .eleven: return [0, 4, 7, 10, 14, 17]
        case .M11: return [0, 4, 7, 11, 14, 17]
        case .add11: return [0, 4, 7, 17]
        case .thirteen: return [0, 4, 7, 10, 14, 21]
        case .M13: return [0, 4, 7, 11, 14, 21]
        case .m13: return [0, 3, 7, 10, 14, 21]
        case .add13: return [0, 4, 7, 21]
        case .sevenSus4: return [0, 5, 7, 10]
        case .sevenb9: return [0, 4, 7, 10, 13]
        case .sevenSharp9: return [0, 4, 7, 10, 15]
        case .sevenb5: return [0, 4, 6, 10]
        case .sevenSharp5: return [0, 4, 8, 10]
        case .sevenSharp11: return [0, 4, 7, 10, 18]
        case .sevenb13: return [0, 4, 7, 10, 20]
        case .sevenAlt: return [0, 4, 6, 10, 13]  // Simplified
        case .mM7: return [0, 3, 7, 11]
        }
    }
}

// MARK: - Shape Kind (5 forms)

enum ShapeKind: String, CaseIterable, Identifiable {
    case open = "Open"
    case eShape = "E-shape"
    case aShape = "A-shape"
    case compact = "Compact"
    case color = "Color"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var description: String {
        switch self {
        case .open:
            return "Open chord with open strings"
        case .eShape:
            return "Barre chord, 6th string root (E-shape)"
        case .aShape:
            return "Barre chord, 5th string root (A-shape)"
        case .compact:
            return "Compact voicing on upper strings"
        case .color:
            return "Color tone voicing (add9, 6/9, sus)"
        }
    }
}

// MARK: - Chord Fret

enum ChordFret: Equatable {
    case open         // 0 (open string)
    case muted        // x (muted)
    case fretted(Int) // 1-15
    
    var displayValue: String {
        switch self {
        case .open: return "0"
        case .muted: return "x"
        case .fretted(let f): return "\(f)"
        }
    }
    
    var midiOffset: Int? {
        switch self {
        case .open: return 0
        case .muted: return nil
        case .fretted(let f): return f
        }
    }
}

// MARK: - Chord Finger

enum ChordFinger: Int, Codable {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    
    var displayValue: String { "\(rawValue)" }
}

// MARK: - Chord Barre

struct ChordBarre: Identifiable, Codable {
    let id: UUID
    let fret: Int
    let fromString: Int  // 1-6 (high to low)
    let toString: Int
    let finger: ChordFinger
    
    init(fret: Int, fromString: Int, toString: Int, finger: ChordFinger) {
        self.id = UUID()
        self.fret = fret
        self.fromString = fromString
        self.toString = toString
        self.finger = finger
    }
}

// MARK: - Chord Shape (single form)

struct ChordShape: Identifiable, Codable {
    let id: UUID
    let kind: String  // ShapeKind.rawValue
    let label: String // "Open", "3fr", "5fr"
    let frets: [String]  // 6 strings (1st to 6th), ["0", "1", "0", "2", "3", "x"]
    let fingers: [Int?]  // 6 strings (1st to 6th)
    let barres: [ChordBarre]
    let tips: [String]  // Multiple tips
    
    init(
        kind: ShapeKind,
        label: String,
        frets: [ChordFret],
        fingers: [ChordFinger?],
        barres: [ChordBarre] = [],
        tips: [String] = []
    ) {
        self.id = UUID()
        self.kind = kind.rawValue
        self.label = label
        self.frets = frets.map { $0.displayValue }
        self.fingers = fingers.map { $0?.rawValue }
        self.barres = barres
        self.tips = tips
    }
    
    /// Convert to MIDI note numbers using 1st->6th order
    func toMIDINotes(rootSemitone: Int) -> [UInt8] {
        // Open strings (1st to 6th): E4, B3, G3, D3, A2, E2
        let openStrings = [64, 59, 55, 50, 45, 40]
        var notes: [UInt8] = []
        
        for (index, fretStr) in frets.enumerated() {
            if fretStr == "x" { continue }
            let fret = Int(fretStr) ?? 0
            let midiNote = openStrings[index] + fret
            notes.append(UInt8(midiNote))
        }
        
        return notes.sorted()
    }
}

// MARK: - Chord Entry (complete chord info)

struct ChordEntry: Identifiable {
    let id: UUID
    let root: ChordRoot
    let quality: ChordLibraryQuality
    let symbol: String  // "Cmaj7"
    let display: String // "Cmaj7"
    let shapes: [ChordShape]  // 5 forms
    let intervals: String  // "R · III · V · VII"
    let notes: String  // "C · E · G · B"
    let voicingNote: String  // "Rich major 7th sound"
    
    init(root: ChordRoot, quality: ChordLibraryQuality, shapes: [ChordShape]) {
        self.id = UUID()
        self.root = root
        self.quality = quality
        self.symbol = root.displayName + quality.symbolSuffix
        self.display = symbol
        self.shapes = shapes
        
        // Calculate intervals
        let intervalNames = quality.intervals.map { interval in
            ChordEntry.intervalName(interval)
        }
        self.intervals = intervalNames.joined(separator: " · ")
        
        // Calculate note names
        let noteNames = quality.intervals.map { interval in
            ChordRoot.from(semitone: root.semitone + interval).displayName
        }
        self.notes = noteNames.joined(separator: " · ")
        
        // Voicing note
        self.voicingNote = ChordEntry.voicingDescription(quality)
    }
    
    private static func intervalName(_ semitones: Int) -> String {
        let normalized = ((semitones % 12) + 12) % 12
        switch normalized {
        case 0: return "R"
        case 1: return "♭II"
        case 2: return "II"
        case 3: return "♭III"
        case 4: return "III"
        case 5: return "IV"
        case 6: return "♭V"
        case 7: return "V"
        case 8: return "♭VI"
        case 9: return "VI"
        case 10: return "♭VII"
        case 11: return "VII"
        default: return "?"
        }
    }
    
    private static func voicingDescription(_ quality: ChordLibraryQuality) -> String {
        switch quality {
        case .M: return "Bright, stable major triad"
        case .m: return "Melancholic minor sound"
        case .seven: return "Bluesy dominant 7th"
        case .M7: return "Rich major 7th sound"
        case .m7: return "Smooth minor 7th"
        case .dim: return "Tense diminished triad"
        case .dim7: return "Symmetrical diminished 7th"
        case .sus2: return "Open, suspended sound"
        case .sus4: return "Suspended, resolving feel"
        default: return "Extended harmony"
        }
    }
}

extension ChordLibraryQuality {
    /// Suffix used for chord symbols (Major returns empty string)
    var symbolSuffix: String { self == .M ? "" : self.rawValue }
}

// MARK: - Chord Display Mode

enum ChordDisplayMode: String, CaseIterable, Identifiable {
    case finger = "Finger"
    case roman = "Roman"
    case note = "Note"
    
    var id: String { rawValue }
}

// MARK: - Chord Library Manager

@MainActor
class ChordLibraryManager: ObservableObject {
    static let shared = ChordLibraryManager()
    
    @Published private var cache: [String: ChordEntry] = [:]
    
    private init() {}
    
    /// Get chord entry (generates if not cached)
    func getChord(root: ChordRoot, quality: ChordLibraryQuality) -> ChordEntry? {
        let key = "\(root.rawValue)-\(quality.rawValue)"
        
        if let cached = cache[key] {
            return cached
        }
        
        // Generate shapes (will be implemented in ChordShapeGenerator)
        let shapes = ChordShapeGenerator.shared.generateShapes(root: root, quality: quality)
        
        if shapes.isEmpty { return nil }
        
        let entry = ChordEntry(root: root, quality: quality, shapes: shapes)
        cache[key] = entry
        
        return entry
    }
    
    /// Build chord symbol string
    func buildSymbol(root: ChordRoot, quality: ChordLibraryQuality) -> String {
        return root.displayName + quality.displayName
    }
    
    /// Clear cache (for memory management)
    func clearCache() {
        cache.removeAll()
    }
}

