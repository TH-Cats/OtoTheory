//
//  ChordShapeGenerator.swift
//  OtoTheory
//
//  Generates 5 chord shapes for each root+quality combination
//  v3.1.1: Open / E-shape / A-shape / Compact / Color
//

import Foundation

@MainActor
class ChordShapeGenerator {
    static let shared = ChordShapeGenerator()
    
    private init() {}
    
    /// Generate 5 shapes for a chord
    func generateShapes(root: ChordRoot, quality: ChordLibraryQuality) -> [ChordShape] {
        var shapes: [ChordShape] = []
        
        // 1. Open form (if root is within first 4 frets)
        if let openShape = generateOpenShape(root: root, quality: quality) {
            shapes.append(openShape)
        }
        
        // 2. E-shape (6th string root)
        if let eShape = generateEShape(root: root, quality: quality) {
            shapes.append(eShape)
        }
        
        // 3. A-shape (5th string root)
        if let aShape = generateAShape(root: root, quality: quality) {
            shapes.append(aShape)
        }
        
        // 4. Compact (upper 4 strings)
        if let compactShape = generateCompactShape(root: root, quality: quality) {
            shapes.append(compactShape)
        }
        
        // 5. Color (add9, 6/9, sus2/4)
        if let colorShape = generateColorShape(root: root, quality: quality) {
            shapes.append(colorShape)
        }
        
        return shapes
    }
    
    // MARK: - Open Shapes
    
    private func generateOpenShape(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        // Only generate open shapes for roots within first 4 frets
        guard root.semitone <= 4 else { return nil }
        
        switch (root, quality) {
        // C Major family
        case (.C, .M):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .muted, .open, .open, .fretted(1), .fretted(3)],
                fingers: [nil, nil, nil, nil, .one, .three],
                tips: ["Classic C major open chord.", "Mute 5th string."]
            )
        case (.C, .m):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.muted, .fretted(3), .fretted(1), .open, .fretted(1), .fretted(3)],
                fingers: [nil, .three, .one, nil, .one, .four],
                barres: [ChordBarre(fret: 1, fromString: 2, toString: 4, finger: .one)],
                tips: ["Cm open voicing", "Dark minor sound"]
            )
        case (.C, .seven):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.muted, .fretted(3), .fretted(2), .fretted(3), .fretted(1), .open],
                fingers: [nil, .three, .two, .four, .one, nil],
                tips: ["C7 with 7th on 4th string"]
            )
        case (.C, .M7):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.muted, .fretted(3), .fretted(2), .open, .open, .open],
                fingers: [nil, .three, .two, nil, nil, nil],
                tips: ["Rich Cmaj7 open voicing", "Jazzy and sophisticated"]
            )
        
        // D Major family
        case (.D, .M):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.muted, .muted, .open, .fretted(2), .fretted(3), .fretted(2)],
                fingers: [nil, nil, nil, .one, .three, .two],
                tips: ["Classic D major open chord"]
            )
        case (.D, .m):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.muted, .muted, .open, .fretted(2), .fretted(3), .fretted(1)],
                fingers: [nil, nil, nil, .two, .three, .one],
                tips: ["Dm open voicing"]
            )
        case (.D, .seven):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.muted, .muted, .open, .fretted(2), .fretted(1), .fretted(2)],
                fingers: [nil, nil, nil, .two, .one, .three],
                tips: ["D7 open chord"]
            )
        case (.D, .M7):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.muted, .muted, .open, .fretted(2), .fretted(2), .fretted(2)],
                fingers: [nil, nil, nil, .one, .two, .three],
                tips: ["Dmaj7 open voicing"]
            )
        
        // E Major family
        case (.E, .M):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .fretted(2), .fretted(2), .fretted(1), .open, .open],
                fingers: [nil, .two, .three, .one, nil, nil],
                tips: ["Classic E major open chord"]
            )
        case (.E, .m):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .fretted(2), .fretted(2), .open, .open, .open],
                fingers: [nil, .two, .three, nil, nil, nil],
                tips: ["Em open chord - very common"]
            )
        case (.E, .seven):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .fretted(2), .fretted(0), .fretted(1), .open, .open],
                fingers: [nil, .two, nil, .one, nil, nil],
                tips: ["E7 open voicing"]
            )
        case (.E, .M7):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .fretted(2), .fretted(1), .fretted(1), .open, .open],
                fingers: [nil, .three, .one, .two, nil, nil],
                tips: ["Emaj7 open chord"]
            )
        
        // G Major family
        case (.G, .M):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.fretted(3), .fretted(2), .open, .open, .open, .fretted(3)],
                fingers: [.three, .one, nil, nil, nil, .four],
                tips: ["Classic G major open chord"]
            )
        case (.G, .m):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.fretted(3), .fretted(1), .open, .open, .fretted(3), .fretted(3)],
                fingers: [.two, .one, nil, nil, .three, .four],
                tips: ["Gm open voicing"]
            )
        case (.G, .seven):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.fretted(3), .fretted(2), .open, .open, .open, .fretted(1)],
                fingers: [.three, .two, nil, nil, nil, .one],
                tips: ["G7 open chord"]
            )
        
        // A Major family
        case (.A, .M):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.muted, .open, .fretted(2), .fretted(2), .fretted(2), .open],
                fingers: [nil, nil, .one, .two, .three, nil],
                tips: ["Classic A major open chord"]
            )
        case (.A, .m):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.muted, .open, .fretted(2), .fretted(2), .fretted(1), .open],
                fingers: [nil, nil, .two, .three, .one, nil],
                tips: ["Am open chord - very common"]
            )
        case (.A, .seven):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.muted, .open, .fretted(2), .open, .fretted(2), .open],
                fingers: [nil, nil, .two, nil, .one, nil],
                tips: ["A7 open voicing"]
            )
        
        default:
            return nil
        }
    }
    
    // MARK: - E-Shape (6th string root)
    
    private func generateEShape(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        let rootFret = root.semitone
        
        // E-shape positions
        switch quality {
        case .M:
            return ChordShape(
                kind: .eShape,
                label: "\(rootFret)fr",
                frets: [
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 1),
                    .fretted(rootFret),
                    .fretted(rootFret)
                ],
                fingers: [.one, .three, .four, .two, .one, .one],
                barres: [ChordBarre(fret: rootFret, fromString: 1, toString: 6, finger: .one)],
                tips: ["E-shape major barre chord"]
            )
        case .m:
            return ChordShape(
                kind: .eShape,
                label: "\(rootFret)fr",
                frets: [
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret),
                    .fretted(rootFret),
                    .fretted(rootFret)
                ],
                fingers: [.one, .three, .four, .one, .one, .one],
                barres: [ChordBarre(fret: rootFret, fromString: 1, toString: 6, finger: .one)],
                tips: ["E-shape minor barre chord"]
            )
        case .seven:
            return ChordShape(
                kind: .eShape,
                label: "\(rootFret)fr",
                frets: [
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret),
                    .fretted(rootFret + 1),
                    .fretted(rootFret),
                    .fretted(rootFret)
                ],
                fingers: [.one, .three, .one, .two, .one, .one],
                barres: [ChordBarre(fret: rootFret, fromString: 1, toString: 6, finger: .one)],
                tips: ["E-shape dominant 7th barre"]
            )
        case .M7:
            return ChordShape(
                kind: .eShape,
                label: "\(rootFret)fr",
                frets: [
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 1),
                    .fretted(rootFret + 1),
                    .fretted(rootFret),
                    .fretted(rootFret)
                ],
                fingers: [.one, .four, .two, .three, .one, .one],
                barres: [ChordBarre(fret: rootFret, fromString: 1, toString: 6, finger: .one)],
                tips: ["E-shape major 7th barre"]
            )
        case .m7:
            return ChordShape(
                kind: .eShape,
                label: "\(rootFret)fr",
                frets: [
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret),
                    .fretted(rootFret),
                    .fretted(rootFret),
                    .fretted(rootFret)
                ],
                fingers: [.one, .two, .one, .one, .one, .one],
                barres: [ChordBarre(fret: rootFret, fromString: 1, toString: 6, finger: .one)],
                tips: ["E-shape minor 7th barre"]
            )
        case .six:
            return ChordShape(
                kind: .eShape,
                label: "\(rootFret)fr",
                frets: [
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 1),
                    .fretted(rootFret + 2),
                    .fretted(rootFret)
                ],
                fingers: [.one, .two, .three, .one, .four, .one],
                barres: [ChordBarre(fret: rootFret, fromString: 1, toString: 6, finger: .one)],
                tips: ["E-shape 6th chord"]
            )
        default:
            // Default to major shape
            return ChordShape(
                kind: .eShape,
                label: "\(rootFret)fr",
                frets: [
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 1),
                    .fretted(rootFret),
                    .fretted(rootFret)
                ],
                fingers: [.one, .three, .four, .two, .one, .one],
                barres: [ChordBarre(fret: rootFret, fromString: 1, toString: 6, finger: .one)],
                tips: ["E-shape barre chord"]
            )
        }
    }
    
    // MARK: - A-Shape (5th string root)
    
    private func generateAShape(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        let rootFret = root.semitone
        
        // A-shape positions
        switch quality {
        case .M:
            return ChordShape(
                kind: .aShape,
                label: "\(rootFret)fr",
                frets: [
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret)
                ],
                fingers: [nil, .one, .three, .three, .three, .one],
                barres: [
                    ChordBarre(fret: rootFret, fromString: 2, toString: 6, finger: .one),
                    ChordBarre(fret: rootFret + 2, fromString: 3, toString: 5, finger: .three)
                ],
                tips: ["A-shape major barre chord"]
            )
        case .m:
            return ChordShape(
                kind: .aShape,
                label: "\(rootFret)fr",
                frets: [
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 1),
                    .fretted(rootFret)
                ],
                fingers: [nil, .one, .three, .four, .two, .one],
                barres: [ChordBarre(fret: rootFret, fromString: 2, toString: 6, finger: .one)],
                tips: ["A-shape minor barre chord"]
            )
        case .seven:
            return ChordShape(
                kind: .aShape,
                label: "\(rootFret)fr",
                frets: [
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret)
                ],
                fingers: [nil, .one, .three, .one, .two, .one],
                barres: [ChordBarre(fret: rootFret, fromString: 2, toString: 6, finger: .one)],
                tips: ["A-shape dominant 7th barre"]
            )
        case .M7:
            return ChordShape(
                kind: .aShape,
                label: "\(rootFret)fr",
                frets: [
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 1),
                    .fretted(rootFret + 2),
                    .fretted(rootFret)
                ],
                fingers: [nil, .one, .three, .two, .four, .one],
                barres: [ChordBarre(fret: rootFret, fromString: 2, toString: 6, finger: .one)],
                tips: ["A-shape major 7th barre"]
            )
        case .m7:
            return ChordShape(
                kind: .aShape,
                label: "\(rootFret)fr",
                frets: [
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret),
                    .fretted(rootFret + 1),
                    .fretted(rootFret)
                ],
                fingers: [nil, .one, .three, .one, .two, .one],
                barres: [ChordBarre(fret: rootFret, fromString: 2, toString: 6, finger: .one)],
                tips: ["A-shape minor 7th barre"]
            )
        default:
            // Default to major shape
            return ChordShape(
                kind: .aShape,
                label: "\(rootFret)fr",
                frets: [
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret)
                ],
                fingers: [nil, .one, .three, .three, .three, .one],
                barres: [
                    ChordBarre(fret: rootFret, fromString: 2, toString: 6, finger: .one),
                    ChordBarre(fret: rootFret + 2, fromString: 3, toString: 5, finger: .three)
                ],
                tips: ["A-shape barre chord"]
            )
        }
    }
    
    // MARK: - Compact (Upper 4 strings)
    
    private func generateCompactShape(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        let rootFret = (root.semitone + 5) % 12 + 3  // Find comfortable position on 4th string
        
        switch quality {
        case .M:
            return ChordShape(
                kind: .compact,
                label: "\(rootFret)fr",
                frets: [
                    .muted,
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 1)
                ],
                fingers: [nil, nil, .one, .three, .four, .two],
                tips: ["Compact major voicing on upper strings"]
            )
        case .m:
            return ChordShape(
                kind: .compact,
                label: "\(rootFret)fr",
                frets: [
                    .muted,
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 1),
                    .fretted(rootFret + 1)
                ],
                fingers: [nil, nil, .one, .four, .two, .three],
                tips: ["Compact minor voicing"]
            )
        case .seven:
            return ChordShape(
                kind: .compact,
                label: "\(rootFret)fr",
                frets: [
                    .muted,
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 1),
                    .fretted(rootFret + 3)
                ],
                fingers: [nil, nil, .one, .two, .one, .four],
                tips: ["Compact 7th chord"]
            )
        case .M7:
            return ChordShape(
                kind: .compact,
                label: "\(rootFret)fr",
                frets: [
                    .muted,
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2)
                ],
                fingers: [nil, nil, .one, .two, .three, .four],
                tips: ["Compact maj7 voicing"]
            )
        default:
            return ChordShape(
                kind: .compact,
                label: "\(rootFret)fr",
                frets: [
                    .muted,
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 1)
                ],
                fingers: [nil, nil, .one, .three, .four, .two],
                tips: ["Compact voicing on upper strings"]
            )
        }
    }
    
    // MARK: - Color (add9, 6/9, sus)
    
    private func generateColorShape(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        let rootFret = root.semitone
        
        // Pick color variation based on quality
        switch quality {
        case .M, .m:
            // add9 voicing
            return ChordShape(
                kind: .color,
                label: "\(rootFret)fr (add9)",
                frets: [
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret),
                    .fretted(rootFret + 2)
                ],
                fingers: [nil, .one, .two, .three, .one, .four],
                barres: [ChordBarre(fret: rootFret, fromString: 2, toString: 5, finger: .one)],
                tips: ["add9 voicing for rich color"]
            )
        case .seven:
            // 9th chord
            return ChordShape(
                kind: .color,
                label: "\(rootFret)fr (9)",
                frets: [
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret),
                    .fretted(rootFret),
                    .fretted(rootFret + 2)
                ],
                fingers: [nil, .one, .three, .one, .one, .four],
                barres: [ChordBarre(fret: rootFret, fromString: 2, toString: 5, finger: .one)],
                tips: ["9th chord for jazzy color"]
            )
        case .M7, .m7:
            // 6/9 voicing
            return ChordShape(
                kind: .color,
                label: "\(rootFret)fr (6/9)",
                frets: [
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 1),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2)
                ],
                fingers: [nil, .one, .two, .one, .three, .four],
                barres: [ChordBarre(fret: rootFret, fromString: 2, toString: 4, finger: .one)],
                tips: ["6/9 voicing for smooth color"]
            )
        default:
            // sus2 as default color
            return ChordShape(
                kind: .color,
                label: "\(rootFret)fr (sus2)",
                frets: [
                    .muted,
                    .fretted(rootFret),
                    .fretted(rootFret + 2),
                    .fretted(rootFret + 2),
                    .fretted(rootFret),
                    .fretted(rootFret)
                ],
                fingers: [nil, .one, .three, .four, .one, .one],
                barres: [ChordBarre(fret: rootFret, fromString: 2, toString: 6, finger: .one)],
                tips: ["sus2 voicing for open color"]
            )
        }
    }
}

