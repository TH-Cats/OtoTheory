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
    
    // MARK: - Helpers (relative patterns)
    
    private func eShapeFrets(rootFret r: Int, quality: ChordLibraryQuality) -> [ChordFret]? {
        switch quality {
        case .M:     return [.fretted(r), .fretted(r), .fretted(r+1), .fretted(r+2), .fretted(r+2), .fretted(r)]
        case .m:     return [.fretted(r), .fretted(r), .fretted(r),   .fretted(r+2), .fretted(r+2), .fretted(r)]
        case .seven: return [.fretted(r), .fretted(r), .fretted(r+1), .fretted(r),   .fretted(r+2), .fretted(r)]
        case .M7:    return [.fretted(r), .fretted(r), .fretted(r+1), .fretted(r+1), .fretted(r+2), .fretted(r)]
        case .six:   return [.fretted(r), .fretted(r+2), .fretted(r+1), .fretted(r+2), .fretted(r+2), .fretted(r)]
        case .dim:   return [.fretted(r), .fretted(r), .fretted(r),   .fretted(r+1), .fretted(r+1), .fretted(r)]
        case .dim7:  return [.fretted(r), .fretted(r+2), .fretted(r), .fretted(r+1), .fretted(r+1), .fretted(r)]
        default:     return [.fretted(r), .fretted(r), .fretted(r+1), .fretted(r+2), .fretted(r+2), .fretted(r)]
        }
    }
    
    private func aShapeFrets(rootFret r: Int, quality: ChordLibraryQuality) -> [ChordFret]? {
        switch quality {
        case .M:     return [.fretted(r),   .fretted(r+2), .fretted(r+2), .fretted(r+2), .fretted(r),   .muted]
        case .m:     return [.fretted(r),   .fretted(r+1), .fretted(r+2), .fretted(r+2), .fretted(r),   .muted]
        case .seven: return [.fretted(r),   .fretted(r+2), .fretted(r),   .fretted(r+2), .fretted(r),   .muted]
        case .M7:    return [.fretted(r),   .fretted(r+2), .fretted(r+1), .fretted(r+2), .fretted(r),   .muted]
        case .six:   return [.fretted(r+2), .fretted(r+2), .fretted(r+2), .fretted(r+2), .fretted(r),   .muted]
        case .dim:   return [.fretted(r),   .fretted(r+1), .fretted(r+2), .fretted(r+1), .fretted(r),   .muted]
        case .dim7:  return [.fretted(r+2), .fretted(r+1), .fretted(r+2), .fretted(r+1), .fretted(r),   .muted]
        default:     return [.fretted(r),   .fretted(r+2), .fretted(r+2), .fretted(r+2), .fretted(r),   .muted]
        }
    }

    private func makeCompact(from base: [ChordFret]) -> [ChordFret] {
        // Keep 1..4 strings, mute 5..6
        return [base[0], base[1], base[2], base[3], .muted, .muted]
    }

    // MARK: - Open Shapes
    
    private func generateOpenShape(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        // Only generate open shapes for roots within first 4 frets
        guard root.semitone <= 4 else { return nil }
        
        switch (root, quality) {
        // C Major family
        case (.C, .M):
            // Canonical C: [0,1,0,2,3,x] (1->6)
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .fretted(1), .open, .fretted(2), .fretted(3), .muted],
                fingers: [nil, .one, nil, .two, .three, nil],
                tips: ["Standard C major", "Mute 6th string."]
            )
        case (.C, .m):
            // Use small barre near 3rd fret as open equivalent
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.fretted(3), .fretted(4), .fretted(5), .fretted(5), .fretted(3), .muted],
                fingers: [.one, .two, .three, .four, .one, nil],
                barres: [ChordBarre(fret: 3, fromString: 1, toString: 5, finger: .one)],
                tips: ["Cm first-position shape"]
            )
        case (.C, .seven):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .fretted(1), .fretted(3), .fretted(2), .fretted(3), .muted],
                fingers: [nil, .one, .four, .two, .three, nil],
                tips: ["C7 open"]
            )
        case (.C, .M7):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .open, .open, .fretted(2), .fretted(3), .muted],
                fingers: [nil, nil, nil, .two, .three, nil],
                tips: ["Cmaj7 open"]
            )
        
        // D Major family (unchanged canonical)
        case (.D, .M):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.fretted(2), .fretted(3), .fretted(2), .open, .muted, .muted],
                fingers: [.two, .three, .one, nil, nil, nil],
                tips: ["Classic D major open chord"]
            )
        case (.D, .m):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.fretted(1), .fretted(3), .fretted(2), .open, .muted, .muted],
                fingers: [.one, .three, .two, nil, nil, nil],
                tips: ["Dm open voicing"]
            )
        case (.D, .seven):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.fretted(2), .fretted(1), .fretted(2), .open, .muted, .muted],
                fingers: [.two, .one, .three, nil, nil, nil],
                tips: ["D7 open chord"]
            )
        case (.D, .M7):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.fretted(2), .fretted(2), .fretted(2), .open, .muted, .muted],
                fingers: [.one, .two, .three, nil, nil, nil],
                tips: ["Dmaj7 open voicing"]
            )
        
        // E Major family
        case (.E, .M):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .open, .fretted(1), .fretted(2), .fretted(2), .open],
                fingers: [nil, nil, .one, .three, .two, nil],
                tips: ["Classic E major open chord"]
            )
        case (.E, .m):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .open, .open, .fretted(2), .fretted(2), .open],
                fingers: [nil, nil, nil, .three, .two, nil],
                tips: ["Em open"]
            )
        case (.E, .seven):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .open, .fretted(1), .open, .fretted(2), .open],
                fingers: [nil, nil, .one, nil, .two, nil],
                tips: ["E7 open"]
            )
        case (.E, .M7):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .open, .fretted(1), .fretted(1), .fretted(2), .open],
                fingers: [nil, nil, .one, .two, .three, nil],
                tips: ["Emaj7 open"]
            )
        
        // G Major family (keep canonical)
        case (.G, .M):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.fretted(3), .open, .open, .open, .fretted(2), .fretted(3)],
                fingers: [.four, nil, nil, nil, .two, .three],
                tips: ["Classic G major open chord"]
            )
        case (.G, .m):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.fretted(3), .fretted(3), .fretted(3), .fretted(5), .fretted(5), .fretted(3)],
                fingers: [.one, .one, .one, .three, .four, .one],
                barres: [ChordBarre(fret: 3, fromString: 1, toString: 6, finger: .one)],
                tips: ["Gm barre (first position)"]
            )
        case (.G, .seven):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.fretted(1), .open, .open, .open, .fretted(2), .fretted(3)],
                fingers: [.one, nil, nil, nil, .two, .three],
                tips: ["G7 open"]
            )
        
        // A Major family (canonical)
        case (.A, .M):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .fretted(2), .fretted(2), .fretted(2), .open, .muted],
                fingers: [nil, .three, .two, .one, nil, nil],
                tips: ["A major open"]
            )
        case (.A, .m):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .fretted(1), .fretted(2), .fretted(2), .open, .muted],
                fingers: [nil, .one, .three, .two, nil, nil],
                tips: ["Am open"]
            )
        case (.A, .seven):
            return ChordShape(
                kind: .open,
                label: "Open",
                frets: [.open, .fretted(2), .open, .fretted(2), .open, .muted],
                fingers: [nil, .two, nil, .three, nil, nil],
                tips: ["A7 open"]
            )
        default:
            return nil
        }
    }
    
    // MARK: - E-Shape (6th string root)
    
    private func generateEShape(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        // 6th string open = E = semitone 4
        // Calculate fret: (root - 4 + 12) % 12, but if 0 use 12 for playability
        var r = (root.semitone - 4 + 12) % 12
        if r == 0 { r = 12 }
        guard let frets = eShapeFrets(rootFret: r, quality: quality) else { return nil }
        
        // Determine fingers and tips based on quality
        let (fingers, tips): ([ChordFinger?], [String]) = {
            switch quality {
            case .dim:
                return ([.one, .one, .one, .four, .three, .one],
                        ["Anxious spice.", "Insert for just one beat as bridge."])
            case .dim7:
                return ([.one, .two, .one, .four, .three, .one],
                        ["Symmetrical tension.", "Slide by m3 for sequences."])
            default:
                return ([.one, .three, .four, .two, .one, .one],
                        ["E-shape \(quality.displayName.isEmpty ? "Maj" : quality.displayName) barre"])
            }
        }()
        
        return ChordShape(
            kind: .eShape,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: [ChordBarre(fret: r, fromString: 1, toString: 6, finger: .one)],
            tips: tips
        )
    }
    
    // MARK: - A-Shape (5th string root)
    
    private func generateAShape(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        // 5th string open = A = semitone 9
        // Calculate fret: (root - 9 + 12) % 12, but if 0 use 12 for playability
        var r = (root.semitone - 9 + 12) % 12
        if r == 0 { r = 12 }
        guard let frets = aShapeFrets(rootFret: r, quality: quality) else { return nil }
        
        // Determine fingers and tips based on quality
        let (fingers, tips): ([ChordFinger?], [String]) = {
            switch quality {
            case .dim:
                return ([.one, .two, .four, .three, .one, nil],
                        ["One-beat bridge.", "Arpeggio passage sounds elegant."])
            case .dim7:
                return ([.four, .two, .three, .two, .one, nil],
                        ["Chromatic leading.", "Move by m3 for classic diminished runs."])
            default:
                return ([.one, .three, .three, .three, .one, nil],
                        ["A-shape \(quality.displayName.isEmpty ? "Maj" : quality.displayName) barre"])
            }
        }()
        
        return ChordShape(
            kind: .aShape,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: [ChordBarre(fret: r, fromString: 1, toString: 5, finger: .one)],
            tips: tips
        )
    }
    
    // MARK: - Compact (Upper 4 strings)
    
    private func generateCompactShape(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        // Use same fret as E-shape for consistency
        var r = (root.semitone - 4 + 12) % 12
        if r == 0 { r = 12 }
        // Prefer E-shape compact; if nil fallback to A-shape
        let base = eShapeFrets(rootFret: r, quality: quality) ?? aShapeFrets(rootFret: r, quality: quality)
        guard let baseFrets = base else { return nil }
        let compact = makeCompact(from: baseFrets)
        return ChordShape(
            kind: .compact,
            label: "\(r)fr",
            frets: compact,
            fingers: [nil, nil, .one, .two, nil, nil],
            tips: ["Compact \(quality.displayName.isEmpty ? "Maj" : quality.displayName)"]
        )
    }
    
    // MARK: - Color (add9, 6/9, sus)
    
    private func generateColorShape(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        // Use same fret as E-shape for consistency
        var r = (root.semitone - 4 + 12) % 12
        if r == 0 { r = 12 }
        guard let base = eShapeFrets(rootFret: r, quality: .M) else { return nil }
        let compact = makeCompact(from: base)
        var frets = compact
        var label = "\(r)fr"
        switch quality {
        case .M, .m:
            // add9: 1弦 r -> r+2
            if case .fretted = frets[0] { frets[0] = .fretted(r+2) } else { frets[0] = .fretted(r+2) }
            label += " (add9)"
        case .seven:
            // 9th: 1弦 r -> r+2, 4弦 -> r
            frets[0] = .fretted(r+2)
            frets[3] = .fretted(r)
            label += " (9)"
        case .M7, .m7:
            // 6/9: 1弦 r+2, 2弦 r+2
            frets[0] = .fretted(r+2)
            frets[1] = .fretted(r+2)
            label += " (6/9)"
        default:
            // sus2: 3弦 r+1 -> r
            frets[2] = .fretted(r)
            label += " (sus2)"
        }
        return ChordShape(
            kind: .color,
            label: label,
            frets: frets,
            fingers: [nil, nil, .one, .two, nil, nil],
            tips: ["Color voicing"]
        )
    }
}

