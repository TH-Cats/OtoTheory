//
//  ArticleService.swift
//  OtoTheory
//
//  Service for loading and managing Learn articles from bundled Markdown files
//
//  SSOT参照:
//  - メイン仕様: /docs/SSOT/v3.2_SSOT.md
//  - 実装仕様: /docs/SSOT/v3.2_Implementation_SSOT.md
//  - リソース仕様: /docs/SSOT/RESOURCES_SSOT_v1.md
//
//  変更時は必ずSSOTとの整合性を確認すること
//

import Foundation

class ArticleService: ObservableObject {
    static let shared = ArticleService()
    
    @Published var articles: [LearnArticle] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private init() {
        loadArticles()
    }
    
    func loadArticles() {
        isLoading = true
        error = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let articles = try self?.loadBundledArticles() ?? []
                
                DispatchQueue.main.async {
                    self?.articles = articles.sorted { $0.displayOrder < $1.displayOrder }
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.error = error
                    self?.isLoading = false
                }
            }
        }
    }
    
    private func loadBundledArticles() throws -> [LearnArticle] {
        var articles: [LearnArticle] = []
        
        // Load Japanese articles
        if let jaArticles = try? loadArticlesFromBundle(lang: "ja") {
            articles.append(contentsOf: jaArticles)
        }
        
        // Load English articles
        if let enArticles = try? loadArticlesFromBundle(lang: "en") {
            articles.append(contentsOf: enArticles)
        }
        
        // order重複チェック
        var orderMap: [String: [Int]] = ["ja": [], "en": []]
        for article in articles {
            orderMap[article.lang]?.append(article.order)
        }

        for (lang, orders) in orderMap {
            let sortedOrders = orders.sorted()
            for i in 0..<sortedOrders.count - 1 {
                if sortedOrders[i] == sortedOrders[i + 1] {
                    print("⚠️ [ArticleService] Duplicate order \(sortedOrders[i]) found in \(lang) articles")
                }
            }
        }

        return articles
    }
    
    private func loadArticlesFromBundle(lang: String) throws -> [LearnArticle] {
        // バンドル全体から検索（subdirectory: nil）
        let urls = Bundle.main.urls(
            forResourcesWithExtension: "md",
            subdirectory: nil
        ) ?? []
        
        print("📁 [ArticleService] Found \(urls.count) total .md files in bundle")
        
        // 言語サフィックスでフィルタリング
        let filtered = urls.filter { $0.lastPathComponent.hasSuffix("_\(lang).md") }
        
        // 空配列ガード（最重要）
        guard !filtered.isEmpty else {
            print("ℹ️ [ArticleService] No '_\(lang).md' files found for lang: \(lang)")
            return []
        }
        
        print("ℹ️ [ArticleService] Found \(filtered.count) '_\(lang).md' files to process")
        
        var articlesDict: [String: LearnArticle] = [:] // slugをキーとする辞書
        
        for url in filtered {
            let filename = url.lastPathComponent
            print("🔍 [ArticleService] Processing: \(filename)")
            
            // ファイル名から言語サフィックスを抽出: *_ja or *_en
            guard let underscoreIndex = filename.lastIndex(of: "_") else {
                print("⚠️ [ArticleService] Skipping file without language suffix: \(filename)")
                continue
            }
            
            let slug = String(filename[..<underscoreIndex])
            // let langSuffix = ... (もう `lang` と一致することはわかっているのでチェック不要)
            
            // ファイル読み込み
            guard let content = try? String(contentsOf: url, encoding: .utf8) else {
                print("❌ [ArticleService] Cannot read file: \(url.lastPathComponent)")
                continue
            }
            
            // Markdown解析
            if let article = parseMarkdownArticle(
                content: content,
                lang: lang,
                filename: url.lastPathComponent,
                explicitSlug: slug
            ) {
                if articlesDict[article.slug] == nil {
                    articlesDict[article.slug] = article
                } else {
                    print("⚠️ [ArticleService] Duplicate skipped: \(article.slug)")
                }
            }
        }
        
        let articles = Array(articlesDict.values)
        
        if articles.isEmpty {
            print("⚠️ [ArticleService] No articles loaded for lang: \(lang).")
        } else {
            print("✅ [ArticleService] Loaded \(articles.count) articles for lang: \(lang)")
            let allStatuses = Set(articles.map { $0.status })
            print("📊 [ArticleService] All statuses: \(allStatuses)")
            print("📊 [ArticleService] Loaded: \(articles.map { "\($0.slug) (Order: \($0.order), Status: \($0.status))" })")
        }
        return articles.sorted { ($0.order, $0.slug) < ($1.order, $1.slug) }
    }
    
    private func parseMarkdownArticle(content: String, lang: String, filename: String, explicitSlug: String) -> LearnArticle? {
        // Simple YAML frontmatter parser
        let lines = content.components(separatedBy: .newlines)
        var frontmatter: [String: String] = [:]
        var contentStartIndex = 0
        var inFrontmatter = false
        var frontmatterEndFound = false
        
        if lines.first == "---" {
            inFrontmatter = true
            
            for (index, line) in lines.enumerated() {
                if index == 0 { continue } // Skip first ---
                
                // 2つ目の --- を検出したらfront-matter終了
                if line == "---" {
                    contentStartIndex = index + 1
                    frontmatterEndFound = true
                    break
                }
                
                // 空行やコメントはスキップ
                if line.trimmingCharacters(in: .whitespaces).isEmpty || line.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
                    continue
                }
                
                // インデントされた行（ネストしたキー）は無視する
                if line.starts(with: " ") || line.starts(with: "\t") || line.starts(with: "-") {
                    continue
                }
                
                // コロンで分割（トップレベルのフィールドのみ）
                let components = line.components(separatedBy: ":")
                if components.count >= 2 {
                    let key = components[0].trimmingCharacters(in: .whitespaces)
                    let value = components[1...].joined(separator: ":").trimmingCharacters(in: .whitespaces)
                    
                    // 空でないキーと値のみを保存
                    if !key.isEmpty {
                        // すでに同じキーが存在する場合は上書きしない（最初の値を保持）
                        if frontmatter[key] == nil {
                            frontmatter[key] = value
                            print("  ✓ Parsed: \(key) = \(value.prefix(50))...")
                        }
                    }
                }
            }
        }
        
        // front-matterが正しく終了していない場合
        if !frontmatterEndFound {
            print("⚠️ [ArticleService] Front-matter end marker '---' not found in \(filename)")
            contentStartIndex = 0
        }
        
        // Range境界チェックを追加（クラッシュ防止）
        guard contentStartIndex >= 0, contentStartIndex < lines.count else {
            print("⚠️ [ArticleService] Invalid contentStartIndex for \(filename): \(contentStartIndex), lines.count: \(lines.count)")
            return LearnArticle(
                id: explicitSlug,
                title: normalize(frontmatter["title"]),
                subtitle: "",
                lang: lang,
                slug: explicitSlug,
                order: 0,
                status: .draft,
                readingTime: "5分",
                updated: "",
                keywords: [],
                related: [],
                sources: [],
                content: ""  // 空本文で返す
            )
        }
        
        let content = lines[contentStartIndex...].joined(separator: "\n")
        
        // デバッグログ追加
        print("📄 [ArticleService] Parsing \(filename):")
        print("  - contentStartIndex: \(contentStartIndex), lines.count: \(lines.count)")
        print("  - content length: \(content.count) characters")
        print("  - frontmatter keys: \(frontmatter.keys.sorted())")
        
        // タイトル取得（必須）- 正規化適用
        let title = normalize(frontmatter["title"])
        guard !title.isEmpty else {
            print("⚠️ [ArticleService] Missing title in \(filename)")
            return nil
        }

        // 必須項目のバリデーション（正規化後）
        let normalizedLang = normalize(frontmatter["lang"]).lowercased()
        guard ["ja", "en"].contains(normalizedLang) else {
            print("⚠️ [ArticleService] Invalid or missing 'lang' in \(filename). Expected 'ja' or 'en', got: '\(frontmatter["lang"] ?? "nil")' -> normalized: '\(normalizedLang)'")
            return nil
        }
        
        // その他のフィールドを取得（オプショナル）- 正規化適用
        let subtitle = normalize(frontmatter["subtitle"])
        let order = Int(normalize(frontmatter["order"])) ?? 0
        
        let rawStatus = normalize(frontmatter["status"])
        let status = normalizeStatus(rawStatus)
        let readingTime = normalize(frontmatter["readingTime"])
        let updated = normalize(frontmatter["updated"])
        
        // keywords と related は配列として解析（簡易版）
        let keywords = frontmatter["keywords"]?
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty } ?? []
        
        let related = frontmatter["related"]?
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty } ?? []
        
        let article = LearnArticle(
            id: explicitSlug,
            title: title,
            subtitle: subtitle,
            lang: normalizedLang,
            slug: explicitSlug,
            order: order,
            status: status,
            readingTime: readingTime,
            updated: updated,
            keywords: keywords,
            related: related,
            sources: [], // sourcesは複雑なのでスキップ（必要に応じて後で実装）
            content: content
        )
        
        // デバッグログ強化
        print("✅ [ArticleService] Created article: \(article.title) (order: \(article.order), status: '\(article.status)', lang: '\(article.lang)', content: \(article.content.count) chars)")
        return article
    }
    
    // 正規化ヘルパー関数
    private func normalize(_ value: String?) -> String {
        return value?.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\"")) ?? ""
    }
    
    // status正規化ヘルパー関数
    private func normalizeStatus(_ rawStatus: String) -> ArticleStatus {
        let normalized = rawStatus.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            .lowercased()
        
        switch normalized {
        case "published":
            return .published
        case "coming":
            return .coming
        default:
            return .draft
        }
    }
    
    func getAllArticles(lang: String = "ja") -> [LearnArticle] {
        return articles.filter { $0.lang == lang }
    }
    
    func getPublishedArticles(lang: String = "ja") -> [LearnArticle] {
        return articles.filter { $0.lang == lang && $0.isPublished }
    }
    
    func getArticle(slug: String, lang: String = "ja") -> LearnArticle? {
        return articles.first { $0.slug == slug && $0.lang == lang }
    }
    
    func getNextArticle(currentOrder: Int, lang: String = "ja") -> LearnArticle? {
        let publishedArticles = getPublishedArticles(lang: lang)
        return publishedArticles.first { $0.order == currentOrder + 1 }
    }
    
    func getPrevArticle(currentOrder: Int, lang: String = "ja") -> LearnArticle? {
        let publishedArticles = getPublishedArticles(lang: lang)
        return publishedArticles.first { $0.order == currentOrder - 1 }
    }
}

enum ArticleServiceError: Error {
    case bundleNotFound
    case parsingFailed
    case fileNotFound
}
