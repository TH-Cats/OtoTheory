# タブバー自動表示/非表示機能 実装レポート

**日付**: 2025-10-12  
**ステータス**: 未解決  
**環境**: iOS 17+, SwiftUI, Xcode 15+

---

## 🎯 **実現したいこと**

### 要件
ProgressionViewでスクロール時にタブバーを自動的に表示/非表示にする機能を実装したい。

### 期待される動作
1. **画面を下にスクロール（コンテンツを上に移動）** → タブバーが消える
2. **画面を上にスクロール（コンテンツを下に移動）** → タブバーが表示される
3. **画面トップに到達** → タブバーが必ず表示される

### 目的
- 縦長の画面でコンテンツの表示領域を最大化
- ユーザーがコンテンツに集中できるようにする
- 必要な時だけタブバーを表示

---

## 📱 **アプリ構造**

### TabView構造
```
ContentView
  └─ MainTabView (TabView)
       ├─ ProgressionView (tag: 0) ← ここで実装
       ├─ FindChordsView (tag: 1)
       └─ ReferenceView (tag: 2)
```

### 問題点
- `MainTabView.swift`で`TabView`が定義されているため、個別のView（`ProgressionView`）から直接タブバーを制御できない
- SwiftUIの`.toolbar(.hidden, for: .tabBar)`が期待通りに動作しない

---

## 🔧 **試した実装（3つのアプローチ）**

### **アプローチ1: PreferenceKey + ScrollView Offset**

#### 実装内容
```swift
// ProgressionView.swift

@State private var scrollOffset: CGFloat = 0
@State private var showTabBar = true

ScrollView {
    VStack {
        Color.clear
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self,
                                   value: geo.frame(in: .named("scroll")).minY)
                }
            )
        
        // Content...
    }
}
.coordinateSpace(name: "scroll")
.onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
    let delta = offset - scrollOffset
    
    if offset >= -50 {
        showTabBar = true  // Near top
    } else if delta < -30 {
        showTabBar = true  // Scrolling up
    } else if delta > 30 {
        showTabBar = false // Scrolling down
    }
    
    scrollOffset = offset
}
.toolbar(showTabBar ? .visible : .hidden, for: .tabBar)

// PreferenceKey定義
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
```

#### 結果
- ❌ スクロール検知が動作しない
- ❌ `.toolbar()`がタブバーに効かない
- ❌ デバッグログが表示されない

---

### **アプローチ2: UIKit直接制御 + Custom Modifier**

#### 実装内容
```swift
// TabBarVisibilityHelper.swift

extension UIApplication {
    var tabBarController: UITabBarController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController as? UITabBarController
    }
}

struct TabBarVisibilityModifier: ViewModifier {
    let isHidden: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                setTabBarVisibility(hidden: isHidden)
            }
            .onChange(of: isHidden) { _, newValue in
                setTabBarVisibility(hidden: newValue)
            }
    }
    
    private func setTabBarVisibility(hidden: Bool) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let tabBarController = window.rootViewController as? UITabBarController else {
            return
        }
        
        let tabBar = tabBarController.tabBar
        
        UIView.animate(withDuration: 0.3) {
            if hidden {
                tabBar.frame.origin.y = window.bounds.height
                tabBar.alpha = 0
                tabBar.isHidden = true
            } else {
                tabBar.isHidden = false
                tabBar.alpha = 1
                tabBar.frame.origin.y = window.bounds.height - tabBar.frame.height
            }
        }
    }
}

extension View {
    func tabBarHidden(_ hidden: Bool) -> some View {
        modifier(TabBarVisibilityModifier(isHidden: hidden))
    }
}
```

#### 使用方法
```swift
// ProgressionView.swift
.tabBarHidden(!showTabBar)
```

#### 結果
- ❌ タブバーが常に表示されたまま
- ✅ UITabBarControllerの取得は成功している可能性
- ❌ アニメーションが実行されていない

---

### **アプローチ3: ViewOffsetKey (最新の実装)**

#### 実装内容
```swift
// ProgressionView.swift

@State private var lastDragValue: CGFloat = 0
@State private var showTabBar = true

ZStack(alignment: .bottom) {
    ScrollView {
        VStack(spacing: 24) {
            buildProgressionSection
            chordBuilderSection
            analyzeAndResultSection
        }
        .padding(.vertical)
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: ViewOffsetKey.self, 
                               value: geo.frame(in: .named("scrollView")).minY)
            }
        )
    }
    .coordinateSpace(name: "scrollView")
    .onPreferenceChange(ViewOffsetKey.self) { offset in
        let delta = offset - lastDragValue
        
        print("📊 Offset: \(offset), Delta: \(delta)")
        
        if offset > -50 {
            if !showTabBar {
                print("🔼 Near top - showing tab bar")
                showTabBar = true
            }
        } else if delta > 5 {
            if !showTabBar {
                print("⬆️ Scrolling up - showing tab bar")
                showTabBar = true
            }
        } else if delta < -5 {
            if showTabBar {
                print("⬇️ Scrolling down - hiding tab bar")
                showTabBar = false
            }
        }
        
        lastDragValue = offset
    }
    .tabBarHidden(!showTabBar)
}

// PreferenceKey定義
struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
```

#### 結果
- ⚠️ コンソールに1回だけ `📊 Offset: 0.0, Delta: 0.0` と表示される
- ❌ スクロール中にログが更新されない
- ❌ タブバーが常に表示されたまま

---

## 🐛 **問題分析**

### 症状
1. `PreferenceKey`の`onPreferenceChange`が初回（`onAppear`時）のみ呼ばれ、スクロール中に更新されない
2. `GeometryReader`がスクロール位置を追跡していない
3. `UITabBar`の直接制御（`frame`, `alpha`, `isHidden`）が効いていない

### 考えられる原因
1. **SwiftUIとUIKitの統合問題**
   - SwiftUIの`TabView`が内部で`UITabBarController`を使っているが、直接アクセスできない可能性
   
2. **PreferenceKeyの更新タイミング**
   - `GeometryReader`の値が変化していない、または変化を検知できていない
   - `coordinateSpace`の設定ミス
   
3. **View階層の問題**
   - `MainTabView` → `TabView` → `ProgressionView`という階層で、`ProgressionView`からタブバーにアクセスできない

4. **iOS17+の仕様変更**
   - SwiftUIのタブバー制御方法が変更されている可能性

---

## 📂 **関連ファイル**

### 主要ファイル
1. **`ProgressionView.swift`** - メインの実装（177-223行目: body定義、1342-1350行目: PreferenceKey定義）
2. **`MainTabView.swift`** - TabView定義
3. **`TabBarVisibilityHelper.swift`** - UIKit直接制御のヘルパー

### サポートファイル
4. **`ContentView.swift`** - アプリのルートView

---

## 💡 **代替案の候補**

### Option A: 手動トグルボタン
最もシンプル。画面上にタブバー表示/非表示を切り替えるボタンを配置。

```swift
Button(action: { showTabBar.toggle() }) {
    Image(systemName: showTabBar ? "chevron.down" : "chevron.up")
}
```

### Option B: iOS 18の新API使用
iOS 18で導入された`.tabViewStyle()`や`.toolbar()`の新しいモディファイアを使用。
（ただし、iOS 17対応が必要な場合は不可）

### Option C: UIViewControllerRepresentableでラップ
`UIScrollView`と`UIScrollViewDelegate`を使って確実にスクロール検知。
複雑だが最も確実。

---

## 🔍 **現在のコンソール出力**

```
📊 Offset: 0.0, Delta: 0.0
```

- 初回のみ出力され、スクロール中は更新されない
- これは`onPreferenceChange`がスクロール時に呼ばれていないことを示している

---

## ❓ **ChatGPTへの質問**

1. SwiftUI + TabViewの環境で、タブバーを個別のViewから制御する方法はありますか？
2. `PreferenceKey`がスクロール時に更新されない原因は何ですか？
3. `GeometryReader`を使ってScrollView内のスクロール位置を追跡する正しい方法を教えてください
4. UIKitの`UITabBar`を直接制御しているのに変化しない理由は何ですか？
5. iOS 17+で推奨されるタブバー制御の方法はありますか？

---

## 📎 **補足情報**

- **SwiftUIバージョン**: iOS 17+ (Xcode 15+)
- **ビルド**: 成功（エラーなし）
- **実機/シミュレーター**: シミュレーター (iPhone 16)
- **動作**: タブバーが常に表示されたまま、スクロール検知が機能していない

