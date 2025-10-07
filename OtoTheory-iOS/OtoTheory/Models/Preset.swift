import Foundation

struct Preset: Identifiable {
    let id: String
    let name: String
    let romanNumerals: [String]
    let category: PresetCategory
    let description: String
}

enum PresetCategory: String, CaseIterable {
    case rock = "Rock"
    case pop = "Pop"
    case blues = "Blues"
    case ballad = "Ballad"
    case jazz = "Jazz"
}

// MARK: - Preset Library

extension Preset {
    static let all: [Preset] = [
        // Pop (王道進行系)
        Preset(
            id: "I-V-vi-IV",
            name: "I–V–vi–IV (Canon)",
            romanNumerals: ["I", "V", "vi", "IV"],
            category: .pop,
            description: "Most popular progression. Let It Be, Don't Stop Believin'"
        ),
        Preset(
            id: "I-vi-IV-V",
            name: "I–vi–IV–V (50s)",
            romanNumerals: ["I", "vi", "IV", "V"],
            category: .pop,
            description: "50s doo-wop classic. Stand By Me"
        ),
        Preset(
            id: "vi-IV-I-V",
            name: "vi–IV–I–V (Axis)",
            romanNumerals: ["vi", "IV", "I", "V"],
            category: .pop,
            description: "Axis progression. With Or Without You"
        ),
        Preset(
            id: "I-IV-vi-V",
            name: "I–IV–vi–V",
            romanNumerals: ["I", "IV", "vi", "V"],
            category: .pop,
            description: "Bright and uplifting"
        ),
        Preset(
            id: "I-bVII-IV",
            name: "I–♭VII–IV (Mixo)",
            romanNumerals: ["I", "bVII", "IV"],
            category: .rock,
            description: "Rock/Mixolydian feel. Sweet Child O' Mine"
        ),
        
        // Jazz (ii-V-I系)
        Preset(
            id: "ii-V-I",
            name: "ii–V–I (Jazz)",
            romanNumerals: ["ii", "V", "I"],
            category: .jazz,
            description: "Jazz turnaround. Most common in standards"
        ),
        Preset(
            id: "ii-V-I-vi",
            name: "ii–V–I–vi",
            romanNumerals: ["ii", "V", "I", "vi"],
            category: .jazz,
            description: "Extended jazz turnaround"
        ),
        Preset(
            id: "iii-vi-ii-V",
            name: "iii–vi–ii–V (Circular)",
            romanNumerals: ["iii", "vi", "ii", "V"],
            category: .jazz,
            description: "Circular progression. Autumn Leaves"
        ),
        Preset(
            id: "I-vi-ii-V",
            name: "I–vi–ii–V",
            romanNumerals: ["I", "vi", "ii", "V"],
            category: .jazz,
            description: "Jazz classic. Blue Moon"
        ),
        
        // Blues
        Preset(
            id: "12-bar",
            name: "12-bar Blues",
            romanNumerals: ["I", "I", "I", "I", "IV", "IV", "I", "I", "V", "IV", "I", "V"],
            category: .blues,
            description: "Standard 12-bar blues"
        ),
        Preset(
            id: "8-bar-blues",
            name: "8-bar Blues",
            romanNumerals: ["I", "I", "IV", "IV", "I", "V", "I", "V"],
            category: .blues,
            description: "Shorter blues form"
        ),
        
        // Rock
        Preset(
            id: "I-IV-V",
            name: "I–IV–V (Classic Rock)",
            romanNumerals: ["I", "IV", "V"],
            category: .rock,
            description: "Classic rock. La Bamba, Twist and Shout"
        ),
        Preset(
            id: "I-bIII-bVII-IV",
            name: "I–♭III–♭VII–IV (Aeolian)",
            romanNumerals: ["I", "bIII", "bVII", "IV"],
            category: .rock,
            description: "Dark rock progression"
        ),
        Preset(
            id: "vi-IV-V",
            name: "vi–IV–V",
            romanNumerals: ["vi", "IV", "V"],
            category: .rock,
            description: "Minor to major resolution"
        ),
        
        // Ballad
        Preset(
            id: "I-iii-IV-V",
            name: "I–iii–IV–V",
            romanNumerals: ["I", "iii", "IV", "V"],
            category: .ballad,
            description: "Smooth ascending ballad"
        ),
        Preset(
            id: "I-IV-I-V",
            name: "I–IV–I–V (Simple)",
            romanNumerals: ["I", "IV", "I", "V"],
            category: .ballad,
            description: "Simple and clear"
        ),
        Preset(
            id: "vi-V-IV-V",
            name: "vi–V–IV–V",
            romanNumerals: ["vi", "V", "IV", "V"],
            category: .ballad,
            description: "Melancholic ballad"
        ),
        Preset(
            id: "I-V-IV",
            name: "I–V–IV",
            romanNumerals: ["I", "V", "IV"],
            category: .ballad,
            description: "Three-chord ballad"
        ),
        
        // Additional patterns
        Preset(
            id: "I-II",
            name: "I–II (Phrygian)",
            romanNumerals: ["I", "II"],
            category: .rock,
            description: "Phrygian color. Flamenco feel"
        ),
        Preset(
            id: "I-vi-iii-IV",
            name: "I–vi–iii–IV (Descending)",
            romanNumerals: ["I", "vi", "iii", "IV"],
            category: .ballad,
            description: "Descending thirds"
        ),
    ]
    
    static func byCategory(_ category: PresetCategory) -> [Preset] {
        all.filter { $0.category == category }
    }
}

