import { PC_NAMES, mod12 } from '../music-theory/constants';

export type ScaleCandidate = {
    root: string;
    type: string;
    score: number; // 0-100
};

type ParsedChord = {
    root: number; // 0-11
    quality: string;
};

// Scale intervals (semitones from root)
const SCALE_INTERVALS: Record<string, number[]> = {
    'Ionian': [0, 2, 4, 5, 7, 9, 11],
    'Dorian': [0, 2, 3, 5, 7, 9, 10],
    'Phrygian': [0, 1, 3, 5, 7, 8, 10],
    'Lydian': [0, 2, 4, 6, 7, 9, 11],
    'Mixolydian': [0, 2, 4, 5, 7, 9, 10],
    'Aeolian': [0, 2, 3, 5, 7, 8, 10],
    'Locrian': [0, 1, 3, 5, 6, 8, 10],
    'HarmonicMinor': [0, 2, 3, 5, 7, 8, 11],
    'MelodicMinor': [0, 2, 3, 5, 7, 9, 11],
    'MajorPentatonic': [0, 2, 4, 7, 9],
    'MinorPentatonic': [0, 3, 5, 7, 10],
};

const CANDIDATE_TYPES_MAJOR = ['Ionian', 'Lydian', 'Mixolydian', 'MajorPentatonic'];
const CANDIDATE_TYPES_MINOR = ['Aeolian', 'Dorian', 'Phrygian', 'HarmonicMinor'];

function parseChordSymbol(chord: string): ParsedChord | null {
    chord = chord.trim();
    if (!chord) return null;
    
    const rootMatch = chord.match(/^([A-G](?:#|b)?)/);
    if (!rootMatch) return null;
    
    const rootStr = rootMatch[1];
    const normalized = rootStr.replace(/Db/, 'C#')
        .replace(/Eb/, 'D#')
        .replace(/Gb/, 'F#')
        .replace(/Ab/, 'G#')
        .replace(/Bb/, 'A#');
    
    const rootPc = PC_NAMES.indexOf(normalized as any);
    if (rootPc === -1) return null;
    
    const rest = chord.slice(rootStr.length).split('/')[0];
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
        tones.push(mod12(root + 10)); // minor 7th
    }
    
    return tones;
}

function getScalePitches(rootPc: number, scaleType: string): number[] {
    const intervals = SCALE_INTERVALS[scaleType];
    if (!intervals) return [];
    return intervals.map(interval => mod12(rootPc + interval));
}

function uniq<T>(arr: T[]): T[] {
    return Array.from(new Set(arr));
}

export function scoreScales(
    prog: string[],
    key: { root: string; mode: 'Major' | 'Minor' }
): ScaleCandidate[] {
    const rootPc = PC_NAMES.indexOf(key.root as any);
    if (rootPc === -1) return [];
    
    const types = key.mode === 'Major' ? CANDIDATE_TYPES_MAJOR : CANDIDATE_TYPES_MINOR;
    
    // Extract all chord tones
    const chordPcs = uniq(
        prog
            .map(parseChordSymbol)
            .filter((c): c is ParsedChord => c !== null)
            .flatMap(getChordTones)
    );
    
    // Check if progression has V7 (dominant 7th)
    const hasV7 = prog.some(ch => /7\b/.test(ch));
    
    return types
        .map(type => {
            const scale = getScalePitches(rootPc, type);
            const hit = chordPcs.filter(pc => scale.includes(pc)).length;
            const cover = hit / Math.max(1, chordPcs.length);
            
            // Bonuses (max total 0.05)
            let bonus = 0;
            if (key.mode === 'Major' && type === 'Ionian') bonus += 0.02;
            if (key.mode === 'Minor' && type === 'Aeolian') bonus += 0.02;
            if (hasV7 && (type === 'HarmonicMinor' || type === 'MelodicMinor')) bonus += 0.03;
            
            const raw = Math.min(1, cover + bonus);
            const score = Math.round(raw * 100);
            
            return { root: key.root, type, score };
        })
        .sort((a, b) => b.score - a.score);
}

