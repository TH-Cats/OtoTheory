//
//  ChordLibraryAudioPlayer.swift
//  OtoTheory
//
//  Audio player for Chord Library
//  Supports strum and arpeggio playback
//

import Foundation
import AVFoundation

@MainActor
class ChordLibraryAudioPlayer: ObservableObject {
    static let shared = ChordLibraryAudioPlayer()
    
    private var audioEngine: AVAudioEngine
    private var sampler: AVAudioUnitSampler
    
    private init() {
        audioEngine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        
        audioEngine.attach(sampler)
        audioEngine.connect(sampler, to: audioEngine.mainMixerNode, format: nil)
        
        loadSoundFont()
        startEngine()
    }
    
    private func loadSoundFont() {
        guard let soundFontURL = Bundle.main.url(forResource: "FluidR3_GM", withExtension: "sf2") else {
            print("⚠️ SoundFont not found")
            return
        }
        
        do {
            // Use program 25 (Acoustic Steel Guitar)
            try sampler.loadSoundBankInstrument(
                at: soundFontURL,
                program: 25,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
            print("✅ SoundFont loaded (Acoustic Steel Guitar)")
        } catch {
            print("❌ Failed to load SoundFont: \(error)")
        }
    }
    
    private func startEngine() {
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
                print("✅ Audio engine started")
            } catch {
                print("❌ Failed to start audio engine: \(error)")
            }
        }
    }
    
    /// Play chord with strum (じゃーん)
    func playStrum(shape: ChordShape, root: ChordRoot) {
        let notes = shape.toMIDINotes(rootSemitone: root.semitone)
        playStrumNotes(notes)
    }
    
    /// Play chord with arpeggio
    func playArpeggio(shape: ChordShape, root: ChordRoot) {
        let notes = shape.toMIDINotes(rootSemitone: root.semitone)
        playArpeggioNotes(notes)
    }
    
    private func playStrumNotes(_ notes: [UInt8]) {
        let velocity: UInt8 = 80
        let strumDelay: TimeInterval = 0.015  // 15ms between strings
        
        for (index, note) in notes.enumerated() {
            let delay = Double(index) * strumDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.sampler.startNote(note, withVelocity: velocity, onChannel: 0)
            }
            
            // Stop after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 1.5) { [weak self] in
                self?.sampler.stopNote(note, onChannel: 0)
            }
        }
    }
    
    private func playArpeggioNotes(_ notes: [UInt8]) {
        let velocity: UInt8 = 70
        let noteDuration: TimeInterval = 0.25  // 250ms per note
        let noteGap: TimeInterval = 0.05  // 50ms gap
        
        for (index, note) in notes.enumerated() {
            let startTime = Double(index) * (noteDuration + noteGap)
            
            // Start note
            DispatchQueue.main.asyncAfter(deadline: .now() + startTime) { [weak self] in
                self?.sampler.startNote(note, withVelocity: velocity, onChannel: 0)
            }
            
            // Stop note
            DispatchQueue.main.asyncAfter(deadline: .now() + startTime + noteDuration) { [weak self] in
                self?.sampler.stopNote(note, onChannel: 0)
            }
        }
    }
    
    /// Stop all playing notes
    func stopAll() {
        for note in 0...127 {
            sampler.stopNote(UInt8(note), onChannel: 0)
        }
    }
}

