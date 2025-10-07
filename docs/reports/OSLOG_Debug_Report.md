# OSLog デバッグ結果レポート

## 📋 実施日時
2025年10月7日

## 🎯 目的
ChordSequencer の診断ログ（グラフダンプ、接続情報、ゲイン値）が Terminal から確認できない原因を特定する。

---

## 🔍 STEP 1: アプリログの Unified Log 記録確認

### 実施内容
アプリを起動・再生後、Terminal で以下を実行：

```bash
xcrun simctl spawn booted log show --style syslog --last 3m --info --debug \
  --predicate 'process == "OtoTheory"'
```

### 結果
❌ **ログが出力されませんでした**

### 考察
- アプリは起動・再生できている（音が出る）
- しかし Unified Log には何も記録されていない
- → `print()` でのみ出力している可能性が高い

---

## 🔍 STEP 2: コード内の文字列存在確認

### 実施内容
プロジェクト内で診断ログの文字列を検索：

```bash
cd /Users/nh/App/OtoTheory/OtoTheory-iOS
grep -Rn 'Graph.*post-connect' .
```

### 結果
✅ **コードに存在することを確認**

```
./OtoTheory/Core/Audio/ChordSequencer.swift:80:        dumpGraph("post-connect")
```

### コードの実装確認
`dumpGraph()` 関数（453行目）を確認：

```swift
print("🔎 [Graph] \(tag)")
```

### 考察
✅ **原因が判明**：
- コードには存在している
- しかし **`print()` で出力している**
- `print()` は **Xcode コンソールにのみ表示**され、**Unified Log には記録されない**

---

## 🔍 STEP 3: OSLog（Unified Log）への切り替え

### 実施内容

#### 1. Logger の追加
```swift
import os.log

private let logger = Logger(subsystem: "com.nh.OtoTheory", category: "ChordSequencer")
```

#### 2. 重要ポイントに OSLog を追加

**配線と初期ボリューム設定の直後（51行目）**:
```swift
logger.info("[Graph] post-connect  A->main[0], B->main[1]  (A.out=\(self.subMixA.outputVolume, privacy: .public)  B.out=\(self.subMixB.outputVolume, privacy: .public))")
```

**初期化完了時（82行目、86行目）**:
```swift
logger.info("🔎 [OSLOG] ChordSequencer initialized - engine started")
logger.info("🔎 [OSLOG] Graph dump completed")
```

**再生開始時（95行目）**:
```swift
logger.info("🔎 [OSLOG] PATH = ChordSequencer (fallback)")
```

**dumpMainInputs() 内（413行目、417行目）**:
```swift
logger.info("🔎 [OSLOG] dumpMainInputs - checking \(main.numberOfInputs) buses")
logger.info("🔌 [OSLOG] Main in \(bus): \(nodeName) → main[\(bus)] (src bus:\(point.bus))")
```

#### 3. ビルド
✅ **BUILD SUCCEEDED**

#### 4. Terminal でログ確認
```bash
xcrun simctl spawn booted log show --style syslog --last 2m --info --debug --predicate 'subsystem == "com.nh.OtoTheory" AND category == "ChordSequencer"'
```

### 結果
❌ **ログが出力されませんでした**

```
getpwuid_r did not find a match for uid 501
Filtering the log data using "subsystem == "com.nh.OtoTheory" AND category == "ChordSequencer""
Timestamp                       (process)[PID]    
```

---

## 🚨 問題点のまとめ

### 1. **アプリが起動していない可能性**
Terminal で以下のエラーが出ている：

```
An error was encountered processing the command (domain=FBSOpenApplicationServiceErrorDomain, code=4):
Simulator device failed to launch com.nh.OtoTheory.
Underlying error (domain=FBSOpenApplicationServiceErrorDomain, code=4):
        The request to open "com.nh.OtoTheory" failed.
```

### 2. **OSLog が記録されていない**
- `logger.info()` を追加したが、Unified Log に何も記録されていない
- ビルドは成功している
- しかしアプリが正常に起動していない可能性

### 3. **考えられる原因**
1. **アプリが実際には起動していない**
   - Terminal からの起動が失敗している
   - Xcode から起動する必要がある

2. **シミュレーターの問題**
   - シミュレーターの状態が不安定
   - 再起動が必要な可能性

3. **Bundle Identifier の不一致**
   - `com.nh.OtoTheory` が正しいか確認が必要

---

## 📊 現在の状況

### ✅ 完了したこと
1. `print()` → `Logger` への切り替え実装
2. 重要なポイントに OSLog を追加
3. ビルド成功

### ❌ 未解決の問題
1. アプリが Terminal から起動できない
2. OSLog が Unified Log に記録されていない
3. 診断ログが確認できない

---

## 💡 次のステップ（推奨）

### 1. **Xcode から直接起動してテスト**
Terminal からではなく、**Xcode で ⌘R** で起動して：
- Xcode のデバッグコンソールでログを確認
- `print()` と `logger.info()` の両方が出力されるはず

### 2. **シミュレーターの再起動**
```bash
xcrun simctl shutdown "iPhone 16"
xcrun simctl boot "iPhone 16"
```

### 3. **Bundle Identifier の確認**
プロジェクト設定で正しい Bundle Identifier を確認

### 4. **実機でのテスト**
シミュレーターの問題を回避するため、実機でテスト

---

## 🔧 技術的な詳細

### 追加したファイル
- `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Core/Audio/ChordSequencer.swift`

### 変更内容
- `import os.log` を追加
- `Logger(subsystem: "com.nh.OtoTheory", category: "ChordSequencer")` を追加
- 5箇所に `logger.info()` を追加

### ビルド状態
✅ ビルド成功（BUILD SUCCEEDED）

### 実行状態
❌ Terminal からの起動失敗
❓ Xcode からの起動は未確認

---

## 📝 結論

**原因**: `print()` を使用していたため、Unified Log に記録されていなかった。

**対策**: `Logger` を使用した OSLog への切り替えを実装。

**現状**: ビルドは成功したが、アプリの起動に問題があり、ログが確認できていない。

**推奨**: Xcode から直接起動して、デバッグコンソールでログを確認する。
