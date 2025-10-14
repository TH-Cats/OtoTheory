import Foundation

struct Preset: Identifiable {
    let id: String
    let name: String
    let romanNumerals: [String]
    let category: PresetCategory
    let description: String
    let isFree: Bool  // true = Free (first 20), false = Pro only
}

enum PresetCategory: String, CaseIterable {
    case pop = "Pop"
    case rock = "Rock"
    case jazz = "Jazz"
    case blues = "Blues"
    case ballad = "Ballad"
    case rnb = "R&B / Soul"
    case acoustic = "Acoustic"
}

// MARK: - Preset Library

extension Preset {
    static let all: [Preset] = [
        // ======== FREE (20 presets) ========
        
        // Pop (王道進行系)
        Preset(
            id: "I-V-vi-IV",
            name: "I–V–vi–IV (Canon)",
            romanNumerals: ["I", "V", "vi", "IV"],
            category: .pop,
            description: "Most popular progression. Let It Be, Don't Stop Believin'",
            isFree: true
        ),
        Preset(
            id: "I-vi-IV-V",
            name: "I–vi–IV–V (50s)",
            romanNumerals: ["I", "vi", "IV", "V"],
            category: .pop,
            description: "50s doo-wop classic. Stand By Me",
            isFree: true
        ),
        Preset(
            id: "vi-IV-I-V",
            name: "vi–IV–I–V (Axis)",
            romanNumerals: ["vi", "IV", "I", "V"],
            category: .pop,
            description: "Axis progression. With Or Without You",
            isFree: true
        ),
        Preset(
            id: "I-IV-vi-V",
            name: "I–IV–vi–V",
            romanNumerals: ["I", "IV", "vi", "V"],
            category: .pop,
            description: "Bright and uplifting",
            isFree: true
        ),
        Preset(
            id: "I-bVII-IV",
            name: "I–♭VII–IV (Mixo)",
            romanNumerals: ["I", "bVII", "IV"],
            category: .rock,
            description: "Rock/Mixolydian feel. Sweet Child O' Mine",
            isFree: true
        ),
        
        // Jazz (ii-V-I系)
        Preset(
            id: "ii-V-I",
            name: "ii–V–I (Jazz)",
            romanNumerals: ["ii", "V", "I"],
            category: .jazz,
            description: "Jazz turnaround. Most common in standards",
            isFree: true
        ),
        Preset(
            id: "ii-V-I-vi",
            name: "ii–V–I–vi",
            romanNumerals: ["ii", "V", "I", "vi"],
            category: .jazz,
            description: "Extended jazz turnaround",
            isFree: true
        ),
        Preset(
            id: "iii-vi-ii-V",
            name: "iii–vi–ii–V (Circular)",
            romanNumerals: ["iii", "vi", "ii", "V"],
            category: .jazz,
            description: "Circular progression. Autumn Leaves",
            isFree: true
        ),
        Preset(
            id: "I-vi-ii-V",
            name: "I–vi–ii–V",
            romanNumerals: ["I", "vi", "ii", "V"],
            category: .jazz,
            description: "Jazz classic. Blue Moon",
            isFree: true
        ),
        
        // Blues
        Preset(
            id: "12-bar",
            name: "12-bar Blues",
            romanNumerals: ["I", "I", "I", "I", "IV", "IV", "I", "I", "V", "IV", "I", "V"],
            category: .blues,
            description: "Standard 12-bar blues",
            isFree: true
        ),
        Preset(
            id: "8-bar-blues",
            name: "8-bar Blues",
            romanNumerals: ["I", "I", "IV", "IV", "I", "V", "I", "V"],
            category: .blues,
            description: "Shorter blues form",
            isFree: true
        ),
        
        // Rock
        Preset(
            id: "I-IV-V",
            name: "I–IV–V (Classic Rock)",
            romanNumerals: ["I", "IV", "V"],
            category: .rock,
            description: "Classic rock. La Bamba, Twist and Shout",
            isFree: true
        ),
        Preset(
            id: "I-bIII-bVII-IV",
            name: "I–♭III–♭VII–IV (Aeolian)",
            romanNumerals: ["I", "bIII", "bVII", "IV"],
            category: .rock,
            description: "Dark rock progression",
            isFree: true
        ),
        Preset(
            id: "vi-IV-V",
            name: "vi–IV–V",
            romanNumerals: ["vi", "IV", "V"],
            category: .rock,
            description: "Minor to major resolution",
            isFree: true
        ),
        
        // Ballad
        Preset(
            id: "I-iii-IV-V",
            name: "I–iii–IV–V",
            romanNumerals: ["I", "iii", "IV", "V"],
            category: .ballad,
            description: "Smooth ascending ballad",
            isFree: true
        ),
        Preset(
            id: "I-IV-I-V",
            name: "I–IV–I–V (Simple)",
            romanNumerals: ["I", "IV", "I", "V"],
            category: .ballad,
            description: "Simple and clear",
            isFree: true
        ),
        Preset(
            id: "vi-V-IV-V",
            name: "vi–V–IV–V",
            romanNumerals: ["vi", "V", "IV", "V"],
            category: .ballad,
            description: "Melancholic ballad",
            isFree: true
        ),
        Preset(
            id: "I-V-IV",
            name: "I–V–IV",
            romanNumerals: ["I", "V", "IV"],
            category: .ballad,
            description: "Three-chord ballad",
            isFree: true
        ),
        Preset(
            id: "I-II",
            name: "I–II (Phrygian)",
            romanNumerals: ["I", "II"],
            category: .rock,
            description: "Phrygian color. Flamenco feel",
            isFree: true
        ),
        Preset(
            id: "I-vi-iii-IV",
            name: "I–vi–iii–IV (Descending)",
            romanNumerals: ["I", "vi", "iii", "IV"],
            category: .ballad,
            description: "Descending thirds",
            isFree: true
        ),
        
        // ======== PRO ONLY (30 presets to be added) ========
        // Phase 5: Pro-exclusive presets (placeholder for testing)
        Preset(
            id: "I-IVmaj7-iii-vi",
            name: "I–IVmaj7–iii–vi (Neo Soul)",
            romanNumerals: ["I", "IVmaj7", "iii", "vi"],
            category: .jazz,
            description: "Smooth neo-soul progression",
            isFree: false
        ),
        Preset(
            id: "I-V-vi-iii-IV-I-IV-V",
            name: "I–V–vi–iii–IV–I–IV–V (Epic)",
            romanNumerals: ["I", "V", "vi", "iii", "IV", "I", "IV", "V"],
            category: .pop,
            description: "Epic 8-chord progression",
            isFree: false
        ),
        Preset(
            id: "ii-V-I-IV-vii-iii-vi",
            name: "ii–V–I–IV–vii–iii–vi (Jazz Extended)",
            romanNumerals: ["ii", "V", "I", "IV", "vii", "iii", "vi"],
            category: .jazz,
            description: "Extended jazz sequence",
            isFree: false
        ),
        Preset(
            id: "vi-bVII-I",
            name: "vi–♭VII–I (Royal Road)",
            romanNumerals: ["vi", "bVII", "I"],
            category: .pop,
            description: "Japanese Royal Road progression",
            isFree: false
        ),
        Preset(
            id: "I-bII-bVI-V",
            name: "I–♭II–♭VI–V (Exotic)",
            romanNumerals: ["I", "bII", "bVI", "V"],
            category: .jazz,
            description: "Exotic chromatic movement",
            isFree: false
        ),
        
        // ======== PRO ONLY: Pop (10 presets) ========
        Preset(
            id: "I-V-vi-IV-I-V-IV-V",
            name: "I–V–vi–IV–I–V–IV–V (8-bar Ballad)",
            romanNumerals: ["I", "V", "vi", "IV", "I", "V", "IV", "V"],
            category: .pop,
            description: "Extended ballad with key change setup",
            isFree: false
        ),
        Preset(
            id: "I-III-IV-iv",
            name: "I–III–IV–iv (Beatles)",
            romanNumerals: ["I", "III", "IV", "iv"],
            category: .pop,
            description: "Beatles-style chromatic movement",
            isFree: false
        ),
        Preset(
            id: "vi-I-III-VII",
            name: "vi–I–III–VII (Synth Pop)",
            romanNumerals: ["vi", "I", "III", "VII"],
            category: .pop,
            description: "80s synth pop progression",
            isFree: false
        ),
        Preset(
            id: "I-V-IV-V",
            name: "I–V–IV–V (Teen Pop)",
            romanNumerals: ["I", "V", "IV", "V"],
            category: .pop,
            description: "Upbeat teen pop sound",
            isFree: false
        ),
        Preset(
            id: "vi-IV-I-V-bVI-bVII-I",
            name: "vi–IV–I–V–♭VI–♭VII–I (Power Ballad)",
            romanNumerals: ["vi", "IV", "I", "V", "bVI", "bVII", "I"],
            category: .pop,
            description: "Power ballad with chromatic climax",
            isFree: false
        ),
        Preset(
            id: "I-vi-iii-IV",
            name: "I–vi–iii–IV (Japanese Pop)",
            romanNumerals: ["I", "vi", "iii", "IV"],
            category: .pop,
            description: "J-Pop typical progression",
            isFree: false
        ),
        Preset(
            id: "IV-V-iii-vi",
            name: "IV–V–iii–vi (K-Pop)",
            romanNumerals: ["IV", "V", "iii", "vi"],
            category: .pop,
            description: "K-Pop chord sequence",
            isFree: false
        ),
        Preset(
            id: "I-bVII-bVI-bVII",
            name: "I–♭VII–♭VI–♭VII (Indie Pop)",
            romanNumerals: ["I", "bVII", "bVI", "bVII"],
            category: .pop,
            description: "Indie/Alternative feel",
            isFree: false
        ),
        Preset(
            id: "I-V-vi-iii-IV-I-II-V",
            name: "I–V–vi–iii–IV–I–II–V (Epic 8-bar)",
            romanNumerals: ["I", "V", "vi", "iii", "IV", "I", "II", "V"],
            category: .pop,
            description: "Epic 8-bar with Phrygian touch",
            isFree: false
        ),
        Preset(
            id: "vi-V-IV-III",
            name: "vi–V–IV–III (Descending Pop)",
            romanNumerals: ["vi", "V", "IV", "III"],
            category: .pop,
            description: "Descending pop progression",
            isFree: false
        ),
        
        // ======== PRO ONLY: Rock (5 presets) ========
        Preset(
            id: "I-IV-V-IV",
            name: "I–IV–V–IV (Rock Anthem)",
            romanNumerals: ["I", "IV", "V", "IV"],
            category: .rock,
            description: "Stadium rock anthem",
            isFree: false
        ),
        Preset(
            id: "iv-I-V-vi",
            name: "iv–I–V–vi (Alternative Rock)",
            romanNumerals: ["iv", "I", "V", "vi"],
            category: .rock,
            description: "Alt-rock with minor IV",
            isFree: false
        ),
        Preset(
            id: "I-bIII-IV-V",
            name: "I–♭III–IV–V (Hard Rock)",
            romanNumerals: ["I", "bIII", "IV", "V"],
            category: .rock,
            description: "Hard rock power progression",
            isFree: false
        ),
        Preset(
            id: "I-bVI-bVII-I",
            name: "I–♭VI–♭VII–I (Aeolian Rock)",
            romanNumerals: ["I", "bVI", "bVII", "I"],
            category: .rock,
            description: "Natural minor rock vamp",
            isFree: false
        ),
        Preset(
            id: "I-V-bVII-IV",
            name: "I–V–♭VII–IV (Brit Rock)",
            romanNumerals: ["I", "V", "bVII", "IV"],
            category: .rock,
            description: "British rock style. Wonderwall",
            isFree: false
        ),
        
        // ======== PRO ONLY: Jazz (7 presets) ========
        Preset(
            id: "I-IV-vii-iii-vi-ii-V-I",
            name: "I–IV–vii–iii–vi–ii–V–I (Coltrane Changes)",
            romanNumerals: ["I", "IV", "vii", "iii", "vi", "ii", "V", "I"],
            category: .jazz,
            description: "Giant Steps inspired sequence",
            isFree: false
        ),
        Preset(
            id: "ii-bII-I",
            name: "ii–♭II–I (Tritone Sub)",
            romanNumerals: ["ii", "bII", "I"],
            category: .jazz,
            description: "Jazz tritone substitution",
            isFree: false
        ),
        Preset(
            id: "I-bII-I-bII",
            name: "I–♭II–I–♭II (Bossa Nova)",
            romanNumerals: ["I", "bII", "I", "bII"],
            category: .jazz,
            description: "Bossa nova vamp",
            isFree: false
        ),
        Preset(
            id: "ii-V-iii-VI-ii-V-I",
            name: "ii–V–iii–VI–ii–V–I (Modal Jazz)",
            romanNumerals: ["ii", "V", "iii", "VI", "ii", "V", "I"],
            category: .jazz,
            description: "Modal jazz turnaround",
            isFree: false
        ),
        Preset(
            id: "I-IVmaj7-V-iii",
            name: "I–IVmaj7–V–iii (Smooth Jazz)",
            romanNumerals: ["I", "IVmaj7", "V", "iii"],
            category: .jazz,
            description: "Smooth jazz with major 7th",
            isFree: false
        ),
        Preset(
            id: "I-vi-IV-V",
            name: "I–vi–IV–V (Gospel)",
            romanNumerals: ["I", "vi", "IV", "V"],
            category: .jazz,
            description: "Gospel chord progression",
            isFree: false
        ),
        Preset(
            id: "I-III-vi-IV",
            name: "I–III–vi–IV (Jazz Ballad)",
            romanNumerals: ["I", "III", "vi", "IV"],
            category: .jazz,
            description: "Jazz ballad with chromatic III",
            isFree: false
        ),
        
        // ======== PRO ONLY: Blues (2 presets) ========
        Preset(
            id: "i-iv-i-V",
            name: "i–iv–i–V (Minor Blues)",
            romanNumerals: ["i", "iv", "i", "V"],
            category: .blues,
            description: "Minor blues progression",
            isFree: false
        ),
        Preset(
            id: "I-IV-I-I-IV-IV-I-I-V-V-I-I",
            name: "I–IV–I–I–IV–IV–I–I–V–V–I–I (Slow Blues)",
            romanNumerals: ["I", "IV", "I", "I", "IV", "IV", "I", "I", "V", "V", "I", "I"],
            category: .blues,
            description: "Slow 12-bar blues with extended changes",
            isFree: false
        ),
        
        // ======== PRO ONLY: R&B / Soul (3 presets) ========
        Preset(
            id: "i-bVII-bVI-V",
            name: "i–♭VII–♭VI–V (R&B Soul)",
            romanNumerals: ["i", "bVII", "bVI", "V"],
            category: .rnb,
            description: "Classic R&B soul progression",
            isFree: false
        ),
        Preset(
            id: "I-IVmaj7-Vmaj7-iii",
            name: "I–IVmaj7–Vmaj7–iii (Neo Soul)",
            romanNumerals: ["I", "IVmaj7", "Vmaj7", "iii"],
            category: .rnb,
            description: "Modern neo-soul with extended chords",
            isFree: false
        ),
        Preset(
            id: "ii-V-I-VI",
            name: "ii–V–I–VI (Motown)",
            romanNumerals: ["ii", "V", "I", "VI"],
            category: .rnb,
            description: "Motown classic sound",
            isFree: false
        ),
        
        // ======== PRO ONLY: Acoustic (3 presets) ========
        Preset(
            id: "I-IV-I-V",
            name: "I–IV–I–V (Folk Ballad)",
            romanNumerals: ["I", "IV", "I", "V"],
            category: .acoustic,
            description: "Simple folk ballad",
            isFree: false
        ),
        Preset(
            id: "i-bVII-bVI-bVII",
            name: "i–♭VII–♭VI–♭VII (Celtic)",
            romanNumerals: ["i", "bVII", "bVI", "bVII"],
            category: .acoustic,
            description: "Celtic modal progression",
            isFree: false
        ),
        Preset(
            id: "I-ii-iii-IV",
            name: "I–ii–iii–IV (Fingerstyle)",
            romanNumerals: ["I", "ii", "iii", "IV"],
            category: .acoustic,
            description: "Ascending fingerstyle pattern",
            isFree: false
        ),
    ]
    
    static func byCategory(_ category: PresetCategory) -> [Preset] {
        all.filter { $0.category == category }
    }
}

