//
//  ChordBuilderView.swift
//  OtoTheory
//
//  Phase E-4B: Chord Builder Component
//

import SwiftUI

struct ChordBuilderView: View {
    @Binding var selectedRoot: String
    @Binding var selectedQuick: String
    @Binding var showAdvanced: Bool
    @Binding var selectedSlashBass: String?
    let previewChord: String
    let isPro: Bool
    let onPreview: () -> Void
    let onAdd: () -> Void
    let onShowPaywall: () -> Void
    
    // Animation state for Add button
    @State private var isAdding: Bool = false
    @State private var addButtonScale: CGFloat = 1.0
    
    private let roots = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    // Quality Master.csv based qualities - ONLY Free qualities
    private var qualityPresets: [(category: String, qualities: [String])] {
        let freeQualities = QualityMaster.getQualitiesByCategory(tier: "Free")
        
        var result: [(category: String, qualities: [String])] = []
        
        // Define the desired order for free qualities only
        let freeCategoryOrder = ["基本", "基本の飾り付け"] // Basics first, then Essential Colors
        
        // Free qualities only - show English category names in specified order
        for category in freeCategoryOrder {
            if let qualityInfos = freeQualities[category] {
                let englishCategory = getEnglishCategoryName(category)
                result.append((category: englishCategory, qualities: qualityInfos.map { $0.quality }))
            }
        }
        
        // NOTE: Pro qualities are now handled separately in AdvancedChordBuilderView
        // No Pro qualities should appear in the main Quality section
        
        return result
    }
    
    private func getEnglishCategoryName(_ japaneseCategory: String) -> String {
        switch japaneseCategory {
        case "基本": return "Basics"
        case "基本の飾り付け": return "Essential Colors"
        // Pro categories are handled in AdvancedChordBuilderView, not here
        default: return japaneseCategory
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Choose Chords")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Button(action: {
                    // Show info alert
                    let isJapanese = Locale.current.language.languageCode?.identifier == "ja"
                    let title = "Choose Chords"
                    let message = isJapanese ? 
                        "ルートとコードタイプを選んでください。追加ボタンでコード進行のスロットに追加できます。\nProプランの場合、より複雑なコードタイプを選ぶことができます。" :
                        "Select a root note and chord type. Use the Add button to add to chord progression slots.\nPro plan allows you to select more complex chord types."
                    
                    let alert = UIAlertController(
                        title: title,
                        message: message,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.present(alert, animated: true)
                    }
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                // Root Selection
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Root")
                            .font(.headline)
                        
                        Button(action: {
                            // Show info alert
                            let isJapanese = Locale.current.language.languageCode?.identifier == "ja"
                            let title = "Root"
                            let message = isJapanese ? 
                                "コードの基準となる音で、コード名の元になります。Cコードのルート音は「C（ド）」。" :
                                "The fundamental note that serves as the basis of the chord and forms the root of the chord name. The root note of a C chord is \"C\"."
                            
                            let alert = UIAlertController(
                                title: title,
                                message: message,
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.rootViewController?.present(alert, animated: true)
                            }
                        }) {
                            Image(systemName: "graduationcap.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(roots, id: \.self) { root in
                                Button(action: {
                                    selectedRoot = root
                                }) {
                                    Text(root)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .frame(minWidth: 50)
                                        .padding(.vertical, 12)
                                        .background(selectedRoot == root ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedRoot == root ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Quality Selection - Quality Master.csv based
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Quality")
                            .font(.headline)
                        
                        Button(action: {
                            // Show info alert
                            let isJapanese = Locale.current.language.languageCode?.identifier == "ja"
                            let title = "Quality"
                            let message = isJapanese ? 
                                "コードの「音の雰囲気」を決める要素。メジャーは明るく元気、マイナーは暗くて切ない、M7はジャズっぽくオシャレな響きに。同じルート音でも全く違う印象になります。" :
                                "Defines the \"mood\" of a chord. Major sounds bright and happy, minor sounds sad and emotional, M7 sounds jazzy and sophisticated. Even with the same root note, the quality completely changes the character."
                            
                            let alert = UIAlertController(
                                title: title,
                                message: message,
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.rootViewController?.present(alert, animated: true)
                            }
                        }) {
                            Image(systemName: "graduationcap.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Quality categories from Quality Master.csv
                    ForEach(qualityPresets, id: \.category) { categoryData in
                        VStack(alignment: .leading, spacing: 8) {
                            // Category header
                            HStack {
                                Text(categoryData.category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Quality chips
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(categoryData.qualities, id: \.self) { quality in
                                        let qualityLabel = getQualityLabel(quality)
                                        let isProQuality = QualityMaster.isProQuality(quality)
                                        let comment = QualityMaster.getQualityComment(for: quality, locale: "ja")
                                        
                                        Button(action: {
                                            if isProQuality && !isPro {
                                                // Show Pro paywall
                                                onShowPaywall()
                                            } else {
                                                selectedQuick = quality
                                                selectedSlashBass = nil
                                            }
                                        }) {
                                            HStack(spacing: 4) {
                                                Text(qualityLabel)
                                                    .font(.body)
                                                    .fontWeight(.semibold)
                                                
                                                if isProQuality && !isPro {
                                                    Image(systemName: "crown.fill")
                                                        .font(.caption)
                                                        .foregroundColor(.orange)
                                                }
                                            }
                                            .frame(minWidth: 60)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 8)
                                            .background(selectedQuick == quality ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedQuick == quality ? .white : .primary)
                                            .cornerRadius(8)
                                        }
                                        .contextMenu {
                                            if !comment.isEmpty {
                                                Button {
                                                    UIPasteboard.general.string = comment
                                                } label: {
                                                    Label("説明文をコピー", systemImage: "doc.on.doc")
                                                }
                                            }
                                        } preview: {
                                            if !comment.isEmpty {
                                                QualityInfoView(title: qualityLabel, bodyText: comment)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
                // Advanced Chord Builder
                AdvancedChordBuilderView(
                    showAdvanced: $showAdvanced,
                    selectedQuick: $selectedQuick,
                    selectedSlashBass: $selectedSlashBass,
                    isPro: isPro,
                    onShowPaywall: onShowPaywall
                )
                
                // Preview & Add
                HStack(spacing: 12) {
                    // Preview Chip
                    HStack(spacing: 8) {
                        Button(action: onPreview) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 20))
                                Text(previewChord)
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .contextMenu {
                            Button(action: {
                                // Navigate to chord library
                                NotificationCenter.default.post(
                                    name: .navigateToChordLibrary,
                                    object: previewChord
                                )
                            }) {
                                Label("フォームを確認", systemImage: "music.note")
                            }
                        }
                    }
                    
                    // Add Button
                    Button(action: {
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                        
                        // Scale animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            addButtonScale = 0.85
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                addButtonScale = 1.0
                            }
                        }
                        
                        // Call the actual add action
                        onAdd()
                    }) {
                        HStack(spacing: 6) {
                            Text("Add")
                                .font(.headline)
                            
                            // Success checkmark animation
                            if isAdding {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(width: 80)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .cornerRadius(8)
                        .scaleEffect(addButtonScale)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Helper function to get display label for quality
    private func getQualityLabel(_ quality: String) -> String {
        switch quality {
        case "Major": return "Major"
        case "m (minor)": return "m"
        case "7": return "7"
        case "maj7": return "maj7"
        case "m7": return "m7"
        case "sus4": return "sus4"
        case "sus2": return "sus2"
        case "add9": return "add9"
        case "dim": return "dim"
        case "M9 (maj9)": return "M9"
        case "6": return "6"
        case "6/9": return "6/9"
        case "add#11": return "add#11"
        case "m9": return "m9"
        case "m11": return "m11"
        case "m7b5": return "m7b5"
        case "mM7": return "mM7"
        case "m6": return "m6"
        case "7sus4": return "7sus4"
        case "aug": return "aug"
        case "dim7": return "dim7"
        case "7(#9)": return "7(#9)"
        case "7(b9)": return "7(b9)"
        case "7(#5)": return "7(#5)"
        case "7(b13)": return "7(b13)"
        default: return quality
        }
    }
}

