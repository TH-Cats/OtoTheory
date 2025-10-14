import Foundation
import CloudKit

/// CloudKit manager for syncing sketches across devices (Pro feature)
@MainActor
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    
    private let container: CKContainer
    private let database: CKDatabase
    private let recordType = "Sketch"
    
    // MARK: - Initialization
    
    private init() {
        self.container = CKContainer.default()
        self.database = container.privateCloudDatabase
    }
    
    // MARK: - Sync Status
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error(String)
        
        var description: String {
            switch self {
            case .idle: return "Idle"
            case .syncing: return "Syncing..."
            case .success: return "Synced"
            case .error(let message): return "Error: \(message)"
            }
        }
    }
    
    // MARK: - Check iCloud Availability
    
    func checkiCloudStatus() async -> Bool {
        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                print("☁️ iCloud available")
                return true
            case .noAccount:
                print("⚠️ No iCloud account")
                return false
            case .restricted:
                print("⚠️ iCloud restricted")
                return false
            case .couldNotDetermine:
                print("⚠️ Could not determine iCloud status")
                return false
            case .temporarilyUnavailable:
                print("⚠️ iCloud temporarily unavailable")
                return false
            @unknown default:
                print("⚠️ Unknown iCloud status")
                return false
            }
        } catch {
            print("❌ Error checking iCloud status: \(error)")
            return false
        }
    }
    
    // MARK: - Save Sketch to CloudKit
    
    func saveSketch(_ sketch: Sketch) async throws {
        syncStatus = .syncing
        
        let record: CKRecord
        
        // Check if record exists (update) or create new
        if let existingRecord = try? await fetchRecord(withID: sketch.id) {
            record = existingRecord
        } else {
            record = CKRecord(recordType: recordType, recordID: CKRecord.ID(recordName: sketch.id))
        }
        
        // Populate record fields
        record["name"] = sketch.name as CKRecordValue
        record["bpm"] = sketch.bpm as CKRecordValue
        record["lastModified"] = sketch.lastModified as CKRecordValue
        record["useSectionMode"] = sketch.useSectionMode as CKRecordValue
        record["fretboardDisplay"] = sketch.fretboardDisplay.rawValue as CKRecordValue
        
        // Optional fields
        if let key = sketch.key {
            record["key"] = key as CKRecordValue
        }
        if let scale = sketch.scale {
            record["scale"] = scale as CKRecordValue
        }
        
        // JSON encode complex structures
        if let chordsData = try? JSONEncoder().encode(sketch.chords) {
            record["chords"] = chordsData as CKRecordValue
        }
        
        if let sectionsData = try? JSONEncoder().encode(sketch.sectionDefinitions) {
            record["sectionDefinitions"] = sectionsData as CKRecordValue
        }
        
        if let playbackOrderData = try? JSONEncoder().encode(sketch.playbackOrder) {
            record["playbackOrder"] = playbackOrderData as CKRecordValue
        }
        
        do {
            _ = try await database.save(record)
            print("☁️ Saved sketch to iCloud: \(sketch.name) (ID: \(sketch.id))")
            syncStatus = .success
            lastSyncDate = Date()
        } catch {
            print("❌ Error saving to iCloud: \(error)")
            syncStatus = .error(error.localizedDescription)
            throw error
        }
    }
    
    // MARK: - Fetch Single Record
    
    private func fetchRecord(withID id: String) async throws -> CKRecord? {
        let recordID = CKRecord.ID(recordName: id)
        do {
            let record = try await database.record(for: recordID)
            return record
        } catch let error as CKError where error.code == .unknownItem {
            // Record doesn't exist yet
            return nil
        } catch {
            throw error
        }
    }
    
    // MARK: - Fetch All Sketches
    
    func fetchAllSketches() async throws -> [Sketch] {
        syncStatus = .syncing
        
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "lastModified", ascending: false)]
        
        do {
            let (matchResults, _) = try await database.records(matching: query)
            
            var sketches: [Sketch] = []
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    if let sketch = parseSketch(from: record) {
                        sketches.append(sketch)
                    }
                case .failure(let error):
                    print("❌ Error fetching record: \(error)")
                }
            }
            
            print("☁️ Fetched \(sketches.count) sketches from iCloud")
            syncStatus = .success
            lastSyncDate = Date()
            
            return sketches
        } catch {
            print("❌ Error fetching sketches: \(error)")
            syncStatus = .error(error.localizedDescription)
            throw error
        }
    }
    
    // MARK: - Delete Sketch
    
    func deleteSketch(withID id: String) async throws {
        syncStatus = .syncing
        
        let recordID = CKRecord.ID(recordName: id)
        
        do {
            try await database.deleteRecord(withID: recordID)
            print("☁️ Deleted sketch from iCloud: \(id)")
            syncStatus = .success
            lastSyncDate = Date()
        } catch {
            print("❌ Error deleting from iCloud: \(error)")
            syncStatus = .error(error.localizedDescription)
            throw error
        }
    }
    
    // MARK: - Parse Record to Sketch
    
    private func parseSketch(from record: CKRecord) -> Sketch? {
        guard let name = record["name"] as? String,
              let bpm = record["bpm"] as? Double,
              let lastModified = record["lastModified"] as? Date,
              let useSectionMode = record["useSectionMode"] as? Bool,
              let fretboardDisplayRaw = record["fretboardDisplay"] as? String,
              let fretboardDisplay = FretboardDisplayMode(rawValue: fretboardDisplayRaw) else {
            print("⚠️ Failed to parse required fields from record")
            return nil
        }
        
        let key = record["key"] as? String
        let scale = record["scale"] as? String
        
        // Decode chords
        var chords: [String?] = Array(repeating: nil, count: 12)
        if let chordsData = record["chords"] as? Data,
           let decodedChords = try? JSONDecoder().decode([String?].self, from: chordsData) {
            chords = decodedChords
        }
        
        // Decode section definitions
        var sectionDefinitions: [SectionDefinition] = []
        if let sectionsData = record["sectionDefinitions"] as? Data,
           let decodedSections = try? JSONDecoder().decode([SectionDefinition].self, from: sectionsData) {
            sectionDefinitions = decodedSections
        }
        
        // Decode playback order
        var playbackOrder = PlaybackOrder()
        if let playbackOrderData = record["playbackOrder"] as? Data,
           let decodedOrder = try? JSONDecoder().decode(PlaybackOrder.self, from: playbackOrderData) {
            playbackOrder = decodedOrder
        }
        
        return Sketch(
            id: record.recordID.recordName,
            name: name,
            chords: chords,
            key: key,
            scale: scale,
            bpm: bpm,
            fretboardDisplay: fretboardDisplay,
            sectionDefinitions: sectionDefinitions,
            playbackOrder: playbackOrder,
            useSectionMode: useSectionMode,
            lastModified: lastModified
        )
    }
    
    // MARK: - Sync All
    
    func syncAll(localSketches: [Sketch]) async throws -> [Sketch] {
        syncStatus = .syncing
        
        // Fetch cloud sketches
        let cloudSketches = try await fetchAllSketches()
        
        // Merge logic: last modified wins
        var mergedSketches: [String: Sketch] = [:]
        
        // Add cloud sketches
        for sketch in cloudSketches {
            mergedSketches[sketch.id] = sketch
        }
        
        // Merge local sketches (newer wins)
        for localSketch in localSketches {
            if let cloudSketch = mergedSketches[localSketch.id] {
                // Conflict resolution: last modified wins
                if localSketch.lastModified > cloudSketch.lastModified {
                    mergedSketches[localSketch.id] = localSketch
                    // Upload newer local version
                    try await saveSketch(localSketch)
                }
            } else {
                // New local sketch, upload to cloud
                mergedSketches[localSketch.id] = localSketch
                try await saveSketch(localSketch)
            }
        }
        
        let result = Array(mergedSketches.values).sorted { $0.lastModified > $1.lastModified }
        
        syncStatus = .success
        lastSyncDate = Date()
        
        print("☁️ Sync complete: \(result.count) sketches")
        
        return result
    }
}

