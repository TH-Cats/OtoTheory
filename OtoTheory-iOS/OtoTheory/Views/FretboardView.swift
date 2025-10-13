//
//  FretboardView.swift
//  OtoTheory
//
//  Phase E-1: Fretboard Component - SwiftUI Canvas Implementation
//

import SwiftUI

struct FretboardView: View {
    // MARK: - Configuration
    
    let strings: [String]  // High to low (E, B, G, D, A, E)
    let frets: Int
    let overlay: FretboardOverlay
    let onTapNote: ((Int) -> Void)?  // Callback with MIDI note number
    
    // MARK: - State
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    /// True if device is in landscape orientation (uses size class instead of geometry)
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    // MARK: - Constants
    
    private let leftGutter: CGFloat = 50
    private let minSpaceWidth: CGFloat = 70  // Wider frets for horizontal scrolling
    private let minRowHeight: CGFloat = 55   // Increased row height for better spacing
    private let topBarHeight: CGFloat = 48   // Top bar for fret numbers
    private let openGap: CGFloat = 24        // Open string gap
    private let nutWidth: CGFloat = 5        // Nut thickness (more visible)
    private let fretDotPositions = [3, 5, 7, 9, 12, 15]
    private let fretNumberPositions = [0, 1, 3, 5, 7, 9, 12, 15]  // Positions to show numbers
    
    // String open MIDI numbers (high to low)
    private let stringOpenMIDI = [64, 59, 55, 50, 45, 40]  // E4, B3, G3, D3, A2, E2
    
    // MARK: - Computed Layout
    
    /// Dynamic top bar height based on orientation
    private var dynamicTopBarHeight: CGFloat {
        return isLandscape ? 35 : topBarHeight
    }
    
    /// Calculate optimal fret width based on screen size
    private func calculateFretWidth(availableWidth: CGFloat) -> CGFloat {
        let zeroColWidth = minSpaceWidth + openGap
        let usableWidth = availableWidth - leftGutter - zeroColWidth - 20  // 20pt margin
        let calculatedWidth = usableWidth / CGFloat(frets)
        
        // In landscape, fit all frets on screen; in portrait, use minimum for scrolling
        if isLandscape {
            // Force fit all frets within available width
            return max(calculatedWidth, 30)  // Minimum 30pt per fret
        } else {
            return minSpaceWidth  // Use larger width for better scrolling UX
        }
    }
    
    /// Calculate optimal row height based on screen size
    private func calculateRowHeight(availableHeight: CGFloat) -> CGFloat {
        let usableHeight = availableHeight - dynamicTopBarHeight - 5
        let fitHeight = usableHeight / CGFloat(strings.count)
        
        // In landscape, use calculated height to fit all strings
        if isLandscape {
            return fitHeight
        } else {
            // In portrait, use minimum that fits within parent (prevent overflow)
            return min(minRowHeight, fitHeight)
        }
    }
    
    // MARK: - Pitch Map
    
    private let pitchMap: [String: Int] = [
        "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4,
        "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8, "Ab": 8,
        "A": 9, "A#": 10, "Bb": 10, "B": 11
    ]
    
    private let pitches12 = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
    
    // MARK: - Initializer
    
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
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            let spaceWidth = calculateFretWidth(availableWidth: geometry.size.width)
            let rowHeight = calculateRowHeight(availableHeight: geometry.size.height)
            let zeroColWidth = spaceWidth + openGap
            let totalWidth = leftGutter + zeroColWidth + CGFloat(frets) * spaceWidth
            
            ScrollView(.horizontal, showsIndicators: !isLandscape) {
                Canvas { context, size in
                    let currentTopBarHeight = dynamicTopBarHeight
                    
                    // Draw background (guitar-like wood texture) - to 6th string bottom edge with pixel snapping
                    let bgBottom = currentTopBarHeight + CGFloat(strings.count) * rowHeight
                    let bgHeight = ceil(bgBottom)  // Snap to integer pixel to prevent hairline
                    context.fill(
                        Path(CGRect(x: 0, y: 0, width: totalWidth, height: bgHeight)),
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
                    height: geometry.size.height  // Always clamp to parent height
                )
                .contentShape(Rectangle())
                .onTapGesture { location in
                    handleTap(at: location, spaceWidth: spaceWidth, rowHeight: rowHeight, zeroColWidth: zeroColWidth)
            }
        }
        .scrollDisabled(false)  // Always allow horizontal scrolling
    }
}
    
    // MARK: - Drawing Functions
    
    private func drawFretNumbers(context: GraphicsContext, spaceWidth: CGFloat, zeroColWidth: CGFloat, topBarHeight: CGFloat) {
        for fretNum in fretNumberPositions where fretNum <= frets {
            let x: CGFloat
            if fretNum == 0 {
                // Open string
                x = leftGutter + zeroColWidth / 2
            } else {
                // Fret position (center of fret)
                x = leftGutter + zeroColWidth + CGFloat(fretNum - 1) * spaceWidth + spaceWidth / 2
            }
            
            let y = topBarHeight / 2
            
            let text = Text("\(fretNum)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            
            context.draw(text, at: CGPoint(x: x, y: y))
        }
    }
    
    private func drawFretDots(context: GraphicsContext, spaceWidth: CGFloat, rowHeight: CGFloat, zeroColWidth: CGFloat, topBarHeight: CGFloat) {
        for fret in fretDotPositions where fret <= frets {
            let x = leftGutter + zeroColWidth + CGFloat(fret - 1) * spaceWidth + spaceWidth / 2
            let y = topBarHeight + CGFloat(strings.count) * rowHeight / 2
            
            var path = Path()
            path.addEllipse(in: CGRect(x: x - 3, y: y - 3, width: 6, height: 6))
            context.fill(path, with: .color(.gray.opacity(0.3)))
        }
    }
    
    // drawStrings function removed - strings are no longer drawn for cleaner Web-like design
    
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
    
    private func drawNut(context: GraphicsContext, rowHeight: CGFloat, zeroColWidth: CGFloat, topBarHeight: CGFloat) {
        let x = leftGutter + zeroColWidth - nutWidth / 2
        let firstStringY = topBarHeight + rowHeight / 2
        let lastStringY = topBarHeight + CGFloat(strings.count - 1) * rowHeight + rowHeight / 2
        let stringHeight = lastStringY - firstStringY
        
        let path = Path(
            roundedRect: CGRect(x: x, y: firstStringY, width: nutWidth, height: stringHeight),
            cornerRadius: 2
        )
        // Draw nut with light color for better visibility against dark background
        context.fill(path, with: .color(.white))
    }
    
    private func drawOpenMarkers(context: GraphicsContext, spaceWidth: CGFloat, rowHeight: CGFloat, zeroColWidth: CGFloat, topBarHeight: CGFloat) {
        guard overlay.hasScale, let scaleRootPc = overlay.scaleRootPc, let scaleType = overlay.scaleType else {
            return
        }
        
        for (stringIndex, stringNote) in strings.enumerated() {
            let openPc = pitchIndex(stringNote)
            let y = topBarHeight + CGFloat(stringIndex) * rowHeight + rowHeight / 2
            let x = leftGutter + (spaceWidth + openGap) / 2
            
            // Check if in scale
            guard FretboardHelpers.isInScale(pitchClass: openPc, root: scaleRootPc, scaleType: scaleType) else {
                continue
            }
            
            let isRoot = openPc == scaleRootPc
            let degree = FretboardHelpers.degreeLabel(for: openPc, root: scaleRootPc, scaleType: scaleType)
            let color = FretboardHelpers.colorForDegree(degree, isRoot: isRoot)
            
            // Draw marker (unified size for consistency)
            drawMarker(
                context: context,
                at: CGPoint(x: x, y: y),
                label: overlay.display == .degrees ? (degree ?? "•") : pitches12[openPc],
                color: color,
                size: 30,  // Unified size for all markers
                isGhost: false
            )
        }
    }
    
    private func drawOverlayMarkers(context: GraphicsContext, spaceWidth: CGFloat, rowHeight: CGFloat, zeroColWidth: CGFloat, topBarHeight: CGFloat) {
        guard overlay.hasScale, let scaleRootPc = overlay.scaleRootPc, let scaleType = overlay.scaleType else {
            return
        }
        
        // Debug: Log overlay state
        if let chordNotes = overlay.chordNotes, !chordNotes.isEmpty {
            print("🎨 FretboardView drawing with chordNotes: \(chordNotes), shouldShowGhost: \(overlay.shouldShowGhost)")
        }
        
        for (stringIndex, stringNote) in strings.enumerated() {
            let openPc = pitchIndex(stringNote)
            let y = topBarHeight + CGFloat(stringIndex) * rowHeight + rowHeight / 2
            
            for fret in 1...frets {
                let fretPc = (openPc + fret) % 12
                let x = leftGutter + zeroColWidth + CGFloat(fret - 1) * spaceWidth + spaceWidth / 2
                
                // Check if in scale
                guard FretboardHelpers.isInScale(pitchClass: fretPc, root: scaleRootPc, scaleType: scaleType) else {
                    continue
                }
                
                let isRoot = fretPc == scaleRootPc
                let degree = FretboardHelpers.degreeLabel(for: fretPc, root: scaleRootPc, scaleType: scaleType)
                
                // Check if chord tone
                let isChordTone: Bool = {
                    guard let chordNotes = overlay.chordNotes, !chordNotes.isEmpty else {
                        return false
                    }
                    return chordNotes.contains(where: { pitchIndex($0) == fretPc })
                }()
                
                let color = FretboardHelpers.colorForDegree(degree, isRoot: isRoot)
                
                // Draw marker (unified sizes for consistency)
                if isChordTone {
                    // Chord layer (main) - larger for chord tones
                    drawMarker(
                        context: context,
                        at: CGPoint(x: x, y: y),
                        label: overlay.display == .degrees ? (degree ?? "•") : pitches12[fretPc],
                        color: color,
                        size: 32,  // Larger for chord tones
                        isGhost: false
                    )
                } else if overlay.shouldShowGhost {
                    // Scale layer (ghost) - smaller, faded
                    drawMarker(
                        context: context,
                        at: CGPoint(x: x, y: y),
                        label: nil,  // No label for ghost
                        color: color,
                        size: 18,  // Slightly larger ghost
                        isGhost: true
                    )
                } else {
                    // Scale layer (no chord present) - normal size
                    drawMarker(
                        context: context,
                        at: CGPoint(x: x, y: y),
                        label: overlay.display == .degrees ? (degree ?? "•") : pitches12[fretPc],
                        color: color,
                        size: 28,  // Standard size for scale
                        isGhost: false
                    )
                }
            }
        }
    }
    
    private func drawMarker(
        context: GraphicsContext,
        at point: CGPoint,
        label: String?,
        color: Color,
        size: CGFloat,
        isGhost: Bool
    ) {
        let radius = size / 2
        
        if isGhost {
            // Ghost marker (stroke only)
            var path = Path()
            path.addEllipse(in: CGRect(x: point.x - radius, y: point.y - radius, width: size, height: size))
            context.stroke(path, with: .color(color.opacity(0.4)), lineWidth: 1.5)
        } else {
            // Main marker (filled)
            var path = Path()
            path.addEllipse(in: CGRect(x: point.x - radius, y: point.y - radius, width: size, height: size))
            context.fill(path, with: .color(color))
            
            // Label (larger font for better readability)
            if let label = label {
                let text = Text(label)
                    .font(.system(size: size * 0.6, weight: .bold))  // Increased from 0.5
                    .foregroundColor(.white)
                
                context.draw(text, at: point)
            }
        }
    }
    
    // MARK: - Interaction Handling
    
    private func handleTap(at location: CGPoint, spaceWidth: CGFloat, rowHeight: CGFloat, zeroColWidth: CGFloat) {
        // Calculate string index
        let stringIndex = Int((location.y - dynamicTopBarHeight) / rowHeight)
        guard stringIndex >= 0 && stringIndex < strings.count else { return }
        
        // Calculate fret number
        let xInFretboard = location.x - leftGutter - zeroColWidth
        let fretNumber = max(0, Int(xInFretboard / spaceWidth) + 1)
        guard fretNumber >= 1 && fretNumber <= frets else { return }
        
        // Calculate MIDI note
        let baseMIDI = stringOpenMIDI[stringIndex]
        let midiNote = baseMIDI + fretNumber
        
        // Callback
        onTapNote?(midiNote)
    }
    
    // MARK: - Helper Functions
    
    private func pitchIndex(_ note: String) -> Int {
        pitchMap[note] ?? 0
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Text("Fretboard Preview")
            .font(.headline)
        
        FretboardView(
            overlay: .scaleOnly(rootPc: 0, scaleType: "Ionian")
        )
        .frame(height: 200)
        .padding()
    }
}

