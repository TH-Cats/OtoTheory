//
//  BuildProgressionView.swift
//  OtoTheory
//
//  Phase E-4C: Build Progression Section Component
//

import SwiftUI

struct BuildProgressionView: View {
    let slots: [String?]
    let cursorIndex: Int
    let currentSlotIndex: Int?
    let lastAddedSlotIndex: Int?
    let sections: [Section]
    let isPlaying: Bool
    let bpm: Double
    let instruments: [(String, Int)]
    let selectedInstrument: Int
    let isPro: Bool
    
    let onSlotTap: (Int) -> Void
    let onSlotDelete: (Int) -> Void
    let onSlotLongPress: (Int) -> Void
    let onReset: () -> Void
    let onPreset: () -> Void
    let onSections: () -> Void
    let onPlayPause: () -> Void
    let onBPMChange: (Double) -> Void
    let onInstrumentChange: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text("Build Progression")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            // Buttons - 1 row
            HStack(spacing: 8) {
                // Preset Button
                Button(action: onPreset) {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note.list")
                        Text("Preset")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                // Sections Button (Pro only)
                if isPro {
                    Button(action: onSections) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.grid.3x2")
                            Text("Sections")
                            if !sections.isEmpty {
                                Text("(\(sections.count))")
                                    .font(.caption)
                            }
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                // Reset Button
                Button(action: onReset) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            
            // Playback controls
            HStack(spacing: 12) {
                // Play/Pause button
                Button(action: onPlayPause) {
                    HStack(spacing: 6) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        Text(isPlaying ? "Pause" : "Play")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isPlaying ? Color.orange : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(slots.compactMap({ $0 }).isEmpty)
                .opacity(slots.compactMap({ $0 }).isEmpty ? 0.5 : 1.0)
                
                // BPM
                VStack(alignment: .leading, spacing: 4) {
                    Text("BPM")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text("\(Int(bpm))")
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(width: 50, alignment: .center)
                        
                        Stepper("", value: Binding(
                            get: { bpm },
                            set: { onBPMChange($0) }
                        ), in: 40...240, step: 5)
                        .labelsHidden()
                    }
                }
                
                // Instrument Picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sound")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("", selection: Binding(
                        get: { selectedInstrument },
                        set: { onInstrumentChange($0) }
                    )) {
                        ForEach(0..<instruments.count, id: \.self) { index in
                            Text(instruments[index].0).tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .padding(.horizontal)
            
            // Section Markers
            if !sections.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(sections.sortedByRange) { section in
                            SectionMarker(section: section)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
            }
            
            // 12 Slots Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(0..<12) { index in
                    SlotView(
                        index: index,
                        chord: slots[index],
                        isCursor: index == cursorIndex,
                        isPlaying: currentSlotIndex == index,
                        isHighlighted: lastAddedSlotIndex == index,
                        onTap: { onSlotTap(index) },
                        onDelete: slots[index] != nil ? { onSlotDelete(index) } : nil
                    )
                    .onLongPressGesture(minimumDuration: 0.5) {
                        if slots[index] != nil {
                            onSlotLongPress(index)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

