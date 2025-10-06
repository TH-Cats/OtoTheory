/**
 * 代理コード（Substitute Chords）推奨ロジック（リファクタリング版）
 * 
 * 各ダイアトニックコードに対して、機能的に類似した代理コード候補を提示
 */

import { pcToName, mod12 } from '@/lib/music/constants';

export type SubstituteChord = {
  chord: string; // "Cmaj7", "Am" など
  reason: string; // 代理の理由（一文）
  examples?: string[]; // 代表曲の例（2〜3件）
};

export type ChordContext = {
  rootPc: number; // 0=C, 1=C#, ..., 11=B
  quality: 'maj' | 'min' | 'dom7' | 'dim';
  degree: number; // 1=I, 2=II, ..., 7=VII (1-indexed)
  key: { tonic: number; mode: 'Major' | 'Minor' };
};

type SubstituteRule = (context: ChordContext) => SubstituteChord[];

/**
 * Major keyにおける各度数の代理コード定義
 */
const MAJOR_KEY_SUBSTITUTES: Record<number, SubstituteRule> = {
  // I (Tonic)
  1: ({ rootPc }) => [
    {
      chord: `${pcToName(rootPc)}maj7`,
      reason: "Richer tonic sound with major 7th",
      examples: ["The Girl from Ipanema", "Fly Me to the Moon"]
    },
    {
      chord: `${pcToName(rootPc)}6`,
      reason: "Jazz tonic with added 6th",
      examples: ["All the Things You Are", "Autumn Leaves"]
    },
    {
      chord: `${pcToName(mod12(rootPc + 9))}m`,
      reason: "Relative minor shares the same notes",
      examples: ["Let It Be", "No Woman No Cry"]
    }
  ],

  // ii (Subdominant)
  2: ({ rootPc, key }) => [
    {
      chord: `${pcToName(rootPc)}m7`,
      reason: "Jazz ii with minor 7th",
      examples: ["Autumn Leaves", "Fly Me to the Moon"]
    },
    {
      chord: pcToName(mod12(key.tonic + 5)),
      reason: "IV chord shares subdominant function",
      examples: ["Let It Be", "Hey Jude"]
    }
  ],

  // IV (Subdominant)
  4: ({ rootPc, key }) => [
    {
      chord: `${pcToName(rootPc)}maj7`,
      reason: "Lydian color with major 7th",
      examples: ["The Girl from Ipanema", "Dreams (Fleetwood Mac)"]
    },
    {
      chord: `${pcToName(mod12(key.tonic + 2))}m`,
      reason: "ii chord shares subdominant function",
      examples: ["Autumn Leaves", "Fly Me to the Moon"]
    },
    {
      chord: `${pcToName(rootPc)}m`,
      reason: "Borrowed minor IV for color",
      examples: ["Yesterday", "Creep"]
    }
  ],

  // V (Dominant)
  5: ({ rootPc, key }) => [
    {
      chord: `${pcToName(rootPc)}7`,
      reason: "Dominant 7th creates strong tension",
      examples: ["Sweet Home Alabama", "Twist and Shout"]
    },
    {
      chord: `${pcToName(rootPc)}sus4`,
      reason: "Suspended 4th delays resolution",
      examples: ["Pinball Wizard", "The Edge of Glory"]
    },
    {
      chord: `${pcToName(mod12(key.tonic + 11))}dim`,
      reason: "vii° shares dominant function",
      examples: ["Girl from Ipanema", "Michelle"]
    }
  ],

  // vi (Tonic)
  6: ({ rootPc, key }) => [
    {
      chord: `${pcToName(rootPc)}m7`,
      reason: "Jazz minor with added 7th",
      examples: ["Stairway to Heaven", "Hotel California"]
    },
    {
      chord: pcToName(key.tonic),
      reason: "Relative major shares the same notes",
      examples: ["Let It Be", "Hey Jude"]
    }
  ]
};

/**
 * Minor keyにおける各度数の代理コード定義
 */
const MINOR_KEY_SUBSTITUTES: Record<number, SubstituteRule> = {
  // i (Tonic)
  1: ({ rootPc }) => [
    {
      chord: `${pcToName(rootPc)}m7`,
      reason: "Natural minor 7th",
      examples: ["Stairway to Heaven", "Smooth"]
    },
    {
      chord: `${pcToName(rootPc)}m6`,
      reason: "Minor 6th for Dorian color",
      examples: ["Scarborough Fair", "So What"]
    },
    {
      chord: pcToName(mod12(rootPc + 3)),
      reason: "Relative major (bIII) shares notes",
      examples: ["Stairway to Heaven", "All Along the Watchtower"]
    }
  ],

  // iv (Subdominant)
  4: ({ rootPc }) => [
    {
      chord: `${pcToName(rootPc)}m7`,
      reason: "Minor 7th for subdominant color",
      examples: ["Light My Fire", "Losing My Religion"]
    }
  ],

  // v or V (Dominant)
  5: ({ rootPc, quality }) => {
    if (quality === 'min') {
      return [
        {
          chord: `${pcToName(rootPc)}7`,
          reason: "Raised 3rd (V7) for stronger resolution",
          examples: ["Stairway to Heaven", "House of the Rising Sun"]
        }
      ];
    } else {
      return [
        {
          chord: `${pcToName(rootPc)}7`,
          reason: "Dominant 7th for tension",
          examples: ["Smooth", "Black Magic Woman"]
        }
      ];
    }
  }
};

/**
 * 汎用的な代理コード（度数が定義されていない場合）
 */
function getGenericSubstitutes(context: ChordContext): SubstituteChord[] {
  const { rootPc, quality } = context;
  const subs: SubstituteChord[] = [];

  if (quality === 'maj') {
    subs.push({
      chord: `${pcToName(rootPc)}maj7`,
      reason: "Added major 7th for richer sound"
    });
  } else if (quality === 'min') {
    subs.push({
      chord: `${pcToName(rootPc)}m7`,
      reason: "Added minor 7th for jazz flavor"
    });
  }

  return subs;
}

/**
 * 代理コード候補を取得
 * @param context コードのコンテキスト（ルート音、クオリティ、度数、キー）
 * @returns 代理コード候補の配列（最大3つ）
 */
export function getSubstitutes(context: ChordContext): SubstituteChord[] {
  const { degree, key } = context;
  const isMajorKey = key.mode === 'Major';

  // 辞書から適切なルールを取得
  const substitutesMap = isMajorKey ? MAJOR_KEY_SUBSTITUTES : MINOR_KEY_SUBSTITUTES;
  const rule = substitutesMap[degree];

  let substitutes: SubstituteChord[];
  
  if (rule) {
    substitutes = rule(context);
  } else {
    // 定義されていない度数には汎用ルールを適用
    substitutes = getGenericSubstitutes(context);
  }

  // 最大3つまで
  return substitutes.slice(0, 3);
}

