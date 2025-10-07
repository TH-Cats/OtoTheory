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
            
            ReferenceView()
                .tabItem {
                    Label("Reference", systemImage: "book")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainTabView()
}

