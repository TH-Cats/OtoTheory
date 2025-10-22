//
//  MarkdownRenderer.swift
//  OtoTheory
//
//  Markdown to SwiftUI renderer with custom blocks support
//

import SwiftUI

struct MarkdownRenderer: View {
    let content: String
    @State private var renderedContent: AttributedString = AttributedString()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(renderedContent)
                    .font(.body)
                    .lineSpacing(4)
                    .textSelection(.enabled)
            }
            .padding()
        }
        .onAppear {
            renderContent()
        }
    }
    
    private func renderContent() {
        var content = self.content
        
        // Process custom blocks first
        content = processFACTCards(content: content)
        
        // Convert to AttributedString
        do {
            renderedContent = try AttributedString(markdown: content)
        } catch {
            // Fallback to plain text
            renderedContent = AttributedString(content)
        }
    }
    
    private func processFACTCards(content: String) -> String {
        // Convert :::fact blocks to markdown blockquotes
        let factCardRegex = #/:::fact source="([^"]+)"\n([\s\S]*?)\n:::/#
        
        return content.replacing(factCardRegex) { match in
            let source = String(match.1)
            let factContent = String(match.2)
            
            return """
            > **🎙️ FACT** — \(source)
            > 
            > \(factContent)
            """
        }
    }
}

struct FACTCardView: View {
    let source: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🎙️")
                    .font(.title2)
                Text("FACT")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Text(content)
                .font(.body)
                .italic()
                .padding(.vertical, 4)
            
            Text("出典：\(source)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    MarkdownRenderer(content: """
    # Test Article
    
    This is a **bold** text and *italic* text.
    
    :::fact source="Test Source"
    This is a fact card content.
    :::
    
    - List item 1
    - List item 2
    
    ## Subheading
    
    Regular paragraph text.
    """)
}
