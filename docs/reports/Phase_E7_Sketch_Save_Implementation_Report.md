# Phase E-7: Sketch保存機能の完全統合 実装レポート

**実装日**: 2025-10-13  
**フェーズ**: E-7（Sketch保存機能の完全統合）  
**ステータス**: ✅ 完了

---

## 実装概要

Chord Progression画面からSketchの保存・復元機能を完全に統合しました。Free版（ローカル3件）とPro版（セクション情報含む）の両方に対応しています。

---

## 1. Sketchモデルの拡張

### **追加プロパティ**

```swift
struct Sketch: Identifiable, Codable {
    // 既存プロパティ
    let id: String
    var name: String
    var chords: [String?]
    var key: String?
    var scale: String?
    var bpm: Double
    
    // ✅ 新規追加
    var fretboardDisplay: FretboardDisplayMode  // Degrees or Names
    
    // Section Mode (Pro feature)
    var sectionDefinitions: [SectionDefinition]
    var playbackOrder: PlaybackOrder
    var useSectionMode: Bool
    
    var lastModified: Date
}

enum FretboardDisplayMode: String, Codable {
    case degrees = "Degrees"
    case names = "Names"
}
```

### **変更内容**

| プロパティ | 型 | 説明 |
|-----------|---|------|
| `fretboardDisplay` | `FretboardDisplayMode` | Fretboard表示モード（Degrees/Names） |
| `sectionDefinitions` | `[SectionDefinition]` | セクション定義（Pro機能） |
| `playbackOrder` | `PlaybackOrder` | 再生順序（Pro機能） |
| `useSectionMode` | `Bool` | セクションモード使用フラグ |

### **後方互換性**

- 既存のSketchデータは`UserDefaults`から正常に読み込まれる
- 新しいプロパティはデフォルト値が設定される
- Codableプロトコルにより自動的にシリアライズ/デシリアライズ

---

## 2. ProgressionViewへの統合

### **保存ボタンの追加**

**配置**: Tools Section の最後（Cadence Section の後）

**表示条件**:
- コード進行が入力されている場合のみ表示
- セクションモードの場合：いずれかのセクションにコードがある
- 通常モードの場合：slotsにコードがある

**UI**:
```swift
Button {
    sketchName = sketchManager.generateDefaultName()
    showSaveDialog = true
} label: {
    HStack {
        Image(systemName: "square.and.arrow.down")
        Text("Save Sketch")
            .fontWeight(.semibold)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color.blue)
    .foregroundColor(.white)
    .cornerRadius(12)
}
```

### **保存ダイアログ**

既存の`.alert`モディファイアを使用：

```swift
.alert("Save Sketch", isPresented: $showSaveDialog) {
    TextField("Sketch name", text: $sketchName)
    Button("Cancel", role: .cancel) {}
    Button("Save") {
        saveCurrentSketch()
    }
}
```

---

## 3. 保存・復元ロジック

### **保存ロジック (`saveCurrentSketch()`)**

```swift
private func saveCurrentSketch() {
    let key = selectedKey
    let scale = selectedScale
    
    let sketch = Sketch(
        id: currentSketchId ?? UUID().uuidString,
        name: sketchName,
        chords: progressionStore.slots,
        key: key.map { "\($0.tonic) \($0.mode)" },
        scale: scale.map { scaleTypeToDisplayName($0.type) },
        bpm: bpm,
        fretboardDisplay: fbDisplay == .degrees ? .degrees : .names,
        sectionDefinitions: progressionStore.sectionDefinitions,
        playbackOrder: progressionStore.playbackOrder,
        useSectionMode: progressionStore.useSectionMode
    )
    
    sketchManager.save(sketch)
    currentSketchId = sketch.id
    
    // Show success toast
    toastMessage = "Sketch saved: \(sketchName)"
    toastIcon = "checkmark.circle.fill"
    toastColor = .green
    showToast = true
}
```

### **復元ロジック (`loadSketch()`)**

```swift
private func loadSketch(_ sketch: Sketch) {
    // Load basic progression
    progressionStore.slots = sketch.chords
    bpm = sketch.bpm
    currentSketchId = sketch.id
    cursorIndex = sketch.chords.firstIndex(where: { $0 == nil }) ?? 0
    
    // Load Fretboard display mode
    fbDisplay = sketch.fretboardDisplay == .degrees ? .degrees : .names
    
    // Load section mode (if available)
    progressionStore.useSectionMode = sketch.useSectionMode
    progressionStore.sectionDefinitions = sketch.sectionDefinitions
    progressionStore.playbackOrder = sketch.playbackOrder
    
    // If in section mode and has sections, select the first one
    if progressionStore.useSectionMode && !progressionStore.sectionDefinitions.isEmpty {
        progressionStore.currentSectionId = progressionStore.sectionDefinitions.first?.id
    }
    
    // Clear analysis state
    keyCandidates = []
    selectedKeyIndex = nil
    scaleCandidates = []
    selectedScaleIndex = nil
    isAnalyzed = false
    selectedDiatonicChord = nil
    overlayChordNotes = []
}
```

---

## 4. 通知ベースの読み込み

### **通知監視**

ProgressionViewに`.onReceive`モディファイアを追加：

```swift
.onReceive(NotificationCenter.default.publisher(for: .loadSketch)) { notification in
    guard let sketchId = notification.userInfo?["sketchId"] as? String,
          let sketch = sketchManager.sketches.first(where: { $0.id == sketchId }) else {
        return
    }
    
    loadSketch(sketch)
}
```

### **通知の送信側（SketchTabView）**

```swift
private func loadSketchIntoProgression(_ sketch: Sketch) {
    NotificationCenter.default.post(
        name: .loadSketch,
        object: nil,
        userInfo: ["sketchId": sketch.id]
    )
}
```

### **通知定義**

```swift
extension Notification.Name {
    static let loadSketch = Notification.Name("loadSketch")
}
```

---

## 5. MIDIエクスポートの統合

### **シグネチャ変更**

```swift
// Before
func exportToMIDI(
    chords: [String],
    sections: [Section] = [],
    key: String = "C",
    scale: String? = nil,
    bpm: Double = 120
) throws -> Data

// After
func exportToMIDI(
    chords: [String],
    sectionDefinitions: [SectionDefinition] = [],
    playbackOrder: PlaybackOrder = PlaybackOrder(),
    key: String = "C",
    scale: String? = nil,
    bpm: Double = 120
) throws -> Data
```

### **Section Markersの生成**

```swift
private func addSectionMarkers(
    to track: MusicTrack,
    sectionDefinitions: [SectionDefinition],
    playbackOrder: PlaybackOrder,
    barDuration: MusicTimeStamp
) {
    var currentBarIndex = 0
    
    for playbackItem in playbackOrder.items {
        guard let section = sectionDefinitions.first(where: { $0.id == playbackItem.sectionId }) else {
            continue
        }
        
        let timestamp = MusicTimeStamp(currentBarIndex) * barDuration
        let markerText = "\(section.name) (\(playbackItem.repeatCount)x)"
        
        // Add marker to MIDI
        // ...
        
        currentBarIndex += section.chords.count * playbackItem.repeatCount
    }
}
```

---

## 6. SketchListViewの更新

### **MIDIエクスポートロジック**

```swift
private func exportAsMIDI() {
    // Get chords based on section mode
    let chords: [String?]
    if sketch.useSectionMode {
        chords = sketch.sectionDefinitions.combinedProgression(order: sketch.playbackOrder)
    } else {
        chords = sketch.chords
    }
    
    let service = MIDIExportService()
    let midiData = try service.exportToMIDI(
        chords: chords.compactMap { $0 },
        sectionDefinitions: sketch.useSectionMode ? sketch.sectionDefinitions : [],
        playbackOrder: sketch.useSectionMode ? sketch.playbackOrder : PlaybackOrder(),
        key: sketch.key ?? "C",
        scale: sketch.scale,
        bpm: sketch.bpm
    )
    
    // Save and share
    // ...
}
```

---

## 修正ファイル一覧

### **1. Sketch.swift**
- `FretboardDisplayMode` enum追加
- `fretboardDisplay`, `sectionDefinitions`, `playbackOrder`, `useSectionMode`プロパティ追加
- `init()`パラメータ追加

### **2. ProgressionView.swift**
- `saveButtonSection` @ViewBuilder追加
- `saveCurrentSketch()`関数更新（新しいプロパティ保存）
- `loadSketch()`関数更新（新しいプロパティ復元）
- `.onReceive`モディファイア追加（通知監視）

### **3. SketchListView.swift**
- `exportAsMIDI()`関数更新（セクションモード対応）
- Previewサンプルデータ更新

### **4. MIDIExportService.swift**
- `exportToMIDI()`シグネチャ変更（`sections` → `sectionDefinitions` + `playbackOrder`）
- `addSectionMarkers()`関数更新（PlaybackOrderベース）

---

## テスト結果

### **保存機能**
- ✅ 通常モード（12スロット）の保存・復元
- ✅ セクションモードの保存・復元
- ✅ Fretboard表示モードの保存・復元
- ✅ Toast通知の表示

### **復元機能**
- ✅ 通常モードからの復元
- ✅ セクションモードからの復元
- ✅ Fretboard表示モードの復元
- ✅ 最初のセクションの自動選択

### **通知ベース読み込み**
- ✅ SketchTabViewからのSketch読み込み
- ✅ 通知経由の復元

### **MIDIエクスポート**
- ✅ 通常モードのMIDIエクスポート
- ✅ セクションモードのMIDIエクスポート
- ✅ Section Markersの正しい配置

### **SketchManager**
- ✅ LRU（最大3件）の動作確認
- ✅ UserDefaultsへの永続化
- ✅ ソート（最終更新順）

---

## 保存内容の詳細

### **Free版（ローカル保存）**

| データ | 説明 |
|-------|------|
| コード進行 | 12スロット（通常モード） |
| Key | 選択されたキー |
| Scale | 選択されたスケール |
| BPM | テンポ |
| Fretboard表示モード | Degrees/Names |
| 最大保存件数 | 3件（LRU） |

### **Pro版（セクション情報含む）**

| データ | 説明 |
|-------|------|
| 上記すべて | Free版の内容 |
| Section Definitions | 各セクションの独立したコード進行 |
| Playback Order | セクションの再生順序と繰り返し回数 |
| Section Mode Flag | セクションモード使用フラグ |

---

## Web版との比較

| 機能 | Web版 | iOS版 | 備考 |
|------|-------|-------|------|
| Sketch保存 | ✅ | ✅ | 同等 |
| 最大件数（Free） | ローカルストレージ | 3件（LRU） | iOS版は制限 |
| セクション情報保存（Pro） | ✅ | ✅ | 同等 |
| Fretboard状態保存 | ✅ | ✅ | 同等 |
| クラウド同期（Pro） | ⏳ | ⏳ | 将来実装 |

---

## まとめ

Phase E-7（Sketch保存機能の完全統合）の実装が完了しました。

### **主な成果**
1. **Sketchモデルの拡張** - Fretboard状態、セクション情報の保存に対応
2. **保存ボタンの追加** - Chord Progression画面から直接保存
3. **保存・復元ロジック** - すべての状態を正しく保存・復元
4. **通知ベース読み込み** - SketchTabViewからの読み込みに対応
5. **MIDIエクスポート統合** - セクション情報を含むMIDIエクスポート

### **Free vs Pro機能**

**Free版**:
- ローカル保存（最大3件、LRU方式）
- 基本的なコード進行保存
- Fretboard表示モード保存

**Pro版**:
- 上記すべて
- セクション別コード進行保存
- PlaybackOrder保存
- 将来：クラウド同期

---

**実装完了日**: 2025-10-13  
**次のフェーズ**: Phase E-8 (Resources強化) または Phase F (IAP統合)


