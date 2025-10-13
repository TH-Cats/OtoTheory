//
//  Section.swift
//  OtoTheory
//
//  Phase 2: Section editing for song structure
//

import Foundation

/// Represents a section in a chord progression (e.g., Verse, Chorus, Bridge)
struct Section: Identifiable, Codable, Equatable {
    let id: UUID
    var name: SectionType
    var range: ClosedRange<Int>  // Bar range (0-based, inclusive)
    var repeatCount: Int  // Number of times to repeat (1 = play once, 2 = play twice)
    
    init(id: UUID = UUID(), name: SectionType, range: ClosedRange<Int>, repeatCount: Int = 1) {
        self.id = id
        self.name = name
        self.range = range
        self.repeatCount = max(1, repeatCount)  // At least 1
    }
    
    /// Number of bars in this section
    var barCount: Int {
        range.upperBound - range.lowerBound + 1
    }
    
    /// Display name for UI
    var displayName: String {
        "\(name.displayName) (bars \(range.lowerBound + 1)-\(range.upperBound + 1))"
    }
}

/// Common section types in song structure
enum SectionType: String, Codable, CaseIterable {
    case intro = "Intro"
    case verse = "Verse"
    case preChorus = "Pre-Chorus"
    case chorus = "Chorus"
    case postChorus = "Post-Chorus"
    case bridge = "Bridge"
    case solo = "Solo"
    case outro = "Outro"
    case interlude = "Interlude"
    case breakdown = "Breakdown"
    
    var displayName: String {
        rawValue
    }
    
    /// Icon for UI
    var icon: String {
        switch self {
        case .intro: return "play.circle"
        case .verse: return "music.note"
        case .preChorus: return "arrow.up.circle"
        case .chorus: return "star.circle"
        case .postChorus: return "star.circle.fill"
        case .bridge: return "arrow.triangle.branch"
        case .solo: return "guitars"
        case .outro: return "stop.circle"
        case .interlude: return "ellipsis.circle"
        case .breakdown: return "waveform"
        }
    }
}

// MARK: - Codable conformance for ClosedRange

extension Section {
    enum CodingKeys: String, CodingKey {
        case id, name, rangeStart, rangeEnd, repeatCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(SectionType.self, forKey: .name)
        let start = try container.decode(Int.self, forKey: .rangeStart)
        let end = try container.decode(Int.self, forKey: .rangeEnd)
        range = start...end
        repeatCount = try container.decode(Int.self, forKey: .repeatCount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(range.lowerBound, forKey: .rangeStart)
        try container.encode(range.upperBound, forKey: .rangeEnd)
        try container.encode(repeatCount, forKey: .repeatCount)
    }
}

// MARK: - Validation

extension Section {
    /// Validates that the section is valid (range is positive, repeatCount >= 1)
    var isValid: Bool {
        range.lowerBound >= 0 &&
        range.upperBound >= range.lowerBound &&
        repeatCount >= 1
    }
    
    /// Checks if this section overlaps with another section
    func overlaps(with other: Section) -> Bool {
        range.overlaps(other.range)
    }
}

// MARK: - Helper methods for section management

extension Array where Element == Section {
    /// Validates that all sections are valid and non-overlapping
    var areAllValid: Bool {
        // Check individual validity
        guard allSatisfy({ $0.isValid }) else {
            return false
        }
        
        // Check for overlaps
        for i in 0..<count {
            for j in (i + 1)..<count {
                if self[i].overlaps(with: self[j]) {
                    return false
                }
            }
        }
        
        return true
    }
    
    /// Returns sections sorted by range start
    var sortedByRange: [Section] {
        sorted { $0.range.lowerBound < $1.range.lowerBound }
    }
    
    /// Finds the section containing a given bar index
    func section(at barIndex: Int) -> Section? {
        first { $0.range.contains(barIndex) }
    }
}

