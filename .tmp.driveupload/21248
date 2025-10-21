//
//  MIDIExportService.swift
//  OtoTheory
//
//  Phase 3: MIDI export service (SMF Type-1)
//

import Foundation
import AVFoundation
import CoreMIDI

/// Parsed chord structure for unified parsing
struct ParsedChord {
    let mainRoot: String   // "C"
    let quality: String    // "maj7", "m7", "7", ...
    let onBass: String?    // "E" in "C/E"
}

/// MIDI export service for chord progressions
class MIDIExportService {
    
    // MARK: - Export
    
    /// Export chord progression to MIDI file
    /// - Parameters:
    ///   - chords: Array of chord symbols (e.g., ["C", "F", "G", "Am"])
    ///   - sections: Array of sections (optional)
    ///   - key: Key signature (e.g., "C")
    ///   - scale: Scale name (e.g., "Major Scale", "Minor Pentatonic")
    ///   - bpm: Tempo in BPM
    /// - Returns: Data of the MIDI file (SMF Type-1)
    func exportToMIDI(
        chords: [String],
        sectionDefinitions: [SectionDefinition] = [],
        playbackOrder: PlaybackOrder = PlaybackOrder(),
        key: String = "C",
        scale: String? = nil,
        bpm: Double = 120
    ) throws -> Data {
        // Create MusicSequence
        var sequence: MusicSequence?
        guard NewMusicSequence(&sequence) == noErr,
              let seq = sequence else {
            throw MIDIExportError.sequenceCreationFailed
        }
        
        // Set tempo
        var tempoTrack: MusicTrack?
        guard MusicSequenceGetTempoTrack(seq, &tempoTrack) == noErr,
              let tempo = tempoTrack else {
            throw MIDIExportError.tempoTrackCreationFailed
        }
        
        // Add track name to tempo track (visible in DAW)
        addTrackName(track: tempo, name: "Markers & Chords")
        
        MusicTrackNewExtendedTempoEvent(tempo, 0, bpm)
        
        // Add Key Signature (DAW enhancement)
        addKeySignature(to: tempo, key: key, scale: scale)
        
        // Add Time Signature (DAW enhancement)
        addTimeSignature(to: tempo, numerator: 4, denominator: 4)
        
        // Create tracks
        // Track 1: Chord Track (root notes)
        var chordTrack: MusicTrack?
        guard MusicSequenceNewTrack(seq, &chordTrack) == noErr,
              let track1 = chordTrack else {
            throw MIDIExportError.trackCreationFailed
        }
        
        // Track 2: Bass Line
        var bassTrack: MusicTrack?
        guard MusicSequenceNewTrack(seq, &bassTrack) == noErr,
              let track2 = bassTrack else {
            throw MIDIExportError.trackCreationFailed
        }
        
        // Track 3: Scale Guide (Bass Range - for bass line creation)
        var scaleTrack: MusicTrack?
        guard MusicSequenceNewTrack(seq, &scaleTrack) == noErr,
              let track3 = scaleTrack else {
            throw MIDIExportError.trackCreationFailed
        }
        
        // Track 4: Scale Guide (Middle Range - for guitar/melody)
        var scaleBassTrack: MusicTrack?
        guard MusicSequenceNewTrack(seq, &scaleBassTrack) == noErr,
              let track4 = scaleBassTrack else {
            throw MIDIExportError.trackCreationFailed
        }
        
        // Track 5: Guide Tones (3rd/7th only) - for jazz/pop arranging
        var guideToneTrack: MusicTrack?
        guard MusicSequenceNewTrack(seq, &guideToneTrack) == noErr,
              let track5 = guideToneTrack else {
            throw MIDIExportError.trackCreationFailed
        }
        
        // Add track names
        addTrackName(track: track1, name: "Guitar")
        addTrackName(track: track2, name: "Bass")
        addTrackName(track: track3, name: "Scale Guide (Bass)")  // Track3 now contains bass range data
        addTrackName(track: track4, name: "Scale Guide (Middle)")  // Track4 now contains middle range data
        addTrackName(track: track5, name: "Guide Tones (3rd/7th)")
        
        // Add program changes (instrument selection)
        addProgramChange(track: track1, program: 25, channel: 0) // Acoustic Steel Guitar
        addProgramChange(track: track2, program: 33, channel: 1) // Electric Bass (finger)
        
        // Add chord symbols to tempo track (as markers for DAW visibility)
        addChordSymbols(to: tempo, chords: chords, key: key, scale: scale)
        
        // Add section markers to tempo track
        addSectionMarkers(to: tempo, sectionDefinitions: sectionDefinitions, playbackOrder: playbackOrder, barDuration: 4.0)
        
        // Generate chord events (now includes full voicing + rhythm)
        try addChordEvents(to: track1, chords: chords, key: key)
        
        // Generate bass line events (now includes rhythm pattern)
        try addBassLineEvents(to: track2, chords: chords, key: key)
        
        // Generate scale guide (ghost notes) if scale is provided
        if let scale = scale {
            print("🎵 Generating Scale Guide for: \(scale)")
            // Bass range (2 octaves lower, matching bass track C2-C3, 1 octave) - Channel 2
            try addScaleGuide(to: track3, chords: chords, key: key, scale: scale, octaveOffset: -24, channel: 2, use2Octaves: false)
            // Middle range (1 octave lower, for guitar C3-C5, 2 octaves) - Channel 3
            try addScaleGuide(to: track4, chords: chords, key: key, scale: scale, octaveOffset: -12, channel: 3, use2Octaves: true)
            print("✅ Scale Guide tracks added (Bass: C2-C3 [1oct], Middle: C3-C5 [2oct])")
        } else {
            print("⚠️ No scale provided, skipping Scale Guide tracks")
        }
        
        // Generate guide tones (3rd/7th only) - Essential for jazz/pop arranging
        try addGuideTones(to: track5, chords: chords, key: key, channel: 4)
        print("✅ Guide Tones track added (3rd/7th)")
        
        // Export to data
        var data: Unmanaged<CFData>?
        guard MusicSequenceFileCreateData(seq, .midiType, .eraseFile, 0, &data) == noErr,
              let cfData = data?.takeRetainedValue() else {
            throw MIDIExportError.exportFailed
        }
        
        // Clean up
        DisposeMusicSequence(seq)
        
        return cfData as Data
    }
    
    // MARK: - Program Change
    
    /// Add Program Change event (instrument selection)
    private func addProgramChange(track: MusicTrack, program: UInt8, channel: UInt8) {
        var message = MIDIChannelMessage(
            status: 0xC0 | channel, // Program Change
            data1: program,
            data2: 0,
            reserved: 0
        )
        MusicTrackNewMIDIChannelEvent(track, 0, &message)
    }
    
    // MARK: - Track Names
    
    private func addTrackName(track: MusicTrack, name: String) {
        let nameData = name.data(using: .utf8) ?? Data()
        var metaEvent = MIDIMetaEvent()
        metaEvent.metaEventType = 3 // Track Name
        metaEvent.dataLength = UInt32(nameData.count)
        
        nameData.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            if let baseAddress = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) {
                withUnsafeMutablePointer(to: &metaEvent.data) { dataPtr in
                    dataPtr.withMemoryRebound(to: UInt8.self, capacity: nameData.count) { bytePtr in
                        bytePtr.update(from: baseAddress, count: nameData.count)
                    }
                }
            }
        }
        
        MusicTrackNewMetaEvent(track, 0, &metaEvent)
    }
    
    // MARK: - Section Markers
    
    private func addSectionMarkers(to track: MusicTrack, sectionDefinitions: [SectionDefinition], playbackOrder: PlaybackOrder, barDuration: MusicTimeStamp) {
        guard !sectionDefinitions.isEmpty && !playbackOrder.items.isEmpty else { return }
        
        var currentBarIndex = 0
        
        for playbackItem in playbackOrder.items {
            guard let section = sectionDefinitions.first(where: { $0.id == playbackItem.sectionId }) else {
                continue
            }
            
            // Add marker at the start of this section occurrence (only once, not per repeat)
            let timestamp = MusicTimeStamp(currentBarIndex) * barDuration
            let markerText = section.name
            let markerData = markerText.data(using: .utf8) ?? Data()
            
            var metaEvent = MIDIMetaEvent()
            metaEvent.metaEventType = 6 // Marker
            metaEvent.dataLength = UInt32(markerData.count)
            
            markerData.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                if let baseAddress = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) {
                    withUnsafeMutablePointer(to: &metaEvent.data) { dataPtr in
                        dataPtr.withMemoryRebound(to: UInt8.self, capacity: markerData.count) { bytePtr in
                            bytePtr.update(from: baseAddress, count: markerData.count)
                        }
                    }
                }
            }
            
            MusicTrackNewMetaEvent(track, timestamp, &metaEvent)
            
            // Advance bar index by the number of NON-EMPTY chords (not total slots)
            let filledCount = section.chords.compactMap { $0 }.count
            currentBarIndex += filledCount * playbackItem.repeatCount
            
            print("  📍 Section marker: '\(section.name)' at bar \(currentBarIndex - filledCount * playbackItem.repeatCount), length: \(filledCount) chords × \(playbackItem.repeatCount)x = \(filledCount * playbackItem.repeatCount) bars")
        }
    }
    
    // MARK: - Chord Events (Full Voicing + Rhythm)
    
    private func addChordEvents(to track: MusicTrack, chords: [String], key: String) throws {
        let barDuration: MusicTimeStamp = 4.0 // 1 bar = 4 quarter notes (4/4 time signature)
        
        var previousVoicing: [UInt8]? = nil
        
        for (index, chord) in chords.enumerated() {
            guard !chord.isEmpty else { continue }
            
            let barStart = MusicTimeStamp(index) * barDuration
            
            // ✨ Voice Leading: Use close voicing that minimizes movement from previous chord
            let voicing: [UInt8]
            if let prev = previousVoicing {
                voicing = findClosestVoicing(for: chord, key: key, from: prev)
            } else {
                // First chord: use standard voicing
                voicing = parseChordVoicing(chord, key: key)
            }
            
            previousVoicing = voicing
            
            // ✨ DAW Enhancement: Output as whole notes (block chords)
            // Makes editing in DAW much easier - users can see full chord duration
            let duration = barDuration * 0.95 // Whole note (slightly shorter to avoid overlap)
            
            // Add all notes in the voicing simultaneously
            for (noteIndex, midiNote) in voicing.enumerated() {
                var note = MIDINoteMessage(
                    channel: 0,
                    note: midiNote,
                    velocity: UInt8(70 + noteIndex * 2), // Slight velocity variation for realism
                    releaseVelocity: 0,
                    duration: Float32(duration)
                )
                
                MusicTrackNewMIDINoteEvent(track, barStart, &note)
            }
        }
    }
    
    // MARK: - Guide Tones (3rd/7th only)
    
    /// Add guide tones (3rd and 7th of each chord) - Essential for jazz/pop arranging
    /// - Parameters:
    ///   - track: MIDI track
    ///   - chords: Array of chord symbols
    ///   - key: Key name
    ///   - channel: MIDI channel
    private func addGuideTones(to track: MusicTrack, chords: [String], key: String, channel: UInt8) throws {
        let barDuration: MusicTimeStamp = 4.0
        
        for (index, chord) in chords.enumerated() {
            guard !chord.isEmpty else { continue }
            
            let barStart = MusicTimeStamp(index) * barDuration
            let duration = barDuration * 0.5  // Shorter duration for guide tones (to avoid overlap with guitar)
            
            // Extract 3rd and 7th from chord
            let guideTones = extractGuideTones(chord, key: key)
            
            // Add guide tones as simultaneous shell voicing (2-note chord)
            // Lower velocity and shorter duration to avoid interfering with main guitar track
            for midiNote in guideTones {
                var note = MIDINoteMessage(
                    channel: channel,
                    note: midiNote,
                    velocity: 25,  // Low velocity for guide tones (reduced from 30 for less prominence)
                    releaseVelocity: 0,
                    duration: Float32(duration)
                )
                
                // All guide tones play simultaneously at the start of the bar
                // This creates a "shell voicing" that highlights the chord quality (major/minor, 7th)
                MusicTrackNewMIDINoteEvent(track, barStart, &note)
            }
        }
    }
    
    /// Extract 3rd and 7th from a chord (the most important voice leading notes)
    /// - Parameters:
    ///   - chord: Chord symbol
    ///   - key: Key name
    /// - Returns: Array of MIDI note numbers for 3rd and 7th
    private func extractGuideTones(_ chord: String, key: String) -> [UInt8] {
        let parsed = parseChordSymbol(chord)
        let root = parseNoteToMIDI(parsed.mainRoot, octave: 4)  // C4 = 60
        let chordLower = chord.lowercased()
        
        var guideTones: [UInt8] = []
        
        // Determine 3rd
        if chordLower.contains("m") || chordLower.contains("min") {
            // Minor 3rd
            guideTones.append(root + 3)
        } else {
            // Major 3rd (default)
            guideTones.append(root + 4)
        }
        
        // Determine 7th (if applicable)
        if chordLower.contains("maj7") || chordLower.contains("major7") {
            // Major 7th
            guideTones.append(root + 11)
        } else if chordLower.contains("7") {
            // Minor/Dominant 7th
            guideTones.append(root + 10)
        }
        // If no 7th, only return 3rd
        
        return guideTones
    }
    
    // MARK: - Bass Line Events (Rhythm Pattern)
    
    private func addBassLineEvents(to track: MusicTrack, chords: [String], key: String) throws {
        let barDuration: MusicTimeStamp = 4.0
        let quarterNote: MusicTimeStamp = 1.0
        
        for (index, chord) in chords.enumerated() {
            guard !chord.isEmpty else { continue }
            
            let barStart = MusicTimeStamp(index) * barDuration
            let parsed = parseChordSymbol(chord)
            
            // Determine bass note: onBass ?? mainRoot
            let bassNote = parsed.onBass ?? parsed.mainRoot
            let bassLow = parseNoteToMIDI(bassNote, octave: 2)  // C2 = 36
            
            // Get main root for 5th calculation
            let mainRoot = parseNoteToMIDI(parsed.mainRoot, octave: 2)
            let mainFifth = mainRoot + 7  // Perfect 5th of main root
            
            // Three-tier safety system for bass pattern
            let bassPattern: [(note: UInt8, beat: Int)]
            
            if let onBass = parsed.onBass {
                // Slash chord: check if on-bass is within chord tones
                if isBassInChordTones(onBass, mainRoot: parsed.mainRoot, quality: parsed.quality) {
                    // Tier 1: On-bass ↔ Main root's 5th (C/E → E ↔ G)
                    bassPattern = [
                        (bassLow, 0),      // Beat 1: On-bass
                        (mainFifth, 1),    // Beat 2: Main root's 5th
                        (bassLow, 2),      // Beat 3: On-bass
                        (mainFifth, 3)     // Beat 4: Main root's 5th
                    ]
                } else {
                    // Tier 2: Non-chord tone → On-bass 4-beat pattern
                    bassPattern = [
                        (bassLow, 0),      // Beat 1: On-bass
                        (bassLow, 1),      // Beat 2: On-bass
                        (bassLow, 2),      // Beat 3: On-bass
                        (bassLow, 3)       // Beat 4: On-bass
                    ]
                }
            } else {
                // Regular chord: Root ↔ 5th pattern
                bassPattern = [
                    (bassLow, 0),      // Beat 1: Root
                    (mainFifth, 1),    // Beat 2: 5th
                    (bassLow, 2),      // Beat 3: Root
                    (mainFifth, 3)     // Beat 4: 5th
                ]
            }
            
            for (note, beat) in bassPattern {
                let timestamp = barStart + (MusicTimeStamp(beat) * quarterNote)
                let duration = quarterNote * 0.8 // Slightly shorter for punch
                
                var midiNote = MIDINoteMessage(
                    channel: 1, // Bass on channel 1
                    note: note,
                    velocity: 90, // Strong bass presence
                    releaseVelocity: 0,
                    duration: Float32(duration)
                )
                
                MusicTrackNewMIDINoteEvent(track, timestamp, &midiNote)
            }
        }
    }
    
    // MARK: - Scale Guide (Ghost Notes)
    
    /// Add scale guide track (ghost notes showing available scale tones)
    /// - Parameters:
    ///   - track: MusicTrack to add notes to
    ///   - chords: Array of chord symbols
    ///   - key: Key signature
    ///   - scale: Scale name
    ///   - octaveOffset: Semitone offset (e.g., -24 for bass range, -12 for middle range)
    ///   - channel: MIDI channel (default 2)
    ///   - use2Octaves: If true, generates 2-octave pattern (for middle range)
    private func addScaleGuide(to track: MusicTrack, chords: [String], key: String, scale: String, octaveOffset: Int = 0, channel: UInt8 = 2, use2Octaves: Bool = false) throws {
        let barDuration: MusicTimeStamp = 4.0
        let noteInterval: MusicTimeStamp = 0.25 // 125ms between notes
        let noteDuration: MusicTimeStamp = 0.5 // 16th note equivalent (120 ticks at 480 PPQ)
        
        // Get scale degrees from scale name
        let scaleDegrees = getScaleDegrees(scaleName: scale)
        guard !scaleDegrees.isEmpty else {
            print("⚠️ Unknown scale: '\(scale)', skipping scale guide")
            print("   Available scales: Major Scale, Dorian, Minor Pentatonic, etc.")
            return
        }
        
        print("  ✓ Scale degrees: \(scaleDegrees)")
        print("  ✓ Octave offset: \(octaveOffset)")
        print("  ✓ Channel: \(channel)")
        print("  ✓ 2-Octave mode: \(use2Octaves)")
        
        // Get root note MIDI number with octave offset
        let rootMIDI = parseChordRoot(key, key: key)
        let adjustedRoot = Int(rootMIDI) + octaveOffset
        
        for (index, _) in chords.enumerated() {
            let barStart = MusicTimeStamp(index) * barDuration
            
            // Convert scale degrees to MIDI notes (first octave)
            let scaleNotesOctave1 = scaleDegrees.map { degree -> UInt8 in
                let semitones = degreeToSemitones(degree)
                return UInt8(adjustedRoot + semitones)
            }
            
            // If 2-octave mode, add second octave
            var allAscendingNotes = scaleNotesOctave1
            if use2Octaves {
                let scaleNotesOctave2 = scaleDegrees.map { degree -> UInt8 in
                    let semitones = degreeToSemitones(degree)
                    return UInt8(adjustedRoot + semitones + 12) // +1 octave
                }
                allAscendingNotes += scaleNotesOctave2
            }
            
            if index == 0 {
                print("  ✓ Bar \(index): Adding \(allAscendingNotes.count) notes (MIDI: \(allAscendingNotes))")
            }
            
            // Ascending pattern (1 or 2 octaves depending on mode)
            for (noteIndex, midiNote) in allAscendingNotes.enumerated() {
                let timestamp = barStart + (MusicTimeStamp(noteIndex) * noteInterval)
                var note = MIDINoteMessage(
                    channel: channel,
                    note: midiNote,
                    velocity: 20, // Ghost note (very quiet)
                    releaseVelocity: 0,
                    duration: Float32(noteDuration) // 16th note equivalent for better visibility in DAW
                )
                MusicTrackNewMIDINoteEvent(track, timestamp, &note)
            }
            
            // Descending pattern (optional, if time allows in the bar)
            let descendingStart = barStart + (MusicTimeStamp(allAscendingNotes.count) * noteInterval)
            if descendingStart < barStart + barDuration {
                for (noteIndex, midiNote) in allAscendingNotes.reversed().enumerated() {
                    let timestamp = descendingStart + (MusicTimeStamp(noteIndex) * noteInterval)
                    if timestamp >= barStart + barDuration { break }
                    
                    var note = MIDINoteMessage(
                        channel: channel,
                        note: midiNote,
                        velocity: 20, // Same velocity for descending
                        releaseVelocity: 0,
                        duration: Float32(noteDuration) // 16th note equivalent
                    )
                    MusicTrackNewMIDINoteEvent(track, timestamp, &note)
                }
            }
        }
    }
    
    /// Get scale degrees from scale name
    private func getScaleDegrees(scaleName: String) -> [String] {
        // Remove key name prefix (e.g., "C Major Scale" → "Major Scale")
        let cleanedName = removeKeyPrefix(from: scaleName)
        
        // Map common scale names to degrees (based on SCALE_CATALOG)
        let scaleMap: [String: [String]] = [
            // Diatonic
            "Major Scale": ["1", "2", "3", "4", "5", "6", "7"],
            "Ionian": ["1", "2", "3", "4", "5", "6", "7"],
            "Dorian Scale": ["1", "2", "b3", "4", "5", "6", "b7"],
            "Dorian": ["1", "2", "b3", "4", "5", "6", "b7"],
            "Phrygian Scale": ["1", "b2", "b3", "4", "5", "b6", "b7"],
            "Phrygian": ["1", "b2", "b3", "4", "5", "b6", "b7"],
            "Lydian Scale": ["1", "2", "3", "#4", "5", "6", "7"],
            "Lydian": ["1", "2", "3", "#4", "5", "6", "7"],
            "Mixolydian Scale": ["1", "2", "3", "4", "5", "6", "b7"],
            "Mixolydian": ["1", "2", "3", "4", "5", "6", "b7"],
            "Natural Minor Scale": ["1", "2", "b3", "4", "5", "b6", "b7"],
            "Aeolian": ["1", "2", "b3", "4", "5", "b6", "b7"],
            "Locrian Scale": ["1", "b2", "b3", "4", "b5", "b6", "b7"],
            "Locrian": ["1", "b2", "b3", "4", "b5", "b6", "b7"],
            
            // Pentatonic
            "Major Pentatonic": ["1", "2", "3", "5", "6"],
            "MajorPentatonic": ["1", "2", "3", "5", "6"],
            "Minor Pentatonic": ["1", "b3", "4", "5", "b7"],
            "MinorPentatonic": ["1", "b3", "4", "5", "b7"],
            "Blues Scale (minor)": ["1", "b3", "4", "b5", "5", "b7"],
            "Blues": ["1", "b3", "4", "b5", "5", "b7"],
            
            // Minor variations
            "Harmonic Minor": ["1", "2", "b3", "4", "5", "b6", "7"],
            "HarmonicMinor": ["1", "2", "b3", "4", "5", "b6", "7"],
            "Melodic Minor Scale": ["1", "2", "b3", "4", "5", "6", "7"],
            "MelodicMinor": ["1", "2", "b3", "4", "5", "6", "7"]
        ]
        
        if let degrees = scaleMap[cleanedName] {
            print("  ✓ Matched scale: '\(cleanedName)'")
            return degrees
        }
        
        // If still not found, return empty
        print("  ✗ No match for: '\(cleanedName)' (original: '\(scaleName)')")
        return []
    }
    
    /// Remove key name prefix from scale name
    /// Examples: "C Major Scale" → "Major Scale", "A Minor Pentatonic" → "Minor Pentatonic"
    private func removeKeyPrefix(from scaleName: String) -> String {
        // List of key names (including sharps and flats)
        let keyNames = ["C", "C#", "Db", "D", "D#", "Eb", "E", "F", "F#", "Gb", "G", "G#", "Ab", "A", "A#", "Bb", "B"]
        
        for keyName in keyNames {
            // Check if scale name starts with key name + space
            if scaleName.hasPrefix(keyName + " ") {
                // Remove key name and return the rest
                let startIndex = scaleName.index(scaleName.startIndex, offsetBy: keyName.count + 1)
                return String(scaleName[startIndex...])
            }
        }
        
        // If no key name found, return as is
        return scaleName
    }
    
    /// Convert degree string to semitones from root
    private func degreeToSemitones(_ degree: String) -> Int {
        switch degree {
        case "1": return 0
        case "b2": return 1
        case "2": return 2
        case "b3": return 3
        case "3": return 4
        case "4": return 5
        case "#4", "b5": return 6
        case "5": return 7
        case "#5", "b6": return 8
        case "6": return 9
        case "bb7": return 9
        case "b7": return 10
        case "7": return 11
        default: return 0
        }
    }
    
    // MARK: - Chord Symbols (Markers for DAW Timeline)
    
    /// Add chord symbol markers (visible in DAW timeline)
    private func addChordSymbols(to track: MusicTrack, chords: [String], key: String, scale: String?) {
        let barDuration: MusicTimeStamp = 4.0
        
        for (index, chord) in chords.enumerated() {
            guard !chord.isEmpty else { continue }
            
            // Convert chord to enharmonic spelling based on key signature
            let normalizedChord = normalizeChordSpelling(chord, key: key, scale: scale)
            
            let timestamp = MusicTimeStamp(index) * barDuration
            let chordData = normalizedChord.data(using: .utf8) ?? Data()
            
            var metaEvent = MIDIMetaEvent()
            metaEvent.metaEventType = 6 // Marker (displayed in DAW timeline)
            metaEvent.dataLength = UInt32(chordData.count)
            
            chordData.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                if let baseAddress = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) {
                    withUnsafeMutablePointer(to: &metaEvent.data) { dataPtr in
                        dataPtr.withMemoryRebound(to: UInt8.self, capacity: chordData.count) { bytePtr in
                            bytePtr.update(from: baseAddress, count: chordData.count)
                        }
                    }
                }
            }
            
            MusicTrackNewMetaEvent(track, timestamp, &metaEvent)
        }
    }
    
    /// Normalize chord spelling to match key signature (e.g., A# → Bb in F major)
    /// - Parameters:
    ///   - chord: Original chord symbol (e.g., "A#m7")
    ///   - key: Key name (e.g., "F")
    ///   - scale: Scale name (optional)
    /// - Returns: Normalized chord symbol (e.g., "Bbm7")
    private func normalizeChordSpelling(_ chord: String, key: String, scale: String?) -> String {
        // Extract root note from chord (handle slash chords)
        var root = ""
        var suffix = ""
        var bassNote = ""
        
        if chord.contains("/") {
            let parts = chord.split(separator: "/", maxSplits: 1)
            let mainChord = String(parts[0])
            bassNote = parts.count > 1 ? String(parts[1]) : ""
            
            // Extract root from main chord
            if mainChord.count >= 2 && (mainChord.dropFirst().prefix(1) == "#" || mainChord.dropFirst().prefix(1) == "b") {
                root = String(mainChord.prefix(2))
                suffix = String(mainChord.dropFirst(2))
            } else {
                root = String(mainChord.prefix(1))
                suffix = String(mainChord.dropFirst())
            }
        } else {
            // No slash chord
            if chord.count >= 2 && (chord.dropFirst().prefix(1) == "#" || chord.dropFirst().prefix(1) == "b") {
                root = String(chord.prefix(2))
                suffix = String(chord.dropFirst(2))
            } else {
                root = String(chord.prefix(1))
                suffix = String(chord.dropFirst())
            }
        }
        
        // Determine if key prefers sharps or flats
        let keyComponents = key.split(separator: " ")
        let tonic = String(keyComponents.first ?? "C")
        
        let sharpKeys = ["G", "D", "A", "E", "B", "F#", "C#", "E Minor", "B Minor", "F# Minor", "C# Minor", "G# Minor", "D# Minor", "A# Minor"]
        let flatKeys = ["F", "Bb", "Eb", "Ab", "Db", "Gb", "Cb", "D Minor", "G Minor", "C Minor", "F Minor", "Bb Minor", "Eb Minor", "Ab Minor"]
        
        let prefersFlats = flatKeys.contains(key) || flatKeys.contains(tonic)
        let prefersSharps = sharpKeys.contains(key) || sharpKeys.contains(tonic)
        
        // Check scale for additional context
        if let scale = scale {
            let scaleLower = scale.lowercased()
            // Flat-based modes
            if scaleLower.contains("phrygian") || scaleLower.contains("locrian") {
                // These modes often use flats
            }
        }
        
        // Enharmonic conversion map
        let sharpToFlat: [String: String] = [
            "C#": "Db", "D#": "Eb", "F#": "Gb", "G#": "Ab", "A#": "Bb"
        ]
        let flatToSharp: [String: String] = [
            "Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"
        ]
        
        // Normalize root
        var normalizedRoot = root
        if prefersFlats && sharpToFlat.keys.contains(root) {
            normalizedRoot = sharpToFlat[root] ?? root
        } else if prefersSharps && flatToSharp.keys.contains(root) {
            normalizedRoot = flatToSharp[root] ?? root
        }
        
        // Normalize bass note if present
        var normalizedBass = bassNote
        if !bassNote.isEmpty {
            if prefersFlats && sharpToFlat.keys.contains(bassNote) {
                normalizedBass = sharpToFlat[bassNote] ?? bassNote
            } else if prefersSharps && flatToSharp.keys.contains(bassNote) {
                normalizedBass = flatToSharp[bassNote] ?? bassNote
            }
        }
        
        // Reconstruct chord
        if !normalizedBass.isEmpty {
            return "\(normalizedRoot)\(suffix)/\(normalizedBass)"
        } else {
            return "\(normalizedRoot)\(suffix)"
        }
    }
    
    // MARK: - Key & Time Signature (DAW Enhancement)
    
    /// Add Key Signature meta event to tempo track
    /// - Parameters:
    ///   - track: Tempo track
    ///   - key: Key name (e.g., "C", "A Minor", "D Major")
    ///   - scale: Scale name (e.g., "A Lydian", "C Major Scale", "Minor Pentatonic")
    private func addKeySignature(to track: MusicTrack, key: String, scale: String?) {
        // Extract tonic from key (handle "A Minor", "C Major" format)
        let components = key.split(separator: " ")
        let tonic = String(components.first ?? "C")
        let keyMode = components.count > 1 ? String(components[1]) : ""
        
        // Map key to sharps/flats count (Major keys)
        // Positive = sharps, Negative = flats
        let majorKeySignatureMap: [String: Int8] = [
            "C": 0, "G": 1, "D": 2, "A": 3, "E": 4, "B": 5, "F#": 6, "C#": 7,
            "F": -1, "Bb": -2, "Eb": -3, "Ab": -4, "Db": -5, "Gb": -6, "Cb": -7
        ]
        
        // For minor keys, use relative major's key signature
        let minorToMajorMap: [String: String] = [
            "A": "C", "E": "G", "B": "D", "F#": "A", "C#": "E", "G#": "B", "D#": "F#",
            "D": "F", "G": "Bb", "C": "Eb", "F": "Ab", "Bb": "Db", "Eb": "Gb"
        ]
        
        // Determine major/minor mode
        var mi: UInt8 = 0  // Default to Major
        var effectiveTonic = tonic
        
        // Priority 1: Check scale name (more specific than key)
        if let scale = scale {
            let scaleLower = scale.lowercased()
            
            // Major-type modes: Use Major key signature
            if scaleLower.contains("ionian") || scaleLower.contains("major scale") ||
               scaleLower.contains("lydian") || scaleLower.contains("mixolydian") ||
               scaleLower.contains("major pentatonic") {
                mi = 0  // Major
                effectiveTonic = tonic  // Use tonic directly for Major
            }
            // Minor-type modes: Use Minor key signature (relative major)
            else if scaleLower.contains("aeolian") || scaleLower.contains("natural minor") ||
                    scaleLower.contains("dorian") || scaleLower.contains("phrygian") ||
                    scaleLower.contains("harmonic minor") || scaleLower.contains("melodic minor") ||
                    scaleLower.contains("locrian") || scaleLower.contains("minor pentatonic") {
                mi = 1  // Minor
                effectiveTonic = minorToMajorMap[tonic] ?? tonic
            }
            // Default: use key mode if scale doesn't give clear indication
            else if keyMode.lowercased() == "minor" {
                mi = 1
                effectiveTonic = minorToMajorMap[tonic] ?? tonic
            }
        }
        // Priority 2: If no scale, use key mode
        else if keyMode.lowercased() == "minor" {
            mi = 1
            effectiveTonic = minorToMajorMap[tonic] ?? tonic
        }
        
        let sf = majorKeySignatureMap[effectiveTonic] ?? 0  // Sharps/flats count
        
        // MIDI Key Signature meta event: FF 59 02 sf mi
        var metaEvent = MIDIMetaEvent()
        metaEvent.metaEventType = 0x59  // Key Signature
        metaEvent.dataLength = 2
        
        // Set data bytes
        withUnsafeMutablePointer(to: &metaEvent.data) { dataPtr in
            dataPtr.withMemoryRebound(to: UInt8.self, capacity: 2) { bytePtr in
                bytePtr[0] = UInt8(bitPattern: sf)  // Sharps/flats
                bytePtr[1] = mi  // Major/Minor
            }
        }
        
        MusicTrackNewMetaEvent(track, 0, &metaEvent)
        
        print("🎵 Key Signature added: \(tonic) (\(mi == 0 ? "Major" : "Minor")), sf=\(sf) [Original key: \(key), Scale: \(scale ?? "nil")]")
    }
    
    /// Add Time Signature meta event to tempo track
    /// - Parameters:
    ///   - track: Tempo track
    ///   - numerator: Time signature numerator (e.g., 4 for 4/4)
    ///   - denominator: Time signature denominator (e.g., 4 for 4/4)
    private func addTimeSignature(to track: MusicTrack, numerator: UInt8, denominator: UInt8) {
        // MIDI Time Signature meta event: FF 58 04 nn dd cc bb
        // nn = numerator
        // dd = denominator as power of 2 (2 = quarter note, 3 = eighth note)
        // cc = MIDI clocks per metronome click (typically 24)
        // bb = Number of 32nd notes per quarter note (typically 8)
        
        let dd: UInt8
        switch denominator {
        case 2: dd = 1   // Half note
        case 4: dd = 2   // Quarter note
        case 8: dd = 3   // Eighth note
        case 16: dd = 4  // Sixteenth note
        default: dd = 2  // Default to quarter note
        }
        
        var metaEvent = MIDIMetaEvent()
        metaEvent.metaEventType = 0x58  // Time Signature
        metaEvent.dataLength = 4
        
        // Set data bytes
        withUnsafeMutablePointer(to: &metaEvent.data) { dataPtr in
            dataPtr.withMemoryRebound(to: UInt8.self, capacity: 4) { bytePtr in
                bytePtr[0] = numerator
                bytePtr[1] = dd
                bytePtr[2] = 24  // MIDI clocks per metronome click
                bytePtr[3] = 8   // 32nd notes per quarter note
            }
        }
        
        MusicTrackNewMetaEvent(track, 0, &metaEvent)
        
        print("🎵 Time Signature added: \(numerator)/\(denominator)")
    }
    
    // MARK: - Voice Leading (Close Voicing)
    
    /// Find the closest voicing for a chord that minimizes movement from previous voicing
    /// - Parameters:
    ///   - chord: Chord symbol (e.g., "C", "Am7", "Fmaj7")
    ///   - key: Key name
    ///   - previousVoicing: Previous chord's voicing (MIDI note numbers)
    /// - Returns: Optimal voicing with minimal voice movement
    private func findClosestVoicing(for chord: String, key: String, from previousVoicing: [UInt8]) -> [UInt8] {
        // Get base voicing for the chord
        let baseVoicing = parseChordVoicing(chord, key: key)
        
        // Generate possible voicings (base + inversions + octave shifts)
        var possibleVoicings: [[UInt8]] = []
        
        // Add base voicing
        possibleVoicings.append(baseVoicing)
        
        // Add inversions (rotate the voicing)
        for inversion in 1..<baseVoicing.count {
            var inverted = baseVoicing
            for i in 0..<inversion {
                inverted[i] += 12  // Move to next octave
            }
            inverted.sort()  // Re-sort after inversion
            possibleVoicings.append(inverted)
        }
        
        // Add octave shifts (-12, +12 semitones)
        let octaveDown = baseVoicing.map { $0 - 12 }
        let octaveUp = baseVoicing.map { $0 + 12 }
        possibleVoicings.append(octaveDown)
        possibleVoicings.append(octaveUp)
        
        // Find voicing with minimal total movement
        var bestVoicing = baseVoicing
        var minDistance = Int.max
        
        for voicing in possibleVoicings {
            let distance = calculateVoiceDistance(from: previousVoicing, to: voicing)
            if distance < minDistance {
                minDistance = distance
                bestVoicing = voicing
            }
        }
        
        print("🎵 Voice Leading: \(chord) - Distance: \(minDistance) semitones")
        return bestVoicing
    }
    
    /// Calculate total voice movement distance between two voicings
    /// - Parameters:
    ///   - from: Previous voicing
    ///   - to: Next voicing
    /// - Returns: Total semitone distance
    private func calculateVoiceDistance(from: [UInt8], to: [UInt8]) -> Int {
        // Ensure both voicings have same number of notes
        guard from.count == to.count else {
            return Int.max  // Penalize mismatched voicings
        }
        
        var totalDistance = 0
        
        // For each voice, find closest matching note in next chord
        for fromNote in from {
            // Find the note in 'to' that is closest to 'fromNote'
            var minVoiceDistance = Int.max
            for toNote in to {
                let distance = abs(Int(toNote) - Int(fromNote))
                if distance < minVoiceDistance {
                    minVoiceDistance = distance
                }
            }
            totalDistance += minVoiceDistance
        }
        
        return totalDistance
    }
    
    // MARK: - Unified Chord Parsing
    
    /// Parse chord symbol into structured components
    private func parseChordSymbol(_ symbol: String) -> ParsedChord {
        if symbol.contains("/") {
            let parts = symbol.split(separator: "/")
            let mainChord = String(parts[0])
            let onBass = parts.count > 1 ? String(parts[1]).trimmingCharacters(in: .whitespaces) : nil
            
            // Extract root and quality from main chord
            let rootMatch = mainChord.range(of: "^[A-G][#b]?", options: .regularExpression)
            let root = rootMatch.map { String(mainChord[$0]) } ?? "C"
            let quality = rootMatch.map { String(mainChord[$0.upperBound...]) } ?? ""
            
            return ParsedChord(mainRoot: root, quality: quality, onBass: onBass)
        } else {
            // Regular chord
            let rootMatch = symbol.range(of: "^[A-G][#b]?", options: .regularExpression)
            let root = rootMatch.map { String(symbol[$0]) } ?? "C"
            let quality = rootMatch.map { String(symbol[$0.upperBound...]) } ?? ""
            
            return ParsedChord(mainRoot: root, quality: quality, onBass: nil)
        }
    }
    
    /// Parse note name to MIDI number with octave specification
    private func parseNoteToMIDI(_ noteName: String, octave: Int = 4) -> UInt8 {
        let rootMap: [String: UInt8] = [
            "C": 60, "C#": 61, "Db": 61,
            "D": 62, "D#": 63, "Eb": 63,
            "E": 64,
            "F": 65, "F#": 66, "Gb": 66,
            "G": 67, "G#": 68, "Ab": 68,
            "A": 69, "A#": 70, "Bb": 70,
            "B": 71
        ]
        
        // Extract note name (1-2 characters)
        var root = String(noteName.prefix(1))
        if noteName.count > 1 {
            let second = String(noteName[noteName.index(noteName.startIndex, offsetBy: 1)])
            if second == "#" || second == "b" {
                root += second
            }
        }
        
        let baseNote = rootMap[root] ?? 60  // Default to C4
        return UInt8(Int(baseNote) + (octave - 4) * 12)
    }
    
    /// Apply octave clamping for guitar bass notes to avoid collision with real bass
    private func clampGuitarBass(_ guitarBass: UInt8, realBass: UInt8) -> UInt8 {
        // If guitar bass is too close to real bass (< 7 semitones), move up one octave
        if guitarBass - realBass < 7 {
            return guitarBass + 12
        }
        return guitarBass
    }
    
    /// Check if bass note is within chord tones
    private func isBassInChordTones(_ bass: String, mainRoot: String, quality: String) -> Bool {
        let bassPc = parseNoteToMIDI(bass, octave: 0) % 12
        let rootPc = parseNoteToMIDI(mainRoot, octave: 0) % 12
        
        // Get chord intervals
        var intervals: [Int] = [0]  // Root
        let qualityLower = quality.lowercased()
        
        if qualityLower.contains("maj7") || qualityLower.contains("major7") {
            intervals = [0, 4, 7, 11]  // Root, 3rd, 5th, 7th
        } else if qualityLower.contains("m7") || qualityLower.contains("min7") {
            intervals = [0, 3, 7, 10]
        } else if qualityLower.contains("7") {
            intervals = [0, 4, 7, 10]
        } else if qualityLower.contains("dim") {
            intervals = [0, 3, 6]
        } else if qualityLower.contains("aug") {
            intervals = [0, 4, 8]
        } else if qualityLower.contains("m") || qualityLower.contains("min") {
            intervals = [0, 3, 7]
        } else {
            intervals = [0, 4, 7]  // Major triad
        }
        
        // Check if bass pitch class matches any chord tone
        return intervals.contains { (Int(rootPc) + $0) % 12 == Int(bassPc) }
    }
    
    // MARK: - Chord Parsing
    
    /// Parse chord full voicing (root + 3rd + 5th + 7th if applicable)
    /// Voice Leading: Upper voices only, on-bass is fixed
    private func parseChordVoicing(_ chord: String, key: String) -> [UInt8] {
        let parsed = parseChordSymbol(chord)
        let root = parseNoteToMIDI(parsed.mainRoot, octave: 4)  // C4 = 60
        let qualityLower = parsed.quality.lowercased()
        
        var voicing: [UInt8] = []
        
        // Add on-bass as lowest note if present and different from root
        if let onBass = parsed.onBass {
            let bassNote = parseNoteToMIDI(onBass, octave: 3)  // C3 = 48
            if bassNote != root {
                voicing.append(bassNote)
            }
        }
        
        // Add root
        voicing.append(root)
        
        // Determine chord quality and build voicing (upper voices only)
        if qualityLower.contains("maj7") || qualityLower.contains("major7") {
            // Major 7th: Root + 3rd + 5th + 7th
            voicing.append(root + 4)  // Major 3rd
            voicing.append(root + 7)  // Perfect 5th
            voicing.append(root + 11) // Major 7th
        } else if qualityLower.contains("m7") || qualityLower.contains("min7") {
            // Minor 7th: Root + 3rd + 5th + 7th
            voicing.append(root + 3)  // Minor 3rd
            voicing.append(root + 7)  // Perfect 5th
            voicing.append(root + 10) // Minor 7th
        } else if qualityLower.contains("7") {
            // Dominant 7th: Root + 3rd + 5th + 7th
            voicing.append(root + 4)  // Major 3rd
            voicing.append(root + 7)  // Perfect 5th
            voicing.append(root + 10) // Minor 7th
        } else if qualityLower.contains("dim") {
            // Diminished: Root + 3rd + 5th
            voicing.append(root + 3)  // Minor 3rd
            voicing.append(root + 6)  // Diminished 5th
        } else if qualityLower.contains("aug") {
            // Augmented: Root + 3rd + 5th
            voicing.append(root + 4)  // Major 3rd
            voicing.append(root + 8)  // Augmented 5th
        } else if qualityLower.contains("m") || qualityLower.contains("min") {
            // Minor triad: Root + 3rd + 5th
            voicing.append(root + 3)  // Minor 3rd
            voicing.append(root + 7)  // Perfect 5th
        } else {
            // Major triad (default): Root + 3rd + 5th
            voicing.append(root + 4)  // Major 3rd
            voicing.append(root + 7)  // Perfect 5th
        }
        
        return voicing
    }
    
    /// Parse chord root note
    private func parseChordRoot(_ chord: String, key: String) -> UInt8 {
        // Simple parsing: extract root note
        // This is a basic implementation - you may want to use RomanConverter for more accuracy
        
        let rootMap: [String: UInt8] = [
            "C": 60, "C#": 61, "Db": 61,
            "D": 62, "D#": 63, "Eb": 63,
            "E": 64,
            "F": 65, "F#": 66, "Gb": 66,
            "G": 67, "G#": 68, "Ab": 68,
            "A": 69, "A#": 70, "Bb": 70,
            "B": 71
        ]
        
        // Extract root (first 1-2 characters)
        var root = String(chord.prefix(1))
        if chord.count > 1 {
            let second = String(chord[chord.index(chord.startIndex, offsetBy: 1)])
            if second == "#" || second == "b" {
                root += second
            }
        }
        
        return rootMap[root] ?? 60 // Default to C
    }
}

// MARK: - Errors

enum MIDIExportError: LocalizedError {
    case sequenceCreationFailed
    case tempoTrackCreationFailed
    case trackCreationFailed
    case exportFailed
    
    var errorDescription: String? {
        switch self {
        case .sequenceCreationFailed:
            return "Failed to create MIDI sequence"
        case .tempoTrackCreationFailed:
            return "Failed to create tempo track"
        case .trackCreationFailed:
            return "Failed to create MIDI track"
        case .exportFailed:
            return "Failed to export MIDI file"
        }
    }
}

