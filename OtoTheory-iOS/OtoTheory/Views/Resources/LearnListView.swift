//
//  LearnListView.swift
//  OtoTheory
//
//  Learn articles list view for Resources section
//
//  SSOT参照:
//  - メイン仕様: /docs/SSOT/v3.2_SSOT.md
//  - 言語仕様: /docs/SSOT/EN_JA_language_SSOT.md
//  - 実装仕様: /docs/SSOT/v3.2_Implementation_SSOT.md
//  - リソース仕様: /docs/SSOT/RESOURCES_SSOT_v1.md
//
//  変更時は必ずSSOTとの整合性を確認すること
//

import SwiftUI

struct LearnListView: View {
    @StateObject private var articleService = ArticleService.shared
    @State private var selectedLang: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Language selector
                Picker("Language", selection: $selectedLang) {
                    Text("日本語").tag("ja")
                    Text("English").tag("en")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if articleService.isLoading {
                    Spacer()
                    ProgressView(selectedLang == "ja" ? "記事を読み込み中..." : "Loading articles...")
                    Spacer()
                } else if let error = articleService.error {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(selectedLang == "ja" ? "読み込みエラー" : "Loading Error")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button(selectedLang == "ja" ? "再試行" : "Retry") {
                            articleService.loadArticles()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(articleService.getAllArticles(lang: selectedLang)) { article in
                            if article.status == "published" {
                                NavigationLink(destination: LearnArticleView(article: article)) {
                                    ArticleRowView(article: article)
                                }
                            } else {
                                ArticleRowView(article: article)
                                    .opacity(0.6)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle(selectedLang == "ja" ? "音楽理論を学ぶ" : "Learn Music Theory")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ArticleRowView: View {
    let article: LearnArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Article icon
                Image(systemName: articleIcon(for: article.order))
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(article.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(article.readingTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if article.status == "draft" {
                        Text(article.lang == "ja" ? "近日公開" : "Coming Soon")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func articleIcon(for order: Int) -> String {
        switch order {
        case 1: return "music.note"
        case 2: return "ruler"
        case 3: return "paintpalette"
        case 4: return "magnet"
        case 5: return "map"
        case 6: return "person.3"
        case 7: return "ear"
        case 8: return "guitars"
        default: return "doc.text"
        }
    }
}

#Preview {
    LearnListView()
}
