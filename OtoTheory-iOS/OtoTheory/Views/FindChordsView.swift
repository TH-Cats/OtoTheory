import SwiftUI
import AVFoundation

struct FindChordsView: View {
    @State private var selectedKey = "C"
    @State private var selectedScale = "major"
    @State private var displayMode: FretboardOverlay.DisplayMode = .degrees
    @State private var isLandscape: Bool = false
    @State private var showFretboardMode: Bool = false
    @State private var selectedChord: String? = nil
    @State private var selectedChordDegree: Int? = nil  // 1-based degree (I=1, ii=2, etc.)
    @State private var previewScaleId: String? = nil  // For scale preview
    @StateObject private var orientationManager = OrientationManager.shared
    
    // Phase E-4A: Chord addition to progression
    @StateObject private var progressionStore = ProgressionStore.shared
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon: String? = "checkmark.circle.fill"
    @State private var toastColor: Color = .green
    
    // Audio engine for note playback
    private let audioEngine = AVAudioEngine()
    private let sampler = AVAudioUnitSampler()
    @State private var scalePreviewPlayer: ScalePreviewPlayer? = nil
    
    // Keys with enharmonic equivalents (matching Web version)
    private let keysRow1 = ["C", "C#", "D", "Eb", "E"]
    private let keysRow2 = ["F", "F#", "G", "Ab", "A", "Bb", "B"]
    
    private var allKeys: [String] {
        keysRow1 + keysRow2
    }
    
    // Expanded scale list to match Web version
    private let scales = [
        "major", "dorian", "phrygian", "lydian", "mixolydian", "minor", "locrian",
        "majorPentatonic", "minorPentatonic", "blues", 
        "harmonicMinor", "melodicMinor",
        "diminishedWH", "diminishedHW"
    ]
    
    private let scaleDisplayNames: [String: String] = [
        "major": "Major Scale",
        "dorian": "Dorian Scale",
        "phrygian": "Phrygian Scale",
        "lydian": "Lydian Scale",
        "mixolydian": "Mixolydian Scale",
        "minor": "Natural Minor Scale",
        "locrian": "Locrian Scale",
        "majorPentatonic": "Major Pentatonic",
        "minorPentatonic": "Minor Pentatonic",
        "blues": "Blues Scale (minor)",
        "harmonicMinor": "Harmonic Minor",
        "melodicMinor": "Melodic Minor Scale",
        "diminishedWH": "Diminished Scale (Whole-Half)",
        "diminishedHW": "Diminished Scale (Half-Whole)"
    ]
    
    private let keyToPitchClass: [String: Int] = [
        "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4,
        "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11
    ]
    
    private let scaleTypeMap: [String: String] = [
        "major": "Ionian",
        "minor": "Aeolian",
        "dorian": "Dorian",
        "phrygian": "Phrygian",
        "lydian": "Lydian",
        "mixolydian": "Mixolydian",
        "locrian": "Locrian",
        "majorPentatonic": "MajorPentatonic",
        "minorPentatonic": "MinorPentatonic",
        "blues": "Blues",
        "harmonicMinor": "HarmonicMinor",
        "melodicMinor": "MelodicMinor",
        "diminishedWH": "DiminishedWH",
        "diminishedHW": "DiminishedHW"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let _ = updateOrientation(geometry.size)
            
            if showFretboardMode {
                // Fretboard Mode (landscape fullscreen)
                fretboardModeView
            } else {
                // Normal Mode
                normalView
            }
        }
        .onAppear {
            setupAudio()
        }
        .toast(
            isShowing: $showToast,
            message: toastMessage,
            icon: toastIcon,
            backgroundColor: toastColor
        )
    }
    
    // MARK: - Subviews
    
    private var normalView: some View {
        ScrollView {
            VStack(spacing: 20) {
                    // Select Key & Scale (Web-style section)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Key & Scale")
                            .font(.title2)
                            .bold()
                        
                        // Key Selection (2 rows, Web-style)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key")
                                .font(.headline)
                            
                            // Row 1: C, C#, D, Eb, E
                            HStack(spacing: 8) {
                                ForEach(keysRow1, id: \.self) { key in
                                    Button {
                                        selectedKey = key
                                    } label: {
                                        Text(key)
                                            .font(.system(size: 16, weight: selectedKey == key ? .bold : .regular))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(selectedKey == key ? Color.blue : Color(.systemGray5))
                                            .foregroundColor(selectedKey == key ? .white : .primary)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            // Row 2: F, F#, G, Ab, A, Bb, B
                            HStack(spacing: 8) {
                                ForEach(keysRow2, id: \.self) { key in
                                    Button {
                                        selectedKey = key
                                    } label: {
                                        Text(key)
                                            .font(.system(size: 16, weight: selectedKey == key ? .bold : .regular))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(selectedKey == key ? Color.blue : Color(.systemGray5))
                                            .foregroundColor(selectedKey == key ? .white : .primary)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        // Scale Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Scale")
                                .font(.headline)
                            
                            Picker("Scale", selection: $selectedScale) {
                                ForEach(scales, id: \.self) { scale in
                                    Text(scaleDisplayNames[scale] ?? scale).tag(scale)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Diatonic Table (before Fretboard, Web-style)
                    DiatonicTableView(
                        key: selectedKey,
                        scale: scaleTypeMap[selectedScale] ?? "Ionian",
                        selectedChord: $selectedChord,
                        onChordTap: { chord, degree in
                            selectedChordDegree = degree
                            playChord(chord)
                        },
                        onChordLongPress: { chord in
                            addChordToProgression(chord)
                        }
                    )
                    
                    // Suggested scales for selected chord
                    if let currentChord = selectedChord,
                       let quality = ChordQuality.from(chordName: currentChord),
                       let scalePlayer = scalePreviewPlayer {
                        ScaleSuggestionsView(
                            chordQuality: quality,
                            selectedKey: selectedKey,
                            previewScaleId: $previewScaleId,
                            scalePreviewPlayer: scalePlayer,
                            onResetPreview: {
                                previewScaleId = nil
                                self.selectedChord = nil
                                selectedChordDegree = nil
                            }
                        )
                    }
                    
                    // Substitute Chords for selected chord
                    if let selectedChord = selectedChord,
                       let selectedChordDegree = selectedChordDegree,
                       let quality = ChordQuality.from(chordName: selectedChord) {
                        SubstituteChordsView(
                            context: ChordContext(
                                rootPc: keyToPitchClass[selectedKey] ?? 0,
                                quality: quality,
                                degree: selectedChordDegree,
                                keyTonic: keyToPitchClass[selectedKey] ?? 0,
                                keyMode: selectedScale.contains("minor") || selectedScale == "minor" ? .minor : .major
                            ),
                            onPlay: { substituteChord in
                                playChord(substituteChord)
                            },
                            onLongPress: { substituteChord in
                                addChordToProgression(substituteChord)
                            }
                        )
                    }
                    
                    // Fretboard Visualization (with toggle buttons)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Fretboard")
                                .font(.headline)
                            
                            Spacer()
                            
                            // Display Mode Toggle (compact)
                            HStack(spacing: 6) {
                                Button {
                                    displayMode = .degrees
                                } label: {
                                    Text("°")
                                        .font(.system(size: 16, weight: displayMode == .degrees ? .bold : .regular))
                                        .frame(minWidth: 32)
                                        .padding(.vertical, 8)
                                        .background(displayMode == .degrees ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(displayMode == .degrees ? .white : .primary)
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    displayMode = .names
                                } label: {
                                    Text("♪")
                                        .font(.system(size: 16, weight: displayMode == .names ? .bold : .regular))
                                        .frame(minWidth: 32)
                                        .padding(.vertical, 8)
                                        .background(displayMode == .names ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(displayMode == .names ? .white : .primary)
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                                
                                // Reset button (show when chord is selected)
                                if selectedChord != nil {
                                    Button {
                                        selectedChord = nil
                                        selectedChordDegree = nil
                                        previewScaleId = nil
                                    } label: {
                                        Text("Reset")
                                            .font(.system(size: 14, weight: .medium))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .background(Color.red.opacity(0.1))
                                            .foregroundColor(.red)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            // Fullscreen button with landscape hint
                            Button {
                                showFretboardMode = true
                                // Force landscape orientation for better fretboard viewing
                                orientationManager.lockToLandscape()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "rotate.right")
                                        .font(.system(size: 11, weight: .semibold))
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        
                        FretboardView(
                            overlay: currentOverlay,
                            onTapNote: { midiNote in
                                playNote(midiNote)
                            }
                        )
                        .frame(height: 350)  // Fixed height for scrollable container
                    }
                    
                    // Coming Soon
                    VStack(spacing: 12) {
                        Text("Coming Soon:")
                            .font(.headline)
                        Text("• Scale table (Why + Glossary)")
                        Text("• Chord forms (Open/Barre)")
                        Text("• Basic substitutes")
                    }
                    .foregroundColor(.secondary)
                    .padding()
                    
                Spacer()
            }
            .padding()
        }
    }
    
    private var fretboardModeView: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Bar (Key/Scale info + Chord info + Exit button)
                    VStack(spacing: 8) {
                        HStack {
                            // Key/Scale info
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(selectedKey) \(scaleDisplayNames[selectedScale] ?? selectedScale)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                // Chord name (if selected)
                                if let chord = selectedChord {
                                    HStack(spacing: 4) {
                                        Image(systemName: "music.note")
                                            .font(.system(size: 10))
                                            .foregroundColor(.blue)
                                        Text("Chord: \(chord)")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                // Preview scale info (if selected)
                                if let previewScale = previewScaleId {
                                    HStack(spacing: 4) {
                                        Image(systemName: "waveform")
                                            .font(.system(size: 10))
                                            .foregroundColor(.green)
                                        Text("Scale for this chord: \(getScaleLabel(previewScale))")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Display Mode Toggle (compact)
                            HStack(spacing: 4) {
                                Button {
                                    displayMode = .degrees
                                } label: {
                                    Text("°")
                                        .font(.system(size: 12, weight: displayMode == .degrees ? .bold : .regular))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(displayMode == .degrees ? Color.blue : Color.gray.opacity(0.3))
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    displayMode = .names
                                } label: {
                                    Text("♪")
                                        .font(.system(size: 12, weight: displayMode == .names ? .bold : .regular))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(displayMode == .names ? Color.blue : Color.gray.opacity(0.3))
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Reset button (show when chord or preview scale is selected)
                            if selectedChord != nil || previewScaleId != nil {
                                Button {
                                    // Reset logic: clear preview scale first, then chord
                                    if previewScaleId != nil {
                                        previewScaleId = nil
                                    } else if selectedChord != nil {
                                        selectedChord = nil
                                        selectedChordDegree = nil
                                    }
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
                            
                            // Exit button (more prominent)
                            Button {
                                showFretboardMode = false
                                // Unlock orientation when exiting fullscreen
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
                        overlay: currentOverlay,
                        onTapNote: { midiNote in
                            playNote(midiNote)
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .ignoresSafeArea(.all)
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - Helper Functions
    
    private func updateOrientation(_ size: CGSize) {
        isLandscape = size.width > size.height
    }
    
    /// Add chord to progression with haptic feedback and toast
    private func addChordToProgression(_ chord: String) {
        // Non-blocking async execution to prevent UI freeze
        Task { @MainActor in
            let success: Bool
            
            // Phase E-5: Section-aware chord addition
            if progressionStore.useSectionMode {
                success = progressionStore.addChordToSection(chord)
            } else {
                success = progressionStore.addChord(chord)
            }
            
            if success {
                // Success feedback
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.success)
                
                // Show success toast with slot info
                let slotIndex = (progressionStore.activeSlots.firstIndex(of: chord) ?? 0) + 1
                let sectionInfo = progressionStore.useSectionMode && progressionStore.currentSection != nil
                    ? " (\(progressionStore.currentSection!.name))"
                    : ""
                toastMessage = "Added \(chord) → Slot \(slotIndex)\(sectionInfo)"
                toastIcon = "arrow.right.circle.fill"
                toastColor = .green
                showToast = true
                
                // Visual cue: briefly highlight the added chord
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    // Animation trigger
                }
            } else {
                // Full feedback
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.warning)
                
                // Show warning toast
                let sectionInfo = progressionStore.useSectionMode && progressionStore.currentSection != nil
                    ? " in \(progressionStore.currentSection!.name)"
                    : ""
                toastMessage = "Section is full (12/12)\(sectionInfo)"
                toastIcon = "exclamationmark.triangle.fill"
                toastColor = .orange
                showToast = true
            }
        }
    }
    
    /// Get user-friendly label for scale ID
    private func getScaleLabel(_ scaleId: String) -> String {
        switch scaleId {
        case "Ionian":
            return "Major Scale"
        case "Lydian":
            return "Lydian (#4 Color)"
        case "Aeolian":
            return "Natural Minor"
        case "Dorian":
            return "Dorian (Bright Minor)"
        case "Phrygian":
            return "Phrygian (Dark Minor)"
        case "Mixolydian":
            return "Mixolydian (Dominant)"
        case "Locrian":
            return "Locrian (Half-Dim)"
        case "DiminishedWholeHalf":
            return "Whole–Half Dim"
        case "HarmonicMinor":
            return "Harmonic Minor"
        case "MelodicMinor":
            return "Melodic Minor"
        default:
            return scaleId
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentOverlay: FretboardOverlay {
        let rootPc = keyToPitchClass[selectedKey] ?? 0
        
        // Use preview scale if selected, otherwise use current scale
        let scaleType: String
        if let previewScaleId = previewScaleId {
            scaleType = previewScaleId
        } else {
            scaleType = scaleTypeMap[selectedScale] ?? "Ionian"
        }
        
        if let chord = selectedChord {
            // Show both scale and chord
            return FretboardOverlay.scaleAndChord(
                rootPc: rootPc,
                scaleType: scaleType,
                chordNotes: parseChordNotes(chord),
                display: displayMode
            )
        } else {
            // Show only scale
            return FretboardOverlay.scaleOnly(
                rootPc: rootPc,
                scaleType: scaleType,
                display: displayMode
            )
        }
    }
    
    /// Parse chord name to extract note names (e.g., "Cm" -> ["C", "Eb", "G"])
    private func parseChordNotes(_ chordName: String) -> [String] {
        // Extract root note
        let root = String(chordName.prefix(while: { $0.isUppercase || $0 == "#" || $0 == "b" }))
        
        // Determine quality
        let suffix = chordName.dropFirst(root.count)
        let isMinor = suffix.contains("m") && !suffix.contains("dim")
        let isDiminished = suffix.contains("dim")
        
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        guard let rootIndex = notes.firstIndex(of: root) else { return [] }
        
        // Build triad
        if isDiminished {
            // Diminished: Root + m3 + dim5
            let third = notes[(rootIndex + 3) % 12]
            let fifth = notes[(rootIndex + 6) % 12]
            return [root, third, fifth]
        } else if isMinor {
            // Minor: Root + m3 + P5
            let third = notes[(rootIndex + 3) % 12]
            let fifth = notes[(rootIndex + 7) % 12]
            return [root, third, fifth]
        } else {
            // Major: Root + M3 + P5
            let third = notes[(rootIndex + 4) % 12]
            let fifth = notes[(rootIndex + 7) % 12]
            return [root, third, fifth]
        }
    }
    
    // MARK: - Audio Functions
    
    private func setupAudio() {
        do {
            audioEngine.attach(sampler)
            audioEngine.connect(sampler, to: audioEngine.mainMixerNode, format: nil)
            
            // Load default sound font
            if let soundFontURL = Bundle.main.url(forResource: "GeneralUser GS MuseScore v1.442", withExtension: "sf2") {
                try sampler.loadSoundBankInstrument(
                    at: soundFontURL,
                    program: 0,  // Acoustic Grand Piano
                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                    bankLSB: UInt8(kAUSampler_DefaultBankLSB)
                )
            }
            
            try audioEngine.start()
            
            // Initialize ScalePreviewPlayer for scale suggestions (only once)
            if scalePreviewPlayer == nil {
                if let fluidURL = Bundle.main.url(forResource: "FluidR3_GM", withExtension: "sf2") {
                    let player = try ScalePreviewPlayer(sf2URL: fluidURL)
                    scalePreviewPlayer = player
                    print("✅ ScalePreviewPlayer initialized in FindChordsView")
                }
            }
        } catch {
            print("❌ Audio setup error: \(error)")
        }
    }
    
    private func playNote(_ midiNote: Int) {
        sampler.startNote(UInt8(midiNote), withVelocity: 80, onChannel: 0)
        
        // Stop note after 240ms
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            sampler.stopNote(UInt8(midiNote), onChannel: 0)
        }
    }
    
    /// Play chord as an arpeggio or simultaneos notes
    private func playChord(_ chordName: String) {
        let chordNotes = parseChordNotes(chordName)
        
        // Convert note names to MIDI notes (middle octave: C4 = 60)
        let midiNotes = chordNotes.compactMap { noteName -> UInt8? in
            let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
            guard let index = notes.firstIndex(of: noteName) else { return nil }
            return UInt8(60 + index)  // C4 = 60
        }
        
        // Play all notes simultaneously
        for midiNote in midiNotes {
            sampler.startNote(midiNote, withVelocity: 70, onChannel: 0)
        }
        
        // Stop all notes after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            for midiNote in midiNotes {
                sampler.stopNote(midiNote, onChannel: 0)
            }
        }
    }
}

#Preview {
    FindChordsView()
}

