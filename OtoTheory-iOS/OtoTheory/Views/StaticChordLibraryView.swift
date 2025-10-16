//
//  StaticChordLibraryView.swift
//  OtoTheory
//
//  Static Chord Library UI (v0)
//  Displays chord forms from attached PDF chart
//

import SwiftUI

struct StaticChordLibraryView: View {
    @StateObject private var provider = StaticChordProvider.shared
    @StateObject private var audioPlayer = ChordLibraryAudioPlayer.shared
    @StateObject private var orientationManager = OrientationManager.shared
    
    @State private var selectedChordIndex: Int = 0
    @State private var currentFormIndex: Int = 0
    @State private var displayMode: ChordDisplayMode = .finger
    @State private var showFullscreen: Bool = false
    
    private var selectedChord: StaticChord? {
        guard selectedChordIndex < provider.chords.count else { return nil }
        return provider.chords[selectedChordIndex]
    }
    
    private var currentForm: StaticForm? {
        guard let chord = selectedChord,
              currentFormIndex < chord.forms.count else { return nil }
        return chord.forms[currentFormIndex]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Chord selector (horizontal scroll)
                    chordSelectorSection
                    
                    if let chord = selectedChord {
                        // Chord info + Display Mode
                        chordInfoSection(chord)
                        
                        // Page indicator + Fullscreen button
                        HStack {
                            Spacer()
                            Text("\(currentFormIndex + 1) / \(chord.forms.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            
                            // Fullscreen button
                            Button {
                                showFullscreen = true
                                orientationManager.lockToLandscape()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        .font(.caption)
                                    Text("Fullscreen")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Forms horizontal scroller
                        formsScrollerSection(chord)
                    } else {
                        Text("No chords available")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Chord Library (Static)")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showFullscreen, onDismiss: {
                orientationManager.unlock()
            }) {
                if let chord = selectedChord {
                    StaticChordFullscreenView(
                        chord: chord,
                        currentFormIndex: $currentFormIndex,
                        displayMode: $displayMode,
                        onClose: {
                            showFullscreen = false
                            orientationManager.unlock()
                        }
                    )
                }
            }
            .onAppear {
                // Track page view (using formsViewOpen as proxy)
                TelemetryService.shared.track(.formsViewOpen)
            }
        }
    }
    
    // MARK: - Chord Selector Section
    
    private var chordSelectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Chord")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(provider.chords.enumerated()), id: \.offset) { index, chord in
                        Button(action: {
                            selectedChordIndex = index
                            currentFormIndex = 0  // Reset to first form
                        }) {
                            Text(chord.symbol)
                                .font(.system(size: 16, weight: selectedChordIndex == index ? .bold : .regular))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedChordIndex == index ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedChordIndex == index ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Chord Info Section
    
    private func chordInfoSection(_ chord: StaticChord) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(chord.symbol)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Display mode selector
                HStack(spacing: 4) {
                    ForEach(ChordDisplayMode.allCases) { mode in
                        Button(action: {
                            displayMode = mode
                        }) {
                            Text(mode.rawValue.lowercased())
                                .font(.caption)
                                .fontWeight(displayMode == mode ? .bold : .regular)
                                .frame(width: 50, height: 24)
                                .background(displayMode == mode ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            Text(chord.quality)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Forms Scroller Section
    
    private func formsScrollerSection(_ chord: StaticChord) -> some View {
        let forms = sortForms(chord.forms)
        TabView(selection: $currentFormIndex) {
            ForEach(Array(forms.enumerated()), id: \.offset) { index, form in
                formCardView(form: form, chord: chord)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 500)
    }
    
    // MARK: - Form Card View
    
    private func formCardView(form: StaticForm, chord: StaticChord) -> some View {
        VStack(spacing: 16) {
            // Shape title inferred or explicit
            Text(shapeTitle(for: form))
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(height: 20)
            
            // Diagram
            StaticChordDiagramView(
                form: form,
                rootSemitone: getRootSemitone(from: chord.symbol),
                displayMode: displayMode
            )
            
            // Play buttons
            HStack(spacing: 16) {
                Button(action: {
                    audioPlayer.playStrum(form: form, rootSemitone: getRootSemitone(from: chord.symbol))
                    // Track play event
                    TelemetryService.shared.track(.progressionPlay)
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Play")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    audioPlayer.playArpeggio(form: form, rootSemitone: getRootSemitone(from: chord.symbol))
                    // Track play event
                    TelemetryService.shared.track(.progressionPlay)
                }) {
                    HStack {
                        Image(systemName: "music.note.list")
                        Text("Arp")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                }
            }
            
            // Tips
            if !form.tips.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(form.tips, id: \.self) { tip in
                        Text("• \(tip)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Form Ordering & Title Helpers

    private let desiredOrder: [String] = ["Open", "Root-6", "Root-5", "Root-4", "Triad-1", "Triad-2"]

    private func shapeTitle(for form: StaticForm) -> String {
        if let explicit = form.shapeName, !explicit.isEmpty { return explicit }
        // Heuristics
        let hasOpen = form.frets.contains { if case .open = $0 { return true } else { return false } }
        if hasOpen { return "Open" }
        if form.barres.contains(where: { $0.fromString == 1 && $0.toString == 6 }) { return "Root-6" }
        if form.barres.contains(where: { $0.toString == 5 }) { return "Root-5" }
        let sounding = form.frets.filter { if case .x = $0 { return false } else { return true } }.count
        if sounding <= 3 { return "Triad-1" }
        return "Root-4"
    }

    private func sortForms(_ forms: [StaticForm]) -> [StaticForm] {
        return forms.sorted { a, b in
            let ka = desiredOrder.firstIndex(of: shapeTitle(for: a)) ?? desiredOrder.count
            let kb = desiredOrder.firstIndex(of: shapeTitle(for: b)) ?? desiredOrder.count
            if ka != kb { return ka < kb }
            return a.id < b.id
        }
    }
    
    // MARK: - Helpers
    
    /// Extract root semitone from chord symbol
    private func getRootSemitone(from symbol: String) -> Int {
        // Simple parsing: C=0, C#=1, D=2, etc.
        let noteMap: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1,
            "D": 2, "D#": 3, "Eb": 3,
            "E": 4,
            "F": 5, "F#": 6, "Gb": 6,
            "G": 7, "G#": 8, "Ab": 8,
            "A": 9, "A#": 10, "Bb": 10,
            "B": 11
        ]
        
        // Try 2-char match first (for sharps/flats)
        if symbol.count >= 2 {
            let prefix2 = String(symbol.prefix(2))
            if let semitone = noteMap[prefix2] {
                return semitone
            }
        }
        
        // Try 1-char match
        if symbol.count >= 1 {
            let prefix1 = String(symbol.prefix(1))
            if let semitone = noteMap[prefix1] {
                return semitone
            }
        }
        
        return 0  // Default to C
    }
}

// MARK: - Fullscreen View

struct StaticChordFullscreenView: View {
    let chord: StaticChord
    @Binding var currentFormIndex: Int
    @Binding var displayMode: ChordDisplayMode
    let onClose: () -> Void
    
    @StateObject private var audioPlayer = ChordLibraryAudioPlayer.shared
    
    private var currentForm: StaticForm {
        chord.forms[currentFormIndex]
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    // Chord name and info
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 8) {
                            Text(chord.symbol)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            // Page dots
                            HStack(spacing: 6) {
                                ForEach(0..<chord.forms.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == currentFormIndex ? Color.blue : Color.gray.opacity(0.4))
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                        
                        Text(chord.quality)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Display Mode
                    HStack(spacing: 4) {
                        ForEach(ChordDisplayMode.allCases) { mode in
                            Button(action: {
                                displayMode = mode
                            }) {
                                Text(mode.rawValue.lowercased())
                                    .font(.caption)
                                    .fontWeight(displayMode == mode ? .bold : .regular)
                                    .frame(width: 50, height: 24)
                                    .background(displayMode == mode ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Close button
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.8))
                
                // Main content with TabView for swipe navigation
                TabView(selection: $currentFormIndex) {
                    ForEach(Array(chord.forms.enumerated()), id: \.offset) { index, form in
                        GeometryReader { geometry in
                            HStack(spacing: 16) {
                                // Left: Fretboard (70%)
                                VStack(spacing: 8) {
                                    StaticChordDiagramView(
                                        form: form,
                                        rootSemitone: getRootSemitone(from: chord.symbol),
                                        displayMode: displayMode
                                    )
                                    .frame(height: geometry.size.height * 0.85)
                                }
                                .frame(width: geometry.size.width * 0.7)
                                
                                // Right: Tips + Actions (25%)
                                VStack(alignment: .leading, spacing: 6) {
                                    // Tips
                                    if !form.tips.isEmpty {
                                        VStack(alignment: .leading, spacing: 2) {
                                            ForEach(form.tips, id: \.self) { tip in
                                                Text("• \(tip)")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Action buttons (horizontal)
                                    HStack(spacing: 6) {
                                        Button(action: {
                                            audioPlayer.playStrum(form: form, rootSemitone: getRootSemitone(from: chord.symbol))
                                        }) {
                                            Image(systemName: "play.circle.fill")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .cornerRadius(6)
                                        
                                        Button(action: {
                                            audioPlayer.playArpeggio(form: form, rootSemitone: getRootSemitone(from: chord.symbol))
                                        }) {
                                            Image(systemName: "music.note.list")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(6)
                                    }
                                }
                                .frame(width: geometry.size.width * 0.25)
                                .padding(.trailing)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
    }
    
    /// Extract root semitone from chord symbol
    private func getRootSemitone(from symbol: String) -> Int {
        let noteMap: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1,
            "D": 2, "D#": 3, "Eb": 3,
            "E": 4,
            "F": 5, "F#": 6, "Gb": 6,
            "G": 7, "G#": 8, "Ab": 8,
            "A": 9, "A#": 10, "Bb": 10,
            "B": 11
        ]
        
        if symbol.count >= 2 {
            let prefix2 = String(symbol.prefix(2))
            if let semitone = noteMap[prefix2] {
                return semitone
            }
        }
        
        if symbol.count >= 1 {
            let prefix1 = String(symbol.prefix(1))
            if let semitone = noteMap[prefix1] {
                return semitone
            }
        }
        
        return 0
    }
}

// MARK: - Preview

#Preview {
    StaticChordLibraryView()
}

