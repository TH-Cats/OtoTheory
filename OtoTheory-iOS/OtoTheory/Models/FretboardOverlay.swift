//
//  FretboardOverlay.swift
//  OtoTheory
//
//  Phase E-1: Fretboard Component - Data Model
//

import Foundation

/// Represents the two-layer overlay system for the fretboard
struct FretboardOverlay {
    // MARK: - Scale Layer (Ghost)
    
    /// Root pitch class (0-11) for the scale
    var scaleRootPc: Int?
    
    /// Scale type (e.g., "Ionian", "Dorian", "Major Pentatonic")
    var scaleType: String?
    
    /// Whether to show scale ghost notes
    var showScaleGhost: Bool = true
    
    // MARK: - Chord Layer (Main)
    
    /// Chord notes as pitch names (e.g., ["C", "E", "G"])
    var chordNotes: [String]?
    
    // MARK: - Display Mode
    
    /// Display mode for fretboard markers
    var display: DisplayMode = .degrees
    
    enum DisplayMode: String {
        case degrees  // Show degrees (1, 2, 3, b3, 5, b7, etc.)
        case names    // Show note names (C, D, E, F, G, etc.)
    }
    
    // MARK: - Computed Properties
    
    /// Whether the scale layer has data
    var hasScale: Bool {
        scaleRootPc != nil && scaleType != nil
    }
    
    /// Whether the chord layer has data
    var hasChord: Bool {
        !(chordNotes?.isEmpty ?? true)
    }
    
    /// Whether to show ghost notes (scale layer visible)
    var shouldShowGhost: Bool {
        showScaleGhost && hasScale
    }
    
    // MARK: - Factory Methods
    
    /// Create an overlay with only scale layer
    static func scaleOnly(rootPc: Int, scaleType: String, display: DisplayMode = .degrees) -> FretboardOverlay {
        FretboardOverlay(
            scaleRootPc: rootPc,
            scaleType: scaleType,
            showScaleGhost: true,
            chordNotes: nil,
            display: display
        )
    }
    
    /// Create an overlay with both scale and chord layers
    static func scaleAndChord(rootPc: Int, scaleType: String, chordNotes: [String], display: DisplayMode = .degrees) -> FretboardOverlay {
        FretboardOverlay(
            scaleRootPc: rootPc,
            scaleType: scaleType,
            showScaleGhost: true,
            chordNotes: chordNotes,
            display: display
        )
    }
    
    /// Reset chord layer (keep scale layer)
    mutating func resetChord() {
        chordNotes = nil
    }
    
    /// Toggle display mode
    mutating func toggleDisplay() {
        display = display == .degrees ? .names : .degrees
    }
}

