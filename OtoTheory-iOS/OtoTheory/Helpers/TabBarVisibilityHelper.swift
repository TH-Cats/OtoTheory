//
//  TabBarVisibilityHelper.swift
//  OtoTheory
//
//  Helper to control tab bar visibility
//

import SwiftUI
import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    var tabBarController: UITabBarController? {
        keyWindow?.rootViewController as? UITabBarController
    }
}

struct TabBarVisibilityModifier: ViewModifier {
    let isHidden: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                setTabBarVisibility(hidden: isHidden)
            }
            .onChange(of: isHidden) { _, newValue in
                setTabBarVisibility(hidden: newValue)
            }
    }
    
    private func setTabBarVisibility(hidden: Bool) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let tabBarController = window.rootViewController as? UITabBarController else {
            return
        }
        
        let tabBar = tabBarController.tabBar
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            if hidden {
                // Move tab bar off-screen and hide it
                tabBar.frame.origin.y = window.bounds.height
                tabBar.alpha = 0
                tabBar.isHidden = true
            } else {
                // Show tab bar and move it back to position
                tabBar.isHidden = false
                tabBar.alpha = 1
                tabBar.frame.origin.y = window.bounds.height - tabBar.frame.height
            }
        }
    }
}

extension View {
    func tabBarHidden(_ hidden: Bool) -> some View {
        modifier(TabBarVisibilityModifier(isHidden: hidden))
    }
}

