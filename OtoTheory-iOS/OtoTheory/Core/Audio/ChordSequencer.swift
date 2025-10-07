import AVFoundation
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
    private let fadeMs: Double = 120       // 80–150ms（Release相当）
    private let maxVoices = 6
    
    private let sf2URL: URL
    
    // Playback state
    private var isPlaying = false
    private var playbackTask: Task<Void, Never>?
    private var currentBusIsA = true  // A/B交互切替用
    
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
        
        // 初期ボリューム
        subMixA.outputVolume = 1.0
        subMixB.outputVolume = 0.0  // Bは最初ミュート
        
        audioTrace("Graph ready — samplerA→subMixA, samplerB→subMixB, main connected")
        audioTrace("Conn samplerA→ \(engine.outputConnectionPoints(for: samplerA, outputBus: 0).map{ $0.node }.description)")
        audioTrace("Conn samplerB→ \(engine.outputConnectionPoints(for: samplerB, outputBus: 0).map{ $0.node }.description)")
        logger.info("[Graph] post-connect  A->main[0], B->main[1]  (A.out=\(self.subMixA.outputVolume, privacy: .public)  B.out=\(self.subMixB.outputVolume, privacy: .public))")
        
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
        dumpGraph("post-connect")
        dumpConnections(engine)
        dumpMainInputs()
        logger.info("🔎 [OSLOG] Graph dump completed")
        
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
            let strumDelay = strumMs / 1000.0
            
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
            
            // 最初のコードはA
            currentBusIsA = true
            subMixA.outputVolume = 1.0
            subMixB.outputVolume = 0.0
            
            // 基準時刻（単調クロック）
            let t0 = CACurrentMediaTime()
            var barIndex = 0
            
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
                    
                    // 今回使うサンプラーとノード
                    let nextSampler = currentBusIsA ? samplerA : samplerB
                    let nextSub = currentBusIsA ? subMixA : subMixB
                    let prevSampler = currentBusIsA ? samplerB : samplerA
                    let prevSub = currentBusIsA ? subMixB : subMixA
                    
                    // c) 小節頭：並行で仕込む（flush → 0→1フェード → 発音）
                    dumpAB("bar-head (before xfade)")
                    dumpAndNudgeGains(tag: "bar-head before xfade")
                    audioTrace("NEXT bus:\(currentBusIsA ? "A" : "B")  PREV bus:\(currentBusIsA ? "B" : "A")")
                    
                    // [TEST] 強制ミュート試験
                    subMixA.outputVolume = 0.0; subMixB.outputVolume = 0.0
                    audioTrace(String(format:"[TEST] forced mute A,B → A:%.2f B:%.2f", subMixA.outputVolume, subMixB.outputVolume))
                    
                    // 再利用する側を掃除（flush）
                    flushSampler(nextSampler)
                    
                    // to側は必ず0から
                    nextSub.outputVolume = 0.0
                    
                    // 対称フェード開始（並行）
                    audioTrace("Symmetric cross-fade start: 120ms  from:\(currentBusIsA ? "B" : "A") to:\(currentBusIsA ? "A" : "B")")
                    crossFadeSym(from: prevSub, to: nextSub, ms: fadeMs)
                    
                    // ストラムは"待たずに"非同期で予約（小節内で時間を消費しない）
                    audioTrace("Playing chord: \(symbol) bus:\(currentBusIsA ? "A" : "B")")
                    audioTrace("Playing chord: \(symbol)  notes:\(midiChord)  bus:\(currentBusIsA ? "A" : "B")")
                    let playedNotes = Array(midiChord.prefix(maxVoices))  // Phase B-Lite: ノートを保存
                    for (i, note) in playedNotes.enumerated() {
                        let d = (Double(i) * strumMs / 1000.0)
                        xfadeQ.asyncAfter(deadline: .now() + d) { [weak nextSampler] in
                            nextSampler?.startNote(note, withVelocity: 80, onChannel: 0)
                        }
                    }
                    
                    // Phase B-Lite: Note Duration を制限（60% = 1.2秒）
                    // SF2 の Release が長いため、さらに短くする
                    let noteDuration = barSec * 0.6
                    print("🎵 Phase B-Lite: Note Duration = \(noteDuration)s (60% of \(barSec)s)")
                    xfadeQ.asyncAfter(deadline: .now() + noteDuration) { [weak nextSampler] in
                        print("⏹️ Phase B-Lite: Stopping notes after \(noteDuration)s")
                        // 明示的に Note Off
                        for note in playedNotes {
                            nextSampler?.stopNote(note, onChannel: 0)
                        }
                        // CC120: All Sound Off
                        nextSampler?.sendController(120, withValue: 0, onChannel: 0)
                        nextSampler?.sendController(123, withValue: 0, onChannel: 0)
                        print("✅ Phase B-Lite: Notes stopped, CC120/123 sent")
                    }
                    
                    // フェード完了 +10ms で旧サンプラーを kill（1回だけ）
                    xfadeQ.asyncAfter(deadline: .now() + (fadeMs/1000.0) + 0.010) { [weak self] in
                        self?.hardKillSampler(prevSampler)
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
        
        // ボリュームをリセット
        subMixA.outputVolume = 1.0
        subMixB.outputVolume = 0.0
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
    
    /// 対称クロスフェード（from: 1→0, to: 0→1）
    private func crossFadeSym(from: AVAudioMixerNode, to: AVAudioMixerNode, ms: Double) {
        xfadeTimer?.cancel()
        let steps = 30
        let dt = (ms / 1000.0) / Double(steps)

        let fromStart = max(0, min(1, from.outputVolume))
        from.outputVolume = fromStart
        to.outputVolume   = 0.0                        // to側は必ず0から

        var i = 0
        let t = DispatchSource.makeTimerSource(queue: xfadeQ)
        t.schedule(deadline: .now(), repeating: dt, leeway: .milliseconds(1))
        t.setEventHandler { [weak from, weak to] in
            i += 1
            let p = min(1.0, Float(i)/Float(steps))
            from?.outputVolume = fromStart * (1.0 - p) // 1→0
            to?.outputVolume   = p                     // 0→1
            if i >= steps { t.cancel() }
        }
        xfadeTimer = t
        t.resume()
    }
    
    // MARK: - Chord to MIDI
    
    private func chordToMidi(_ symbol: String) -> [UInt8] {
        let parts = symbol.split(separator: "/")
        let mainChord = String(parts[0])
        
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
        
        return intervals.map { root + UInt8($0) }
    }
    
    // ★ 追加：バー頭でのゲインを1行で出す（A/Bの数値）
    private func dumpAB(_ tag: String) {
        let a = String(format: "%.2f", subMixA.volume)
        let b = String(format: "%.2f", subMixB.volume)
        let ms = Int(CACurrentMediaTime() * 1000) % 100_000
        print("[\(ms)ms] [Gain] \(tag)  A:\(a)  B:\(b)")
    }
    
    private func dumpAndNudgeGains(tag: String) {
        let oa = subMixA.outputVolume
        let ob = subMixB.outputVolume
        let va = subMixA.volume
        let vb = subMixB.volume
        let da = subMixA.destination(forMixer: engine.mainMixerNode, bus: 0)?.volume ?? -1
        let db = subMixB.destination(forMixer: engine.mainMixerNode, bus: 0)?.volume ?? -1
        print("🔎 [\(tag)] A: out=\(String(format:"%.2f",oa)) vol=\(String(format:"%.2f",va)) dest=\(String(format:"%.2f",da)) | B: out=\(String(format:"%.2f",ob)) vol=\(String(format:"%.2f",vb)) dest=\(String(format:"%.2f",db))")

        // --- ここが「効くノブ」を一撃で見つける肝 ---
        // 300msだけ全ミュート→自動で戻す
        if let dA = subMixA.destination(forMixer: engine.mainMixerNode, bus: 0),
           let dB = subMixB.destination(forMixer: engine.mainMixerNode, bus: 0) {
            dA.volume = 0.0
            dB.volume = 0.0
            print("🧪 [\(tag)] set dest volumes to 0.0 (muting 300ms)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                dA.volume = 1.0
                dB.volume = 1.0
                print("🧪 [\(tag)] restore dest volumes to 1.0")
            }
        } else {
            // フォールバック：nodeのout/volumeも0→1にしてみる
            subMixA.outputVolume = 0.0; subMixB.outputVolume = 0.0
            subMixA.volume = 0.0;       subMixB.volume = 0.0
            print("🧪 [\(tag)] set node out/vol to 0.0 (muting 300ms)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                self.subMixA.outputVolume = 1.0; self.subMixB.outputVolume = 1.0
                self.subMixA.volume = 1.0;       self.subMixB.volume = 1.0
                print("🧪 [\(tag)] restore node out/vol to 1.0")
            }
        }
    }
    
    private func dumpMainInputs() {
        func name(_ n: AVAudioNode?) -> String {
            guard let n = n else { return "nil" }
            return String(describing: type(of: n))
        }
        let main = engine.mainMixerNode
        logger.info("🔎 [OSLOG] dumpMainInputs - checking \(main.numberOfInputs) buses")
        for bus in 0..<max(2, main.numberOfInputs) { // 0/1だけでOK
            if let point = engine.inputConnectionPoint(for: main, inputBus: bus) {
                let nodeName = name(point.node)
                logger.info("🔌 [OSLOG] Main in \(bus): \(nodeName) → main[\(bus)] (src bus:\(point.bus))")
                print("🔌 [Main in \(bus)] 1 source")
                print("   - \(nodeName) → main[\(bus)] (src bus:\(point.bus))")
            }
        }
    }
    
    func dumpConnections(_ engine: AVAudioEngine) {
        func name(_ n: AVAudioNode?) -> String {
            guard let n = n else { return "nil" }
            switch n {
            case is AVAudioMixerNode: return "MainMixer"
            case is AVAudioUnitSampler: return "Sampler"
            case is AVAudioPlayerNode: return "Player"
            default: return String(describing: type(of: n))
            }
        }
        func show(_ from: AVAudioNode) {
            let outs = engine.outputConnectionPoints(for: from, outputBus: 0)
            for cp in outs {
                print("🔌 \(from) -> \(name(cp.node)) bus:\(cp.bus)")
            }
        }
        print("🔎 [Dump] after connect")
        show(samplerA)
        show(samplerB)
        show(subMixA)
        show(subMixB)
        // MainMixer への入力側も確認
        for b in 0..<engine.mainMixerNode.numberOfInputs {
            if let src = engine.inputConnectionPoint(for: engine.mainMixerNode, inputBus: b) {
                print("↪️ MainMixer bus:\(b) <- \(name(src.node))")
            }
        }
    }
    
    private func dumpGraph(_ tag: String) {
        func name(_ n: AVAudioNode) -> String {
            switch n {
            case is AVAudioUnitSampler: return "AUSampler"
            case is AVAudioMixerNode:   return "Mixer"
            default: return String(describing: type(of: n))
            }
        }
        print("🔎 [Graph] \(tag)")
        for (label, node) in [("samplerA", samplerA as AVAudioNode),
                              ("samplerB", samplerB as AVAudioNode),
                              ("subMixA",  subMixA  as AVAudioNode),
                              ("subMixB",  subMixB  as AVAudioNode),
                              ("main",     engine.mainMixerNode as AVAudioNode)] {
            let outs = engine.outputConnectionPoints(for: node, outputBus: 0)
            if outs.isEmpty {
                print(" - \(label) (\(name(node))) → (no outputs)")
            } else {
                for o in outs {
                    if let destNode = o.node {
                        print(" - \(label) → \(name(destNode)) bus:\(o.bus)")
                    }
                }
            }
        }
    }
}
