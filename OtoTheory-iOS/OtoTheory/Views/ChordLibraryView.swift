//
//  ChordLibraryView.swift
//  OtoTheory
//
//  Main UI for Chord Library (Web version style)
//  Horizontal scrolling with page indicators
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
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
                    
                    // Root selector
                    rootSelectorSection
                    
                    // Quality selector
                    qualitySelectorSection
                    
                    // Chord info + Display Mode
                    if let chordEntry = libraryManager.getChord(root: selectedRoot, quality: selectedQuality) {
                        chordInfoAndDisplaySection(chordEntry)
                        
                        // Page indicator hint
                        HStack {
                            Spacer()
                            Text("\(currentShapeIndex + 1) / \(chordEntry.shapes.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
    
    // MARK: - Chord Info + Display Mode
    
    private func chordInfoAndDisplaySection(_ chordEntry: ChordEntry) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Left: Chord info
            VStack(alignment: .leading, spacing: 4) {
                Text(chordEntry.display)
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack(spacing: 4) {
                    Text(chordEntry.intervals)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("|")
                        .foregroundColor(.secondary)
                    Text(chordEntry.notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Right: Display Mode (compact)
            HStack(spacing: 4) {
                ForEach(ChordDisplayMode.allCases) { mode in
                    Button(action: {
                        displayMode = mode
                    }) {
                        Text(mode.rawValue.lowercased())
                            .font(.caption)
                            .fontWeight(displayMode == mode ? .bold : .regular)
                            .frame(width: 50, height: 28)
                            .background(displayMode == mode ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(displayMode == mode ? .white : .primary)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Forms Scroller
    
    private func formsScrollerSection(_ chordEntry: ChordEntry) -> some View {
        TabView(selection: $currentShapeIndex) {
            ForEach(Array(chordEntry.shapes.enumerated()), id: \.offset) { index, shape in
                ChordFormFullCard(
                    shape: shape,
                    root: selectedRoot,
                    quality: selectedQuality,
                    symbol: chordEntry.symbol,
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
                        toggleSave(shape: shape)
                    }
                )
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide default dots
        .frame(height: 500) // Larger for landscape diagram
    }
    
    // MARK: - Helpers
    
    private func toggleSave(shape: ChordShape) {
        if savedFormsManager.isSaved(
            root: selectedRoot.rawValue,
            quality: selectedQuality.rawValue,
            shapeKind: shape.kind
        ) {
            // Remove
            if let savedForm = savedFormsManager.savedForms.first(where: {
                $0.root == selectedRoot.rawValue &&
                $0.quality == selectedQuality.rawValue &&
                $0.shapeKind == shape.kind
            }) {
                savedFormsManager.delete(savedForm)
            }
        } else {
            // Save
            let newForm = SavedForm(
                root: selectedRoot.rawValue,
                quality: selectedQuality.rawValue,
                shapeKind: shape.kind,
                symbol: libraryManager.buildSymbol(root: selectedRoot, quality: selectedQuality)
            )
            savedFormsManager.save(newForm)
        }
    }
}

// MARK: - Chord Form Full Card (1 screen = 1 form)

struct ChordFormFullCard: View {
    let shape: ChordShape
    let root: ChordRoot
    let quality: ChordLibraryQuality
    let symbol: String
    let displayMode: ChordDisplayMode
    let isSaved: Bool
    let onPlayStrum: () -> Void
    let onPlayArpeggio: () -> Void
    let onToggleSave: () -> Void
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var body: some View {
        GeometryReader { geometry in
            if isLandscape {
                // Landscape: Compact layout to fit everything
                HStack(spacing: 16) {
                    // Left: Diagram (larger)
                    ChordDiagramView(
                        shape: shape,
                        root: root,
                        displayMode: displayMode
                    )
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.8)
                    
                    // Right: Info + Actions
                    VStack(alignment: .leading, spacing: 8) {
                        // Shape label
                        HStack {
                            Text(shape.kind)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(shape.label)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Tips (compact)
                        if !shape.tips.isEmpty {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(shape.tips.prefix(2), id: \.self) { tip in
                                    Text("• \(tip)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Spacer()
                        
                        // Action buttons (compact)
                        HStack(spacing: 12) {
                            Button(action: onPlayStrum) {
                                VStack(spacing: 2) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title2)
                                    Text("Play")
                                        .font(.caption2)
                                }
                            }
                            
                            Button(action: onPlayArpeggio) {
                                VStack(spacing: 2) {
                                    Image(systemName: "music.note.list")
                                        .font(.title2)
                                    Text("Arp")
                                        .font(.caption2)
                                }
                            }
                            
                            Button(action: onToggleSave) {
                                VStack(spacing: 2) {
                                    Image(systemName: isSaved ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundColor(isSaved ? .yellow : .primary)
                                    Text(isSaved ? "Saved" : "Save")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                    .frame(width: geometry.size.width * 0.35)
                    .padding(.trailing)
                }
                .padding()
            } else {
                // Portrait: Vertical layout
                VStack(spacing: 12) {
                    // Shape label
                    HStack {
                        Text(shape.kind)
                            .font(.title3)
                            .fontWeight(.semibold)
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
                    .frame(height: min(280, geometry.size.height * 0.5))
                    
                    // Tips
                    if !shape.tips.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(shape.tips, id: \.self) { tip in
                                Text("• \(tip)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }
                    
                    // Action buttons
                    HStack(spacing: 20) {
                        Button(action: onPlayStrum) {
                            VStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 44))
                                Text("Play")
                                    .font(.caption)
                            }
                        }
                        
                        Button(action: onPlayArpeggio) {
                            VStack {
                                Image(systemName: "music.note.list")
                                    .font(.system(size: 44))
                                Text("Arp")
                                    .font(.caption)
                            }
                        }
                        
                        Button(action: onToggleSave) {
                            VStack {
                                Image(systemName: isSaved ? "star.fill" : "star")
                                    .font(.system(size: 44))
                                    .foregroundColor(isSaved ? .yellow : .primary)
                                Text(isSaved ? "Saved" : "Save")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    
                    Spacer(minLength: 0)
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    ChordLibraryView()
}
