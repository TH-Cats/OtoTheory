import SwiftUI
import AVFoundation

// MARK: - Unified toolbar label style (icon over text, fixed min height)
struct VerticalToolbarLabelStyle: LabelStyle {
    var spacing: CGFloat = 4
    var symbolSize: CGFloat = 20   // アイコンの"枠"を固定

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: spacing) {
            configuration.icon
                .symbolRenderingMode(.monochrome)
                .font(.system(size: symbolSize, weight: .regular)) // 絶対サイズ
                .frame(height: symbolSize)                          // バウンディングを統一

            configuration.title
                .font(.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

// Fixed height bordered style for uniform button heights
struct BorderedTintFixedHeightButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var height: CGFloat = 45
    var cornerRadius: CGFloat = 12
    var disabledOpacity: Double = 0.45

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: height) // 固定で統一（minHeightではなく）
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.tint, lineWidth: 1)
            )
            .foregroundStyle(.tint)
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1.0) : disabledOpacity)
    }
}

// MARK: - Constants

private enum ProgressionConstants {
    static let defaultBPM: Double = 120
    static let defaultKey: String = "C"
    static let simulatedAnalysisDelay: UInt64 = 1_000_000_000 // 1 second in nanoseconds
}

struct ProgressionView: View {
    @StateObject private var progressionStore = ProgressionStore.shared
    @State private var cursorIndex = 0
    @State private var selectedChords: Set<Int> = []
    
    // Computed property for backward compatibility
    private var slots: [String?] {
        get { progressionStore.slots }
        nonmutating set { progressionStore.slots = newValue }
    }
    
    // Active slots (section-aware)
    private var activeSlots: [String?] {
        progressionStore.activeSlots
    }
    
    // Audio Architecture
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var sketchManager = SketchManager.shared
    @StateObject private var proManager = ProManager.shared
    @State private var sequencer: ChordSequencer?  // Legacy MIDI sequencer
    @State private var hybridPlayer: HybridPlayer?
    @State private var bounceService: GuitarBounceService?
    @State private var bassService: BassBounceService?
    @State private var scalePreviewPlayer: ScalePreviewPlayer?
    @State private var scrollToResult = false
    
    // Chord builder state
    @State private var selectedRoot: String = ProgressionConstants.defaultKey
    @State private var selectedQuick: String = ""
    
    // Advanced Chord Builder (Pro)
    @State private var showAdvanced: Bool = false
    @State private var selectedSlashBass: String? = nil  // For slash chords
    
    // Slash Chord Editor (Pro)
    @State private var editingSlotIndex: Int? = nil
    @State private var showSlashEditor = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = "checkmark.circle.fill"
    @State private var toastColor: Color = .green
    
    // Playback state
    @State private var isPlaying = false
    @State private var bpm: Double = ProgressionConstants.defaultBPM
    @State private var bpmPickerValue: Int = Int(ProgressionConstants.defaultBPM)
    @State private var currentSlotIndex: Int? = nil
    @State private var selectedInstrument: Int = 0
    @State private var playbackMode: PlaybackMode = .fullSong // Full song or per-section playback
    
    private let instruments = [
        ("Acoustic Steel", 25),
        ("Electric Clean", 27),
        ("Electric Muted", 28),
        ("Piano", 0)
    ]
    
    // Preset state
    @State private var showPresetPicker = false
    @State private var selectedPresetKey: String = ProgressionConstants.defaultKey
    
    // Pro / Paywall state
    @State private var showPaywall = false
    
    // Section state (Legacy)
    @State private var sections: [Section] = []
    @State private var showSectionEditor = false
    
    // Section mode
    @State private var showSectionManagement = false
    
    // Sketch state
    @State private var showSaveDialog = false
    @State private var sketchName: String = ""
    @State private var currentSketchId: String?
    
    // Convert to Section state
    @State private var showConvertSheet = false
    
    // Analysis state
    @State private var keyCandidates: [KeyCandidate] = []
    @State private var selectedKeyIndex: Int? = nil
    @State private var scaleCandidates: [ScaleCandidate] = []
    @State private var selectedScaleIndex: Int? = nil
    @State private var isAnalyzed = false
    @State private var isAnalyzing = false
    
    // Fretboard & Diatonic state
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
        var chord = selectedRoot
        
        // Add quality suffix only if it's not Major
        if selectedQuick != "Major" && !selectedQuick.isEmpty {
            // Remove parenthetical descriptions from quality (e.g., "m (minor)" -> "m", "M9 (maj9)" -> "M9")
            let cleanQuality = selectedQuick.components(separatedBy: " (").first ?? selectedQuick
            chord += cleanQuality
        }
        
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
        // Initialize HybridPlayer for audio playback
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
                    let bass = try BassBounceService(sf2URL: url)
                    _bounceService = State(initialValue: bounce)
                    _bassService = State(initialValue: bass)  // ベースサービスを保存
                    
                    // Initialize ScalePreviewPlayer for scale audio preview
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
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 24) {
                            buildProgressionSection
                            chordBuilderSection
                            analyzeAndResultSection
                                .id("resultSection")
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    .onChange(of: scrollToResult) { _, shouldScroll in
                        if shouldScroll {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                proxy.scrollTo("resultSection", anchor: .top)
                            }
                            scrollToResult = false
                        }
                    }
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
        .sheet(isPresented: $showConvertSheet) {
            ConvertToSectionSheet(
                progressionStore: progressionStore,
                onConvert: { sectionType, sectionName in
                    performConvertToSections(type: sectionType, name: sectionName)
                }
            )
        }
        .sheet(isPresented: $showSlashEditor) {
            // Slash Chord Editor Sheet
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
        .onReceive(NotificationCenter.default.publisher(for: .loadSketch)) { notification in
            // Load sketch from notification
            guard let sketchId = notification.userInfo?["sketchId"] as? String,
                  let sketch = sketchManager.sketches.first(where: { $0.id == sketchId }) else {
                print("⚠️ Sketch not found")
                return
            }
            
            loadSketch(sketch)
        }
    }
    
    // MARK: - View Sections
    
    // MARK: - Section Picker
    
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
    private var sectionCards: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var buildProgressionSection: some View {
        Group {
            buildProgressionHeader
            playbackControls
            sectionMarkers
            
            // Section Picker (if section mode is enabled) - show section cards only
            if progressionStore.useSectionMode {
                sectionCards
            }
            
            slotsGrid
            
            // Contextual convert to sections prompt
            if !progressionStore.useSectionMode && !progressionStore.slots.compactMap({ $0 }).isEmpty {
                Button(action: { showConvertSheet = true }) {
                    Text("Convert to sections?")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var buildProgressionHeader: some View {
                // Build Progression Section
                VStack(alignment: .leading, spacing: 12) {
                        // Title with Info Button
                        HStack {
                            Text("Build Progression")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Button(action: {
                                // Show info alert
                                let isJapanese = Locale.current.language.languageCode?.identifier == "ja"
                                let title = "Build Progression"
                                let message = isJapanese ? 
                                    "Choose Chordsからコードを選んでスロットに追加ボタンから追加してください。上部のプリセットからコード進行を選択して追加することもできます。" :
                                    "Select chords from Choose Chords and add them using the slot add button. You can also select chord progressions from the presets at the top to add them."
                                
                                let alert = UIAlertController(
                                    title: title,
                                    message: message,
                                    preferredStyle: .alert
                                )
                                alert.addAction(UIAlertAction(title: "OK", style: .default))
                                
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    window.rootViewController?.present(alert, animated: true)
                                }
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Buttons row unified
                        HStack(spacing: 8) {
                            Button(action: { showPresetPicker = true }) {
                                Label("Preset", systemImage: "music.note.list")
                            }
                            .labelStyle(VerticalToolbarLabelStyle())

                            Button(action: {
                                if !progressionStore.useSectionMode { progressionStore.enableSectionMode() }
                                showSectionManagement = true
                            }) {
                                Label {
                                    HStack(spacing: 2) {
                                        Text("Section")
                                        if progressionStore.useSectionMode && !progressionStore.sectionDefinitions.isEmpty {
                                            Text("(\(progressionStore.sectionDefinitions.count))")
                                        }
                                    }
                                } icon: {
                                    Image(systemName: progressionStore.useSectionMode ? "square.grid.3x2.fill" : "square.grid.3x2")
                                }
                            }
                            .labelStyle(VerticalToolbarLabelStyle())

                            Button(action: resetProgression) {
                                Label("Reset", systemImage: "arrow.counterclockwise")
                            }
                            .labelStyle(VerticalToolbarLabelStyle())

                            Button(action: {
                                analyzeProgression()
                                // Scroll to result section after analysis
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.8)) {
                                        scrollToResult = true
                                    }
                                }
                            }) {
                                Label("Analyze", systemImage: "magnifyingglass")
                            }
                            .labelStyle(VerticalToolbarLabelStyle())
                            .disabled(!hasEnoughChords || isAnalyzing)

                            Button(action: { showSaveDialog = true }) {
                                Label("Save", systemImage: "square.and.arrow.down")
                            }
                            .labelStyle(VerticalToolbarLabelStyle())
                            .disabled(progressionStore.slots.compactMap({ $0 }).isEmpty)
                        }
                        .buttonStyle(BorderedTintFixedHeightButtonStyle(height: 45))
                        .tint(.blue)
                        .buttonBorderShape(.roundedRectangle)
                        .padding(.horizontal)
                }
    }
    
    @ViewBuilder
    private var playbackControls: some View {
                            // Playback Controls
                            VStack(spacing: 12) {
                                // Compact controls: Play mode, BPM Slider, Instrument (single row)
                                HStack(spacing: 12) {
                                    Spacer(minLength: 0) // align left edge with top buttons' left padding
                                    
                                    // Play mode buttons (when in section mode) or single Play button
                                    if progressionStore.useSectionMode {
                                        // Full Song button
                                        Button(action: { 
                                            playbackMode = .fullSong
                                            togglePlayback()
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: isPlaying && playbackMode == .fullSong ? "stop.fill" : "play.fill")
                                                    .font(.system(size: 14))
                                                Text("Full Song")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(playbackMode == .fullSong ? (isPlaying ? Color.red : Color.blue) : Color.secondary.opacity(0.1))
                                            .foregroundColor(playbackMode == .fullSong ? .white : .primary)
                                            .cornerRadius(6)
                                        }
                                        
                                        // Current Section button
                                        Button(action: { 
                                            playbackMode = .currentSection
                                            togglePlayback()
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: isPlaying && playbackMode == .currentSection ? "stop.fill" : "play.rectangle.fill")
                                                    .font(.system(size: 14))
                                                Text("Section")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(playbackMode == .currentSection ? (isPlaying ? Color.red : Color.blue) : Color.secondary.opacity(0.1))
                                            .foregroundColor(playbackMode == .currentSection ? .white : .primary)
                                            .cornerRadius(6)
                                        }
                                    } else {
                                        // Single Play button (when not in section mode)
                                        Button(action: togglePlayback) {
                                            HStack(spacing: 6) {
                                                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                                    .font(.system(size: 16))
                                                Text(isPlaying ? "Stop" : "Play")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(isPlaying ? Color.red : Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                        }
                                    }

                                    // BPM Control (Slider: 40...240 step 5) — compact
                                    VStack(spacing: 2) {
                                        Text("BPM \(Int(bpm))")
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                        Slider(value: $bpm, in: 40...240, step: 5)
                                            .frame(height: 20)
                                    }
                                    .frame(maxWidth: .infinity)

                                    // Instrument Picker (with up/down arrows like scale picker)
                                    HStack(spacing: 4) {
                                        Text(instruments[selectedInstrument].0)
                                            .font(.caption)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.9)
                                        
                                        Menu {
                                            ForEach(instruments.indices, id: \.self) { i in
                                                Button {
                                                    selectedInstrument = i
                                                    changeInstrument(instruments[i].1)
                                                } label: {
                                                    HStack {
                                                        Text(instruments[i].0)
                                                        if i == selectedInstrument {
                                                            Image(systemName: "checkmark")
                                                        }
                                                    }
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .frame(height: 44) // compact row height
                            }
                            .padding(.horizontal)
    }
    
    @ViewBuilder
    private var sectionMarkers: some View {
                        // Section Markers
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
                    // Slash Chord Editor (Pro)
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
                // Choose Chords Section
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
                    Button(action: {
                        analyzeProgression()
                        // Scroll to result section after analysis
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                scrollToResult = true
                            }
                        }
                    }) {
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
                            .bold()
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
                                            Text("\(candidate.tonic) \(scaleTypeToDisplayName(candidate.mode))")
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
                            Text("\(key.tonic) \(scaleTypeToDisplayName(scale.type))")
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
            
            // Save Button Section
            saveButtonSection
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
                
                // Debug log moved outside ViewBuilder
                let _ = print("🎯 Fretboard overlay: scale=\(scale.type), key=\(key.tonic), rootPc=\(rootPc), ghost=\(overlay.shouldShowGhost), hasScale=\(overlay.hasScale), hasChord=\(overlay.hasChord), overlayChordNotes=\(overlayChordNotes)")
                
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
            // Heading removed per spec
            
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
        if let key = selectedKey, let scale = selectedScale {
            let slots = progressionStore.useSectionMode ? progressionStore.combinedProgression : progressionStore.slots
            let chords = slots.compactMap { $0 }
            
            if !chords.isEmpty {
                let patterns = detectPatterns(chords: chords, key: key, scale: scale)
                
                if !patterns.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Patterns")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(patterns, id: \.name) { pattern in
                                HStack(spacing: 8) {
                                    Text(pattern.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                    
                                    Text("(\(pattern.romanPattern))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("Bars \(pattern.startIndex + 1)-\(pattern.endIndex + 1)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // MARK: - Cadence Section
    
    @ViewBuilder
    private var cadenceSection: some View {
        if let key = selectedKey, let scale = selectedScale {
            let slots = progressionStore.useSectionMode ? progressionStore.combinedProgression : progressionStore.slots
            let chords = slots.compactMap { $0 }
            
            if !chords.isEmpty {
                let cadences = detectCadences(chords: chords, key: key, scale: scale)
                
                if !cadences.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cadence")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(cadences, id: \.name) { cadence in
                                HStack(spacing: 8) {
                                    Text(cadence.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.purple)
                                    
                                    Text("(\(cadence.romanPattern))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("Bars \(cadence.startIndex + 1)-\(cadence.endIndex + 1)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // MARK: - Save Button Section
    
    @ViewBuilder
    private var saveButtonSection: some View {
        let hasChords = progressionStore.useSectionMode 
            ? progressionStore.sectionDefinitions.contains(where: { $0.hasChords })
            : progressionStore.slots.compactMap({ $0 }).count > 0
        
        if hasChords {
            VStack(spacing: 16) {
                Divider()
                    .padding(.horizontal)
                
                Button {
                    // Generate default name
                    sketchName = sketchManager.generateDefaultName()
                    showSaveDialog = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save Sketch")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Roman Numeral Helper
    
    private func getRomanNumeral(for chord: String, key: KeyCandidate, scale: ScaleCandidate) -> String {
        // Parse chord root (handle # and b)
        var chordRoot = ""
        if chord.count > 1 {
            let secondChar = chord[chord.index(chord.startIndex, offsetBy: 1)]
            if secondChar == "#" || secondChar == "♯" || secondChar == "b" || secondChar == "♭" {
                chordRoot = String(chord.prefix(2))
            } else {
                chordRoot = String(chord.prefix(1))
            }
        } else {
            chordRoot = String(chord.prefix(1))
        }
        
        // Get pitch classes
        let keyPitchClass = keyToPitchClass(key.tonic)
        let chordPitchClass = keyToPitchClass(chordRoot)
        
        // Calculate interval from key
        let interval = (chordPitchClass - keyPitchClass + 12) % 12
        
        // Get quality (major/minor/dim)
        let isMinor = chord.contains("m") && !chord.contains("maj")
        let isDim = chord.contains("dim") || chord.contains("°")
        let isAug = chord.contains("aug") || chord.contains("+")
        
        // Roman numerals for all 12 chromatic intervals
        let diatonicIntervals = [0, 2, 4, 5, 7, 9, 11]
        let romanNumerals = ["I", "II", "III", "IV", "V", "VI", "VII"]
        
        // Find closest diatonic degree
        var roman = ""
        if let index = diatonicIntervals.firstIndex(of: interval) {
            // Exact diatonic match
            roman = romanNumerals[index]
        } else {
            // Chromatic note - find nearest diatonic and add accidental
            let nearestLower = diatonicIntervals.filter { $0 < interval }.max() ?? 0
            let nearestUpper = diatonicIntervals.filter { $0 > interval }.min() ?? 12
            
            let distToLower = interval - nearestLower
            let distToUpper = nearestUpper - interval
            
            if distToLower <= distToUpper {
                // Use lower with sharp
                if let lowerIndex = diatonicIntervals.firstIndex(of: nearestLower) {
                    roman = "♯" + romanNumerals[lowerIndex]
                }
            } else {
                // Use upper with flat
                if let upperIndex = diatonicIntervals.firstIndex(of: nearestUpper) {
                    roman = "♭" + romanNumerals[upperIndex]
                }
            }
        }
        
        // Apply quality
        if isMinor {
            roman = roman.lowercased()
        } else if isDim {
            roman = roman.lowercased() + "°"
        } else if isAug {
            roman = roman + "+"
        }
        
        // Add quality suffix
        if chord.contains("7") && !chord.contains("maj7") {
            roman += "7"
        } else if chord.contains("maj7") {
            roman += "maj7"
        }
        
        return roman
    }
    
    // MARK: - Pattern & Cadence Detection
    
    struct ProgressionPattern: Identifiable {
        let id = UUID()
        let name: String
        let romanPattern: String
        let startIndex: Int
        let endIndex: Int
    }
    
    struct CadencePattern: Identifiable {
        let id = UUID()
        let name: String
        let romanPattern: String
        let startIndex: Int
        let endIndex: Int
    }
    
    private func detectPatterns(chords: [String], key: KeyCandidate, scale: ScaleCandidate) -> [ProgressionPattern] {
        guard chords.count >= 4 else { return [] }
        
        var patterns: [ProgressionPattern] = []
        let romans = chords.map { getRomanNumeral(for: $0, key: key, scale: scale) }
        
        // Canon progression (I-V-vi-IV)
        for i in 0...(chords.count - 4) {
            let slice = Array(romans[i..<(i+4)])
            
            if matchesPattern(slice, ["I", "V", "vi", "IV"]) {
                patterns.append(ProgressionPattern(
                    name: "Canon Progression",
                    romanPattern: "I-V-vi-IV",
                    startIndex: i,
                    endIndex: i + 3
                ))
            }
            else if matchesPattern(slice, ["I", "vi", "IV", "V"]) {
                patterns.append(ProgressionPattern(
                    name: "Doo-wop",
                    romanPattern: "I-vi-IV-V",
                    startIndex: i,
                    endIndex: i + 3
                ))
            }
            else if matchesPattern(slice, ["I", "IV", "V", "IV"]) {
                patterns.append(ProgressionPattern(
                    name: "Blues I-IV-V",
                    romanPattern: "I-IV-V-IV",
                    startIndex: i,
                    endIndex: i + 3
                ))
            }
            else if matchesPattern(slice, ["vi", "IV", "I", "V"]) {
                patterns.append(ProgressionPattern(
                    name: "Pop Progression",
                    romanPattern: "vi-IV-I-V",
                    startIndex: i,
                    endIndex: i + 3
                ))
            }
        }
        
        // ii-V-I (Jazz, 3 chords)
        for i in 0...(chords.count - 3) {
            let slice = Array(romans[i..<(i+3)])
            if matchesPattern(slice, ["ii", "V", "I"]) {
                patterns.append(ProgressionPattern(
                    name: "ii-V-I (Jazz)",
                    romanPattern: "ii-V-I",
                    startIndex: i,
                    endIndex: i + 2
                ))
            }
        }
        
        // 50s progression (I-vi-ii-V)
        for i in 0...(chords.count - 4) {
            let slice = Array(romans[i..<(i+4)])
            if matchesPattern(slice, ["I", "vi", "ii", "V"]) {
                patterns.append(ProgressionPattern(
                    name: "50s Progression",
                    romanPattern: "I-vi-ii-V",
                    startIndex: i,
                    endIndex: i + 3
                ))
            }
        }
        
        return patterns
    }
    
    private func detectCadences(chords: [String], key: KeyCandidate, scale: ScaleCandidate) -> [CadencePattern] {
        guard chords.count >= 2 else { return [] }
        
        var cadences: [CadencePattern] = []
        let romans = chords.map { getRomanNumeral(for: $0, key: key, scale: scale) }
        
        for i in 0...(chords.count - 2) {
            let current = romans[i]
            let next = romans[i + 1]
            
            // Perfect Cadence (V-I)
            if matchesPattern([current, next], ["V", "I"]) {
                cadences.append(CadencePattern(
                    name: "Perfect Cadence",
                    romanPattern: "V→I",
                    startIndex: i,
                    endIndex: i + 1
                ))
            }
            // Plagal Cadence (IV-I)
            else if matchesPattern([current, next], ["IV", "I"]) {
                cadences.append(CadencePattern(
                    name: "Plagal Cadence",
                    romanPattern: "IV→I",
                    startIndex: i,
                    endIndex: i + 1
                ))
            }
            // Deceptive Cadence (V-vi)
            else if matchesPattern([current, next], ["V", "vi"]) {
                cadences.append(CadencePattern(
                    name: "Deceptive Cadence",
                    romanPattern: "V→vi",
                    startIndex: i,
                    endIndex: i + 1
                ))
            }
        }
        
        // Half Cadence (ending on V)
        if romans.count > 0 && romans.last == "V" {
            cadences.append(CadencePattern(
                name: "Half Cadence",
                romanPattern: "...→V",
                startIndex: max(0, romans.count - 2),
                endIndex: romans.count - 1
            ))
        }
        
        return cadences
    }
    
    private func matchesPattern(_ romanNumerals: [String], _ pattern: [String]) -> Bool {
        guard romanNumerals.count == pattern.count else { return false }
        for (roman, expected) in zip(romanNumerals, pattern) {
            // Remove quality suffixes for matching (e.g., "V7" matches "V")
            let cleanRoman = roman.replacingOccurrences(of: "7", with: "")
                                   .replacingOccurrences(of: "maj", with: "")
                                   .replacingOccurrences(of: "°", with: "")
            if cleanRoman != expected {
                return false
            }
        }
        return true
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
    
    // Comprehensive chord to MIDI conversion
    private func chordToMidi(_ chordSymbol: String) -> [UInt8] {
        // Debug log for input chord symbol
        print("🎼 Input chordSymbol: '\(chordSymbol)'")
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
        
        // Handle slash chords (on chords) and compound qualities like 6/9
        let parts = chordSymbol.split(separator: "/")
        var mainChord = String(parts[0])
        var slashBass = parts.count > 1 ? String(parts[1]) : nil
        
        print("🔍 Slash parsing: parts=\(parts), mainChord='\(mainChord)', slashBass='\(slashBass ?? "nil")'")
        
        // Special case: 6/9 is a compound quality, not a slash chord
        if mainChord.contains("6/9") {
            slashBass = nil // Not a slash chord
            print("🎯 Detected 6/9 compound quality")
        }
        
        // Extract root and quality from main chord
        var root = ""
        var quality = ""
        
        if mainChord.count >= 2 && (mainChord[mainChord.index(mainChord.startIndex, offsetBy: 1)] == "#" || mainChord[mainChord.index(mainChord.startIndex, offsetBy: 1)] == "b") {
            root = String(mainChord.prefix(2))
            quality = String(mainChord.dropFirst(2))
        } else {
            root = String(mainChord.prefix(1))
            quality = String(mainChord.dropFirst(1))
        }
        
        guard let rootNote = rootMap[root] else {
            return [60, 64, 67] // Default to C major
        }
        
        // Debug log for quality parsing
        print("🔍 Parsed chord: root='\(root)', quality='\(quality)'")
        
        // Determine intervals based on quality
        var intervals: [UInt8] = [0, 4, 7] // Default: major triad
        
        if quality.isEmpty || quality == "Major" {
            intervals = [0, 4, 7] // Major triad
        } else if quality == "m" || quality == "m (minor)" {
            intervals = [0, 3, 7] // Minor triad
        } else if quality.contains("dim") && !quality.contains("7") {
            intervals = [0, 3, 6] // Diminished triad
        } else if quality.contains("dim7") {
            intervals = [0, 3, 6, 9] // Diminished 7th
        } else if quality.contains("aug") {
            intervals = [0, 4, 8] // Augmented triad
        } else if quality == "7" {
            intervals = [0, 4, 7, 10] // Dominant 7th
        } else if quality.contains("maj7") || quality.contains("M7") {
            intervals = [0, 4, 7, 11] // Major 7th
        } else if quality == "m7" {
            intervals = [0, 3, 7, 10] // Minor 7th
        } else if quality.contains("m7b5") {
            intervals = [0, 3, 6, 10] // Minor 7th flat 5
        } else if quality.contains("mM7") {
            intervals = [0, 3, 7, 11] // Minor major 7th
        } else if quality == "sus4" {
            intervals = [0, 5, 7] // Suspended 4th
        } else if quality == "sus2" {
            intervals = [0, 2, 7] // Suspended 2nd
        } else if quality == "7sus4" {
            intervals = [0, 5, 7, 10] // Dominant 7th suspended 4th
        } else if quality.contains("add9") {
            intervals = [0, 4, 7, 14] // Major add 9
        } else if quality.contains("add#11") {
            intervals = [0, 4, 7, 18] // Major add sharp 11
        } else if quality.contains("M9") || quality.contains("maj9") {
            intervals = [0, 4, 7, 11, 14] // Major 9th
        } else if quality.contains("m9") {
            intervals = [0, 3, 7, 10, 14] // Minor 9th
        } else if quality.contains("m11") {
            intervals = [0, 3, 7, 10, 14, 17] // Minor 11th
        } else if quality == "6" {
            intervals = [0, 4, 7, 9] // Major 6th (根音、3度、5度、6度)
        } else if quality.contains("6/9") {
            intervals = [0, 4, 7, 9, 14] // Major 6/9 (根音、3度、5度、6度、9度)
            // 6度と9度の両方を含む豊かな響き
        } else if quality.contains("m6") {
            intervals = [0, 3, 7, 9] // Minor 6th
        } else if quality.contains("7(#9)") {
            intervals = [0, 4, 7, 10, 15] // Dominant 7th sharp 9
        } else if quality.contains("7(b9)") {
            intervals = [0, 4, 7, 10, 13] // Dominant 7th flat 9
        } else if quality.contains("7(#5)") {
            intervals = [0, 4, 8, 10] // Dominant 7th sharp 5
        } else if quality.contains("7(b13)") {
            intervals = [0, 4, 7, 10, 20] // Dominant 7th flat 13
        }
        
        // Convert intervals to MIDI notes
        var midiNotes = intervals.map { rootNote + $0 }
        
        // Handle slash chord bass note
        if let slashBass = slashBass, let bassNote = rootMap[slashBass] {
            // Replace the lowest note with the bass note
            midiNotes[0] = bassNote
            // Ensure bass note is the lowest
            midiNotes.sort()
        }
        
        // Debug log for chord generation
        let noteNames = midiNotes.map { note in
            let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
            return noteNames[Int(note) % 12]
        }
        print("🎵 Generated chord: \(chordSymbol) -> MIDI: \(midiNotes) -> Notes: \(noteNames)")
        
        return midiNotes
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
        // Exit section mode completely
        progressionStore.useSectionMode = false
        progressionStore.sectionDefinitions.removeAll()
        progressionStore.playbackOrder = PlaybackOrder()
        progressionStore.currentSectionId = nil
        
        // Clear all slots
        slots = Array(repeating: nil, count: 12)
        
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
    
    private func generateUniqueSectionName(baseName: String) -> String {
        let existingNames = progressionStore.sectionDefinitions.map { $0.name }
        
        // If base name is unique, use it
        if !existingNames.contains(baseName) {
            return baseName
        }
        
        // Find the next available number
        var counter = 1
        var uniqueName = "\(baseName) (\(counter))"
        
        while existingNames.contains(uniqueName) {
            counter += 1
            uniqueName = "\(baseName) (\(counter))"
        }
        
        return uniqueName
    }
    
    private func performConvertToSections(type: SectionType, name: String) {
        // Convert current progression to section mode
        let currentChords = progressionStore.slots
        
        // Generate unique name if needed
        let uniqueName = generateUniqueSectionName(baseName: name)
        
        // Create a section with user's choice
        let newSection = progressionStore.createSection(name: uniqueName, type: type)
        
        // Copy chords to the new section
        if let index = progressionStore.sectionDefinitions.firstIndex(where: { $0.id == newSection }) {
            progressionStore.sectionDefinitions[index].chords = currentChords
        }
        
        // Enable section mode
        progressionStore.useSectionMode = true
        progressionStore.currentSectionId = newSection
        
        // Clear original slots
        progressionStore.slots = Array(repeating: nil, count: 12)
        
        // Close the sheet
        showConvertSheet = false
        
        // Show success toast
        toastMessage = "Converted to section mode"
        toastIcon = "music.note.list"
        toastColor = .blue
        showToast = true
        
        print("✅ Converted to section mode: \(currentChords.compactMap { $0 }.count) chords")
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
        
        // Build section info for weighted analysis
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
        
        // Simulate analysis delay
        Task {
            try? await Task.sleep(nanoseconds: ProgressionConstants.simulatedAnalysisDelay)
            
            await MainActor.run {
                // Analyze with section weights
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
        guard index < keyCandidates.count else { 
            print("❌ selectKey: index \(index) out of range (0-\(keyCandidates.count-1))")
            return 
        }
        
        selectedKeyIndex = index
        let candidate = keyCandidates[index]
        
        // Fetch scale candidates for selected key
        guard let bridge = theoryBridge else { 
            print("❌ selectKey: theoryBridge is nil")
            return 
        }
        
        // Use combinedProgression for full song analysis
        let slots = progressionStore.useSectionMode ? progressionStore.combinedProgression : progressionStore.slots
        let chords = slots.compactMap { $0 }
        
        print("🔍 selectKey: analyzing \(chords.count) chords for key \(candidate.tonic) \(candidate.mode)")
        
        let scales = bridge.scoreScales(chords, key: candidate.tonic, mode: candidate.mode)
        
        print("🔍 selectKey: received \(scales.count) scale candidates")
        
        // v3.1: スケール候補を5つに制限（UI改善）
        scaleCandidates = Array(scales.prefix(5))
        selectedScaleIndex = scales.isEmpty ? nil : 0 // Auto-select first scale
        
        print("✅ Selected key: \(candidate.tonic) \(candidate.mode)")
        print("   Scale candidates (top 5): \(scaleCandidates.map { "\($0.type) (\($0.score)%)" }.joined(separator: ", "))")
        print("   selectedScaleIndex: \(selectedScaleIndex ?? -1)")
        print("   selectedScale: \(selectedScale?.type ?? "nil")")
    }
    
    
    // MARK: - Scale Preview
    
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
        let key = selectedKey
        let scale = selectedScale
        
        let sketch = Sketch(
            id: currentSketchId ?? UUID().uuidString,
            name: sketchName,
            chords: progressionStore.slots,
            key: key.map { "\($0.tonic) \($0.mode)" },
            scale: scale.map { scaleTypeToDisplayName($0.type) },
            bpm: bpm,
            fretboardDisplay: fbDisplay == .degrees ? .degrees : .names,
            sectionDefinitions: progressionStore.sectionDefinitions,
            playbackOrder: progressionStore.playbackOrder,
            useSectionMode: progressionStore.useSectionMode
        )
        
        sketchManager.save(sketch)
        currentSketchId = sketch.id
        
        // Show success toast
        toastMessage = "Sketch saved: \(sketchName)"
        toastIcon = "checkmark.circle.fill"
        toastColor = .green
        showToast = true
        
        print("✅ Sketch saved: \(sketchName)")
    }
    
    private func loadSketch(_ sketch: Sketch) {
        // Load basic progression
        progressionStore.slots = sketch.chords
        bpm = sketch.bpm
        currentSketchId = sketch.id
        cursorIndex = sketch.chords.firstIndex(where: { $0 == nil }) ?? 0
        
        // Load Fretboard display mode
        fbDisplay = sketch.fretboardDisplay == .degrees ? .degrees : .names
        
        // Load section mode (if available)
        progressionStore.useSectionMode = sketch.useSectionMode
        progressionStore.sectionDefinitions = sketch.sectionDefinitions
        progressionStore.playbackOrder = sketch.playbackOrder
        
        // If in section mode and has sections, select the first one
        if progressionStore.useSectionMode && !progressionStore.sectionDefinitions.isEmpty {
            progressionStore.currentSectionId = progressionStore.sectionDefinitions.first?.id
        }
        
        // Clear UI state
        selectedDiatonicChord = nil
        overlayChordNotes = []
        
        // Auto-analyze if there are chords
        let chordsToAnalyze = progressionStore.useSectionMode 
            ? progressionStore.combinedProgression.compactMap { $0 }
            : progressionStore.slots.compactMap { $0 }
        
        if !chordsToAnalyze.isEmpty {
            // Store saved key/scale for later restoration
            let savedKey = sketch.key
            let savedScale = sketch.scale
            
            // Analyze progression
            analyzeProgression()
            
            // Wait for analysis to complete, then restore saved selections
            Task {
                // Wait for analysis to complete (same delay as analyzeProgression)
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                
                await MainActor.run {
                    // Try to restore saved key/scale selection
                    if let savedKey = savedKey {
                        // Parse saved key (format: "F Major" or "D Minor")
                        let components = savedKey.split(separator: " ")
                        if components.count >= 2 {
                            let tonic = String(components[0])
                            let mode = String(components[1])
                            
                            // Find matching key in candidates
                            if let index = keyCandidates.firstIndex(where: { $0.tonic == tonic && $0.mode == mode }) {
                                selectedKeyIndex = index
                                
                                // Select scale if available
                                if let savedScale = savedScale, let bridge = theoryBridge {
                                    let scaleCands = bridge.scoreScales(chordsToAnalyze, key: tonic, mode: mode)
                                    scaleCandidates = Array(scaleCands.prefix(5))
                                    
                                    // Find matching scale
                                    if let scaleIndex = scaleCands.firstIndex(where: { scaleTypeToDisplayName($0.type) == savedScale }) {
                                        selectedScaleIndex = scaleIndex
                                        print("✅ Restored saved key/scale: \(tonic) \(mode) - \(savedScale)")
                                    } else if !scaleCands.isEmpty {
                                        // Fallback to first scale
                                        selectedScaleIndex = 0
                                        print("⚠️ Saved scale '\(savedScale)' not found, using first scale")
                                    }
                                }
                            } else {
                                print("⚠️ Saved key '\(tonic) \(mode)' not found in candidates")
                            }
                        }
                    }
                }
            }
        }
        
        print("✅ Sketch loaded: \(sketch.name)")
        
        // Show success toast
        toastMessage = "Loaded: \(sketch.name)"
        toastIcon = "checkmark.circle.fill"
        toastColor = .blue
        showToast = true
    }
    
    // MARK: - Playback Functions
    
    private func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        // Select slots based on playback mode
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
        guard let bass = bassService else { return }
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
                
                // Generate bass PCM buffer for each bar
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
                            
                            // Auto-switch section during full song playback
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
        
        // Try HybridPlayer first, fallback to ChordSequencer
        if hybridPlayer != nil {
            hybridPlayer?.stop()
            print("✅ HybridPlayer: stopped")
        } else {
            sequencer?.stop()
            print("✅ ChordSequencer: stopped")
        }
    }
    
    /// Auto-switch to the section that contains the given slot index
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
    // MusicSequence click track implementation
    
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
        .contextMenu {
            if let chord = chord {
                Button(action: {
                    // Navigate to chord library
                    NotificationCenter.default.post(
                        name: .navigateToChordLibrary,
                        object: chord
                    )
                }) {
                    Label("フォームを確認", systemImage: "music.note")
                }
            }
        }
    }
}

// MARK: - Section Marker

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

// MARK: - Scale Candidate Button

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
    
    private func fitColor(_ score: Int) -> Color {
        if score >= 90 { return .green }
        if score >= 70 { return .yellow }
        return .orange
    }
    
}

// MARK: - Helper Functions

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

// MARK: - Convert to Section Sheet

struct ConvertToSectionSheet: View {
    @ObservedObject var progressionStore: ProgressionStore
    let onConvert: (SectionType, String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: SectionType = .verse
    @State private var sectionName: String = ""
    
    private let sectionTypes: [SectionType] = [.intro, .verse, .preChorus, .chorus, .postChorus, .bridge, .outro]
    
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("Enable Sections")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    sectionName = selectedType.displayName
                }
                .onChange(of: selectedType) {
                    sectionName = selectedType.displayName
                }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 20) {
            typePickerSection
            nameInputSection
            Spacer()
            convertButton
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private var typePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Section Type")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Picker("Type", selection: $selectedType) {
                ForEach(sectionTypes, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Section Name")
                .font(.headline)
                .foregroundColor(.secondary)
            
            TextField("Name", text: $sectionName)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var convertButton: some View {
        Button(action: {
            onConvert(selectedType, sectionName)
            dismiss()
        }) {
            Text("Convert to Section")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(sectionName.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(sectionName.isEmpty)
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

// MARK: - Playback Mode

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
