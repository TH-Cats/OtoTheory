import { PC_NAMES, mod12 } from '../music-theory/constants';

export type KeyCandidate = {
    tonic: string;
    mode: 'Major' | 'Minor';
    confidence: number;
    reasons: string[];
};

type ParsedChord = {
    root: number; // 0-11
    quality: string; // '', 'm', '7', 'maj7', 'm7', 'dim', etc.
};

// Diatonic chord quality expectations for each degree
const DEG_QUAL_MAJOR: Record<number, string[]> = {
    0: ['', 'maj7', '7'],  // I
    2: ['m', 'm7'],         // ii
    4: ['m', 'm7'],         // iii
    5: ['', 'maj7'],        // IV
    7: ['', '7'],           // V
    9: ['m', 'm7'],         // vi
    11: ['dim', 'm7b5'],    // vii°
};

const DEG_QUAL_MINOR: Record<number, string[]> = {
    0: ['m', 'm7'],         // i
    2: ['dim', 'm7b5'],     // ii°
    3: ['', 'maj7'],        // III
    5: ['m', 'm7'],         // iv
    7: ['m', '7'],          // v (or V7 in harmonic)
    8: ['', 'maj7'],        // VI
    10: ['', '7'],          // VII
};

// Major scale (Ionian)
const MAJOR_SCALE = [0, 2, 4, 5, 7, 9, 11];
// Natural minor scale (Aeolian)
const MINOR_SCALE = [0, 2, 3, 5, 7, 8, 10];

function parseChordSymbol(chord: string): ParsedChord | null {
    // Remove whitespace
    chord = chord.trim();
    if (!chord) return null;
    
    // Match root note (C, C#, Db, etc.)
    const rootMatch = chord.match(/^([A-G](?:#|b)?)/);
    if (!rootMatch) return null;
    
    const rootStr = rootMatch[1];
    
    // Normalize to sharp notation (PC_NAMES uses sharps)
    const normalized = rootStr.replace(/Db/, 'C#')
        .replace(/Eb/, 'D#')
        .replace(/Gb/, 'F#')
        .replace(/Ab/, 'G#')
        .replace(/Bb/, 'A#');
    
    const rootPc = PC_NAMES.indexOf(normalized as any);
    if (rootPc === -1) return null;
    
    // Extract quality (everything after root, before slash)
    const rest = chord.slice(rootStr.length).split('/')[0];
    
    // Normalize quality
    let quality = rest;
    if (!quality || quality === 'maj') quality = '';
    if (quality === 'min') quality = 'm';
    
    return { root: rootPc, quality };
}

function getChordTones(parsed: ParsedChord): number[] {
    const { root, quality } = parsed;
    const tones = [root];
    
    // Third
    if (quality.includes('m')) {
        tones.push(mod12(root + 3)); // minor 3rd
    } else {
        tones.push(mod12(root + 4)); // major 3rd
    }
    
    // Fifth
    if (quality.includes('dim')) {
        tones.push(mod12(root + 6)); // diminished 5th
    } else if (quality.includes('aug') || quality.includes('+')) {
        tones.push(mod12(root + 8)); // augmented 5th
    } else {
        tones.push(mod12(root + 7)); // perfect 5th
    }
    
    // Seventh
    if (quality.includes('maj7') || quality.includes('M7')) {
        tones.push(mod12(root + 11)); // major 7th
    } else if (quality.includes('7')) {
        tones.push(mod12(root + 10)); // minor 7th (dominant 7th)
    }
    
    return tones;
}

function scoreForKey(chords: ParsedChord[], key: { root: number; mode: 'Major' | 'Minor' }): { score: number; reasons: string[] } {
    const { root, mode } = key;
    const table = mode === 'Major' ? DEG_QUAL_MAJOR : DEG_QUAL_MINOR;
    const scale = mode === 'Major' ? MAJOR_SCALE : MINOR_SCALE;
    
    const maxPerChord = 3;
    const bonuses = 3;
    const denom = chords.length * maxPerChord + bonuses;
    
    let score = 0;
    const reasons: string[] = [];
    
    // Score each chord
    chords.forEach((chord, idx) => {
        const deg = mod12(chord.root - root);
        const expected = table[deg];
        
        if (expected) {
            if (expected.includes(chord.quality)) {
                score += 3; // Perfect match
            } else {
                score += 2; // Right degree, wrong quality
            }
        } else {
            // Check if chord tones fit in scale
            const tones = getChordTones(chord);
            const inScale = tones.every(t => scale.includes(mod12(t - root)));
            if (inScale) {
                score += 1;
            }
        }
        
        // Cadence bonus
        if (idx > 0) {
            const prevDeg = mod12(chords[idx - 1].root - root);
            const currDeg = deg;
            
            // Perfect cadence: V→I
            if (prevDeg === 7 && currDeg === 0) {
                score += 1;
                if (!reasons.includes('Cadence: V→I')) {
                    reasons.push('Cadence: V→I');
                }
            }
            // ii→V
            if (prevDeg === 2 && currDeg === 7) {
                score += 1;
            }
        }
    });
    
    // First chord bonus
    if (chords.length > 0) {
        const firstDeg = mod12(chords[0].root - root);
        if (mode === 'Major' && (firstDeg === 0 || firstDeg === 9)) {
            score += 2; // I or vi
        }
        if (mode === 'Minor' && (firstDeg === 0 || firstDeg === 3)) {
            score += 2; // i or III
        }
    }
    
    const pct = Math.round((score / Math.max(denom, 1)) * 100);
    reasons.unshift(`diatonic fit ${pct}%`);
    
    return { score: pct, reasons };
}

export function analyzeProgression(chordSymbols: string[]): KeyCandidate[] {
    const chords = chordSymbols
        .map(parseChordSymbol)
        .filter((c): c is ParsedChord => c !== null);
    
    if (chords.length === 0) {
        return [];
    }
    
    const candidates: KeyCandidate[] = [];
    
    // Test all 24 keys (12 major + 12 minor)
    for (let root = 0; root < 12; root++) {
        for (const mode of ['Major', 'Minor'] as const) {
            const { score, reasons } = scoreForKey(chords, { root, mode });
            candidates.push({
                tonic: PC_NAMES[root],
                mode,
                confidence: score,
                reasons
            });
        }
    }
    
    // Sort by confidence and return top 3
    candidates.sort((a, b) => b.confidence - a.confidence);
    return candidates.slice(0, 3);
}

