import AVFoundation

@MainActor
class AudioPlayer: ObservableObject {
    private var engine: AVAudioEngine
    private var sampler: AVAudioUnitSampler
    private var isSetup = false
    
    @Published var currentInstrument: String = "Acoustic Guitar (Steel)"
    
    init() {
        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        setupAudio()
    }
    
    private func setupAudio() {
        // Attach sampler to engine
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        
        // Load default SoundFont
        loadInstrument(program: 25) // Acoustic Guitar (steel)
        
        // Start engine
        do {
            try engine.start()
            isSetup = true
            print("✅ Audio Engine started successfully")
        } catch {
            print("❌ Failed to start audio engine: \(error)")
        }
    }
    
    private func loadInstrument(program: UInt8) {
        // Load General MIDI instrument from system SoundFont
        let soundFontURL = URL(fileURLWithPath: "/System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls")
        
        do {
            try sampler.loadSoundBankInstrument(
                at: soundFontURL,
                program: program,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
            print("✅ Instrument loaded: program \(program)")
        } catch {
            print("❌ Failed to load instrument: \(error)")
        }
    }
    
    // Play single note
    func playNote(midiNote: UInt8, velocity: UInt8 = 100, duration: Double = 1.0) {
        guard isSetup else {
            print("❌ Audio engine not setup")
            return
        }
        
        // Note On
        sampler.startNote(midiNote, withVelocity: velocity, onChannel: 0)
        
        // Note Off (after duration)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            self.sampler.stopNote(midiNote, onChannel: 0)
        }
    }
    
    // Play chord (simultaneous notes)
    func playChord(midiNotes: [UInt8], velocity: UInt8 = 100, duration: Double = 2.0, strum: Bool = false) {
        guard isSetup else {
            print("❌ Audio engine not setup")
            return
        }
        
        if strum {
            // Strum: slight delay between notes (10-20ms)
            for (index, note) in midiNotes.enumerated() {
                let delay = Double(index) * 0.02 // 20ms per note
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    self.sampler.startNote(note, withVelocity: velocity, onChannel: 0)
                }
            }
        } else {
            // Simultaneous: all notes at once
            for note in midiNotes {
                sampler.startNote(note, withVelocity: velocity, onChannel: 0)
            }
        }
        
        // Note Off for all notes (after duration)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            for note in midiNotes {
                self.sampler.stopNote(note, onChannel: 0)
            }
        }
    }
    
    // Convert note name to MIDI number (C4 = 60)
    func noteNameToMIDI(_ noteName: String, octave: Int = 4) -> UInt8? {
        let noteMap: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1,
            "D": 2, "D#": 3, "Eb": 3,
            "E": 4,
            "F": 5, "F#": 6, "Gb": 6,
            "G": 7, "G#": 8, "Ab": 8,
            "A": 9, "A#": 10, "Bb": 10,
            "B": 11
        ]
        
        guard let offset = noteMap[noteName] else { return nil }
        let midiNote = (octave + 1) * 12 + offset
        return UInt8(midiNote)
    }
    
    // Change instrument
    func changeInstrument(program: UInt8, name: String) {
        loadInstrument(program: program)
        currentInstrument = name
    }
}

// Instrument presets
extension AudioPlayer {
    enum Instrument {
        case acousticGuitarSteel
        case acousticGuitarNylon
        case electricGuitarClean
        case distortionGuitar
        case acousticGrandPiano
        case electricBass
        
        var program: UInt8 {
            switch self {
            case .acousticGuitarSteel: return 25
            case .acousticGuitarNylon: return 24
            case .electricGuitarClean: return 27
            case .distortionGuitar: return 30
            case .acousticGrandPiano: return 0
            case .electricBass: return 33
            }
        }
        
        var name: String {
            switch self {
            case .acousticGuitarSteel: return "Acoustic Guitar (Steel)"
            case .acousticGuitarNylon: return "Acoustic Guitar (Nylon)"
            case .electricGuitarClean: return "Electric Guitar (Clean)"
            case .distortionGuitar: return "Distortion Guitar"
            case .acousticGrandPiano: return "Piano"
            case .electricBass: return "Bass"
            }
        }
    }
}

