//
//  ScaleCategoryIcons.swift
//  OtoTheory
//
//  SF Symbols mapping for scale categories
//

import SwiftUI

struct ScaleCategoryIcons {
    
    // MARK: - Category to SF Symbol Mapping
    
    static func iconForCategory(_ category: String) -> String {
        switch category {
        case "Basic":
            return "star.fill"
        case "Modes":
            return "sparkles"
        case "Pentatonic & Blues":
            return "music.note"
        case "Minor family":
            return "moon.fill"
        case "Symmetrical":
            return "grid"
        case "Advanced":
            return "bolt.fill"
        default:
            return "music.note"
        }
    }
    
    // MARK: - Category Display Names
    
    static func displayNameForCategory(_ category: String, isJapanese: Bool = false) -> String {
        if isJapanese {
            switch category {
            case "Basic":
                return "基本"
            case "Modes":
                return "モード"
            case "Pentatonic & Blues":
                return "ペンタ＆ブルース"
            case "Minor family":
                return "マイナー系"
            case "Symmetrical":
                return "対称系"
            case "Advanced":
                return "高度"
            default:
                return category
            }
        } else {
            return category
        }
    }
    
    // MARK: - Category Color Mapping
    
    static func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Basic":
            return .blue
        case "Modes":
            return .purple
        case "Pentatonic & Blues":
            return .green
        case "Minor family":
            return .indigo
        case "Symmetrical":
            return .orange
        case "Advanced":
            return .red
        default:
            return .gray
        }
    }
    
    // MARK: - Helper Methods
    
    static func allCategories() -> [String] {
        return ["Basic", "Modes", "Pentatonic & Blues", "Minor family", "Symmetrical", "Advanced"]
    }
    
    static func categoryInfo() -> [(category: String, icon: String, color: Color)] {
        return allCategories().map { category in
            (category: category, icon: iconForCategory(category), color: colorForCategory(category))
        }
    }
}

// MARK: - Category Header View Component

struct ScaleCategoryHeader: View {
    let category: String
    let isJapanese: Bool
    
    var body: some View {
        HStack {
            Image(systemName: ScaleCategoryIcons.iconForCategory(category))
                .foregroundColor(ScaleCategoryIcons.colorForCategory(category))
                .font(.system(size: 16, weight: .medium))
            
            Text(ScaleCategoryIcons.displayNameForCategory(category, isJapanese: isJapanese))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6).opacity(0.5))
    }
}

// MARK: - Preview

struct ScaleCategoryIcons_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            ForEach(ScaleCategoryIcons.allCategories(), id: \.self) { category in
                ScaleCategoryHeader(category: category, isJapanese: false)
            }
        }
        .padding()
    }
}
