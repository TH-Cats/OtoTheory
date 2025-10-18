# App Store Submission - Final Checklist

**App**: OtoTheory  
**Version**: 1.0  
**Build**: 1  
**Bundle ID**: TH-Quest.OtoTheory  
**Date**: 2025-10-17  
**Status**: Ready for TestFlight 🚀

---

## 📋 Pre-Submission Checklist

### ✅ 1. Documentation (完了)

- [x] **App Store Metadata**: 日本語・英語完成
  - `/docs/App_Store_Metadata_Final.md`
- [x] **TestFlight Guide**: TestFlight配信手順完成
  - `/docs/TestFlight_Setup_Guide.md`
- [x] **Screenshots Guide**: スクリーンショット整理ガイド完成
  - `/docs/Screenshots_Organization_Guide.md`
- [x] **Code Cleanup Report**: クリーンアップ完了レポート
  - `/docs/reports/iOS_Code_Cleanup_Report.md`

### ✅ 2. Build Configuration (確認済み)

- [x] **Bundle ID**: `TH-Quest.OtoTheory`
- [x] **Version**: `1.0`
- [x] **Build Number**: `1`
- [x] **Product Name**: `OtoTheory`
- [x] **Build Success**: ✅ (0 warnings, 0 errors)

### 📸 3. Screenshots (提供済み)

#### iPhone 6.7" (1290 x 2796)
- [x] 1. Chord Progression（メイン機能）
- [x] 2. Fretboard - C major scale（横・黒背景）
- [x] 3. Find Chords - Result（Diatonic + Patterns）
- [x] 4. Sketches（保存機能）
- [x] 5. Chord Library - Cmaj7（横・黒背景）

#### iPad Pro 12.9" (2048 x 2732)
- [x] 1. Find Chords - Fretboard + Diatonic（2層・縦）
- [x] 2. Chord Library - Gsus4（横・詳細UI）
- [x] 3. Build Progression - Preset Picker（横）
- [x] 4. Find Chords - D Phrygian（横・完全版）
- [x] 5. Find Chords - Roman Numerals（縦・Save機能）

**Action Required**: スクリーンショットファイルを整理してApp Store Connectアップロード準備

### 🔐 4. Code Signing (要確認)

- [ ] **Provisioning Profile**: App Store Distribution
- [ ] **Certificate**: Apple Distribution Certificate有効期限確認
- [ ] **Capabilities**: 
  - [ ] In-App Purchase
  - [ ] iCloud (CloudKit)
  - [ ] Push Notifications（将来用、オプション）

**Action Required**: Xcode → Signing & Capabilities確認

### 🎨 5. Assets (要確認)

- [ ] **App Icon**: 1024x1024 設定確認
  - Path: `OtoTheory-iOS/OtoTheory/Assets.xcassets/AppIcon.appiconset/`
- [ ] **Launch Screen**: 設定確認
  - Path: `OtoTheory-iOS/OtoTheory/LaunchScreen.storyboard` または SwiftUI

**Action Required**: Xcode → Assets.xcassets確認

### 📄 6. Legal & Privacy (要作成/確認)

#### URLs Required
- [ ] **Privacy Policy**: https://ototheory.com/privacy
- [ ] **Terms of Service**: https://ototheory.com/terms
- [ ] **Support URL**: https://ototheory.com/support

**Action Required**: 
1. プライバシーポリシー・利用規約をWebサイトに公開
2. URLが有効か確認
3. App Store Connectに入力

#### Privacy Manifest (iOS 17+推奨)
- [ ] **PrivacyInfo.xcprivacy**: 作成確認
  - Tracking使用の有無
  - Required Reason API使用の有無
  - Data Collection詳細

**Action Required**: 必要に応じてPrivacy Manifest作成

### 💰 7. In-App Purchase (要設定)

#### Product Configuration
- [ ] **Product ID**: `com.ototheory.pro.monthly`（確認必要）
- [ ] **Type**: Auto-Renewable Subscription
- [ ] **Price**: ¥490/month
- [ ] **Localization**: 日本語・英語
- [ ] **Review Information**: スクリーンショット、説明

**Action Required**: 
1. App Store Connect → Features → In-App Purchases
2. Product作成・設定
3. "Ready to Submit"ステータス確認

### 🧪 8. Testing (実施推奨)

#### Device Testing
- [ ] iPhone実機テスト（iPhone 12以降推奨）
- [ ] iPad実機テスト（iPad Pro推奨）
- [ ] iOS 17.0 最低動作確認
- [ ] iOS 18.0 最新バージョン確認

#### Functional Testing
- [ ] Chord Progression（追加・削除・再生）
- [ ] Find Chords（解析・Diatonic・Fretboard）
- [ ] Chord Library（フォーム表示・再生）
- [ ] Sketches（保存・読み込み・3件制限）
- [ ] Pro機能（Paywall表示、購入フロー）
- [ ] Audio再生（HybridPlayer、音質）

#### UI/UX Testing
- [ ] 縦向き・横向き対応
- [ ] Safe Area対応（ノッチ、ホームインジケーター）
- [ ] ダークモード対応
- [ ] Dynamic Type対応（文字サイズ）
- [ ] VoiceOver基本対応（アクセシビリティ）

#### Performance Testing
- [ ] 起動時間 < 3秒
- [ ] メモリリークなし
- [ ] クラッシュなし
- [ ] ネットワークエラーハンドリング

**Action Required**: 実機で主要機能をテスト

---

## 🚀 TestFlight Deployment Steps

### Step 1: Archive Build
```bash
# Xcodeでプロジェクトを開く
open /Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory.xcodeproj

# 手順:
# 1. デバイス選択: Any iOS Device (arm64)
# 2. Product → Archive
# 3. Organizer確認
```

### Step 2: Upload to App Store Connect
```
# Organizer手順:
# 1. Distribute App
# 2. App Store Connect → Upload
# 3. Distribution Options: 
#    - Upload your app's symbols ✓
#    - Manage Version and Build Number ✓
# 4. Automatically manage signing
# 5. Upload (5-15分)
```

### Step 3: TestFlight Setup
```
# App Store Connect手順:
# 1. https://appstoreconnect.apple.com
# 2. My Apps → OtoTheory → TestFlight
# 3. Build (1.0 (1)) が "Ready to Test" になるまで待機
# 4. Internal Testing → Add Testers
# 5. What to Test 記入
```

### Step 4: Monitor Testing
```
# 監視項目:
# - TestFlight Analytics (Installs, Sessions, Crashes)
# - Crash Reports (Xcode Organizer)
# - Feedback (TestFlight app内)
```

---

## 📱 App Store Submission Steps (TestFlight後)

### Step 1: Create Version
```
# App Store Connect:
# 1. My Apps → OtoTheory → App Store
# 2. + Version → 1.0
```

### Step 2: Metadata Input
```
# 日本語版:
# - アプリ名: OtoTheory
# - サブタイトル: 苦手な理論を味方に変えるギタリストの作曲・ソロ創作支援アプリ
# - キーワード: (App_Store_Metadata_Final.mdから)
# - 説明文: (App_Store_Metadata_Final.mdから)
# - What's New: 初回リリース内容
```

### Step 3: Screenshots Upload
```
# iPhone 6.7" (5枚)
# iPad 12.9" (5枚)
# Captions（オプション）
```

### Step 4: Build Selection
```
# Build: 1.0 (1)
```

### Step 5: Pricing & Availability
```
# - Price: Free
# - Availability: All countries
```

### Step 6: Age Rating
```
# Questionnaire:
# - Violence: None
# - Medical: None
# - Gambling: None
# → Result: 4+
```

### Step 7: Review Information
```
# - First Name / Last Name
# - Phone / Email
# - Demo Account: Not required
# - Notes: (App_Store_Metadata_Final.mdから)
```

### Step 8: Submit for Review
```
# - Final review
# - Submit for Review
# → Status: Waiting for Review
```

---

## ⏱️ Timeline Estimation

### TestFlight Deployment
- Archive Build: 30分
- Upload: 30分
- Processing: 10-30分
- Internal Testing Setup: 30分
- **Total**: 2-3時間

### Testing Period
- Internal Testing: 3-7日
- Bug Fixes (if needed): 1-3日
- **Total**: 1-2週間

### App Store Review
- Review Queue: 1-3日
- Review Process: 1-2日
- **Total**: 2-5日

### **Total Timeline: 2-3週間**

---

## ✅ Final Verification

### Before Archive
- [ ] ビルド成功（警告0）
- [ ] Version/Build Number確認（1.0/1）
- [ ] Code Signing設定完了
- [ ] App Icon設定確認
- [ ] Privacy URLs準備完了

### Before TestFlight
- [ ] Archive成功
- [ ] Upload成功
- [ ] What to Test記入
- [ ] Internal Testers招待準備

### Before App Store Submission
- [ ] TestFlight testing完了
- [ ] クラッシュなし確認
- [ ] スクリーンショット準備完了
- [ ] メタデータ完成（日英）
- [ ] IAP設定完了
- [ ] Privacy/Support URLs有効

---

## 🎯 Success Criteria

### TestFlight Success
- ✅ 最低2名のInternal Testerがテスト
- ✅ クラッシュ率 < 0.1%
- ✅ 重大なバグ報告なし
- ✅ 基本機能すべて動作確認

### App Store Approval
- ✅ Review Guidelinesに準拠
- ✅ メタデータ正確
- ✅ スクリーンショット適切
- ✅ プライバシー情報完全
- ✅ IAP適切に実装

---

## 📞 Support & Resources

### Documentation
- ✅ `App_Store_Metadata_Final.md`
- ✅ `TestFlight_Setup_Guide.md`
- ✅ `Screenshots_Organization_Guide.md`
- ✅ `iOS_Code_Cleanup_Report.md`

### External Resources
- **App Store Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **App Store Connect Help**: https://help.apple.com/app-store-connect/
- **TestFlight Guide**: https://developer.apple.com/testflight/
- **Human Interface Guidelines**: https://developer.apple.com/design/human-interface-guidelines/

### Contact
- **Developer Email**: support@ototheory.com
- **Apple Developer Support**: https://developer.apple.com/support/

---

## 🚨 Risk Assessment

### High Priority (Must Fix Before Submission)
- ❗ Privacy Policy URL must be live
- ❗ Support URL must be functional
- ❗ IAP Product ID must be configured
- ❗ App Icon must be set (1024x1024)

### Medium Priority (Fix Before TestFlight)
- ⚠️ Code Signing configuration
- ⚠️ Device testing (iPhone/iPad実機)
- ⚠️ Crash/Bug testing

### Low Priority (Can Fix After TestFlight)
- ℹ️ English localization（将来）
- ℹ️ Privacy Manifest（iOS 17+推奨）
- ℹ️ Additional screenshots（6-8枚目）

---

## 📊 Status Summary

| Category | Status | Progress |
|----------|--------|----------|
| **Documentation** | ✅ Complete | 100% |
| **Build Configuration** | ✅ Verified | 100% |
| **Screenshots** | ✅ Ready | 100% |
| **Code Signing** | ⏳ Pending | 0% |
| **Assets** | ⏳ Pending | 0% |
| **Legal & Privacy** | ⏳ Pending | 0% |
| **In-App Purchase** | ⏳ Pending | 0% |
| **Testing** | ⏳ Pending | 0% |

### Overall Progress: **35%**

---

## 🎯 Next Immediate Actions

### Priority 1 (今すぐ)
1. ✅ ドキュメント作成完了
2. [ ] App Icon確認（1024x1024）
3. [ ] Code Signing設定確認

### Priority 2 (今日中)
4. [ ] Privacy Policy/Terms公開
5. [ ] IAP Product ID設定
6. [ ] スクリーンショットファイル整理

### Priority 3 (明日)
7. [ ] Archive Build作成
8. [ ] TestFlight Upload
9. [ ] Internal Testing開始

---

**Status**: ✅ Documentation Complete | ⏳ Technical Setup Pending  
**Next Action**: Code Signing & Assets確認  
**Target**: TestFlight配信 (2-3日以内)


