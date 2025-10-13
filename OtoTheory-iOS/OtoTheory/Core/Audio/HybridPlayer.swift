import AVFoundation
import AudioToolbox
import os.log

/// HybridPlayer
/// ギター+ベースPCM（AVAudioPlayerNode）+ ドラムMIDI（AVAudioSequencer）を統合再生
/// Phase C-2.5: ベースも PCM バッファとして事前レンダリングし、完璧な同期を実現
final class HybridPlayer {
    
    // MARK: - Audio Components
    
    let engine = AVAudioEngine()
    let playerGtr = AVAudioPlayerNode()    // ギター PCM
    let playerBass = AVAudioPlayerNode()   // ベース PCM（Phase C-2.5 で追加）
    let playerDrum = AVAudioPlayerNode()   // ドラム PCM（Phase C-3 で追加）
    let samplerDrum = AVAudioUnitSampler() // ドラム MIDI（廃止予定）
    var sequencer: AVAudioSequencer!       // ドラム用（廃止予定）
    
    private var isPlaying = false
    private var currentBarIndex = 0
    private var playbackStartTime: Date?  // 再生開始時刻（UI タイミング計算用）
    private var uiUpdateTimer: Timer?  // UI 更新タイマー
    private var barCount: Int = 0  // バー数
    private var currentScore: Score?  // 現在再生中のスコア（スロットインデックス取得用）
    
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
        engine.attach(playerBass)  // ベース PCM 用
        engine.attach(playerDrum)  // ドラム PCM 用（Phase C-3）
        engine.attach(samplerDrum)  // 廃止予定
        
        // mainMixerNodeへ接続
        let format = AVAudioFormat(
            standardFormatWithSampleRate: 44100.0,
            channels: 2
        )!
        
        engine.connect(playerGtr, to: engine.mainMixerNode, format: format)
        engine.connect(playerBass, to: engine.mainMixerNode, format: format)  // ベース PCM 接続
        engine.connect(playerDrum, to: engine.mainMixerNode, format: format)  // ドラム PCM 接続（Phase C-3）
        engine.connect(samplerDrum, to: engine.mainMixerNode, format: format)  // 廃止予定
        
        // Sequencer初期化（廃止予定）
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
        
        // ✅ Phase C-2.5: ベースは PCM バッファとして事前レンダリングするため、
        // Sampler ロードは不要（削除）
        print("ℹ️ HybridPlayer.prepare: Bass will be rendered as PCM (no Sampler needed)")
        
        // ✅ Phase C-3: ドラムも PCM バッファとして事前レンダリング
        print("ℹ️ HybridPlayer.prepare: Drum will be rendered as PCM (no Sampler needed)")
        
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
        
        // ✅ Phase C-2.5: ベースは PCM なので CC 初期化も不要
        print("ℹ️ HybridPlayer.prepare: Bass CC init skipped (PCM mode)")
        
        print("✅ HybridPlayer.prepare: complete")
    }
    
    /// 再生：ギター+ベース+ドラムPCMバッファ配列
    /// - Parameters:
    ///   - score: Score（BPM + bars）
    ///   - guitarBuffers: 各小節のギターPCMバッファ配列
    ///   - bassBuffers: 各小節のベースPCMバッファ配列（Phase C-2.5 で追加）
    ///   - drumBuffer: ドラムPCMバッファ（Phase C-3 で追加、全小節共通）
    ///   - onBarChange: 小節変更時のコールバック
    func play(
        score: Score,
        guitarBuffers: [AVAudioPCMBuffer],
        bassBuffers: [AVAudioPCMBuffer],
        drumBuffer: AVAudioPCMBuffer?,
        onBarChange: @escaping (Int) -> Void
    ) throws {
        logger.info("PATH = HybridPlayer (PCM)")
        audioTrace("PATH = HybridPlayer (PCM)")
        
        guard guitarBuffers.count == score.barCount && bassBuffers.count == score.barCount else {
            throw NSError(
                domain: "HybridPlayer",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Buffer count mismatch (guitar=\(guitarBuffers.count), bass=\(bassBuffers.count), expected=\(score.barCount))"]
            )
        }
        
        isPlaying = true
        currentBarIndex = 0
        barCount = score.barCount
        currentScore = score  // スコアを保存（スロットインデックス取得用）
        playbackStartTime = Date()  // 再生開始時刻を記録
        
        // UI 更新タイマーを開始（0.1秒ごとにチェック）
        startUIUpdateTimer(onBarChange: onBarChange)
        
        // ✅ Phase C-2.5: Sequencer は不要（ベースも PCM）
        // Sequencer は将来的にドラム用に使用
        
        // Phase B: カウントインバッファ生成（4拍）
        let countInBuffer = try generateCountInBuffer(bpm: score.bpm)
        
        // カウントインをスケジュール
        playerGtr.scheduleBuffer(countInBuffer) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            self.logger.info("COUNT-IN done")
            print("✅ Count-in completed")
        }
        
        // PlayerNodeにギター+ベース+ドラムPCMをスケジュール（絶対サンプル時刻で連結）
        let countInDuration = 60.0 / score.bpm * 4.0  // 4拍分
        let countInFrames = AVAudioFramePosition(countInDuration * 44100.0)
        scheduleGuitarBuffers(guitarBuffers, countInFrames: countInFrames, onBarChange: onBarChange)
        scheduleBassBuffers(bassBuffers, countInFrames: countInFrames)
        
        // ✅ Phase C-3: ドラムPCMをスケジュール（全小節共通のバッファをループ）
        if let drumBuffer = drumBuffer {
            scheduleDrumBuffer(drumBuffer, countInFrames: countInFrames, barCount: score.barCount)
        }
        
        // 同時スタート（0.2秒先に予約して同期精度向上）
        let startTime = AVAudioTime(
            hostTime: mach_absolute_time() + AVAudioTime.hostTime(forSeconds: 0.2)
        )
        logger.info("START at hostTime=\(startTime.hostTime)")
        
        playerGtr.play(at: startTime)
        playerBass.play(at: startTime)  // ✅ ベースも同時起動（完璧な同期）
        if drumBuffer != nil {
            playerDrum.play(at: startTime)  // ✅ ドラムも同時起動（Phase C-3）
        }
        
        print("✅ HybridPlayer: Guitar + Bass + Drum PCM playback started (perfectly synchronized)")
        
        print("✅ HybridPlayer: playback started (with count-in)")
    }
    
    /// 停止
    func stop() {
        isPlaying = false
        
        playerGtr.stop()
        playerBass.stop()  // ✅ ベース PCM も停止
        playerDrum.stop()  // ✅ ドラム PCM も停止（Phase C-3）
        sequencer.stop()   // 廃止予定
        
        // ✅ Phase C-3: Sampler は廃止予定（クリーンアップ不要）
        // for ch: UInt8 in 0...1 {
        //     samplerDrum.sendController(120, withValue: 0, onChannel: ch)  // All Sound Off
        //     samplerDrum.sendController(123, withValue: 0, onChannel: ch)  // All Notes Off
        // }
        
        currentBarIndex = 0
        currentScore = nil
        
        // UI 更新タイマーを停止
        uiUpdateTimer?.invalidate()
        uiUpdateTimer = nil
        
        print("✅ HybridPlayer: stopped")
    }
    
    // MARK: - Private Helpers
    
    /// Sequencer準備（Phase C-2.5: 現在は使用していない、将来のドラム用に保持）
    private func prepareSequencer(score: Score) throws {
        // ✅ Phase C-2.5: ベースは PCM に移行したため、この関数は現在未使用
        // 将来的にドラム実装時に再利用
        return  // Early return
        
        /* Commented out - will be re-enabled for drums in Phase C-4
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
        
        // ✅ 再生開始位置を設定
        sequencer.currentPositionInBeats = 0
        print("✅ HybridPlayer: sequencer position set to 0")
        
        // Bass トラックを samplerBass にバインド
        if sequencer.tracks.count > 1 {
            // Track 0 = テンポトラック
            // Track 1 = ベーストラック
            sequencer.tracks[1].destinationAudioUnit = samplerBass
            print("✅ HybridPlayer: Bass track bound to samplerBass")
        }
        
        print("✅ HybridPlayer: sequencer prepared (tempo=\(score.bpm)BPM, bass enabled)")
        */  // End of commented-out code
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
    
    /// ベースPCMバッファをPlayerNodeにスケジュール（絶対サンプル時刻で連結）
    /// ギターと完全に同期するため、同じタイミングロジックを使用
    private func scheduleBassBuffers(
        _ buffers: [AVAudioPCMBuffer],
        countInFrames: AVAudioFramePosition
    ) {
        let sampleRate: Double = 44100.0  // 固定（PCMバッファと一致）
        var cursor: AVAudioFramePosition = countInFrames
        
        // 2周分をスケジュール
        for cycle in 0..<2 {
            for (index, buffer) in buffers.enumerated() {
                let when = AVAudioTime(sampleTime: cursor, atRate: sampleRate)
                let isLastBuffer = (cycle == 1 && index == buffers.count - 1)
                let nextCursor = cursor + AVAudioFramePosition(buffer.frameLength)
                
                playerBass.scheduleBuffer(buffer, at: when, options: []) { [weak self] in
                    guard let self = self, self.isPlaying else { return }
                    
                    // 最後のバッファ完了後に次の2周を再予約
                    if isLastBuffer {
                        self.logger.info("BASS LOOP re-scheduled (2x bars)")
                        self.scheduleBassBuffers(
                            buffers,
                            countInFrames: nextCursor
                        )
                    }
                }
                
                self.logger.info("BASS scheduled i=\(index) cycle=\(cycle) when.sampleTime=\(when.sampleTime)")
                cursor = nextCursor
            }
        }
        
        logger.info("✅ HybridPlayer: Bass 2 cycles scheduled (\(buffers.count * 2) bars)")
    }
    
    /// ドラムPCMバッファをPlayerNodeにスケジュール（絶対サンプル時刻で連結）
    /// 全小節共通のバッファを小節数分繰り返しスケジュール
    /// - Parameters:
    ///   - buffer: 1小節分のドラムPCMバッファ
    ///   - countInFrames: カウントイン時間（フレーム数）
    ///   - barCount: 小節数
    private func scheduleDrumBuffer(
        _ buffer: AVAudioPCMBuffer,
        countInFrames: AVAudioFramePosition,
        barCount: Int
    ) {
        let sampleRate: Double = 44100.0  // 固定（PCMバッファと一致）
        var cursor: AVAudioFramePosition = countInFrames
        
        // 2周分をスケジュール（ギター・ベースと同じ）
        for cycle in 0..<2 {
            for bar in 0..<barCount {
                let when = AVAudioTime(sampleTime: cursor, atRate: sampleRate)
                let isLastBar = (cycle == 1 && bar == barCount - 1)
                let nextCursor = cursor + AVAudioFramePosition(buffer.frameLength)
                
                playerDrum.scheduleBuffer(buffer, at: when, options: []) { [weak self] in
                    guard let self = self, self.isPlaying else { return }
                    
                    // 最後のバッファ完了後に次の2周を再予約
                    if isLastBar {
                        self.logger.info("DRUM LOOP re-scheduled (2x bars)")
                        self.scheduleDrumBuffer(
                            buffer,
                            countInFrames: nextCursor,
                            barCount: barCount
                        )
                    }
                }
                
                self.logger.info("DRUM scheduled bar=\(bar) cycle=\(cycle) when.sampleTime=\(when.sampleTime)")
                cursor = nextCursor
            }
        }
        
        logger.info("✅ HybridPlayer: Drum 2 cycles scheduled (\(barCount * 2) bars)")
    }
    
    /// UI 更新タイマーを開始（0.1秒ごとにチェック）
    private func startUIUpdateTimer(onBarChange: @escaping (Int) -> Void) {
        // カウントイン終了時（2秒後）に最初の i=0 を即座に表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self, self.isPlaying, let score = self.currentScore else { return }
            self.currentBarIndex = 0
            let slotIndex = score.bars.isEmpty ? 0 : score.bars[0].slotIndex
            onBarChange(slotIndex)
            self.logger.info("🎯 UI updated (initial): barIndex=0, slotIndex=\(slotIndex) at 2.0s")
        }
        
        uiUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying, let startTime = self.playbackStartTime, let score = self.currentScore else { return }
            
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
                    let slotIndex = score.bars[barIndex].slotIndex
                    DispatchQueue.main.async {
                        onBarChange(slotIndex)
                    }
                    self.logger.info("🎯 UI updated (timer): barIndex=\(barIndex), slotIndex=\(slotIndex) at \(elapsed)s")
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


