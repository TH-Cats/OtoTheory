//
//  LearnArticleView.swift
//  OtoTheory
//
//  Individual article view with navigation
//

import SwiftUI

struct LearnArticleView: View {
    let article: LearnArticle
    @StateObject private var articleService = ArticleService.shared
    @Environment(\.dismiss) private var dismiss
    
    private var nextArticle: LearnArticle? {
        articleService.getNextArticle(currentOrder: article.order, lang: article.lang)
    }
    
    private var prevArticle: LearnArticle? {
        articleService.getPrevArticle(currentOrder: article.order, lang: article.lang)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text(article.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    Text(article.subtitle)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 16) {
                        Label(article.readingTime, systemImage: "clock")
                        Label("記事 \(article.order)", systemImage: "number")
                        Label(article.updated, systemImage: "calendar")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Divider()
                
                // Content
                MarkdownRenderer(content: article.content)
                    .padding(.horizontal)
                
                // Navigation
                if prevArticle != nil || nextArticle != nil {
                    VStack(spacing: 16) {
                        Divider()
                        
                        HStack {
                            if let prev = prevArticle {
                                NavigationLink(destination: LearnArticleView(article: prev)) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        VStack(alignment: .leading) {
                                            Text("前の記事")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(prev.title)
                                                .font(.subheadline)
                                                .lineLimit(1)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            } else {
                                Spacer()
                            }
                            
                            if let next = nextArticle {
                                NavigationLink(destination: LearnArticleView(article: next)) {
                                    HStack {
                                        VStack(alignment: .trailing) {
                                            Text("次の記事")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(next.title)
                                                .font(.subheadline)
                                                .lineLimit(1)
                                        }
                                        Image(systemName: "chevron.right")
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
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

#Preview {
    NavigationView {
        LearnArticleView(article: LearnArticle.sampleArticles[0])
    }
}
