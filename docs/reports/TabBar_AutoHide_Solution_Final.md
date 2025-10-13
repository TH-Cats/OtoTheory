# タブバー自動表示/非表示機能 — 最終解決策

**日付**: 2025-10-12  
**ステータス**: ✅ **実装完了**  
**環境**: iOS 17+, SwiftUI, Pure SwiftUI実装

---

## 🎯 **解決策の概要**

ChatGPTの分析により、**2つの根本原因**を特定し、**Pure SwiftUI**で完全解決。

---

## 🔍 **根本原因の分析**

### **原因A: スクロール検知の失敗**
- **問題**: `VStack.background(GeometryReader)`でScrollView内のコンテンツ全体の座標を読んでいた
- **結果**: ScrollView内での相対座標は変化しないため、`onPreferenceChange`が初回のみ発火
- **ログ**: `📊 Offset: 0.0, Delta: 0.0` が1回だけ表示され、以降更新されない

### **原因B: タブバー制御の階層問題**
- **問題**: 子View（ProgressionView）から直接`UITabBar`を操作していた
- **結果**: SwiftUIの`TabView`が内部で管理しているため、レイアウト更新で上書きされる
- **症状**: `isHidden`/`frame`/`alpha`を変更しても効果なし

---

## ✅ **実装した解決策**

### **アプローチ: Pure SwiftUI + PreferenceKey通信**

```
ProgressionView (子)
  ↓ スクロール検知（Global座標センサー）
  ↓ 可視状態を計算
  ↓ PreferenceKey で通知
  ↓
MainTabView (親)
  ↓ onPreferenceChange で受信
  ↓ .toolbar(.visible/.hidden, for: .tabBar)
```

---

## 📝 **実装詳細**

### **1. ProgressionView.swift - スクロール検知**

#### センサー配置
```swift
ScrollView {
    // ← 先頭に高さ0のセンサーを配置
    GeometryReader { geo in
        let y = geo.frame(in: .global).minY  // Global座標を取得
        Color.clear
            .preference(key: ScrollYPreferenceKey.self, value: y)
    }
    .frame(height: 0)
    
    VStack(spacing: 24) {
        // コンテンツ...
    }
}
```

#### スクロール判定ロジック
```swift
@State private var initialY: CGFloat? = nil
@State private var lastY: CGFloat = 0
@State private var showTabBar: Bool = true

.onPreferenceChange(ScrollYPreferenceKey.self) { y in
    if initialY == nil {
        initialY = y
        lastY = y
        return
    }
    guard let y0 = initialY else { return }
    
    let delta = y - lastY          // スクロール方向 (+ 上 / - 下)
    let offset = y - y0            // 総オフセット (0 = トップ)
    
    let dirThreshold: CGFloat = 4   // ヒステリシス（抖動防止）
    let topThreshold: CGFloat = -50
    
    var next = showTabBar
    if offset > topThreshold {
        next = true  // トップ付近は常に表示
    } else if delta > dirThreshold {
        next = true  // 上スクロール → 表示
    } else if delta < -dirThreshold {
        next = false // 下スクロール → 非表示
    }
    
    if next != showTabBar {
        withAnimation(.easeInOut(duration: 0.25)) {
            showTabBar = next
        }
    }
    lastY = y
}
.preference(key: TabBarVisiblePreferenceKey.self, value: showTabBar)
```

#### PreferenceKey定義
```swift
struct ScrollYPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TabBarVisiblePreferenceKey: PreferenceKey {
    static var defaultValue: Bool = true
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}
```

---

### **2. MainTabView.swift - タブバー制御**

```swift
struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var tabVisibility: Visibility = .visible
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ProgressionView()
                .tabItem {
                    Label("Chord Progression", systemImage: "music.note.list")
                }
                .tag(0)
            
            // ... 他のタブ
        }
        // 子からの可視状態を受信
        .onPreferenceChange(TabBarVisiblePreferenceKey.self) { visible in
            withAnimation(.easeInOut(duration: 0.25)) {
                tabVisibility = visible ? .visible : .hidden
            }
        }
        // タブバーの公式制御は親で行う
        .toolbar(tabVisibility, for: .tabBar)
    }
}
```

---

## 🔧 **技術的なポイント**

### **なぜGlobal座標なのか？**

| 座標空間 | 特徴 | スクロール時の挙動 |
|---------|------|------------------|
| `.named("scrollView")` | ScrollView内の相対座標 | ❌ VStack全体の座標は固定（0のまま） |
| `.global` | 画面全体の絶対座標 | ✅ スクロールに合わせて毎フレーム変化 |

### **センサーの配置理由**

```swift
// ❌ NG: VStack全体のbackground
VStack {
    // コンテンツ...
}
.background(GeometryReader { ... })  // コンテンツ全体 = 固定座標

// ✅ OK: 先頭に固定センサー
GeometryReader { ... }.frame(height: 0)  // 先頭の点 = 可変座標
VStack {
    // コンテンツ...
}
```

### **親子通信の流れ**

1. **子（ProgressionView）**:
   - センサーでGlobal Y座標を取得
   - 初回値を基準に相対位置とスクロール方向を計算
   - `showTabBar`（Bool）を決定
   - `.preference(key: TabBarVisiblePreferenceKey.self, value: showTabBar)`で親に通知

2. **親（MainTabView）**:
   - `.onPreferenceChange(TabBarVisiblePreferenceKey.self)`で受信
   - `tabVisibility`（Visibility）を更新
   - `.toolbar(tabVisibility, for: .tabBar)`で公式API経由で制御

---

## 🎨 **UX調整パラメータ**

### しきい値の調整
```swift
let dirThreshold: CGFloat = 4    // スクロール方向判定（小 = 敏感）
let topThreshold: CGFloat = -50  // トップ判定範囲（大 = 広範囲）
```

### アニメーション調整
```swift
withAnimation(.easeInOut(duration: 0.25)) {
    // 短い = キビキビ / 長い = ゆったり
}
```

---

## ✅ **動作確認**

### 期待される挙動
1. **起動直後** → タブバー表示 ✅
2. **下スクロール（コンテンツを上へ）** → タブバー非表示 ✅
3. **上スクロール（戻る）** → タブバー表示 ✅
4. **トップ到達** → タブバー表示 ✅
5. **微小な指ブレ** → チラつかない（ヒステリシス効果）✅

### コンソールログ
```
⬇️ Hiding tab bar
⬆️ Showing tab bar
```

---

## 📊 **Before / After**

| 項目 | Before（失敗実装） | After（成功実装） |
|------|------------------|-----------------|
| スクロール検知 | ❌ 初回のみ | ✅ 毎フレーム更新 |
| タブバー制御 | ❌ UIKit直接操作 | ✅ SwiftUI公式API |
| ログ出力 | 1回のみ | 連続出力 |
| タブバー動作 | 常に表示 | スクロール連動 |
| コード構造 | 複雑（UIKit混在） | シンプル（Pure SwiftUI） |

---

## 🚫 **使用停止したコード**

### TabBarVisibilityHelper.swift
- **理由**: UIKit直接操作はSwiftUIのレイアウト更新で上書きされる
- **状態**: ファイルは残すが、使用しない（フォールバック用）
- **推奨**: `.toolbar()`を使った公式制御

---

## 📂 **変更ファイル一覧**

1. **ProgressionView.swift**
   - 行177-231: `body`実装（センサー + スクロール検知）
   - 行1350-1364: PreferenceKey定義

2. **MainTabView.swift**
   - 行5: `tabVisibility`追加
   - 行28-34: PreferenceKey受信 + `.toolbar()`制御

3. **TabBarVisibilityHelper.swift**
   - 変更なし（使用停止、削除はしない）

---

## 🎓 **学んだこと**

1. **GeometryReaderの座標空間**: `.global`がスクロール検知には必須
2. **SwiftUI階層構造**: タブバーは親（TabView）で制御するのが正解
3. **PreferenceKey通信**: 子→親への安全なデータ伝達方法
4. **Pure SwiftUI**: UIKit混在を避けることで安定性向上

---

## 🔗 **参考情報**

- **ChatGPT分析**: `TabBar_AutoHide_Issue_Report.md`
- **SwiftUI公式ドキュメント**: `.toolbar(_:for:)`
- **iOS要件**: iOS 17+ (`.toolbar(Visibility, for:)`導入バージョン)

---

## ✨ **完了日**: 2025-10-12 22:43
## 🎸 **実装者**: Claude + ChatGPT連携

