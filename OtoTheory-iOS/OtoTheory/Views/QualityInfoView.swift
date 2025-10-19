//
//  QualityInfoView.swift
//  OtoTheory
//
//  Chord quality information display view for Sheet/Popover
//

import SwiftUI

struct QualityInfoView: View {
    let info: QualityInfo
    @Environment(\.dismiss) private var dismiss
    
    // テキストを段落に分割
    private func parseSections(from text: String) -> [(title: String, content: String)] {
        let lines = text.components(separatedBy: .newlines)
        var sections: [(title: String, content: String)] = []
        var currentTitle = ""
        var currentContent = ""

        // 見出し検出の正規表現：
        //  1) • **雰囲気** / **雰囲気**（太字行）
        //  2) 雰囲気: 本文 / 雰囲気：本文（1行完結）
        let headerBold = try! NSRegularExpression(pattern: #"^\s*(?:•\s*)?(?:\*\*)?(雰囲気|特徴|Try|理論|Vibe|Usage|Theory)(?:\*\*)?\s*$"#)
        let headerInline = try! NSRegularExpression(pattern: #"^\s*(雰囲気|特徴|Try|理論|Vibe|Usage|Theory)\s*[:：]\s*(.+)\s*$"#)

        for raw in lines {
            let line = raw.trimmingCharacters(in: .whitespaces)

            // 2) 1行完結「雰囲気：本文」
            if let m = headerInline.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)) {
                // 直前のセクションを確定
                if !currentTitle.isEmpty {
                    sections.append((title: currentTitle, content: currentContent.trimmingCharacters(in: .whitespacesAndNewlines)))
                }
                // 新セクション開始（見出し＋初期本文）
                let title = String(line[Range(m.range(at: 1), in: line)!])
                let firstContent = String(line[Range(m.range(at: 2), in: line)!])
                currentTitle = title
                currentContent = firstContent + "\n"
                continue
            }

            // 1) 太字見出し行（• **雰囲気** / **雰囲気**）
            if headerBold.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)) != nil {
                if !currentTitle.isEmpty {
                    sections.append((title: currentTitle, content: currentContent.trimmingCharacters(in: .whitespacesAndNewlines)))
                }
                // 太字行からタイトルだけ抽出
                let t = line.replacingOccurrences(of: "•", with: "")
                            .replacingOccurrences(of: "*", with: "")
                            .trimmingCharacters(in: .whitespaces)
                currentTitle = t
                currentContent = ""
                continue
            }

            // どちらでもなければ本文行として追記
            if !line.isEmpty {
                currentContent += raw + "\n" // 元の改行を維持
            }
        }

        // 最後のセクションを確定
        if !currentTitle.isEmpty {
            sections.append((title: currentTitle, content: currentContent.trimmingCharacters(in: .whitespacesAndNewlines)))
        }

        return sections
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                let sections = parseSections(from: info.body)
                
                if sections.isEmpty {
                    // フォールバック: セクションが解析されなかった場合
                    VStack(alignment: .leading) {
                        Text(info.body)
                            .font(.body)
                            .lineSpacing(4)
                            .textSelection(.enabled)
                            .foregroundColor(.primary)
                    }
                    .padding(16)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(sections.indices, id: \.self) { i in
                            VStack(alignment: .leading, spacing: 3) {
                                // 見出し
                                HStack {
                                    Text("•")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.orange)
                                    
                                    Text(sections[i].title)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.orange)
                                }
                                
                                // 本文
                                Text(sections[i].content)
                                    .font(.body)
                                    .lineSpacing(4)
                                    .textSelection(.enabled)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle(info.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    QualityInfoView(
        info: QualityInfo(
            title: "M9 (maj9)",
            body: "ポップス、R&Bの王道おしゃれサウンド。"
        )
    )
}
