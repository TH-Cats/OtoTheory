//
//  ChordDiagramView.swift
//  OtoTheory
//
//  Canvas-based chord diagram renderer (Horizontal layout - Web version style)
//  Frets go left-right, strings go top-bottom (1st string at top)
//

import SwiftUI

struct ChordDiagramView: View {
    let shape: ChordShape
    let root: ChordRoot
    let displayMode: ChordDisplayMode
    
    private let stringCount = 6
    private let fretCount = 4
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let width = size.width
                let height = size.height
                
                // Padding (increased padLeft to avoid overlap with open string dots)
                let padLeft: CGFloat = 50
                let padRight: CGFloat = 20
                let padTop: CGFloat = 20
                let padBottom: CGFloat = 35
                
                let innerW = width - padLeft - padRight
                let innerH = height - padTop - padBottom
                
                let fretW = innerW / CGFloat(fretCount)
                let stringH = innerH / CGFloat(stringCount - 1)
                
                // Calculate base fret
                // If chord has open strings (0), always show from fret 1 (low position chord)
                let hasOpenStrings = shape.frets.contains("0")
                let pos = shape.frets.compactMap { Int($0) }.filter { $0 > 0 }
                let baseFret = hasOpenStrings ? 1 : (pos.min() ?? 1)
                let showNut = baseFret == 1
                
                // Helper functions
                func xForFret(_ absFret: Int) -> CGFloat {
                    if absFret == 0 { return padLeft - 12 }
                    let rel = absFret - baseFret + 1
                    return padLeft + fretW * (CGFloat(rel) - 0.5)
                }
                
                func yForString(_ sIdx: Int) -> CGFloat {
                    return padTop + stringH * CGFloat(5 - sIdx)
                }
                
                // Draw strings (horizontal lines, 1st string at top)
                for s in 0..<stringCount {
                    let path = Path { p in
                        p.move(to: CGPoint(x: padLeft, y: yForString(s)))
                        p.addLine(to: CGPoint(x: padLeft + innerW, y: yForString(s)))
                    }
                    context.stroke(path, with: .color(Color(white: 0.35)), lineWidth: 1)
                }
                
                // Draw frets (vertical lines)
                for f in 1...fretCount {
                    let path = Path { p in
                        p.move(to: CGPoint(x: padLeft + fretW * CGFloat(f), y: padTop))
                        p.addLine(to: CGPoint(x: padLeft + fretW * CGFloat(f), y: padTop + innerH))
                    }
                    context.stroke(path, with: .color(Color(white: 0.35)), lineWidth: 1)
                }
                
                // Draw nut or fret number
                if showNut {
                    let nutRect = CGRect(x: padLeft - 7, y: padTop - 1.5, width: 7, height: innerH + 3)
                    context.fill(Path(roundedRect: nutRect, cornerRadius: 3), with: .color(Color(white: 0.9)))
                } else {
                    let text = Text("\(baseFret)fr")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    context.draw(text, at: CGPoint(x: padLeft - 8, y: padTop - 10))
                }
                
                // Draw fret numbers at bottom (1..4)
                for f in 1...fretCount {
                    let displayFret = baseFret + f - 1
                    let text = Text("\(displayFret)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    context.draw(text, at: CGPoint(x: padLeft + fretW * (CGFloat(f) - 0.5), y: height - 6))
                }
                
                // Draw markers (1st to 6th order)
                for (stringIndex, fretStr) in shape.frets.enumerated() {
                    // stringIndex: 0=1st string, 5=6th string
                    // yForString: expects 0=6th, 5=1st, so we use (5-stringIndex)
                    let y = yForString(5 - stringIndex)
                    
                    if fretStr == "x" {
                        let x = padLeft - 15
                        let crossPath = Path { p in
                            p.move(to: CGPoint(x: x - 5, y: y - 5))
                            p.addLine(to: CGPoint(x: x + 5, y: y + 5))
                            p.move(to: CGPoint(x: x + 5, y: y - 5))
                            p.addLine(to: CGPoint(x: x - 5, y: y + 5))
                        }
                        context.stroke(crossPath, with: .color(.red), lineWidth: 2)
                    } else if fretStr == "0" {
                        let x = padLeft - 15
                        
                        // Check if open string is the root
                        let isRoot = isRootNote(stringIndex: stringIndex, fret: 0)
                        let dotColor: Color = isRoot ? .orange : .blue
                        
                        // Draw filled dot (same as fretted notes)
                        let dotRadius: CGFloat = 16
                        let circle = Circle().path(in: CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
                        context.fill(circle, with: .color(dotColor))
                        context.stroke(circle, with: .color(.white), lineWidth: 2)
                        
                        // Always show roman/note text inside the dot
                        let displayText = getDisplayText(stringIndex: stringIndex, fretStr: fretStr)
                        let finalText = displayText.isEmpty ? "?" : displayText
                        let text = Text(finalText)
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        // Position text at center of dot
                        context.draw(text, at: CGPoint(x: x, y: y))
                    } else if let fret = Int(fretStr), fret > 0 {
                        let x = xForFret(fret)
                        // Larger dot size: 32x32 (was 24x24)
                        let dotRadius: CGFloat = 16
                        let circle = Circle().path(in: CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
                        
                        // Check if this note is the root
                        let isRoot = isRootNote(stringIndex: stringIndex, fret: fret)
                        let dotColor: Color = isRoot ? .orange : .blue
                        
                        context.fill(circle, with: .color(dotColor))
                        context.stroke(circle, with: .color(.white), lineWidth: 2)
                        
                        // Pass stringIndex directly (0=1st, 5=6th)
                        let displayText = getDisplayText(stringIndex: stringIndex, fretStr: fretStr)
                        let text = Text(displayText)
                            .font(.body)  // Larger font for larger dot
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        context.draw(text, at: CGPoint(x: x, y: y))
                    }
                }
                
                // Draw barre lines
                for barre in shape.barres {
                    let x = xForFret(barre.fret)
                    let y1 = yForString(6 - barre.fromString)
                    let y2 = yForString(6 - barre.toString)
                    let y = min(y1, y2) - 14
                    let h = abs(y2 - y1) + 28
                    
                    // Wider barre to match larger dots
                    let barreRect = CGRect(x: x - 14, y: y, width: 28, height: h)
                    context.fill(Path(roundedRect: barreRect, cornerRadius: 14), with: .color(Color.teal.opacity(0.3)))
                }
            }
        }
    }
    
    private func getDisplayText(stringIndex: Int, fretStr: String) -> String {
        switch displayMode {
        case .finger:
            // Show finger number
            if let fingerNum = shape.fingers[stringIndex] {
                return "\(fingerNum)"
            }
            return ""
        case .roman:
            // Show interval (R, III, V, etc.)
            return getRomanNumeral(stringIndex: stringIndex, fretStr: fretStr)
        case .note:
            // Show note name (C, E, G, etc.)
            return getNoteName(stringIndex: stringIndex, fretStr: fretStr)
        }
    }
    
    private func getRomanNumeral(stringIndex: Int, fretStr: String) -> String {
        guard let fret = Int(fretStr) else { return "" }
        
        // Open strings (1st to 6th): E4(64), B3(59), G3(55), D3(50), A2(45), E2(40)
        let openStrings = [64, 59, 55, 50, 45, 40]
        let midiNote = openStrings[stringIndex] + fret
        // Calculate interval from root pitch class
        let notePitchClass = midiNote % 12
        let rootPitchClass = root.semitone
        let interval = (notePitchClass - rootPitchClass + 12) % 12
        
        switch interval {
        case 0: return "R"
        case 1: return "♭II"
        case 2: return "II"
        case 3: return "♭III"
        case 4: return "III"
        case 5: return "IV"
        case 6: return "♭V"
        case 7: return "V"
        case 8: return "♭VI"
        case 9: return "VI"
        case 10: return "♭VII"
        case 11: return "VII"
        default: return "?"
        }
    }
    
    private func getNoteName(stringIndex: Int, fretStr: String) -> String {
        guard let fret = Int(fretStr) else { return "" }
        
        // Open strings (1st to 6th): E4(64), B3(59), G3(55), D3(50), A2(45), E2(40)
        let openStrings = [64, 59, 55, 50, 45, 40]
        let midiNote = openStrings[stringIndex] + fret
        let pitchClass = midiNote % 12
        
        return ChordRoot.from(semitone: pitchClass).displayName
    }
    
    private func isRootNote(stringIndex: Int, fret: Int) -> Bool {
        // Open strings (1st to 6th): E4(64), B3(59), G3(55), D3(50), A2(45), E2(40)
        let openStrings = [64, 59, 55, 50, 45, 40]
        let midiNote = openStrings[stringIndex] + fret
        // Calculate interval from root pitch class
        let notePitchClass = midiNote % 12
        let rootPitchClass = root.semitone
        let interval = (notePitchClass - rootPitchClass + 12) % 12
        
        return interval == 0
    }
}

#Preview {
    VStack {
        ChordDiagramView(
            shape: ChordShape(
                kind: .open,
                label: "Open",
                frets: [.muted, .fretted(3), .fretted(2), .open, .fretted(1), .open],
                fingers: [nil, .three, .two, nil, .one, nil],
                tips: ["C major open chord"]
            ),
            root: .C,
            displayMode: .finger
        )
        
        ChordDiagramView(
            shape: ChordShape(
                kind: .eShape,
                label: "3fr",
                frets: [
                    .fretted(3),
                    .fretted(5),
                    .fretted(5),
                    .fretted(4),
                    .fretted(3),
                    .fretted(3)
                ],
                fingers: [.one, .three, .four, .two, .one, .one],
                barres: [ChordBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["G major barre chord"]
            ),
            root: .G,
            displayMode: .roman
        )
    }
}

