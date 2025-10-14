import SwiftUI

// MARK: - Notification Extension
extension Notification.Name {
    static let loadSketch = Notification.Name("loadSketch")
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ProgressionView()
                .tabItem {
                    Label("Chord Progression", systemImage: "music.note.list")
                }
                .tag(0)
            
            FindChordsView()
                .tabItem {
                    Label("Find Chords", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            SketchListView()
                .tabItem {
                    Label("Sketches", systemImage: "music.note")
                }
                .tag(2)
            
            ReferenceView()
                .tabItem {
                    Label("Resources", systemImage: "book")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .onReceive(NotificationCenter.default.publisher(for: .loadSketch)) { _ in
            // Switch to Chord Progression tab when loading a sketch
            selectedTab = 0
        }
    }
}

#Preview {
    MainTabView()
}

