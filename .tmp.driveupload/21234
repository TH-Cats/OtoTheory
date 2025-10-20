import AVFoundation
import AudioToolbox

/// BassBounceService
/// 1小節（2.0秒@120BPM）のベースPCMをオフラインレンダリング
/// パターン: Root → Root → 5th → Root+1Oct（4つ打ち、各1拍）
final class BassBounceService {
    
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
        print("✅ BassBounceService initialized with \(sf2URL.lastPathComponent)")
    }
    
    // MARK: - Public API
    
    /// 指定されたコードの1小節ベースPCMバッファを生成（またはキャッシュから取得）
    /// パターン: Root → Root → 5th → Root+1Oct（4つ打ち、各1拍）
    /// - Parameters:
    ///   - key: キャッシュキー（chord, program, bpm）
    ///   - sf2URL: SoundFont ファイルのURL
    /// - Returns: 2.0秒のPCMバッファ（44.1kHz, 2ch）
    func buffer(
        for key: CacheKey,
        sf2URL: URL
    ) throws -> AVAudioPCMBuffer {
        
        // キャッシュヒット
        if let cached = cache[key] {
            print("✅ BassBounce: cache hit for \(key.chord)")
            updateCacheOrder(key)
            return cached
        }
        
        print("🔧 BassBounce: rendering \(key.chord) @ \(key.bpm)BPM...")
        
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
        
        // オフラインモード有効化 → エンジン起動
        print("🔧 BassBounce: enabling offline mode...")
        try engine.enableManualRenderingMode(
            .offline,
            format: format,
            maximumFrameCount: 4096
        )
        
        print("🔧 BassBounce: starting engine...")
        try engine.start()
        
        // SF2ロード（エンジン起動後に実行）
        print("🔧 BassBounce: loading SF2 from \(sf2URL.lastPathComponent), program=\(key.program)")
        do {
            try sampler.loadSoundBankInstrument(
                at: sf2URL,
                program: key.program,  // 34 = Electric Bass (finger)
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
            print("✅ BassBounce: SF2 loaded successfully")
        } catch {
            print("❌ BassBounce: SF2 load failed: \(error)")
            throw NSError(
                domain: "BassBounceService",
                code: -10851,
                userInfo: [NSLocalizedDescriptionKey: "SF2 load failed: \(error.localizedDescription)"]
            )
        }
        
        // CC初期化（Reverb/Chorus/Sustain=0）
        print("🔧 BassBounce: initializing CC...")
        for ch: UInt8 in 0...1 {
            sampler.sendController(91, withValue: 0, onChannel: ch)  // Reverb
            sampler.sendController(93, withValue: 0, onChannel: ch)  // Chorus
            sampler.sendController(64, withValue: 0, onChannel: ch)  // Sustain
            sampler.sendController(7, withValue: 100, onChannel: ch) // Volume
        }
        print("✅ BassBounce: CC initialized")
        
        // 出力バッファ準備
        guard let renderBuffer = AVAudioPCMBuffer(
            pcmFormat: engine.manualRenderingFormat,
            frameCapacity: totalFrames
        ) else {
            throw NSError(
                domain: "BassBounceService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create render buffer"]
            )
        }
        
        // ベースノート取得（全てRoot音のみ）
        let bassRoot = chordToBassRoot(key.chord)
        
        // イベントリスト作成（4つ打ち、各1拍、全てRoot音）
        let beatFrames = AVAudioFramePosition((60.0 / key.bpm) * sampleRate)  // 1拍のフレーム数
        let noteDuration = beatFrames * 90 / 100  // 拍の90%（次の拍の前に切る）
        
        // ✅ ベースのアタックディレイ（現在: 全て0ms = 完全同期）
        // 注: この遅延は PCM 再生専用で、MIDI エクスポートには影響しない
        let attackDelay = AVAudioFramePosition(0)  // 0ms（ディレイなし）
        
        var events: [(frame: AVAudioFramePosition, note: UInt8, isNoteOn: Bool)] = []
        
        // 1拍目: Root音
        events.append((frame: attackDelay, note: bassRoot, isNoteOn: true))
        events.append((frame: noteDuration, note: bassRoot, isNoteOn: false))
        
        // 2拍目: Root音
        events.append((frame: beatFrames + attackDelay, note: bassRoot, isNoteOn: true))
        events.append((frame: beatFrames + noteDuration, note: bassRoot, isNoteOn: false))
        
        // 3拍目: Root音（5thから変更）
        events.append((frame: beatFrames * 2 + attackDelay, note: bassRoot, isNoteOn: true))
        events.append((frame: beatFrames * 2 + noteDuration, note: bassRoot, isNoteOn: false))
        
        // 4拍目: Root音（Root+1Octから変更）
        events.append((frame: beatFrames * 3 + attackDelay, note: bassRoot, isNoteOn: true))
        events.append((frame: beatFrames * 3 + noteDuration, note: bassRoot, isNoteOn: false))
        
        // イベントをフレーム順にソート
        events.sort { $0.frame < $1.frame }
        
        print("🎵 BassBounce: 4つ打ち（全てRoot音） - Beat1-4: Root(\(bassRoot))")
        
        // Scratch バッファ準備
        guard let scratchBuffer = AVAudioPCMBuffer(
            pcmFormat: engine.manualRenderingFormat,
            frameCapacity: 4096
        ) else {
            throw NSError(
                domain: "BassBounceService",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create scratch buffer"]
            )
        }
        
        // レンダーループ
        var currentFrame: AVAudioFramePosition = 0
        var eventIndex = 0
        
        renderBuffer.frameLength = 0
        
        while currentFrame < AVAudioFramePosition(totalFrames) {
            // 次のチャンクサイズ決定
            let remainingFrames = AVAudioFramePosition(totalFrames) - currentFrame
            let framesToRender = min(AVAudioFrameCount(remainingFrames), 4096)
            
            // 現在のチャンク範囲内のイベントを処理
            while eventIndex < events.count {
                let event = events[eventIndex]
                if event.frame >= currentFrame && event.frame < currentFrame + AVAudioFramePosition(framesToRender) {
                    // イベント発火
                    if event.isNoteOn {
                        sampler.startNote(event.note, withVelocity: 100, onChannel: 0)
                        print("🎵 Note On: \(event.note) at frame \(event.frame)")
                    } else {
                        sampler.stopNote(event.note, onChannel: 0)
                        print("🎵 Note Off: \(event.note) at frame \(event.frame)")
                    }
                    eventIndex += 1
                } else if event.frame >= currentFrame + AVAudioFramePosition(framesToRender) {
                    break
                } else {
                    eventIndex += 1
                }
            }
            
            // レンダリング実行
            scratchBuffer.frameLength = 0
            let status = try engine.renderOffline(framesToRender, to: scratchBuffer)
            
            guard status == .success else {
                throw NSError(
                    domain: "BassBounceService",
                    code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "Render failed with status \(status.rawValue)"]
                )
            }
            
            // Scratch → Accumulate
            guard let srcL = scratchBuffer.floatChannelData?[0],
                  let srcR = scratchBuffer.floatChannelData?[1],
                  let dstL = renderBuffer.floatChannelData?[0],
                  let dstR = renderBuffer.floatChannelData?[1] else {
                throw NSError(
                    domain: "BassBounceService",
                    code: -4,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to access channel data"]
                )
            }
            
            let offset = Int(renderBuffer.frameLength)
            let copyFrames = Int(scratchBuffer.frameLength)
            
            for i in 0..<copyFrames {
                dstL[offset + i] = srcL[i]
                dstR[offset + i] = srcR[i]
            }
            
            renderBuffer.frameLength += scratchBuffer.frameLength
            currentFrame += AVAudioFramePosition(scratchBuffer.frameLength)
        }
        
        print("✅ BassBounce: rendered \(key.chord), \(renderBuffer.frameLength) frames")
        
        // キャッシュに保存
        cache[key] = renderBuffer
        updateCacheOrder(key)
        
        // LRU制限
        if cache.count > maxCacheSize {
            if let oldest = cacheOrder.first {
                cache.removeValue(forKey: oldest)
                cacheOrder.removeFirst()
            }
        }
        
        return renderBuffer
    }
    
    // MARK: - Private Helpers
    
    /// キャッシュアクセス順序を更新（LRU）
    private func updateCacheOrder(_ key: CacheKey) {
        cacheOrder.removeAll { $0 == key }
        cacheOrder.append(key)
    }
    
    /// コードシンボルからベースルート音を抽出（C2 = 36 ベース）
    private func chordToBassRoot(_ chord: String) -> UInt8 {
        // ルート音抽出（例: "Cmaj7" → "C", "F#m" → "F#"）
        let rootMatch = chord.range(of: "^[A-G][#b]?", options: .regularExpression)
        guard let range = rootMatch else {
            print("⚠️ BassBounce: Failed to parse chord '\(chord)', using C")
            return 36  // C2 (デフォルト)
        }
        
        let rootStr = String(chord[range])
        
        // ルート音 → MIDI番号（C2 = 36 ベース）
        let pcMap: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1,
            "D": 2, "D#": 3, "Eb": 3,
            "E": 4,
            "F": 5, "F#": 6, "Gb": 6,
            "G": 7, "G#": 8, "Ab": 8,
            "A": 9, "A#": 10, "Bb": 10,
            "B": 11
        ]
        
        guard let pc = pcMap[rootStr] else {
            print("⚠️ BassBounce: Unknown root '\(rootStr)', using C")
            return 36
        }
        
        return UInt8(36 + pc)  // C2 = 36
    }
}

