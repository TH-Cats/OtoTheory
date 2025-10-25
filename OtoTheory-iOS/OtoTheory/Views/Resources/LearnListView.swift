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
    @State private var currentLang: AppLang = resolveAppLanguage()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if articleService.isLoading {
                    Spacer()
                    ProgressView(currentLang == .ja ? "記事を読み込み中..." : "Loading articles...")
                    Spacer()
                } else if let error = articleService.error {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(currentLang == .ja ? "読み込みエラー" : "Loading Error")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button(currentLang == .ja ? "再試行" : "Retry") {
                            articleService.loadArticles()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else {
                    let articles = articleService.getAllArticles(lang: currentLang.rawValue)
                    
                    if articles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text(currentLang == .ja ? "表示できる記事がありません" : "No articles available")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(articles) { article in
                                if article.status == .published {
                                    NavigationLink(destination: LearnArticleView(article: article)) {
                                        ArticleRowView(article: article)
                                    }
                                } else {
                                    ArticleRowView(article: article)
                                        .overlay(alignment: .trailing) {
                                            Text(currentLang == .ja ? "近日公開" : "Coming Soon")
                                                .font(.caption)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Capsule())
                                        }
                                        .contentShape(Rectangle())
                                        .disabled(true)
                                        .opacity(0.6)
                                        .accessibilityHint(currentLang == .ja ? "近日公開" : "Coming Soon")
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle(currentLang == .ja ? "音楽理論を学ぶ" : "Learn Music Theory")
            .navigationBarTitleDisplayMode(.large)
            .task {
                // デバイス言語が変更された場合の再読み込み
                let newLang = resolveAppLanguage()
                if newLang != currentLang {
                    currentLang = newLang
                    articleService.loadArticles()
                }
            }
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
                    
                    if article.status == .draft {
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
