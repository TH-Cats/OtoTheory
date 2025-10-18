import SwiftUI

// MARK: - Notification Extension
extension Notification.Name {
    static let loadSketch = Notification.Name("loadSketch")
    static let navigateToChordLibrary = Notification.Name("navigateToChordLibrary")
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var targetChordForLibrary: String? = nil
    @State private var highlightChordInLibrary: Bool = false
    
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
            
            ChordLibraryView(
                targetChord: $targetChordForLibrary,
                highlightChord: $highlightChordInLibrary
            )
                .tabItem {
                    Label("Chord Library", systemImage: "guitars.fill")
                }
                .tag(2)
            
            SketchListView()
                .tabItem {
                    Label("Sketches", systemImage: "music.note")
                }
                .tag(3)
            
            ReferenceView()
                .tabItem {
                    Label("Resources", systemImage: "book")
                }
                .tag(4)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .onReceive(NotificationCenter.default.publisher(for: .loadSketch)) { _ in
            // Switch to Chord Progression tab when loading a sketch
            selectedTab = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToChordLibrary)) { notification in
            // Navigate to Chord Library tab and highlight specific chord
            if let chordName = notification.object as? String {
                targetChordForLibrary = chordName
                selectedTab = 2
                highlightChordInLibrary = true
            }
        }
    }
}

#Preview {
    MainTabView()
}

