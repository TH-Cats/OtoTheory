# OSLog 実装結果レポート

## 📋 実施日時
2025年10月7日

## 🎯 目的
ChordSequencer の診断ログを Xcode デバッグコンソールで確認できるようにする。

---

## ✅ 実施内容

### 1. **既存の `audioTrace()` 関数を拡張**

**ファイル**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/AudioTrace.swift.swift`

**変更内容**:
```swift
import os

enum LogTag {
    static let audio = Logger(subsystem: "com.ototheory.app", category: "audio")
}

func audioTrace(_ message: String) {
    let ms = Int((CACurrentMediaTime() - appStart) * 1000)
    print("[\(ms) ms] \(message)")
    LogTag.audio.info("[audio] \(message, privacy: .public)")
}
```

**効果**:
- `print()` と `Logger.info()` の両方を出力
- Xcode コンソールと Unified Log の両方に記録される

---

### 2. **アプリ起動時のログを追加**

**ファイル**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/OtoTheoryApp.swift`

**変更内容**:
```swift
@main
struct OtoTheoryApp: App {
    init() {
        audioTrace("BOOT mark — app did launch")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

### 3. **再生開始時のログを追加**

**ファイル**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/ChordSequencer.swift`

**変更内容**:
```swift
func play(chords: [String], program: UInt8, bpm: Double, onBarChange: @escaping (Int?) -> Void) {
    audioTrace("Playback started (ChordSequencer)")
    // ...
}
```

---

## 📊 テスト結果

### ✅ **成功したログ**
```
[audio] BOOT mark — app did launch
```

### ❌ **出力されなかったログ**
```
[audio] Playback started (ChordSequencer)
```

---

## 🔍 分析

### 考えられる原因

1. **再生ボタンが押されていない**
   - アプリは起動したが、実際に再生操作を行っていない可能性

2. **ChordSequencer.play() が呼ばれていない**
   - 別の経路（HybridPlayer）で再生されている可能性
   - または再生処理自体が実行されていない

3. **ログの出力タイミング**
   - `play()` メソッドの先頭に `audioTrace()` があるため、メソッドが呼ばれれば必ず出力されるはず
   - 出力されないということは、メソッド自体が呼ばれていない

---

## 💡 次のステップ

### 追加すべき診断ログ（最小セット）

以下の3つのログを追加して、経路と動作を確認：

1. **グラフ準備完了時**:
   ```swift
   audioTrace("Graph ready — samplerA→subMixA, samplerB→subMixB, main connected")
   ```

2. **再生開始時**:
   ```swift
   audioTrace("Playback started (ChordSequencer)") // or (Hybrid)
   ```

3. **各小節の再生時**:
   ```swift
   audioTrace("Playing chord: \(symbol) bus:\(currentBusIsA ? "A" : "B")")
   ```

これにより以下が確認できる：
- どの経路で鳴っているか（ChordSequencer / Hybrid）
- 小節ごとに何が起きているか
- バス切り替えが正しく動作しているか

---

## 🔧 技術的な詳細

### 変更したファイル
1. `/Users/nh/App/OtoTheory/OtoTheory-iOS/AudioTrace.swift.swift`
2. `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/OtoTheoryApp.swift`
3. `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/ChordSequencer.swift`

### 削除したファイル
- `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/Log.swift`
  （既存の `audioTrace()` と競合したため削除し、AudioTrace.swift.swift に統合）

### ビルド状態
✅ **BUILD SUCCEEDED**

### 実行状態
✅ アプリ起動成功
✅ 起動時ログ出力成功
❌ 再生時ログ未確認（再生操作が必要）

---

## 📝 結論

**成果**:
- OSLog の配線が完了
- `audioTrace()` が Unified Log に記録されるようになった
- アプリ起動時のログが正常に出力された

**未確認**:
- 再生時のログ（再生操作を行っていないため）

**推奨**:
- 追加の診断ログを実装
- 実際に再生操作を行って、全ログが出力されることを確認
