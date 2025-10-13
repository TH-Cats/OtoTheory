import Foundation

/// SSOT: スコア（曲全体）
/// BPM と 小節配列を保持
struct Score {
    var bpm: Double
    var bars: [Bar]
    
    init(bpm: Double = 120.0, bars: [Bar] = []) {
        self.bpm = bpm
        self.bars = bars
    }
    
    /// 既存のslotsから Score を生成
    static func from(slots: [String?], bpm: Double = 120.0) -> Score {
        let bars: [Bar] = slots.enumerated().compactMap { (index, chord) -> Bar? in
            guard let chord = chord, !chord.isEmpty else { return nil }
            return Bar(chord: chord, slotIndex: index)
        }
        return Score(bpm: bpm, bars: bars)
    }
    
    /// 小節数
    var barCount: Int {
        bars.count
    }
    
    /// 総秒数（BPM120なら1小節=2.0秒）
    var totalDuration: Double {
        let secondsPerBar = 60.0 / bpm * 4.0  // 4拍/小節
        return secondsPerBar * Double(barCount)
    }
}

/// SSOT: 小節（1小節分）
/// コードシンボルと元のスロットインデックスを保持
struct Bar {
    var chord: String  // "C", "Am7", "G/B" など
    var slotIndex: Int  // 元のスロットインデックス（UI更新用）
    
    init(chord: String, slotIndex: Int = 0) {
        self.chord = chord
        self.slotIndex = slotIndex
    }
}

