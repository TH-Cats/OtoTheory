import Foundation

struct Sketch: Identifiable, Codable {
    let id: String
    var name: String
    var chords: [String?] // 12 slots, nil = empty (used when not in section mode)
    var key: String?
    var scale: String?
    var bpm: Double
    var fretboardDisplay: FretboardDisplayMode  // Degrees or Names
    
    // Section Mode (Pro feature)
    var sectionDefinitions: [SectionDefinition]
    var playbackOrder: PlaybackOrder
    var useSectionMode: Bool
    
    var lastModified: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        chords: [String?],
        key: String? = nil,
        scale: String? = nil,
        bpm: Double = 120,
        fretboardDisplay: FretboardDisplayMode = .degrees,
        sectionDefinitions: [SectionDefinition] = [],
        playbackOrder: PlaybackOrder = PlaybackOrder(),
        useSectionMode: Bool = false,
        lastModified: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.chords = chords
        self.key = key
        self.scale = scale
        self.bpm = bpm
        self.fretboardDisplay = fretboardDisplay
        self.sectionDefinitions = sectionDefinitions
        self.playbackOrder = playbackOrder
        self.useSectionMode = useSectionMode
        self.lastModified = lastModified
    }
}

// MARK: - Fretboard Display Mode

enum FretboardDisplayMode: String, Codable {
    case degrees = "Degrees"
    case names = "Names"
}

// MARK: - Sketch Manager

@MainActor
class SketchManager: ObservableObject {
    static let shared = SketchManager()
    
    @Published var sketches: [Sketch] = []
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    private let maxSketchesFree = 3 // Free tier limit
    private let storageKey = "OtoTheory.Sketches"
    
    private let proManager = ProManager.shared
    private let cloudKitManager = CloudKitManager.shared
    
    private init() {
        loadSketches()
    }
    
    // MARK: - Pro Features
    
    var maxSketches: Int {
        proManager.isProUser ? Int.max : maxSketchesFree
    }
    
    var canUseCloudSync: Bool {
        proManager.isProUser
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
            // New sketch - apply LRU if at limit (Free tier only)
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
        
        // Persist locally first
        persistSketches()
        
        // Upload to iCloud if Pro user
        if canUseCloudSync {
            Task {
                do {
                    try await cloudKitManager.saveSketch(updatedSketch)
                    await MainActor.run {
                        self.lastSyncDate = Date()
                        self.syncError = nil
                    }
                } catch {
                    print("⚠️ Failed to sync to iCloud: \(error)")
                    await MainActor.run {
                        self.syncError = error.localizedDescription
                    }
                }
            }
        }
    }
    
    // MARK: - Delete
    
    func delete(_ sketch: Sketch) {
        sketches.removeAll { $0.id == sketch.id }
        persistSketches()
        
        // Delete from iCloud if Pro user
        if canUseCloudSync {
            Task {
                do {
                    try await cloudKitManager.deleteSketch(withID: sketch.id)
                    await MainActor.run {
                        self.lastSyncDate = Date()
                        self.syncError = nil
                    }
                } catch {
                    print("⚠️ Failed to delete from iCloud: \(error)")
                    await MainActor.run {
                        self.syncError = error.localizedDescription
                    }
                }
            }
        }
    }
    
    // MARK: - Rename
    
    func rename(_ sketch: Sketch, to newName: String) {
        guard let index = sketches.firstIndex(where: { $0.id == sketch.id }) else { return }
        sketches[index].name = newName
        sketches[index].lastModified = Date()
        
        // Re-sort
        sketches.sort { $0.lastModified > $1.lastModified }
        
        persistSketches()
        
        // Upload to iCloud if Pro user
        if canUseCloudSync {
            let updatedSketch = sketches[index]
            Task {
                do {
                    try await cloudKitManager.saveSketch(updatedSketch)
                    await MainActor.run {
                        self.lastSyncDate = Date()
                        self.syncError = nil
                    }
                } catch {
                    print("⚠️ Failed to sync renamed sketch: \(error)")
                    await MainActor.run {
                        self.syncError = error.localizedDescription
                    }
                }
            }
        }
    }
    
    // MARK: - Cloud Sync
    
    func syncWithCloud() async {
        guard canUseCloudSync else {
            print("⚠️ Cloud sync not available (not a Pro user)")
            return
        }
        
        isSyncing = true
        syncError = nil
        
        do {
            // Check iCloud availability
            let isAvailable = await cloudKitManager.checkiCloudStatus()
            guard isAvailable else {
                syncError = "iCloud is not available. Please check your iCloud settings."
                isSyncing = false
                return
            }
            
            // Sync all sketches
            let mergedSketches = try await cloudKitManager.syncAll(localSketches: sketches)
            
            // Update local storage
            sketches = mergedSketches
            persistSketches()
            
            lastSyncDate = Date()
            syncError = nil
            
            print("✅ Cloud sync completed: \(sketches.count) sketches")
        } catch {
            print("❌ Cloud sync failed: \(error)")
            syncError = error.localizedDescription
        }
        
        isSyncing = false
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

