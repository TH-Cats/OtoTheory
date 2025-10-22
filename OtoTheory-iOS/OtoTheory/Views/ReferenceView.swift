import SwiftUI

struct ReferenceView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Learn Music Theory Section
                NavigationLink(destination: LearnListView()) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "music.note")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("音楽理論を学ぶ")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        
                        Text("感覚で作るを言葉にできるようになる")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Chord Reference Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "guitars.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                        Text("Chord Reference")
                            .font(.headline)
                    }
                    
                    Text("Browse common chord shapes and voicings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Scale Reference Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "music.note.list")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("Scale Reference")
                            .font(.headline)
                    }
                    
                    Text("Explore scales and their characteristics")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Coming Soon Section
                VStack(spacing: 8) {
                    Text("Coming Soon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Artist Lab, Training, and more reference content")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ReferenceView()
}

