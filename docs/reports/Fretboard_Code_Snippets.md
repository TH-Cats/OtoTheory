# Fretboard問題 - コードスニペット

## 1. FretboardView.swift - 現在の実装

### 初期化とパラメータ
```swift
struct FretboardView: View {
    let strings: [String]  // High to low (E, B, G, D, A, E)
    let frets: Int
    let overlay: FretboardOverlay
    let onTapNote: ((Int) -> Void)?
    
    @State private var isLandscape = false
    
    private let leftGutter: CGFloat = 50
    private let minSpaceWidth: CGFloat = 70
    private let minRowHeight: CGFloat = 55
    private let topBarHeight: CGFloat = 48
    private let openGap: CGFloat = 24
    private let nutWidth: CGFloat = 5
    
    init(
        strings: [String] = ["E", "B", "G", "D", "A", "E"],
        frets: Int = 15,
        overlay: FretboardOverlay,
        onTapNote: ((Int) -> Void)? = nil
    ) {
        self.strings = strings
        self.frets = frets
        self.overlay = overlay
        self.onTapNote = onTapNote
    }
}
```

### body実装（メイン構造）
```swift
var body: some View {
    GeometryReader { geometry in
        let spaceWidth = calculateFretWidth(availableWidth: geometry.size.width)
        let rowHeight = calculateRowHeight(availableHeight: geometry.size.height)
        let zeroColWidth = spaceWidth + openGap
        let totalWidth = leftGutter + zeroColWidth + CGFloat(frets) * spaceWidth
        let totalHeight = CGFloat(strings.count) * rowHeight + dynamicTopBarHeight
        
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
                drawFretNumbers(context: context, spaceWidth: spaceWidth, zeroColWidth: zeroColWidth, topBarHeight: currentTopBarHeight)
                
                // Draw fret dots (position markers)
                drawFretDots(context: context, spaceWidth: spaceWidth, rowHeight: rowHeight, zeroColWidth: zeroColWidth, topBarHeight: currentTopBarHeight)
                
                // Draw strings (horizontal lines) - removed for cleaner Web-like design
                // drawStrings(context: context, spaceWidth: spaceWidth, rowHeight: rowHeight, zeroColWidth: zeroColWidth, topBarHeight: currentTopBarHeight)
                
                // Draw frets (vertical lines)
                drawFrets(context: context, spaceWidth: spaceWidth, rowHeight: rowHeight, zeroColWidth: zeroColWidth, topBarHeight: currentTopBarHeight)
                
                // Draw nut (thick line between open and fret 1)
                drawNut(context: context, rowHeight: rowHeight, zeroColWidth: zeroColWidth, topBarHeight: currentTopBarHeight)
                
                // Draw open string markers
                drawOpenMarkers(context: context, spaceWidth: spaceWidth, rowHeight: rowHeight, zeroColWidth: zeroColWidth, topBarHeight: currentTopBarHeight)
                
                // Draw overlay markers (scale ghost + chord main)
                drawOverlayMarkers(context: context, spaceWidth: spaceWidth, rowHeight: rowHeight, zeroColWidth: zeroColWidth, topBarHeight: currentTopBarHeight)
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
        .onAppear {
            updateOrientation(geometry.size)
        }
        .onChange(of: geometry.size) { _, newSize in
            updateOrientation(newSize)
        }
    }
}
```

### 計算関数
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

private func calculateRowHeight(availableHeight: CGFloat) -> CGFloat {
    if isLandscape {
        let usableHeight = availableHeight - dynamicTopBarHeight - 5
        let calculatedHeight = usableHeight / CGFloat(strings.count)
        return calculatedHeight
    } else {
        return minRowHeight  // 55
    }
}
```

---

## 2. ProgressionView.swift - FretboardViewの呼び出し

### fretboardSection（現在の実装）
```swift
@ViewBuilder
private var fretboardSection: some View {
    VStack(alignment: .leading, spacing: 12) {
        HStack {
            Text("Fretboard")
                .font(.headline)
            
            Spacer()
            
            // Degrees/Names Toggle (icon-based like FindChords)
            HStack(spacing: 4) {
                Button {
                    fbDisplay = .degrees
                } label: {
                    Text("°")
                        .font(.system(size: 16, weight: fbDisplay == .degrees ? .bold : .regular))
                        .frame(minWidth: 32)
                        .padding(.vertical, 6)
                        .background(fbDisplay == .degrees ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(fbDisplay == .degrees ? .white : .primary)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                
                Button {
                    fbDisplay = .names
                } label: {
                    Text("♪")
                        .font(.system(size: 16, weight: fbDisplay == .names ? .bold : .regular))
                        .frame(minWidth: 32)
                        .padding(.vertical, 6)
                        .background(fbDisplay == .names ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(fbDisplay == .names ? .white : .primary)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                
                // Fullscreen button
                Button {
                    showFretboardFullscreen = true
                    orientationManager.lockToLandscape()
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        
        // Fretboard View
        if let scale = selectedScale, let key = selectedKey {
            let rootPc = keyToPitchClass(key.tonic)
            let overlay = FretboardOverlay(
                scaleRootPc: rootPc,
                scaleType: scale.type,
                showScaleGhost: true,
                chordNotes: overlayChordNotes.isEmpty ? nil : overlayChordNotes,
                display: fbDisplay == .degrees ? .degrees : .names
            )
            let _ = !overlayChordNotes.isEmpty ? print("🎯 Fretboard overlay: chord notes=\(overlayChordNotes), ghost=\(overlay.shouldShowGhost)") : ()
            
            // FretboardView already has horizontal scrolling built-in
            FretboardView(
                strings: ["E", "B", "G", "D", "A", "E"],
                frets: 15,
                overlay: overlay,
                onTapNote: { midiNote in
                    // Play single note
                    audioPlayer.playNote(midiNote: UInt8(midiNote), duration: 0.3)
                }
            )
            .id(overlayChordNotes.joined(separator: ","))  // Force update when chord notes change
            .frame(height: 350)  // Fixed height for portrait mode (same as FindChords)
            .clipped()  // Clip content to frame bounds to hide any overflow lines
        } else {
            Text("Analyze progression to view fretboard")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
        }
    }
}
```

---

## 3. FindChordsView.swift - 正常動作する参考実装

### FretboardViewの呼び出し（縦画面・通常表示）
```swift
VStack(alignment: .leading, spacing: 12) {
    HStack {
        Text("Fretboard")
            .font(.headline)
        
        Spacer()
        
        HStack(spacing: 4) {
            Button {
                fbDisplay = .degrees
            } label: {
                Text("°")
                    .font(.system(size: 16, weight: fbDisplay == .degrees ? .bold : .regular))
                    .frame(minWidth: 32)
                    .padding(.vertical, 6)
                    .background(fbDisplay == .degrees ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(fbDisplay == .degrees ? .white : .primary)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            
            Button {
                fbDisplay = .names
            } label: {
                Text("♪")
                    .font(.system(size: 16, weight: fbDisplay == .names ? .bold : .regular))
                    .frame(minWidth: 32)
                    .padding(.vertical, 6)
                    .background(fbDisplay == .names ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(fbDisplay == .names ? .white : .primary)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            
            Button {
                showFretboardFullscreen = true
                orientationManager.lockToLandscape()
            } label: {
                HStack(spacing: 4) {
                    Text("Best in")
                        .font(.system(size: 9, weight: .medium))
                    Image(systemName: "rotate.right")
                        .font(.system(size: 11, weight: .semibold))
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        
        FretboardView(
            overlay: currentOverlay,
            onTapNote: { midiNote in
                playNote(midiNote)
            }
        )
        .frame(height: 350)  // Fixed height for scrollable container
    }
}
```

**重要な違い**:
- `strings`と`frets`パラメータを指定していない（デフォルト値を使用）
- `.clipped()`修飾子なし
- `.id()`修飾子なし

---

## 4. 比較表

| 項目 | FindChordsView（正常） | ProgressionView（問題あり） |
|------|----------------------|-------------------------|
| strings指定 | なし（デフォルト） | `["E", "B", "G", "D", "A", "E"]` |
| frets指定 | なし（デフォルト） | `15` |
| .frame(height:) | `350` | `350` |
| .clipped() | なし | あり |
| .id() | なし | `overlayChordNotes.joined(separator: ",")` |
| 親VStackのspacing | `12` | `12` |
| ヘッダーHStackの.padding | `.padding(.horizontal)` | `.padding(.horizontal)` |
| FretboardViewの.padding | なし | なし |

---

## 5. デバッグ用の提案コード

### 提案1: FindChordsと完全に同じ呼び出し方にする
```swift
// ProgressionView.swift の fretboardSection を以下に変更
FretboardView(
    overlay: overlay,
    onTapNote: { midiNote in
        audioPlayer.playNote(midiNote: UInt8(midiNote), duration: 0.3)
    }
)
.frame(height: 350)
```

### 提案2: デバッグログを追加
```swift
var body: some View {
    GeometryReader { geometry in
        let spaceWidth = calculateFretWidth(availableWidth: geometry.size.width)
        let rowHeight = calculateRowHeight(availableHeight: geometry.size.height)
        let zeroColWidth = spaceWidth + openGap
        let totalWidth = leftGutter + zeroColWidth + CGFloat(frets) * spaceWidth
        let totalHeight = CGFloat(strings.count) * rowHeight + dynamicTopBarHeight
        
        // デバッグログ
        let _ = print("🔍 Fretboard metrics:")
        let _ = print("   geometry: \(geometry.size)")
        let _ = print("   isLandscape: \(isLandscape)")
        let _ = print("   spaceWidth: \(spaceWidth)")
        let _ = print("   rowHeight: \(rowHeight)")
        let _ = print("   totalWidth: \(totalWidth)")
        let _ = print("   totalHeight: \(totalHeight)")
        let _ = print("   lastStringY: \(dynamicTopBarHeight + CGFloat(strings.count - 1) * rowHeight + rowHeight / 2)")
        
        ScrollView(.horizontal, showsIndicators: !isLandscape) {
            // ... 既存のCanvas実装
        }
    }
}
```

### 提案3: 背景を視覚化
```swift
// Canvas内の背景描画を以下に変更（デバッグ用）
let lastStringY = currentTopBarHeight + CGFloat(strings.count - 1) * rowHeight + rowHeight / 2
context.fill(
    Path(CGRect(x: 0, y: 0, width: totalWidth, height: lastStringY)),
    with: .color(.red.opacity(0.3))  // 赤色で視覚化
)
```

---

**作成日**: 2025-10-13 19:42


