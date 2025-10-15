//
//  ChordLibraryView.swift
//  OtoTheory
//
//  Main UI for Chord Library
//  Displays 5 forms with horizontal scrolling
//

import SwiftUI

struct ChordLibraryView: View {
    @StateObject private var audioPlayer = ChordLibraryAudioPlayer.shared
    @StateObject private var libraryManager = ChordLibraryManager.shared
    @StateObject private var savedFormsManager = SavedFormsManager.shared
    
    @State private var selectedRoot: ChordRoot = .C
    @State private var selectedQuality: ChordLibraryQuality = .M
    @State private var displayMode: ChordDisplayMode = .finger
    @State private var showAdvanced: Bool = false
    @State private var currentShapeIndex: Int = 0
    @State private var showMyForms: Bool = false
    
    // Orientation detection
    @State private var isLandscape: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // My Forms button
                    Button(action: {
                        showMyForms = true
                        TelemetryService.shared.track(.formsViewOpen)
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("My Forms (\(savedFormsManager.savedForms.count))")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showMyForms) {
                        SavedFormsView()
                    }
                    // Landscape hint (show in portrait)
                    if !isLandscape {
                        landscapeHint
                    }
                    
                    // Root selector
                    rootSelectorSection
                    
                    // Quality selector
                    qualitySelectorSection
                    
                    // Display mode toggle
                    displayModeSection
                    
                    // Chord info
                    if let chordEntry = libraryManager.getChord(root: selectedRoot, quality: selectedQuality) {
                        chordInfoSection(chordEntry)
                        
                        // 5 Forms horizontal scroller
                        formsScrollerSection(chordEntry)
                    } else {
                        Text("Chord not available")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Chord Library")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                detectOrientation()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                detectOrientation()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Landscape Hint
    
    private var landscapeHint: some View {
        HStack {
            Image(systemName: "rotate.right")
                .foregroundColor(.orange)
            Text("Rotate device for landscape view for better experience")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Root Selector
    
    private var rootSelectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Root")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ChordRoot.allCases) { root in
                        Button(action: {
                            selectedRoot = root
                            currentShapeIndex = 0
                        }) {
                            Text(root.displayName)
                                .font(.body)
                                .fontWeight(selectedRoot == root ? .bold : .regular)
                                .frame(minWidth: 44, minHeight: 44)
                                .background(selectedRoot == root ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedRoot == root ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Quality Selector
    
    private var qualitySelectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Quality")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showAdvanced.toggle()
                    }
                }) {
                    HStack {
                        Text(showAdvanced ? "Show Less" : "Show Advanced")
                            .font(.caption)
                        Image(systemName: showAdvanced ? "chevron.up" : "chevron.down")
                            .font(.caption)
                    }
                }
            }
            
            // Quick qualities
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach([ChordLibraryQuality.M, .m, .seven, .M7, .m7, .dim, .sus4], id: \.self) { quality in
                        qualityChip(quality)
                    }
                }
            }
            
            // Advanced qualities
            if showAdvanced {
                VStack(alignment: .leading, spacing: 12) {
                    qualitySection(title: "Extended", qualities: [.six, .m6, .nine, .M9, .m9, .eleven, .M11, .thirteen, .M13, .m13])
                    qualitySection(title: "Altered", qualities: [.sevenb9, .sevenSharp9, .sevenb5, .sevenSharp5, .sevenSharp11])
                    qualitySection(title: "Other", qualities: [.aug, .dim7, .m7b5, .sus2, .add9, .sixNine, .mM7])
                }
            }
        }
    }
    
    private func qualitySection(title: String, qualities: [ChordLibraryQuality]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(qualities, id: \.self) { quality in
                        qualityChip(quality)
                    }
                }
            }
        }
    }
    
    private func qualityChip(_ quality: ChordLibraryQuality) -> some View {
        Button(action: {
            selectedQuality = quality
            currentShapeIndex = 0
        }) {
            Text(quality.displayName)
                .font(.body)
                .fontWeight(selectedQuality == quality ? .bold : .regular)
                .frame(minWidth: 50, minHeight: 36)
                .background(selectedQuality == quality ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(selectedQuality == quality ? .white : .primary)
                .cornerRadius(8)
        }
    }
    
    // MARK: - Display Mode
    
    private var displayModeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Display")
                .font(.headline)
            
            Picker("Display Mode", selection: $displayMode) {
                ForEach(ChordDisplayMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    // MARK: - Chord Info
    
    private func chordInfoSection(_ chordEntry: ChordEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(chordEntry.display)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(chordEntry.intervals)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("\(chordEntry.notes)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(chordEntry.voicingNote)
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
    }
    
    // MARK: - Forms Scroller (5 forms)
    
    private func formsScrollerSection(_ chordEntry: ChordEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Forms (\(chordEntry.shapes.count))")
                .font(.headline)
            
            TabView(selection: $currentShapeIndex) {
                ForEach(Array(chordEntry.shapes.enumerated()), id: \.offset) { index, shape in
                    ChordFormCard(
                        shape: shape,
                        root: selectedRoot,
                        quality: selectedQuality,
                        displayMode: displayMode,
                        isSaved: savedFormsManager.isSaved(
                            root: selectedRoot.rawValue,
                            quality: selectedQuality.rawValue,
                            shapeKind: shape.kind
                        ),
                        onPlayStrum: {
                            audioPlayer.playStrum(shape: shape, root: selectedRoot)
                        },
                        onPlayArpeggio: {
                            audioPlayer.playArpeggio(shape: shape, root: selectedRoot)
                        },
                        onToggleSave: {
                            if savedFormsManager.isSaved(
                                root: selectedRoot.rawValue,
                                quality: selectedQuality.rawValue,
                                shapeKind: shape.kind
                            ) {
                                // Remove from saved forms
                                if let savedForm = savedFormsManager.savedForms.first(where: {
                                    $0.root == selectedRoot.rawValue &&
                                    $0.quality == selectedQuality.rawValue &&
                                    $0.shapeKind == shape.kind
                                }) {
                                    savedFormsManager.delete(savedForm)
                                }
                            } else {
                                // Save to My Forms
                                let newForm = SavedForm(
                                    root: selectedRoot.rawValue,
                                    quality: selectedQuality.rawValue,
                                    shapeKind: shape.kind,
                                    symbol: libraryManager.buildSymbol(root: selectedRoot, quality: selectedQuality)
                                )
                                savedFormsManager.save(newForm)
                            }
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: isLandscape ? 400 : 500)
        }
    }
    
    // MARK: - Helpers
    
    private func detectOrientation() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        if let windowWidth = window?.bounds.width,
           let windowHeight = window?.bounds.height {
            isLandscape = windowWidth > windowHeight
        }
    }
}

// MARK: - Chord Form Card

struct ChordFormCard: View {
    let shape: ChordShape
    let root: ChordRoot
    let quality: ChordLibraryQuality
    let displayMode: ChordDisplayMode
    let isSaved: Bool
    let onPlayStrum: () -> Void
    let onPlayArpeggio: () -> Void
    let onToggleSave: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Shape label
            HStack {
                Text(shape.kind)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text(shape.label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Diagram
            ChordDiagramView(
                shape: shape,
                root: root,
                displayMode: displayMode
            )
            
            // Tips
            if !shape.tips.isEmpty {
                Text(shape.tips)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Action buttons
            HStack(spacing: 20) {
                // Play (Strum)
                Button(action: onPlayStrum) {
                    VStack {
                        Image(systemName: "play.circle.fill")
                            .font(.largeTitle)
                        Text("Play")
                            .font(.caption)
                    }
                }
                
                // Arp (Arpeggio)
                Button(action: onPlayArpeggio) {
                    VStack {
                        Image(systemName: "music.note.list")
                            .font(.largeTitle)
                        Text("Arp")
                            .font(.caption)
                    }
                }
                
                // Save to My Forms
                Button(action: onToggleSave) {
                    VStack {
                        Image(systemName: isSaved ? "star.fill" : "star")
                            .font(.largeTitle)
                            .foregroundColor(isSaved ? .yellow : .primary)
                        Text(isSaved ? "Saved" : "Save")
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    ChordLibraryView()
}

