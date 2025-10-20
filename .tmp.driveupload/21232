import AVFoundation
import AudioToolbox

/// GuitarBounceService
/// 1小節（2.0秒@120BPM）のギターPCMをオフラインレンダリング
/// 末尾120msを波形で線形フェードアウト
final class GuitarBounceService {
    
    // MARK: - Cache Key
    
    struct CacheKey: Hashable {
        let chord: String
        let program: UInt8
        let bpm: Double
    }
    
    // MARK: - Properties
    
    private var cache: [CacheKey: AVAudioPCMBuffer] = [:]
    private let maxCacheSize = 16  // LRU制限
    private var cacheOrder: [CacheKey] = []
    
    private let sampleRate: Double = 44100.0
    private let sf2URL: URL
    
    // MARK: - Init
    
    init(sf2URL: URL) throws {
        self.sf2URL = sf2URL
        print("✅ GuitarBounceService initialized with \(sf2URL.lastPathComponent)")
    }
    
    // MARK: - Public API
    
    /// 指定されたコードの1小節PCMバッファを生成（またはキャッシュから取得）
    /// - Parameters:
    ///   - key: キャッシュキー（chord, program, bpm）
    ///   - sf2URL: SoundFont ファイルのURL
    ///   - strumMs: ストラム遅延（デフォルト15ms）
    ///   - releaseMs: フェードアウト時間（デフォルト200ms）
    /// - Returns: 2.0秒のPCMバッファ（44.1kHz, 2ch）
    func buffer(
        for key: CacheKey,
        sf2URL: URL,
        strumMs: Double = 15.0,
        releaseMs: Double = 200.0
    ) throws -> AVAudioPCMBuffer {
        
        // キャッシュヒット
        if let cached = cache[key] {
            print("✅ GuitarBounce: cache hit for \(key.chord)")
            updateCacheOrder(key)
            return cached
        }
        
        print("🔧 GuitarBounce: rendering \(key.chord) @ \(key.bpm)BPM...")
        
        // 1小節の秒数計算（BPM120なら2.0秒）
        let secondsPerBar = 60.0 / key.bpm * 4.0
        let totalFrames = AVAudioFrameCount(secondsPerBar * sampleRate)
        
        // オフラインエンジン準備
        let engine = AVAudioEngine()
        let sampler = AVAudioUnitSampler()
        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 2
        )!
        
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: format)
        
        // ✅ 順序修正: オフラインモード有効化 → エンジン起動 → SF2ロード
        print("🔧 GuitarBounce: enabling offline mode...")
        try engine.enableManualRenderingMode(
            .offline,
            format: format,
            maximumFrameCount: 4096
        )
        
        print("🔧 GuitarBounce: starting engine...")
        try engine.start()
        
        // SF2ロード（エンジン起動後に実行）
        print("🔧 GuitarBounce: loading SF2 from \(sf2URL.lastPathComponent), program=\(key.program)")
        do {
            try sampler.loadSoundBankInstrument(
                at: sf2URL,
                program: key.program,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
            print("✅ GuitarBounce: SF2 loaded successfully")
        } catch {
            print("❌ GuitarBounce: SF2 load failed: \(error)")
            throw NSError(
                domain: "GuitarBounceService",
                code: -10851,
                userInfo: [NSLocalizedDescriptionKey: "SF2 load failed: \(error.localizedDescription)"]
            )
        }
        
        // CC初期化（Reverb/Chorus/Sustain=0）
        print("🔧 GuitarBounce: initializing CC...")
        for ch: UInt8 in 0...1 {
            sampler.sendController(91, withValue: 0, onChannel: ch)  // Reverb
            sampler.sendController(93, withValue: 0, onChannel: ch)  // Chorus
            sampler.sendController(64, withValue: 0, onChannel: ch)  // Sustain
            sampler.sendController(7, withValue: 100, onChannel: ch) // Volume
        }
        print("✅ GuitarBounce: CC initialized")
        
        // 出力バッファ準備
        guard let renderBuffer = AVAudioPCMBuffer(
            pcmFormat: engine.manualRenderingFormat,
            frameCapacity: totalFrames
        ) else {
            throw NSError(
                domain: "GuitarBounceService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create render buffer"]
            )
        }
        
        // MIDIノート取得（最大6声）
        let midiNotes = Array(chordToMidi(key.chord).prefix(6))
        
        // A案: イベント駆動レンダーループ + Scratch→Accum 方式
        
        // 1. イベントリスト作成（4拍分のストラム）
        let strumFrames = AVAudioFramePosition(strumMs / 1000.0 * sampleRate)
        let beatFrames = AVAudioFramePosition((60.0 / key.bpm) * sampleRate)  // 1拍のフレーム数
        let noteDuration = beatFrames * 70 / 100  // 拍の70%で切る（フェード領域を確保）
        
        var events: [(frame: AVAudioFramePosition, note: UInt8, isNoteOn: Bool)] = []
        
        // 4拍分のストラムを生成
        for beat in 0..<4 {
            let beatStart = AVAudioFramePosition(beat) * beatFrames
            
            // ストラム（ノートオン）
            for (i, note) in midiNotes.enumerated() {
                let startFrame = beatStart + AVAudioFramePosition(i) * strumFrames
                events.append((frame: startFrame, note: note, isNoteOn: true))
            }
            
            // ノートオフ（拍の70%後、4拍目は75%で緩やかに）
            let adjustedDuration = (beat == 3) ? (beatFrames * 75 / 100) : noteDuration
            for note in midiNotes {
                let offFrame = beatStart + adjustedDuration
                events.append((frame: offFrame, note: note, isNoteOn: false))
            }
        }
        
        // イベントをフレーム順にソート
        events.sort { $0.frame < $1.frame }
        
        // 2. Scratch バッファ（小さなブロック用）
        let blockSize = engine.manualRenderingMaximumFrameCount
        guard let scratchBuffer = AVAudioPCMBuffer(
            pcmFormat: engine.manualRenderingFormat,
            frameCapacity: blockSize
        ) else {
            throw NSError(
                domain: "GuitarBounceService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create scratch buffer"]
            )
        }
        
        // 3. Accum バッファ（最終出力用）
        guard let accumBuffer = AVAudioPCMBuffer(
            pcmFormat: engine.manualRenderingFormat,
            frameCapacity: totalFrames
        ) else {
            throw NSError(
                domain: "GuitarBounceService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create accum buffer"]
            )
        }
        accumBuffer.frameLength = totalFrames
        
        // 4. イベント駆動レンダーループ
        var framesRendered: AVAudioFrameCount = 0
        var nextEventIndex = 0
        
        while framesRendered < totalFrames {
            // 次のイベントまでのフレーム数を計算
            let framesToRender: AVAudioFrameCount
            if nextEventIndex < events.count {
                let nextEventFrame = events[nextEventIndex].frame
                let framesUntilEvent = AVAudioFrameCount(max(0, nextEventFrame - AVAudioFramePosition(framesRendered)))
                framesToRender = min(blockSize, framesUntilEvent, totalFrames - framesRendered)
            } else {
                framesToRender = min(blockSize, totalFrames - framesRendered)
            }
            
            // レンダリング
            if framesToRender > 0 {
                scratchBuffer.frameLength = framesToRender
                let status = try engine.renderOffline(framesToRender, to: scratchBuffer)
                
                guard status == .success else {
                    throw NSError(
                        domain: "GuitarBounceService",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Render failed"]
                    )
                }
                
                // Scratch → Accum にコピー
                for ch in 0..<Int(scratchBuffer.format.channelCount) {
                    if let src = scratchBuffer.floatChannelData?[ch],
                       let dst = accumBuffer.floatChannelData?[ch] {
                        let dstOffset = Int(framesRendered)
                        memcpy(dst.advanced(by: dstOffset), src, Int(framesToRender) * MemoryLayout<Float>.stride)
                    }
                }
                
                framesRendered += framesToRender
            }
            
            // イベント発火（フレーム位置が一致した瞬間にノートオン/オフ）
            while nextEventIndex < events.count && events[nextEventIndex].frame <= AVAudioFramePosition(framesRendered) {
                let event = events[nextEventIndex]
                if event.isNoteOn {
                    sampler.startNote(event.note, withVelocity: 80, onChannel: 0)
                    print("🎵 Note On: \(event.note) at frame \(event.frame)")
                } else {
                    sampler.stopNote(event.note, onChannel: 0)
                    print("🎵 Note Off: \(event.note) at frame \(event.frame)")
                }
                nextEventIndex += 1
            }
        }
        
        engine.stop()
        
        // 5. 末尾200msを線形フェード（accumBuffer に適用）
        applyFadeOut(to: accumBuffer, durationMs: releaseMs)
        
        // 6. 検証: 末尾が -90dB 以下か確認
        verifyFadeOut(accumBuffer)
        
        // 7. キャッシュ登録
        cache[key] = accumBuffer
        updateCacheOrder(key)
        enforceCacheLimit()
        
        print("✅ GuitarBounce: rendered \(key.chord), \(accumBuffer.frameLength) frames")
        
        return accumBuffer
    }
    
    // MARK: - Private Helpers
    
    /// 末尾を線形フェードアウト（200ms → 0.0）
    private func applyFadeOut(to buffer: AVAudioPCMBuffer, durationMs: Double) {
        guard let floatData = buffer.floatChannelData else { return }
        
        let fadeFrames = Int(durationMs / 1000.0 * sampleRate)
        let totalFrames = Int(buffer.frameLength)
        let fadeStartFrame = max(0, totalFrames - fadeFrames)
        
        for ch in 0..<Int(buffer.format.channelCount) {
            let channelData = floatData[ch]
            for i in fadeStartFrame..<totalFrames {
                let progress = Float(i - fadeStartFrame) / Float(fadeFrames)
                let gain = 1.0 - progress  // 1.0 → 0.0
                channelData[i] *= gain
            }
        }
    }
    
    /// フェードアウト検証: 末尾が -90dB 以下か確認
    private func verifyFadeOut(_ buffer: AVAudioPCMBuffer) {
        guard let floatData = buffer.floatChannelData else { return }
        
        let totalFrames = Int(buffer.frameLength)
        let checkFrames = min(1024, totalFrames)  // 末尾1024サンプルをチェック
        let startFrame = totalFrames - checkFrames
        
        var maxAbs: Float = 0.0
        for ch in 0..<Int(buffer.format.channelCount) {
            let channelData = floatData[ch]
            for i in startFrame..<totalFrames {
                maxAbs = max(maxAbs, abs(channelData[i]))
            }
        }
        
        let dB = maxAbs > 0 ? 20.0 * log10(maxAbs) : -100.0
        print("🔍 Fade-out verification: tail max = \(maxAbs) (\(dB) dB)")
        
        if dB > -90.0 {
            print("⚠️ Warning: tail is louder than -90dB")
        } else {
            print("✅ Fade-out OK: tail < -90dB")
        }
    }
    
    /// キャッシュLRU管理
    private func updateCacheOrder(_ key: CacheKey) {
        cacheOrder.removeAll { $0 == key }
        cacheOrder.append(key)
    }
    
    private func enforceCacheLimit() {
        while cacheOrder.count > maxCacheSize {
            let oldest = cacheOrder.removeFirst()
            cache.removeValue(forKey: oldest)
            print("🗑️ GuitarBounce: evicted cache for \(oldest.chord)")
        }
    }
    
    /// コードシンボル → MIDIノート番号配列
    /// （既存のChordSequencer.chordToMidiと同じロジック）
    private func chordToMidi(_ symbol: String) -> [UInt8] {
        let parts = symbol.split(separator: "/")
        let mainChord = String(parts[0])
        
        // ルート音抽出
        let rootMatch = mainChord.range(of: "^[A-G][#b]?", options: .regularExpression)
        guard let rootRange = rootMatch else { return [] }
        let rootStr = String(mainChord[rootRange])
        let quality = String(mainChord[rootRange.upperBound...])
        
        let rootPc = noteNameToPitchClass(rootStr)
        let basePitch: UInt8 = 48 + UInt8(rootPc)  // C3=48
        
        // コード構成音
        var intervals: [Int] = [0]  // ルート
        if quality.contains("m") && !quality.contains("maj") {
            intervals.append(3)  // m3
        } else {
            intervals.append(4)  // M3
        }
        
        if quality.contains("dim") {
            intervals.append(6)  // dim5
        } else if quality.contains("aug") {
            intervals.append(8)  // aug5
        } else {
            intervals.append(7)  // P5
        }
        
        if quality.contains("7") {
            if quality.contains("maj7") {
                intervals.append(11)  // M7
            } else {
                intervals.append(10)  // m7
            }
        }
        
        return intervals.map { basePitch + UInt8($0) }
    }
    
    private func noteNameToPitchClass(_ name: String) -> Int {
        let baseNotes: [String: Int] = [
            "C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11
        ]
        
        var pc = baseNotes[String(name.prefix(1))] ?? 0
        if name.contains("#") { pc += 1 }
        if name.contains("b") { pc -= 1 }
        return (pc + 12) % 12
    }
}

