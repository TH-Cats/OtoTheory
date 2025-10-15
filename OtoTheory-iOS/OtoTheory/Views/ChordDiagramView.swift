//
//  ChordDiagramView.swift
//  OtoTheory
//
//  Canvas-based chord diagram renderer
//  Draws fretboard, strings, frets, fingers, and markers
//

import SwiftUI

struct ChordDiagramView: View {
    let shape: ChordShape
    let root: ChordRoot
    let displayMode: ChordDisplayMode
    
    private let stringCount = 6
    private let fretCount = 4
    private let stringSpacing: CGFloat = 30
    private let fretHeight: CGFloat = 40
    
    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let startX: CGFloat = 40
            let startY: CGFloat = 30
            let fretboardWidth = stringSpacing * CGFloat(stringCount - 1)
            let fretboardHeight = fretHeight * CGFloat(fretCount)
            
            // Draw strings (vertical lines)
            for i in 0..<stringCount {
                let x = startX + CGFloat(i) * stringSpacing
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: startY))
                    p.addLine(to: CGPoint(x: x, y: startY + fretboardHeight))
                }
                context.stroke(path, with: .color(.gray), lineWidth: 1)
            }
            
            // Draw frets (horizontal lines)
            for i in 0...fretCount {
                let y = startY + CGFloat(i) * fretHeight
                let path = Path { p in
                    p.move(to: CGPoint(x: startX, y: y))
                    p.addLine(to: CGPoint(x: startX + fretboardWidth, y: y))
                }
                // Nut is thicker
                let lineWidth: CGFloat = (i == 0 && shape.label == "Open") ? 3 : 1
                context.stroke(path, with: .color(.gray), lineWidth: lineWidth)
            }
            
            // Draw fret number (if not open)
            if shape.label != "Open", let fretNum = extractFretNumber(from: shape.label) {
                let text = Text("\(fretNum)fr")
                    .font(.caption)
                    .foregroundColor(.secondary)
                context.draw(text, at: CGPoint(x: startX - 20, y: startY + fretHeight / 2))
            }
            
            // Draw barre lines
            for barre in shape.barres {
                let fromString = barre.fromString - 1
                let toString = barre.toString - 1
                let x1 = startX + CGFloat(fromString) * stringSpacing
                let x2 = startX + CGFloat(toString) * stringSpacing
                let y = startY + (CGFloat(barre.fret) - 0.5) * fretHeight + fretHeight / 2
                
                let barrePath = Path { p in
                    p.move(to: CGPoint(x: x1, y: y))
                    p.addLine(to: CGPoint(x: x2, y: y))
                }
                context.stroke(barrePath, with: .color(.blue.opacity(0.3)), lineWidth: 12)
            }
            
            // Draw markers (dots/crosses/open)
            for (stringIndex, fretStr) in shape.frets.enumerated() {
                let x = startX + CGFloat(stringIndex) * stringSpacing
                
                if fretStr == "x" {
                    // Muted string (X)
                    let y = startY - 15
                    let crossPath = Path { p in
                        p.move(to: CGPoint(x: x - 5, y: y - 5))
                        p.addLine(to: CGPoint(x: x + 5, y: y + 5))
                        p.move(to: CGPoint(x: x + 5, y: y - 5))
                        p.addLine(to: CGPoint(x: x - 5, y: y + 5))
                    }
                    context.stroke(crossPath, with: .color(.red), lineWidth: 2)
                } else if fretStr == "0" {
                    // Open string (O)
                    let y = startY - 15
                    let circle = Circle()
                        .path(in: CGRect(x: x - 6, y: y - 6, width: 12, height: 12))
                    context.stroke(circle, with: .color(.green), lineWidth: 2)
                } else if let fret = Int(fretStr), fret > 0 {
                    // Fretted note (filled circle)
                    let minFret = shape.frets.compactMap { Int($0) }.filter { $0 > 0 }.min() ?? 1
                    let relativeFret = fret - minFret + 1
                    let y = startY + (CGFloat(relativeFret) - 0.5) * fretHeight
                    
                    let circle = Circle()
                        .path(in: CGRect(x: x - 10, y: y - 10, width: 20, height: 20))
                    context.fill(circle, with: .color(.blue))
                    context.stroke(circle, with: .color(.white), lineWidth: 2)
                    
                    // Draw display text (finger/roman/note)
                    let displayText = getDisplayText(
                        stringIndex: stringIndex,
                        fretStr: fretStr
                    )
                    let text = Text(displayText)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    context.draw(text, at: CGPoint(x: x, y: y))
                }
            }
        }
        .frame(height: 200)
        .padding()
    }
    
    private func extractFretNumber(from label: String) -> Int? {
        let components = label.components(separatedBy: "fr")
        return Int(components[0])
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
        
        // Open strings: E(40), A(45), D(50), G(55), B(59), E(64)
        let openStrings = [40, 45, 50, 55, 59, 64]
        let midiNote = openStrings[5 - stringIndex] + fret
        let interval = (midiNote - (root.semitone + 40)) % 12
        
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
        
        // Open strings: E(40), A(45), D(50), G(55), B(59), E(64)
        let openStrings = [40, 45, 50, 55, 59, 64]
        let midiNote = openStrings[5 - stringIndex] + fret
        let semitone = midiNote % 12
        
        return ChordRoot.from(semitone: semitone).displayName
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
                tips: "C major open chord"
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
                tips: "G major barre chord"
            ),
            root: .G,
            displayMode: .roman
        )
    }
}

