//
//  AppDelegate.swift
//  OtoTheory
//
//  App delegate for managing app-level settings
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return OrientationManager.shared.supportedOrientations
    }
}

