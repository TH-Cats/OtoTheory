# Xcodeプロジェクト作成ガイド

**作成日**: 2025-10-04  
**対象**: M4 Week 1 Day 3-4  
**環境**: Xcode 16.4, Swift 6.1.2 ✅

> **注**: このファイルは初回セットアップの詳細手順です。
> 実装の進捗状況と結果は [`v3.1_Implementation_Report.md`](./v3.1_Implementation_Report.md) を参照してください。
> マイルストーン全体は [`v3.1_Roadmap_Milestones.md`](../SSOT/v3.1_Roadmap_Milestones.md) を参照してください。

---

## 📋 このガイドの目的

1. **Xcodeプロジェクト作成**（ototheory-ios）
2. **プロジェクト構造整理**（グループ作成）
3. **JSバンドル追加**
4. **TheoryBridge実装**
5. **動作確認**

**所要時間**: 30-45分

---

## Step 1: Xcodeプロジェクト作成

### 1-1. Xcodeを起動

1. **Spotlight**（⌘ Space）で「Xcode」と入力
2. **Xcode**を起動

### 1-2. 新規プロジェクト作成

1. Xcodeのメニューバーから **File > New > Project...** を選択
   - または、Welcome画面で **Create New Project** をクリック

2. **テンプレート選択**:
   - **iOS** タブを選択
   - **App** を選択
   - **Next** をクリック

3. **プロジェクト設定**:
   ```
   Product Name: OtoTheory
   Team: （あなたのApple Developer Team を選択）
   Organization Identifier: com.thquest
   Bundle Identifier: com.thquest.ototheory （自動生成される）
   Interface: SwiftUI
   Language: Swift
   Storage: None
   
   ✅ Include Tests （チェックを入れる）
   ```

4. **保存場所**:
   - **Next** をクリック
   - `/Users/nh/App/OtoTheory/` に移動
   - **Create** をクリック
   
   → **`/Users/nh/App/OtoTheory/OtoTheory/`** にプロジェクトが作成されます

### 1-3. プロジェクト確認

Xcodeの左サイドバー（Navigator）で以下の構造を確認:

```
OtoTheory/
├── OtoTheory/
│   ├── OtoTheoryApp.swift
│   ├── ContentView.swift
│   ├── Assets.xcassets
│   └── Preview Content/
├── OtoTheoryTests/
└── OtoTheoryUITests/
```

---

## Step 2: プロジェクト構造の整理

### 2-1. グループ（フォルダ）を作成

Xcodeの左サイドバーで **OtoTheory** フォルダを右クリック → **New Group** を選択して、以下のグループを作成:

1. **App** グループを作成
   - `OtoTheoryApp.swift` と `ContentView.swift` をドラッグ&ドロップで移動

2. **Core** グループを作成
   - その中に **Audio** グループを作成
   - その中に **Theory** グループを作成
   - その中に **Telemetry** グループを作成

3. **Features** グループを作成
   - その中に **Progression** グループを作成
   - その中に **FindChords** グループを作成
   - その中に **Settings** グループを作成

4. **Shared** グループを作成
   - その中に **Models** グループを作成
   - その中に **Extensions** グループを作成
   - その中に **Utilities** グループを作成

5. **Resources** グループを作成
   - `Assets.xcassets` をドラッグ&ドロップで移動

**完成イメージ**:

```
OtoTheory/
├── App/
│   ├── OtoTheoryApp.swift
│   └── ContentView.swift
├── Core/
│   ├── Audio/
│   ├── Theory/
│   └── Telemetry/
├── Features/
│   ├── Progression/
│   ├── FindChords/
│   └── Settings/
├── Shared/
│   ├── Models/
│   ├── Extensions/
│   └── Utilities/
└── Resources/
    └── Assets.xcassets
```

---

## Step 3: JSバンドルの追加

### 3-1. JSファイルをXcodeに追加

1. **Finder**を開く（⌘ Space → "Finder"）

2. `/Users/nh/App/OtoTheory/ototheory-ios-resources/` に移動

3. **ototheory-core.js** ファイルを確認

4. **Xcode**に戻る

5. **Resources** グループを右クリック → **Add Files to "OtoTheory"...** を選択

6. `ototheory-core.js` を選択

7. **Options**:
   - ✅ **Copy items if needed** にチェック
   - **Added folders**: "Create groups" を選択
   - **Add to targets**: ✅ **OtoTheory** にチェック

8. **Add** をクリック

### 3-2. 確認

**Resources** グループ内に **ototheory-core.js** が表示されていることを確認。

---

## Step 4: TheoryBridge.swift の実装

### 4-1. 新しいSwiftファイルを作成

1. **Core/Theory** グループを右クリック
2. **New File...** を選択
3. **Swift File** を選択 → **Next**
4. **File Name**: `TheoryBridge.swift`
5. **Save** をクリック

### 4-2. TheoryBridge.swift にコードを記述

以下のコードを **TheoryBridge.swift** に貼り付け:

```swift
import Foundation
import JavaScriptCore

class TheoryBridge {
    private let context: JSContext
    
    init?() {
        guard let context = JSContext() else {
            print("❌ Failed to create JSContext")
            return nil
        }
        self.context = context
        
        // エラーハンドリング
        context.exceptionHandler = { context, exception in
            if let exc = exception {
                print("❌ JS Error: \(exc)")
            }
        }
        
        // JSファイルの読み込み
        guard let jsPath = Bundle.main.path(forResource: "ototheory-core", ofType: "js"),
              let jsCode = try? String(contentsOfFile: jsPath) else {
            print("❌ Failed to load JS bundle")
            return nil
        }
        
        // JS実行
        context.evaluateScript(jsCode)
        
        print("✅ TheoryBridge initialized successfully")
    }
    
    // Chord parsing
    func parseChord(_ symbol: String) -> ChordInfo? {
        let script = """
        (function() {
            try {
                const result = parseChord('\(symbol)');
                return JSON.stringify(result);
            } catch (e) {
                return JSON.stringify({ error: e.message });
            }
        })()
        """
        
        guard let result = context.evaluateScript(script),
              let jsonString = result.toString(),
              let jsonData = jsonString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return nil
        }
        
        return ChordInfo(
            root: dict["root"] as? String ?? "",
            quality: dict["quality"] as? String ?? "",
            bass: dict["bass"] as? String
        )
    }
    
    // Diatonic chords
    func getDiatonicChords(key: String, scale: String) -> [String] {
        let script = """
        (function() {
            try {
                const result = getDiatonicChords('\(key)', '\(scale)');
                return JSON.stringify(result);
            } catch (e) {
                return JSON.stringify([]);
            }
        })()
        """
        
        guard let result = context.evaluateScript(script),
              let jsonString = result.toString(),
              let jsonData = jsonString.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: jsonData) as? [String] else {
            return []
        }
        
        return array
    }
}

// Models
struct ChordInfo {
    let root: String
    let quality: String
    let bass: String?
}
```

### 4-3. 保存

**⌘ S** で保存

---

## Step 5: ContentView.swift でテスト

### 5-1. ContentView.swift を編集

**App/ContentView.swift** を開いて、以下のコードに置き換え:

```swift
import SwiftUI

struct ContentView: View {
    @State private var testResult = "Tap 'Test Bridge' to start..."
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("OtoTheory iOS")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(testResult)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            Button("Test Bridge") {
                testBridge()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
    
    func testBridge() {
        testResult = "Testing..."
        
        guard let bridge = TheoryBridge() else {
            testResult = "❌ Failed to initialize TheoryBridge"
            return
        }
        
        var results: [String] = []
        
        // Test 1: Chord parsing
        if let chord = bridge.parseChord("Cmaj7") {
            results.append("✅ parseChord('Cmaj7')")
            results.append("   Root: \(chord.root)")
            results.append("   Quality: \(chord.quality)")
        } else {
            results.append("❌ Failed to parse chord")
        }
        
        // Test 2: Diatonic chords
        let diatonic = bridge.getDiatonicChords(key: "C", scale: "ionian")
        if !diatonic.isEmpty {
            results.append("✅ getDiatonicChords('C', 'ionian')")
            results.append("   \(diatonic.joined(separator: ", "))")
        } else {
            results.append("❌ Failed to get diatonic chords")
        }
        
        testResult = results.joined(separator: "\n")
    }
}

#Preview {
    ContentView()
}
```

### 5-2. 保存

**⌘ S** で保存

---

## Step 6: 実行とテスト

### 6-1. Simulatorを選択

Xcodeの上部ツールバーで:
- **OtoTheory** スキームが選択されていることを確認
- **iPhone 15 Pro** (or any simulator) を選択

### 6-2. ビルド & 実行

**⌘ R** を押す（または上部の **▶ Run** ボタンをクリック）

### 6-3. 期待される結果

Simulatorが起動し、アプリが表示される:

```
🎵 (音符アイコン)

OtoTheory iOS

Tap 'Test Bridge' to start...

[Test Bridge] ボタン
```

**"Test Bridge" ボタンをタップ**すると:

```
✅ parseChord('Cmaj7')
   Root: C
   Quality: maj7
✅ getDiatonicChords('C', 'ionian')
   C, Dm, Em, F, G, Am, Bdim
```

---

## ✅ 完了チェックリスト

- [ ] Xcodeプロジェクトが作成された
- [ ] グループ構造が整理された
- [ ] ototheory-core.js が追加された
- [ ] TheoryBridge.swift が実装された
- [ ] ContentView.swift が更新された
- [ ] ビルドが成功した（エラーなし）
- [ ] Simulatorでアプリが起動した
- [ ] "Test Bridge" ボタンで正しい結果が表示された

---

## 🚨 トラブルシューティング

### エラー1: "No such file or directory: ototheory-core.js"

**原因**: JSファイルがBundle内にコピーされていない

**解決**:
1. Xcodeの左サイドバーで **ototheory-core.js** を選択
2. 右サイドバー（Inspector）で **Target Membership** を確認
3. **OtoTheory** にチェックが入っていることを確認

### エラー2: "❌ Failed to initialize TheoryBridge"

**原因**: JSContextの初期化失敗 or JSファイルの読み込み失敗

**解決**:
1. Xcode下部の **Console**（⌘ Shift Y）でログを確認
2. "Failed to load JS bundle" と表示されている場合、Step 3を再実行
3. それでも解決しない場合、JSファイルの内容を確認

### エラー3: ビルドエラー（Swift 6関連）

**原因**: Swift 6の厳格な並行性チェック

**解決**:
1. Xcodeメニュー: **Product > Clean Build Folder** (⌘ Shift K)
2. 再度ビルド (⌘ B)
3. それでもエラーが出る場合は、エラーメッセージを確認

---

## 🎉 成功した場合

**おめでとうございます！🎉**

- ✅ Xcodeプロジェクト作成完了
- ✅ JavaScriptCore Bridge動作確認完了
- ✅ TypeScript共通ロジック → Swift Bridge成功

**次のステップ（Day 5-6）**:
- Audio Engine実装
- Tab Bar Navigation実装

詳細は **M4_Week1_Tasks.md** の **Step 7-8** を参照してください。

---

## 📝 次に報告してほしいこと

1. ✅ **成功した場合**:
   - "Test Bridge成功しました！"
   - スクリーンショットを共有（任意）

2. ❌ **エラーが出た場合**:
   - エラーメッセージをコピー&ペースト
   - どのステップで止まったか教えてください

---

**頑張ってください！困ったことがあれば、いつでも聞いてください！** 🚀

