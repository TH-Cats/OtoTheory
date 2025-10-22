//
//  ArticleService.swift
//  OtoTheory
//
//  Service for loading and managing Learn articles from bundled Markdown files
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
        
        return articles
    }
    
    private func loadArticlesFromBundle(lang: String) throws -> [LearnArticle] {
        guard let bundlePath = Bundle.main.path(forResource: "Resources", ofType: nil),
              let langPath = Bundle.main.path(forResource: lang, ofType: nil, inDirectory: "Resources") else {
            throw ArticleServiceError.bundleNotFound
        }
        
        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(atPath: langPath)
        
        var articles: [LearnArticle] = []
        
        for file in files where file.hasSuffix(".md") {
            let filePath = "\(langPath)/\(file)"
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            
            // Remove language suffix from filename to get the base slug
            let baseFilename = file.replacingOccurrences(of: "_\(lang).md", with: ".md")
            let slug = String(baseFilename.dropLast(3)) // Remove .md extension
            
            if let article = parseMarkdownArticle(content: content, lang: lang, slug: slug) {
                articles.append(article)
            }
        }
        
        return articles
    }
    
    private func parseMarkdownArticle(content: String, lang: String, slug: String) -> LearnArticle? {
        // Simple YAML frontmatter parser
        let lines = content.components(separatedBy: .newlines)
        var frontmatter: [String: String] = [:]
        var contentStartIndex = 0
        
        if lines.first == "---" {
            for (index, line) in lines.enumerated() {
                if index == 0 { continue } // Skip first ---
                if line == "---" {
                    contentStartIndex = index + 1
                    break
                }
                
                let components = line.components(separatedBy: ":")
                if components.count >= 2 {
                    let key = components[0].trimmingCharacters(in: .whitespaces)
                    let value = components[1...].joined(separator: ":").trimmingCharacters(in: .whitespaces)
                    frontmatter[key] = value
                }
            }
        }
        
        let content = lines[contentStartIndex...].joined(separator: "\n")
        
        // Parse frontmatter
        guard let title = frontmatter["title"],
              let subtitle = frontmatter["subtitle"],
              let orderStr = frontmatter["order"],
              let order = Int(orderStr),
              let status = frontmatter["status"],
              let readingTime = frontmatter["readingTime"],
              let updated = frontmatter["updated"] else {
            return nil
        }
        
        let keywords = frontmatter["keywords"]?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        let related = frontmatter["related"]?.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        
        return LearnArticle(
            id: slug,
            title: title,
            subtitle: subtitle,
            lang: lang,
            slug: slug,
            order: order,
            status: status,
            readingTime: readingTime,
            updated: updated,
            keywords: keywords,
            related: related,
            sources: [], // TODO: Parse sources from frontmatter
            content: content
        )
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
