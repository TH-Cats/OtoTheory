//
//  ScaleSuggestions.swift
//  OtoTheory
//
//  Suggest appropriate scales for a given chord quality
//

import Foundation

struct ScaleSuggestion {
    let scaleId: String
    let label: String
    let reason: String
}

func suggestScalesForChord(quality: ChordQuality, chordIndex: Int = 0) -> [ScaleSuggestion] {
    switch quality {
    case .major:
        return [
            ScaleSuggestion(
                scaleId: "Ionian",
                label: "Major Scale",
                reason: "Foundation for major chords – fits all diatonic tones"
            ),
            ScaleSuggestion(
                scaleId: "Lydian",
                label: "Lydian (#4 Color)",
                reason: "Bright color with raised 4th (#11) – jazz/modern sound"
            )
        ]
    case .minor:
        return [
            ScaleSuggestion(
                scaleId: "Aeolian",
                label: "Natural Minor",
                reason: "Natural minor foundation – matches all minor scale tones"
            ),
            ScaleSuggestion(
                scaleId: "Dorian",
                label: "Dorian (Bright Minor)",
                reason: "Brighter minor with natural 6th – popular in jazz and funk"
            ),
            ScaleSuggestion(
                scaleId: "Phrygian",
                label: "Phrygian (Dark Minor)",
                reason: "Dark minor with flat 2nd – Spanish/flamenco character"
            )
        ]
    case .diminished:
        return [
            ScaleSuggestion(
                scaleId: "DiminishedWholeHalf",
                label: "Whole–Half Dim",
                reason: "Symmetrical whole-half pattern – creates tension over diminished chords"
            ),
            ScaleSuggestion(
                scaleId: "Locrian",
                label: "Locrian",
                reason: "Outlines half-diminished chord – starts on the 7th degree"
            )
        ]
    }
}

enum ChordQuality {
    case major
    case minor
    case diminished
    
    static func from(chordName: String) -> ChordQuality? {
        let normalized = chordName.lowercased()
        if normalized.contains("dim") || normalized.contains("°") {
            return .diminished
        } else if normalized.contains("m") {
            return .minor
        } else {
            return .major
        }
    }
}

