//
//  FretboardHelpers.swift
//  OtoTheory
//
//  Phase E-1: Helper functions for fretboard calculations
//

import Foundation
import SwiftUI

struct FretboardHelpers {
    // MARK: - Scale Definitions (Simplified for MVP)
    
    static let scaleIntervals: [String: [Int]] = [
        "Ionian": [0, 2, 4, 5, 7, 9, 11],           // Major Scale
        "Dorian": [0, 2, 3, 5, 7, 9, 10],
        "Phrygian": [0, 1, 3, 5, 7, 8, 10],
        "Lydian": [0, 2, 4, 6, 7, 9, 11],
        "Mixolydian": [0, 2, 4, 5, 7, 9, 10],
        "Aeolian": [0, 2, 3, 5, 7, 8, 10],          // Natural Minor
        "Locrian": [0, 1, 3, 5, 6, 8, 10],
        "MajorPentatonic": [0, 2, 4, 7, 9],
        "MinorPentatonic": [0, 3, 5, 7, 10],
        "Blues": [0, 3, 5, 6, 7, 10],
        "HarmonicMinor": [0, 2, 3, 5, 7, 8, 11],
        "MelodicMinor": [0, 2, 3, 5, 7, 9, 11],
        "DiminishedWH": [0, 2, 3, 5, 6, 8, 9, 11],  // Whole-Half Diminished
        "DiminishedHW": [0, 1, 3, 4, 6, 7, 9, 10]   // Half-Whole Diminished
    ]
    
    // MARK: - Degree Labels
    
    static func degreeLabel(for pitchClass: Int, root: Int, scaleType: String) -> String? {
        let interval = (pitchClass - root + 12) % 12
        
        // Check if in scale
        guard let intervals = scaleIntervals[scaleType],
              intervals.contains(interval) else {
            return nil
        }
        
        // Map interval to degree
        switch interval {
        case 0: return "R"    // 1 → R
        case 1: return "♭II"  // b2 → ♭II
        case 2: return "II"   // 2 → II
        case 3: return "♭III" // b3 → ♭III
        case 4: return "III"  // 3 → III
        case 5: return "IV"   // 4 → IV
        case 6: return "♭V"   // b5 → ♭V
        case 7: return "V"    // 5 → V
        case 8: return "♭VI"  // b6 → ♭VI
        case 9: return "VI"   // 6 → VI
        case 10: return "♭VII"// b7 → ♭VII
        case 11: return "VII" // 7 → VII
        default: return nil
        }
    }
    
    // MARK: - Color for Degree
    
    static func colorForDegree(_ degree: String?, isRoot: Bool) -> Color {
        if isRoot {
            return Color.orange  // Root
        }
        
        guard let degree = degree else {
            return Color.gray.opacity(0.5)
        }

        // Roman表記に対応（♭/♯を除去し、ベースのローマ数字で判定）
        let base = degree
            .replacingOccurrences(of: "♭", with: "")
            .replacingOccurrences(of: "♯", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        switch base {
        case "III":
            return Color.blue   // 3rd
        case "V":
            return Color.green  // 5th
        case "VII":
            return Color.purple // 7th
        default:
            return Color.gray.opacity(0.7)  // その他のスケール音
        }
    }
    
    // MARK: - Check if in scale
    
    static func isInScale(pitchClass: Int, root: Int, scaleType: String) -> Bool {
        let interval = (pitchClass - root + 12) % 12
        return scaleIntervals[scaleType]?.contains(interval) ?? false
    }
}

