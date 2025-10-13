import SwiftUI

struct SettingsView: View {
    @StateObject private var proManager = ProManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Subscription Section
                SwiftUI.Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Plan")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(proManager.isProUser ? "Pro" : "Free")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        if proManager.isProUser {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if !proManager.isProUser {
                        Button(action: { showPaywall = true }) {
                            HStack {
                                Image(systemName: "crown.fill")
                                Text("Upgrade to Pro")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Subscription")
                }
                
                // MARK: - Support Section
                SwiftUI.Section {
                    if let contactURL = URL(string: "https://www.ototheory.com/support") {
                        Link(destination: contactURL) {
                            HStack {
                                Image(systemName: "envelope")
                                Text("Contact Us")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if let faqURL = URL(string: "https://www.ototheory.com/faq") {
                        Link(destination: faqURL) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                Text("FAQ")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Support")
                }
                
                // MARK: - Legal Section
                SwiftUI.Section {
                    if let termsURL = URL(string: "https://www.ototheory.com/terms") {
                        Link(destination: termsURL) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Terms of Service")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if let privacyURL = URL(string: "https://www.ototheory.com/privacy") {
                        Link(destination: privacyURL) {
                            HStack {
                                Image(systemName: "lock.shield")
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Legal")
                }
                
                // MARK: - App Info Section
                SwiftUI.Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(buildNumber)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("App Info")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    // MARK: - App Version Info
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}

#Preview {
    SettingsView()
}
