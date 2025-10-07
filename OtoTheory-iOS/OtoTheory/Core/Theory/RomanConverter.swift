import Foundation

struct RomanConverter {
    /// Convert Roman numeral to chord symbol based on key
    /// e.g., "I" in C major -> "C", "vi" in C major -> "Am"
    static func toChordSymbol(_ roman: String, key: String) -> String? {
        // Parse Roman numeral
        guard let parsed = parseRoman(roman) else { return nil }
        
        // Get key pitch class (0-11)
        guard let keyPc = pitchClass(key) else { return nil }
        
        // Calculate root pitch class
        let rootPc = (keyPc + parsed.degree) % 12
        let root = pitchNames[rootPc]
        
        // Build chord symbol
        return root + parsed.quality
    }
    
    /// Convert multiple Roman numerals to chord symbols
    static func toChordSymbols(_ romans: [String], key: String) -> [String] {
        romans.compactMap { toChordSymbol($0, key: key) }
    }
    
    // MARK: - Private Helpers
    
    private static func parseRoman(_ roman: String) -> (degree: Int, quality: String)? {
        var remaining = roman
        var accidental = 0
        
        // Handle accidentals (b, #)
        if remaining.hasPrefix("b") {
            accidental = -1
            remaining = String(remaining.dropFirst())
        } else if remaining.hasPrefix("#") {
            accidental = 1
            remaining = String(remaining.dropFirst())
        }
        
        // Parse numeral (I, II, III, IV, V, VI, VII)
        let uppercase = remaining.uppercased()
        var degree: Int?
        var consumed = 0
        
        if uppercase.hasPrefix("VII") {
            degree = 11
            consumed = 3
        } else if uppercase.hasPrefix("VI") {
            degree = 9
            consumed = 2
        } else if uppercase.hasPrefix("V") {
            degree = 7
            consumed = 1
        } else if uppercase.hasPrefix("IV") {
            degree = 5
            consumed = 2
        } else if uppercase.hasPrefix("III") {
            degree = 4
            consumed = 3
        } else if uppercase.hasPrefix("II") {
            degree = 2
            consumed = 2
        } else if uppercase.hasPrefix("I") {
            degree = 0
            consumed = 1
        }
        
        guard let baseDegree = degree else { return nil }
        
        // Apply accidental
        let finalDegree = (baseDegree + accidental + 12) % 12
        
        // Determine quality (major/minor/dim/aug)
        let isLowercase = remaining.first?.isLowercase ?? false
        let suffix = String(remaining.dropFirst(consumed))
        
        var quality = ""
        if isLowercase {
            quality = "m"
        }
        
        // Add extensions (7, maj7, m7, dim, aug, sus4, etc.)
        quality += suffix
        
        return (degree: finalDegree, quality: quality)
    }
    
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
    
    private static let pitchNames = [
        "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
    ]
}


