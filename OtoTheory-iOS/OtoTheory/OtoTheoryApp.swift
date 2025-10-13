//
//  OtoTheoryApp.swift
//  OtoTheory
//
//  Created by Norito Harada on 2025/10/04.
//

import SwiftUI

@main
struct OtoTheoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        audioTrace("BOOT mark — app did launch")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
