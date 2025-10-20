//
//  DiatonicTableView.swift
//  OtoTheory
//
//  Phase E-2: Diatonic chord table with Roman numerals
//

import SwiftUI

struct DiatonicTableView: View {
    let key: String
    let scale: String
    @Binding var selectedChord: String?
    let onChordTap: (String, Int) -> Void  // (chordName, degree 1-based)
    let onChordLongPress: ((String) -> Void)?  // Optional long press handler for adding to progression
    
    @State private var showCapo: Bool = false
    @State private var diatonicChords: [DiatonicChord] = []
    @State private var capoSuggestions: [CapoSuggestion] = []
    
    // Non-heptatonic scale detection (SSOT v3.2)
    private var isHeptatonicScale: Bool {
        let scaleId = mapOldScaleTypeToNewId(scale)
        return ScaleMaster.scaleById(scaleId)?.heptatonic ?? true
    }
    
    private var isJapanese: Bool {
        Bundle.main.preferredLocalizations.first == "ja"
    }
    
    private var nonHeptatonicNote: String {
        let scaleId = mapOldScaleTypeToNewId(scale)
        guard let scale = ScaleMaster.scaleById(scaleId) else {
            return isJapanese ? "スケール情報が見つかりません" : "Scale information not found"
        }
        
        return isJapanese ? 
            "このスケールは\(scale.tones)音スケールです。表示は7音として見せますが、実際の音数は\(scale.tones)音です。" :
            "This is a \(scale.tones)-note scale. Displayed as 7 notes but actually contains \(scale.tones) notes."
    }
    
    private func mapOldScaleTypeToNewId(_ type: String) -> String {
        switch type {
        case "Ionian": return "major"
        case "Aeolian": return "naturalMinor"
        case "Dorian": return "dorian"
        case "Phrygian": return "phrygian"
        case "Lydian": return "lydian"
        case "Mixolydian": return "mixolydian"
        case "Locrian": return "locrian"
        case "HarmonicMinor": return "harmonicMinor"
        case "MelodicMinor": return "melodicMinor"
        case "MajorPentatonic": return "majPent"
        case "MinorPentatonic": return "minPent"
        case "Blues": return "bluesMinor"
        case "DiminishedWH": return "dimWholeHalf"
        case "DiminishedHW": return "dimHalfWhole"
        case "Lydianb7": return "lydianb7"
        case "Mixolydianb6": return "mixolydianb6"
        case "PhrygianDominant": return "phrygDominant"
        case "Altered": return "altered"
        case "WholeTone": return "wholeTone"
        default: return type
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text("Diatonic")
                .font(.headline)
            
            // Non-heptatonic note (SSOT v3.2)
            if !isHeptatonicScale {
                VStack(alignment: .leading, spacing: 8) {
                    Text(isJapanese ? "注意" : "Note")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                    
                    Text(nonHeptatonicNote)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Diatonic table (Web-style with unified scrolling)
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 8) {
                    // Roman numeral header
                    HStack(spacing: 4) {
                        Text("")
                            .frame(width: 60)  // Row label column
                        
                        ForEach(diatonicChords) { chord in
                            Text(chord.romanNumeral)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 70)
                        }
                    }
                    
                    Divider()
                    
                    // Open row
                    HStack(alignment: .center, spacing: 4) {
                        Text("Open")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 60, alignment: .leading)
                        
                        ForEach(Array(diatonicChords.enumerated()), id: \.element.id) { index, chord in
                            DiatonicChordButton(
                                chord: chord,
                                isSelected: selectedChord == chord.chordName,
                                action: {
                                    // Call onChordTap - parent handles toggle logic
                                    onChordTap(chord.chordName, index + 1)  // 1-based degree
                                },
                                onLongPress: {
                                    onChordLongPress?(chord.chordName)
                                }
                            )
                        }
                    }
                    
                    // Capo rows (Top 2)
                    ForEach(capoSuggestions.prefix(2)) { suggestion in
                        Divider()
                        
                        HStack(alignment: .center, spacing: 4) {
                            Text("Capo \(suggestion.capoFret)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 60, alignment: .leading)
                            
                            ForEach(getCapoDiatonicChords(capoFret: suggestion.capoFret)) { chord in
                                CapoChordButton(chord: chord)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGray5))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            loadDiatonicChords()
        }
        .onChange(of: key) { _, _ in
            loadDiatonicChords()
        }
        .onChange(of: scale) { _, _ in
            loadDiatonicChords()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadDiatonicChords() {
        // Get diatonic chords from TheoryBridge
        // For MVP, use hardcoded logic for major/minor scales
        
        print("🎵 Loading diatonic chords for key: \(key), scale: \(scale)")
        
        let scaleLower = scale.lowercased()
        
        // Check for major scale variations (exact match or starts with)
        if scaleLower == "major" || scaleLower == "ionian" || scaleLower == "major scale" {
            diatonicChords = getMajorDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) major diatonic chords for \(scale)")
        }
        // Check for minor scale variations (exact match or starts with, but not pentatonic)
        else if (scaleLower == "minor" || scaleLower == "aeolian" || scaleLower == "natural minor") {
            diatonicChords = getMinorDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) minor diatonic chords for \(scale)")
        }
        // For other diatonic modes, use mode-specific diatonic chords
        else if scaleLower == "dorian" {
            diatonicChords = getDorianDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for Dorian")
        }
        else if scaleLower == "phrygian" {
            diatonicChords = getPhrygianDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for Phrygian")
        }
        else if scaleLower == "lydian" {
            diatonicChords = getLydianDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for Lydian")
        }
        else if scaleLower == "mixolydian" {
            diatonicChords = getMixolydianDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for Mixolydian")
        }
        else if scaleLower == "locrian" {
            diatonicChords = getLocrianDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for Locrian")
        }
        else if scaleLower == "harmonicminor" || scaleLower == "harmonic minor" {
            diatonicChords = getHarmonicMinorDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for HarmonicMinor")
        }
        else if scaleLower == "melodicminor" || scaleLower == "melodic minor" {
            diatonicChords = getMelodicMinorDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for MelodicMinor")
        }
        // Web版仕様: Pentatonic scales use their parent mode's diatonic chords
        else if scaleLower == "majorpentatonic" {
            // MajorPentatonic → Ionian (Major)
            diatonicChords = getMajorDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) major diatonic chords for MajorPentatonic (parent: Ionian)")
        }
        else if scaleLower == "minorpentatonic" {
            // MinorPentatonic → Aeolian (Minor)
            diatonicChords = getMinorDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) minor diatonic chords for MinorPentatonic (parent: Aeolian)")
        }
        else if scaleLower == "blues" {
            // Blues → Mixolydian (Dominant)
            diatonicChords = getMixolydianDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for Blues (parent: Mixolydian)")
        }
        // Advanced scales
        else if scaleLower == "lydianb7" || scaleLower == "lydian b7" || scaleLower == "lydian dominant" {
            diatonicChords = getLydianb7DiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for Lydian b7")
        }
        else if scaleLower == "mixolydianb6" || scaleLower == "mixolydian b6" {
            diatonicChords = getMixolydianb6DiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for Mixolydian b6")
        }
        else if scaleLower == "phrygiandominant" || scaleLower == "phrygian dominant" || scaleLower == "spanish phrygian" {
            diatonicChords = getPhrygianDominantDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for Phrygian Dominant")
        }
        else if scaleLower == "altered" || scaleLower == "super locrian" {
            diatonicChords = getAlteredDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for Altered")
        }
        else if scaleLower == "wholetone" || scaleLower == "whole tone" {
            diatonicChords = getWholeToneDiatonicChords(root: key)
            print("✅ Loaded \(diatonicChords.count) diatonic chords for Whole-Tone")
        }
        else {
            // For other non-heptatonic scales, show no diatonic table
            print("⚠️ Non-diatonic scale: \(scale) - hiding diatonic table")
            diatonicChords = []
        }
        
        // Load capo suggestions (Top 2) - always load if we have diatonic chords
        if !diatonicChords.isEmpty {
            capoSuggestions = getCapoSuggestions(key: key)
            print("✅ Loaded \(capoSuggestions.count) capo suggestions")
        } else {
            capoSuggestions = []
        }
    }
    
    private func getMajorDiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        // Map enharmonic equivalents
        let keyMap: [String: String] = [
            "Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"
        ]
        let normalizedRoot = keyMap[root] ?? root
        
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else {
            print("❌ Invalid root note: \(root)")
            return []
        }
        
        let intervals = [0, 2, 4, 5, 7, 9, 11]  // Major scale intervals
        let qualities: [DiatonicChord.ChordQuality] = [.major, .minor, .minor, .major, .major, .minor, .diminished]
        let romanNumerals = ["I", "ii", "iii", "IV", "V", "vi", "vii°"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            let noteName = notes[noteIndex]
            let quality = qualities[index]
            let chord = noteName + quality.symbol
            
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumerals[index],
                chordName: chord,
                quality: quality
            )
        }
    }
    
    private func getMinorDiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        // Map enharmonic equivalents
        let keyMap: [String: String] = [
            "Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"
        ]
        let normalizedRoot = keyMap[root] ?? root
        
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else {
            print("❌ Invalid root note: \(root)")
            return []
        }
        
        let intervals = [0, 2, 3, 5, 7, 8, 10]  // Natural minor scale intervals
        let qualities: [DiatonicChord.ChordQuality] = [.minor, .diminished, .major, .minor, .minor, .major, .major]
        let romanNumerals = ["i", "ii°", "III", "iv", "v", "VI", "VII"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            let noteName = notes[noteIndex]
            let quality = qualities[index]
            let chord = noteName + quality.symbol
            
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumerals[index],
                chordName: chord,
                quality: quality
            )
        }
    }
    
    private func getDorianDiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let keyMap: [String: String] = ["Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"]
        let normalizedRoot = keyMap[root] ?? root
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else { return [] }
        
        let intervals = [0, 2, 3, 5, 7, 9, 10]  // Dorian intervals
        let qualities: [DiatonicChord.ChordQuality] = [.minor, .minor, .major, .major, .minor, .diminished, .major]
        let romanNumerals = ["i", "ii", "III", "IV", "v", "vi°", "VII"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumerals[index],
                chordName: notes[noteIndex] + qualities[index].symbol,
                quality: qualities[index]
            )
        }
    }
    
    private func getPhrygianDiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let keyMap: [String: String] = ["Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"]
        let normalizedRoot = keyMap[root] ?? root
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else { return [] }
        
        let intervals = [0, 1, 3, 5, 7, 8, 10]  // Phrygian intervals
        let qualities: [DiatonicChord.ChordQuality] = [.minor, .major, .major, .minor, .diminished, .major, .minor]
        let romanNumerals = ["i", "II", "III", "iv", "v°", "VI", "vii"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumerals[index],
                chordName: notes[noteIndex] + qualities[index].symbol,
                quality: qualities[index]
            )
        }
    }
    
    private func getLydianDiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let keyMap: [String: String] = ["Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"]
        let normalizedRoot = keyMap[root] ?? root
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else { return [] }
        
        let intervals = [0, 2, 4, 6, 7, 9, 11]  // Lydian intervals
        let qualities: [DiatonicChord.ChordQuality] = [.major, .major, .minor, .diminished, .major, .minor, .minor]
        let romanNumerals = ["I", "II", "iii", "#iv°", "V", "vi", "vii"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumerals[index],
                chordName: notes[noteIndex] + qualities[index].symbol,
                quality: qualities[index]
            )
        }
    }
    
    private func getMixolydianDiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let keyMap: [String: String] = ["Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"]
        let normalizedRoot = keyMap[root] ?? root
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else { return [] }
        
        let intervals = [0, 2, 4, 5, 7, 9, 10]  // Mixolydian intervals
        let qualities: [DiatonicChord.ChordQuality] = [.major, .minor, .diminished, .major, .minor, .minor, .major]
        let romanNumerals = ["I", "ii", "iii°", "IV", "v", "vi", "VII"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumerals[index],
                chordName: notes[noteIndex] + qualities[index].symbol,
                quality: qualities[index]
            )
        }
    }
    
    private func getLocrianDiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let keyMap: [String: String] = ["Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"]
        let normalizedRoot = keyMap[root] ?? root
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else { return [] }
        
        let intervals = [0, 1, 3, 5, 6, 8, 10]  // Locrian intervals
        let qualities: [DiatonicChord.ChordQuality] = [.diminished, .major, .minor, .minor, .major, .major, .minor]
        let romanNumerals = ["i°", "II", "iii", "iv", "V", "VI", "vii"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumerals[index],
                chordName: notes[noteIndex] + qualities[index].symbol,
                quality: qualities[index]
            )
        }
    }
    
    private func getHarmonicMinorDiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let keyMap: [String: String] = ["Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"]
        let normalizedRoot = keyMap[root] ?? root
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else { return [] }
        
        let intervals = [0, 2, 3, 5, 7, 8, 11]  // Harmonic minor intervals
        let qualities: [DiatonicChord.ChordQuality] = [.minor, .diminished, .augmented, .minor, .major, .major, .diminished]
        let romanNumerals = ["i", "ii°", "III+", "iv", "V", "VI", "vii°"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumerals[index],
                chordName: notes[noteIndex] + qualities[index].symbol,
                quality: qualities[index]
            )
        }
    }
    
    private func getMelodicMinorDiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let keyMap: [String: String] = ["Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"]
        let normalizedRoot = keyMap[root] ?? root
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else { return [] }
        
        let intervals = [0, 2, 3, 5, 7, 9, 11]  // Melodic minor intervals (ascending)
        let qualities: [DiatonicChord.ChordQuality] = [.minor, .minor, .augmented, .major, .major, .diminished, .diminished]
        let romanNumerals = ["i", "ii", "III+", "IV", "V", "vi°", "vii°"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumerals[index],
                chordName: notes[noteIndex] + qualities[index].symbol,
                quality: qualities[index]
            )
        }
    }
    
    private func getCapoSuggestions(key: String) -> [CapoSuggestion] {
        // Calculate best capo positions (prefer easy open chord shapes)
        // C, G, D, A, E are the easiest open chord shapes
        let easyShapes = ["C", "G", "D", "A", "E"]
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        // Map enharmonic equivalents
        let keyMap: [String: String] = [
            "Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"
        ]
        let normalizedKey = keyMap[key] ?? key
        
        guard let rootIndex = notes.firstIndex(of: normalizedKey) else {
            print("❌ Invalid key for capo: \(key)")
            return []
        }
        
        var suggestions: [(capoFret: Int, shaped: String, score: Int)] = []
        
        // Try capo positions 1-7
        for capoFret in 1...7 {
            let shapedIndex = (rootIndex - capoFret + 12) % 12
            let shapedKey = notes[shapedIndex]
            
            // Score based on how easy the shape is
            if let easyIndex = easyShapes.firstIndex(of: shapedKey) {
                let score = 5 - easyIndex  // C=5, G=4, D=3, A=2, E=1
                suggestions.append((capoFret, shapedKey, score))
            }
        }
        
        // Sort by score (best first) and take top 2
        let topSuggestions = suggestions.sorted { $0.score > $1.score }.prefix(2)
        
        return topSuggestions.map { suggestion in
            CapoSuggestion(
                capoFret: suggestion.capoFret,
                shapedChord: suggestion.shaped,
                soundingChord: key
            )
        }
    }
    
    /// Get diatonic chords for a specific capo position (shaped chords)
    private func getCapoDiatonicChords(capoFret: Int) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        // Map enharmonic equivalents
        let keyMap: [String: String] = [
            "Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"
        ]
        let normalizedKey = keyMap[key] ?? key
        
        guard let rootIndex = notes.firstIndex(of: normalizedKey) else {
            print("❌ Invalid key for capo diatonic: \(key)")
            return []
        }
        
        // Calculate the "shaped" key (what you finger)
        let shapedRootIndex = (rootIndex - capoFret + 12) % 12
        let shapedKey = notes[shapedRootIndex]
        
        // Get diatonic chords for the shaped key based on the current scale
        let scaleLower = scale.lowercased()
        
        if scaleLower == "major" || scaleLower == "ionian" || scaleLower == "major scale" {
            return getMajorDiatonicChords(root: shapedKey)
        } else if scaleLower == "minor" || scaleLower == "aeolian" || scaleLower == "natural minor" {
            return getMinorDiatonicChords(root: shapedKey)
        } else if scaleLower == "dorian" {
            return getDorianDiatonicChords(root: shapedKey)
        } else if scaleLower == "phrygian" {
            return getPhrygianDiatonicChords(root: shapedKey)
        } else if scaleLower == "lydian" {
            return getLydianDiatonicChords(root: shapedKey)
        } else if scaleLower == "mixolydian" {
            return getMixolydianDiatonicChords(root: shapedKey)
        } else if scaleLower == "locrian" {
            return getLocrianDiatonicChords(root: shapedKey)
        } else if scaleLower == "harmonicminor" || scaleLower == "harmonic minor" {
            return getHarmonicMinorDiatonicChords(root: shapedKey)
        } else if scaleLower == "melodicminor" || scaleLower == "melodic minor" {
            return getMelodicMinorDiatonicChords(root: shapedKey)
        } else if scaleLower == "majorpentatonic" {
            return getMajorDiatonicChords(root: shapedKey)
        } else if scaleLower == "minorpentatonic" {
            return getMinorDiatonicChords(root: shapedKey)
        } else if scaleLower == "blues" {
            return getMixolydianDiatonicChords(root: shapedKey)
        }
        // Advanced scales
        else if scaleLower == "lydianb7" || scaleLower == "lydian b7" || scaleLower == "lydian dominant" {
            return getLydianb7DiatonicChords(root: shapedKey)
        } else if scaleLower == "mixolydianb6" || scaleLower == "mixolydian b6" {
            return getMixolydianb6DiatonicChords(root: shapedKey)
        } else if scaleLower == "phrygiandominant" || scaleLower == "phrygian dominant" || scaleLower == "spanish phrygian" {
            return getPhrygianDominantDiatonicChords(root: shapedKey)
        } else if scaleLower == "altered" || scaleLower == "super locrian" {
            return getAlteredDiatonicChords(root: shapedKey)
        } else if scaleLower == "wholetone" || scaleLower == "whole tone" {
            return getWholeToneDiatonicChords(root: shapedKey)
        } else {
            return []
        }
    }
}

// MARK: - Subviews

struct DiatonicChordButton: View {
    let chord: DiatonicChord
    let isSelected: Bool
    let action: () -> Void
    let onLongPress: (() -> Void)?
    
    @State private var isAdding: Bool = false
    @State private var addScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: action) {
            // Chip-style button
            Text(chord.chordName)
                .font(.system(size: 15, weight: isSelected ? .bold : .semibold))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 70)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color(.systemGray4))
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(addScale)
        .opacity(isAdding ? 0.5 : 1.0)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    // "Sucked in" animation
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        addScale = 0.8
                        isAdding = true
                    }
                    
                    // Call long press handler
                    onLongPress?()
                    
                    // Reset animation after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            addScale = 1.0
                            isAdding = false
                        }
                    }
                }
        )
        .contextMenu {
            Button(action: {
                // Navigate to chord library
                NotificationCenter.default.post(
                    name: .navigateToChordLibrary,
                    object: chord.chordName
                )
            }) {
                Label("フォームを確認", systemImage: "music.note")
            }
            
            Button(action: {
                // Add to progression slot
                onLongPress?()
            }) {
                Label("スロットに追加", systemImage: "plus")
            }
        }
    }
}

struct CapoChordButton: View {
    let chord: DiatonicChord
    
    var body: some View {
        // Chip-style (disabled, for reference)
        Text(chord.chordName)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.secondary)
            .frame(width: 70)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray5))
            )
    }
}

#Preview {
    DiatonicTableView(
        key: "C",
        scale: "Major",
        selectedChord: .constant(nil),
        onChordTap: { _, _ in },
        onChordLongPress: { chord in
            print("Long press: \(chord)")
        }
    )
    .padding()
}

// MARK: - Advanced Scale Diatonic Chords

extension DiatonicTableView {
    
    private func getLydianb7DiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        let keyMap: [String: String] = [
            "Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"
        ]
        let normalizedRoot = keyMap[root] ?? root
        
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else {
            print("❌ Invalid root note: \(root)")
            return []
        }
        
        // Lydian b7 intervals: R, 2, 3, #4, 5, 6, b7
        let intervals = [0, 2, 4, 6, 7, 9, 10]
        let qualities: [DiatonicChord.ChordQuality] = [.major, .minor, .minor, .augmented, .major, .minor, .minor]
        let romanNumerals = ["I", "ii", "iii", "IV+", "V", "vi", "vii"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            let noteName = notes[noteIndex]
            let quality = qualities[index]
            let romanNumeral = romanNumerals[index]
            
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumeral,
                chordName: "\(noteName)\(quality.symbol)",
                quality: quality
            )
        }
    }
    
    private func getMixolydianb6DiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        let keyMap: [String: String] = [
            "Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"
        ]
        let normalizedRoot = keyMap[root] ?? root
        
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else {
            print("❌ Invalid root note: \(root)")
            return []
        }
        
        // Mixolydian b6 intervals: R, 2, 3, 4, 5, b6, b7
        let intervals = [0, 2, 4, 5, 7, 8, 10]
        let qualities: [DiatonicChord.ChordQuality] = [.major, .minor, .diminished, .major, .major, .minor, .minor]
        let romanNumerals = ["I", "ii", "iii°", "IV", "V", "vi", "vii"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            let noteName = notes[noteIndex]
            let quality = qualities[index]
            let romanNumeral = romanNumerals[index]
            
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumeral,
                chordName: "\(noteName)\(quality.symbol)",
                quality: quality
            )
        }
    }
    
    private func getPhrygianDominantDiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        let keyMap: [String: String] = [
            "Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"
        ]
        let normalizedRoot = keyMap[root] ?? root
        
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else {
            print("❌ Invalid root note: \(root)")
            return []
        }
        
        // Phrygian Dominant intervals: R, b2, 3, 4, 5, b6, b7
        let intervals = [0, 1, 4, 5, 7, 8, 10]
        let qualities: [DiatonicChord.ChordQuality] = [.major, .diminished, .diminished, .major, .major, .minor, .minor]
        let romanNumerals = ["I", "ii°", "iii°", "IV", "V", "vi", "vii"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            let noteName = notes[noteIndex]
            let quality = qualities[index]
            let romanNumeral = romanNumerals[index]
            
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumeral,
                chordName: "\(noteName)\(quality.symbol)",
                quality: quality
            )
        }
    }
    
    private func getAlteredDiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        let keyMap: [String: String] = [
            "Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"
        ]
        let normalizedRoot = keyMap[root] ?? root
        
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else {
            print("❌ Invalid root note: \(root)")
            return []
        }
        
        // Altered intervals: R, b2, #2, 3, b5, b6, b7
        let intervals = [0, 1, 3, 4, 6, 8, 10]
        let qualities: [DiatonicChord.ChordQuality] = [.major, .diminished, .augmented, .diminished, .diminished, .minor, .minor]
        let romanNumerals = ["I", "ii°", "iii+", "iv°", "v°", "vi", "vii"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            let noteName = notes[noteIndex]
            let quality = qualities[index]
            let romanNumeral = romanNumerals[index]
            
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumeral,
                chordName: "\(noteName)\(quality.symbol)",
                quality: quality
            )
        }
    }
    
    private func getWholeToneDiatonicChords(root: String) -> [DiatonicChord] {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        
        let keyMap: [String: String] = [
            "Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"
        ]
        let normalizedRoot = keyMap[root] ?? root
        
        guard let rootIndex = notes.firstIndex(of: normalizedRoot) else {
            print("❌ Invalid root note: \(root)")
            return []
        }
        
        // Whole-Tone intervals: R, 2, 3, #4, #5, b7
        let intervals = [0, 2, 4, 6, 8, 10]
        let qualities: [DiatonicChord.ChordQuality] = [.major, .major, .major, .augmented, .augmented, .major]
        let romanNumerals = ["I", "II", "III", "IV+", "V+", "VII"]
        
        return intervals.enumerated().map { index, interval in
            let noteIndex = (rootIndex + interval) % 12
            let noteName = notes[noteIndex]
            let quality = qualities[index]
            let romanNumeral = romanNumerals[index]
            
            return DiatonicChord(
                degree: index + 1,
                romanNumeral: romanNumeral,
                chordName: "\(noteName)\(quality.symbol)",
                quality: quality
            )
        }
    }
}

