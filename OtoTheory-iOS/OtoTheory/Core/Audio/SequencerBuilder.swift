import AVFoundation
import AudioToolbox

/// SequencerBuilder
/// Score からベース/ドラムのMusicSequenceを構築（Phase A: 雛形のみ）
final class SequencerBuilder {
    
    // MARK: - Public API
    
    /// ScoreからMusicSequenceを構築
    /// Phase A: テンポトラックのみ
    /// Phase B: ベース基本形（Root/5th）を追加
    /// Phase C: ドラムパターンを追加
    static func build(
        score: Score,
        includeBass: Bool = false,
        includeDrums: Bool = false
    ) throws -> MusicSequence {
        
        var musicSequence: MusicSequence?
        NewMusicSequence(&musicSequence)
        
        guard let sequence = musicSequence else {
            throw NSError(
                domain: "SequencerBuilder",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create MusicSequence"]
            )
        }
        
        // テンポトラック設定
        var tempoTrack: MusicTrack?
        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        
        if let track = tempoTrack {
            MusicTrackNewExtendedTempoEvent(track, 0.0, score.bpm)
        }
        
        // Phase B: ベース実装
        if includeBass {
            try addBassTrack(to: sequence, score: score)
        }
        
        if includeDrums {
            // TODO: Phase C でドラムトラックを追加
            print("⚠️ SequencerBuilder: Drum track not yet implemented (Phase C)")
        }
        
        print("✅ SequencerBuilder: sequence built (tempo=\(score.bpm)BPM)")
        
        return sequence
    }
    
    // MARK: - Private Helpers (Phase B/C で実装)
    
    /// ベーストラック追加（Phase B）
    private static func addBassTrack(
        to sequence: MusicSequence,
        score: Score
    ) throws {
        var track: MusicTrack?
        MusicSequenceNewTrack(sequence, &track)
        
        guard let bassTrack = track else {
            throw NSError(
                domain: "SequencerBuilder",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create bass track"]
            )
        }
        
        for (barIndex, bar) in score.bars.enumerated() {
            let bassNote = chordToBassRoot(bar.chord)
            let beatTime = MusicTimeStamp(barIndex * 4)  // 小節頭（4拍/小節）
            
            // Root on beat 1（1拍目）
            var rootNote = MIDINoteMessage(
                channel: 0,
                note: bassNote,
                velocity: 80,
                releaseVelocity: 0,
                duration: 1.0  // 1拍分
            )
            MusicTrackNewMIDINoteEvent(bassTrack, beatTime, &rootNote)
            
            // 5th on beat 3（3拍目）
            var fifthNote = MIDINoteMessage(
                channel: 0,
                note: bassNote + 7,  // 完全5度上
                velocity: 80,
                releaseVelocity: 0,
                duration: 1.0
            )
            MusicTrackNewMIDINoteEvent(bassTrack, beatTime + 2.0, &fifthNote)
        }
        
        print("✅ SequencerBuilder: Bass track added (\(score.bars.count) bars)")
    }
    
    /// コードシンボルからベースルート音を抽出（C3 = 48 ベース）
    private static func chordToBassRoot(_ chord: String) -> UInt8 {
        // ルート音抽出
        let rootMatch = chord.range(of: "^[A-G][#b]?", options: .regularExpression)
        guard let rootRange = rootMatch else { return 48 }  // デフォルトC3
        
        let rootStr = String(chord[rootRange])
        let rootPc = noteNameToPitchClass(rootStr)
        
        // ベース音域（C2=36 ～ B2=47、オクターブ下）
        return UInt8(36 + rootPc)
    }
    
    /// 音名からピッチクラス（0-11）を取得
    private static func noteNameToPitchClass(_ name: String) -> Int {
        let baseNotes: [String: Int] = [
            "C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11
        ]
        
        var pc = baseNotes[String(name.prefix(1))] ?? 0
        if name.contains("#") { pc += 1 }
        if name.contains("b") { pc -= 1 }
        return (pc + 12) % 12
    }
    
    /// ドラムトラック追加（Phase C）
    private static func addDrumTrack(
        to sequence: MusicSequence,
        score: Score,
        pattern: DrumPattern = .basic
    ) throws {
        // TODO: Phase C
        // 1. MusicSequenceNewTrack でトラック作成（ch=10）
        // 2. 16ステップパターンを各小節に配置
        //    - Kick=36, Snare=38, HiHat=42/46
        // 3. destination を samplerDrum.audioUnit にバインド
    }
    
    enum DrumPattern {
        case basic
        case rock
        case pop
        case funk
    }
}

