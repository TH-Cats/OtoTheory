import AVFoundation
import AudioToolbox
import os.log

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
    private var playbackStartTime: Date?  // 再生開始時刻（UI タイミング計算用）
    private var uiUpdateTimer: Timer?  // UI 更新タイマー
    private var barCount: Int = 0  // バー数
    
    // OSLog
    private let logger = Logger(subsystem: "com.ototheory.app", category: "audio")
    
    // MARK: - Initialization
    
    init(sf2URL: URL) throws {
        setupEngine()
        print("✅ HybridPlayer initialized with \(sf2URL.lastPathComponent)")
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
        
        // Bass SF2ロード（暫定: ベースなしで動作）
        // FluidR3_GM.sf2 にベース音色が存在しないため、将来別のSF2を用意する
        print("⚠️ HybridPlayer.prepare: Bass SF2 load skipped (FluidR3_GM.sf2 has no bass patches)")
        print("   Bass will play with default piano sound (will fix in future)")
        
        // ドラムSF2ロードは将来実装（Phase C）
        print("⚠️ HybridPlayer.prepare: Drum SF2 load skipped (Phase C feature)")
        
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
        logger.info("PATH = HybridPlayer (PCM)")
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
        barCount = score.barCount
        playbackStartTime = Date()  // 再生開始時刻を記録
        
        // UI 更新タイマーを開始（0.1秒ごとにチェック）
        startUIUpdateTimer(onBarChange: onBarChange)
        
        // Sequencer準備（Phase B: ベース有効化）
        try prepareSequencer(score: score)
        
        // Phase B: カウントインバッファ生成（4拍）
        let countInBuffer = try generateCountInBuffer(bpm: score.bpm)
        
        // カウントインをスケジュール
        playerGtr.scheduleBuffer(countInBuffer) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            self.logger.info("COUNT-IN done")
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
        logger.info("START at hostTime=\(startTime.hostTime)")
        
        playerGtr.play(at: startTime)
        
        // Phase B: Sequencer は暫定的に無効化（ベース音色が正しくないため）
        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 + countInDuration) { [weak self] in
        //     guard let self = self, self.isPlaying else { return }
        //     do {
        //         try self.sequencer.start()
        //         self.logger.info("Sequencer started (bass)")
        //         print("✅ HybridPlayer: sequencer started (bass, delayed by \(countInDuration)s)")
        //     } catch {
        //         print("⚠️ HybridPlayer: sequencer start failed: \(error)")
        //     }
        // }
        print("⚠️ HybridPlayer: Bass playback disabled (will be fixed in Phase C)")
        
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
        
        // UI 更新タイマーを停止
        uiUpdateTimer?.invalidate()
        uiUpdateTimer = nil
        
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
        // ✅ 改善案: 2周分（= 全バー×2）を先に予約、最後の1個の completion で次の2周を再予約
        
        let sampleRate: Double = 44100.0  // 固定（PCMバッファと一致）
        var cursor: AVAudioFramePosition = countInFrames
        
        // 2周分をスケジュール
        for cycle in 0..<2 {
            for (index, buffer) in buffers.enumerated() {
                let when = AVAudioTime(sampleTime: cursor, atRate: sampleRate)
                let isLastBuffer = (cycle == 1 && index == buffers.count - 1)
                let nextCursor = cursor + AVAudioFramePosition(buffer.frameLength)
                
                // ✅ UI 更新はタイマーで自動的に行われる（asyncAfter は使用しない）
                
                playerGtr.scheduleBuffer(buffer, at: when, options: []) { [weak self] in
                    guard let self = self, self.isPlaying else { return }
                    
                    // 最後のバッファ完了後に次の2周を再予約
                    if isLastBuffer {
                        self.logger.info("LOOP re-scheduled (2x bars)")
                        self.scheduleGuitarBuffers(
                            buffers,
                            countInFrames: nextCursor,
                            onBarChange: onBarChange
                        )
                    }
                }
                
                self.logger.info("GTR scheduled i=\(index) cycle=\(cycle) when.sampleTime=\(when.sampleTime)")
                cursor = nextCursor
            }
        }
        
        logger.info("✅ HybridPlayer: 2 cycles scheduled (\(buffers.count * 2) bars)")
    }
    
    /// UI 更新タイマーを開始（0.1秒ごとにチェック）
    private func startUIUpdateTimer(onBarChange: @escaping (Int) -> Void) {
        // カウントイン終了時（2秒後）に最初の i=0 を即座に表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            self.currentBarIndex = 0
            onBarChange(0)
            self.logger.info("🎯 UI updated (initial): i=0 at 2.0s")
        }
        
        uiUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying, let startTime = self.playbackStartTime else { return }
            
            // 再生開始からの経過時間を計算
            let elapsed = Date().timeIntervalSince(startTime)
            
            // カウントイン（2秒）を引いて、音楽開始からの経過時間を取得
            let musicElapsed = elapsed - 2.0
            
            if musicElapsed >= 0 {
                // 現在のバーインデックスを計算（1バー = 2秒）
                let barIndex = Int(musicElapsed / 2.0) % self.barCount
                
                // バーが変わったら UI を更新
                if barIndex != self.currentBarIndex {
                    self.currentBarIndex = barIndex
                    DispatchQueue.main.async {
                        onBarChange(barIndex)
                    }
                    self.logger.info("🎯 UI updated (timer): i=\(barIndex) at \(elapsed)s")
                }
            }
        }
    }
    
    /// カウントインバッファ生成（4拍、ハイハット風ノイズ音）
    private func generateCountInBuffer(bpm: Double) throws -> AVAudioPCMBuffer {
        // ✅ 44100Hz に固定（ギターバッファと一致させる）
        let sampleRate: Double = 44100.0
        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 2
        )!
        
        // 4拍分のフレーム数 (BPM 120 → 88200 frames)
        let framesPerBeat = AVAudioFrameCount(60.0 / bpm * sampleRate)
        let totalFrames = framesPerBeat * 4
        print("🔍 Count-in: bpm=\(bpm), sampleRate=\(sampleRate), framesPerBeat=\(framesPerBeat), totalFrames=\(totalFrames)")
        
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
        
        // 各拍にハイハット風のクリック音を生成（ホワイトノイズ + ハイパスフィルタ、30ms）
        let clickDuration = 0.03  // 30ms（短めでタイトな音）
        let clickFrames = AVAudioFrameCount(clickDuration * sampleRate)
        
        for beat in 0..<4 {
            let startFrame = Int(framesPerBeat) * beat
            
            // ハイハット風の音: ホワイトノイズ + エンベロープ
            for frame in 0..<Int(clickFrames) {
                let absoluteFrame = startFrame + frame
                
                // ホワイトノイズ生成
                let noise = Float.random(in: -1.0...1.0)
                
                // エンベロープ（指数減衰）
                let progress = Float(frame) / Float(clickFrames)
                let envelope = exp(-8.0 * progress)  // 急速に減衰
                
                // ハイパスフィルタ効果（高周波強調）
                let value = noise * envelope * 0.4  // 40%音量
                
                // ステレオ両チャンネルに書き込み
                buffer.floatChannelData?[0][absoluteFrame] = value
                buffer.floatChannelData?[1][absoluteFrame] = value
            }
        }
        
        print("✅ HybridPlayer: Count-in buffer generated (4 beats, hi-hat style, \(totalFrames) frames)")
        return buffer
    }
}


