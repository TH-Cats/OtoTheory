//
//  SlashChordEditorView.swift
//  OtoTheory
//
//  Phase E-4C: Slash Chord Editor (Pro)
//

import SwiftUI

struct SlashChordEditorView: View {
    let originalChord: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedBass: String? = nil
    
    private let bassNotes = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
    
    // 既存のスラッシュコードを分解
    private var baseChord: String {
        originalChord.components(separatedBy: "/").first ?? originalChord
    }
    
    private var currentBass: String? {
        let parts = originalChord.components(separatedBy: "/")
        return parts.count > 1 ? parts[1] : nil
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with Pro badge
            HStack {
                Text("Edit: \(originalChord)")
                    .font(.headline)
                
                Spacer()
                
                // Pro badge
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12))
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
            
            Divider()
            
            // Add Bass Note section
            VStack(alignment: .leading, spacing: 12) {
                Text("Add Bass Note (On)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                    ForEach(bassNotes, id: \.self) { bass in
                        Button {
                            // 同じベース音は無視（C → C/C は無意味）
                            // ルート音を抽出（例: "Cmaj7" → "C"、"F#m" → "F#"）
                            let rootNote = extractRootNote(from: baseChord)
                            if bass != rootNote {
                                let newChord = "\(baseChord)/\(bass)"
                                onSave(newChord)
                                dismiss()
                            }
                        } label: {
                            Text(bass)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(currentBass == bass ? .white : .primary)
                                .frame(width: 50, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(currentBass == bass ? Color.blue : Color.blue.opacity(0.15))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Divider()
            
            // Actions
            VStack(spacing: 12) {
                // Remove slash (if exists)
                if currentBass != nil {
                    Button {
                        onSave(baseChord)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "minus.circle")
                            Text("Remove Slash (/\(currentBass!))")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                    }
                }
                
                // Delete chord
                Button(role: .destructive) {
                    onSave("")  // Empty = delete
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Chord")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.15))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
                
                // Cancel
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.secondary)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
    
    // Extract root note from chord (e.g., "Cmaj7" → "C", "F#m" → "F#", "Bbdim" → "Bb")
    private func extractRootNote(from chord: String) -> String {
        let possibleRoots = ["C#", "D#", "F#", "G#", "A#", "Eb", "Ab", "Bb",  // Sharp/Flat first (2 chars)
                             "C", "D", "E", "F", "G", "A", "B"]  // Natural (1 char)
        
        for root in possibleRoots {
            if chord.hasPrefix(root) {
                return root
            }
        }
        
        return String(chord.prefix(1))  // Fallback: first character
    }
}

#Preview {
    SlashChordEditorView(
        originalChord: "C",
        onSave: { chord in
            print("Saved: \(chord)")
        }
    )
}

