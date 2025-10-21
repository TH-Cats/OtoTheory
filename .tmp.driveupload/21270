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
    let suggestions: [ScaleSuggestion]
    
    switch quality {
    case .major:
        suggestions = [
            ScaleSuggestion(
                scaleId: "major",
                label: getScaleDisplayName("major"),
                reason: getScaleReason("major")
            ),
            ScaleSuggestion(
                scaleId: "lydian",
                label: getScaleDisplayName("lydian"),
                reason: getScaleReason("lydian")
            ),
            ScaleSuggestion(
                scaleId: "majPent",
                label: getScaleDisplayName("majPent"),
                reason: getScaleReason("majPent")
            )
        ]
    case .minor:
        suggestions = [
            ScaleSuggestion(
                scaleId: "naturalMinor",
                label: getScaleDisplayName("naturalMinor"),
                reason: getScaleReason("naturalMinor")
            ),
            ScaleSuggestion(
                scaleId: "dorian",
                label: getScaleDisplayName("dorian"),
                reason: getScaleReason("dorian")
            ),
            ScaleSuggestion(
                scaleId: "minPent",
                label: getScaleDisplayName("minPent"),
                reason: getScaleReason("minPent")
            )
        ]
    case .diminished:
        suggestions = [
            ScaleSuggestion(
                scaleId: "dimWholeHalf",
                label: getScaleDisplayName("dimWholeHalf"),
                reason: getScaleReason("dimWholeHalf")
            ),
            ScaleSuggestion(
                scaleId: "locrian",
                label: getScaleDisplayName("locrian"),
                reason: getScaleReason("locrian")
            ),
            ScaleSuggestion(
                scaleId: "dimHalfWhole",
                label: getScaleDisplayName("dimHalfWhole"),
                reason: getScaleReason("dimHalfWhole")
            )
        ]
    }
    
    // Limit to maximum 3 suggestions
    return Array(suggestions.prefix(3))
}

private func getScaleDisplayName(_ scaleId: String) -> String {
    guard let scale = ScaleMaster.scaleById(scaleId) else {
        return scaleId
    }
    
    let isJapanese = Bundle.main.preferredLocalizations.first == "ja"
    return isJapanese ? scale.scaleJa : scale.scaleEn
}

private func getScaleReason(_ scaleId: String) -> String {
    guard let scale = ScaleMaster.scaleById(scaleId) else {
        return "Scale information not available"
    }
    
    let isJapanese = Bundle.main.preferredLocalizations.first == "ja"
    let comments = isJapanese ? scale.comments.ja : scale.comments.en
    
    // Use the "use" section as the reason
    return comments.use
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

