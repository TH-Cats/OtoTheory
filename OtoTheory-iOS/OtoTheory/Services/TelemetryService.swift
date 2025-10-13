//
//  TelemetryService.swift
//  OtoTheory
//
//  Phase 1: IAP & Paywall telemetry support
//

import Foundation

/// OtoTheory iOS telemetry events
enum TelemetryEvent: String {
    // Playback
    case progressionPlay = "progression_play"
    case instrumentChange = "instrument_change"
    
    // Preset
    case presetInserted = "preset_inserted"
    
    // Pro / IAP
    case paywallView = "paywall_view"
    case purchaseSuccess = "purchase_success"
    case purchaseFail = "purchase_fail"
    case restoreSuccess = "restore_success"
    case restoreFail = "restore_fail"
    
    // Sections (Phase 2)
    case sectionEdit = "section_edit"
    case sectionPlay = "section_play"
    
    // MIDI (Phase 3)
    case midiExport = "midi_export"
    
    // Sketch
    case saveProject = "save_project"
    case openProject = "open_project"
    case projectDelete = "project_delete"
    case projectLimitWarn = "project_limit_warn"
    case projectLimitBlock = "project_limit_block"
}

/// Telemetry service for iOS
class TelemetryService {
    static let shared = TelemetryService()
    
    private init() {}
    
    /// Track an event
    func track(_ event: TelemetryEvent, payload: [String: Any] = [:]) {
        var body: [String: Any] = [
            "ev": event.rawValue,
            "platform": "ios",
            "ts": Date().timeIntervalSince1970
        ]
        
        // Merge payload
        body.merge(payload) { (_, new) in new }
        
        // Send to server
        sendToServer(body)
        
        // Debug log
        #if DEBUG
        print("[TelemetryService] \(event.rawValue) \(payload)")
        #endif
    }
    
    /// Send telemetry data to server
    private func sendToServer(_ body: [String: Any]) {
        guard let url = URL(string: "https://ototheory.com/api/telemetry") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("[TelemetryService] Failed to serialize JSON: \(error)")
            return
        }
        
        // Fire and forget
        URLSession.shared.dataTask(with: request).resume()
    }
}

// MARK: - Convenience methods

extension TelemetryService {
    /// Track paywall view
    func trackPaywallView() {
        track(.paywallView)
    }
    
    /// Track purchase success
    func trackPurchaseSuccess(productId: String) {
        track(.purchaseSuccess, payload: ["product_id": productId])
    }
    
    /// Track purchase failure
    func trackPurchaseFail(error: String) {
        track(.purchaseFail, payload: ["error": error])
    }
    
    /// Track restore success
    func trackRestoreSuccess() {
        track(.restoreSuccess)
    }
    
    /// Track restore failure
    func trackRestoreFail(error: String) {
        track(.restoreFail, payload: ["error": error])
    }
}

