import AVFoundation
import AudioToolbox

/// DrumBounceService
/// 1小節（2.0秒@120BPM）のドラムPCMをオフラインレンダリング
/// パターン: Rock / Pop / Funk
final class DrumBounceService {
    
    // MARK: - Drum Pattern
    
    enum Pattern: String, CaseIterable {
        case rock = "Rock"
        case pop = "Pop"
        // case funk = "Funk"  // ✅ 削除（CPU負荷軽減）
    }
    
    // MARK: - Cache Key
    
    struct CacheKey: Hashable {
        let pattern: Pattern
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
        print("✅ DrumBounceService initialized with \(sf2URL.lastPathComponent)")
    }
    
    // MARK: - Public API
    
    /// 指定されたパターンの1小節ドラムPCMバッファを生成（またはキャッシュから取得）
    /// - Parameters:
    ///   - key: キャッシュキー（pattern, bpm）
    ///   - sf2URL: SoundFont ファイルのURL
    /// - Returns: 2.0秒のPCMバッファ（44.1kHz, 2ch）
    func buffer(
        for key: CacheKey,
        sf2URL: URL
    ) throws -> AVAudioPCMBuffer {
        
        // キャッシュヒット
        if let cached = cache[key] {
            print("✅ DrumBounce: cache hit for \(key.pattern.rawValue)")
            updateCacheOrder(key)
            return cached
        }
        
        print("🔧 DrumBounce: rendering \(key.pattern.rawValue) @ \(key.bpm)BPM...")
        
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
        print("🔧 DrumBounce: enabling offline mode...")
        try engine.enableManualRenderingMode(
            .offline,
            format: format,
            maximumFrameCount: 4096
        )
        
        print("🔧 DrumBounce: starting engine...")
        try engine.start()
        
        // SF2ロード（エンジン起動後に実行）
        // ドラムはチャンネル10、Percussion Bankを使用
        print("🔧 DrumBounce: loading SF2 from \(sf2URL.lastPathComponent), Percussion Bank")
        do {
            try sampler.loadSoundBankInstrument(
                at: sf2URL,
                program: 0,  // Percussion Bankではprogram=0
                bankMSB: UInt8(kAUSampler_DefaultPercussionBankMSB),  // 0x78 = 120
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
            print("✅ DrumBounce: SF2 loaded successfully")
        } catch {
            print("❌ DrumBounce: SF2 load failed: \(error)")
            throw NSError(
                domain: "DrumBounceService",
                code: -10851,
                userInfo: [NSLocalizedDescriptionKey: "SF2 load failed: \(error.localizedDescription)"]
            )
        }
        
        // CC初期化（Reverb/Chorus=0）
        print("🔧 DrumBounce: initializing CC...")
        for ch: UInt8 in 9...10 {  // チャンネル10（インデックス9）
            sampler.sendController(91, withValue: 0, onChannel: ch)  // Reverb
            sampler.sendController(93, withValue: 0, onChannel: ch)  // Chorus
            sampler.sendController(7, withValue: 100, onChannel: ch) // Volume
        }
        print("✅ DrumBounce: CC initialized")
        
        // 出力バッファ準備
        guard let renderBuffer = AVAudioPCMBuffer(
            pcmFormat: engine.manualRenderingFormat,
            frameCapacity: totalFrames
        ) else {
            throw NSError(
                domain: "DrumBounceService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create render buffer"]
            )
        }
        
        // イベントリスト作成（パターン別）
        let events = createEvents(pattern: key.pattern, bpm: key.bpm)
        
        print("🎵 DrumBounce: \(key.pattern.rawValue) pattern - \(events.count) events")
        
        // Scratch バッファ準備
        guard let scratchBuffer = AVAudioPCMBuffer(
            pcmFormat: engine.manualRenderingFormat,
            frameCapacity: 4096
        ) else {
            throw NSError(
                domain: "DrumBounceService",
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
                    // イベント発火（ドラムはチャンネル9 = MIDI ch10）
                    if event.isNoteOn {
                        sampler.startNote(event.note, withVelocity: event.velocity, onChannel: 9)
                    } else {
                        sampler.stopNote(event.note, onChannel: 9)
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
                    domain: "DrumBounceService",
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
                    domain: "DrumBounceService",
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
        
        print("✅ DrumBounce: rendered \(key.pattern.rawValue), \(renderBuffer.frameLength) frames")
        
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
    
    /// ドラムパターンのイベントリストを作成
    private func createEvents(
        pattern: Pattern,
        bpm: Double
    ) -> [(frame: AVAudioFramePosition, note: UInt8, velocity: UInt8, isNoteOn: Bool)] {
        
        let beatFrames = AVAudioFramePosition((60.0 / bpm) * sampleRate)  // 1拍のフレーム数
        let sixteenthFrames = beatFrames / 4  // 16分音符のフレーム数
        
        // General MIDI Drum Map（チャンネル10）
        let kick: UInt8 = 36        // Bass Drum 1
        let snare: UInt8 = 38       // Acoustic Snare
        let closedHH: UInt8 = 42    // Closed Hi-Hat
        let openHH: UInt8 = 46      // Open Hi-Hat
        
        var events: [(frame: AVAudioFramePosition, note: UInt8, velocity: UInt8, isNoteOn: Bool)] = []
        
        switch pattern {
        case .rock:
            // Rock: キック+スネアのみ（1,3拍目=キック、2,4拍目=スネア）
            // 1小節 = 4拍
            // ✅ Note Off は削除（ドラムは減衰楽器のため不要、CPU負荷軽減）
            // ✅ ハイハット削除（高音の突っ込み感回避）
            for beat in 0..<4 {
                let beatStart = AVAudioFramePosition(beat) * beatFrames
                
                // キック: 1拍目と3拍目
                if beat == 0 || beat == 2 {
                    events.append((frame: beatStart, note: kick, velocity: 100, isNoteOn: true))
                }
                
                // スネア: 2拍目と4拍目
                if beat == 1 || beat == 3 {
                    events.append((frame: beatStart, note: snare, velocity: 95, isNoteOn: true))
                }
            }
            
        case .pop:
            // Pop: キック+スネアのみ（1,3拍目=キック、2,4拍目=スネア）
            // 1小節 = 4拍
            // ✅ Note Off は削除（ドラムは減衰楽器のため不要、CPU負荷軽減）
            // ✅ ハイハット削除（高音の突っ込み感回避）
            for beat in 0..<4 {
                let beatStart = AVAudioFramePosition(beat) * beatFrames
                
                // キック: 1拍目と3拍目
                if beat == 0 || beat == 2 {
                    events.append((frame: beatStart, note: kick, velocity: 100, isNoteOn: true))
                }
                
                // スネア: 2拍目と4拍目
                if beat == 1 || beat == 3 {
                    events.append((frame: beatStart, note: snare, velocity: 90, isNoteOn: true))
                }
            }
            
        // case .funk:  // ✅ 削除（CPU負荷軽減）
        }
        
        // イベントをフレーム順にソート
        events.sort { $0.frame < $1.frame }
        
        return events
    }
}

