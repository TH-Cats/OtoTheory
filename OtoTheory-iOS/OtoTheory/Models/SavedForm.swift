//
//  SavedForm.swift
//  OtoTheory
//
//  My Forms data model and manager
//  Free: UserDefaults (max 30, LRU)
//  Pro: CloudKit sync (unlimited)
//

import Foundation
import SwiftUI
import CloudKit

// MARK: - Saved Form Model

struct SavedForm: Identifiable, Codable {
    let id: UUID
    let root: String  // ChordRoot.rawValue
    let quality: String  // ChordLibraryQuality.rawValue
    let shapeKind: String  // ShapeKind.rawValue
    let symbol: String  // "Cmaj7"
    let createdAt: Date
    var ckRecordName: String?  // CloudKit record ID
    
    init(
        id: UUID = UUID(),
        root: String,
        quality: String,
        shapeKind: String,
        symbol: String,
        createdAt: Date = Date(),
        ckRecordName: String? = nil
    ) {
        self.id = id
        self.root = root
        self.quality = quality
        self.shapeKind = shapeKind
        self.symbol = symbol
        self.createdAt = createdAt
        self.ckRecordName = ckRecordName
    }
    
    /// Convert to CloudKit record
    func toCKRecord() -> CKRecord {
        let record: CKRecord
        if let recordName = ckRecordName {
            let recordID = CKRecord.ID(recordName: recordName)
            record = CKRecord(recordType: "SavedForm", recordID: recordID)
        } else {
            record = CKRecord(recordType: "SavedForm")
        }
        
        record["id"] = id.uuidString as CKRecordValue
        record["root"] = root as CKRecordValue
        record["quality"] = quality as CKRecordValue
        record["shapeKind"] = shapeKind as CKRecordValue
        record["symbol"] = symbol as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        
        return record
    }
    
    /// Create from CloudKit record
    static func fromCKRecord(_ record: CKRecord) -> SavedForm? {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString),
              let root = record["root"] as? String,
              let quality = record["quality"] as? String,
              let shapeKind = record["shapeKind"] as? String,
              let symbol = record["symbol"] as? String,
              let createdAt = record["createdAt"] as? Date else {
            return nil
        }
        
        return SavedForm(
            id: id,
            root: root,
            quality: quality,
            shapeKind: shapeKind,
            symbol: symbol,
            createdAt: createdAt,
            ckRecordName: record.recordID.recordName
        )
    }
}

// MARK: - Saved Forms Manager

@MainActor
class SavedFormsManager: ObservableObject {
    static let shared = SavedFormsManager()
    
    @Published var savedForms: [SavedForm] = []
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    private let maxFreeCount = 30
    private let userDefaultsKey = "savedForms"
    private let cloudKitManager = CloudKitManager.shared
    
    private init() {
        loadFromUserDefaults()
    }
    
    // MARK: - CRUD Operations
    
    /// Save a new form
    func save(_ form: SavedForm) {
        // Check Free limit
        if !ProManager.shared.isProUser && savedForms.count >= maxFreeCount {
            // Remove oldest form (LRU)
            if let oldestIndex = savedForms.enumerated()
                .min(by: { $0.element.createdAt < $1.element.createdAt })?.offset {
                savedForms.remove(at: oldestIndex)
            }
        }
        
        savedForms.insert(form, at: 0)
        saveToUserDefaults()
        
        // Sync to CloudKit if Pro
        if ProManager.shared.isProUser {
            Task {
                await syncFormToCloud(form)
            }
        }
        
        // Track telemetry
        TelemetryService.shared.track(.formSaved, payload: [
            "root": form.root,
            "quality": form.quality,
            "shapeKind": form.shapeKind
        ])
    }
    
    /// Delete a form
    func delete(_ form: SavedForm) {
        savedForms.removeAll { $0.id == form.id }
        saveToUserDefaults()
        
        // Delete from CloudKit if Pro
        if ProManager.shared.isProUser, let recordName = form.ckRecordName {
            Task {
                await deleteFormFromCloud(recordName)
            }
        }
        
        // Track telemetry
        TelemetryService.shared.track(.formDeleted, payload: [
            "root": form.root,
            "quality": form.quality
        ])
    }
    
    /// Check if a form is already saved
    func isSaved(root: String, quality: String, shapeKind: String) -> Bool {
        return savedForms.contains { form in
            form.root == root && form.quality == quality && form.shapeKind == shapeKind
        }
    }
    
    // MARK: - UserDefaults Persistence
    
    private func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let forms = try? JSONDecoder().decode([SavedForm].self, from: data) else {
            return
        }
        savedForms = forms
    }
    
    private func saveToUserDefaults() {
        guard let data = try? JSONEncoder().encode(savedForms) else {
            print("❌ Failed to encode saved forms")
            return
        }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
    
    // MARK: - CloudKit Sync
    
    /// Sync a single form to CloudKit
    private func syncFormToCloud(_ form: SavedForm) async {
        do {
            let record = form.toCKRecord()
            try await cloudKitManager.saveRecord(record)
            print("✅ Form synced to CloudKit: \(form.symbol)")
        } catch {
            print("❌ Failed to sync form to CloudKit: \(error)")
            syncError = error.localizedDescription
        }
    }
    
    /// Delete a form from CloudKit
    private func deleteFormFromCloud(_ recordName: String) async {
        do {
            let recordID = CKRecord.ID(recordName: recordName)
            try await cloudKitManager.deleteRecord(recordID)
            print("✅ Form deleted from CloudKit")
        } catch {
            print("❌ Failed to delete form from CloudKit: \(error)")
        }
    }
    
    /// Full sync with CloudKit (for Pro users)
    func syncWithCloud() async {
        guard ProManager.shared.isProUser else { return }
        
        isSyncing = true
        syncError = nil
        
        do {
            // Fetch all forms from CloudKit
            let query = CKQuery(recordType: "SavedForm", predicate: NSPredicate(value: true))
            let records = try await cloudKitManager.fetchRecords(query: query)
            
            let cloudForms = records.compactMap { SavedForm.fromCKRecord($0) }
            
            // Merge with local forms (Last-Write-Wins based on createdAt)
            var mergedForms: [String: SavedForm] = [:]
            
            // Add local forms
            for form in savedForms {
                let key = "\(form.root)-\(form.quality)-\(form.shapeKind)"
                mergedForms[key] = form
            }
            
            // Merge cloud forms (replace if newer)
            for cloudForm in cloudForms {
                let key = "\(cloudForm.root)-\(cloudForm.quality)-\(cloudForm.shapeKind)"
                if let localForm = mergedForms[key] {
                    // Keep newer version
                    if cloudForm.createdAt > localForm.createdAt {
                        mergedForms[key] = cloudForm
                    }
                } else {
                    mergedForms[key] = cloudForm
                }
            }
            
            // Update local list
            savedForms = Array(mergedForms.values).sorted { $0.createdAt > $1.createdAt }
            saveToUserDefaults()
            
            lastSyncDate = Date()
            print("✅ Forms synced with CloudKit: \(savedForms.count) forms")
            
        } catch {
            print("❌ Failed to sync forms with CloudKit: \(error)")
            syncError = error.localizedDescription
        }
        
        isSyncing = false
    }
}

// MARK: - CloudKit Manager Extension

extension CloudKitManager {
    /// Save a record to CloudKit
    func saveRecord(_ record: CKRecord) async throws {
        let container = CKContainer(identifier: "iCloud.TH-Quest.OtoTheory")
        let database = container.privateCloudDatabase
        
        _ = try await database.save(record)
    }
    
    /// Delete a record from CloudKit
    func deleteRecord(_ recordID: CKRecord.ID) async throws {
        let container = CKContainer(identifier: "iCloud.TH-Quest.OtoTheory")
        let database = container.privateCloudDatabase
        
        _ = try await database.deleteRecord(withID: recordID)
    }
    
    /// Fetch records from CloudKit
    func fetchRecords(query: CKQuery) async throws -> [CKRecord] {
        let container = CKContainer(identifier: "iCloud.TH-Quest.OtoTheory")
        let database = container.privateCloudDatabase
        
        let (matchResults, _) = try await database.records(matching: query)
        
        var records: [CKRecord] = []
        for (_, result) in matchResults {
            switch result {
            case .success(let record):
                records.append(record)
            case .failure(let error):
                print("⚠️ Failed to fetch record: \(error)")
            }
        }
        
        return records
    }
}

