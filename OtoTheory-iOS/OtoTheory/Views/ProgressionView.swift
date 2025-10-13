import SwiftUI
import AVFoundation

struct ProgressionView: View {
    @StateObject private var progressionStore = ProgressionStore.shared
    @State private var cursorIndex = 0
    @State private var selectedChords: Set<Int> = []
    
    // Computed property for backward compatibility
    private var slots: [String?] {
        get { progressionStore.slots }
        nonmutating set { progressionStore.slots = newValue }
    }
    
    // Phase E-5: Active slots (section-aware)
    private var activeSlots: [String?] {
        progressionStore.activeSlots
    }
    
    // Phase A: Hybrid Audio Architecture
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var sketchManager = SketchManager()
    @StateObject private var proManager = ProManager.shared  // Phase 1: Pro feature management
    @State private var sequencer: ChordSequencer?  // 旧実装（Phase Bで削除予定）
    @State private var hybridPlayer: HybridPlayer?
    @State private var bounceService: GuitarBounceService?
    @State private var bassService: BassBounceService?  // Phase C-2.5: ベース PCM レンダリング
    @State private var scalePreviewPlayer: ScalePreviewPlayer?  // Phase A-3: スケール音プレビュー（進捗バー対応）
    
    // Chord builder state
    @State private var selectedRoot: String = "C"
    @State private var selectedQuick: String = ""
    
    // Phase E-4B: Advanced Chord Builder (Pro)
    @State private var showAdvanced: Bool = false
    @State private var selectedSlashBass: String? = nil  // For slash chords
    
    // Phase E-4C: Slash Chord Editor (Pro)
    @State private var editingSlotIndex: Int? = nil
    @State private var showSlashEditor = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = "checkmark.circle.fill"
    @State private var toastColor: Color = .green
    
    // Playback state
    @State private var isPlaying = false
    @State private var bpm: Double = 120
    @State private var currentSlotIndex: Int? = nil
    @State private var selectedInstrument: Int = 0 // 0=Steel, 1=Nylon, 2=Clean, 3=Dist, 4=OverDrive, 5=Muted, 6=Piano
    @State private var playbackMode: PlaybackMode = .fullSong // Phase E-5: 全体/セクションごと再生
    
    private let instruments = [
        ("Acoustic Steel", 25),
        ("Electric Clean", 27),
        ("Electric Muted", 28),
        ("Piano", 0)
    ]
    
    // Preset state
    @State private var showPresetPicker = false
    @State private var selectedPresetKey: String = "C"
    
    // Pro / Paywall state (Phase 1)
    @State private var showPaywall = false
    
    // Section state (Phase 2 - Legacy)
    @State private var sections: [Section] = []
    @State private var showSectionEditor = false
    
    // Section mode (Phase E-5)
    @State private var showSectionManagement = false
    
    // Sketch state
    @State private var showSketchList = false
    @State private var showSaveDialog = false
    @State private var sketchName: String = ""
    @State private var currentSketchId: String?
    
    // Analysis state
    @State private var keyCandidates: [KeyCandidate] = []
    @State private var selectedKeyIndex: Int? = nil
    @State private var scaleCandidates: [ScaleCandidate] = []
    @State private var selectedScaleIndex: Int? = nil
    @State private var isAnalyzed = false
    @State private var isAnalyzing = false
    
    // Fretboard & Diatonic state (Phase E: Progression Tools)
    @State private var fbDisplay: FretboardDisplay = .degrees
    @State private var selectedDiatonicChord: String? = nil
    @State private var overlayChordNotes: [String] = []
    @State private var showFretboardFullscreen = false
    @StateObject private var orientationManager = OrientationManager.shared
    
    private var selectedKey: KeyCandidate? {
        guard let index = selectedKeyIndex, index < keyCandidates.count else {
            return nil
        }
        return keyCandidates[index]
    }
    
    private var selectedScale: ScaleCandidate? {
        guard let index = selectedScaleIndex, index < scaleCandidates.count else {
            return nil
        }
        return scaleCandidates[index]
    }
    
    // Theory bridge (lazy initialization)
    private var theoryBridge: TheoryBridge? = {
        return TheoryBridge()
    }()
    
    private let roots = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    private let quicks = ["", "m", "7", "maj7", "m7", "dim", "sus4"] // Free版
    
    private var previewChord: String {
        var chord = selectedRoot + selectedQuick
        if let bass = selectedSlashBass {
            chord += "/\(bass)"
        }
        return chord
    }
    
    private var hasEnoughChords: Bool {
        // Use combinedProgression for full song check
        let slots = progressionStore.useSectionMode ? progressionStore.combinedProgression : progressionStore.slots
        return slots.compactMap({ $0 }).count >= 3
    }
    
    private func fitColor(_ fit: Int) -> Color {
        if fit >= 80 {
            return .green
        } else if fit >= 60 {
            return .orange
        } else {
            return .red
        }
    }
    
    // MARK: - Init
    
    init() {
        // ✅ HybridPlayer を常用（Phase B 最終版）
        audioTrace("PATH = Hybrid (fixed)")
        
        let candidates = [
            ("FluidR3_GM", "sf2"),
            ("TimGM6mb", "sf2")
        ]
        
        for (name, ext) in candidates {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                do {
                    // HybridPlayer を初期化
                    let hybrid = try HybridPlayer(sf2URL: url)
                    _hybridPlayer = State(initialValue: hybrid)
                    
                    // GuitarBounceService を初期化
                    let bounce = try GuitarBounceService(sf2URL: url)
                    let bass = try BassBounceService(sf2URL: url)  // Phase C-2.5: ベースサービス初期化
                    _bounceService = State(initialValue: bounce)
                    _bassService = State(initialValue: bass)  // ベースサービスを保存
                    
                    // ScalePreviewPlayer を初期化（Phase A-3）
                    let preview = try ScalePreviewPlayer(sf2URL: url)
                    _scalePreviewPlayer = State(initialValue: preview)
                    
                    // ChordSequencer はクリック専用（フォールバック）
                    let seq = try ChordSequencer(sf2URL: url)
                    _sequencer = State(initialValue: seq)
                    
                    print("✅ HybridPlayer initialized with \(name).\(ext)")
                    print("✅ GuitarBounceService initialized")
                    print("✅ ScalePreviewPlayer initialized")
                    print("✅ ChordSequencer initialized (click-only)")
                    return
                } catch {
                    print("❌ Failed to initialize HybridPlayer with \(name).\(ext): \(error)")
                }
            }
        }
        
        print("❌ SF2 not found for HybridPlayer initialization")
        _sequencer = State(initialValue: nil)
        _hybridPlayer = State(initialValue: nil)
        _bounceService = State(initialValue: nil)
    }
    
    var body: some View {
        Group {
            if showFretboardFullscreen {
                fretboardFullscreenView
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        buildProgressionSection
                        chordBuilderSection
                        analyzeAndResultSection
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
        }
        .sheet(isPresented: $showPresetPicker) {
            PresetPickerView(
                selectedKey: $selectedPresetKey,
                onSelect: { preset in
                    applyPreset(preset)
                    showPresetPicker = false
                },
                onProRequired: {
                    showPresetPicker = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showPaywall = true
                    }
                }
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showSectionEditor) {
            SectionEditorView(
                sections: $sections,
                maxBars: 12
            )
        }
        .sheet(isPresented: $showSectionManagement) {
            SectionManagementView(store: progressionStore)
        }
        .sheet(isPresented: $showSketchList) {
            SketchListView(
                sketchManager: sketchManager,
                onLoad: { sketch in
                    loadSketch(sketch)
                }
            )
        }
        .sheet(isPresented: $showSlashEditor) {
            // Phase E-4C: Slash Chord Editor Sheet
            if let index = editingSlotIndex {
                let currentChord: String? = {
                    if progressionStore.useSectionMode {
                        return progressionStore.activeSlots[index]
                    } else {
                        return slots[index]
                    }
                }()
                
                if let chord = currentChord {
                    SlashChordEditorView(
                        originalChord: chord,
                        onSave: { newChord in
                            if newChord.isEmpty {
                                deleteChord(at: index)
                            } else {
                                if progressionStore.useSectionMode {
                                    progressionStore.updateSectionChord(newChord, at: index)
                                } else {
                                    slots[index] = newChord
                                }
                                
                                // Toast通知
                                toastMessage = "Updated to \(newChord)"
                                toastIcon = "checkmark.circle.fill"
                                toastColor = .green
                                showToast = true
                            }
                        }
                    )
                    .presentationDetents([.height(450)])
                    .presentationDragIndicator(.visible)
                }
            }
        }
        .toast(
            isShowing: $showToast,
            message: toastMessage,
            icon: toastIcon,
            backgroundColor: toastColor
        )
        .alert("Save Sketch", isPresented: $showSaveDialog) {
            TextField("Sketch name", text: $sketchName)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                saveCurrentSketch()
            }
        }
    }
    
    // MARK: - View Sections (Phase E-4B/C: Performance Optimization)
    
    // MARK: - Section Picker (Phase E-5)
    
    @ViewBuilder
    private var sectionPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Editing Section")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { showSectionManagement = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(progressionStore.sectionDefinitions) { section in
                        SectionChip(
                            section: section,
                            isSelected: progressionStore.currentSectionId == section.id,
                            onTap: {
                                progressionStore.currentSectionId = section.id
                                // Reset cursor to first slot when switching sections
                                cursorIndex = 0
                            }
                        )
                    }
                    
                    // Add Section Button
                    Button(action: { showSectionManagement = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add")
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            
            // Full Song Info
            let totalChords = progressionStore.combinedProgression.compactMap { $0 }.count
            if totalChords > 0 {
                HStack(spacing: 12) {
                    Image(systemName: "music.note")
                        .foregroundColor(.secondary)
                    Text("Full Song: \(totalChords) chords in \(progressionStore.playbackOrder.items.count) sections")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
        }
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var buildProgressionSection: some View {
        Group {
            buildProgressionHeader
            playbackControls
            sectionMarkers
            
            // Phase E-5: Section Picker (if section mode is enabled)
            if progressionStore.useSectionMode {
                sectionPicker
            }
            
            slotsGrid
        }
    }
    
    @ViewBuilder
    private var buildProgressionHeader: some View {
                // Build Progression Section
                VStack(alignment: .leading, spacing: 12) {
                        // Title
                        Text("Build Progression")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        // Buttons - 1 row with Pro-conditional Sections button
                        HStack(spacing: 8) {
                            // Preset Button
                            Button(action: { showPresetPicker = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "music.note.list")
                                    Text("Preset")
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            
                            // Sections Button (Pro only - Phase E-5)
                            #if DEBUG
                            // Always show in DEBUG mode for testing
                            Button(action: {
                                if !progressionStore.useSectionMode {
                                    progressionStore.enableSectionMode()
                                }
                                showSectionManagement = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: progressionStore.useSectionMode ? "square.grid.3x2.fill" : "square.grid.3x2")
                                    Text("Sections")
                                    if progressionStore.useSectionMode && !progressionStore.sectionDefinitions.isEmpty {
                                        Text("(\(progressionStore.sectionDefinitions.count))")
                                            .font(.caption)
                                    }
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .background(progressionStore.useSectionMode ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                            #else
                            // Production: Pro only
                            if proManager.isProUser {
                                Button(action: {
                                    if !progressionStore.useSectionMode {
                                        progressionStore.enableSectionMode()
                                    }
                                    showSectionManagement = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: progressionStore.useSectionMode ? "square.grid.3x2.fill" : "square.grid.3x2")
                                        Text("Sections")
                                        if progressionStore.useSectionMode && !progressionStore.sectionDefinitions.isEmpty {
                                            Text("(\(progressionStore.sectionDefinitions.count))")
                                                .font(.caption)
                                        }
                                    }
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .background(progressionStore.useSectionMode ? Color.blue.opacity(0.1) : Color.clear)
                                .cornerRadius(8)
                            }
                            #endif
                            
                            // Reset Button
                            Button(action: resetProgression) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset")
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            
                            // Sketches Button
                            Button(action: { showSketchList = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "folder")
                                    Text("Sketches")
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.horizontal)
                }
    }
    
    @ViewBuilder
    private var playbackControls: some View {
                            // Playback Controls
                            VStack(spacing: 12) {
                                // Playback Mode Selector (Phase E-5: Section mode only)
                                if progressionStore.useSectionMode {
                                    HStack(spacing: 8) {
                                        ForEach(PlaybackMode.allCases, id: \.self) { mode in
                                            Button(action: { playbackMode = mode }) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: mode.icon)
                                                        .font(.caption)
                                                    Text(mode.rawValue)
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(playbackMode == mode ? Color.blue : Color.secondary.opacity(0.1))
                                                .foregroundColor(playbackMode == mode ? .white : .primary)
                                                .cornerRadius(6)
                                            }
                                        }
                                    }
                                }
                                
                                HStack(spacing: 16) {
                                    // Play/Stop Button
                                    Button(action: togglePlayback) {
                                        HStack {
                                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                                .font(.system(size: 20))
                                            Text(isPlaying ? "Stop" : "Play")
                                                .fontWeight(.semibold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(isPlaying ? Color.red : Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    }
                                    
                                    // BPM Control
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("BPM: \(Int(bpm))")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        
                                        Slider(value: $bpm, in: 40...240, step: 10)
                                            .frame(width: 120)
                                    }
                                }
                                
                                // Instrument Selection
                                HStack(spacing: 8) {
                                    Text("Instrument:")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    Picker("Instrument", selection: $selectedInstrument) {
                                        ForEach(0..<instruments.count, id: \.self) { index in
                                            Text(instruments[index].0).tag(index)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .onChange(of: selectedInstrument) { _, newValue in
                                        changeInstrument(instruments[newValue].1)
                                    }
                                }
                            }
                            .padding(.horizontal)
    }
    
    @ViewBuilder
    private var sectionMarkers: some View {
                        // Section Markers (Phase 2)
                        if !sections.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(sections.sortedByRange) { section in
                                        SectionMarker(section: section)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 8)
                        }
    }
    
    @ViewBuilder
    private var slotsGrid: some View {
        // Cache activeSlots to avoid multiple calls to computed property
        let currentSlots = progressionStore.activeSlots
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
            ForEach(0..<12) { index in
                SlotView(
                    index: index,
                    chord: currentSlots[index],
                    isCursor: index == cursorIndex,
                    isPlaying: currentSlotIndex == index,
                    isHighlighted: progressionStore.lastAddedSlotIndex == index,
                    onTap: { handleSlotTap(index) },
                    onDelete: currentSlots[index] != nil ? { deleteChord(at: index) } : nil
                )
                .onLongPressGesture(minimumDuration: 0.5) {
                    // Phase E-4C: Slash Chord Editor (Pro)
                    if currentSlots[index] != nil {
                        // Pro判定
                        if proManager.isProUser {
                            // Pro版: Slash Editor表示
                            editingSlotIndex = index
                            showSlashEditor = true
                        } else {
                            // Free版: Paywall表示
                            showPaywall = true
                        }
                        
                        // ハプティクフィードバック
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var chordBuilderSection: some View {
                // Choose Chords Section (Phase E-4B: Component)
                ChordBuilderView(
                    selectedRoot: $selectedRoot,
                    selectedQuick: $selectedQuick,
                    showAdvanced: $showAdvanced,
                    selectedSlashBass: $selectedSlashBass,
                    previewChord: previewChord,
                    isPro: proManager.isProUser,
                    onPreview: {
                        let midiNotes = chordToMidi(previewChord)
                        audioPlayer.playChord(midiNotes: midiNotes, duration: 1.5, strum: true)
                    },
                    onAdd: {
                        addChordToProgression(previewChord)
                    },
                    onShowPaywall: {
                        showPaywall = true
                    }
                )
    }
    
    @ViewBuilder
    private var analyzeAndResultSection: some View {
        VStack(spacing: 24) {
                // Analyze Section
                VStack(alignment: .leading, spacing: 12) {
                    Button(action: analyzeProgression) {
                        HStack {
                            if isAnalyzing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("Analyzing...")
                                    .fontWeight(.semibold)
                            } else {
                                Image(systemName: "magnifyingglass")
                                Text("Analyze")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(hasEnoughChords && !isAnalyzing ? Color.red : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(!hasEnoughChords || isAnalyzing)
                    .padding(.horizontal)
                    
                    if !hasEnoughChords {
                        Text("Add at least 3 chords to analyze")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
                
                // Result Section (after analysis)
                if isAnalyzed && !keyCandidates.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Result")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        // Key Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key")
                                .font(.headline)
                                .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(Array(keyCandidates.enumerated()), id: \.offset) { index, candidate in
                                Button(action: {
                                    selectKey(index)
                                }) {
                                    HStack {
                                        // Key & Mode
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(candidate.tonic) \(candidate.mode)")
                                                .font(.body)
                                                .fontWeight(selectedKeyIndex == index ? .bold : .semibold)
                                                .foregroundColor(.primary)
                                        }
                                        
                                        Spacer()
                                        
                                        // Fit percentage (compact)
                                        Text("\(candidate.confidence)%")
                                            .font(.body)
                                            .fontWeight(.bold)
                                            .foregroundColor(fitColor(candidate.confidence))
                                        
                                        // Selection indicator
                                        if selectedKeyIndex == index {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 20))
                                        }
                                    }
                                    .padding()
                                    .background(selectedKeyIndex == index ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        }
                        
                        // Scale Selection (after key selection)
                        if selectedKey != nil && !scaleCandidates.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Scale")
                                    .font(.headline)
                                    .padding(.horizontal)
                        
                                TimelineView(.periodic(from: .now, by: 0.1)) { _ in
                                    VStack(spacing: 8) {
                                        ForEach(Array(scaleCandidates.enumerated()), id: \.offset) { index, candidate in
                                            // Unified button: tap to select & preview
                                            ScaleCandidateButton(
                                                candidate: candidate,
                                                index: index,
                                                isSelected: selectedScaleIndex == index,
                                                isPlaying: scalePreviewPlayer?.currentPlayingScale == candidate.type,
                                                progress: scalePreviewPlayer?.progress ?? 0.0,
                                                onTap: {
                                                    playScalePreview(candidate)
                                                    selectedScaleIndex = index
                                                }
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
                // Tools Section - separated for compilation performance
                if isAnalyzed && selectedScale != nil {
                    toolsSection
                }
                
                // Save Button (after Tools)
                if isAnalyzed && selectedScale != nil {
                    Button(action: {
                        sketchName = sketchManager.generateDefaultName()
                        showSaveDialog = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save Sketch")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
        }
    }
    
    // MARK: - Fretboard Fullscreen View
    
    @ViewBuilder
    private var fretboardFullscreenView: some View {
        if let scale = selectedScale, let key = selectedKey {
            let rootPc = keyToPitchClass(key.tonic)
            let overlay = FretboardOverlay(
                scaleRootPc: rootPc,
                scaleType: scale.type,
                showScaleGhost: true,
                chordNotes: overlayChordNotes.isEmpty ? nil : overlayChordNotes,
                display: fbDisplay == .degrees ? .degrees : .names
            )
            
            ZStack {
                // Background
                Color.black.opacity(0.95)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Top toolbar
                    HStack(spacing: 12) {
                        // Info section
                        VStack(alignment: .leading, spacing: 4) {
                            // Key & Scale
                            Text("\(key.tonic) \(scale.type)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            // Progression
                            let slots = progressionStore.useSectionMode ? progressionStore.combinedProgression : progressionStore.slots
                            let chords = slots.compactMap { $0 }
                            if !chords.isEmpty {
                                Text(chords.prefix(6).joined(separator: " – ") + (chords.count > 6 ? "..." : ""))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            // Selected Diatonic Chord
                            if let selectedChord = selectedDiatonicChord {
                                Text("Selected: \(selectedChord)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.cyan)
                            }
                        }
                        
                        Spacer()
                        
                        // Controls
                        HStack(spacing: 8) {
                            // Degrees/Names toggle
                            Button {
                                fbDisplay = .degrees
                            } label: {
                                Text("°")
                                    .font(.system(size: 16, weight: fbDisplay == .degrees ? .bold : .regular))
                                    .frame(minWidth: 32)
                                    .padding(.vertical, 6)
                                    .background(fbDisplay == .degrees ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                fbDisplay = .names
                            } label: {
                                Text("♪")
                                    .font(.system(size: 16, weight: fbDisplay == .names ? .bold : .regular))
                                    .frame(minWidth: 32)
                                    .padding(.vertical, 6)
                                    .background(fbDisplay == .names ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            
                            // Reset button (show when chord is selected)
                            if selectedDiatonicChord != nil {
                                Button {
                                    selectedDiatonicChord = nil
                                    overlayChordNotes = []
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: 12))
                                        Text("Reset")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Close button
                            Button {
                                showFretboardFullscreen = false
                                orientationManager.unlock()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                    Text("Close")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.8))
                    
                    // Fretboard (fullscreen, centered)
                    FretboardView(
                        strings: ["E", "B", "G", "D", "A", "E"],
                        frets: 15,
                        overlay: overlay,
                        onTapNote: { midiNote in
                            audioPlayer.playNote(midiNote: UInt8(midiNote), duration: 0.3)
                        }
                    )
                    .id(overlayChordNotes.joined(separator: ","))  // Force update when chord notes change
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .ignoresSafeArea(.all)
            }
            .toolbar(.hidden, for: .tabBar)
        } else {
            // Fallback if no key/scale selected
            ZStack {
                Color.black.ignoresSafeArea(.all)
                VStack {
                    Text("No key/scale selected")
                        .foregroundColor(.white)
                    Button("Close") {
                        showFretboardFullscreen = false
                        orientationManager.unlock()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    // MARK: - Tools Section (Fretboard & Diatonic & Roman)
    
    @ViewBuilder
    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tools")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            // Fretboard Section
            fretboardSection
            
            // Diatonic Table Section
            diatonicSection
            
            Divider()
                .padding(.horizontal)
            
            // Roman Numerals Section
            romanSection
            
            // Patterns Section (after Roman)
            patternsSection
            
            // Cadence Section (after Patterns)
            cadenceSection
        }
    }
    
    // MARK: - Fretboard Section
    
    @ViewBuilder
    private var fretboardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Fretboard")
                    .font(.headline)
                
                Spacer()
                
                // Degrees/Names Toggle (icon-based like FindChords)
                HStack(spacing: 4) {
                    Button {
                        fbDisplay = .degrees
                    } label: {
                        Text("°")
                            .font(.system(size: 16, weight: fbDisplay == .degrees ? .bold : .regular))
                            .frame(minWidth: 32)
                            .padding(.vertical, 6)
                            .background(fbDisplay == .degrees ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(fbDisplay == .degrees ? .white : .primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        fbDisplay = .names
                    } label: {
                        Text("♪")
                            .font(.system(size: 16, weight: fbDisplay == .names ? .bold : .regular))
                            .frame(minWidth: 32)
                            .padding(.vertical, 6)
                            .background(fbDisplay == .names ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(fbDisplay == .names ? .white : .primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    // Fullscreen button
                    Button {
                        showFretboardFullscreen = true
                        orientationManager.lockToLandscape()
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            
            // Fretboard View
            if let scale = selectedScale, let key = selectedKey {
                let rootPc = keyToPitchClass(key.tonic)
                let overlay = FretboardOverlay(
                    scaleRootPc: rootPc,
                    scaleType: scale.type,
                    showScaleGhost: true,
                    chordNotes: overlayChordNotes.isEmpty ? nil : overlayChordNotes,
                    display: fbDisplay == .degrees ? .degrees : .names
                )
                let _ = !overlayChordNotes.isEmpty ? print("🎯 Fretboard overlay: chord notes=\(overlayChordNotes), ghost=\(overlay.shouldShowGhost)") : ()
                
            // FretboardView already has horizontal scrolling built-in
            FretboardView(
                overlay: overlay,
                onTapNote: { midiNote in
                    // Play single note
                    audioPlayer.playNote(midiNote: UInt8(midiNote), duration: 0.3)
                }
            )
            .frame(height: 350)  // Fixed height for portrait mode (same as FindChords)
            } else {
                Text("Analyze progression to view fretboard")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            }
        }
    }
    
    // MARK: - Diatonic Section
    
    @ViewBuilder
    private var diatonicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Diatonic Chords")
                .font(.headline)
                .padding(.horizontal)
            
            if let scale = selectedScale, let key = selectedKey {
                DiatonicTableView(
                    key: key.tonic,
                    scale: scale.type,
                    selectedChord: $selectedDiatonicChord,
                    onChordTap: { chord, degree in
                        print("🎵 onChordTap called: chord=\(chord), selectedDiatonicChord=\(selectedDiatonicChord ?? "nil")")
                        
                        // Toggle selection: if same chord is tapped, deselect it
                        if selectedDiatonicChord == chord {
                            // Deselect
                            selectedDiatonicChord = nil
                            overlayChordNotes = []
                            print("🎸 Deselected chord: \(chord)")
                        } else {
                            // Select new chord
                            selectedDiatonicChord = chord
                            
                            // Get chord notes for overlay
                            if let notes = getChordNotes(chord: chord, key: key.tonic) {
                                overlayChordNotes = notes
                                print("🎸 Selected chord: \(chord), notes: \(notes), key: \(key.tonic)")
                                print("🎯 overlayChordNotes updated to: \(overlayChordNotes)")
                            } else {
                                print("⚠️ Failed to get chord notes for: \(chord)")
                                overlayChordNotes = []
                            }
                        }
                        
                        // Play chord (no strum) - always play, even when deselecting
                        let midiNotes = chordToMidi(chord)
                        if !midiNotes.isEmpty {
                            audioPlayer.playChord(midiNotes: midiNotes, duration: 1.5, strum: false)
                        }
                    },
                    onChordLongPress: { chord in
                        // Add chord to progression
                        addChordToProgression(chord)
                        
                        // Toast notification
                        toastMessage = "Added \(chord)"
                        toastIcon = "checkmark.circle.fill"
                        toastColor = .green
                        showToast = true
                    }
                )
                .id("\(key.tonic)-\(scale.type)")  // Force recreation on key/scale change
                .padding(.horizontal)
            } else {
                Text("Analyze progression to view diatonic chords")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            }
        }
    }
    
    // MARK: - Roman Numerals Section
    
    @ViewBuilder
    private var romanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Roman Numerals")
                .font(.headline)
                .padding(.horizontal)
            
            if let _ = selectedScale, let _ = selectedKey {
                // Get the progression chords
                let slots = progressionStore.useSectionMode ? progressionStore.combinedProgression : progressionStore.slots
                let chords = slots.compactMap { $0 }
                
                if chords.isEmpty {
                    Text("No chords in progression")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(chords.enumerated()), id: \.offset) { index, chord in
                                let roman = getRomanNumeral(for: chord, key: selectedKey!, scale: selectedScale!)
                                Text(roman)
                                    .font(.system(size: 18, weight: .semibold, design: .serif))
                                    .foregroundColor(.primary)
                                
                                if index < chords.count - 1 {
                                    Text("–")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            } else {
                Text("Analyze progression to view Roman numerals")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
        }
    }
    
    // MARK: - Patterns Section
    
    @ViewBuilder
    private var patternsSection: some View {
        if let _ = selectedScale, let _ = selectedKey {
            let slots = progressionStore.useSectionMode ? progressionStore.combinedProgression : progressionStore.slots
            let chords = slots.compactMap { $0 }
            
            if !chords.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        Text("Patterns")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Pattern detection placeholder
                        Text("Doo-wop (I–vi–IV–V)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Cadence Section
    
    @ViewBuilder
    private var cadenceSection: some View {
        if let _ = selectedScale, let _ = selectedKey {
            let slots = progressionStore.useSectionMode ? progressionStore.combinedProgression : progressionStore.slots
            let chords = slots.compactMap { $0 }
            
            if !chords.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        Text("Cadence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Cadence detection placeholder
                        Text("Perfect Cadence (V→I)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
        }
    }
    
    // MARK: - Roman Numeral Helper
    
    private func getRomanNumeral(for chord: String, key: KeyCandidate, scale: ScaleCandidate) -> String {
        // Simple Roman numeral conversion
        // Parse chord root
        let chordRoot = String(chord.prefix(chord.count > 1 && (chord[chord.index(chord.startIndex, offsetBy: 1)] == "#" || chord[chord.index(chord.startIndex, offsetBy: 1)] == "b") ? 2 : 1))
        
        // Get pitch classes
        let keyPitchClass = keyToPitchClass(key.tonic)
        let chordPitchClass = keyToPitchClass(chordRoot)
        
        // Calculate interval from key
        let interval = (chordPitchClass - keyPitchClass + 12) % 12
        
        // Get quality (major/minor/dim)
        let isMinor = chord.contains("m") && !chord.contains("maj")
        let isDim = chord.contains("dim") || chord.contains("°")
        
        // Roman numerals based on interval
        let romans = ["I", "II", "III", "IV", "V", "VI", "VII"]
        let romanIndex = [0, 2, 4, 5, 7, 9, 11].firstIndex(of: interval) ?? 0
        var roman = romans[romanIndex]
        
        // Apply quality
        if isMinor {
            roman = roman.lowercased()
        } else if isDim {
            roman = roman.lowercased() + "°"
        }
        
        // Add quality suffix
        if chord.contains("7") && !chord.contains("maj7") {
            roman += "7"
        } else if chord.contains("maj7") {
            roman += "maj7"
        }
        
        return roman
    }
    
    private func keyToPitchClass(_ note: String) -> Int {
        let map: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4,
            "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11
        ]
        return map[note] ?? 0
    }
    
    // Helper: Get chord notes as pitch names
    private func getChordNotes(chord: String, key: String) -> [String]? {
        // Parse chord root
        let chordRoot = String(chord.prefix(chord.count > 1 && (chord[chord.index(chord.startIndex, offsetBy: 1)] == "#" || chord[chord.index(chord.startIndex, offsetBy: 1)] == "b") ? 2 : 1))
        
        // Get intervals based on quality
        let isMinor = chord.contains("m") && !chord.contains("maj")
        let isDim = chord.contains("dim") || chord.contains("°")
        let isMaj7 = chord.contains("maj7") || chord.contains("M7")
        let is7 = chord.contains("7") && !isMaj7
        
        var intervals: [Int]
        if isDim {
            intervals = [0, 3, 6]  // dim triad
        } else if isMinor {
            intervals = is7 ? [0, 3, 7, 10] : [0, 3, 7]  // m or m7
        } else {
            intervals = isMaj7 ? [0, 4, 7, 11] : (is7 ? [0, 4, 7, 10] : [0, 4, 7])  // maj, maj7, or 7
        }
        
        // Convert intervals to note names
        let rootPc = keyToPitchClass(chordRoot)
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        return intervals.map { interval in
            noteNames[(rootPc + interval) % 12]
        }
    }
    
    private func handleSlotTap(_ index: Int) {
        let currentSlots = progressionStore.activeSlots
        if let chord = currentSlots[index] {
            // If slot has a chord, play it
            let midiNotes = chordToMidi(chord)
            if !midiNotes.isEmpty {
                audioPlayer.playChord(midiNotes: midiNotes, duration: 2.0, strum: true)
                print("🎸 Playing \(chord): \(midiNotes)")
            }
        } else {
            // Empty slot, move cursor
            cursorIndex = index
        }
    }
    
    // Simple chord to MIDI conversion (basic triads)
    private func chordToMidi(_ chordSymbol: String) -> [UInt8] {
        // Parse root note
        let rootMap: [String: UInt8] = [
            "C": 60, "C#": 61, "Db": 61,
            "D": 62, "D#": 63, "Eb": 63,
            "E": 64,
            "F": 65, "F#": 66, "Gb": 66,
            "G": 67, "G#": 68, "Ab": 68,
            "A": 69, "A#": 70, "Bb": 70,
            "B": 71
        ]
        
        // Extract root (first 1-2 chars)
        var root = ""
        var quality = ""
        
        if chordSymbol.count >= 2 && (chordSymbol[chordSymbol.index(chordSymbol.startIndex, offsetBy: 1)] == "#" || chordSymbol[chordSymbol.index(chordSymbol.startIndex, offsetBy: 1)] == "b") {
            root = String(chordSymbol.prefix(2))
            quality = String(chordSymbol.dropFirst(2))
        } else {
            root = String(chordSymbol.prefix(1))
            quality = String(chordSymbol.dropFirst(1))
        }
        
        guard let rootNote = rootMap[root] else {
            return [60, 64, 67] // Default to C major
        }
        
        // Determine intervals based on quality
        var intervals: [UInt8] = [0, 4, 7] // Default: major triad
        
        if quality.contains("m") && !quality.contains("maj") {
            intervals = [0, 3, 7] // Minor triad
        } else if quality.contains("dim") {
            intervals = [0, 3, 6] // Diminished triad
        } else if quality.contains("aug") {
            intervals = [0, 4, 8] // Augmented triad
        } else if quality.contains("7") && !quality.contains("maj") {
            intervals = [0, 4, 7, 10] // Dominant 7th
        } else if quality.contains("maj7") || quality.contains("M7") {
            intervals = [0, 4, 7, 11] // Major 7th
        } else if quality.contains("m7") {
            intervals = [0, 3, 7, 10] // Minor 7th
        }
        
        return intervals.map { rootNote + $0 }
    }
    
    private func addChordToProgression(_ chord: String) {
        if progressionStore.useSectionMode {
            // Section mode: update current section
            if let sectionId = progressionStore.currentSectionId,
               let index = progressionStore.sectionDefinitions.firstIndex(where: { $0.id == sectionId }) {
                var section = progressionStore.sectionDefinitions[index]
                
                if cursorIndex < 12 {
                    section.chords[cursorIndex] = chord
                    progressionStore.sectionDefinitions[index] = section
                    progressionStore.objectWillChange.send()
                    
                    print("✅ Added \(chord) to section '\(section.name)' at cursor \(cursorIndex)")
                    print("🔍 Section chords: \(section.chords.compactMap { $0 })")
                    
                    // Move cursor to next empty slot
                    if let nextEmpty = section.chords.indices.first(where: { $0 > cursorIndex && section.chords[$0] == nil }) {
                        cursorIndex = nextEmpty
                    } else if cursorIndex < 11 {
                        cursorIndex += 1
                    }
                }
            }
        } else {
            // Legacy mode: update slots directly
            if cursorIndex < 12 {
                slots[cursorIndex] = chord
                // Move cursor to next empty slot
                if let nextEmpty = slots.indices.first(where: { $0 > cursorIndex && slots[$0] == nil }) {
                    cursorIndex = nextEmpty
                } else if cursorIndex < 11 {
                    cursorIndex += 1
                }
            }
        }
    }
    
    private func resetProgression() {
        if progressionStore.useSectionMode {
            // Clear current section's chords
            if let sectionId = progressionStore.currentSectionId,
               let index = progressionStore.sectionDefinitions.firstIndex(where: { $0.id == sectionId }) {
                var section = progressionStore.sectionDefinitions[index]
                section.chords = Array(repeating: nil, count: 12)
                progressionStore.sectionDefinitions[index] = section
                progressionStore.objectWillChange.send()
            }
        } else {
            slots = Array(repeating: nil, count: 12)
        }
        
        cursorIndex = 0
        selectedChords.removeAll()
        currentSketchId = nil
        
        // Clear analysis state
        keyCandidates = []
        selectedKeyIndex = nil
        scaleCandidates = []
        selectedScaleIndex = nil
        isAnalyzed = false
        isAnalyzing = false
    }
    
    private func deleteChord(at index: Int) {
        if progressionStore.useSectionMode {
            progressionStore.updateSectionChord(nil, at: index)
        } else {
            slots[index] = nil
        }
        cursorIndex = index
    }
    
    private func applyPreset(_ preset: Preset) {
        // Convert Roman numerals to chord symbols
        let chords = RomanConverter.toChordSymbols(preset.romanNumerals, key: selectedPresetKey)
        
        if progressionStore.useSectionMode {
            // Section mode: ensure we have a section to add to
            var targetSectionId: UUID?
            
            if let currentId = progressionStore.currentSectionId {
                targetSectionId = currentId
            } else if let firstSection = progressionStore.sectionDefinitions.first {
                // No section selected, use first section
                targetSectionId = firstSection.id
                progressionStore.currentSectionId = firstSection.id
            } else {
                // No sections exist, create one
                let _ = progressionStore.createSection(name: "Verse", type: .verse)
                targetSectionId = progressionStore.currentSectionId
            }
            
            // Now apply chords to the target section
            if let sectionId = targetSectionId,
               let index = progressionStore.sectionDefinitions.firstIndex(where: { $0.id == sectionId }) {
                var section = progressionStore.sectionDefinitions[index]
                var insertIndex = cursorIndex
                
                for chord in chords {
                    if insertIndex < 12 {
                        section.chords[insertIndex] = chord
                        insertIndex += 1
                    } else {
                        break
                    }
                }
                
                progressionStore.sectionDefinitions[index] = section
                progressionStore.objectWillChange.send()
                
                // Move cursor
                if let nextEmpty = section.chords.indices.first(where: { $0 >= insertIndex && section.chords[$0] == nil }) {
                    cursorIndex = nextEmpty
                } else if insertIndex < 12 {
                    cursorIndex = insertIndex
                }
            }
        } else {
            // Legacy mode: update slots directly
            var insertIndex = cursorIndex
            for chord in chords {
                if insertIndex < 12 {
                    slots[insertIndex] = chord
                    insertIndex += 1
                } else {
                    break
                }
            }
            
            // Move cursor to next empty slot or end
            if let nextEmpty = slots.indices.first(where: { $0 >= insertIndex && slots[$0] == nil }) {
                cursorIndex = nextEmpty
            } else if insertIndex < 12 {
                cursorIndex = insertIndex
            }
        }
    }
    
    // MARK: - Analysis Functions
    
    // Helper: Note name to MIDI number (C4 = 60)
    private func noteToMidi(_ note: String) -> UInt8? {
        let noteMap: [String: UInt8] = [
            "C": 60, "C#": 61, "Db": 61,
            "D": 62, "D#": 63, "Eb": 63,
            "E": 64,
            "F": 65, "F#": 66, "Gb": 66,
            "G": 67, "G#": 68, "Ab": 68,
            "A": 69, "A#": 70, "Bb": 70,
            "B": 71
        ]
        return noteMap[note]
    }
    
    private func analyzeProgression() {
        // Use combinedProgression for full song analysis (respects section mode & playback order)
        let slots = progressionStore.useSectionMode ? progressionStore.combinedProgression : progressionStore.slots
        let chords = slots.compactMap { $0 }
        
        print("🔍 analyzeProgression - useSectionMode: \(progressionStore.useSectionMode)")
        print("🔍 analyzeProgression - total chords: \(chords.count)")
        
        guard chords.count >= 3 else {
            print("⚠️ Not enough chords to analyze")
            return
        }
        
        guard let bridge = theoryBridge else {
            print("❌ TheoryBridge not initialized")
            return
        }
        
        // Phase E-5: Build section info for weighted analysis
        var sectionInfos: [SectionInfo]? = nil
        if progressionStore.useSectionMode && !progressionStore.sectionDefinitions.isEmpty {
            var cumulativeIndex = 0
            sectionInfos = []
            
            for sectionId in progressionStore.playbackOrder.expandedSectionIds {
                guard let section = progressionStore.sectionDefinitions.first(where: { $0.id == sectionId }) else {
                    continue
                }
                
                let filledCount = section.chords.compactMap { $0 }.count
                if filledCount > 0 {
                    let endIndex = cumulativeIndex + section.chords.count - 1
                    let info = SectionInfo(
                        type: section.type,
                        startIndex: cumulativeIndex,
                        endIndex: endIndex,
                        repeatCount: progressionStore.playbackOrder.items.first(where: { $0.sectionId == sectionId })?.repeatCount ?? 1
                    )
                    sectionInfos?.append(info)
                    print("📊 Section '\(section.name)': \(info.type.rawValue), slots \(info.startIndex)-\(info.endIndex), repeat \(info.repeatCount)x")
                }
                
                cumulativeIndex += section.chords.count
            }
        }
        
        // Show analyzing state
        isAnalyzing = true
        
        // Simulate analysis delay (2 seconds)
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                // Phase E-5: Analyze with section weights
                let candidates = bridge.analyzeProgression(chords, sections: sectionInfos)
                
                guard !candidates.isEmpty else {
                    print("❌ No key candidates found")
                    isAnalyzing = false
                    return
                }
                
                print("✅ Analysis results:")
                for (index, candidate) in candidates.enumerated() {
                    print("   \(index + 1). \(candidate.tonic) \(candidate.mode) (\(candidate.confidence)%)")
                }
                
                // Update state
                keyCandidates = candidates
                isAnalyzed = true
                isAnalyzing = false
                
                // Auto-select first key and fetch scales
                selectKey(0)
            }
        }
    }
    
    private func selectKey(_ index: Int) {
        guard index < keyCandidates.count else { return }
        
        selectedKeyIndex = index
        let candidate = keyCandidates[index]
        
        // Fetch scale candidates for selected key
        guard let bridge = theoryBridge else { return }
        
        // Use combinedProgression for full song analysis
        let slots = progressionStore.useSectionMode ? progressionStore.combinedProgression : progressionStore.slots
        let chords = slots.compactMap { $0 }
        let scales = bridge.scoreScales(chords, key: candidate.tonic, mode: candidate.mode)
        
        // v3.1: スケール候補を5つに制限（UI改善）
        scaleCandidates = Array(scales.prefix(5))
        selectedScaleIndex = scales.isEmpty ? nil : 0 // Auto-select first scale
        
        print("✅ Selected key: \(candidate.tonic) \(candidate.mode)")
        print("   Scale candidates (top 5): \(scaleCandidates.map { "\($0.type) (\($0.score)%)" }.joined(separator: ", "))")
    }
    
    private func scaleTypeToDisplayName(_ type: String) -> String {
        switch type {
        case "Ionian": return "Major Scale"
        case "Dorian": return "Dorian"
        case "Phrygian": return "Phrygian"
        case "Lydian": return "Lydian"
        case "Mixolydian": return "Mixolydian"
        case "Aeolian": return "Natural Minor"
        case "Locrian": return "Locrian"
        case "HarmonicMinor": return "Harmonic Minor"
        case "MelodicMinor": return "Melodic Minor"
        case "MajorPentatonic": return "Major Pentatonic"
        case "MinorPentatonic": return "Minor Pentatonic"
        default: return type
        }
    }
    
    // MARK: - Scale Preview (Phase A-3)
    
    private func playScalePreview(_ candidate: ScaleCandidate) {
        guard let player = scalePreviewPlayer else {
            print("⚠️ ScalePreviewPlayer not initialized")
            return
        }
        
        // Convert root string to MIDI pitch class (0-11)
        let root = pitchClassFromString(candidate.root)
        
        print("🎵 Playing scale preview: \(candidate.root) \(candidate.type)")
        player.playScale(root: root, scaleType: candidate.type, octave: 4)
    }
    
    private func pitchClassFromString(_ note: String) -> Int {
        switch note {
        case "C": return 0
        case "C#", "Db": return 1
        case "D": return 2
        case "D#", "Eb": return 3
        case "E": return 4
        case "F": return 5
        case "F#", "Gb": return 6
        case "G": return 7
        case "G#", "Ab": return 8
        case "A": return 9
        case "A#", "Bb": return 10
        case "B": return 11
        default: return 0
        }
    }
    
    // MARK: - Sketch Functions
    
    private func saveCurrentSketch() {
        guard let key = selectedKey, let scale = selectedScale else {
            print("⚠️ No key or scale selected")
            return
        }
        
        let sketch = Sketch(
            id: currentSketchId ?? UUID().uuidString,
            name: sketchName,
            chords: slots,
            key: "\(key.tonic) \(key.mode)",
            scale: "\(key.tonic) \(scaleTypeToDisplayName(scale.type))",
            bpm: bpm
        )
        
        sketchManager.save(sketch)
        currentSketchId = sketch.id
    }
    
    private func loadSketch(_ sketch: Sketch) {
        slots = sketch.chords
        bpm = sketch.bpm
        currentSketchId = sketch.id
        cursorIndex = sketch.chords.firstIndex(where: { $0 == nil }) ?? 0
        
        // Clear analysis state (user needs to re-analyze if needed)
        keyCandidates = []
        selectedKeyIndex = nil
        scaleCandidates = []
        selectedScaleIndex = nil
        isAnalyzed = false
        isAnalyzing = false
    }
    
    // MARK: - Playback Functions (Phase B: HybridPlayer)
    
    private func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        // Phase E-5: Select slots based on playback mode
        let slots: [String?]
        if progressionStore.useSectionMode && playbackMode == .currentSection {
            // Current section only
            slots = progressionStore.activeSlots
            print("🔍 startPlayback - mode: Current Section")
        } else if progressionStore.useSectionMode {
            // Full song (all sections in playback order)
            slots = progressionStore.combinedProgression
            print("🔍 startPlayback - mode: Full Song")
        } else {
            // Simple mode (no sections)
            slots = progressionStore.slots
            print("🔍 startPlayback - mode: Simple (no sections)")
        }
        
        let chords = slots.compactMap { $0 }
        print("🔍 startPlayback - total chords: \(chords.count)")
        
        guard !chords.isEmpty else {
            print("⚠️ No chords to play")
            return
        }
        
        // ✅ HybridPlayer を常用
        guard let hybrid = hybridPlayer, let bounce = bounceService else {
            print("❌ HybridPlayer or BounceService not available")
            assertionFailure("HybridPlayer must be initialized")
            return
        }
        
        audioTrace("Playback started (HybridPlayer)")
        guard let bass = bassService else { return }  // Phase C-2.5: ベースサービス確認
        playWithHybridPlayer(slots: slots, chords: chords, player: hybrid, bounce: bounce, bass: bass)
    }
    
    private func playWithHybridPlayer(slots: [String?], chords: [String], player: HybridPlayer, bounce: GuitarBounceService, bass: BassBounceService) {
        isPlaying = true
        
        Task {
            do {
                // SF2 URL取得（SF3は避ける、SF2のみ）
                let sf2Candidates = [
                    ("FluidR3_GM", "sf2"),
                    ("TimGM6mb", "sf2")
                ]
                
                var sf2URL: URL?
                for (name, ext) in sf2Candidates {
                    if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                        sf2URL = url
                        print("✅ SF2 found: \(name).\(ext)")
                        break
                    }
                }
                
                guard let sf2URL = sf2URL else {
                    print("❌ SF2 file not found (tried: \(sf2Candidates.map { "\($0.0).\($0.1)" }.joined(separator: ", ")))")
                    await MainActor.run { isPlaying = false }
                    return
                }
                
                // Score作成
                let score = Score.from(slots: slots, bpm: bpm)
                print("✅ Score created: \(score.barCount) bars, BPM=\(score.bpm)")
                print("🔍 Slots used: \(slots.compactMap { $0 })")
                
                // 準備（先にSF2をロード）
                print("🔧 HybridPlayer: preparing with SF2...")
                try player.prepare(sf2URL: sf2URL, drumKitURL: nil)
                print("✅ HybridPlayer: SF2 loaded")
                
                // 各小節のギターPCMバッファ生成
                var guitarBuffers: [AVAudioPCMBuffer] = []
                for bar in score.bars {
                    let key = GuitarBounceService.CacheKey(
                        chord: bar.chord,
                        program: UInt8(instruments[selectedInstrument].1),
                        bpm: bpm
                    )
                    print("🔧 Bouncing Guitar: \(bar.chord)...")
                    // ✅ strumMs を 0.0 に設定（完全同時発音）
                    // ✅ releaseMs を 80 に設定（自然な余韻）
                    let buffer = try bounce.buffer(for: key, sf2URL: sf2URL, strumMs: 0.0, releaseMs: 80.0)
                    guitarBuffers.append(buffer)
                }
                
                print("✅ All guitar buffers generated: \(guitarBuffers.count) bars")
                
                // 各小節のベースPCMバッファ生成（Phase C-2.5）
                var bassBuffers: [AVAudioPCMBuffer] = []
                for bar in score.bars {
                    let key = BassBounceService.CacheKey(
                        chord: bar.chord,
                        program: 34,  // Electric Bass (finger)
                        bpm: bpm
                    )
                    print("🔧 Bouncing Bass: \(bar.chord)...")
                    let buffer = try bass.buffer(for: key, sf2URL: sf2URL)
                    bassBuffers.append(buffer)
                }
                
                print("✅ All bass buffers generated: \(bassBuffers.count) bars")
                
                // 再生（ギター+ベースのみ）
                try player.play(
                    score: score,
                    guitarBuffers: guitarBuffers,
                    bassBuffers: bassBuffers,
                    drumBuffer: nil,  // ドラムなし
                    onBarChange: { slotIndex in
                        DispatchQueue.main.async {
                            self.currentSlotIndex = slotIndex
                            
                            // Phase E-5: Auto-switch section during full song playback
                            if self.progressionStore.useSectionMode && self.playbackMode == .fullSong {
                                self.autoSwitchSection(for: slotIndex)
                            }
                        }
                    }
                )
                
                print("✅ HybridPlayer: playback started")
            } catch {
                print("❌ HybridPlayer error: \(error)")
                await MainActor.run {
                    isPlaying = false
                }
            }
        }
    }
    
    private func stopPlayback() {
        isPlaying = false
        currentSlotIndex = nil
        
        // Phase B: Try HybridPlayer first, fallback to ChordSequencer
        if hybridPlayer != nil {
            hybridPlayer?.stop()
            print("✅ HybridPlayer: stopped")
        } else {
            sequencer?.stop()
            print("✅ ChordSequencer: stopped")
        }
    }
    
    /// Phase E-5: Auto-switch to the section that contains the given slot index
    private func autoSwitchSection(for slotIndex: Int) {
        guard progressionStore.useSectionMode else { return }
        
        var cumulativeSlots = 0
        
        for sectionId in progressionStore.playbackOrder.expandedSectionIds {
            guard let section = progressionStore.sectionDefinitions.first(where: { $0.id == sectionId }) else {
                continue
            }
            
            let sectionSlotCount = section.chords.count
            
            // Check if slotIndex falls within this section's range
            if slotIndex < cumulativeSlots + sectionSlotCount {
                // Calculate local slot index within the section
                let localSlotIndex = slotIndex - cumulativeSlots
                
                // Switch to this section if not already current
                if progressionStore.currentSectionId != sectionId {
                    progressionStore.currentSectionId = sectionId
                    print("🔄 Auto-switched to section '\(section.name)', local slot: \(localSlotIndex)")
                } else {
                    print("🎵 Same section '\(section.name)', local slot: \(localSlotIndex)")
                }
                
                // Always update the local slot index for highlighting
                self.currentSlotIndex = localSlotIndex
                
                return
            }
            
            cumulativeSlots += sectionSlotCount
        }
    }
    
    // 注意: カウントインはChordSequencer内で実装されているため、この関数は不要
    // （Phase 2では MusicSequence のクリックトラックで実装）
    
    // 音色変更
    private func changeInstrument(_ program: Int) {
        print("🎵 Changing instrument to program: \(program)")
        
        // Preview用: AudioPlayer
        audioPlayer.changeInstrument(UInt8(program))
        
        // Sequencer用: ChordSequencer
        sequencer?.changeInstrument(UInt8(program))
    }
}

// MARK: - SlotView Component

struct SlotView: View {
    let index: Int
    let chord: String?
    let isCursor: Bool
    let isPlaying: Bool
    let isHighlighted: Bool  // New: for newly added chords
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    
    // 色の計算を分割
    private var fillColor: Color {
        if isPlaying {
            return Color.orange.opacity(0.3)
        } else if isHighlighted {
            return Color.green.opacity(0.25)  // Highlighted color
        } else if chord != nil {
            return Color.blue.opacity(0.15)
        } else if isCursor {
            return Color.green.opacity(0.1)
        } else {
            return Color.gray.opacity(0.05)
        }
    }
    
    private var strokeColor: Color {
        if isPlaying {
            return Color.orange
        } else if isHighlighted {
            return Color.green  // Highlighted color
        } else if chord != nil {
            return Color.blue
        } else if isCursor {
            return Color.green
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var strokeWidth: CGFloat {
        if isPlaying {
            return 4
        } else if isHighlighted {
            return 4  // Highlighted thickness
        } else if isCursor {
            return 3
        } else {
            return 2
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(fillColor)
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(strokeColor, lineWidth: strokeWidth)
                    )
                
                // Top-left badge (slot number)
                Text("\(index + 1)")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(4)
                    .padding(6)
                
                // Chord name (center)
                if let chord = chord {
                    Text(chord)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Delete button (top-right) - Web版のバツマーク
                if chord != nil, let onDelete = onDelete {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: onDelete) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 20))
                                    .background(Color.white.clipShape(Circle()))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(6)
                        }
                        Spacer()
                    }
                }
                
                // "New!" indicator for highlighted slots
                if isHighlighted {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("New!")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(12)
                                .padding(8)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHighlighted ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHighlighted)
    }
}

// MARK: - Section Marker (Phase 2)

struct SectionMarker: View {
    let section: Section
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: section.name.icon)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(section.name.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text("Bars \(section.range.lowerBound + 1)-\(section.range.upperBound + 1)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            if section.repeatCount > 1 {
                HStack(spacing: 2) {
                    Image(systemName: "repeat")
                        .font(.system(size: 10))
                    Text("×\(section.repeatCount)")
                        .font(.system(size: 10))
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.blue.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.blue, lineWidth: 1)
        )
    }
}

// MARK: - Scale Candidate Button (Phase A-3)

struct ScaleCandidateButton: View {
    let candidate: ScaleCandidate
    let index: Int
    let isSelected: Bool
    let isPlaying: Bool
    let progress: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .leading) {
                // Progress bar background (shows when playing this scale)
                if isPlaying {
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.green.opacity(0.3))
                            .frame(width: geometry.size.width * (1.0 - progress))
                            .animation(.linear(duration: 0.1), value: progress)
                    }
                }
                
                HStack {
                    // Scale name
                    VStack(alignment: .leading, spacing: 4) {
                        Text(scaleTypeToDisplayName(candidate.type))
                            .font(.body)
                            .fontWeight(isSelected ? .bold : .semibold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Fit percentage (compact)
                    Text("\(candidate.score)%")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(fitColor(candidate.score))
                    
                    // Selection indicator
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                }
                .padding()
            }
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private func scaleTypeToDisplayName(_ type: String) -> String {
        switch type {
        case "Ionian": return "Major Scale"
        case "Dorian": return "Dorian"
        case "Phrygian": return "Phrygian"
        case "Lydian": return "Lydian"
        case "Mixolydian": return "Mixolydian"
        case "Aeolian": return "Natural Minor"
        case "Locrian": return "Locrian"
        case "HarmonicMinor": return "Harmonic Minor"
        case "MelodicMinor": return "Melodic Minor"
        case "MajorPentatonic": return "Major Pentatonic"
        case "MinorPentatonic": return "Minor Pentatonic"
        case "Blues": return "Blues"
        default: return type
        }
    }
    
    private func fitColor(_ score: Int) -> Color {
        if score >= 90 { return .green }
        if score >= 70 { return .yellow }
        return .orange
    }
    
}

// MARK: - Section Chip

struct SectionChip: View {
    let section: SectionDefinition
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: section.type.icon)
                    .font(.caption)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(section.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(section.filledSlotsCount)/12")
                        .font(.caption2)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.secondary.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
        }
    }
}

// MARK: - Playback Mode (Phase E-5)

enum PlaybackMode: String, CaseIterable {
    case fullSong = "Full Song"
    case currentSection = "Current Section"
    
    var icon: String {
        switch self {
        case .fullSong: return "play.rectangle.fill"
        case .currentSection: return "play.square.fill"
        }
    }
}

// MARK: - Fretboard Display Mode

enum FretboardDisplay {
    case degrees
    case names
    
    var label: String {
        switch self {
        case .degrees: return "Degrees"
        case .names: return "Names"
        }
    }
    
    var icon: String {
        switch self {
        case .degrees: return "circle.grid.cross"
        case .names: return "textformat.abc"
        }
    }
}

#Preview {
    ProgressionView()
}
