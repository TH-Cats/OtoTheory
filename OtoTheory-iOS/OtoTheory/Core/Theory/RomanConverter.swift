import Foundation

/// Roman numeral to chord symbol converter with diatonic context
/// Follows the same theory as Web version (theory.ts)
struct RomanConverter {
    // MARK: - Public API
    
    /// Convert Roman numeral to chord symbol based on key and mode
    /// e.g., "Ⅱ" in C Major -> "Dm" (auto-complements minor quality)
    ///       "Ⅶ" in C Major -> "Bdim" (auto-complements diminished quality)
    static func toChordSymbol(_ roman: String, key: String, mode: Mode = .major) -> String? {
        guard let parsed = parseRomanNumeral(roman) else { return nil }
        guard let keyPc = pitchClass(key) else { return nil }
        
        let rootPc = (keyPc + parsed.degree) % 12
        // Use key-aware note naming (respects sharp/flat key signature)
        let root = pcToNoteName(rootPc, keyRoot: keyPc)
        
        // If explicit quality is provided, use it; otherwise use diatonic default
        let quality = parsed.explicitQuality ?? defaultQuality(forDegree: parsed.degree, mode: mode)
        
        return root + quality
    }
    
    /// Convert multiple Roman numerals to chord symbols
    static func toChordSymbols(_ romans: [String], key: String, mode: Mode = .major) -> [String] {
        romans.compactMap { toChordSymbol($0, key: key, mode: mode) }
    }
    
    // MARK: - Mode Definition
    
    enum Mode {
        case major
        case minor
    }
    
    // MARK: - Diatonic Quality Tables
    
    /// Diatonic qualities for Major mode (first candidate is default)
    private static let degQualMajor: [Int: [String]] = [
        0: ["", "maj7"],      // I
        2: ["m", "m7"],       // ii
        4: ["m", "m7"],       // iii
        5: ["", "maj7"],      // IV
        7: ["", "7"],         // V
        9: ["m", "m7"],       // vi
        11: ["dim", "m7b5"]   // vii°
    ]
    
    /// Diatonic qualities for Minor mode (first candidate is default)
    private static let degQualMinor: [Int: [String]] = [
        0: ["m", "m7"],          // i
        2: ["dim", "m7b5"],      // ii°
        3: ["", "maj7"],         // ♭III
        5: ["m", "m7"],          // iv
        7: ["m", "7", "", "7"],  // v, V (both allowed in minor)
        8: ["", "maj7"],         // ♭VI
        10: ["", "7"]            // ♭VII
    ]
    
    /// Get default diatonic quality for a degree and mode
    private static func defaultQuality(forDegree degree: Int, mode: Mode) -> String {
        let table = mode == .major ? degQualMajor : degQualMinor
        return table[degree]?.first ?? "" // Major triad if not in diatonic table (borrowed chord)
    }
    
    // MARK: - Roman Numeral Parsing
    
    private struct ParsedRoman {
        let degree: Int
        let explicitQuality: String?
    }
    
    /// Parse Roman numeral into degree and explicit quality
    /// Examples:
    ///   "Ⅱm7" -> (degree: 2, explicitQual: "m7")
    ///   "Ⅴ" -> (degree: 7, explicitQual: nil)
    ///   "♭Ⅶ" -> (degree: 10, explicitQual: nil)
    private static func parseRomanNumeral(_ roman: String) -> ParsedRoman? {
        var remaining = roman
        var accidental = 0
        
        // Handle accidentals (♭ or b, ♯ or #)
        if remaining.hasPrefix("♭") || remaining.hasPrefix("b") {
            accidental = -1
            remaining = String(remaining.dropFirst())
        } else if remaining.hasPrefix("♯") || remaining.hasPrefix("#") {
            accidental = 1
            remaining = String(remaining.dropFirst())
        }
        
        // Parse Roman numeral body (Ⅰ-Ⅶ)
        var degree: Int?
        var consumed = 0
        
        // Check uppercase Roman numerals first
        if remaining.hasPrefix("Ⅶ") {
            degree = 11; consumed = 1
        } else if remaining.hasPrefix("ⅶ") {
            degree = 11; consumed = 1
        } else if remaining.hasPrefix("Ⅵ") {
            degree = 9; consumed = 1
        } else if remaining.hasPrefix("ⅵ") {
            degree = 9; consumed = 1
        } else if remaining.hasPrefix("Ⅴ") {
            degree = 7; consumed = 1
        } else if remaining.hasPrefix("ⅴ") {
            degree = 7; consumed = 1
        } else if remaining.hasPrefix("Ⅳ") {
            degree = 5; consumed = 1
        } else if remaining.hasPrefix("ⅳ") {
            degree = 5; consumed = 1
        } else if remaining.hasPrefix("Ⅲ") {
            degree = 4; consumed = 1
        } else if remaining.hasPrefix("ⅲ") {
            degree = 4; consumed = 1
        } else if remaining.hasPrefix("Ⅱ") {
            degree = 2; consumed = 1
        } else if remaining.hasPrefix("ⅱ") {
            degree = 2; consumed = 1
        } else if remaining.hasPrefix("Ⅰ") {
            degree = 0; consumed = 1
        } else if remaining.hasPrefix("ⅰ") {
            degree = 0; consumed = 1
        }
        
        // Fallback: ASCII Roman numerals (VII, VI, V, IV, III, II, I)
        if degree == nil {
            let upper = remaining.uppercased()
            if upper.hasPrefix("VII") {
                degree = 11; consumed = 3
            } else if upper.hasPrefix("VI") {
                degree = 9; consumed = 2
            } else if upper.hasPrefix("V") {
                degree = 7; consumed = 1
            } else if upper.hasPrefix("IV") {
                degree = 5; consumed = 2
            } else if upper.hasPrefix("III") {
                degree = 4; consumed = 3
            } else if upper.hasPrefix("II") {
                degree = 2; consumed = 2
            } else if upper.hasPrefix("I") {
                degree = 0; consumed = 1
            }
        }
        
        guard let baseDegree = degree else {
            print("⚠️ RomanConverter: Unknown Roman numeral '\(roman)'")
            return nil
        }
        
        // Apply accidental
        let finalDegree = (baseDegree + accidental + 12) % 12
        
        // Extract explicit quality suffix (if any)
        let suffix = String(remaining.dropFirst(consumed)).trimmingCharacters(in: .whitespaces)
        let explicitQuality = suffix.isEmpty ? nil : suffix
        
        return ParsedRoman(degree: finalDegree, explicitQuality: explicitQuality)
    }
    
    // MARK: - Pitch Class Utilities
    
    private static func pitchClass(_ noteName: String) -> Int? {
        let map: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1,
            "D": 2, "D#": 3, "Eb": 3,
            "E": 4,
            "F": 5, "F#": 6, "Gb": 6,
            "G": 7, "G#": 8, "Ab": 8,
            "A": 9, "A#": 10, "Bb": 10,
            "B": 11
        ]
        return map[noteName]
    }
    
    /// Get note name for pitch class, respecting key signature
    private static func pcToNoteName(_ pc: Int, keyRoot: Int? = nil) -> String {
        guard let keyRoot = keyRoot else {
            // No key info: prefer flats (same as Chord Library)
            let flatPreferred = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
            return flatPreferred[pc]
        }
        
        // Sharp keys vs flat keys
        let sharpKeys: Set<Int> = [7, 2, 9, 4, 11, 6, 1] // G, D, A, E, B, F#, C#
        
        if sharpKeys.contains(keyRoot) {
            // Sharp key: C, C#, D, D#, E, F, F#, G, G#, A, A#, B
            let sharpNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
            return sharpNames[pc]
        } else {
            // Flat key (or C): C, Db, D, Eb, E, F, Gb, G, Ab, A, Bb, B
            let flatNames = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
            return flatNames[pc]
        }
    }
}
