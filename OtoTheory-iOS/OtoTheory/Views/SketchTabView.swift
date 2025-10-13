import SwiftUI

struct SketchTabView: View {
    @StateObject private var sketchManager = SketchManager()
    @State private var editingSketch: Sketch?
    @State private var newName: String = ""
    @State private var showLoadAlert = false
    @State private var selectedSketch: Sketch?
    
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
                        
                        Text("Save your chord progressions from the Home tab")
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
                                    selectedSketch = sketch
                                    showLoadAlert = true
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
            .alert("Load Sketch", isPresented: $showLoadAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Load") {
                    if let sketch = selectedSketch {
                        loadSketchIntoProgression(sketch)
                    }
                }
            } message: {
                Text("Switch to Home tab to load this sketch into your progression.")
            }
        }
    }
    
    private func loadSketchIntoProgression(_ sketch: Sketch) {
        // Store the sketch to load
        UserDefaults.standard.set(sketch.id, forKey: "pendingSketchLoad")
        
        // Post notification to switch tab and load
        NotificationCenter.default.post(
            name: .loadSketch,
            object: nil,
            userInfo: ["sketchId": sketch.id]
        )
    }
}

// MARK: - Notification Extension

extension Notification.Name {
    static let loadSketch = Notification.Name("loadSketch")
}

#Preview {
    SketchTabView()
}

