import SwiftUI

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
            
            SketchTabView()
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
    }
}

#Preview {
    MainTabView()
}

