//
//  ScaleSuggestionsView.swift
//  OtoTheory
//
//  Suggested scales for a selected chord (collapsible)
//

import SwiftUI
import AVFoundation

struct ScaleSuggestionsView: View {
    let chordQuality: ChordQuality
    let selectedKey: String
    @Binding var previewScaleId: String?
    let scalePreviewPlayer: ScalePreviewPlayer
    let onResetPreview: () -> Void
    
    @State private var isExpanded: Bool = false
    @State private var showScaleInfo: Bool = false
    @State private var selectedScaleForInfo: String = ""
    
    private let keyToPitchClass: [String: Int] = [
        "C": 0, "C#": 1, "D": 2, "Eb": 3, "E": 4, "F": 5,
        "F#": 6, "G": 7, "Ab": 8, "A": 9, "Bb": 10, "B": 11
    ]
    
    private var suggestions: [ScaleSuggestion] {
        suggestScalesForChord(quality: chordQuality)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Collapsible header
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Suggested scales for this chord")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            // Content (collapsible)
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Scale chips with Reset button
                    HStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(suggestions.enumerated()), id: \.element.scaleId) { index, suggestion in
                                    HStack(spacing: 4) {
                                        Button {
                                            previewScaleId = suggestion.scaleId
                                            playScalePreview(scaleId: suggestion.scaleId)
                                        } label: {
                                            Text(suggestion.label)
                                                .font(.system(size: 14, weight: previewScaleId == suggestion.scaleId ? .bold : .semibold))
                                                .foregroundColor(previewScaleId == suggestion.scaleId ? .white : .primary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(previewScaleId == suggestion.scaleId ? Color.blue : Color(.systemGray4))
                                                )
                                        }
                                        .buttonStyle(.plain)
                                        
                                        // Lightbulb info button
                                        Button {
                                            selectedScaleForInfo = suggestion.scaleId
                                            showScaleInfo = true
                                        } label: {
                                            Image(systemName: "lightbulb.fill")
                                                .foregroundColor(.orange)
                                                .font(.system(size: 14))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        
                        Button {
                            onResetPreview()
                        } label: {
                            Text("Reset")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray5))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // "Why" explanation (only for selected scale)
                    if let previewScaleId = previewScaleId,
                       let selectedSuggestion = suggestions.first(where: { $0.scaleId == previewScaleId }) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(selectedSuggestion.reason)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showScaleInfo) {
            ScaleInfoSheet(scaleId: selectedScaleForInfo)
        }
    }
    
    private func playScaleArpeggio(scaleId: String) {
        // Play scale using ScalePreviewPlayer
        let rootPc = keyToPitchClass[selectedKey] ?? 0
        
        // Use ScalePreviewPlayer's playScale method
        scalePreviewPlayer.playScale(root: rootPc, scaleType: scaleId, octave: 4)
    }
    
    private func playScalePreview(scaleId: String) {
        // Play scale using ScalePreviewPlayer
        let rootPc = keyToPitchClass[selectedKey] ?? 0
        
        // Map scale ID to old format for ScalePreviewPlayer
        let oldScaleType = mapScaleIdToOldType(scaleId)
        
        print("🎵 Playing scale preview: \(selectedKey) \(oldScaleType)")
        scalePreviewPlayer.playScale(root: rootPc, scaleType: oldScaleType, octave: 4)
    }
    
    private func mapScaleIdToOldType(_ scaleId: String) -> String {
        switch scaleId {
        case "major": return "Ionian"
        case "naturalMinor": return "Aeolian"
        case "dorian": return "Dorian"
        case "phrygian": return "Phrygian"
        case "lydian": return "Lydian"
        case "mixolydian": return "Mixolydian"
        case "locrian": return "Locrian"
        case "majPent": return "MajorPentatonic"
        case "minPent": return "MinorPentatonic"
        case "bluesMinor": return "Blues"
        case "harmonicMinor": return "HarmonicMinor"
        case "melodicMinor": return "MelodicMinor"
        case "dimWholeHalf": return "DiminishedWH"
        case "dimHalfWhole": return "DiminishedHW"
        case "lydianb7": return "Lydianb7"
        case "mixolydianb6": return "Mixolydianb6"
        case "phrygDominant": return "PhrygianDominant"
        case "altered": return "Altered"
        case "wholeTone": return "WholeTone"
        default: return scaleId
        }
    }
}

