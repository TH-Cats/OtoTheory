@preconcurrency import AVFoundation
import AudioToolbox
import os.log

@MainActor
final class ChordSequencer: ObservableObject {
    private let logger = Logger(subsystem: "com.nh.OtoTheory", category: "ChordSequencer")
    let engine = AVAudioEngine()
    
    // 2バス・フェードアウト方式（A/B交互）
    let samplerA = AVAudioUnitSampler()
    let samplerB = AVAudioUnitSampler()
    let subMixA = AVAudioMixerNode()
    let subMixB = AVAudioMixerNode()
    
    // クロスフェード専用キュー
    private let xfadeQ = DispatchQueue(label: "audio.xfade", qos: .userInteractive)
    private var xfadeTimer: DispatchSourceTimer?
    
    // SSOT準拠：軽ストラム/Release
    private let strumMs: Double = 15       // 10–20ms
    private let fadeMs: Double = 80        // 80ms（10ms × 8ステップ）
    private let maxVoices = 6
    
    private let sf2URL: URL
    
    // Playback state
    private var isPlaying = false
    private var playbackTask: Task<Void, Never>?
    private var currentBusIsA = true  // A/B交互切替用
    
    // destination を保持（正しいフェーダー制御）
    private var destA: AVAudioMixingDestination!
    private var destB: AVAudioMixingDestination!
    
    init(sf2URL: URL) throws {
        self.sf2URL = sf2URL
        
        // エンジンにノードをアタッチ
        engine.attach(samplerA)
        engine.attach(samplerB)
        engine.attach(subMixA)
        engine.attach(subMixB)
        
        // 配線: Sampler → SubMix → MainMixer
        engine.connect(samplerA, to: subMixA, format: nil)
        engine.connect(samplerB, to: subMixB, format: nil)
        engine.connect(subMixA, to: engine.mainMixerNode, format: nil)
        engine.connect(subMixB, to: engine.mainMixerNode, format: nil)
        
        // destination を取得・保持（一度だけ、接続完了後）
        guard let destA = subMixA.destination(forMixer: engine.mainMixerNode, bus: 0),
              let destB = subMixB.destination(forMixer: engine.mainMixerNode, bus: 1) else {
            throw NSError(domain: "ChordSequencer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get destination"])
        }
        self.destA = destA
        self.destB = destB
        
        // 初期ボリューム（destination.volume のみ使用）
        destA.volume = 1.0
        destB.volume = 0.0  // Bは最初ミュート
        
        audioTrace("Graph ready — samplerA→subMixA, samplerB→subMixB, main connected")
        audioTrace("Conn samplerA→ \(engine.outputConnectionPoints(for: samplerA, outputBus: 0).map{ $0.node }.description)")
        audioTrace("Conn samplerB→ \(engine.outputConnectionPoints(for: samplerB, outputBus: 0).map{ $0.node }.description)")
        logger.info("[Graph] post-connect  A->main[0], B->main[1]")
        
        // 両方のサンプラーに同じSF2をロード
        for sampler in [samplerA, samplerB] {
            try sampler.loadSoundBankInstrument(
                at: sf2URL,
                program: 25,  // Acoustic Steel (デフォルト)
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
            
            // CC Reset（全チャンネル）
            for ch: UInt8 in 0...15 {
                sampler.sendController(64, withValue: 0, onChannel: ch)  // Sustain OFF
                sampler.sendController(91, withValue: 0, onChannel: ch)  // Reverb 0
                sampler.sendController(93, withValue: 0, onChannel: ch)  // Chorus 0
                sampler.sendController(7, withValue: 100, onChannel: ch)  // Volume 100
            }
        }
        
        // Audio Session を短いバッファに設定（レイテンシ削減）
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setPreferredSampleRate(44100)
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.01)  // 10ms（シミュレーター対応）
            print("✅ Audio Session: Category=.playback, SampleRate=44100, IOBufferDuration=10ms")
        } catch {
            print("⚠️ Failed to set Audio Session: \(error)")
        }
        
        // エンジン起動
        try engine.start()
        
        logger.info("🔎 [OSLOG] ChordSequencer initialized - engine started")
        
        print("✅ ChordSequencer initialized (2-Bus Fade-out method)")
    }
    
    // MARK: - Public Methods
    
    /// コード進行を再生（2バス・フェードアウト方式）
    func play(chords: [String], program: UInt8, bpm: Double, onBarChange: @escaping (Int?) -> Void) {
        audioTrace("Playback started (ChordSequencer)")
        logger.info("🔎 [OSLOG] PATH = ChordSequencer (fallback)")
        guard !isPlaying else { return }
        isPlaying = true
        
        // 音色をロード（両方のサンプラー）
        changeInstrument(program)
        
        // 再生タスク
        playbackTask = Task { @MainActor in
            let beatSec = 60.0 / bpm
            let barSec = beatSec * 4
            let _ = strumMs / 1000.0
            
            print("🎵 Starting playback (2-Bus Fade): BPM=\(bpm), fadeMs=\(fadeMs)")
            
            // カウントイン（高音4回）- サンプラーAで
            onBarChange(nil)  // カウント中
            for i in 0..<4 {
                samplerA.startNote(84, withVelocity: 127, onChannel: 0)  // C7
                try? await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
                samplerA.stopNote(84, onChannel: 0)
                
                if i < 3 {
                    try? await Task.sleep(nanoseconds: UInt64((beatSec - 0.1) * 1_000_000_000))
                } else {
                    try? await Task.sleep(nanoseconds: UInt64((beatSec - 0.1) * 1_000_000_000))
                }
                
                if !isPlaying { return }
            }
            
            // 最初のコードはA（destination版 - 保持済みのプロパティを使用）
            currentBusIsA = true
            destA.volume = 1.0
            destB.volume = 0.0
            
            // タイマーをクリア（2回目の再生対策）
            xfadeTimer?.cancel()
            xfadeTimer = nil
            
            // 基準時刻（単調クロック）
            let t0 = CACurrentMediaTime()
            var barIndex = 0
            
            // strumDelay は使用しないため削除（警告対策）
            // let strumDelay = strumMs / 1000.0
            
            // コード進行（ループ）
            while isPlaying {
                for (bar, symbol) in chords.enumerated() {
                    if !isPlaying { break }
                    
                    // a) この小節の開始・終了目標（t0 からの相対）
                    let start = t0 + Double(barIndex) * barSec
                    let end   = start + barSec
                    
                    // b) 開始目標までの残りだけ待つ（余分は加えない）
                    let waitToStart = max(0, start - CACurrentMediaTime())
                    try? await Task.sleep(nanoseconds: UInt64(waitToStart * 1_000_000_000))
                    
                    onBarChange(bar)
                    let midiChord = chordToMidi(symbol)
                    
                    // ① 小節頭で参照を確定（キャプチャ）- currentBusIsA を確定して以降は触らない
                    let useA = currentBusIsA
                    let nextSampler = useA ? samplerA : samplerB
                    let prevSampler = useA ? samplerB : samplerA
                    let nextDest = useA ? destA! : destB!  // 保持済みの destination を使用（非オプショナル）
                    let prevDest = useA ? destB! : destA!  // 保持済みの destination を使用（非オプショナル）
                    
                    // ログ：確定値を出す
                    audioTrace(String(format: "[Bar %d] next=%.2f prev=%.2f", bar, nextDest.volume, prevDest.volume))
                    
                    // ② 新バスは即時1.0（1拍目が軽くならない）
                    nextDest.volume = 1.0
                    audioTrace(String(format: "destNext.volume = %.2f (full gain)", nextDest.volume))
                    
                    // 発音（ストラム）- 即座に開始
                    audioTrace("Playing chord: \(symbol) bus:\(useA ? "A" : "B") (4 beats)")
                    let playedNotes = Array(midiChord.prefix(maxVoices))
                    
                    // 4) 4拍分のストラムを予約（直列キュー）
                    for beat in 0..<4 {
                        let beatDelay = Double(beat) * beatSec
                        
                        // 各拍でストラム（診断ログ付き）
                        for (i, note) in playedNotes.enumerated() {
                            let d = beatDelay + (Double(i) * strumMs / 1000.0)
                            xfadeQ.asyncAfter(deadline: .now() + d) { @MainActor [weak self, weak nextSampler, bar] in
                                if beat == 0 && i == 0 {
                                    self?.audioTrace("startNote: first note of bar \(bar)")
                                }
                                nextSampler?.startNote(note, withVelocity: 80, onChannel: 0)
                            }
                        }
                        
                        // 各拍の音を短く切る（全て同じ長さ）
                        let noteDuration = beatSec * 0.85  // 拍の85%で切る
                        xfadeQ.asyncAfter(deadline: .now() + beatDelay + noteDuration) { @MainActor [weak nextSampler] in
                            for note in playedNotes {
                                nextSampler?.stopNote(note, onChannel: 0)
                            }
                        }
                    }
                    
                    // ③ 旧バスのフェードアウトは「小節の最後にだけ」実行（キャプチャした prevDest を使用）
                    let fadeStartSec = barSec - (fadeMs / 1000.0)  // 2.0 - 0.08 = 1.92s
                    xfadeQ.asyncAfter(deadline: .now() + fadeStartSec) { @MainActor [weak self, prevDest, prevSampler] in
                        guard let self = self else { return }
                        audioTrace("Fade-out start: 80ms (prevDest)")
                        
                        // fadeOutDestination を使用（片側フェードアウトのみ）
                        self.fadeOutDestination(prevDest, ms: self.fadeMs)
                        
                        // フェード完了後に CC64 を送る（Sustain Off のみ、reset は呼ばない）
                        let ccDelay = (self.fadeMs / 1000.0) + 0.010
                        self.xfadeQ.asyncAfter(deadline: .now() + ccDelay) { @MainActor [weak self] in
                            guard let self = self else { return }
                            for ch: UInt8 in 0...1 {
                                prevSampler.sendController(64, withValue: 0, onChannel: ch)
                            }
                            self.audioTrace("CC64 sent (Sustain Off only, no reset)")
                        }
                    }
                    
                    // d) 小節終了目標まで"残りだけ"待つ（2.000sに揃う）
                    let waitToEnd = max(0, end - CACurrentMediaTime())
                    try? await Task.sleep(nanoseconds: UInt64(waitToEnd * 1_000_000_000))
                    
                    // e) 次へ
                    currentBusIsA.toggle()
                    barIndex += 1
                }
            }
            
            onBarChange(nil)
        }
    }
    
    func stop() {
        isPlaying = false
        playbackTask?.cancel()
        playbackTask = nil
        xfadeTimer?.cancel()
        
        // 両方のサンプラーを停止
        for sampler in [samplerA, samplerB] {
            flushSampler(sampler)
        }
        
        // ✅ 最終停止時のみ reset() を実行（再生中は呼ばない）
        for sampler in [samplerA, samplerB] {
            sampler.auAudioUnit.reset()
        }
        
        // ボリュームをリセット（destination版）
        if let destA = subMixA.destination(forMixer: engine.mainMixerNode, bus: 0),
           let destB = subMixB.destination(forMixer: engine.mainMixerNode, bus: 1) {
            destA.volume = 1.0
            destB.volume = 0.0
        }
        currentBusIsA = true
        
        print("⏹️ Playback stopped")
    }
    
    func changeInstrument(_ program: UInt8) {
        print("🎵 Changing instrument to program: \(program)")
        
        // 両方のサンプラーに音色をロード
        for sampler in [samplerA, samplerB] {
            do {
                try sampler.loadSoundBankInstrument(
                    at: sf2URL,
                    program: program,
                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                    bankLSB: UInt8(kAUSampler_DefaultBankLSB)
                )
                
                // CC Reset
                for ch: UInt8 in 0...1 {
                    sampler.sendController(64, withValue: 0, onChannel: ch)  // Sustain OFF
                    sampler.sendController(91, withValue: 0, onChannel: ch)  // Reverb 0
                    sampler.sendController(93, withValue: 0, onChannel: ch)  // Chorus 0
                }
            } catch {
                print("❌ Failed to change instrument: \(error)")
            }
        }
        
        print("✅ Instrument changed to program \(program)")
    }
    
    // MARK: - Sampler Flush & Symmetric Cross Fade
    
    /// デバッグ用トレース（時刻ミリ秒付き）
    private func audioTrace(_ msg: String) {
        let ms = Int(CACurrentMediaTime() * 1000) % 100_000
        print("[\(ms)ms] \(msg)")
    }
    
    /// サンプラーを完全消音（再利用前の掃除）
    private func flushSampler(_ sampler: AVAudioUnitSampler) {
        for ch: UInt8 in 0...1 {
            sampler.sendController(64, withValue: 0, onChannel: ch)   // Sustain OFF
            sampler.sendController(120, withValue: 0, onChannel: ch)  // All Sound Off
            sampler.sendController(123, withValue: 0, onChannel: ch)  // All Notes Off
        }
        audioTrace("Sampler flushed (CC120 + CC123)")
    }
    
    /// 120msフェードが終わってから"確実に"過去の声を消す
    private func hardKillSampler(_ sampler: AVAudioUnitSampler) {
        for ch: UInt8 in 0...1 {
            sampler.sendController(64, withValue: 0, onChannel: ch)   // Sustain OFF
            sampler.sendController(123, withValue: 0, onChannel: ch)  // All Notes Off
            sampler.sendController(120, withValue: 0, onChannel: ch)  // All Sound Off
        }
        sampler.auAudioUnit.reset()  // ← これが決め手
        audioTrace("Sampler hard-kill (CCs + AU reset)")
    }
    
    /// 直列キューで線形フェード（別タイマーを作らない、6段階・20ms刻み）
    /// フェードアウト専用（片側のみ、新側は即 1.0）
    private func fadeOutDestination(_ dest: AVAudioMixingDestination, ms: Double) {
        let steps = 4          // 20ms × 4 = 80ms（バッファ10ms環境で競合しづらい）
        let interval = ms / Double(steps) / 1000.0
        
        let start = dest.volume
        var i = 0
        let timer = DispatchSource.makeTimerSource(queue: xfadeQ)
        timer.setEventHandler { [weak self] in
            i += 1
            let t = Float(i) / Float(steps)
            dest.volume = max(0, start * (1 - t))
            if i >= steps {
                timer.cancel()
                if let self = self {
                    audioTrace(String(format: "Fade complete: dest.volume = %.2f", dest.volume))
                }
            }
        }
        timer.schedule(deadline: .now(), repeating: interval)
        timer.resume()
    }
    
    
    // MARK: - Chord to MIDI
    
    private func chordToMidi(_ symbol: String) -> [UInt8] {
        // ✅ スラッシュコードのベース音を抽出
        let bassNote: UInt8?
        let mainChord: String
        
        if symbol.contains("/") {
            let parts = symbol.split(separator: "/")
            mainChord = String(parts[0])
            if parts.count > 1 {
                let bassStr = String(parts[1]).trimmingCharacters(in: .whitespaces)
                let rootMap: [String: UInt8] = [
                    "C": 60, "C#": 61, "Db": 61,
                    "D": 62, "D#": 63, "Eb": 63,
                    "E": 64,
                    "F": 65, "F#": 66, "Gb": 66,
                    "G": 67, "G#": 68, "Ab": 68,
                    "A": 69, "A#": 70, "Bb": 70,
                    "B": 71
                ]
                bassNote = rootMap[String(bassStr.prefix(2))] ?? rootMap[String(bassStr.prefix(1))]
            } else {
                bassNote = nil
            }
        } else {
            mainChord = symbol
            bassNote = nil
        }
        
        // Root note
        let rootMap: [String: UInt8] = [
            "C": 60, "C#": 61, "Db": 61,
            "D": 62, "D#": 63, "Eb": 63,
            "E": 64,
            "F": 65, "F#": 66, "Gb": 66,
            "G": 67, "G#": 68, "Ab": 68,
            "A": 69, "A#": 70, "Bb": 70,
            "B": 71
        ]
        
        var root: UInt8 = 60
        for (key, val) in rootMap {
            if mainChord.hasPrefix(key) {
                root = val
                break
            }
        }
        
        // Quality
        var intervals: [Int] = [0, 4, 7]  // Major triad
        
        if mainChord.contains("m7") {
            intervals = [0, 3, 7, 10]
        } else if mainChord.contains("maj7") || mainChord.contains("M7") {
            intervals = [0, 4, 7, 11]
        } else if mainChord.contains("7") {
            intervals = [0, 4, 7, 10]
        } else if mainChord.contains("m") {
            intervals = [0, 3, 7]
        } else if mainChord.contains("dim") {
            intervals = [0, 3, 6]
        } else if mainChord.contains("aug") {
            intervals = [0, 4, 8]
        } else if mainChord.contains("sus4") {
            intervals = [0, 5, 7]
        }
        
        var result = intervals.map { root + UInt8($0) }
        
        // スラッシュコードの場合はベース音を最低音として追加
        if let bass = bassNote, bass != root {
            result.insert(bass, at: 0)
        }
        
        return result
    }
    
}
