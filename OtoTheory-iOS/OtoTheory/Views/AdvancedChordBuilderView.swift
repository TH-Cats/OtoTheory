//
//  AdvancedChordBuilderView.swift
//  OtoTheory
//
//  Phase E-4B: Advanced Chord Builder (Pro)
//

import SwiftUI

struct AdvancedChordBuilderView: View {
    @Binding var showAdvanced: Bool
    @Binding var selectedQuick: String
    @Binding var selectedSlashBass: String?
    let isPro: Bool
    let onShowPaywall: () -> Void
    
    private let roots = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    private let extensionChords = ["6", "m6", "9", "m9", "11", "M11", "13", "M13"]
    private let alteredDominant = ["7b5", "7#5", "7b9", "7#9", "7#11", "7b13", "7alt"]
    private let diminishedVariants = ["dim7", "m7b5"]
    private let suspensionsAdds = ["sus2", "add9", "add11", "add13", "6/9"]
    private let augMM7 = ["aug", "mM7"]
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $showAdvanced,
            content: {
                VStack(spacing: 16) {
                    // Extensions
                    chordCategory(title: "Extensions", chords: extensionChords)
                    
                    // Altered Dominant
                    chordCategory(title: "Altered Dominant", chords: alteredDominant)
                    
                    // Diminished / Variants
                    chordCategory(title: "Diminished / Variants", chords: diminishedVariants)
                    
                    // Suspensions / Adds
                    chordCategory(title: "Suspensions / Adds", chords: suspensionsAdds)
                    
                    // Aug / mM7
                    chordCategory(title: "Aug / mM7", chords: augMM7)
                    
                    // Slash Chords (On Bass)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Slash (On)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                // Clear button
                                Button(action: {
                                    selectedSlashBass = nil
                                }) {
                                    Text("Clear")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .frame(minWidth: 50)
                                        .padding(.vertical, 10)
                                        .background(selectedSlashBass == nil ? Color.orange : Color.gray.opacity(0.15))
                                        .foregroundColor(selectedSlashBass == nil ? .white : .primary)
                                        .cornerRadius(6)
                                }
                                
                                ForEach(roots, id: \.self) { bass in
                                    Button(action: {
                                        selectedSlashBass = bass
                                    }) {
                                        Text(bass)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .frame(minWidth: 40)
                                            .padding(.vertical, 10)
                                            .background(selectedSlashBass == bass ? Color.blue : Color.gray.opacity(0.15))
                                            .foregroundColor(selectedSlashBass == bass ? .white : .primary)
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            },
            label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                        .foregroundColor(.orange)
                    Text("Advanced")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Pro badge
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                        Text("Pro")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        )
        .onTapGesture {
            // Pro check when tapping to expand
            if !showAdvanced && !isPro {
                onShowPaywall()
            } else {
                showAdvanced.toggle()
            }
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func chordCategory(title: String, chords: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chords, id: \.self) { chord in
                        Button(action: {
                            selectedQuick = chord
                            selectedSlashBass = nil
                        }) {
                            Text(chord)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(minWidth: 50)
                                .padding(.vertical, 10)
                                .background(selectedQuick == chord ? Color.blue : Color.gray.opacity(0.15))
                                .foregroundColor(selectedQuick == chord ? .white : .primary)
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
    }
}

