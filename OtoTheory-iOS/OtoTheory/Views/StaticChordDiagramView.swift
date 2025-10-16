//
//  StaticChordDiagramView.swift
//  OtoTheory
//
//  Chord diagram view for static chord data (v0)
//  Displays fretboard with finger/roman/note modes
//

import SwiftUI

struct StaticChordDiagramView: View {
    let form: StaticForm
    let rootSemitone: Int
    let displayMode: ChordDisplayMode
    
    private let stringCount = 6
    private let fretCount = 4
    private let stringSpacing: CGFloat = 30
    private let fretHeight: CGFloat = 40
    
    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            
            // Calculate dimensions
            let diagramWidth = CGFloat(stringCount - 1) * stringSpacing
            let diagramHeight = CGFloat(fretCount) * fretHeight
            let startX = (width - diagramWidth) / 2
            let startY = (height - diagramHeight) / 2 + 30
            
            // Draw strings (vertical lines, 1st string at top)
            for i in 0..<stringCount {
                let x = startX + CGFloat(i) * stringSpacing
                let line = Path { path in
                    path.move(to: CGPoint(x: x, y: startY))
                    path.addLine(to: CGPoint(x: x, y: startY + diagramHeight))
                }
                context.stroke(line, with: .color(.gray), lineWidth: 1)
            }
            
            // Draw frets (horizontal lines)
            for i in 0...fretCount {
                let y = startY + CGFloat(i) * fretHeight
                let line = Path { path in
                    path.move(to: CGPoint(x: startX, y: y))
                    path.addLine(to: CGPoint(x: startX + diagramWidth, y: y))
                }
                context.stroke(line, with: .color(.gray), lineWidth: i == 0 ? 3 : 1)
            }
            
            // Draw fret numbers (1, 2, 3, 4) below the diagram
            for i in 1...fretCount {
                let y = startY + diagramHeight + 15
                let x = startX + diagramWidth + 10
                context.draw(
                    Text("\(i)")
                        .font(.caption2)
                        .foregroundColor(.gray),
                    at: CGPoint(x: x, y: startY + CGFloat(i) * fretHeight - fretHeight / 2)
                )
            }
            
            // Draw markers for each string
            for (stringIndex, fretVal) in form.frets.enumerated() {
                let x = startX + CGFloat(stringIndex) * stringSpacing
                
                switch fretVal {
                case .x:
                    // Draw X above nut
                    context.draw(
                        Text("×")
                            .font(.headline)
                            .foregroundColor(.red),
                        at: CGPoint(x: x, y: startY - 15)
                    )
                    
                case .open:
                    // Draw circle above nut
                    let circlePath = Path { path in
                        path.addEllipse(in: CGRect(
                            x: x - 6,
                            y: startY - 21,
                            width: 12,
                            height: 12
                        ))
                    }
                    context.stroke(circlePath, with: .color(.gray), lineWidth: 2)
                    
                case .fret(let fret):
                    // Draw filled circle on fret
                    let y = startY + CGFloat(fret) * fretHeight - fretHeight / 2
                    
                    // Draw circle
                    let circle = Path { path in
                        path.addEllipse(in: CGRect(
                            x: x - 12,
                            y: y - 12,
                            width: 24,
                            height: 24
                        ))
                    }
                    context.fill(circle, with: .color(.blue))
                    
                    // Draw display text inside circle
                    if let displayText = getDisplayText(stringIndex: stringIndex, fret: fret) {
                        context.draw(
                            Text(displayText)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white),
                            at: CGPoint(x: x, y: y)
                        )
                    }
                }
            }
        }
        .frame(height: 300)
    }
    
    /// Get display text for a marker based on display mode
    private func getDisplayText(stringIndex: Int, fret: Int) -> String? {
        switch displayMode {
        case .finger:
            // Return finger number
            if let finger = form.fingers[stringIndex] {
                return "\(finger.rawValue)"
            }
            return nil
            
        case .roman:
            // Return roman numeral (interval)
            return getRomanNumeral(stringIndex: stringIndex, fret: fret)
            
        case .note:
            // Return note name
            return getNoteName(stringIndex: stringIndex, fret: fret)
        }
    }
    
    /// Calculate roman numeral for a string+fret
    private func getRomanNumeral(stringIndex: Int, fret: Int) -> String {
        // Open strings (1st to 6th): E4(64), B3(59), G3(55), D3(50), A2(45), E2(40)
        let openStrings = [64, 59, 55, 50, 45, 40]
        let midiNote = openStrings[stringIndex] + fret
        
        // Calculate interval from root pitch class
        let notePitchClass = midiNote % 12
        let rootPitchClass = rootSemitone % 12
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
    
    /// Calculate note name for a string+fret
    private func getNoteName(stringIndex: Int, fret: Int) -> String {
        // Open strings (1st to 6th): E4(64), B3(59), G3(55), D3(50), A2(45), E2(40)
        let openStrings = [64, 59, 55, 50, 45, 40]
        let midiNote = openStrings[stringIndex] + fret
        
        let pitchClass = midiNote % 12
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        return noteNames[pitchClass]
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Text("Finger Mode")
        StaticChordDiagramView(
            form: StaticForm(
                id: "test-1",
                frets: [.open, .open, F(1), F(2), F(2), .open],
                fingers: [nil, nil, .one, .two, .three, nil],
                barres: [],
                tips: []
            ),
            rootSemitone: 4,  // E
            displayMode: .finger
        )
        
        Text("Roman Mode")
        StaticChordDiagramView(
            form: StaticForm(
                id: "test-2",
                frets: [.open, .open, F(1), F(2), F(2), .open],
                fingers: [nil, nil, .one, .two, .three, nil],
                barres: [],
                tips: []
            ),
            rootSemitone: 4,  // E
            displayMode: .roman
        )
    }
}

