import AVFoundation
import AudioToolbox

@MainActor
class AudioPlayer: ObservableObject {
    private var engine: AVAudioEngine
    var sampler: AVAudioUnitSampler  // ProgressionViewから直接アクセスするためpublicに変更
    private var isSetup = false
    
    @Published var currentInstrument: String = "Acoustic Guitar (Steel)"
    private var currentProgram: UInt8 = 25
    
    init() {
        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        setupAudio()
    }
    
    func changeInstrument(_ program: UInt8) {
        // Program Changeで音色切り替え（軽量）
        for ch: UInt8 in 0...1 {
            sampler.sendProgramChange(program, onChannel: ch)
            sampler.sendController(91, withValue: 0, onChannel: ch)
            sampler.sendController(93, withValue: 0, onChannel: ch)
            sampler.sendController(64, withValue: 0, onChannel: ch)
        }
        currentProgram = program
        print("✅ AudioPlayer instrument changed: program \(program)")
    }
    
    private func setupAudio() {
        // Attach sampler to engine
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        
        // Load default SoundFont
        loadInstrument(program: 25) // Acoustic Guitar (steel)
        
        // Configure sampler
        sampler.overallGain = -6.0 // -6dB（歪み防止）
        // Note: masterGain は iOS 15.0 で非推奨ですが、代替手段がないため使用を継続
        
        // Phase 1: DLSの残響を徹底的に抑制
        // リバーブ/コーラス/サスティンをゼロに（CC91/93/64=0）
        for ch in 0..<2 {
            sampler.sendController(91, withValue: 0, onChannel: UInt8(ch)) // Reverb depth = 0
            sampler.sendController(93, withValue: 0, onChannel: UInt8(ch)) // Chorus depth = 0
            sampler.sendController(64, withValue: 0, onChannel: UInt8(ch)) // Sustain pedal OFF
        }
        print("✅ Sampler configured: overallGain=-6dB, Reverb/Chorus/Sustain=0 (ch0-1)")
        
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
        // SF2をバンドルから読み込む（iOSではシステムDLSが使えない）
        // 複数のファイル名を試す
        var bankURL: URL?
        let candidates = [
            ("FluidR3_GM", "sf2"),         // FluidR3 GM（最も互換性が高い）
            ("GeneralUser GS", "sf2"),     // GeneralUser GS
            ("SGM-V2.01", "sf2"),          // SGM-V2.01
            ("soundfont", "sf2"),          // 汎用名
            ("TimGM6mb", "sf2"),           // TimGM6mb
            ("MuseScore_General", "sf2")   // MuseScore General（非圧縮版のみ）
            // 注意: SF3（圧縮版）はiOSでサポートされていない
        ]
        
        for (name, ext) in candidates {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                bankURL = url
                print("✅ Found SF2: \(name).\(ext)")
                break
            }
        }
        
        guard let bankURL = bankURL else {
            print("❌ SF2 not found in bundle")
            print("   Tried: MuseScore_General.sf3, soundfont.sf2, TimGM6mb.sf2, FluidR3_GM.sf2")
            print("   Please add a GM-compatible SoundFont to the Xcode project")
            return
        }
        
        do {
            let melodic = UInt8(kAUSampler_DefaultMelodicBankMSB)
            let lsb = UInt8(kAUSampler_DefaultBankLSB)
            
            try sampler.loadSoundBankInstrument(
                at: bankURL,
                program: program,
                bankMSB: melodic,
                bankLSB: lsb
            )
            
            // リバーブ/コーラス/サスティンは念のためゼロに
            for ch: UInt8 in 0...1 {
                sampler.sendController(91, withValue: 0, onChannel: ch) // Reverb = 0
                sampler.sendController(93, withValue: 0, onChannel: ch) // Chorus = 0
                sampler.sendController(64, withValue: 0, onChannel: ch) // Sustain = 0
            }
            
            print("✅ Instrument loaded: program \(program) from SF2")
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
    
    // Start chord notes (for manual control)
    func startChord(midiNotes: [UInt8], velocity: UInt8 = 80, strum: Bool = true) {
        guard isSetup else {
            print("❌ Audio engine not setup")
            return
        }
        
        if strum {
            // Strum: slight delay between notes
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
    }
    
    // Stop chord notes (for manual control)
    func stopChord(midiNotes: [UInt8]) {
        guard isSetup else { return }
        
        for note in midiNotes {
            sampler.stopNote(note, onChannel: 0)
        }
    }
    
    // Phase 1: チャンネル強制停止（二段構え）
    // All Notes Off → All Sound Off の順で確実にミュート
    func hardStopChannel(_ channel: UInt8) {
        guard isSetup else { return }
        
        // 1) All Notes Off（通常のNoteOff相当、リリースは鳴る）
        sampler.sendController(123, withValue: 0, onChannel: channel)
        
        // 2) All Sound Off（残響ごと即座に切る）
        sampler.sendController(120, withValue: 0, onChannel: channel)
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

