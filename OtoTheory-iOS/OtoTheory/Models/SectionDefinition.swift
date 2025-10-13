//
//  SectionDefinition.swift
//  OtoTheory
//
//  Phase E-5: Section-specific chord progressions
//

import Foundation

/// A section definition with its own chord progression
struct SectionDefinition: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String                // User-defined name (e.g., "Verse 1", "Chorus A")
    var type: SectionType          // Category (Verse, Chorus, etc.)
    var chords: [String?]          // 12-slot chord progression
    var key: String?               // Optional: detected key for this section
    var scale: String?             // Optional: detected scale for this section
    
    init(
        id: UUID = UUID(),
        name: String,
        type: SectionType,
        chords: [String?] = Array(repeating: nil, count: 12),
        key: String? = nil,
        scale: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.chords = chords
        self.key = key
        self.scale = scale
    }
    
    /// Number of filled chord slots
    var filledSlotsCount: Int {
        chords.compactMap { $0 }.count
    }
    
    /// Whether this section has any chords
    var hasChords: Bool {
        filledSlotsCount > 0
    }
    
    /// Display name with type icon
    var displayName: String {
        name
    }
    
    /// Creates a copy of this section with a new ID and name
    func duplicate(withName newName: String) -> SectionDefinition {
        SectionDefinition(
            id: UUID(),
            name: newName,
            type: type,
            chords: chords,
            key: key,
            scale: scale
        )
    }
}

// MARK: - Playback Order

/// Represents the playback order of sections
struct PlaybackOrder: Codable, Equatable {
    var items: [PlaybackItem]
    
    init(items: [PlaybackItem] = []) {
        self.items = items
    }
    
    /// Total number of times sections will be played (considering repeats)
    var totalPlayCount: Int {
        items.reduce(0) { $0 + $1.repeatCount }
    }
    
    /// Expands the playback order into a flat array of section IDs
    var expandedSectionIds: [UUID] {
        items.flatMap { item in
            Array(repeating: item.sectionId, count: item.repeatCount)
        }
    }
}

/// A single item in the playback order
struct PlaybackItem: Identifiable, Codable, Equatable {
    let id: UUID
    var sectionId: UUID           // Reference to SectionDefinition
    var repeatCount: Int
    
    init(id: UUID = UUID(), sectionId: UUID, repeatCount: Int = 1) {
        self.id = id
        self.sectionId = sectionId
        self.repeatCount = max(1, repeatCount)
    }
}

// MARK: - Combined Progression

/// Helper to combine sections into a single progression for analysis/playback
extension Array where Element == SectionDefinition {
    /// Combines multiple sections according to playback order
    func combinedProgression(order: PlaybackOrder) -> [String?] {
        var combined: [String?] = []
        
        for sectionId in order.expandedSectionIds {
            if let section = first(where: { $0.id == sectionId }) {
                combined.append(contentsOf: section.chords)
            }
        }
        
        return combined
    }
    
    /// Analyzes key modulation between sections
    func detectModulations(order: PlaybackOrder) -> [ModulationPoint] {
        var modulations: [ModulationPoint] = []
        var currentKey: String?
        var barIndex = 0
        
        for sectionId in order.expandedSectionIds {
            guard let section = first(where: { $0.id == sectionId }) else {
                continue
            }
            
            guard let sectionKey = section.key else {
                barIndex += section.chords.count
                continue
            }
            
            // Check if key changed
            if let prevKey = currentKey, prevKey != sectionKey {
                modulations.append(ModulationPoint(
                    barIndex: barIndex,
                    fromKey: prevKey,
                    toKey: sectionKey,
                    sectionName: section.name
                ))
            }
            
            currentKey = sectionKey
            barIndex += section.chords.count
        }
        
        return modulations
    }
}

/// Represents a key modulation point in the progression
struct ModulationPoint: Identifiable {
    let id = UUID()
    let barIndex: Int
    let fromKey: String
    let toKey: String
    let sectionName: String
    
    var displayName: String {
        "\(fromKey) → \(toKey) at \(sectionName)"
    }
}

