import SwiftUI
import AVFoundation

struct ProgressionView: View {
    @State private var slots: [String?] = Array(repeating: nil, count: 12)
    @State private var cursorIndex = 0
    @State private var selectedChords: Set<Int> = []
    
    // Phase A: Hybrid Audio Architecture
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var sketchManager = SketchManager()
    @State private var sequencer: ChordSequencer?  // 旧実装（Phase Bで削除予定）
    @State private var hybridPlayer: HybridPlayer?
    @State private var bounceService: GuitarBounceService?
    
    // Chord builder state
    @State private var selectedRoot: String = "C"
    @State private var selectedQuick: String = ""
    
    // Playback state
    @State private var isPlaying = false
    @State private var bpm: Double = 120
    @State private var currentSlotIndex: Int? = nil
    @State private var selectedInstrument: Int = 0 // 0=Steel, 1=Nylon, 2=Clean, 3=Dist, 4=OverDrive, 5=Muted, 6=Piano
    
    private let instruments = [
        ("Acoustic Steel", 25),
        ("Acoustic Nylon ⚠️", 24),  // ⚠️ 2拍目・3拍目にドラム音が混入
        ("Electric Clean", 27),
        // ⚠️ 一時的に除外（ワウペダル効果の問題）
        // ("Distortion", 30),
        // ("Over Drive", 29),
        ("Electric Muted", 28),
        ("Piano", 0)
    ]
    
    // Preset state
    @State private var showPresetPicker = false
    @State private var selectedPresetKey: String = "C"
    
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
    private let quicks = ["", "m", "7", "maj7", "m7", "dim", "sus4"] // aug はProのみ
    
    private var previewChord: String {
        selectedRoot + selectedQuick
    }
    
    private var hasEnoughChords: Bool {
        slots.compactMap({ $0 }).count >= 3
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
                    _bounceService = State(initialValue: bounce)
                    
                    // ChordSequencer はクリック専用（フォールバック）
                    let seq = try ChordSequencer(sf2URL: url)
                    _sequencer = State(initialValue: seq)
                    
                    print("✅ HybridPlayer initialized with \(name).\(ext)")
                    print("✅ GuitarBounceService initialized")
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
        ScrollView {
            VStack(spacing: 24) {
                // Build Progression Section
                VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Build Progression")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            // Preset Button
                            Button(action: { showPresetPicker = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "music.note.list")
                                    Text("Preset")
                                }
                                .font(.subheadline)
                            }
                            .buttonStyle(.bordered)
                            
                            // Reset Button
                            Button(action: resetProgression) {
                                Text("Reset")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.bordered)
                            
                            // Sketches Button
                            Button(action: { showSketchList = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "folder")
                                    Text("Sketches")
                                }
                                .font(.subheadline)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $showPresetPicker) {
                            PresetPickerView(
                                selectedKey: $selectedPresetKey,
                                onSelect: { preset in
                                    applyPreset(preset)
                                    showPresetPicker = false
                                }
                            )
                        }
                        .sheet(isPresented: $showSketchList) {
                            SketchListView(
                                sketchManager: sketchManager,
                                onLoad: { sketch in
                                    loadSketch(sketch)
                                }
                            )
                        }
                        .alert("Save Sketch", isPresented: $showSaveDialog) {
                            TextField("Sketch name", text: $sketchName)
                            Button("Cancel", role: .cancel) {}
                            Button("Save") {
                                saveCurrentSketch()
                            }
                        }
                        
                            // Playback Controls
                            VStack(spacing: 12) {
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
                        
                        // 12 Slots Grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                            ForEach(0..<12) { index in
                                SlotView(
                                    index: index,
                                    chord: slots[index],
                                    isCursor: index == cursorIndex,
                                    isPlaying: currentSlotIndex == index,
                                    onTap: { handleSlotTap(index) },
                                    onDelete: slots[index] != nil ? { deleteChord(at: index) } : nil
                                )
                            }
                    }
                    .padding(.horizontal)
                }
                
                // Choose Chords Section - Web版のRoot + Quick方式
                VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Chords")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            // Root Selection
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Root")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(roots, id: \.self) { root in
                                            Button(action: {
                                                selectedRoot = root
                                            }) {
                                                Text(root)
                                                    .font(.body)
                                                    .fontWeight(.semibold)
                                                    .frame(minWidth: 50)
                                                    .padding(.vertical, 12)
                                                    .background(selectedRoot == root ? Color.blue : Color.gray.opacity(0.2))
                                                    .foregroundColor(selectedRoot == root ? .white : .primary)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Quick Selection (簡単なコード、Pro版で9th/6th等複雑なコードを追加予定)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Quick")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(quicks, id: \.self) { quick in
                                            Button(action: {
                                                selectedQuick = quick
                                            }) {
                                                Text(quick.isEmpty ? "Major" : quick)
                                                    .font(.body)
                                                    .fontWeight(.semibold)
                                                    .frame(minWidth: 60)
                                                    .padding(.vertical, 12)
                                                    .background(selectedQuick == quick ? Color.blue : Color.gray.opacity(0.2))
                                                    .foregroundColor(selectedQuick == quick ? .white : .primary)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Preview & Add - Web版のPreview+Addボタン（常に表示）
                            HStack(spacing: 12) {
                                    // Preview Chip
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            let midiNotes = chordToMidi(previewChord)
                                            audioPlayer.playChord(midiNotes: midiNotes, duration: 1.5, strum: true)
                                        }) {
                                            HStack {
                                                Image(systemName: "play.circle.fill")
                                                    .font(.system(size: 20))
                                                Text(previewChord)
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(8)
                                        }
                                    }
                                    
                                    // Add Button
                                    Button(action: {
                                        addChordToProgression(previewChord)
                                    }) {
                                        Text("Add")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(width: 80)
                                            .padding(.vertical, 16)
                                            .background(Color.green)
                                            .cornerRadius(8)
                                    }
                            }
                            .padding(.horizontal)
                    }
                }
                
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
                        
                                VStack(spacing: 8) {
                                    ForEach(Array(scaleCandidates.enumerated()), id: \.offset) { index, candidate in
                                        Button(action: {
                                            selectedScaleIndex = index
                                        }) {
                                            HStack {
                                                // Scale name
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(scaleTypeToDisplayName(candidate.type))
                                                        .font(.body)
                                                        .fontWeight(selectedScaleIndex == index ? .bold : .semibold)
                                                        .foregroundColor(.primary)
                                                }
                                                
                                                Spacer()
                                                
                                                // Fit percentage (compact)
                                                Text("\(candidate.score)%")
                                                    .font(.body)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(fitColor(candidate.score))
                                                
                                                // Selection indicator
                                                if selectedScaleIndex == index {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.blue)
                                                        .font(.system(size: 20))
                                                }
                                            }
                                            .padding()
                                            .background(selectedScaleIndex == index ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                                            .cornerRadius(8)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Save Button (after key & scale selection)
                                if selectedScale != nil {
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
                    }
                }
                
                // Tools Section (Coming Soon - after analysis)
                if isAnalyzed {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tools")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Coming Soon:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("• Diatonic chords")
                            Text("• Fretboard visualization")
                            Text("• Roman numerals")
                            Text("• Patterns & Cadence")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
                
                // Coming Soon
                VStack(spacing: 8) {
                        Text("Coming Soon:")
                            .font(.headline)
                        Text("• Drag & Drop reordering")
                        Text("• Instrument selection")
                }
                .foregroundColor(.secondary)
                .font(.caption)
                .padding()
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
    
    private func handleSlotTap(_ index: Int) {
        if let chord = slots[index] {
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
        // Add chord at cursor position
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
    
    private func resetProgression() {
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
    
    private func deleteChord(at index: Int) {
        slots[index] = nil
        cursorIndex = index
    }
    
    private func applyPreset(_ preset: Preset) {
        // Convert Roman numerals to chord symbols
        let chords = RomanConverter.toChordSymbols(preset.romanNumerals, key: selectedPresetKey)
        
        // Insert from cursor position
        var insertIndex = cursorIndex
        for chord in chords {
            if insertIndex < 12 {
                slots[insertIndex] = chord
                insertIndex += 1
            } else {
                // Wrap around to beginning if we run out of slots
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
    
    // MARK: - Analysis Functions
    
    private func analyzeProgression() {
        let chords = slots.compactMap { $0 }
        
        guard chords.count >= 3 else {
            print("⚠️ Not enough chords to analyze")
            return
        }
        
        guard let bridge = theoryBridge else {
            print("❌ TheoryBridge not initialized")
            return
        }
        
        // Show analyzing state
        isAnalyzing = true
        
        // Simulate analysis delay (2 seconds)
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                // Analyze using JavaScriptCore
                let candidates = bridge.analyzeProgression(chords)
                
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
        
        let chords = slots.compactMap { $0 }
        let scales = bridge.scoreScales(chords, key: candidate.tonic, mode: candidate.mode)
        
        scaleCandidates = scales
        selectedScaleIndex = scales.isEmpty ? nil : 0 // Auto-select first scale
        
        print("✅ Selected key: \(candidate.tonic) \(candidate.mode)")
        print("   Scale candidates: \(scales.map { "\($0.type) (\($0.score)%)" }.joined(separator: ", "))")
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
        let chords = slots.compactMap { $0 }
        guard !chords.isEmpty else { return }
        
        // ✅ HybridPlayer を常用
        guard let hybrid = hybridPlayer, let bounce = bounceService else {
            print("❌ HybridPlayer or BounceService not available")
            assertionFailure("HybridPlayer must be initialized")
            return
        }
        
        audioTrace("Playback started (HybridPlayer)")
        playWithHybridPlayer(chords: chords, player: hybrid, bounce: bounce)
    }
    
    private func playWithHybridPlayer(chords: [String], player: HybridPlayer, bounce: GuitarBounceService) {
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
                
                // 準備（先にSF2をロード）
                print("🔧 HybridPlayer: preparing with SF2...")
                try player.prepare(sf2URL: sf2URL, drumKitURL: nil)
                print("✅ HybridPlayer: SF2 loaded")
                
                // 各小節のPCMバッファ生成
                var guitarBuffers: [AVAudioPCMBuffer] = []
                for bar in score.bars {
                    let key = GuitarBounceService.CacheKey(
                        chord: bar.chord,
                        program: UInt8(instruments[selectedInstrument].1),
                        bpm: bpm
                    )
                    print("🔧 Bouncing: \(bar.chord)...")
                    // ✅ strumMs を 0.0 に設定（完全同時発音）
                    // ✅ releaseMs を 80 に設定（自然な余韻）
                    let buffer = try bounce.buffer(for: key, sf2URL: sf2URL, strumMs: 0.0, releaseMs: 80.0)
                    guitarBuffers.append(buffer)
                }
                
                print("✅ All buffers generated: \(guitarBuffers.count) bars")
                
                // 再生
                try player.play(
                    score: score,
                    guitarBuffers: guitarBuffers,
                    onBarChange: { bar in
                        DispatchQueue.main.async {
                            self.currentSlotIndex = bar
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
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    
    // 色の計算を分割
    private var fillColor: Color {
        if isPlaying {
            return Color.orange.opacity(0.3)
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
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProgressionView()
}

