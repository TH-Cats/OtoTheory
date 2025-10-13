//
//  OrientationManager.swift
//  OtoTheory
//
//  Manages device orientation preferences
//

import SwiftUI
import UIKit

/// Manages orientation lock state across the app
class OrientationManager: ObservableObject {
    static let shared = OrientationManager()
    
    @Published var forceLandscape: Bool = false
    
    private init() {}
    
    /// Lock to landscape orientation
    func lockToLandscape() {
        forceLandscape = true
        updateOrientation()
    }
    
    /// Unlock orientation (allow all)
    func unlock() {
        forceLandscape = false
        updateOrientation()
    }
    
    /// Request the system to update orientation
    private func updateOrientation() {
        // Force the orientation to update
        if #available(iOS 16.0, *) {
            // iOS 16+ uses different API
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: forceLandscape ? .landscape : .all))
            
            // Notify all view controllers to update their supported orientations
            windowScene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            // iOS 15 and below
            UIDevice.current.setValue(forceLandscape ? UIInterfaceOrientation.landscapeRight.rawValue : UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            
            // Notify the system that orientation preferences changed
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    var supportedOrientations: UIInterfaceOrientationMask {
        return forceLandscape ? .landscape : .all
    }
}

