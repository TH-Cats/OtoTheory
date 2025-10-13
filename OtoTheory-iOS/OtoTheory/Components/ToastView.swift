//
//  ToastView.swift
//  OtoTheory
//
//  Toast notification component for user feedback
//

import SwiftUI

struct ToastView: View {
    let message: String
    let icon: String?
    let backgroundColor: Color
    
    init(message: String, icon: String? = "checkmark.circle.fill", backgroundColor: Color = .green) {
        self.message = message
        self.icon = icon
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 20))
            }
            
            Text(message)
                .font(.system(size: 15, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(backgroundColor.opacity(0.95))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let icon: String?
    let backgroundColor: Color
    let duration: TimeInterval
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    Spacer()
                    
                    ToastView(
                        message: message,
                        icon: icon,
                        backgroundColor: backgroundColor
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowing)
                    .padding(.bottom, 100) // Above tab bar
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: isShowing)
            }
        }
    }
}

extension View {
    func toast(
        isShowing: Binding<Bool>,
        message: String,
        icon: String? = "checkmark.circle.fill",
        backgroundColor: Color = .green,
        duration: TimeInterval = 2.0
    ) -> some View {
        self.modifier(
            ToastModifier(
                isShowing: isShowing,
                message: message,
                icon: icon,
                backgroundColor: backgroundColor,
                duration: duration
            )
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        ToastView(message: "Added C to Progression")
        ToastView(message: "Progression is full", icon: "exclamationmark.triangle.fill", backgroundColor: .orange)
        ToastView(message: "Error occurred", icon: "xmark.circle.fill", backgroundColor: .red)
    }
    .padding()
}

