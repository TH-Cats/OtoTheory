import AVFoundation
import AudioToolbox

/// HybridPlayer
/// ギターPCM（AVAudioPlayerNode）+ ベース/ドラムMIDI（AVAudioSequencer）を統合再生
final class HybridPlayer {
    
    // MARK: - Audio Components
    
    let engine = AVAudioEngine()
    let playerGtr = AVAudioPlayerNode()
    let samplerBass = AVAudioUnitSampler()
    let samplerDrum = AVAudioUnitSampler()
    var sequencer: AVAudioSequencer!
    
    private var isPlaying = false
    private var currentBarIndex = 0
    
    // MARK: - Initialization
    
    init() {
        setupEngine()
    }
    
    private func setupEngine() {
        // ノードをアタッチ
        engine.attach(playerGtr)
        engine.attach(samplerBass)
        engine.attach(samplerDrum)
        
        // mainMixerNodeへ接続
        let format = AVAudioFormat(
            standardFormatWithSampleRate: 44100.0,
            channels: 2
        )!
        
        engine.connect(playerGtr, to: engine.mainMixerNode, format: format)
        engine.connect(samplerBass, to: engine.mainMixerNode, format: format)
        engine.connect(samplerDrum, to: engine.mainMixerNode, format: format)
        
        // Sequencer初期化
        sequencer = AVAudioSequencer(audioEngine: engine)
        
        print("✅ HybridPlayer: engine setup complete")
    }
    
    // MARK: - Public API
    
    /// 準備：SF2ロード、AVAudioSession設定
    func prepare(sf2URL: URL, drumKitURL: URL?) throws {
        print("🔧 HybridPlayer.prepare: starting...")
        
        // AVAudioSession設定
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setPreferredSampleRate(44100.0)
        #if targetEnvironment(simulator)
        try session.setPreferredIOBufferDuration(0.01)  // 10ms（シミュレータ）
        #else
        try session.setPreferredIOBufferDuration(0.005) // 5ms（実機）
        #endif
        try session.setActive(true)
        print("✅ HybridPlayer.prepare: AVAudioSession configured")
        
        // ✅ Engine を先に起動（SF2 ロード前に必須）
        if !engine.isRunning {
            try engine.start()
            print("✅ HybridPlayer.prepare: engine started")
        }
        
        // ⚠️ 暫定措置: ベース/ドラムのSF2ロードをスキップ（シミュレータでエラー -10851）
        // 実機では有効化する予定
        print("⚠️ HybridPlayer.prepare: Bass/Drum SF2 load skipped (guitar-only mode)")
        
        // Bass SF2ロード（コメントアウト）
        // print("🔧 HybridPlayer.prepare: loading Bass SF2 from \(sf2URL.lastPathComponent)")
        // do {
        //     try samplerBass.loadSoundBankInstrument(
        //         at: sf2URL,
        //         program: 34,
        //         bankMSB: 0x00,
        //         bankLSB: 0x00
        //     )
        //     print("✅ HybridPlayer.prepare: Bass SF2 loaded")
        // } catch {
        //     print("❌ HybridPlayer.prepare: Bass SF2 load failed: \(error)")
        //     throw error
        // }
        
        // Drum SF2ロード（コメントアウト）
        // print("🔧 HybridPlayer.prepare: loading Drum SF2")
        // do {
        //     if let drumURL = drumKitURL {
        //         try samplerDrum.loadSoundBankInstrument(
        //             at: drumURL,
        //             program: 0,
        //             bankMSB: UInt8(kAUSampler_DefaultPercussionBankMSB),
        //             bankLSB: 0x00
        //         )
        //     } else {
        //         // drumKitURLが無い場合は同じSF2でPercussion Bankを指定
        //         try samplerDrum.loadSoundBankInstrument(
        //             at: sf2URL,
        //             program: 0,
        //             bankMSB: UInt8(kAUSampler_DefaultPercussionBankMSB),
        //             bankLSB: 0x00
        //         )
        //     }
        //     print("✅ HybridPlayer.prepare: Drum SF2 loaded")
        // } catch {
        //     print("❌ HybridPlayer.prepare: Drum SF2 load failed: \(error)")
        //     throw error
        // }
        
        // CC初期化（コメントアウト）
        // for sampler in [samplerBass, samplerDrum] {
        //     for ch: UInt8 in 0...1 {
        //         sampler.sendController(91, withValue: 0, onChannel: ch)  // Reverb
        //         sampler.sendController(93, withValue: 0, onChannel: ch)  // Chorus
        //         sampler.sendController(64, withValue: 0, onChannel: ch)  // Sustain
        //         sampler.sendController(7, withValue: 100, onChannel: ch) // Volume
        //     }
        // }
        // print("✅ HybridPlayer.prepare: CC initialized")
        
        print("✅ HybridPlayer.prepare: complete")
    }
    
    /// 再生：ギターPCMバッファ配列 + ベース/ドラムシーケンス
    /// - Parameters:
    ///   - score: Score（BPM + bars）
    ///   - guitarBuffers: 各小節のPCMバッファ配列
    ///   - onBarChange: 小節変更時のコールバック
    func play(
        score: Score,
        guitarBuffers: [AVAudioPCMBuffer],
        onBarChange: @escaping (Int) -> Void
    ) throws {
        audioTrace("PATH = HybridPlayer (PCM)")
        guard guitarBuffers.count == score.barCount else {
            throw NSError(
                domain: "HybridPlayer",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Buffer count mismatch"]
            )
        }
        
        isPlaying = true
        currentBarIndex = 0
        
        // Sequencer準備（Phase B: ベース有効化）
        try prepareSequencer(score: score)
        
        // Phase B: カウントインバッファ生成（4拍）
        let countInBuffer = try generateCountInBuffer(bpm: score.bpm)
        
        // カウントインをスケジュール
        playerGtr.scheduleBuffer(countInBuffer) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            print("✅ Count-in completed")
        }
        
        // PlayerNodeにギターPCMをスケジュール（絶対サンプル時刻で連結）
        let countInDuration = 60.0 / score.bpm * 4.0  // 4拍分
        let countInFrames = AVAudioFramePosition(countInDuration * 44100.0)
        scheduleGuitarBuffers(guitarBuffers, countInFrames: countInFrames, onBarChange: onBarChange)
        
        // 同時スタート（0.2秒先に予約して同期精度向上）
        let startTime = AVAudioTime(
            hostTime: mach_absolute_time() + AVAudioTime.hostTime(forSeconds: 0.2)
        )
        
        playerGtr.play(at: startTime)
        
        // Phase B: Sequencer も同時スタート（カウントイン分遅延）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 + countInDuration) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            do {
                try self.sequencer.start()
                print("✅ HybridPlayer: sequencer started (bass, delayed by \(countInDuration)s)")
            } catch {
                print("⚠️ HybridPlayer: sequencer start failed: \(error)")
            }
        }
        
        print("✅ HybridPlayer: playback started (with count-in)")
    }
    
    /// 停止
    func stop() {
        isPlaying = false
        
        playerGtr.stop()
        sequencer.stop()
        
        // CC120/123でクリーンアップ
        for sampler in [samplerBass, samplerDrum] {
            for ch: UInt8 in 0...1 {
                sampler.sendController(120, withValue: 0, onChannel: ch)  // All Sound Off
                sampler.sendController(123, withValue: 0, onChannel: ch)  // All Notes Off
            }
        }
        
        currentBarIndex = 0
        
        print("✅ HybridPlayer: stopped")
    }
    
    // MARK: - Private Helpers
    
    /// Sequencer準備（Phase B: ベース追加）
    private func prepareSequencer(score: Score) throws {
        // SequencerBuilder を使って MusicSequence 作成
        let sequence = try SequencerBuilder.build(
            score: score,
            includeBass: true,  // Phase B: ベース有効化
            includeDrums: false  // Phase C で有効化
        )
        
        // MusicSequence を一時ファイルに保存
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("temp_sequence.mid")
        
        // MusicSequence → MIDI file
        MusicSequenceFileCreate(
            sequence,
            tempURL as CFURL,
            .midiType,
            .eraseFile,
            0
        )
        
        // Sequencer にロード
        sequencer.stop()
        try sequencer.load(from: tempURL, options: [])
        
        // Bass トラックを samplerBass にバインド
        if sequencer.tracks.count > 1 {
            // Track 0 = テンポトラック
            // Track 1 = ベーストラック
            sequencer.tracks[1].destinationAudioUnit = samplerBass
            print("✅ HybridPlayer: Bass track bound to samplerBass")
        }
        
        print("✅ HybridPlayer: sequencer prepared (tempo=\(score.bpm)BPM, bass enabled)")
    }
    
    /// ギターPCMバッファをPlayerNodeにスケジュール（絶対サンプル時刻で連結）
    private func scheduleGuitarBuffers(
        _ buffers: [AVAudioPCMBuffer],
        countInFrames: AVAudioFramePosition,
        onBarChange: @escaping (Int) -> Void
    ) {
        // A案: 絶対サンプル時刻で全バッファを先にスケジュール
        
        let sampleRate = engine.mainMixerNode.outputFormat(forBus: 0).sampleRate
        let barFrames = buffers.first?.frameLength ?? 88200  // 2.0s @ 44100Hz
        
        var cursor: AVAudioFramePosition = countInFrames
        
        for (index, buffer) in buffers.enumerated() {
            let when = AVAudioTime(sampleTime: cursor, atRate: sampleRate)
            
            playerGtr.scheduleBuffer(buffer, at: when, options: []) { [weak self] in
                guard let self = self, self.isPlaying else { return }
                
                // バー変更通知
                DispatchQueue.main.async {
                    onBarChange(index)
                }
            }
            
            cursor += AVAudioFramePosition(buffer.frameLength)
            print("🎵 Scheduled buffer \(index) at sampleTime \(when.sampleTime)")
        }
        
        // ループ: 最後のバッファ完了後に再度スケジュール
        if let lastBuffer = buffers.last {
            playerGtr.scheduleBuffer(lastBuffer) { [weak self] in
                guard let self = self, self.isPlaying else { return }
                
                // ループ: 全バッファを再スケジュール
                self.scheduleGuitarBuffers(
                    buffers,
                    countInFrames: 0,  // ループ時はカウントイン不要
                    onBarChange: onBarChange
                )
            }
        }
        
        print("✅ HybridPlayer: All buffers scheduled (\(buffers.count) bars)")
    }
    
    /// カウントインバッファ生成（4拍、1000Hzクリック音）
    private func generateCountInBuffer(bpm: Double) throws -> AVAudioPCMBuffer {
        let sampleRate = engine.mainMixerNode.outputFormat(forBus: 0).sampleRate
        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 2
        )!
        
        // 4拍分のフレーム数
        let framesPerBeat = AVAudioFrameCount(60.0 / bpm * sampleRate)
        let totalFrames = framesPerBeat * 4
        
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: totalFrames
        ) else {
            throw NSError(
                domain: "HybridPlayer",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create count-in buffer"]
            )
        }
        
        buffer.frameLength = totalFrames
        
        // 各拍にクリック音を生成（1000Hz、50ms）
        let clickDuration = 0.05  // 50ms
        let clickFrames = AVAudioFrameCount(clickDuration * sampleRate)
        let frequency: Float = 1000.0  // 1000Hz
        
        for beat in 0..<4 {
            let startFrame = Int(framesPerBeat) * beat
            
            for frame in 0..<Int(clickFrames) {
                let absoluteFrame = startFrame + frame
                let time = Float(frame) / Float(sampleRate)
                let value = sin(2.0 * Float.pi * frequency * time) * 0.3  // 30%音量
                
                // ステレオ両チャンネルに書き込み
                buffer.floatChannelData?[0][absoluteFrame] = value
                buffer.floatChannelData?[1][absoluteFrame] = value
            }
        }
        
        print("✅ HybridPlayer: Count-in buffer generated (4 beats, \(totalFrames) frames)")
        return buffer
    }
}


