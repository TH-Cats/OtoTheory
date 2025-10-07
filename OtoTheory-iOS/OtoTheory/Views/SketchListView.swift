import SwiftUI

struct SketchListView: View {
    @ObservedObject var sketchManager: SketchManager
    @Environment(\.dismiss) private var dismiss
    let onLoad: (Sketch) -> Void
    
    @State private var editingSketch: Sketch?
    @State private var newName: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if sketchManager.sketches.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Sketches Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Save your chord progressions to access them later")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Sketch List
                    List {
                        ForEach(sketchManager.sketches) { sketch in
                            SketchRow(
                                sketch: sketch,
                                onLoad: {
                                    onLoad(sketch)
                                    dismiss()
                                },
                                onRename: {
                                    editingSketch = sketch
                                    newName = sketch.name
                                },
                                onDelete: {
                                    sketchManager.delete(sketch)
                                }
                            )
                        }
                    }
                    .listStyle(.plain)
                    
                    // Footer Info
                    VStack(spacing: 8) {
                        Text("\(sketchManager.sketches.count) / \(3) sketches")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !sketchManager.canAddMore {
                            Text("⚠️ Limit reached. Oldest will be replaced.")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Sketches")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Rename Sketch", isPresented: .constant(editingSketch != nil)) {
                TextField("Sketch name", text: $newName)
                Button("Cancel", role: .cancel) {
                    editingSketch = nil
                }
                Button("Save") {
                    if let sketch = editingSketch {
                        sketchManager.rename(sketch, to: newName)
                        editingSketch = nil
                    }
                }
            }
        }
    }
}

// MARK: - Sketch Row

struct SketchRow: View {
    let sketch: Sketch
    let onLoad: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onLoad) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(sketch.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Context Menu Button
                    Menu {
                        Button(action: onRename) {
                            Label("Rename", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                // Chord preview (first 4 non-nil chords)
                HStack(spacing: 4) {
                    ForEach(sketch.chords.compactMap { $0 }.prefix(4), id: \.self) { chord in
                        Text(chord)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    if sketch.chords.compactMap({ $0 }).count > 4 {
                        Text("...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Metadata
                HStack(spacing: 12) {
                    if let key = sketch.key {
                        Label(key, systemImage: "music.note")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Label("\(Int(sketch.bpm)) BPM", systemImage: "metronome")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(sketch.lastModified, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SketchListView(
        sketchManager: {
            let manager = SketchManager()
            manager.sketches = [
                Sketch(name: "My Song", chords: ["C", "Am", "F", "G", nil, nil, nil, nil, nil, nil, nil, nil], key: "C", bpm: 120),
                Sketch(name: "Blues Jam", chords: ["C", "C", "C", "C", "F", "F", "C", "C", "G", "F", "C", "G"], key: "C", bpm: 90)
            ]
            return manager
        }(),
        onLoad: { sketch in
            print("Load: \(sketch.name)")
        }
    )
}


