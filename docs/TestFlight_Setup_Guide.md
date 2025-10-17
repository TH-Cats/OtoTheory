# TestFlight Setup Guide

**App**: OtoTheory  
**Version**: 1.0  
**Build**: 1  
**Bundle ID**: TH-Quest.OtoTheory  
**Date**: 2025-10-17

---

## 📋 Current Build Information

- **Bundle Identifier**: `TH-Quest.OtoTheory`
- **Marketing Version**: `1.0`
- **Build Number**: `1`
- **Product Name**: `OtoTheory`

---

## 🎯 TestFlight Deployment Overview

### Timeline
- **Archive Build**: 1 hour
- **Upload to App Store Connect**: 30 minutes
- **Processing**: 10-30 minutes (Apple側)
- **Internal Testing Setup**: 30 minutes
- **Total**: ~2-3 hours

### Deployment Flow
```
Xcode Archive
    ↓
Distribute to App Store Connect
    ↓
Processing (Apple)
    ↓
TestFlight Internal Testing
    ↓
Invite Testers
    ↓
Feedback Collection
```

---

## 📱 Step 1: Archive Build

### Prerequisites
- ✅ Code cleanup完了（警告0）
- ✅ ビルド成功確認済み
- ✅ Code Signing設定完了
- ✅ Provisioning Profile有効

### Archive Steps

#### 1.1 Xcodeでプロジェクトを開く
```bash
open /Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory.xcodeproj
```

#### 1.2 Schemeを"Any iOS Device"に設定
1. Xcode上部のデバイス選択 → **Any iOS Device (arm64)**

#### 1.3 Archive作成
1. **Product** → **Archive**
2. ビルドプロセス開始（5-10分）
3. 完了後、Organizerが自動的に開く

#### 1.4 Archive確認
Organizerで以下を確認：
- ✅ Version: 1.0
- ✅ Build: 1
- ✅ Archive日時
- ✅ サイズ

---

## 📤 Step 2: Upload to App Store Connect

### 2.1 Distribute App
1. Organizer → **Distribute App**
2. **App Store Connect** を選択 → **Next**

### 2.2 Distribution Method
1. **Upload** を選択 → **Next**

### 2.3 Distribution Options
- ✅ **Upload your app's symbols**: チェック（推奨）
- ✅ **Manage Version and Build Number**: チェック（推奨）
- **Next**

### 2.4 Re-sign Configuration
- **Automatically manage signing** を選択
- **Next**

### 2.5 Review & Upload
1. Archive内容を最終確認
2. **Upload** をクリック
3. アップロード開始（5-15分、ファイルサイズによる）

### 2.6 Upload完了
- ✅ "Upload Successful" メッセージ確認
- **Done** をクリック

---

## 🍎 Step 3: App Store Connect Setup

### 3.1 App Store Connectにログイン
```
https://appstoreconnect.apple.com
```

### 3.2 My Appsへ移動
1. **My Apps** をクリック
2. **OtoTheory** を選択（または新規作成）

### 3.3 App Information入力（初回のみ）

#### Basic Information
- **Name**: OtoTheory
- **Bundle ID**: TH-Quest.OtoTheory
- **SKU**: ototheory-ios-001（任意のユニークID）
- **Primary Language**: Japanese

#### Category
- **Primary**: Music
- **Secondary**: Education

#### Pricing and Availability
- **Price**: Free
- **Availability**: All countries

---

## 🧪 Step 4: TestFlight Internal Testing

### 4.1 TestFlightタブへ移動
1. App Store Connect → **OtoTheory** → **TestFlight**

### 4.2 Build確認
1. **iOS Builds** セクション確認
2. ビルド **1.0 (1)** が表示されるまで待機（10-30分）
3. Status: **Processing** → **Ready to Test**

### 4.3 Internal Testing設定

#### Add Internal Testers
1. **Internal Testing** セクション → **+** ボタン
2. テスターを選択（Apple Developer Program登録済みの人）
3. **Add** をクリック

#### What to Test（テスト指示）
```
【テスト項目 v1.0 (Build 1)】

基本機能:
- Chord Progression（コード追加・削除・再生）
- Find Chords（解析・Diatonic・Fretboard表示）
- Chord Library（フォーム表示・再生）
- Sketches（保存・読み込み）

Pro機能（要購入テスト）:
- Sections（セクション編集）
- MIDI Export
- Unlimited Sketches
- iCloud Sync

確認ポイント:
✓ クラッシュなし
✓ UI表示崩れなし
✓ Audio再生問題なし
✓ 横向き対応（Chord Library/Fretboard）

フィードバック: support@ototheory.com
```

### 4.4 テスター招待
1. テスターがTestFlightアプリで通知を受信
2. **Accept** → **Install**
3. テスト開始

---

## 📧 Step 5: Tester Communication

### Internal Tester Email Template

**Subject**: OtoTheory v1.0 - TestFlight Internal Testing開始

```
こんにちは、

OtoTheory v1.0 (Build 1) のTestFlight内部テストを開始します。

【アプリ概要】
ギタリスト向けのコード進行作成＆スケール分析アプリです。

【テスト期間】
2025/10/17 ～ 2025/10/24（1週間）

【テスト手順】
1. TestFlightアプリでOtoTheoryを開く
2. 「インストール」をタップ
3. アプリを起動してテスト実施
4. 問題やフィードバックをレポート

【重点テスト項目】
✓ Chord Progression機能（コード追加・再生）
✓ Find Chords機能（解析・フレットボード表示）
✓ Chord Library（コードフォーム表示）
✓ Sketches保存・読み込み
✓ Pro機能（セクション・MIDI Export）※要購入

【フィードバック方法】
- TestFlightアプリ内のフィードバック機能
- または support@ototheory.com へメール

【注意事項】
- 開発中のため、バグや不具合がある可能性があります
- Pro機能テストには課金が必要です（テスト用Promo Codeは別途配布予定）

よろしくお願いします！

OtoTheory開発チーム
```

---

## 🔍 Step 6: Monitoring & Feedback

### TestFlight Analytics確認
1. App Store Connect → TestFlight → **OtoTheory**
2. **TestFlight Analytics** タブ
3. 確認項目：
   - Installs数
   - Sessions数
   - Crashes数
   - Feedback数

### Crash Reports確認
1. Xcode → **Window** → **Organizer**
2. **Crashes** タブ
3. TestFlight buildsのクラッシュログ確認

### Feedback収集
1. TestFlightアプリ内フィードバック
2. Email (support@ototheory.com)
3. 直接コミュニケーション

---

## 📝 Step 7: Iterate (Optional)

### 問題が見つかった場合

#### 7.1 修正実施
1. Xcodeでコード修正
2. Build Numberをインクリメント（1 → 2）
3. 再度Archive & Upload

#### 7.2 新しいBuildをTestFlightに追加
1. App Store Connect → TestFlight
2. 新しいBuild (1.0 (2)) 追加
3. Internal Testersに通知

#### 7.3 テスター更新
- TestFlightアプリで自動的に更新通知
- **Update** → テスト継続

---

## ✅ Step 8: Ready for External Beta (Optional)

### Internal Testing完了後
1. 問題なし確認
2. **External Testing** 準備
3. Beta App Review提出

### External Testing準備
- Beta App Description作成
- Test Information入力
- External Testersグループ作成（最大10,000人）
- Beta App Review提出（1-2日）

---

## 🚀 Step 9: App Store Submission

### TestFlight完了後
1. 最終版Build確認
2. **App Store** タブへ移動
3. **Version 1.0** 作成
4. メタデータ入力
5. スクリーンショットアップロード
6. **Submit for Review**

---

## 📊 Checklist - TestFlight Deployment

### Before Archive
- [x] ビルド成功確認（警告0）
- [x] Code Signing設定完了
- [x] Version/Build Number設定（1.0/1）
- [ ] App Icon設定確認（1024x1024）
- [ ] Launch Screen設定確認

### Archive & Upload
- [ ] Archive作成成功
- [ ] Upload to App Store Connect完了
- [ ] Processing完了確認

### TestFlight Setup
- [ ] Internal Testing有効化
- [ ] What to Test記入
- [ ] Internal Testersを招待

### Testing Phase
- [ ] テスターがインストール確認
- [ ] 基本機能テスト完了
- [ ] Pro機能テスト完了
- [ ] Crash/Bug報告なし

### Next Steps Decision
- [ ] External Beta実施判断
- [ ] または App Store直接申請判断

---

## 🆘 Troubleshooting

### Archive失敗
**問題**: Archive作成時にエラー
**解決**:
1. Code Signing確認
2. Provisioning Profile更新
3. Clean Build Folder (`Cmd+Shift+K`)
4. Derived Data削除

### Upload失敗
**問題**: App Store Connectへのアップロード失敗
**解決**:
1. ネットワーク接続確認
2. Apple Developer Program有効期限確認
3. Application Loaderで再試行

### Processing長時間
**問題**: "Processing" が30分以上継続
**解決**:
- 正常な場合もあり（最大2時間）
- Apple側のサーバー状況に依存
- 待機推奨

### TestFlightにBuildが表示されない
**問題**: Upload完了後もBuildが見えない
**解決**:
1. Encryption設定確認（Export Compliance）
2. Missing Complianceステータス確認
3. App Store Connect → TestFlight → Builds確認

---

## 📞 Support Contacts

**Apple Developer Support**: https://developer.apple.com/support/
**App Store Connect Help**: https://help.apple.com/app-store-connect/

---

**Status**: ✅ Ready for TestFlight Deployment
**Next Action**: Archive Build in Xcode

