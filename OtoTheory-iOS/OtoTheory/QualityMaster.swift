//
//  QualityMaster.swift
//  OtoTheory
//
//  Quality Master Data - Single Source of Truth for chord qualities
//  Generated from /Users/nh/App/OtoTheory/docs/content/Quality Master.csv

import Foundation

struct QualityInfo {
    let tier: String // "Free" or "Pro"
    let categoryJa: String
    let categoryEn: String
    let quality: String
    let commentJa: String
    let commentEn: String
}

struct QualityMaster {
    static let allQualities: [QualityInfo] = [
        // Free - 基本 (Basics)
        QualityInfo(
            tier: "Free",
            categoryJa: "基本",
            categoryEn: "Basics",
            quality: "Major",
            commentJa: "明るく、ハッピーな響きの基本となるコード。",
            commentEn: "The fundamental chord for a bright and happy sound."
        ),
        QualityInfo(
            tier: "Free",
            categoryJa: "基本",
            categoryEn: "Basics",
            quality: "m (minor)",
            commentJa: "少し切なく、落ち着いた響きの基本となるコード。",
            commentEn: "The fundamental chord for a slightly sad and calm sound."
        ),
        QualityInfo(
            tier: "Free",
            categoryJa: "基本",
            categoryEn: "Basics",
            quality: "7",
            commentJa: "次のコードへ進みたくなるような、少し不安定でおしゃれな響き。",
            commentEn: "A slightly unstable and stylish sound that creates a sense of resolution to the next chord."
        ),
        QualityInfo(
            tier: "Free",
            categoryJa: "基本",
            categoryEn: "Basics",
            quality: "maj7",
            commentJa: "明るく、洗練された都会的な響き。",
            commentEn: "A bright, sophisticated, and urban sound."
        ),
        QualityInfo(
            tier: "Free",
            categoryJa: "基本",
            categoryEn: "Basics",
            quality: "m7",
            commentJa: "切なさの中に、おしゃれな雰囲気が加わった響き。",
            commentEn: "A sound that adds a stylish atmosphere to sadness."
        ),
        
        // Free - 基本の飾り付け (Essential Colors)
        QualityInfo(
            tier: "Free",
            categoryJa: "基本の飾り付け",
            categoryEn: "Essential Colors",
            quality: "sus4",
            commentJa: "メジャーでもマイナーでもない、解決を待つ浮遊感のある響き。",
            commentEn: "A sound with a floating feel, neither major nor minor, awaiting resolution."
        ),
        QualityInfo(
            tier: "Free",
            categoryJa: "基本の飾り付け",
            categoryEn: "Essential Colors",
            quality: "sus2",
            commentJa: "sus4よりも、より明るく爽やかな浮遊感を持つ響き。",
            commentEn: "A sound with a brighter and fresher floating feel than sus4."
        ),
        QualityInfo(
            tier: "Free",
            categoryJa: "基本の飾り付け",
            categoryEn: "Essential Colors",
            quality: "add9",
            commentJa: "通常のコードにキラキラした透明感を加える、現代ポップスの定番。",
            commentEn: "The go-to chord in modern pop, adding a sparkling transparency to a basic chord."
        ),
        QualityInfo(
            tier: "Free",
            categoryJa: "基本の飾り付け",
            categoryEn: "Essential Colors",
            quality: "dim",
            commentJa: "不気味で緊張感のある響き。コードとコードを繋ぐ時に便利。",
            commentEn: "A spooky and tense sound, useful for connecting one chord to another."
        ),
        
        // Pro - ✨ キラキラ・浮遊感 (Sparkle & Float)
        QualityInfo(
            tier: "Pro",
            categoryJa: "✨ キラキラ・浮遊感",
            categoryEn: "Sparkle & Float",
            quality: "M9 (maj9)",
            commentJa: "ポップス、R&Bの王道おしゃれサウンド。",
            commentEn: "The quintessential stylish sound for Pop and R&B."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "✨ キラキラ・浮遊感",
            categoryEn: "Sparkle & Float",
            quality: "6",
            commentJa: "maj7より少しレトロで温かい響き。",
            commentEn: "A slightly more retro and warmer sound than maj7."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "✨ キラキラ・浮遊感",
            categoryEn: "Sparkle & Float",
            quality: "6/9",
            commentJa: "ジャズやフュージョンで多用される、明るく豊かな響き。",
            commentEn: "A bright and rich sound frequently used in Jazz and Fusion."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "✨ キラキラ・浮遊感",
            categoryEn: "Sparkle & Float",
            quality: "add#11",
            commentJa: "現代的でドリーミーな、まさに「浮遊感」のあるサウンド。",
            commentEn: "A modern, dreamy sound that truly gives a \"floating\" feel."
        ),
        
        // Pro - 🌃 おしゃれ・都会的 (Stylish & Urban)
        QualityInfo(
            tier: "Pro",
            categoryJa: "🌃 おしゃれ・都会的",
            categoryEn: "Stylish & Urban",
            quality: "m9",
            commentJa: "m7をさらにスムーズで洗練させた響き。",
            commentEn: "An even smoother and more refined sound than m7."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "🌃 おしゃれ・都会的",
            categoryEn: "Stylish & Urban",
            quality: "m11",
            commentJa: "Lo-fi Hip HopやR&Bで定番の、少しアンニュイなサウンド。",
            commentEn: "A standard sound in Lo-fi Hip Hop and R&B, with a slightly melancholic vibe."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "🌃 おしゃれ・都会的",
            categoryEn: "Stylish & Urban",
            quality: "m7b5",
            commentJa: "マイナーキーのii-V-Iで必須。ジャズ、ボサノヴァへの入り口。",
            commentEn: "Essential for minor key ii-V-I progressions. Your gateway to Jazz and Bossa Nova."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "🌃 おしゃれ・都会的",
            categoryEn: "Stylish & Urban",
            quality: "mM7",
            commentJa: "映画音楽のような、ミステリアスでドラマチックな響き。",
            commentEn: "A mysterious and dramatic sound, reminiscent of a movie soundtrack."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "🌃 おしゃれ・都会的",
            categoryEn: "Stylish & Urban",
            quality: "m6",
            commentJa: "ジャズや映画音楽で耳にする、少しレトロでミステリアスな響き。",
            commentEn: "A slightly retro and mysterious sound, often heard in jazz and film scores."
        ),
        
        // Pro - ⚡️ 緊張感・スパイス (Tension & Spice)
        QualityInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "7sus4",
            commentJa: "V7の前に置くことで、解決感を劇的に高めるプロの技。",
            commentEn: "A pro technique that dramatically enhances the feeling of resolution when placed before a V7 chord."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "aug",
            commentJa: "不安定で、次のコードへ進む推進力が強い。",
            commentEn: "An unstable sound with a strong drive to move to the next chord."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "dim7",
            commentJa: "経過コードとして非常に便利。緊張感を一気に高める。",
            commentEn: "Very useful as a passing chord to instantly increase tension."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "7(#9)",
            commentJa: "ブルージーでロックな緊張感。",
            commentEn: "A bluesy and rock-oriented tension."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "7(b9)",
            commentJa: "ジャズで多用される強い緊張感。",
            commentEn: "A strong tension frequently used in Jazz."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "7(#5)",
            commentJa: "augと同じ。解決先を強く示す。",
            commentEn: "Same as augmented. Strongly indicates the point of resolution."
        ),
        QualityInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "7(b13)",
            commentJa: "複雑でムーディーな緊張感。",
            commentEn: "A complex and moody tension."
        )
    ]
    
    // Helper functions
    static func getQualityInfo(for quality: String) -> QualityInfo? {
        return allQualities.first { $0.quality == quality }
    }
    
    static func getProQualities() -> [String] {
        return allQualities.filter { $0.tier == "Pro" }.map { $0.quality }
    }
    
    static func getFreeQualities() -> [String] {
        return allQualities.filter { $0.tier == "Free" }.map { $0.quality }
    }
    
    static func isProQuality(_ quality: String) -> Bool {
        return allQualities.contains { $0.quality == quality && $0.tier == "Pro" }
    }
    
    static func getQualityComment(for quality: String, locale: String = "ja") -> String {
        guard let info = getQualityInfo(for: quality) else { return "" }
        return locale == "ja" ? info.commentJa : info.commentEn
    }
    
    static func getQualitiesByCategory(tier: String) -> [String: [QualityInfo]] {
        let filtered = allQualities.filter { $0.tier == tier }
        var grouped: [String: [QualityInfo]] = [:]
        
        for quality in filtered {
            if grouped[quality.categoryJa] == nil {
                grouped[quality.categoryJa] = []
            }
            grouped[quality.categoryJa]?.append(quality)
        }
        
        return grouped
    }
}