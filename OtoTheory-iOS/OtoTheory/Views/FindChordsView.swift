import SwiftUI

struct FindChordsView: View {
    @State private var selectedKey = "C"
    @State private var selectedScale = "major"
    
    private let keys = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    private let scales = ["major", "minor", "dorian", "phrygian", "lydian", "mixolydian", "locrian"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                    // Key Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key")
                            .font(.headline)
                        
                        Picker("Key", selection: $selectedKey) {
                            ForEach(keys, id: \.self) { key in
                                Text(key).tag(key)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Scale Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scale")
                            .font(.headline)
                        
                        Picker("Scale", selection: $selectedScale) {
                            ForEach(scales, id: \.self) { scale in
                                Text(scale.capitalized).tag(scale)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // TODO: Week 2 Day 5+
                    VStack(spacing: 12) {
                        Text("Coming Soon:")
                            .font(.headline)
                        Text("• Diatonic chords display")
                        Text("• Fretboard visualization")
                        Text("• Scale table (Why + Glossary)")
                        Text("• Chord forms (Open/Barre)")
                        Text("• Basic substitutes")
                    }
                    .foregroundColor(.secondary)
                    .padding()
                    
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    FindChordsView()
}

