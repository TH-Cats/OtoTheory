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
    @State private var showFullscreen: Bool = false
    @StateObject private var orientationManager = OrientationManager.shared
    
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
                        
                        // Page indicator hint + Fullscreen button
                        HStack {
                            Spacer()
                            Text("\(currentShapeIndex + 1) / \(chordEntry.shapes.count)")
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
        .fullScreenCover(isPresented: $showFullscreen) {
            if let chordEntry = libraryManager.getChord(root: selectedRoot, quality: selectedQuality),
               currentShapeIndex < chordEntry.shapes.count {
                ChordLibraryFullscreenView(
                    chordEntry: chordEntry,
                    currentShapeIndex: $currentShapeIndex,
                    displayMode: $displayMode,
                    selectedRoot: selectedRoot,
                    selectedQuality: selectedQuality,
                    onClose: {
                        showFullscreen = false
                        orientationManager.unlock()
                    }
                )
            }
        }
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
                HStack(spacing: 8) {
                    // Left: Diagram (optimized size)
                    ChordDiagramView(
                        shape: shape,
                        root: root,
                        displayMode: displayMode
                    )
                    .frame(width: geometry.size.width * 0.55, height: geometry.size.height * 0.85)
                    .padding(.leading, 8)
                    
                    // Right: Info + Actions
                    VStack(alignment: .leading, spacing: 4) {
                        // Shape label
                        HStack {
                            Text(shape.kind)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(shape.label)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        // Tips (compact - max 2 lines)
                        if !shape.tips.isEmpty {
                            VStack(alignment: .leading, spacing: 1) {
                                ForEach(shape.tips.prefix(2), id: \.self) { tip in
                                    Text("• \(tip)")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Spacer(minLength: 4)
                        
                        // Action buttons (compact, vertical)
                        VStack(spacing: 8) {
                            Button(action: onPlayStrum) {
                                HStack(spacing: 4) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title3)
                                    Text("Play")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            }
                            
                            Button(action: onPlayArpeggio) {
                                HStack(spacing: 4) {
                                    Image(systemName: "music.note.list")
                                        .font(.title3)
                                    Text("Arp")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(6)
                            }
                            
                            Button(action: onToggleSave) {
                                HStack(spacing: 4) {
                                    Image(systemName: isSaved ? "star.fill" : "star")
                                        .font(.title3)
                                        .foregroundColor(isSaved ? .yellow : .primary)
                                    Text(isSaved ? "Saved" : "Save")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(6)
                            }
                        }
                    }
                    .frame(width: geometry.size.width * 0.35)
                    .padding(.trailing, 8)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
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

// MARK: - Fullscreen View (Landscape optimized)

struct ChordLibraryFullscreenView: View {
    let chordEntry: ChordEntry
    @Binding var currentShapeIndex: Int
    @Binding var displayMode: ChordDisplayMode
    let selectedRoot: ChordRoot
    let selectedQuality: ChordLibraryQuality
    let onClose: () -> Void
    
    @StateObject private var audioPlayer = ChordLibraryAudioPlayer.shared
    @StateObject private var savedFormsManager = SavedFormsManager.shared
    @StateObject private var libraryManager = ChordLibraryManager.shared
    
    private var currentShape: ChordShape {
        chordEntry.shapes[currentShapeIndex]
    }
    
    private var isSaved: Bool {
        savedFormsManager.isSaved(
            root: selectedRoot.rawValue,
            quality: selectedQuality.rawValue,
            shapeKind: currentShape.kind
        )
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    // Close button
                    Button {
                        onClose()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                            Text("Close")
                        }
                        .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Chord name and info
                    VStack(spacing: 2) {
                        Text(chordEntry.display)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Text(chordEntry.intervals)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("|")
                                .foregroundColor(.gray)
                            Text(chordEntry.notes)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
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
                }
                .padding()
                .background(Color.black.opacity(0.8))
                
                // Main content
                GeometryReader { geometry in
                    HStack(spacing: 16) {
                        // Left: Fretboard (60%)
                        VStack {
                            ChordDiagramView(
                                shape: currentShape,
                                root: selectedRoot,
                                displayMode: displayMode
                            )
                            
                            // Shape info
                            HStack {
                                Text(currentShape.kind)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(currentShape.label)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        }
                        .frame(width: geometry.size.width * 0.6)
                        
                        // Right: Tips + Actions (40%)
                        VStack(alignment: .leading, spacing: 12) {
                            // Tips
                            if !currentShape.tips.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Tips:")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    ForEach(currentShape.tips, id: \.self) { tip in
                                        Text("• \(tip)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Action buttons
                            VStack(spacing: 12) {
                                Button(action: {
                                    audioPlayer.playStrum(shape: currentShape, root: selectedRoot)
                                }) {
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                            .font(.title2)
                                        Text("Play (Strum)")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    audioPlayer.playArpeggio(shape: currentShape, root: selectedRoot)
                                }) {
                                    HStack {
                                        Image(systemName: "music.note.list")
                                            .font(.title2)
                                        Text("Arpeggio")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    toggleSave()
                                }) {
                                    HStack {
                                        Image(systemName: isSaved ? "star.fill" : "star")
                                            .font(.title2)
                                            .foregroundColor(isSaved ? .yellow : .white)
                                        Text(isSaved ? "Saved" : "Save to My Forms")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                            
                            // Navigation
                            HStack(spacing: 16) {
                                Button(action: {
                                    if currentShapeIndex > 0 {
                                        currentShapeIndex -= 1
                                    }
                                }) {
                                    Image(systemName: "chevron.left.circle.fill")
                                        .font(.title)
                                        .foregroundColor(currentShapeIndex > 0 ? .white : .gray)
                                }
                                .disabled(currentShapeIndex == 0)
                                
                                Text("\(currentShapeIndex + 1) / \(chordEntry.shapes.count)")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                
                                Button(action: {
                                    if currentShapeIndex < chordEntry.shapes.count - 1 {
                                        currentShapeIndex += 1
                                    }
                                }) {
                                    Image(systemName: "chevron.right.circle.fill")
                                        .font(.title)
                                        .foregroundColor(currentShapeIndex < chordEntry.shapes.count - 1 ? .white : .gray)
                                }
                                .disabled(currentShapeIndex == chordEntry.shapes.count - 1)
                            }
                            .padding(.top)
                        }
                        .frame(width: geometry.size.width * 0.35)
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
    private func toggleSave() {
        if savedFormsManager.isSaved(
            root: selectedRoot.rawValue,
            quality: selectedQuality.rawValue,
            shapeKind: currentShape.kind
        ) {
            // Remove
            if let savedForm = savedFormsManager.savedForms.first(where: {
                $0.root == selectedRoot.rawValue &&
                $0.quality == selectedQuality.rawValue &&
                $0.shapeKind == currentShape.kind
            }) {
                savedFormsManager.delete(savedForm)
            }
        } else {
            // Save
            let newForm = SavedForm(
                root: selectedRoot.rawValue,
                quality: selectedQuality.rawValue,
                shapeKind: currentShape.kind,
                symbol: libraryManager.buildSymbol(root: selectedRoot, quality: selectedQuality)
            )
            savedFormsManager.save(newForm)
        }
    }
}

#Preview {
    ChordLibraryView()
}
