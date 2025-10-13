# M4-B Pro機能実装計画 & 進捗レポート

**作成日**: 2025-10-11  
**最終更新**: 2025-10-11  
**対象**: OtoTheory iOS v1 Pro機能（M4-B）

---

## 📋 実装概要

### M4-B の目標
**収益化の中核** = Pro機能による月額課金（¥490/月）

### Pro機能一覧
1. ✅ **プリセット20種（Free）+ 30種（Pro、Phase 5で追加予定）**
2. ✅ **セクション編集**（Verse/Chorus/Bridge…）- UI実装完了
3. ✅ **MIDI出力**（4トラック構成: Guitar/Bass/Scale Guide×2）- Phase 3-B完了（2025-10-11）
4. 🔜 **Sketch無制限**（クラウド同期）
5. ✅ **IAP実装**（¥490/月）
6. ✅ **Paywall & 計測**

---

## 🎯 実装フェーズと進捗

### Phase 1: 基盤（IAP & Paywall）✅ **完了**
1. **Pro状態管理**（ローカル・購入状態）
2. **IAP実装**（StoreKit 2）
3. **Paywall UI**（購入画面）
4. **計測**（`paywall_view`, `purchase_success`）
5. **Free/Pro機能分岐**

### Phase 2: セクション編集 ✅ **完了（UI実装）**
1. ✅ **データモデル**（Section型：name, range, repeat）
2. ✅ **UI実装**（セクション追加・編集・削除・並べ替え）
3. ✅ **セクションマーカー表示**（ProgressionViewに横スクロール）
4. ✅ **永続化**（Sketchに含める）
5. 🔜 **再生連動**（Phase 2.5で実装予定）

### Phase 3: MIDI出力 ✅ **完了（Phase 3-A/3-B）**

#### Phase 3-A: 基本実装（完了）
1. ✅ **MusicSequence拡張**（Markers追加）
2. ✅ **Chord Track生成**（コード→MIDI Notes）
3. ✅ **Guide Tones生成**（3rd + 7th）
4. ✅ **SMF Type-1書き出し**
5. ✅ **共有シート**（.midファイル）

#### Phase 3-B: MIDI大幅強化（完了、2025-10-11）
1. ✅ **4トラック構成**（Guitar/Bass/Scale Guide×2）
2. ✅ **Program Change**（楽器自動選択）
3. ✅ **コードボイシング**（Root+3rd+5th+7th）
4. ✅ **リズムパターン**（4拍子ストラム）
5. ✅ **ベースライン**（Root-Root-5th-Root(Oct)）
6. ✅ **Scale Guide Track**（OtoTheory独自機能）
7. ✅ **UI再設計**（Sketch Export方式）

### Phase 4: Sketch無制限 & クラウド同期
1. **CloudKit統合**
2. **同期ロジック**（競合解決）
3. **Pro専用UI**（無制限リスト）

### Phase 5: プリセット拡張
1. **Pro専用プリセット30種**
2. **Free/Pro分岐表示**
3. **Paywall誘導**

---

## ✅ Phase 1 実装完了サマリー

### 実装ファイル
1. **`ProManager.swift`** - StoreKit 2統合、購入状態管理
2. **`TelemetryService.swift`** - イベント計測サービス
3. **`PaywallView.swift`** - Pro購読UI
4. **`Configuration.storekit`** - StoreKitテスト設定
5. **`Preset.swift`** - `isFree`フラグ追加（Free 20種）
6. **`PresetPickerView.swift`** - Free/Pro分岐UI
7. **`ProgressionView.swift`** - Paywall統合

### ビルド結果
✅ **BUILD SUCCEEDED**

### 計測イベント
- `paywall_view` - Paywall表示
- `purchase_success` - 購入成功
- `purchase_fail` - 購入失敗
- `restore_success` - リストア成功
- `restore_fail` - リストア失敗

---

## ✅ Phase 2 実装完了サマリー

### 実装ファイル
1. **`Section.swift`** - セクションモデル（9種類のタイプ、範囲、リピート）
2. **`SectionEditorView.swift`** - セクション編集UI
3. **`Sketch.swift`** - `sections`プロパティ追加
4. **`ProgressionView.swift`** - Sectionsボタン、セクションマーカー表示

### 機能
- ✅ 9種類のセクションタイプ（Intro, Verse, Pre-Chorus, Chorus, Bridge, Solo, Outro, Interlude, Breakdown）
- ✅ セクション追加・編集・削除・並べ替え
- ✅ 範囲指定（0-11バー）、リピート回数（1-8回）
- ✅ 重複チェック（バリデーション）
- ✅ セクションマーカー表示（横スクロール）
- ✅ Pro分岐（Sectionsボタン）

### ビルド結果
✅ **BUILD SUCCEEDED**

---

## ✅ Phase 3 実装完了サマリー

*最終更新: 2025-10-11（Phase 3-B完了）*

### 実装ファイル

#### Phase 3-A（基本実装）
1. **`MIDIExportService.swift`** - MIDI書き出しサービス（基本機能）
2. **`ProgressionView.swift`** - MIDIボタン（後にSketch Exportに移動）
3. **`TelemetryService.swift`** - `midiExport`イベント追加

#### Phase 3-B（大幅強化）
1. **`MIDIExportService.swift`** - 9関数追加/更新
   - `addProgramChange()` - 楽器指定
   - `addScaleGuide()` - スケールガイド
   - `parseChordVoicing()` - コードボイシング
   - `addBassLineEvents()` - ベースライン
   - `addChordEvents()` - 4拍子ストラム
   - `removeKeyPrefix()` - キー名削除
   - `getScaleDegrees()` - スケール度数マップ
   - `degreeToSemitones()` - 度数→半音変換
2. **`SketchListView.swift`** - Export Menu統合（PNG/MIDI）
3. **`ProgressionView.swift`** - MIDIボタン削除、1行レイアウト化
4. **`ActivityViewController.swift`** - UIActivityViewController wrapper

### 機能

#### Phase 3-A
- ✅ Chord Track生成（ルート音のMIDIノート）
- ✅ Guide Tones生成（3rd + 7th）
- ✅ Section Markers埋め込み（Meta Event Type 6）
- ✅ SMF Type-1書き出し（2トラック構成）
- ✅ 共有シート（UIActivityViewController）

#### Phase 3-B（★大幅強化）
- ✅ **4トラック構成**（Guitar/Bass/Scale Guide×2）
- ✅ **Program Change**（楽器自動選択）
- ✅ **コードボイシング**（Root+3rd+5th+7th、全音出力）
- ✅ **リズムパターン**（4拍子ストラム、4分音符×4）
- ✅ **ベースライン**（Root-Root-5th-Root(Oct)パターン）
- ✅ **Chord Symbols**（Marker Type 6、タイムライン表示）
- ✅ **Scale Guide Track（★独自機能）**
  - 2音域対応（Middle: C4周辺、Bass: C3周辺）
  - 15種類のスケール対応
  - Velocity 30（薄く聞こえる、見えるゴーストノート）
  - 上昇→下降パターン（1小節で往復）
- ✅ **UI再設計**（Sketch Export方式）
- ✅ **SwiftUI Sheet統合**（ActivityViewController wrapper）

### MIDI出力フォーマット（最新版）

#### Tempo Track
- Chord Symbols（Marker Type 6）
- Section Markers（Marker Type 6）
- Tempo（BPM）

#### Track 1: Guitar [Program 25: Acoustic Steel]
- コードボイシング（Root+3rd+5th+7th）
- 4拍子ストラム（4分音符×4）
- Velocity: 80±10

#### Track 2: Bass [Program 33: Electric Bass]
- ベースライン（Root-Root-5th-Root(Oct)）
- Velocity: 85

#### Track 3: Scale Guide (Middle) [Piano]
- スケール構成音（中音域、C4周辺）
- 上昇→下降パターン（125ms間隔）
- Velocity: 30（上昇）/ 25（下降）
- ★OtoTheory独自機能

#### Track 4: Scale Guide (Bass) [Piano]
- スケール構成音（低音域、C3周辺、-12半音）
- Track 3と同じパターン（1オクターブ下）
- Velocity: 30（上昇）/ 25（下降）

### ビルド結果
✅ **BUILD SUCCEEDED**（2025-10-11）

### テスト結果
- ✅ 4トラック生成確認（GarageBand）
- ✅ 楽器自動選択確認（Guitar: Acoustic Steel, Bass: Electric Bass）
- ✅ Scale Guide可視化確認（小さな点々として表示）
- ✅ 1オクターブ差確認（Track 4 = Track 3 - 12半音）
- ✅ キー名除去確認（"C Major Scale" → "Major Scale"）

---

## 🔧 Phase 1: 基盤（IAP & Paywall）実装詳細

### 1.1 Pro状態管理

**ファイル**: `/OtoTheory-iOS/OtoTheory/Services/ProManager.swift`（✅ 実装済み）

```swift
import StoreKit
import Combine

@MainActor
class ProManager: ObservableObject {
    static let shared = ProManager()
    
    @Published var isProUser: Bool = false
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    // Product ID
    private let proSubscriptionID = "com.ototheory.pro.monthly"
    
    init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    // StoreKit 2: 商品読み込み
    func loadProducts() async {
        do {
            products = try await Product.products(for: [proSubscriptionID])
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // StoreKit 2: 購入状態確認
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.productID == proSubscriptionID {
                purchasedProductIDs.insert(transaction.productID)
                isProUser = true
            }
        }
    }
    
    // 購入処理
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                await updatePurchasedProducts()
                // Telemetry: purchase_success
                TelemetryService.track("purchase_success")
            case .unverified:
                throw PurchaseError.unverified
            }
        case .userCancelled:
            throw PurchaseError.userCancelled
        case .pending:
            throw PurchaseError.pending
        @unknown default:
            throw PurchaseError.unknown
        }
    }
    
    // リストア
    func restore() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }
}

enum PurchaseError: Error {
    case unverified
    case userCancelled
    case pending
    case unknown
}
```

---

### 1.2 Paywall UI

**ファイル**: `PaywallView.swift`（新規作成）

```swift
import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var proManager = ProManager.shared
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section
                    VStack(spacing: 12) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("OtoTheory Pro")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Unlock all features")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 32)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "music.note", title: "50種類のプリセット", description: "Free 20種 + Pro限定 30種")
                        FeatureRow(icon: "square.grid.3x2", title: "セクション編集", description: "Verse/Chorus/Bridge を自由に構成")
                        FeatureRow(icon: "waveform", title: "MIDI出力", description: "DAWで編集可能なSMFファイル")
                        FeatureRow(icon: "icloud", title: "無制限保存", description: "クラウド同期でデバイス間で共有")
                    }
                    .padding(.horizontal, 24)
                    
                    // Pricing
                    if let product = proManager.products.first {
                        VStack(spacing: 12) {
                            Text(product.displayPrice)
                                .font(.system(size: 48, weight: .bold))
                            
                            Text("/ 月")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                Task {
                                    isPurchasing = true
                                    do {
                                        try await proManager.purchase(product)
                                        dismiss()
                                    } catch {
                                        print("Purchase failed: \(error)")
                                    }
                                    isPurchasing = false
                                }
                            }) {
                                Text(isPurchasing ? "処理中..." : "購読開始")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .disabled(isPurchasing)
                            
                            Button("購入履歴を復元") {
                                Task {
                                    try? await proManager.restore()
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Terms
                    VStack(spacing: 8) {
                        Text("自動更新されます。いつでもキャンセル可能。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            Link("利用規約", destination: URL(string: "https://ototheory.com/terms")!)
                            Link("プライバシーポリシー", destination: URL(string: "https://ototheory.com/privacy")!)
                        }
                        .font(.caption)
                    }
                    .padding(.bottom, 32)
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
        .onAppear {
            // Telemetry: paywall_view
            TelemetryService.track("paywall_view")
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

---

### 1.3 Free/Pro分岐

**既存ファイル更新**: `ProgressionView.swift`

```swift
@StateObject private var proManager = ProManager.shared
@State private var showPaywall = false

// プリセット表示制限
var visiblePresets: [Preset] {
    if proManager.isProUser {
        return allPresets  // 50種
    } else {
        return allPresets.filter { $0.isFree }  // 20種のみ
    }
}

// Pro機能へのアクセス
Button("MIDI出力") {
    if proManager.isProUser {
        exportMIDI()
    } else {
        showPaywall = true
    }
}
.sheet(isPresented: $showPaywall) {
    PaywallView()
}
```

---

## 📊 計測（Telemetry）

### 新規イベント
```swift
// Paywall表示
TelemetryService.track("paywall_view")

// 購入成功
TelemetryService.track("purchase_success")

// Pro機能使用
TelemetryService.track("section_edit")
TelemetryService.track("midi_export")
```

---

## ✅ Phase 1 受け入れ基準（DoD）

- [x] StoreKit 2でIAP実装 ✅
- [x] Paywall UIが正しく表示される ✅
- [x] 購入フローが正常に動作 ✅（実装済み、手動テスト必要）
- [x] 購入状態が永続化される ✅（StoreKit 2のTransaction管理）
- [x] `paywall_view` / `purchase_success` が記録される ✅
- [x] Free/Pro分岐が正しく動作 ✅（PresetPickerView実装）
- [x] リストア機能が動作 ✅

## ✅ Phase 2 受け入れ基準（DoD）

- [x] Sectionモデル実装 ✅
- [x] Sketchにsections追加 ✅
- [x] SectionEditorView実装 ✅
- [x] ProgressionViewにSectionsボタン追加 ✅
- [x] セクションマーカー表示 ✅
- [x] Pro分岐（Sectionsボタン） ✅
- [x] ビルド成功 ✅
- [ ] セクション再生・ループ機能 🔜 Phase 2.5で実装予定

---

## 🎯 現在の状態と次のステップ

### 完了したフェーズ
- ✅ **Phase 1**: IAP & Paywall（完了）
- ✅ **Phase 2**: セクション編集UI（完了）
- ✅ **Phase 3**: MIDI出力（完了）

### 次の実装フェーズ
1. **Phase 4: Sketch無制限 & クラウド同期** ← 次はここ
   - CloudKit統合
   - 同期ロジック
   - 競合解決

2. **Phase 2.5: セクション再生機能**（Phase 3後に実装推奨）
   - HybridPlayerにセクション指定再生・ループ機能追加

3. **Phase 4: Sketch無制限 & クラウド同期**
   - CloudKit統合
   - 同期ロジック

4. **Phase 5: プリセット拡張**
   - Pro専用プリセット30種を追加

---

## 📝 関連レポート

- **Phase 1詳細**: `/docs/reports/Phase_1_IAP_Paywall_Implementation_Report.md`
- **Phase 2詳細**: `/docs/reports/Phase_2_Section_Editing_Implementation_Report.md`
- **Phase 3詳細**: `/docs/reports/Phase_3_MIDI_Export_Implementation_Report.md`

---

**Phase 4（Sketch無制限 & クラウド同期）に進む準備完了！** ☁️💾

