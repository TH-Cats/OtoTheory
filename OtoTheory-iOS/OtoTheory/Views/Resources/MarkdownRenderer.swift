//
//  MarkdownRenderer.swift
//  OtoTheory
//
//  Markdown to SwiftUI renderer with paragraph support, custom blocks, and table rendering
//
//  変更履歴:
//  - v2.0: 段落分割機能を追加、表レンダリング統合、改行・段落問題を解決
//  - v1.0: 初期バージョン（AttributedStringのみ）
//

import SwiftUI

struct MarkdownRenderer: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 段落ごとにレンダリング
            ForEach(splitIntoParagraphs(content), id: \.self) { paragraph in
                renderParagraph(paragraph)
            }
        }
    }
    
    // MARK: - 段落分割
    
    private func splitIntoParagraphs(_ content: String) -> [String] {
        var processedContent = content
        
        // === [デバッグログ] ===
        print("🔍 [MarkdownRenderer] Original content length: \(content.count)")
        print("🔍 [MarkdownRenderer] First 300 chars:")
        print("   \(String(content.prefix(300)))")
        print("🔍 [MarkdownRenderer] Newline count: \(content.filter { $0 == "\n" }.count)")
        
        // 改行コードの正規化
        processedContent = processedContent
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        
        let newlineCount = processedContent.filter { $0 == "\n" }.count
        print("🔍 [MarkdownRenderer] After normalization: \(newlineCount) newlines")
        
        // カスタムブロックの処理（FACTカード）
        processedContent = processFACTCards(content: processedContent)
        
        print("🔍 [MarkdownRenderer] After FACT processing: \(String(processedContent.prefix(300)))")
        
        // 段落分割のロジック
        let lines = processedContent.components(separatedBy: .newlines)
        var paragraphs: [String] = []
        var currentParagraph: [String] = []
        var inTable = false
        var tableLines: [String] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // 表の検出：パイプで始まる行
            if trimmed.hasPrefix("|") && trimmed.hasSuffix("|") {
                if !inTable {
                    // 現在の段落を終了して表を開始
                    if !currentParagraph.isEmpty {
                        paragraphs.append(currentParagraph.joined(separator: "\n"))
                        currentParagraph = []
                    }
                    inTable = true
                }
                tableLines.append(line)
            } else {
                // 表が終了
                if inTable {
                    paragraphs.append(tableLines.joined(separator: "\n"))
                    tableLines = []
                    inTable = false
                }
                
                // 空行の場合、現在の段落を終了
                if trimmed.isEmpty {
                    if !currentParagraph.isEmpty {
                        paragraphs.append(currentParagraph.joined(separator: "\n"))
                        currentParagraph = []
                    }
                }
                // 見出しの場合（# で始まる）、現在の段落を終了して新しい段落を開始
                else if trimmed.hasPrefix("#") {
                    if !currentParagraph.isEmpty {
                        paragraphs.append(currentParagraph.joined(separator: "\n"))
                        currentParagraph = []
                    }
                    paragraphs.append(trimmed)
                }
                // 水平線の場合（---）、現在の段落を終了して新しい段落を開始
                else if trimmed == "---" {
                    if !currentParagraph.isEmpty {
                        paragraphs.append(currentParagraph.joined(separator: "\n"))
                        currentParagraph = []
                    }
                    paragraphs.append(trimmed)
                }
                // 引用の場合（> で始まる）、現在の段落を終了して新しい段落を開始
                else if trimmed.hasPrefix(">") {
                    if !currentParagraph.isEmpty {
                        paragraphs.append(currentParagraph.joined(separator: "\n"))
                        currentParagraph = []
                    }
                    paragraphs.append(trimmed)
                }
                // リストの場合（- または * で始まる）
                else if trimmed.hasPrefix("-") || trimmed.hasPrefix("*") || trimmed.hasPrefix("1.") {
                    currentParagraph.append(line)
                }
                // その他の場合、現在の段落に追加
                else {
                    currentParagraph.append(line)
                }
            }
        }
        
        // 最後の表または段落を追加
        if inTable && !tableLines.isEmpty {
            paragraphs.append(tableLines.joined(separator: "\n"))
        } else if !currentParagraph.isEmpty {
            paragraphs.append(currentParagraph.joined(separator: "\n"))
        }
        
        // 空の段落をフィルタリング
        let filteredParagraphs = paragraphs
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        print("🔍 [MarkdownRenderer] Split into \(filteredParagraphs.count) paragraphs")
        for (i, paragraph) in filteredParagraphs.enumerated() {
            let preview = String(paragraph.prefix(100))
            print("   Paragraph \(i): \(preview)...")
        }
        
        return filteredParagraphs
    }
    
    // MARK: - 段落レンダリング
    
    @ViewBuilder
    private func renderParagraph(_ paragraph: String) -> some View {
        let trimmed = paragraph.trimmingCharacters(in: .whitespaces)
        
        // 表の検出
        if isMarkdownTable(trimmed) {
            renderMarkdownTable(trimmed)
        }
        // 見出し
        else if trimmed.hasPrefix("#") {
            renderHeading(trimmed)
        }
        // 水平線
        else if trimmed == "---" {
            Divider()
                .padding(.vertical, 8)
        }
        // 引用
        else if trimmed.hasPrefix(">") {
            renderQuote(trimmed)
        }
        // リスト
        else if trimmed.hasPrefix("-") || trimmed.hasPrefix("*") || trimmed.hasPrefix("1.") {
            renderList(trimmed)
        }
        // 通常の段落
        else {
            Text(processBasicMarkdown(trimmed))
                    .font(.body)
                    .lineSpacing(4)
                    .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // MARK: - 見出しのレンダリング
    
    @ViewBuilder
    private func renderHeading(_ text: String) -> some View {
        let level = text.prefix(while: { $0 == "#" }).count
        let title = String(text.dropFirst(level)).trimmingCharacters(in: .whitespaces)
        
        Text(title)
            .font(level == 1 ? .largeTitle : level == 2 ? .title : .title2)
            .fontWeight(.bold)
            .padding(.vertical, 4)
    }
    
    // MARK: - 引用のレンダリング
    
    @ViewBuilder
    private func renderQuote(_ text: String) -> some View {
        let quote = String(text.dropFirst()).trimmingCharacters(in: .whitespaces)
        Text(processBasicMarkdown(quote))
            .font(.body)
            .foregroundColor(.secondary)
            .padding(.leading, 16)
            .padding(.vertical, 4)
    }
    
    // MARK: - リストのレンダリング
    
    @ViewBuilder
    private func renderList(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(text.components(separatedBy: .newlines), id: \.self) { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("-") || trimmed.hasPrefix("*") {
                    let content = String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.body)
                        Text(processBasicMarkdown(content))
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else if trimmed.hasPrefix("1.") {
                    let content = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                    HStack(alignment: .top, spacing: 8) {
                        Text("1.")
                            .font(.body)
                        Text(processBasicMarkdown(content))
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
    
    // MARK: - 表のレンダリング
    
    // Markdown表かどうかを判定
    private func isMarkdownTable(_ text: String) -> Bool {
        let lines = text.components(separatedBy: .newlines)
        guard lines.count >= 2 else { return false }
        
        // 少なくとも2行あり、両方ともパイプで始まる
        return lines.allSatisfy { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix("|") && trimmed.hasSuffix("|")
        }
    }
    
    // Markdown表をパース
    private func parseMarkdownTable(_ text: String) -> (headers: [String], rows: [[String]])? {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard lines.count >= 3 else { return nil }
        
        // ヘッダー行（1行目）
        let headerLine = lines[0]
        let headers = headerLine
            .split(separator: "|")
            .dropFirst()  // 最初の空文字列をスキップ
            .dropLast()   // 最後の空文字列をスキップ
            .map { String($0).trimmingCharacters(in: .whitespaces) }
        
        // セパレーター行（2行目）をスキップして検証
        let separatorLine = lines[1]
        let isSeparator = separatorLine.contains("---") || separatorLine.contains(":--")
        
        guard isSeparator else { return nil }
        
        // データ行（3行目以降）
        var rows: [[String]] = []
        for line in lines.dropFirst(2) {
            let cells = line
                .split(separator: "|")
                .dropFirst()
                .dropLast()
                .map { String($0).trimmingCharacters(in: .whitespaces) }
            
            if !cells.isEmpty {
                rows.append(cells)
            }
        }
        
        return (headers: headers, rows: rows)
    }
    
    // Markdown表をレンダリング
    @ViewBuilder
    private func renderMarkdownTable(_ text: String) -> some View {
        if let table = parseMarkdownTable(text) {
            MarkdownTableView(headers: table.headers, rows: table.rows)
        } else {
            // パースに失敗した場合は通常のテキストとして表示
            Text(text)
                .font(.body)
                .lineSpacing(4)
        }
    }
    
    // MARK: - 基本的なMarkdown書式の処理
    
    private func processBasicMarkdown(_ text: String) -> AttributedString {
        var result = AttributedString(text)
        
        // 太字 **text** を処理
        let boldRegex = #/\*\*(.*?)\*\*/#
        var processedText = text
        
        for match in text.matches(of: boldRegex) {
            let boldText = String(match.1)
            processedText = processedText.replacingOccurrences(of: "**\(boldText)**", with: boldText)
            
            if let range = result.range(of: "**\(boldText)**") {
                var boldAttr = AttributedString(boldText)
                boldAttr.font = .body.bold()
                result.replaceSubrange(range, with: boldAttr)
            }
        }
        
        // イタリック *text* を処理（太字と重複しないように）
        let italicRegex = #/\*([^*]+)\*/#
        for match in processedText.matches(of: italicRegex) {
            let italicText = String(match.1)
            
            if let range = result.range(of: "*\(italicText)*") {
                var italicAttr = AttributedString(italicText)
                italicAttr.font = .body.italic()
                result.replaceSubrange(range, with: italicAttr)
            }
        }
        
        return result
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

// MARK: - Markdown表表示コンポーネント

struct MarkdownTableView: View {
    let headers: [String]
    let rows: [[String]]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ヘッダー行
            HStack(spacing: 0) {
                ForEach(headers.indices, id: \.self) { index in
                    Text(headers[index])
                        .font(.body.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .border(Color.gray.opacity(0.3), width: 0.5)
                }
            }
            
            // データ行
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    ForEach(rows[rowIndex].indices, id: \.self) { cellIndex in
                        if cellIndex < rows[rowIndex].count {
                            Text(processMarkdownInCell(rows[rowIndex][cellIndex]))
                                .font(.body)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(rowIndex % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))
                                .border(Color.gray.opacity(0.3), width: 0.5)
                        }
                    }
                }
            }
        }
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.vertical, 8)
    }
    
    // セル内のMarkdownを処理
    private func processMarkdownInCell(_ text: String) -> AttributedString {
        var result = AttributedString(text)
        
        // 太字 **text**
        let boldRegex = #/\*\*(.*?)\*\*/#
        for match in text.matches(of: boldRegex) {
            let boldText = String(match.1)
            if let range = result.range(of: "**\(boldText)**") {
                var boldAttr = AttributedString(boldText)
                boldAttr.font = .body.bold()
                result.replaceSubrange(range, with: boldAttr)
            }
        }
        
        // イタリック *text*
        let italicRegex = #/\*([^*]+)\*/#
        for match in text.matches(of: italicRegex) {
            let italicText = String(match.1)
            if let range = result.range(of: "*\(italicText)*") {
                var italicAttr = AttributedString(italicText)
                italicAttr.font = .body.italic()
                result.replaceSubrange(range, with: italicAttr)
            }
        }
        
        return result
    }
}

// MARK: - FACTカードビュー（未使用だが互換性のため残す）

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

// MARK: - プレビュー

#Preview {
    ScrollView {
    MarkdownRenderer(content: """
    # Test Article
    
    This is a **bold** text and *italic* text.
        
        ## Table Example
        
        | Interval | Name | Example (from C) |
        |----------|------|------------------|
        | 1st | Unison | C → C |
        | 2nd | Major Second | C → D |
        | 3rd | Major Third | C → E |
        
        This is the second paragraph.
    
    :::fact source="Test Source"
    This is a fact card content.
    :::
    
    - List item 1
    - List item 2
        - List item 3
    
    ## Subheading
    
        Regular paragraph text with **bold** and *italic*.
    """)
        .padding()
    }
}