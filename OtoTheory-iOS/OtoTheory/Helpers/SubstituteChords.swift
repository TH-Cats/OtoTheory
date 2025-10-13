//
//  SubstituteChords.swift
//  OtoTheory
//
//  Suggest substitute chords for a given chord
//

import Foundation

struct SubstituteChord: Identifiable {
    let id = UUID()
    let chord: String
    let reason: String
    let examples: [String]?
}

struct ChordContext {
    let rootPc: Int  // 0=C, 1=C#, ..., 11=B
    let quality: ChordQuality
    let degree: Int  // 1=I, 2=II, ..., 7=VII (1-indexed)
    let keyTonic: Int  // 0=C, 1=C#, ..., 11=B
    let keyMode: KeyMode  // Major or Minor
}

enum KeyMode {
    case major
    case minor
}

func getSubstitutes(context: ChordContext) -> [SubstituteChord] {
    let pcNames = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
    
    func pcToName(_ pc: Int) -> String {
        return pcNames[(pc % 12 + 12) % 12]
    }
    
    func mod12(_ val: Int) -> Int {
        return (val % 12 + 12) % 12
    }
    
    let rootName = pcToName(context.rootPc)
    let degree = context.degree
    let keyName = pcToName(context.keyTonic)
    
    var substitutes: [SubstituteChord] = []
    
    // Major key substitutes
    if context.keyMode == .major {
        switch degree {
        case 1:  // I (Tonic)
            substitutes = [
                SubstituteChord(
                    chord: "\(rootName)maj7",
                    reason: "Richer tonic sound with major 7th",
                    examples: ["The Girl from Ipanema", "Fly Me to the Moon"]
                ),
                SubstituteChord(
                    chord: "\(rootName)6",
                    reason: "Jazz tonic with added 6th",
                    examples: ["All the Things You Are", "Autumn Leaves"]
                ),
                SubstituteChord(
                    chord: "\(pcToName(mod12(context.rootPc + 9)))m",
                    reason: "Relative minor shares the same notes",
                    examples: ["Let It Be", "No Woman No Cry"]
                )
            ]
        case 2:  // ii (Subdominant)
            substitutes = [
                SubstituteChord(
                    chord: "\(rootName)m7",
                    reason: "Jazz ii with minor 7th",
                    examples: ["Autumn Leaves", "Fly Me to the Moon"]
                ),
                SubstituteChord(
                    chord: pcToName(mod12(context.keyTonic + 5)),
                    reason: "IV chord shares subdominant function",
                    examples: ["Let It Be", "Hey Jude"]
                )
            ]
        case 4:  // IV (Subdominant)
            substitutes = [
                SubstituteChord(
                    chord: "\(rootName)maj7",
                    reason: "Lydian color with major 7th",
                    examples: ["The Girl from Ipanema", "Dreams (Fleetwood Mac)"]
                ),
                SubstituteChord(
                    chord: "\(pcToName(mod12(context.keyTonic + 2)))m",
                    reason: "ii chord shares subdominant function",
                    examples: ["Autumn Leaves", "Fly Me to the Moon"]
                ),
                SubstituteChord(
                    chord: "\(rootName)m",
                    reason: "Borrowed minor IV for color",
                    examples: ["Yesterday", "Creep"]
                )
            ]
        case 5:  // V (Dominant)
            substitutes = [
                SubstituteChord(
                    chord: "\(rootName)7",
                    reason: "Dominant 7th creates strong tension",
                    examples: ["Sweet Home Alabama", "Twist and Shout"]
                ),
                SubstituteChord(
                    chord: "\(rootName)sus4",
                    reason: "Suspended 4th delays resolution",
                    examples: ["Pinball Wizard", "The Edge of Glory"]
                ),
                SubstituteChord(
                    chord: "\(pcToName(mod12(context.keyTonic + 11)))dim",
                    reason: "vii° shares dominant function",
                    examples: ["Girl from Ipanema", "Michelle"]
                )
            ]
        case 6:  // vi (Tonic)
            substitutes = [
                SubstituteChord(
                    chord: "\(rootName)m7",
                    reason: "Jazz minor with added 7th",
                    examples: ["Stairway to Heaven", "Hotel California"]
                ),
                SubstituteChord(
                    chord: keyName,
                    reason: "Relative major shares the same notes",
                    examples: ["Let It Be", "Hey Jude"]
                )
            ]
        default:
            // Generic substitutes
            if context.quality == .major {
                substitutes = [
                    SubstituteChord(
                        chord: "\(rootName)maj7",
                        reason: "Added major 7th for richer sound",
                        examples: nil
                    )
                ]
            } else if context.quality == .minor {
                substitutes = [
                    SubstituteChord(
                        chord: "\(rootName)m7",
                        reason: "Added minor 7th for jazz flavor",
                        examples: nil
                    )
                ]
            }
        }
    }
    // Minor key substitutes
    else {
        switch degree {
        case 1:  // i (Tonic)
            substitutes = [
                SubstituteChord(
                    chord: "\(rootName)m7",
                    reason: "Natural minor 7th",
                    examples: ["Stairway to Heaven", "Smooth"]
                ),
                SubstituteChord(
                    chord: "\(rootName)m6",
                    reason: "Minor 6th for Dorian color",
                    examples: ["Scarborough Fair", "So What"]
                ),
                SubstituteChord(
                    chord: pcToName(mod12(context.rootPc + 3)),
                    reason: "Relative major (bIII) shares notes",
                    examples: ["Stairway to Heaven", "All Along the Watchtower"]
                )
            ]
        case 4:  // iv (Subdominant)
            substitutes = [
                SubstituteChord(
                    chord: "\(rootName)m7",
                    reason: "Minor 7th for subdominant color",
                    examples: ["Light My Fire", "Losing My Religion"]
                )
            ]
        case 5:  // v or V (Dominant)
            if context.quality == .minor {
                substitutes = [
                    SubstituteChord(
                        chord: "\(rootName)7",
                        reason: "Raised 3rd (V7) for stronger resolution",
                        examples: ["Stairway to Heaven", "House of the Rising Sun"]
                    )
                ]
            } else {
                substitutes = [
                    SubstituteChord(
                        chord: "\(rootName)7",
                        reason: "Dominant 7th for tension",
                        examples: ["Smooth", "Black Magic Woman"]
                    )
                ]
            }
        default:
            // Generic substitutes
            if context.quality == .minor {
                substitutes = [
                    SubstituteChord(
                        chord: "\(rootName)m7",
                        reason: "Added minor 7th for jazz flavor",
                        examples: nil
                    )
                ]
            }
        }
    }
    
    // Maximum 3 substitutes
    return Array(substitutes.prefix(3))
}

