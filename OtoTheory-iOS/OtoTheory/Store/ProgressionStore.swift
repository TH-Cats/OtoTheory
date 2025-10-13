//
//  ProgressionStore.swift
//  OtoTheory
//
//  Phase E-4A: Shared progression store for chord management
//  Phase E-5: Section-specific chord progressions
//

import SwiftUI
import Combine

class ProgressionStore: ObservableObject {
    static let shared = ProgressionStore()
    
    // MARK: - Simple Mode (Legacy)
    @Published var slots: [String?] = Array(repeating: nil, count: 12)
    @Published var lastAddedSlotIndex: Int? = nil  // For highlighting newly added chords
    
    // MARK: - Section Mode (Phase E-5)
    @Published var useSectionMode: Bool = false
    @Published var sectionDefinitions: [SectionDefinition] = []
    @Published var playbackOrder: PlaybackOrder = PlaybackOrder()
    @Published var currentSectionId: UUID?  // Currently editing section
    
    // MARK: - Chord Management
    
    /// Add chord to the next available slot
    /// - Parameter chord: Chord name (e.g., "C", "Dm", "G7")
    /// - Returns: True if added successfully, false if progression is full
    @discardableResult
    func addChord(_ chord: String) -> Bool {
        guard let emptyIndex = slots.firstIndex(of: nil) else {
            return false  // Progression is full
        }
        
        slots[emptyIndex] = chord
        lastAddedSlotIndex = emptyIndex
        print("✅ Added \(chord) to slot \(emptyIndex)")
        
        // Clear highlight after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if self?.lastAddedSlotIndex == emptyIndex {
                self?.lastAddedSlotIndex = nil
            }
        }
        
        return true
    }
    
    /// Add chord to a specific slot
    /// - Parameters:
    ///   - chord: Chord name
    ///   - index: Target slot index (0-11)
    func addChord(_ chord: String, at index: Int) {
        guard index >= 0 && index < slots.count else { return }
        slots[index] = chord
    }
    
    /// Remove chord from a specific slot
    /// - Parameter index: Slot index to clear
    func removeChord(at index: Int) {
        guard index >= 0 && index < slots.count else { return }
        slots[index] = nil
    }
    
    /// Clear all slots
    func clearAll() {
        slots = Array(repeating: nil, count: 12)
    }
    
    /// Get next available slot index
    /// - Returns: Next empty slot index, or nil if full
    func nextAvailableSlot() -> Int? {
        return slots.firstIndex(of: nil)
    }
    
    /// Check if progression has available slots
    var hasAvailableSlots: Bool {
        return slots.contains(nil)
    }
    
    /// Count of filled slots
    var filledSlotsCount: Int {
        return slots.compactMap { $0 }.count
    }
    
    // MARK: - Section Mode Management
    
    /// Currently editing section (for chord input)
    var currentSection: SectionDefinition? {
        get {
            guard let id = currentSectionId else { return nil }
            return sectionDefinitions.first(where: { $0.id == id })
        }
        set {
            if let section = newValue {
                if let index = sectionDefinitions.firstIndex(where: { $0.id == section.id }) {
                    sectionDefinitions[index] = section
                }
            }
        }
    }
    
    /// Get slots for the current section (or legacy slots if not in section mode)
    var activeSlots: [String?] {
        if useSectionMode, let section = currentSection {
            return section.chords
        }
        return slots
    }
    
    /// Add chord in section mode
    /// - Parameter chord: Chord name
    /// - Returns: True if added successfully
    @discardableResult
    func addChordToSection(_ chord: String) -> Bool {
        guard useSectionMode,
              let sectionId = currentSectionId,
              let index = sectionDefinitions.firstIndex(where: { $0.id == sectionId }) else {
            // Fallback to legacy mode
            return addChord(chord)
        }
        
        guard let emptySlot = sectionDefinitions[index].chords.firstIndex(of: nil) else {
            return false  // Section is full
        }
        
        // Update the section
        var updatedSection = sectionDefinitions[index]
        updatedSection.chords[emptySlot] = chord
        sectionDefinitions[index] = updatedSection
        
        lastAddedSlotIndex = emptySlot
        
        print("✅ Added \(chord) to section '\(sectionDefinitions[index].name)' slot \(emptySlot)")
        print("🔍 Section chords: \(sectionDefinitions[index].chords.compactMap { $0 })")
        
        // Manually trigger objectWillChange
        objectWillChange.send()
        
        // Clear highlight after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if self?.lastAddedSlotIndex == emptySlot {
                self?.lastAddedSlotIndex = nil
            }
        }
        
        return true
    }
    
    /// Update chord in section mode
    func updateSectionChord(_ chord: String?, at slotIndex: Int) {
        guard useSectionMode,
              let sectionId = currentSectionId,
              let index = sectionDefinitions.firstIndex(where: { $0.id == sectionId }),
              slotIndex >= 0 && slotIndex < 12 else {
            return
        }
        
        var updatedSection = sectionDefinitions[index]
        updatedSection.chords[slotIndex] = chord
        sectionDefinitions[index] = updatedSection
        
        // Manually trigger objectWillChange
        objectWillChange.send()
    }
    
    /// Create a new section definition
    func createSection(name: String, type: SectionType) -> UUID {
        let section = SectionDefinition(name: name, type: type)
        sectionDefinitions.append(section)
        
        // Add to playback order
        let item = PlaybackItem(sectionId: section.id)
        playbackOrder.items.append(item)
        
        // Set as current
        currentSectionId = section.id
        
        return section.id
    }
    
    /// Delete a section definition
    func deleteSection(id: UUID) {
        sectionDefinitions.removeAll(where: { $0.id == id })
        playbackOrder.items.removeAll(where: { $0.sectionId == id })
        
        if currentSectionId == id {
            currentSectionId = sectionDefinitions.first?.id
        }
    }
    
    /// Duplicate a section definition
    func duplicateSection(id: UUID, withName newName: String) -> UUID? {
        guard let section = sectionDefinitions.first(where: { $0.id == id }) else {
            return nil
        }
        
        let duplicate = section.duplicate(withName: newName)
        sectionDefinitions.append(duplicate)
        
        // Add to playback order (after the original)
        if let originalIndex = playbackOrder.items.firstIndex(where: { $0.sectionId == id }) {
            let item = PlaybackItem(sectionId: duplicate.id)
            playbackOrder.items.insert(item, at: originalIndex + 1)
        } else {
            // If original not in playback order, append to end
            let item = PlaybackItem(sectionId: duplicate.id)
            playbackOrder.items.append(item)
        }
        
        return duplicate.id
    }
    
    /// Get combined progression for analysis
    var combinedProgression: [String?] {
        if useSectionMode && !sectionDefinitions.isEmpty {
            return sectionDefinitions.combinedProgression(order: playbackOrder)
        }
        return slots
    }
    
    /// Enable section mode (Pro feature)
    func enableSectionMode() {
        useSectionMode = true
        
        // Create a default section from current slots if they have chords
        if filledSlotsCount > 0 && sectionDefinitions.isEmpty {
            let section = SectionDefinition(
                name: "Main",
                type: .verse,
                chords: slots
            )
            sectionDefinitions.append(section)
            
            let item = PlaybackItem(sectionId: section.id)
            playbackOrder.items.append(item)
            
            currentSectionId = section.id
        }
    }
    
    /// Disable section mode
    func disableSectionMode() {
        useSectionMode = false
    }
    
    /// Clear all section data
    func clearSections() {
        sectionDefinitions.removeAll()
        playbackOrder = PlaybackOrder()
        currentSectionId = nil
    }
}

