//
//  LanguageResolver.swift
//  OtoTheory
//
//  Language resolution helper for consistent language detection across the app
//
//  SSOT参照:
//  - メイン仕様: /docs/SSOT/v3.2_SSOT.md
//  - 言語仕様: /docs/SSOT/EN_JA_language_SSOT.md
//  - 実装仕様: /docs/SSOT/v3.2_Implementation_SSOT.md
//
//  変更時は必ずSSOTとの整合性を確認すること
//

import Foundation

enum AppLang: String, CaseIterable {
    case ja = "ja"
    case en = "en"
}

func resolveAppLanguage() -> AppLang {
    // 1. アプリの優先言語設定を最優先で確認
    if let preferredLang = Bundle.main.preferredLocalizations.first {
        if let appLang = AppLang(rawValue: preferredLang) {
            print("🌍 [LanguageResolver] Using app preferred language: \(preferredLang)")
            return appLang
        }
    }
    
    // 2. デバイスの現在の言語設定を確認
    if #available(iOS 16.0, *) {
        if let deviceLang = Locale.current.language.languageCode?.identifier,
           let appLang = AppLang(rawValue: deviceLang) {
            print("🌍 [LanguageResolver] Using device language (iOS 16+): \(deviceLang)")
            return appLang
        }
    } else {
        // iOS 15以下では古いAPIを使用
        if let deviceLang = Locale.preferredLanguages.first?.prefix(2),
           let appLang = AppLang(rawValue: String(deviceLang)) {
            print("🌍 [LanguageResolver] Using device language (iOS 15-): \(deviceLang)")
            return appLang
        }
    }
    
    // 3. フォールバック: 英語をデフォルトとする
    print("🌍 [LanguageResolver] Fallback to English")
    return .en
}