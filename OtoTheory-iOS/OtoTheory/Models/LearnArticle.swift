//
//  LearnArticle.swift
//  OtoTheory
//
//  Data model for Learn articles with Markdown content
//

import Foundation

enum ArticleStatus: String, Codable, CaseIterable {
    case published = "published"
    case draft = "draft"
    case coming = "coming"
}

struct LearnArticle: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let lang: String
    let slug: String
    let order: Int
    let status: ArticleStatus
    let readingTime: String
    let updated: String
    let keywords: [String]
    let related: [String]
    let sources: [ArticleSource]
    let content: String
    
    var isPublished: Bool {
        return status == .published
    }
    
    var displayOrder: Int {
        return order
    }
}

struct ArticleSource: Codable {
    let type: String
    let title: String
    let author: String?
    let year: Int?
    let url: String?
    let date: String?
    let citation: String?
}

// MARK: - Sample Data
extension LearnArticle {
    static let sampleArticles: [LearnArticle] = [
        LearnArticle(
            id: "theory-intro",
            title: "音楽理論とは？",
            subtitle: "感覚で作るを言葉にできるようになる",
            lang: "ja",
            slug: "theory-intro",
            order: 1,
            status: .published,
            readingTime: "3min",
            updated: "2025-01-22",
            keywords: ["音楽理論", "耳コピ", "アドリブ", "ギター"],
            related: ["intervals", "chords"],
            sources: [
                ArticleSource(
                    type: "book",
                    title: "Many Years From Now",
                    author: "Barry Miles",
                    year: 1997,
                    url: nil,
                    date: nil,
                    citation: "Chapter 5, p.123"
                )
            ],
            content: "# 🎵 音楽理論とは？\n\n### 感覚で作るを言葉にできるようになる\n\n---\n\n> **\"理論は知らなくても曲は作れる。でも、知るともっと自由になれる。\"**\n\n「理論って難しそう」「感覚でやってるから大丈夫」──そう思ったこと、ありませんか？\n実は、**あのビートルズのメンバーも最初は全員\"感覚派\"**でした。\nポール・マッカートニーはこう語っています。\n\n:::fact source=\"Many Years From Now (1997), Barry Miles\"\n\"I don't read music. I just know what sounds right.\"\n（僕は楽譜は読めない。でも、何が正しい響きかはわかるんだ）\n:::\n\n彼らは理論を知らずに世界を変えた。\nでも、彼らの音楽を分析してみると、**理論的に説明できる\"共通の仕組み\"**がたくさん見つかります。\nそれが、音楽理論の入り口です。"
        ),
        LearnArticle(
            id: "intervals",
            title: "度数とは？",
            subtitle: "音の\"距離\"がわかると、耳コピが速くなる",
            lang: "ja",
            slug: "intervals",
            order: 2,
            status: .draft,
            readingTime: "4min",
            updated: "2025-01-22",
            keywords: ["度数", "インターバル", "耳コピ", "音程"],
            related: ["theory-intro", "chords"],
            sources: [],
            content: "# 🎵 度数とは？\n\n### 音の\"距離\"がわかると、耳コピが速くなる\n\n---\n\n> **Coming Soon**\n\nこの記事は現在準備中です。近日公開予定です。"
        )
    ]
}
