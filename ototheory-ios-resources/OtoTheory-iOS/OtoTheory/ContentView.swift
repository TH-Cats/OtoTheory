import SwiftUI

struct ContentView: View {
    @State private var testResult = "Tap 'Test Bridge' to start..."
    @StateObject private var audioPlayer = AudioPlayer()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "music.note")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("OtoTheory iOS")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(testResult)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(spacing: 12) {
                    Button("Test Bridge") {
                        testBridge()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    
                    Button("Play C") {
                        playTestNote()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    
                    Button("Play Chord") {
                        playTestChord()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    func testBridge() {
        testResult = "Testing..."
        
        guard let bridge = TheoryBridge() else {
            testResult = "❌ Failed to initialize TheoryBridge"
            return
        }
        
        var results: [String] = []
        
        // Test 1: Chord parsing
        if let chord = bridge.parseChord("Cmaj7") {
            results.append("✅ parseChord('Cmaj7')")
            results.append("   Root: \(chord.root)")
            results.append("   Quality: \(chord.quality)")
        } else {
            results.append("❌ Failed to parse chord")
        }
        
        // Test 2: Diatonic chords
        let diatonic = bridge.getDiatonicChords(key: "C", scale: "ionian")
        if !diatonic.isEmpty {
            results.append("✅ getDiatonicChords('C', 'ionian')")
            results.append("   \(diatonic.joined(separator: ", "))")
        } else {
            results.append("❌ Failed to get diatonic chords")
        }
        
        testResult = results.joined(separator: "\n")
    }
    
    func playTestNote() {
        // Play C4 (MIDI 60)
        audioPlayer.playNote(midiNote: 60, duration: 1.0)
        testResult = "🎵 Playing C4..."
    }
    
    func playTestChord() {
        // Play C Major chord (C4, E4, G4)
        let cMajor: [UInt8] = [60, 64, 67]
        audioPlayer.playChord(midiNotes: cMajor, duration: 2.0, strum: true)
        testResult = "🎸 Playing C Major chord..."
    }
}

#Preview {
    ContentView()
}
