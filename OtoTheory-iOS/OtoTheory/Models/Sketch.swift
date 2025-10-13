import Foundation

struct Sketch: Identifiable, Codable {
    let id: String
    var name: String
    var chords: [String?] // 12 slots, nil = empty
    var key: String?
    var scale: String?
    var bpm: Double
    var sections: [Section]  // Phase 2: Song structure (Pro feature)
    var lastModified: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        chords: [String?],
        key: String? = nil,
        scale: String? = nil,
        bpm: Double = 120,
        sections: [Section] = [],
        lastModified: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.chords = chords
        self.key = key
        self.scale = scale
        self.bpm = bpm
        self.sections = sections
        self.lastModified = lastModified
    }
}

// MARK: - Sketch Manager

@MainActor
class SketchManager: ObservableObject {
    @Published var sketches: [Sketch] = []
    
    private let maxSketches = 3 // Free tier limit
    private let storageKey = "OtoTheory.Sketches"
    
    init() {
        loadSketches()
    }
    
    // MARK: - Load
    
    func loadSketches() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Sketch].self, from: data) else {
            sketches = []
            return
        }
        
        // Sort by last modified (most recent first)
        sketches = decoded.sorted { $0.lastModified > $1.lastModified }
    }
    
    // MARK: - Save
    
    func save(_ sketch: Sketch) {
        var updatedSketch = sketch
        updatedSketch.lastModified = Date()
        
        // Check if sketch already exists (update by ID)
        if let index = sketches.firstIndex(where: { $0.id == sketch.id }) {
            // Update existing sketch
            sketches[index] = updatedSketch
            print("📝 Updated existing sketch: \(sketch.name) (ID: \(sketch.id))")
        } else {
            // New sketch - apply LRU if at limit
            if sketches.count >= maxSketches {
                let removed = sketches.removeLast()
                print("🗑️ Removed oldest sketch (LRU): \(removed.name)")
            }
            sketches.insert(updatedSketch, at: 0)
            print("✅ Added new sketch: \(sketch.name) (ID: \(sketch.id))")
        }
        
        // Sort by last modified
        sketches.sort { $0.lastModified > $1.lastModified }
        
        print("💾 Total sketches: \(sketches.count)/\(maxSketches)")
        
        persistSketches()
    }
    
    // MARK: - Delete
    
    func delete(_ sketch: Sketch) {
        sketches.removeAll { $0.id == sketch.id }
        persistSketches()
    }
    
    // MARK: - Rename
    
    func rename(_ sketch: Sketch, to newName: String) {
        guard let index = sketches.firstIndex(where: { $0.id == sketch.id }) else { return }
        sketches[index].name = newName
        sketches[index].lastModified = Date()
        
        // Re-sort
        sketches.sort { $0.lastModified > $1.lastModified }
        
        persistSketches()
    }
    
    // MARK: - Helpers
    
    private func persistSketches() {
        guard let encoded = try? JSONEncoder().encode(sketches) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
    
    var canAddMore: Bool {
        sketches.count < maxSketches
    }
    
    func generateDefaultName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return "Sketch \(dateFormatter.string(from: Date()))"
    }
}

