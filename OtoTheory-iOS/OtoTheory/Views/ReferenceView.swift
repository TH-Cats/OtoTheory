import SwiftUI

struct ReferenceView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                    // Chord Reference Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Chord Reference")
                            .font(.headline)
                        
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
                        Text("Scale Reference")
                            .font(.headline)
                        
                        Text("Explore scales and their characteristics")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Theory Glossary Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theory Glossary")
                            .font(.headline)
                        
                        Text("Music theory terms and concepts")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    VStack(spacing: 8) {
                        Text("Full reference content coming soon")
                            .font(.caption)
                            .foregroundColor(.secondary)
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

