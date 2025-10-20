# OtoTheory - Music Theory Learning App

## 📋 プロジェクト概要

OtoTheoryは、音楽理論学習に特化したアプリケーションです。コード進行の作成、コード検索、音楽理論の学習をサポートします。

## 🎯 現在のバージョン

**v3.2が正式バージョンです**

- **SSOT**: `/docs/SSOT/v3.2_SSOT.md`
- **Implementation SSOT**: `/docs/SSOT/v3.2_Implementation_SSOT.md`
- **Business Plan**: `/docs/SSOT/v3.2_Business_Plan.md`

## ⚠️ 重要な注意事項

**v3.1は参考資料として扱います。今後はv3.2を正として作業を進めてください。**

### バージョン管理ルール

1. **v3.2が正**: 全ての新機能開発はv3.2の仕様に従う
2. **v3.1は参考**: 過去の実装参考として保持、更新は行わない
3. **SSOT優先**: v3.2 SSOTが最優先、矛盾時はSSOTを更新

## 📁 主要ディレクトリ

```
OtoTheory/
├── docs/SSOT/                    # 単一の真実の源（SSOT）
│   ├── v3.2_SSOT.md             # v3.2仕様正本
│   ├── v3.2_Implementation_SSOT.md # v3.2実装基準
│   └── v3.2_Business_Plan.md    # v3.2ビジネスプラン
├── docs/content/                 # コンテンツマスター
│   ├── Quality Master.csv       # コードクオリティマスター
│   └── Chord Library Mastar.csv # コードライブラリマスター
├── OtoTheory-iOS/               # iOS版
├── ototheory-web/               # Web版
└── scripts/                     # 生成スクリプト
```

## 🚀 主要機能

### iOS版（Pro機能付き）
- コード進行作成（セクション編集対応）
- MIDI出力（Chord Track + Section Markers + Guide Tones）
- サウンドパレット（音の雰囲気でコード選択）
- Sketch無制限保存（クラウド同期）
- IAP（¥490/月）

### Web版（Lite）
- 基本コード進行作成
- Find Chords機能
- プリセット20種
- PNG出力
- 広告収益モデル

### Android版（計画中）
- Free機能のみ
- 広告モデル
- iOS Pro誘導

## 📖 開発ガイドライン

### SSOT準拠
- 全ての実装はv3.2 SSOTに準拠
- データマスターCSVを単一の真実の源として使用
- 矛盾時はSSOTを最優先

### MIDI実装仕様（必須参照）
- **⚠️ 重要**: MIDI関連の実装・修正を行う前に、必ず`/on-chord-midi-specification.md`を確認すること
- オンコード（スラッシュコード）のMIDI実装仕様
- オクターブ範囲、クランプ、Voice Leading、三段階安全弁の詳細仕様
- 実装ファイル、テスト仕様、制約事項の完全な定義
- **上記の仕様に従わない実装は禁止**

### 翻訳作業の必須手順
- **⚠️ 重要**: すべての翻訳作業を行う前に、必ず`/docs/SSOT/EN_JA_language_SSOT.md`を確認すること
- 新しいUI要素の翻訳が必要な場合
- 既存の翻訳を修正する場合  
- コード内で日本語文字列を追加・変更する場合
- **上記のいずれの場合も、まず言語相対表で該当する訳語が定義されているかを確認し、定義されていない場合は言語相対表に追加してから実装を行ってください**

### 品質基準
- iOS 16+対応
- SwiftUI最新API使用
- 日本語/英語対応
- アクセシビリティ配慮

## 🔧 開発環境

### 必要ツール
- Xcode 15+
- Node.js 18+
- Next.js 15+

### セットアップ
```bash
# Web版
cd ototheory-web
npm install
npm run dev

# iOS版
cd OtoTheory-iOS
open OtoTheory.xcodeproj
```

## 📝 更新履歴

| 日付 | バージョン | 主要変更 |
|------|-----------|---------|
| 2025/10/20 | v3.2 | コードクオリティコメント表示機能実装 |
| 2025/01/19 | v3.2 | サウンドパレット、Android計画追加 |
| 2025/01/16 | v3.1 | Web Lite GA、iOS収益軸 |

## 📞 サポート

- ドキュメント: `/docs/`配下を参照
- 実装詳細: v3.2 Implementation SSOTを参照
- 仕様確認: v3.2 SSOTを参照

---

**⚠️ 重要: v3.2が正式バージョンです。v3.1は参考資料として扱ってください。**