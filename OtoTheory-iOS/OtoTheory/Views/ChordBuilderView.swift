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
    private let quicks = ["", "m", "7", "maj7", "m7", "dim", "sus4"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Choose Chords")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Button(action: {
                    // Show info alert
                    let alert = UIAlertController(
                        title: "Choose Chords",
                        message: "ルートとコードタイプを選んでください。追加ボタンでコード進行のスロットに追加できます。\nProプランの場合、より複雑なコードタイプを選ぶことができます。",
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
                    Text("Root")
                        .font(.headline)
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
                
                // Quick Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quicks, id: \.self) { quick in
                                Button(action: {
                                    selectedQuick = quick
                                    selectedSlashBass = nil
                                }) {
                                    Text(quick.isEmpty ? "Major" : quick)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .frame(minWidth: 60)
                                        .padding(.vertical, 12)
                                        .background(selectedQuick == quick ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedQuick == quick ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
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
}

