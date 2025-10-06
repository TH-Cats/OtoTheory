# M4 実装計画：iOS v1（Proの核）

**作成日**: 2025-10-04  
**ステータス**: 計画中  
**対象**: M4-A（iOS基盤 & Freeパリティ）、M4-B（Pro核）

---

## 📋 目次

1. [概要](#概要)
2. [前提条件](#前提条件)
3. [アーキテクチャ設計](#アーキテクチャ設計)
4. [実装フェーズ](#実装フェーズ)
5. [技術スタック](#技術スタック)
6. [ディレクトリ構成](#ディレクトリ構成)
7. [共通ロジックの抽出](#共通ロジックの抽出)
8. [データ契約](#データ契約)
9. [実装順序](#実装順序)
10. [DoD & 検証](#dod--検証)

---

## 概要

### 目的
**「DAW前処理を数分で」**を**成果物（MIDI）**で実現し、IAPに直結する。

### スコープ

#### M4-A: iOS基盤 & Freeパリティ
- SwiftUIベースのiOSアプリプロジェクト作成
- Web M3相当の機能実装（結果カード、Diatonic、Fretboard二層、プリセット、自動ループ）
- Sketch 3件（ローカル保存）
- PNG/テキスト出力
- 録音UIは非露出（Flag OFF）

#### M4-B: iOS Pro（収益の中核）
- **セクション編集**（Verse/Chorus/Bridge…）
- **MIDI出力**（Chord Track + Section Markers + Guide Tones）
- **Sketch無制限**（クラウド同期）
- **IAP**（¥490/月、7日間無料トライアル）
- **Paywall & 計測**（`paywall_view`, `purchase_success`, `midi_export`）

### 除外事項（M4.1以降）
- Split Bar（1小節=2コード）
- Groove（簡易ドラム）
- ミニベース（Root-5/Walk）
- MIDI多トラック拡張

---

## 前提条件

### 必須ツール
- [ ] Xcode 15.0+
- [ ] iOS 17.0+ SDK
- [ ] Apple Developer Program登録（IAP実装のため）
- [ ] CocoaPods or Swift Package Manager
- [ ] Node.js 18+ & npm（共通ロジックのビルドのため）

### 既存資産
- ✅ Web実装（M0〜M3.5完了）
- ✅ TypeScript共通ロジック（music-theory, chords, scales, etc.）
- ✅ Telemetryイベント定義
- ✅ SSOT v3.1（全ドキュメント整合済み）

### 新規作成が必要
- [ ] iOSアプリプロジェクト（`ototheory-ios/`）
- [ ] 共通ロジックパッケージ（`packages/core/`）
- [ ] バックエンドAPI（Sketch同期、IAP検証）
- [ ] MIDI生成ライブラリ（Swift実装）

---

## アーキテクチャ設計

### 全体構成

```
┌─────────────────────────────────────────────────────┐
│                  OtoTheory Ecosystem                │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────┐      ┌──────────────────┐   │
│  │ Web (Lite)       │      │ iOS App          │   │
│  │ - Next.js        │      │ - SwiftUI        │   │
│  │ - TypeScript     │      │ - Swift          │   │
│  │ - Vercel         │      │ - App Store      │   │
│  └────────┬─────────┘      └────────┬─────────┘   │
│           │                         │             │
│           └───────┬─────────────────┘             │
│                   │                               │
│         ┌─────────▼─────────┐                     │
│         │  Shared Core      │                     │
│         │  (TypeScript)     │                     │
│         ├───────────────────┤                     │
│         │ - Music Theory    │                     │
│         │ - Chord Logic     │                     │
│         │ - Scale Logic     │                     │
│         │ - Progression     │                     │
│         │ - MIDI Writer     │                     │
│         └─────────┬─────────┘                     │
│                   │                               │
│         ┌─────────▼─────────┐                     │
│         │  Backend API      │                     │
│         │  (Vercel/Node)    │                     │
│         ├───────────────────┤                     │
│         │ - Sketch CRUD     │                     │
│         │ - IAP Validation  │                     │
│         │ - Telemetry       │                     │
│         └───────────────────┘                     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### iOS アプリ構成

```
ototheory-ios/
├── OtoTheory/
│   ├── App/
│   │   ├── OtoTheoryApp.swift          # SwiftUIアプリエントリポイント
│   │   ├── ContentView.swift           # ルートビュー
│   │   └── AppState.swift              # グローバル状態管理
│   │
│   ├── Features/
│   │   ├── Progression/
│   │   │   ├── ProgressionView.swift
│   │   │   ├── ProgressionViewModel.swift
│   │   │   └── Components/
│   │   │       ├── ChordChipView.swift
│   │   │       ├── ProgressionPlayerView.swift
│   │   │       └── PresetPickerView.swift
│   │   │
│   │   ├── FindChords/
│   │   │   ├── FindChordsView.swift
│   │   │   ├── FindChordsViewModel.swift
│   │   │   └── Components/
│   │   │       ├── KeyPickerView.swift
│   │   │       ├── ScalePickerView.swift
│   │   │       └── DiatonicTableView.swift
│   │   │
│   │   ├── Fretboard/
│   │   │   ├── FretboardView.swift
│   │   │   ├── FretboardViewModel.swift
│   │   │   └── Components/
│   │   │       ├── FretView.swift
│   │   │       ├── StringView.swift
│   │   │       └── DotView.swift
│   │   │
│   │   ├── Sketch/
│   │   │   ├── SketchListView.swift
│   │   │   ├── SketchViewModel.swift
│   │   │   └── Storage/
│   │   │       ├── LocalSketchStorage.swift
│   │   │       └── CloudSketchStorage.swift
│   │   │
│   │   ├── Section/ (Pro)
│   │   │   ├── SectionEditorView.swift
│   │   │   ├── SectionViewModel.swift
│   │   │   └── Models/
│   │   │       └── Section.swift
│   │   │
│   │   ├── Export/
│   │   │   ├── ExportView.swift
│   │   │   ├── ExportViewModel.swift
│   │   │   └── Exporters/
│   │   │       ├── PNGExporter.swift
│   │   │       ├── TextExporter.swift
│   │   │       └── MIDIExporter.swift (Pro)
│   │   │
│   │   └── Settings/
│   │       ├── SettingsView.swift
│   │       ├── SubscriptionView.swift (Pro)
│   │       └── PaywallView.swift (Pro)
│   │
│   ├── Core/
│   │   ├── Audio/
│   │   │   ├── AudioPlayer.swift
│   │   │   ├── SoundFontPlayer.swift
│   │   │   └── ChordPlayer.swift
│   │   │
│   │   ├── MIDI/
│   │   │   ├── MIDIWriter.swift
│   │   │   ├── MIDITrack.swift
│   │   │   └── MIDIMarker.swift
│   │   │
│   │   ├── Theory/ (Bridge to JS Core)
│   │   │   ├── TheoryBridge.swift
│   │   │   ├── ChordParser.swift
│   │   │   └── ScaleEngine.swift
│   │   │
│   │   ├── Telemetry/
│   │   │   ├── TelemetryService.swift
│   │   │   └── Events.swift
│   │   │
│   │   └── IAP/
│   │       ├── IAPManager.swift
│   │       ├── ProductIDs.swift
│   │       └── ReceiptValidator.swift
│   │
│   ├── Shared/
│   │   ├── Models/
│   │   │   ├── Sketch.swift
│   │   │   ├── Chord.swift
│   │   │   ├── Key.swift
│   │   │   └── Scale.swift
│   │   │
│   │   ├── Extensions/
│   │   │   ├── Color+Theme.swift
│   │   │   ├── View+Extensions.swift
│   │   │   └── String+Extensions.swift
│   │   │
│   │   └── Utilities/
│   │       ├── Logger.swift
│   │       └── FeatureFlags.swift
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   ├── Localizable.strings (ja/en)
│   │   └── SoundFonts/
│   │
│   └── Info.plist
│
├── OtoTheoryTests/
├── OtoTheoryUITests/
└── Packages/
    └── OtoTheoryCore/  # Shared JS/TS Logic (Bridged)
```

---

## 実装フェーズ

### Phase 0: 環境構築（1-2日）
- [ ] Xcodeプロジェクト作成（`ototheory-ios`）
- [ ] SwiftUI + MVVM構成のセットアップ
- [ ] 共通ロジックパッケージ（`packages/core`）の抽出
- [ ] TypeScript → Swift Bridgeの検証（JavaScriptCore or WASM）
- [ ] Git submodule or monorepo構成の決定

### Phase 1: M4-A 基盤（3-5日）
- [ ] **Navigation & Routing**
  - Tab Bar（Progression, Find Chords, Settings）
  - Screen遷移
- [ ] **Audio Engine**
  - AVFoundation + SoundFont Player
  - Single note playback
  - Chord playback（同時 or 軽ストラム）
  - 最大6声、voice-stealing
- [ ] **Theory Bridge**
  - 共通ロジック（chord parsing, scale generation）のSwift Bridge
  - Key/Scale picker
  - Diatonic chord generation

### Phase 2: M4-A Freeパリティ（5-7日）
- [ ] **Progression View（Lite）**
  - 12コード上限
  - D&D + Delete
  - Cursor-based insertion
  - Playback controls（Play/Stop, BPM）
  - 自動ループ（4拍/4拍子）
- [ ] **Find Chords View**
  - Key/Scale picker
  - Diatonic table（Open row）
  - Scale Table（2-3件 + Why + ⓘGlossary + アルペジオ）
  - Chord Forms（Open/Barre + 試聴）
  - 基礎代理コード（2-3件 + 試聴/+Add）
- [ ] **Fretboard View（二層）**
  - Scale層（輪郭/小/無地）
  - Chord層（塗り/大/ラベル）
  - Degrees/Names toggle
  - Reset（Chordのみ）
  - Tap to play note
- [ ] **Preset System**
  - 20種のプリセット
  - Popup UI
  - Preset insertion（空きスロットから追加）
- [ ] **Sketch（ローカル3件）**
  - Save/Load/Delete
  - Auto-save（3秒idle）
  - LRU overwrite
  - Local storage（UserDefaults or FileManager）
- [ ] **PNG/Text Export**
  - PNG: 白背景固定、構造化レイアウト
  - Text: Key/Scale/Progression/Diatonic/Capo
  - Share Sheet統合

### Phase 3: M4-B Pro核（7-10日）
- [ ] **IAP Setup**
  - Product ID: `com.thquest.ototheory.pro.monthly`
  - 価格: ¥490/月
  - 7日間無料トライアル
  - StoreKit 2統合
  - Receipt validation（サーバー連携）
- [ ] **Paywall**
  - 初回起動時の説明
  - Feature gating（MIDI/Section/Unlimited Sketch）
  - CTA配置（Sketch 4件目、MIDI export試行時）
  - 計測（`paywall_view`, `purchase_success`）
- [ ] **Section Editor（Pro）**
  - Section種別（Intro/Verse/Chorus/Bridge/Outro）
  - Section単位の選択・再生
  - Section名のカスタマイズ
  - Progressionへの紐付け
- [ ] **MIDI Export（Pro）**
  - SMF Type-1生成
  - **Track 1: Chord Track**（Triad/7th）
  - **Track 2: Guide Tones**（3rd/7th）
  - **Markers: Section boundaries**
  - BPM/Key signature/Time signature metadata
  - Share Sheet統合
  - 計測（`midi_export{tracks, sections, bpm}`）
- [ ] **Cloud Sketch Sync（Pro）**
  - Backend API（`/api/sketch/*`）
  - iCloud or Firebase連携
  - Conflict resolution（last-write-wins）
  - Offline support
  - Unlimited storage

### Phase 4: Polish & QA（3-5日）
- [ ] **Telemetry統合**
  - 全イベント実装確認
  - Analytics dashboard連携
- [ ] **A11y対応**
  - VoiceOver対応
  - Dynamic Type対応
  - High Contrast対応
- [ ] **E2E Testing**
  - XCUITest
  - 主要フロー（Preset→Loop→PNG, Preset→Loop→MIDI）
- [ ] **App Store準備**
  - Screenshots（6.7", 6.5", 5.5"）
  - App Preview video
  - Description（JP/EN）
  - Privacy Policy/Terms URLリンク
  - App Store Connect設定

---

## 技術スタック

### iOS
- **言語**: Swift 5.9+
- **UI**: SwiftUI
- **アーキテクチャ**: MVVM + Combine
- **Audio**: AVFoundation + AudioKit (optional)
- **MIDI**: AudioToolbox (MusicSequence API)
- **IAP**: StoreKit 2
- **Network**: URLSession + async/await
- **Storage**: 
  - Local: UserDefaults (metadata), FileManager (sketches)
  - Cloud: iCloud/Firebase
- **Analytics**: Custom telemetry service → Backend API

### Backend (既存 + 拡張)
- **Platform**: Vercel (Next.js API Routes)
- **Language**: TypeScript/Node.js
- **Database**: Vercel Postgres or Firebase Firestore
- **Auth**: Sign in with Apple (AppleID.auth)
- **IAP Validation**: Apple Server-to-Server Notifications

### Shared Core (TypeScript)
- **Package**: `@ototheory/core`
- **Modules**:
  - `music-theory`: Pitch classes, intervals, scales
  - `chords`: Chord parsing, normalization, qualities
  - `progressions`: Progression generation, presets
  - `roman`: Roman numeral conversion
  - `midi-writer`: MIDI SMF generation (可能であれば)

### Bridge Strategy
**Option A: JavaScriptCore**
- TypeScriptをJSにビルド
- JSCoreでSwiftから呼び出し
- Pros: 既存ロジック再利用、高速
- Cons: デバッグが難しい、型安全性が低い

**Option B: WASM (WebAssembly)**
- TypeScript→WASM（via AssemblyScript）
- SwiftからWASMランタイム経由で呼び出し
- Pros: 型安全、パフォーマンス
- Cons: セットアップコスト高、ライブラリサポート限定的

**Option C: Pure Swift Rewrite**
- 音楽理論ロジックをSwiftで再実装
- Pros: 完全ネイティブ、デバッグ容易
- Cons: 実装コスト高、メンテナンスが2重

**推奨**: **Option A (JavaScriptCore)** → 将来的にOption Cへ移行

---

## ディレクトリ構成

```
/Users/nh/App/OtoTheory/
├── docs/                      # 既存
├── ototheory-web/             # 既存（Web Lite）
├── ototheory-ios/             # 新規（iOS App）
│   ├── OtoTheory.xcodeproj
│   ├── OtoTheory/
│   │   ├── App/
│   │   ├── Features/
│   │   ├── Core/
│   │   ├── Shared/
│   │   └── Resources/
│   └── Packages/
│       └── OtoTheoryCore/     # 共通ロジック（Bridge用）
│
├── packages/                  # 新規（共通パッケージ）
│   └── core/
│       ├── package.json
│       ├── tsconfig.json
│       ├── src/
│       │   ├── music-theory/
│       │   ├── chords/
│       │   ├── scales/
│       │   ├── progressions/
│       │   ├── roman/
│       │   └── midi/
│       └── dist/              # ビルド成果物（JS）
│
└── backend/                   # 新規 or ototheory-web/src/app/api拡張
    ├── api/
    │   ├── sketch/
    │   │   ├── list.ts
    │   │   ├── create.ts
    │   │   ├── update.ts
    │   │   └── delete.ts
    │   ├── iap/
    │   │   └── validate.ts
    │   └── telemetry/
    │       └── collect.ts
    └── lib/
        ├── db.ts
        └── auth.ts
```

---

## 共通ロジックの抽出

### 抽出対象（ototheory-web/src/lib → packages/core/src）

#### 1. Music Theory
- `lib/music-theory.ts` → `packages/core/src/music-theory/`
  - `PITCHES`, `PC_NAMES`
  - `transpose()`, `interval()`
  - `normalizeChordSymbol()`

#### 2. Chords
- `lib/chords/` → `packages/core/src/chords/`
  - `format.ts`: Chord symbol formatting
  - `normalize.ts`: Chord normalization
  - `types.ts`: Chord quality types
  - `substitute.ts`: Substitute chord logic

#### 3. Scales
- `lib/scales.ts`, `lib/scaleCatalog.ts` → `packages/core/src/scales/`
  - Scale definitions（Ionian, Dorian, etc.）
  - Scale degree calculation
  - Diatonic chord generation

#### 4. Progressions
- `lib/presets.ts` → `packages/core/src/progressions/`
  - 20 preset patterns
  - Progression validation
  - Progression normalization

#### 5. Roman Numerals
- `lib/roman.ts`, `lib/theory/roman/` → `packages/core/src/roman/`
  - Roman numeral to chord conversion
  - Pattern matching
  - Degree calculation

#### 6. MIDI Writer (新規実装)
- `packages/core/src/midi/`
  - MIDI SMF Type-1 generation
  - Chord Track generation
  - Guide Tone generation
  - Marker generation

### パッケージ構成

```json
// packages/core/package.json
{
  "name": "@ototheory/core",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "jest",
    "watch": "tsc --watch"
  },
  "dependencies": {},
  "devDependencies": {
    "typescript": "^5.0.0",
    "jest": "^29.0.0"
  }
}
```

### Bridge実装例（JavaScriptCore）

```swift
// OtoTheory/Core/Theory/TheoryBridge.swift
import JavaScriptCore

class TheoryBridge {
    private let context: JSContext
    
    init() {
        context = JSContext()!
        
        // Load bundled JS
        if let jsPath = Bundle.main.path(forResource: "ototheory-core", ofType: "js"),
           let jsCode = try? String(contentsOfFile: jsPath) {
            context.evaluateScript(jsCode)
        }
    }
    
    func parseChord(_ symbol: String) -> ChordInfo? {
        let result = context.evaluateScript("parseChord('\(symbol)')")
        guard let dict = result?.toDictionary() else { return nil }
        
        return ChordInfo(
            root: dict["root"] as? String ?? "",
            quality: dict["quality"] as? String ?? "",
            bass: dict["bass"] as? String
        )
    }
    
    func getDiatonicChords(key: String, scale: String) -> [String] {
        let result = context.evaluateScript("getDiatonicChords('\(key)', '\(scale)')")
        return result?.toArray() as? [String] ?? []
    }
}
```

---

## データ契約

### Sketch Model（Swift）

```swift
// OtoTheory/Shared/Models/Sketch.swift
struct Sketch: Codable, Identifiable {
    let id: String
    var name: String
    let createdAt: Date
    var updatedAt: Date
    let schema: String // "sketch_v1"
    let appVersion: String
    
    var key: Key
    var capo: Capo
    var progression: Progression
    var fretboardView: FretboardView
    var sections: [Section]? // Pro only
}

struct Key: Codable {
    let tonic: String // "C"
    let scaleId: String // "ionian"
}

struct Capo: Codable {
    let capoFret: Int
    let notation: String // "Shaped"
}

struct Progression: Codable {
    var bars: [Bar]
    let maxBars: Int // 12 for Lite, unlimited for Pro
}

struct Bar: Codable {
    let chord: String // "Cmaj7"
    let beats: Int // 4
}

struct FretboardView: Codable {
    let mode: String // "Degrees" or "Names"
    let showGuides: Bool
}

struct Section: Codable {
    let id: String
    let name: String // "Verse", "Chorus", etc.
    let barRange: Range<Int> // Start and end bar indices
}
```

### MIDI Export Model（Swift）

```swift
// OtoTheory/Core/MIDI/MIDIWriter.swift
struct MIDIExportConfig {
    let bpm: Int // 120
    let timeSignature: (Int, Int) // (4, 4)
    let keySignature: String // "C"
    let tracks: [MIDITrackType]
    let sections: [Section]
}

enum MIDITrackType {
    case chord // Triad/7th
    case guide // 3rd/7th guide tones
}

struct MIDIMarker {
    let name: String // "Verse 1"
    let position: Int // Tick position
}
```

---

## 実装順序

### Week 1: 環境構築 & M4-A基盤
1. Xcodeプロジェクト作成
2. 共通ロジックパッケージ抽出（`packages/core`）
3. JavaScriptCore Bridge実装
4. Audio Engine実装（単音・和音再生）
5. Navigation & Routing

### Week 2: M4-A Freeパリティ（UI）
1. Progression View（12スロット、D&D、Playback）
2. Find Chords View（Key/Scale picker、Diatonic table）
3. Fretboard View（二層、Degrees/Names、Tap to play）
4. Preset System（20種、Popup UI）
5. Sketch（ローカル3件、Save/Load/Delete）

### Week 3: M4-A Freeパリティ（機能）
1. Scale Table（Why + Glossary + アルペジオ）
2. Chord Forms（Open/Barre + 試聴）
3. 基礎代理コード（2-3件 + 試聴/+Add）
4. PNG/Text Export
5. Telemetry統合（Free events）

### Week 4: M4-B Pro核（IAP & Paywall）
1. IAP Setup（StoreKit 2）
2. Backend API（Sketch CRUD、IAP validation）
3. Paywall UI（Feature gating、CTA）
4. 計測（`paywall_view`, `purchase_success`）

### Week 5: M4-B Pro核（Section & MIDI）
1. Section Editor（Verse/Chorus/Bridge）
2. Section-aware playback
3. MIDI Writer（Chord Track + Guide Tones）
4. MIDI Marker generation（Sections）
5. MIDI Export UI & Share Sheet

### Week 6: M4-B Pro核（Cloud Sketch）
1. Backend API（Sketch sync）
2. iCloud/Firebase統合
3. Conflict resolution
4. Offline support
5. Unlimited storage

### Week 7: Polish & QA
1. Telemetry最終確認（全イベント）
2. A11y対応（VoiceOver、Dynamic Type）
3. E2E Testing（XCUITest）
4. App Store準備（Screenshots、Description）
5. TestFlight配信

---

## DoD & 検証

### M4-A: iOS Free DoD

| 項目 | 検証方法 | 期待結果 |
|------|---------|---------|
| Web M3パリティ | 手動テスト | すべての機能が2タップ以内で実行可能 |
| Audio再生 | 単音・和音再生確認 | クリア・遅延なし |
| Fretboard二層 | Scale/Chord層の切り替え | 正しく表示・リセット動作 |
| Preset 20種 | 全プリセット挿入確認 | 空きスロットから正しく追加 |
| Sketch 3件 | Save/Load/Delete確認 | LRU overwrite動作 |
| PNG/Text Export | Export & Share確認 | 白背景固定、正しいフォーマット |
| 録音UI非露出 | メニュー確認 | Analyze画面が存在しない |

### M4-B: iOS Pro DoD

| 項目 | 検証方法 | 期待結果 |
|------|---------|---------|
| IAP購入フロー | Sandbox環境で購入 | 正常に購入・復元可能 |
| Paywall表示 | Free機能からPro機能アクセス | Paywallが表示される |
| Section編集 | Section追加・編集・削除 | 再生に反映される |
| MIDI Export | Logic Pro/Cubaseで読み込み | Chord Track + Markers + Guide Tonesが正しく表示 |
| Cloud Sketch Sync | 複数デバイスで確認 | 同期・Conflict resolutionが正常動作 |
| Telemetry | Analytics dashboard確認 | `paywall_view`, `purchase_success`, `midi_export`が記録される |

---

## 次のアクション

### 即座に実施
1. ✅ **M4実装計画の策定**（このドキュメント）
2. [ ] **ユーザーに確認**: iOS開発環境の有無、開発リソース、優先順位
3. [ ] **決定**: Bridge Strategy（JavaScriptCore vs Pure Swift）
4. [ ] **決定**: Backend Strategy（Vercel拡張 vs 独立サーバー）
5. [ ] **決定**: Cloud Storage（iCloud vs Firebase）

### 環境構築フェーズ
1. [ ] Xcodeプロジェクト作成
2. [ ] 共通ロジックパッケージ抽出
3. [ ] Bridge実装
4. [ ] Backend API基盤構築
5. [ ] 開発・ステージング環境セットアップ

### 実装フェーズ
- **Week 1-3**: M4-A（iOS基盤 & Freeパリティ）
- **Week 4-6**: M4-B（Pro核）
- **Week 7**: Polish & QA

---

## 備考

### リスク & 課題
1. **iOS開発経験**: SwiftUI/Swift経験が必要
2. **MIDI生成**: AudioToolbox APIの学習コスト
3. **IAP実装**: StoreKit 2の実装・テスト環境
4. **Cloud Sync**: Conflict resolution・Offline supportの複雑性
5. **Bridge Strategy**: TypeScript→Swift Bridgeの性能・デバッグ性

### 代替案
- **React Native**: Web共通化の可能性はあるが、MIDIライブラリサポートが限定的
- **Flutter**: DartでのMIDI実装が必要、学習コスト高
- **Pure Native**: 推奨。App Storeの審査・パフォーマンスに有利

### 外部リソース
- **音源**: SoundFont（FluidSynth or SF2）
- **MIDI Library**: AudioToolbox（Native）or MIDIKit（SPM）
- **IAP Library**: StoreKit 2（Native）or RevenueCat
- **Analytics**: Custom or Firebase Analytics

---

**M4実装計画策定完了。次はユーザーとの合意形成と環境構築フェーズに進みます。** 🚀

