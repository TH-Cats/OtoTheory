//
//  SavedFormsView.swift
//  OtoTheory
//
//  My Forms UI - saved chord forms
//  Free: max 30, Pro: unlimited
//

import SwiftUI

struct SavedFormsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var savedFormsManager = SavedFormsManager.shared
    @StateObject private var proManager = ProManager.shared
    @StateObject private var libraryManager = ChordLibraryManager.shared
    
    @State private var selectedShape: ChordShape?
    @State private var selectedRoot: ChordRoot?
    @State private var selectedQuality: ChordLibraryQuality?
    @State private var showChordDetail: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with count
                HStack {
                    Text("\(savedFormsManager.savedForms.count) Saved Forms")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if !proManager.isProUser {
                        Text("\(savedFormsManager.savedForms.count)/30")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                
                // List of saved forms
                if savedFormsManager.savedForms.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(savedFormsManager.savedForms) { form in
                            SavedFormRow(form: form, onTap: {
                                // Load the chord detail
                                if let root = ChordRoot(rawValue: form.root),
                                   let quality = ChordLibraryQuality(rawValue: form.quality),
                                   let chordEntry = libraryManager.getChord(root: root, quality: quality),
                                   let shape = chordEntry.shapes.first(where: { $0.kind == form.shapeKind }) {
                                    selectedRoot = root
                                    selectedQuality = quality
                                    selectedShape = shape
                                    showChordDetail = true
                                }
                            }, onDelete: {
                                savedFormsManager.delete(form)
                            })
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Forms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if proManager.isProUser && !savedFormsManager.savedForms.isEmpty {
                        Button(action: {
                            Task {
                                await savedFormsManager.syncWithCloud()
                            }
                        }) {
                            HStack {
                                if savedFormsManager.isSyncing {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showChordDetail) {
                if let root = selectedRoot,
                   let quality = selectedQuality,
                   let shape = selectedShape {
                    ChordDetailSheet(root: root, quality: quality, shape: shape)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "star")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Saved Forms")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Save chord forms from the Chord Library to quickly access them later")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Saved Form Row

struct SavedFormRow: View {
    let form: SavedForm
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Icon
                Image(systemName: "music.note")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                // Form info
                VStack(alignment: .leading, spacing: 4) {
                    Text(form.symbol)
                        .font(.headline)
                    
                    HStack {
                        Text(form.shapeKind)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(formatRelativeDate(form.createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.vertical, 8)
        }
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

// MARK: - Chord Detail Sheet

struct ChordDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    let root: ChordRoot
    let quality: ChordLibraryQuality
    let shape: ChordShape
    
    @State private var displayMode: ChordDisplayMode = .finger
    @StateObject private var audioPlayer = ChordLibraryAudioPlayer.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Chord symbol
                Text("\(root.displayName)\(quality.displayName)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Shape info
                HStack {
                    Text(shape.kind)
                        .font(.title2)
                    Text(shape.label)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Display mode picker
                Picker("Display Mode", selection: $displayMode) {
                    ForEach(ChordDisplayMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Diagram
                ChordDiagramView(
                    shape: shape,
                    root: root,
                    displayMode: displayMode
                )
                
                // Tips
                if !shape.tips.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(shape.tips, id: \.self) { tip in
                            Text("• \(tip)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .padding()
                }
                
                // Play buttons
                HStack(spacing: 40) {
                    Button(action: {
                        audioPlayer.playStrum(shape: shape, root: root)
                    }) {
                        VStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                            Text("Play")
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        audioPlayer.playArpeggio(shape: shape, root: root)
                    }) {
                        VStack {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 50))
                            Text("Arp")
                                .font(.caption)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Saved Form")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SavedFormsView()
}

