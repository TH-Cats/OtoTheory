// Static chord library data for Web version
// Based on iOS StaticChordProvider.swift
// Array order: 1st string (high E) to 6th string (low E)

export type StaticFret = number | 0 | 'x';
export type StaticFinger = 1 | 2 | 3 | 4 | null;

export interface StaticBarre {
  fret: number;
  fromString: number; // 1 = high E, 6 = low E
  toString: number;
  finger?: StaticFinger;
}

export interface StaticForm {
  id: string;
  shapeName: string | null; // null = infer from data
  frets: [StaticFret, StaticFret, StaticFret, StaticFret, StaticFret, StaticFret]; // 1→6
  fingers: [StaticFinger, StaticFinger, StaticFinger, StaticFinger, StaticFinger, StaticFinger]; // 1→6
  barres: StaticBarre[];
  tips: string[];
}

export interface StaticChord {
  id: string;
  symbol: string;
  quality: string;
  forms: StaticForm[];
}

// Helper function to create fret notation
const F = (n: number): number => n;

// Major chords (メジャーコード)
export const MAJOR_CHORDS: StaticChord[] = [
  // C Major
  {
    id: 'C',
    symbol: 'C',
    quality: 'M',
    forms: [
      // Open: x32010
      {
        id: 'C-Open',
        shapeName: 'Open',
        frets: [0, 1, 0, 2, 3, 'x'],
        fingers: [null, 1, null, 2, 3, null],
        barres: [],
        tips: ['C major open', 'Beginner-friendly']
      },
      // Root-6 (8fr): 8-8-9-10-10-8
      {
        id: 'C-Root6',
        shapeName: 'Root-6',
        frets: [8, 10, 10, 9, 8, 8],
        fingers: [1, 3, 4, 2, 1, 1],
        barres: [{ fret: 8, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'E-shape barre']
      },
      // Root-5 (3fr): 3-5-5-5-3-x
      {
        id: 'C-Root5',
        shapeName: 'Root-5',
        frets: [3, 5, 5, 5, 3, 'x'],
        fingers: [1, 3, 4, 2, 1, null],
        barres: [{ fret: 3, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'A-shape barre']
      },
      // Root-4: 10-12-12-12-10-x-x (will add later)
    ]
  },

  // D Major
  {
    id: 'D',
    symbol: 'D',
    quality: 'M',
    forms: [
      // Open: xx0232
      {
        id: 'D-Open',
        shapeName: 'Open',
        frets: [2, 3, 2, 0, 'x', 'x'],
        fingers: [1, 3, 2, null, null, null],
        barres: [],
        tips: ['D major open', 'Bright sound']
      },
      // Root-6 (10fr): 10-10-11-12-12-10
      {
        id: 'D-Root6',
        shapeName: 'Root-6',
        frets: [10, 12, 12, 11, 10, 10],
        fingers: [1, 3, 4, 2, 1, 1],
        barres: [{ fret: 10, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'E-shape barre']
      },
      // Root-5 (5fr): 5-7-7-7-5-x
      {
        id: 'D-Root5',
        shapeName: 'Root-5',
        frets: [5, 7, 7, 7, 5, 'x'],
        fingers: [1, 3, 4, 2, 1, null],
        barres: [{ fret: 5, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'A-shape barre']
      }
    ]
  },

  // E Major
  {
    id: 'E',
    symbol: 'E',
    quality: 'M',
    forms: [
      // Open: 022100
      {
        id: 'E-Open',
        shapeName: 'Open',
        frets: [0, 0, 1, 2, 2, 0],
        fingers: [null, null, 1, 3, 2, null],
        barres: [],
        tips: ['E major open', 'Full, rich sound']
      },
      // Root-6 (12fr): 12-12-13-14-14-12
      {
        id: 'E-Root6',
        shapeName: 'Root-6',
        frets: [12, 14, 14, 13, 12, 12],
        fingers: [1, 3, 4, 2, 1, 1],
        barres: [{ fret: 12, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'E-shape barre']
      },
      // Root-5 (7fr): 7-9-9-9-7-x
      {
        id: 'E-Root5',
        shapeName: 'Root-5',
        frets: [7, 9, 9, 9, 7, 'x'],
        fingers: [1, 3, 4, 2, 1, null],
        barres: [{ fret: 7, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'A-shape barre']
      }
    ]
  },

  // G Major
  {
    id: 'G',
    symbol: 'G',
    quality: 'M',
    forms: [
      // Open: 320003
      {
        id: 'G-Open',
        shapeName: 'Open',
        frets: [3, 0, 0, 0, 2, 3],
        fingers: [3, null, null, null, 1, 2],
        barres: [],
        tips: ['G major open', 'Full-bodied']
      },
      // Root-6 (3fr): 3-3-4-5-5-3
      {
        id: 'G-Root6',
        shapeName: 'Root-6',
        frets: [3, 5, 5, 4, 3, 3],
        fingers: [1, 3, 4, 2, 1, 1],
        barres: [{ fret: 3, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'E-shape barre']
      },
      // Root-5 (10fr): 10-12-12-12-10-x
      {
        id: 'G-Root5',
        shapeName: 'Root-5',
        frets: [10, 12, 12, 12, 10, 'x'],
        fingers: [1, 3, 4, 2, 1, null],
        barres: [{ fret: 10, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'A-shape barre']
      }
    ]
  },

  // A Major
  {
    id: 'A',
    symbol: 'A',
    quality: 'M',
    forms: [
      // Open: x02220
      {
        id: 'A-Open',
        shapeName: 'Open',
        frets: [0, 2, 2, 2, 0, 'x'],
        fingers: [null, 2, 3, 1, null, null],
        barres: [],
        tips: ['A major open', 'Powerful sound']
      },
      // Root-6 (5fr): 5-5-6-7-7-5
      {
        id: 'A-Root6',
        shapeName: 'Root-6',
        frets: [5, 7, 7, 6, 5, 5],
        fingers: [1, 3, 4, 2, 1, 1],
        barres: [{ fret: 5, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'E-shape barre']
      },
      // Root-5 (12fr): 12-14-14-14-12-x
      {
        id: 'A-Root5',
        shapeName: 'Root-5',
        frets: [12, 14, 14, 14, 12, 'x'],
        fingers: [1, 3, 4, 2, 1, null],
        barres: [{ fret: 12, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'A-shape barre']
      }
    ]
  },
];

// Minor chords (マイナーコード)
export const MINOR_CHORDS: StaticChord[] = [
  // Am
  {
    id: 'Am',
    symbol: 'Am',
    quality: 'm',
    forms: [
      // Open: x01020
      {
        id: 'Am-Open',
        shapeName: 'Open',
        frets: [0, 1, 0, 2, 0, 'x'],
        fingers: [null, 1, null, 2, null, null],
        barres: [],
        tips: ['A minor open', 'Melancholic']
      },
      // Root-6 (5fr): 5-5-5-5-7-5
      {
        id: 'Am-Root6',
        shapeName: 'Root-6',
        frets: [5, 7, 5, 5, 5, 5],
        fingers: [1, 3, 1, 1, 1, 1],
        barres: [{ fret: 5, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'E-shape minor barre']
      },
      // Root-5 (12fr): 12-14-12-13-12-x
      {
        id: 'Am-Root5',
        shapeName: 'Root-5',
        frets: [12, 13, 12, 14, 12, 'x'],
        fingers: [1, 2, 1, 3, 1, null],
        barres: [{ fret: 12, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'A-shape minor barre']
      }
    ]
  },

  // Dm
  {
    id: 'Dm',
    symbol: 'Dm',
    quality: 'm',
    forms: [
      // Open: xx0231
      {
        id: 'Dm-Open',
        shapeName: 'Open',
        frets: [1, 3, 2, 0, 'x', 'x'],
        fingers: [1, 3, 2, null, null, null],
        barres: [],
        tips: ['D minor open', 'Compact and easy']
      },
      // Root-6 (10fr): 10-10-10-10-12-10
      {
        id: 'Dm-Root6',
        shapeName: 'Root-6',
        frets: [10, 12, 10, 10, 10, 10],
        fingers: [1, 3, 1, 1, 1, 1],
        barres: [{ fret: 10, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'E-shape minor barre']
      },
      // Root-5 (5fr): 5-6-5-7-5-x
      {
        id: 'Dm-Root5',
        shapeName: 'Root-5',
        frets: [5, 7, 5, 6, 5, 'x'],
        fingers: [1, 3, 1, 2, 1, null],
        barres: [{ fret: 5, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'A-shape minor barre']
      }
    ]
  },

  // Em
  {
    id: 'Em',
    symbol: 'Em',
    quality: 'm',
    forms: [
      // Open: 022000
      {
        id: 'Em-Open',
        shapeName: 'Open',
        frets: [0, 0, 0, 2, 2, 0],
        fingers: [null, null, null, 2, 3, null],
        barres: [],
        tips: ['E minor open', 'Beautiful resonance']
      },
      // Root-6 (12fr): 12-12-12-12-14-12
      {
        id: 'Em-Root6',
        shapeName: 'Root-6',
        frets: [12, 14, 12, 12, 12, 12],
        fingers: [1, 3, 1, 1, 1, 1],
        barres: [{ fret: 12, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'E-shape minor barre']
      },
      // Root-5 (7fr): 7-8-7-9-7-x
      {
        id: 'Em-Root5',
        shapeName: 'Root-5',
        frets: [7, 9, 7, 8, 7, 'x'],
        fingers: [1, 3, 1, 2, 1, null],
        barres: [{ fret: 7, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'A-shape minor barre']
      }
    ]
  },
];

// Dominant 7th chords (セブンスコード)
export const DOM7_CHORDS: StaticChord[] = [
  // C7
  {
    id: 'C7',
    symbol: 'C7',
    quality: '7',
    forms: [
      // Open: x32310
      {
        id: 'C7-Open',
        shapeName: 'Open',
        frets: [0, 1, 3, 2, 3, 'x'],
        fingers: [null, 1, 4, 2, 3, null],
        barres: [],
        tips: ['C7 open', 'Blues classic']
      },
      // Root-6 (8fr): 8-8-9-8-10-8
      {
        id: 'C7-Root6',
        shapeName: 'Root-6',
        frets: [8, 10, 8, 9, 8, 8],
        fingers: [1, 3, 1, 2, 1, 1],
        barres: [{ fret: 8, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'E-shape 7th barre']
      },
      // Root-5 (3fr): 3-5-3-5-3-x
      {
        id: 'C7-Root5',
        shapeName: 'Root-5',
        frets: [3, 5, 3, 5, 3, 'x'],
        fingers: [1, 3, 1, 4, 1, null],
        barres: [{ fret: 3, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'A-shape 7th barre']
      }
    ]
  },

  // G7
  {
    id: 'G7',
    symbol: 'G7',
    quality: '7',
    forms: [
      // Open: 320001
      {
        id: 'G7-Open',
        shapeName: 'Open',
        frets: [1, 0, 0, 0, 2, 3],
        fingers: [1, null, null, null, 2, 3],
        barres: [],
        tips: ['G7 open', 'Full-bodied']
      },
      // Root-6 (3fr): 3-3-4-3-5-3
      {
        id: 'G7-Root6',
        shapeName: 'Root-6',
        frets: [3, 5, 3, 4, 3, 3],
        fingers: [1, 3, 1, 2, 1, 1],
        barres: [{ fret: 3, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'E-shape 7th barre']
      },
      // Root-5 (10fr): 10-12-10-12-10-x
      {
        id: 'G7-Root5',
        shapeName: 'Root-5',
        frets: [10, 12, 10, 12, 10, 'x'],
        fingers: [1, 3, 1, 4, 1, null],
        barres: [{ fret: 10, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'A-shape 7th barre']
      }
    ]
  },
];

// Major 7th chords (メジャーセブンスコード)
export const MAJ7_CHORDS: StaticChord[] = [
  // CM7
  {
    id: 'CM7',
    symbol: 'CM7',
    quality: 'M7',
    forms: [
      // Open: x32000
      {
        id: 'CM7-Open',
        shapeName: 'Open',
        frets: [0, 0, 0, 2, 3, 'x'],
        fingers: [null, null, null, 2, 3, null],
        barres: [],
        tips: ['C major 7th open', 'Dreamy']
      },
      // Root-6 (8fr): 8-8-9-9-10-8
      {
        id: 'CM7-Root6',
        shapeName: 'Root-6',
        frets: [8, 10, 9, 9, 8, 8],
        fingers: [1, 3, 2, 2, 1, 1],
        barres: [{ fret: 8, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'E-shape M7 barre']
      },
      // Root-5 (3fr): 3-5-4-5-3-x
      {
        id: 'CM7-Root5',
        shapeName: 'Root-5',
        frets: [3, 5, 4, 5, 3, 'x'],
        fingers: [1, 3, 2, 4, 1, null],
        barres: [{ fret: 3, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'A-shape M7 barre']
      }
    ]
  },
];

// Minor 7th chords (マイナーセブンスコード)
export const MIN7_CHORDS: StaticChord[] = [
  // Cm7
  {
    id: 'Cm7',
    symbol: 'Cm7',
    quality: 'm7',
    forms: [
      // Root-6 (8fr): 8-8-8-8-10-8
      {
        id: 'Cm7-Root6',
        shapeName: 'Root-6',
        frets: [8, 10, 8, 8, 8, 8],
        fingers: [1, 3, 1, 1, 1, 1],
        barres: [{ fret: 8, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'm7 E-shape full barre']
      },
      // Root-5 (3fr): 3-4-3-5-3-x
      {
        id: 'Cm7-Root5',
        shapeName: 'Root-5',
        frets: [3, 5, 3, 4, 3, 'x'],
        fingers: [1, 3, 1, 2, 1, null],
        barres: [{ fret: 3, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'Standard m7 A-shape']
      },
      // Root-4 (10-12fr): 11-11-12-10-x-x
      {
        id: 'Cm7-Root4',
        shapeName: 'Root-4',
        frets: [11, 12, 10, 11, 'x', 'x'],
        fingers: [3, 4, 1, 2, null, null],
        barres: [],
        tips: ['4th string root', 'High position']
      }
    ]
  },

  // Dm7
  {
    id: 'Dm7',
    symbol: 'Dm7',
    quality: 'm7',
    forms: [
      // Open: xx0211
      {
        id: 'Dm7-Open',
        shapeName: 'Open',
        frets: [1, 1, 2, 0, 'x', 'x'],
        fingers: [1, 1, 2, null, null, null],
        barres: [],
        tips: ['D minor 7th', 'Compact and easy']
      },
      // Root-6 (10fr): 10-10-10-10-12-10
      {
        id: 'Dm7-Root6',
        shapeName: 'Root-6',
        frets: [10, 12, 10, 10, 10, 10],
        fingers: [1, 3, 1, 1, 1, 1],
        barres: [{ fret: 10, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'm7 E-shape full barre']
      },
      // Root-5 (5fr): 5-6-5-7-5-x
      {
        id: 'Dm7-Root5',
        shapeName: 'Root-5',
        frets: [5, 7, 5, 6, 5, 'x'],
        fingers: [1, 3, 1, 2, 1, null],
        barres: [{ fret: 5, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'Standard m7 A-shape']
      },
      // Root-4 (12-14fr): 13-13-14-12-x-x
      {
        id: 'Dm7-Root4',
        shapeName: 'Root-4',
        frets: [13, 14, 12, 13, 'x', 'x'],
        fingers: [3, 4, 1, 2, null, null],
        barres: [],
        tips: ['4th string root', 'Compact voicing']
      }
    ]
  },

  // Em7
  {
    id: 'Em7',
    symbol: 'Em7',
    quality: 'm7',
    forms: [
      // Open: 020000
      {
        id: 'Em7-Open',
        shapeName: 'Open',
        frets: [0, 0, 0, 0, 2, 0],
        fingers: [null, null, null, null, 1, null],
        barres: [],
        tips: ['E minor 7th', 'Beautiful open sound']
      },
      // Root-4: 3-3-4-2-x-x
      {
        id: 'Em7-Root4',
        shapeName: 'Root-4',
        frets: [3, 4, 2, 3, 'x', 'x'],
        fingers: [3, 4, 1, 2, null, null],
        barres: [],
        tips: ['4th string root', 'Compact voicing']
      },
      // Root-5 (7fr): 7-8-7-9-7-x
      {
        id: 'Em7-Root5',
        shapeName: 'Root-5',
        frets: [7, 9, 7, 8, 7, 'x'],
        fingers: [1, 3, 1, 2, 1, null],
        barres: [{ fret: 7, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'Standard m7 A-shape']
      },
      // Root-6 (12fr): 12-12-12-12-14-12
      {
        id: 'Em7-Root6',
        shapeName: 'Root-6',
        frets: [12, 14, 12, 12, 12, 12],
        fingers: [1, 3, 1, 1, 1, 1],
        barres: [{ fret: 12, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'm7 E-shape full barre']
      }
    ]
  },

  // Am7
  {
    id: 'Am7',
    symbol: 'Am7',
    quality: 'm7',
    forms: [
      // Open: x01020
      {
        id: 'Am7-Open',
        shapeName: 'Open',
        frets: [0, 1, 0, 2, 0, 'x'],
        fingers: [null, 1, null, 2, null, null],
        barres: [],
        tips: ['A minor 7th', 'Melancholic sound']
      },
      // Root-6 (5fr): 5-5-5-5-7-5
      {
        id: 'Am7-Root6',
        shapeName: 'Root-6',
        frets: [5, 7, 5, 5, 5, 5],
        fingers: [1, 3, 1, 1, 1, 1],
        barres: [{ fret: 5, fromString: 1, toString: 6, finger: 1 }],
        tips: ['6th string root', 'm7 E-shape full barre']
      },
      // Root-5 (12fr): 12-13-12-14-12-x
      {
        id: 'Am7-Root5',
        shapeName: 'Root-5',
        frets: [12, 14, 12, 13, 12, 'x'],
        fingers: [1, 3, 1, 2, 1, null],
        barres: [{ fret: 12, fromString: 1, toString: 5, finger: 1 }],
        tips: ['5th string root', 'Standard m7 A-shape']
      },
      // Root-4 (7-9fr): 8-8-9-7-x-x
      {
        id: 'Am7-Root4',
        shapeName: 'Root-4',
        frets: [8, 9, 7, 8, 'x', 'x'],
        fingers: [3, 4, 1, 2, null, null],
        barres: [],
        tips: ['4th string root', 'Compact voicing']
      }
    ]
  },
];

// Combine all static chords
export const ALL_STATIC_CHORDS: StaticChord[] = [
  ...MAJOR_CHORDS,
  ...MINOR_CHORDS,
  ...DOM7_CHORDS,
  ...MAJ7_CHORDS,
  ...MIN7_CHORDS,
];

// Helper to find chord by symbol
export function getStaticChord(symbol: string): StaticChord | undefined {
  return ALL_STATIC_CHORDS.find(c => c.symbol === symbol);
}

