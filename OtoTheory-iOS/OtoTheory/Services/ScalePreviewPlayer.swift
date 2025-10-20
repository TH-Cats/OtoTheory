import AVFoundation
import Combine

/// スケール音をプレビュー再生するサービス
/// 選択されたスケールの音階を「たららららら」と再生
class ScalePreviewPlayer: ObservableObject {
    private let engine: AVAudioEngine
    private let sampler: AVAudioUnitSampler
    private let mixer: AVAudioMixerNode
    
    private var isPlaying = false
    private var playbackTask: Task<Void, Never>?
    
    /// 再生中のスケールタイプ（UIで識別するため）
    @Published var currentPlayingScale: String? = nil
    /// 再生進捗（0.0〜1.0）
    @Published var progress: Double = 0.0
    
    init(sf2URL: URL) throws {
        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        mixer = engine.mainMixerNode
        
        // Attach sampler
        engine.attach(sampler)
        engine.connect(sampler, to: mixer, format: nil)
        
        // Load SF2
        try sampler.loadSoundBankInstrument(
            at: sf2URL,
            program: 0,  // Piano for scale preview
            bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
            bankLSB: UInt8(kAUSampler_DefaultBankLSB)
        )
        
        // Start engine
        try engine.start()
        
        print("✅ ScalePreviewPlayer initialized")
    }
    
    deinit {
        stop()
        engine.stop()
    }
    
    /// スケールをプレビュー再生
    /// - Parameters:
    ///   - root: ルート音（0=C, 1=C#, ..., 11=B）
    ///   - scaleType: スケールタイプ（"Ionian", "Dorian", etc.）
    ///   - octave: オクターブ（デフォルト4）
    func playScale(root: Int, scaleType: String, octave: Int = 4) {
        // 既存の再生を停止
        stop()
        
        // スケール度数を取得
        guard let degrees = getScaleDegrees(scaleType) else {
            print("⚠️ Unknown scale type: \(scaleType)")
            return
        }
        
        isPlaying = true
        
        // 再生状態を公開
        DispatchQueue.main.async {
            self.currentPlayingScale = scaleType
            self.progress = 0.0
        }
        
        // 非同期で音階を再生
        playbackTask = Task {
            await playScaleSequence(root: root, degrees: degrees, octave: octave, scaleType: scaleType)
        }
    }
    
    /// 再生を停止
    func stop() {
        isPlaying = false
        playbackTask?.cancel()
        playbackTask = nil
        
        // 状態をリセット
        DispatchQueue.main.async {
            self.currentPlayingScale = nil
            self.progress = 0.0
        }
        
        // All notes off
        for note in 0..<128 {
            sampler.stopNote(UInt8(note), onChannel: 0)
        }
    }
    
    // MARK: - Private Methods
    
    private func playScaleSequence(root: Int, degrees: [Int], octave: Int, scaleType: String) async {
        let baseMIDI = octave * 12 + root
        let noteDuration: UInt64 = 200_000_000  // 200ms per note
        
        // 合計ノート数（上昇 + 下降）
        let totalNotes = degrees.count + (degrees.count - 1)  // 下降時はRootを除く
        var currentNote = 0
        
        // 上昇（Root → 最高音）
        for degree in degrees {
            guard isPlaying else { 
                DispatchQueue.main.async {
                    self.currentPlayingScale = nil
                    self.progress = 0.0
                }
                return
            }
            
            let midiNote = UInt8(baseMIDI + degree)
            sampler.startNote(midiNote, withVelocity: 80, onChannel: 0)
            
            // 進捗を更新
            currentNote += 1
            let newProgress = Double(currentNote) / Double(totalNotes)
            DispatchQueue.main.async {
                self.progress = newProgress
            }
            
            try? await Task.sleep(nanoseconds: noteDuration)
            
            sampler.stopNote(midiNote, onChannel: 0)
        }
        
        // 下降（最高音 → Root）
        for degree in degrees.reversed().dropFirst() {  // Root を2回弾かないため dropFirst()
            guard isPlaying else {
                DispatchQueue.main.async {
                    self.currentPlayingScale = nil
                    self.progress = 0.0
                }
                return
            }
            
            let midiNote = UInt8(baseMIDI + degree)
            sampler.startNote(midiNote, withVelocity: 80, onChannel: 0)
            
            // 進捗を更新
            currentNote += 1
            let newProgress = Double(currentNote) / Double(totalNotes)
            DispatchQueue.main.async {
                self.progress = newProgress
            }
            
            try? await Task.sleep(nanoseconds: noteDuration)
            
            sampler.stopNote(midiNote, onChannel: 0)
        }
        
        // 再生完了
        isPlaying = false
        DispatchQueue.main.async {
            self.currentPlayingScale = nil
            self.progress = 0.0
        }
    }
    
    /// スケールタイプから度数配列を取得
    /// - Parameter scaleType: スケールタイプ
    /// - Returns: 半音単位の度数配列（例: [0, 2, 4, 5, 7, 9, 11] for Major）
    private func getScaleDegrees(_ scaleType: String) -> [Int]? {
        switch scaleType {
        // Diatonic Modes
        case "Ionian":
            return [0, 2, 4, 5, 7, 9, 11]  // Major Scale
        case "Dorian":
            return [0, 2, 3, 5, 7, 9, 10]
        case "Phrygian":
            return [0, 1, 3, 5, 7, 8, 10]
        case "Lydian":
            return [0, 2, 4, 6, 7, 9, 11]
        case "Mixolydian":
            return [0, 2, 4, 5, 7, 9, 10]
        case "Aeolian":
            return [0, 2, 3, 5, 7, 8, 10]  // Natural Minor
        case "Locrian":
            return [0, 1, 3, 5, 6, 8, 10]
        
        // Minor Variations
        case "HarmonicMinor":
            return [0, 2, 3, 5, 7, 8, 11]
        case "MelodicMinor":
            return [0, 2, 3, 5, 7, 9, 11]
        
        // Pentatonic
        case "MajorPentatonic":
            return [0, 2, 4, 7, 9]
        case "MinorPentatonic":
            return [0, 3, 5, 7, 10]
        
        // Blues
        case "Blues":
            return [0, 3, 5, 6, 7, 10]
        
        // Diminished (Symmetrical)
        case "DiminishedWH":
            return [0, 2, 3, 5, 6, 8, 9, 11]  // Whole-Half Diminished
        case "DiminishedHW":
            return [0, 1, 3, 4, 6, 7, 9, 10]  // Half-Whole Diminished
        
        // Advanced scales
        case "Lydianb7":
            return [0, 2, 4, 6, 7, 9, 10]      // R, 2, 3, #4, 5, 6, b7
        case "Mixolydianb6":
            return [0, 2, 4, 5, 7, 8, 10]      // R, 2, 3, 4, 5, b6, b7
        case "PhrygianDominant":
            return [0, 1, 4, 5, 7, 8, 10]      // R, b2, 3, 4, 5, b6, b7
        case "Altered":
            return [0, 1, 3, 4, 6, 8, 10]      // R, b2, #2, 3, b5, b6, b7
        case "WholeTone":
            return [0, 2, 4, 6, 8, 10]         // R, 2, 3, #4, #5, b7
        
        default:
            return nil
        }
    }
}

