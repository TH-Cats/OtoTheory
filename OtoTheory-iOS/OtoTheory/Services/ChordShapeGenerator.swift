//
//  ChordShapeGenerator.swift
//  OtoTheory
//
//  Chord Shape Generator - v3.1.2 Rewrite
//  Root-6/5/4 + Variant A/B system (Phase 1: dim/dim7/sus)
//

import Foundation

@MainActor
class ChordShapeGenerator {
    static let shared = ChordShapeGenerator()
    
    private init() {}
    
    // MARK: - Main Entry Point
    
    func generateShapes(root: ChordRoot, quality: ChordLibraryQuality) -> [ChordShape] {
        var shapes: [ChordShape] = []
        
        // 1. Try Open form first
        if let openShape = generateOpenShape(root: root, quality: quality) {
            shapes.append(openShape)
        }
        
        // 2. Generate movable forms based on quality
        switch quality {
        case .dim:
            shapes.append(contentsOf: generateDimForms(root: root))
        case .dim7:
            shapes.append(contentsOf: generateDim7Forms(root: root))
        case .sus2:
            shapes.append(contentsOf: generateSus2Forms(root: root))
        case .sus4:
            shapes.append(contentsOf: generateSus4Forms(root: root))
        case .add9:
            shapes.append(contentsOf: generateAdd9Forms(root: root))
        default:
            // Fallback: generate basic Major/minor forms
            shapes.append(contentsOf: generateBasicForms(root: root, quality: quality))
        }
        
        // Ensure we have at least 3 forms (pad with duplicates if needed)
        while shapes.count < 3 {
            if let first = shapes.first {
                shapes.append(first)
            } else {
                break
            }
        }
        
        // Limit to 5 forms maximum
        return Array(shapes.prefix(5))
    }
    
    // MARK: - Open Shape Dictionary (1→6 order, iOS standard)
    
    private func generateOpenShape(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        let key = "\(root.rawValue)-\(quality.rawValue)"
        
        guard let openDef = openShapeDictionary[key] else { return nil }
        
        return ChordShape(
            kind: .root6,  // Open forms are labeled as Root-6 for consistency
            label: "Open",
            frets: openDef.frets,
            fingers: openDef.fingers,
            barres: [],
            tips: openDef.tips
        )
    }
    
    // MARK: - dim (Diminished Triad) Generation
    
    private func generateDimForms(root: ChordRoot) -> [ChordShape] {
        var forms: [ChordShape] = []
        
        // Root-6 form
        if let root6 = generateDimRoot6(root: root) {
            forms.append(root6)
        }
        
        // Root-5 form
        if let root5 = generateDimRoot5(root: root) {
            forms.append(root5)
        }
        
        // Root-4 form
        if let root4 = generateDimRoot4(root: root) {
            forms.append(root4)
        }
        
        return forms
    }
    
    private func generateDimRoot6(root: ChordRoot) -> ChordShape? {
        // Root on 6th string, open E = 4 semitones
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 4)
        guard r > 0 && r <= 12 else { return nil }
        
        // Pattern: [x, r-1, x, r, x, r] (1→6)
        let frets: [ChordFret] = [
            .muted,
            r-1 > 0 ? .fretted(r-1) : .open,
            .muted,
            .fretted(r),
            .muted,
            .fretted(r)
        ]
        let fingers: [ChordFinger?] = [nil, .two, nil, .one, nil, .three]
        
        return ChordShape(
            kind: .root6,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: [],
            tips: ["Anxious spice.", "Insert for one beat as a bridge."]
        )
    }
    
    private func generateDimRoot5(root: ChordRoot) -> ChordShape? {
        // Root on 5th string, open A = 9 semitones
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 9)
        guard r > 0 && r <= 12 else { return nil }
        
        // Pattern: [r, x, r+1, x, r, x] (1→6)
        let frets: [ChordFret] = [
            .fretted(r),
            .muted,
            .fretted(r+1),
            .muted,
            .fretted(r),
            .muted
        ]
        let fingers: [ChordFinger?] = [.one, nil, .three, nil, .two, nil]
        
        return ChordShape(
            kind: .root5,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: [],
            tips: ["One-beat bridge.", "Arpeggio passage sounds elegant."]
        )
    }
    
    private func generateDimRoot4(root: ChordRoot) -> ChordShape? {
        // Root on 4th string, open D = 2 semitones
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 2)
        guard r > 0 && r <= 12 else { return nil }
        
        // Pattern: [x, r+1, x, r, r-1, x] (1→6)
        let frets: [ChordFret] = [
            .muted,
            .fretted(r+1),
            .muted,
            .fretted(r),
            r-1 > 0 ? .fretted(r-1) : .open,
            .muted
        ]
        let fingers: [ChordFinger?] = [nil, .three, nil, .two, .one, nil]
        
        return ChordShape(
            kind: .root4,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: [],
            tips: ["Compact voicing.", "3-note cluster."]
        )
    }
    
    // MARK: - dim7 (Diminished Seventh) Generation
    
    private func generateDim7Forms(root: ChordRoot) -> [ChordShape] {
        var forms: [ChordShape] = []
        
        // Root-6 form
        if let root6 = generateDim7Root6(root: root) {
            forms.append(root6)
        }
        
        // Root-5 form
        if let root5 = generateDim7Root5(root: root) {
            forms.append(root5)
        }
        
        // Root-4 form
        if let root4 = generateDim7Root4(root: root) {
            forms.append(root4)
        }
        
        return forms
    }
    
    private func generateDim7Root6(root: ChordRoot) -> ChordShape? {
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 4)
        guard r > 0 && r <= 12 else { return nil }
        
        // Pattern: [x, r-1, r, r-1, x, r] (1→6)
        let frets: [ChordFret] = [
            .muted,
            r-1 > 0 ? .fretted(r-1) : .open,
            .fretted(r),
            r-1 > 0 ? .fretted(r-1) : .open,
            .muted,
            .fretted(r)
        ]
        let fingers: [ChordFinger?] = [nil, .two, .three, .one, nil, .four]
        
        return ChordShape(
            kind: .root6,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: [],
            tips: ["Symmetric tension.", "Move in m3 cycles."]
        )
    }
    
    private func generateDim7Root5(root: ChordRoot) -> ChordShape? {
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 9)
        guard r > 0 && r <= 12 else { return nil }
        
        // Pattern: [r, x, r+1, r, r+1, x] (1→6)
        let frets: [ChordFret] = [
            .fretted(r),
            .muted,
            .fretted(r+1),
            .fretted(r),
            .fretted(r+1),
            .muted
        ]
        let fingers: [ChordFinger?] = [.one, nil, .two, .one, .three, nil]
        
        return ChordShape(
            kind: .root5,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: [],
            tips: ["Chromatic leading.", "Move by m3 for classic diminished runs."]
        )
    }
    
    private func generateDim7Root4(root: ChordRoot) -> ChordShape? {
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 2)
        guard r > 0 && r <= 12 else { return nil }
        
        // Pattern: [x, r+1, r, r+1, r-1, x] (1→6)
        let frets: [ChordFret] = [
            .muted,
            .fretted(r+1),
            .fretted(r),
            .fretted(r+1),
            r-1 > 0 ? .fretted(r-1) : .open,
            .muted
        ]
        let fingers: [ChordFinger?] = [nil, .three, .two, .four, .one, nil]
        
        return ChordShape(
            kind: .root4,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: [],
            tips: ["Compact dim7.", "4-note cluster."]
        )
    }
    
    // MARK: - sus2 Generation
    
    private func generateSus2Forms(root: ChordRoot) -> [ChordShape] {
        var forms: [ChordShape] = []
        
        // Try to find practical positions
        if let root6 = generateSus2Root6(root: root) {
            forms.append(root6)
        }
        
        if let root5 = generateSus2Root5(root: root) {
            forms.append(root5)
        }
        
        return forms
    }
    
    private func generateSus2Root6(root: ChordRoot) -> ChordShape? {
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 4)
        guard r > 0 && r <= 12 else { return nil }
        
        // Pattern: [r, r, r-2, r+2, r, r] (1→6) - simplified
        // More practical: [r, r, r, r+2, r, r] with partial mute
        let frets: [ChordFret] = [
            .fretted(r),
            .fretted(r),
            .muted,
            .fretted(r+2),
            .fretted(r),
            .fretted(r)
        ]
        let fingers: [ChordFinger?] = [.one, .one, nil, .four, .one, .one]
        let barres = [ChordBarre(fret: r, fromString: 1, toString: 6, finger: .one)]
        
        return ChordShape(
            kind: .root6,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: barres,
            tips: ["Open, suspended sound.", "No 3rd degree."]
        )
    }
    
    private func generateSus2Root5(root: ChordRoot) -> ChordShape? {
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 9)
        guard r > 0 && r <= 12 else { return nil }
        
        // Pattern: [r, r, r+2, r+2, r, x] (1→6)
        let frets: [ChordFret] = [
            .fretted(r),
            .fretted(r),
            .fretted(r+2),
            .fretted(r+2),
            .fretted(r),
            .muted
        ]
        let fingers: [ChordFinger?] = [.one, .one, .three, .four, .one, nil]
        let barres = [ChordBarre(fret: r, fromString: 1, toString: 5, finger: .one)]
        
        return ChordShape(
            kind: .root5,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: barres,
            tips: ["Bright sus2.", "Resolves to major."]
        )
    }
    
    // MARK: - sus4 Generation
    
    private func generateSus4Forms(root: ChordRoot) -> [ChordShape] {
        var forms: [ChordShape] = []
        
        if let root6 = generateSus4Root6(root: root) {
            forms.append(root6)
        }
        
        if let root5 = generateSus4Root5(root: root) {
            forms.append(root5)
        }
        
        return forms
    }
    
    private func generateSus4Root6(root: ChordRoot) -> ChordShape? {
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 4)
        guard r > 0 && r <= 12 else { return nil }
        
        // Pattern: [r, r, r+2, r+2, r+2, r] (1→6)
        let frets: [ChordFret] = [
            .fretted(r),
            .fretted(r),
            .fretted(r+2),
            .fretted(r+2),
            .fretted(r+2),
            .fretted(r)
        ]
        let fingers: [ChordFinger?] = [.one, .one, .three, .three, .four, .one]
        let barres = [ChordBarre(fret: r, fromString: 1, toString: 6, finger: .one)]
        
        return ChordShape(
            kind: .root6,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: barres,
            tips: ["Suspended, resolving feel.", "4th degree tension."]
        )
    }
    
    private func generateSus4Root5(root: ChordRoot) -> ChordShape? {
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 9)
        guard r > 0 && r <= 12 else { return nil }
        
        // Pattern: [r, r, r+2, r+2, r, x] (1→6)
        let frets: [ChordFret] = [
            .fretted(r),
            .fretted(r),
            .fretted(r+2),
            .fretted(r+2),
            .fretted(r),
            .muted
        ]
        let fingers: [ChordFinger?] = [.one, .one, .three, .four, .one, nil]
        let barres = [ChordBarre(fret: r, fromString: 1, toString: 5, finger: .one)]
        
        return ChordShape(
            kind: .root5,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: barres,
            tips: ["Classic sus4.", "Resolve to the 3rd for classic pull."]
        )
    }
    
    // MARK: - add9 Generation
    
    private func generateAdd9Forms(root: ChordRoot) -> [ChordShape] {
        var forms: [ChordShape] = []
        
        if let root6 = generateAdd9Root6(root: root) {
            forms.append(root6)
        }
        
        if let root5 = generateAdd9Root5(root: root) {
            forms.append(root5)
        }
        
        return forms
    }
    
    private func generateAdd9Root6(root: ChordRoot) -> ChordShape? {
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 4)
        guard r > 0 && r <= 12 else { return nil }
        
        // Pattern: [r, r+2, r+1, r+2, r+2, r] (1→6)
        // (9th on 2nd string)
        let frets: [ChordFret] = [
            .fretted(r),
            .fretted(r+2),
            .fretted(r+1),
            .fretted(r+2),
            .fretted(r+2),
            .fretted(r)
        ]
        let fingers: [ChordFinger?] = [.one, .three, .two, .three, .four, .one]
        let barres = [ChordBarre(fret: r, fromString: 1, toString: 6, finger: .one)]
        
        return ChordShape(
            kind: .variantA,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: barres,
            tips: ["Keep the 3rd; use as color, not suspension.", "Rich add9 sound."]
        )
    }
    
    private func generateAdd9Root5(root: ChordRoot) -> ChordShape? {
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 9)
        guard r > 0 && r <= 12 else { return nil }
        
        // Pattern: [r, r+2, r+4, r+2, r, x] (1→6)
        let frets: [ChordFret] = [
            .fretted(r),
            .fretted(r+2),
            .fretted(r+4),
            .fretted(r+2),
            .fretted(r),
            .muted
        ]
        let fingers: [ChordFinger?] = [.one, .two, .four, .three, .one, nil]
        
        return ChordShape(
            kind: .variantA,
            label: "\(r)fr",
            frets: frets,
            fingers: fingers,
            barres: [],
            tips: ["Bright add9.", "9th on top."]
        )
    }
    
    // MARK: - Basic Forms (Major/minor fallback)
    
    private func generateBasicForms(root: ChordRoot, quality: ChordLibraryQuality) -> [ChordShape] {
        var forms: [ChordShape] = []
        
        // Root-6 basic
        if let root6 = generateBasicRoot6(root: root, quality: quality) {
            forms.append(root6)
        }
        
        // Root-5 basic
        if let root5 = generateBasicRoot5(root: root, quality: quality) {
            forms.append(root5)
        }
        
        return forms
    }
    
    private func generateBasicRoot6(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 4)
        guard r > 0 && r <= 12 else { return nil }
        
        let (fretPattern, tips): ([ChordFret], [String]) = {
            switch quality {
            case .M:
                return ([.fretted(r), .fretted(r), .fretted(r+1), .fretted(r+2), .fretted(r+2), .fretted(r)],
                        ["Classic major barre.", "6th string root."])
            case .m:
                return ([.fretted(r), .fretted(r), .fretted(r), .fretted(r+2), .fretted(r+2), .fretted(r)],
                        ["Minor barre.", "Melancholic sound."])
            default:
                return ([.fretted(r), .fretted(r), .fretted(r+1), .fretted(r+2), .fretted(r+2), .fretted(r)],
                        ["Basic form."])
            }
        }()
        
        let fingers: [ChordFinger?] = [.one, .one, .two, .three, .four, .one]
        let barres = [ChordBarre(fret: r, fromString: 1, toString: 6, finger: .one)]
        
        return ChordShape(
            kind: .root6,
            label: "\(r)fr",
            frets: fretPattern,
            fingers: fingers,
            barres: barres,
            tips: tips
        )
    }
    
    private func generateBasicRoot5(root: ChordRoot, quality: ChordLibraryQuality) -> ChordShape? {
        let r = calculateRootFret(rootSemitone: root.semitone, openStringSemitone: 9)
        guard r > 0 && r <= 12 else { return nil }
        
        let (fretPattern, tips): ([ChordFret], [String]) = {
            switch quality {
            case .M:
                return ([.fretted(r), .fretted(r+2), .fretted(r+2), .fretted(r+2), .fretted(r), .muted],
                        ["Classic major barre.", "5th string root."])
            case .m:
                return ([.fretted(r), .fretted(r+1), .fretted(r+2), .fretted(r+2), .fretted(r), .muted],
                        ["Minor barre.", "5th string root."])
            default:
                return ([.fretted(r), .fretted(r+2), .fretted(r+2), .fretted(r+2), .fretted(r), .muted],
                        ["Basic form."])
            }
        }()
        
        let fingers: [ChordFinger?] = [.one, .three, .three, .three, .one, nil]
        let barres = [ChordBarre(fret: r, fromString: 1, toString: 5, finger: .one)]
        
        return ChordShape(
            kind: .root5,
            label: "\(r)fr",
            frets: fretPattern,
            fingers: fingers,
            barres: barres,
            tips: tips
        )
    }
    
    // MARK: - Helper: Calculate Root Fret
    
    private func calculateRootFret(rootSemitone: Int, openStringSemitone: Int) -> Int {
        var fret = (rootSemitone - openStringSemitone + 12) % 12
        if fret == 0 { fret = 12 }  // Prefer 12th fret over open for movable forms
        return fret
    }
    
    // MARK: - Open Shape Dictionary (1→6 order, iOS standard)
    
    private struct OpenShapeDef {
        let frets: [ChordFret]
        let fingers: [ChordFinger?]
        let tips: [String]
    }
    
    private let openShapeDictionary: [String: OpenShapeDef] = [
        // C shapes
        "C-": OpenShapeDef(
            frets: [.open, .fretted(1), .open, .fretted(2), .fretted(3), .muted],
            fingers: [nil, .one, nil, .two, .three, nil],
            tips: ["Classic C major open chord.", "Mute 6th string."]
        ),
        "C-sus4": OpenShapeDef(
            frets: [.fretted(1), .fretted(1), .open, .fretted(3), .fretted(3), .muted],
            fingers: [.one, .one, nil, .three, .four, nil],
            tips: ["C sus4 open.", "Suspended feel."]
        ),
        "C-sus2": OpenShapeDef(
            frets: [.fretted(3), .fretted(3), .open, .open, .muted, .muted],
            fingers: [.three, .four, nil, nil, nil, nil],
            tips: ["C sus2 open.", "Bright, open sound."]
        ),
        "C-add9": OpenShapeDef(
            frets: [.fretted(3), .fretted(3), .open, .fretted(2), .fretted(3), .muted],
            fingers: [.three, .four, nil, .one, .two, nil],
            tips: ["C add9 open.", "Rich color tone."]
        ),
        
        // D shapes
        "D-": OpenShapeDef(
            frets: [.fretted(2), .fretted(3), .fretted(2), .open, .muted, .muted],
            fingers: [.one, .three, .two, nil, nil, nil],
            tips: ["Classic D major open.", "Mute 5th and 6th strings."]
        ),
        "D-sus4": OpenShapeDef(
            frets: [.fretted(3), .fretted(3), .fretted(2), .open, .muted, .muted],
            fingers: [.three, .four, .one, nil, nil, nil],
            tips: ["D sus4 open.", "Resolve to D major."]
        ),
        "D-sus2": OpenShapeDef(
            frets: [.open, .fretted(3), .fretted(2), .open, .muted, .muted],
            fingers: [nil, .two, .one, nil, nil, nil],
            tips: ["D sus2 open.", "Bright suspended sound."]
        ),
        "D-add9": OpenShapeDef(
            frets: [.open, .fretted(3), .fretted(2), .open, .muted, .muted],
            fingers: [nil, .two, .one, nil, nil, nil],
            tips: ["D add9 open.", "Open 1st string = 9th."]
        ),
        
        // E shapes
        "E-": OpenShapeDef(
            frets: [.open, .open, .fretted(1), .fretted(2), .fretted(2), .open],
            fingers: [nil, nil, .one, .two, .three, nil],
            tips: ["Classic E major open.", "All strings played."]
        ),
        "E-sus4": OpenShapeDef(
            frets: [.open, .open, .fretted(2), .fretted(2), .fretted(2), .open],
            fingers: [nil, nil, .two, .three, .four, nil],
            tips: ["E sus4 open.", "Full open sound."]
        ),
        "E-sus2": OpenShapeDef(
            frets: [.open, .open, .fretted(2), .fretted(4), .fretted(2), .open],
            fingers: [nil, nil, .one, .four, .two, nil],
            tips: ["E sus2 open.", "Wide voicing."]
        ),
        "E-add9": OpenShapeDef(
            frets: [.open, .open, .fretted(1), .fretted(4), .fretted(2), .open],
            fingers: [nil, nil, .one, .four, .two, nil],
            tips: ["E add9 open.", "9th on 4th string."]
        ),
        
        // G shapes
        "G-": OpenShapeDef(
            frets: [.fretted(3), .open, .open, .open, .fretted(2), .fretted(3)],
            fingers: [.two, nil, nil, nil, .one, .three],
            tips: ["Classic G major open.", "Full, ringing sound."]
        ),
        "G-sus4": OpenShapeDef(
            frets: [.fretted(3), .fretted(1), .open, .open, .muted, .fretted(3)],
            fingers: [.three, .one, nil, nil, nil, .four],
            tips: ["G sus4 open.", "Folk style."]
        ),
        "G-sus2": OpenShapeDef(
            frets: [.fretted(3), .fretted(3), .open, .open, .fretted(2), .fretted(3)],
            fingers: [.three, .four, nil, nil, .one, .two],
            tips: ["G sus2 open.", "Bright, jangly."]
        ),
        "G-add9": OpenShapeDef(
            frets: [.fretted(3), .open, .fretted(2), .open, .muted, .fretted(3)],
            fingers: [.three, nil, .one, nil, nil, .four],
            tips: ["G add9 open.", "Add color without 7th."]
        ),
        
        // A shapes
        "A-": OpenShapeDef(
            frets: [.open, .fretted(2), .fretted(2), .fretted(2), .open, .muted],
            fingers: [nil, .one, .two, .three, nil, nil],
            tips: ["Classic A major open.", "Mute 6th string."]
        ),
        "A-sus4": OpenShapeDef(
            frets: [.open, .fretted(3), .fretted(2), .fretted(2), .open, .muted],
            fingers: [nil, .three, .one, .two, nil, nil],
            tips: ["A sus4 open.", "Suspended 4th."]
        ),
        "A-sus2": OpenShapeDef(
            frets: [.open, .open, .fretted(2), .fretted(2), .open, .muted],
            fingers: [nil, nil, .one, .two, nil, nil],
            tips: ["A sus2 open.", "Open 2nd string."]
        ),
        "A-add9": OpenShapeDef(
            frets: [.open, .fretted(2), .fretted(4), .fretted(2), .open, .muted],
            fingers: [nil, .one, .four, .two, nil, nil],
            tips: ["A add9 open.", "9th on 3rd string."]
        )
    ]
}
