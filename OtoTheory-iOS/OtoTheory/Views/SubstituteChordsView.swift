//
//  SubstituteChordsView.swift
//  OtoTheory
//
//  Substitute chords for a selected chord (collapsible)
//

import SwiftUI

struct SubstituteChordsView: View {
    let context: ChordContext
    let onPlay: (String) -> Void
    let onLongPress: ((String) -> Void)?  // Optional long press handler for adding to progression
    
    @State private var isExpanded: Bool = false
    
    private var substitutes: [SubstituteChord] {
        getSubstitutes(context: context)
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
                    Text("Substitute Chords (\(substitutes.count))")
                        .font(.subheadline)
                        .fontWeight(.medium)
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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Alternative chords with similar harmonic function")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                    
                    ForEach(substitutes) { substitute in
                        SubstituteChordRow(
                            substitute: substitute,
                            onPlay: {
                                onPlay(substitute.chord)
                            },
                            onLongPress: {
                                onLongPress?(substitute.chord)
                            }
                        )
                    }
                }
                .padding(12)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}

struct SubstituteChordRow: View {
    let substitute: SubstituteChord
    let onPlay: () -> Void
    let onLongPress: (() -> Void)?
    
    @State private var isAdding: Bool = false
    @State private var addScale: CGFloat = 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(substitute.chord)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(substitute.reason)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    onPlay()
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
            
            // Examples (if available)
            if let examples = substitute.examples, !examples.isEmpty {
                HStack(spacing: 4) {
                    Text("Examples:")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.7))
                    
                    Text(examples.joined(separator: " · "))
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.8))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .scaleEffect(addScale)
        .opacity(isAdding ? 0.5 : 1.0)
        .onLongPressGesture(minimumDuration: 0.5) {
            // "Sucked in" animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                addScale = 0.8
                isAdding = true
            }
            
            // Call long press handler
            onLongPress?()
            
            // Reset animation after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    addScale = 1.0
                    isAdding = false
                }
            }
        }
    }
}

