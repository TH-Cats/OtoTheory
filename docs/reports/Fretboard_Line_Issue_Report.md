# Fretboard表示問題レポート

**作成日**: 2025-10-13  
**対象**: OtoTheory iOS - ProgressionViewのFretboard表示

---

## 問題の概要

### 症状
1. **6弦の下に横線が表示される**（FindChordsでは表示されない）
2. **フレットボードが窮屈で横スクロールができない**
3. **FindChordsのFretboardは正常に動作**（線なし、横スクロール可能）

### スクリーンショット
- ProgressionView: 6弦の下に線が見える、窮屈、横スクロール不可
- FindChordsView: 正常に表示される

---

## 環境

- **デバイス**: iPhone 12（実機）、iPhone 16（シミュレーター）
- **iOS**: 18.6
- **Xcode**: 最新版
- **ビルド構成**: Debug

---

## 現在のコード状態

### 1. FretboardView.swift

**ファイルパス**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Views/FretboardView.swift`

#### 主要な実装箇所

**ScrollView構造**（106-145行目）:
```swift
ScrollView(.horizontal, showsIndicators: !isLandscape) {
    Canvas { context, size in
        let currentTopBarHeight = dynamicTopBarHeight
        
        // Draw background (guitar-like wood texture) - only to last string center
        let lastStringY = currentTopBarHeight + CGFloat(strings.count - 1) * rowHeight + rowHeight / 2
        context.fill(
            Path(CGRect(x: 0, y: 0, width: totalWidth, height: lastStringY)),
            with: .color(Color(red: 0.35, green: 0.25, blue: 0.15).opacity(0.15))
        )
        
        // Draw fret numbers (top bar)
        drawFretNumbers(context: context, ...)
        
        // Draw fret dots (position markers)
        drawFretDots(context: context, ...)
        
        // Draw strings (horizontal lines) - removed for cleaner Web-like design
        // drawStrings(context: context, ...)  // ← コメントアウト済み
        
        // Draw frets (vertical lines)
        drawFrets(context: context, ...)
        
        // Draw nut (thick line between open and fret 1)
        drawNut(context: context, ...)
        
        // Draw open string markers
        drawOpenMarkers(context: context, ...)
        
        // Draw overlay markers (scale ghost + chord main)
        drawOverlayMarkers(context: context, ...)
    }
    .frame(
        width: isLandscape ? geometry.size.width : totalWidth,
        height: isLandscape ? geometry.size.height : totalHeight
    )
    .contentShape(Rectangle())
    .onTapGesture { location in
        handleTap(at: location, spaceWidth: spaceWidth, rowHeight: rowHeight, zeroColWidth: zeroColWidth)
    }
}
.scrollDisabled(isLandscape)
```

**高さ計算**（59-70行目）:
```swift
private func calculateRowHeight(availableHeight: CGFloat) -> CGFloat {
    if isLandscape {
        let usableHeight = availableHeight - dynamicTopBarHeight - 5
        let calculatedHeight = usableHeight / CGFloat(strings.count)
        return calculatedHeight
    } else {
        // In portrait, use fixed minimum height (no scrolling needed)
        return minRowHeight  // 55
    }
}
```

**幅計算**（44-57行目）:
```swift
private func calculateFretWidth(availableWidth: CGFloat) -> CGFloat {
    let zeroColWidth = minSpaceWidth + openGap
    let usableWidth = availableWidth - leftGutter - zeroColWidth - 20
    let calculatedWidth = usableWidth / CGFloat(frets)
    
    if isLandscape {
        return max(calculatedWidth, 30)
    } else {
        return minSpaceWidth  // 70
    }
}
```

**drawFrets実装**（196-210行目）:
```swift
private func drawFrets(context: GraphicsContext, spaceWidth: CGFloat, rowHeight: CGFloat, zeroColWidth: CGFloat, topBarHeight: CGFloat) {
    // Draw fret lines from first string to last string (center to center)
    let firstStringY = topBarHeight + rowHeight / 2
    let lastStringY = topBarHeight + CGFloat(strings.count - 1) * rowHeight + rowHeight / 2
    
    for fret in 0...frets {
        let x = leftGutter + zeroColWidth + CGFloat(fret) * spaceWidth
        var path = Path()
        path.move(to: CGPoint(x: x, y: firstStringY))
        path.addLine(to: CGPoint(x: x, y: lastStringY))
        
        let opacity: CGFloat = fret == 0 ? 0 : 0.2
        context.stroke(path, with: .color(.gray.opacity(opacity)), lineWidth: 1)
    }
}
```

**drawStrings実装（削除済み）**（194行目）:
```swift
// drawStrings function removed - strings are no longer drawn for cleaner Web-like design
```

### 2. ProgressionView.swift

**ファイルパス**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Views/ProgressionView.swift`

**FretboardViewの呼び出し**（1033-1044行目）:
```swift
FretboardView(
    strings: ["E", "B", "G", "D", "A", "E"],
    frets: 15,
    overlay: overlay,
    onTapNote: { midiNote in
        audioPlayer.playNote(midiNote: UInt8(midiNote), duration: 0.3)
    }
)
.id(overlayChordNotes.joined(separator: ","))
.frame(height: 350)  // Fixed height for portrait mode (same as FindChords)
.clipped()  // Clip content to frame bounds to hide any overflow lines
```

### 3. FindChordsView.swift（正常動作している参考実装）

**ファイルパス**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Views/FindChordsView.swift`

**FretboardViewの呼び出し**（305-311行目）:
```swift
FretboardView(
    overlay: currentOverlay,
    onTapNote: { midiNote in
        playNote(midiNote)
    }
)
.frame(height: 350)  // Fixed height for scrollable container
```

**違い**:
- FindChordsView: `strings`と`frets`パラメータを指定していない（デフォルト値使用）
- FindChordsView: `.clipped()`修飾子なし
- FindChordsView: `.padding(.horizontal)`なし（親VStackにある）

---

## 試した修正内容

### 修正1: `drawStrings`関数の削除
**目的**: 弦を表す横線を削除  
**結果**: 線は消えなかった

**詳細**:
```swift
// Before: drawStrings関数が存在し、各弦に横線を描画
private func drawStrings(context: GraphicsContext, ...) {
    for (index, _) in strings.enumerated() {
        let y = topBarHeight + CGFloat(index) * rowHeight + rowHeight / 2
        // ... 線を描画
        context.stroke(path, with: .color(...), lineWidth: stringThickness)
    }
}

// After: 関数を完全に削除し、コメント化
// drawStrings function removed - strings are no longer drawn for cleaner Web-like design
```

### 修正2: `.padding(.horizontal)`の削除
**目的**: FindChordsと同じレイアウト構造にする  
**結果**: 横スクロールが機能しなくなり、窮屈になった

### 修正3: Canvas背景矩形の削除
**目的**: 背景の境界線を削除  
**結果**: 窮屈になり、横スクロール不可、線は消えなかった

**詳細**:
```swift
// 背景矩形を完全に削除
// Before:
context.fill(
    Path(CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight)),
    with: .color(Color(red: 0.35, green: 0.25, blue: 0.15).opacity(0.15))
)

// After:
// Background removed to match FindChords clean design
```

### 修正4: 背景矩形の高さを調整（現在の状態）
**目的**: 背景矩形の下端が6弦の下まで伸びないようにする  
**結果**: 線は消えなかった、窮屈、横スクロール不可

**詳細**:
```swift
// 背景矩形の高さをtotalHeightからlastStringYに変更
let lastStringY = currentTopBarHeight + CGFloat(strings.count - 1) * rowHeight + rowHeight / 2
context.fill(
    Path(CGRect(x: 0, y: 0, width: totalWidth, height: lastStringY)),
    with: .color(Color(red: 0.35, green: 0.25, blue: 0.15).opacity(0.15))
)
```

### 修正5: `.clipped()`修飾子の追加
**目的**: フレーム外のコンテンツをクリッピング  
**結果**: 効果なし

---

## 仮説

### 仮説1: VStack/親コンテナの影響
ProgressionViewの`fretboardSection`がVStackで囲まれており、何らかの境界線が表示されている可能性。

### 仮説2: Canvas/ScrollViewのframe設定の問題
FindChordsとProgressionViewでのframe指定方法に違いがあり、それが原因の可能性。

### 仮説3: 初期化パラメータの違い
FindChordsは`strings`と`frets`を指定せずデフォルト値を使用しているが、ProgressionViewは明示的に指定している。この違いが影響している可能性。

### 仮説4: 横スクロール無効化の条件
`.scrollDisabled(isLandscape)`が誤って縦画面でも適用されている可能性。

### 仮説5: totalHeight計算の問題
```swift
let totalHeight = CGFloat(strings.count) * rowHeight + dynamicTopBarHeight
```
この計算が6弦の下にスペースを含んでいる可能性。

---

## ログ情報

### 正常動作時のログ（コード変更が反映されている）
```
🎸 Selected chord: C, notes: ["C", "E", "G"], key: C
🎯 overlayChordNotes updated to: ["C", "E", "G"]
🎯 Fretboard overlay: chord notes=["C", "E", "G"], ghost=true
🎨 FretboardView drawing with chordNotes: ["C", "E", "G"], shouldShowGhost: true
```

これらのログが出力されているため、コード変更は確実に反映されています。

---

## FindChordsとProgressionViewの比較

### 共通点
- 同じ`FretboardView`コンポーネントを使用
- 同じ`height: 350`を指定
- 同じ`ScrollView(.horizontal)`構造

### 相違点

| 項目 | FindChordsView | ProgressionView |
|------|----------------|-----------------|
| strings指定 | なし（デフォルト） | `["E", "B", "G", "D", "A", "E"]` |
| frets指定 | なし（デフォルト） | `15` |
| .clipped() | なし | あり |
| 親コンテナのpadding | `.padding(.horizontal)`あり | VStack内で`.padding(.horizontal)`はヘッダーのみ |

---

## 関連ファイル

1. **FretboardView.swift**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Views/FretboardView.swift`
2. **ProgressionView.swift**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Views/ProgressionView.swift`
3. **FindChordsView.swift**: `/Users/nh/App/OtoTheory/OtoTheory-iOS/OtoTheory/Views/FindChordsView.swift`

---

## 次のステップ（提案）

1. **FindChordsViewと完全に同じ呼び出し方にする**
   - `strings`と`frets`パラメータを削除してデフォルト値を使用
   - `.clipped()`を削除

2. **デバッグログの追加**
   - `totalHeight`、`totalWidth`、`rowHeight`の値を出力
   - `isLandscape`の状態を確認
   - ScrollViewのコンテンツサイズを確認

3. **VStack構造の見直し**
   - `fretboardSection`全体を`FindChordsView`と同じ構造に変更

4. **Canvas描画領域の視覚化**
   - 背景矩形に明確な色（例: 赤）をつけて、どこまで描画されているか確認

---

## 質問事項

1. 線はCanvas内で描画されているのか、それともSwiftUIの境界線なのか？
2. なぜFindChordsでは正常に動作するのか？
3. `.frame(height: 350)`がScrollViewとCanvasの両方に影響を与えているのか？
4. 横スクロールが機能しない根本原因は何か？（コンテンツサイズ？ScrollView設定？）

---

**最終更新**: 2025-10-13 19:42

