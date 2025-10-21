// OtoTheory Scales Master Data
// Generated from OtoTheory_Scales_v3.csv

export type ScaleId = 
  | 'major' | 'naturalMinor' | 'dorian' | 'phrygian' | 'lydian' | 'mixolydian' | 'locrian'
  | 'majPent' | 'minPent' | 'bluesMinor'
  | 'harmonicMinor' | 'melodicMinor'
  | 'dimWholeHalf' | 'dimHalfWhole'
  | 'lydianb7' | 'mixolydianb6' | 'phrygDominant' | 'altered' | 'wholeTone';

export type ScaleCategory = 'Basic' | 'Modes' | 'Pentatonic & Blues' | 'Minor family' | 'Symmetrical' | 'Advanced';

export interface ScaleComments {
  vibe: string;
  use: string;
  try: string;
  theory: string;
}

export interface ScaleMeta {
  id: ScaleId;
  categoryEn: ScaleCategory;
  categoryJa: string;
  scaleEn: string;
  scaleJa: string;
  aliasEn?: string[];
  degrees: string[];
  intervals: number[];
  tones: 5 | 6 | 7 | 8;
  heptatonic: boolean;
  romanException?: boolean;
  comments: {
    en: ScaleComments;
    ja: ScaleComments;
  };
}

export const SCALE_MASTER: ScaleMeta[] = [
  {
    id: 'major',
    categoryEn: 'Basic',
    categoryJa: '基本',
    scaleEn: 'Major Scale',
    scaleJa: 'メジャースケール',
    aliasEn: ['Ionian'],
    degrees: ['R', '2', '3', '4', '5', '6', '7'],
    intervals: [0, 2, 4, 5, 7, 9, 11],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'Bright, positive, and full of happiness. The quintessential sound, perfect for beginnings or conveying a core message.',
        use: 'The most important scale, forming the foundation of all music from J-POP and rock to country and nursery rhymes.',
        try: 'Use it in the chorus to deliver a direct, positive emotion to the listener. When in doubt, start with this scale.',
        theory: 'Composed of R-2-3-4-5-6-7. It harmonizes perfectly over Imaj7 and IVmaj7 chords.'
      },
      ja: {
        vibe: '明るくポジティブ、幸福感に満ちた王道の響き。物語の始まりや、最も伝えたいメッセージを乗せるのに最適です。',
        use: 'J-POP、ロック、カントリー、童謡など、あらゆる音楽の基礎を成す最も重要なスケールです。',
        try: '曲のサビで使うと、リスナーに最もストレートにポジティブな感情を届けられます。迷ったらまずはこのスケールから始めましょう。',
        theory: '構成音はR-2-3-4-5-6-7。ダイアトニックコードのImaj7、IVmaj7の上で完璧に調和します。'
      }
    }
  },
  {
    id: 'naturalMinor',
    categoryEn: 'Basic',
    categoryJa: '基本',
    scaleEn: 'Natural Minor',
    scaleJa: 'ナチュラルマイナースケール',
    aliasEn: ['Aeolian'],
    degrees: ['R', '2', 'b3', '4', '5', 'b6', 'b7'],
    intervals: [0, 2, 3, 5, 7, 8, 10],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'Melancholy, sentimental, and poignant. Perfect for expressing not just joy, but also sorrow and introspection.',
        use: 'Essential for deep songs like ballads, rock, and R&B. Its contrast with major scales creates drama.',
        try: 'Use it to start a verse quietly, to cool down after a chorus, or to accompany emotional lyrics.',
        theory: 'Composed of R-2-b3-4-5-b6-b7. It\'s the 6th mode of the major scale (Aeolian) and pairs perfectly with Im7 and IVm7 chords.'
      },
      ja: {
        vibe: '物憂げで感傷的、切ない響き。喜びだけでなく、哀愁や内省的な感情を表現するのに最適です。',
        use: 'バラード、ロック、R&Bなど、深みのある楽曲には欠かせません。メジャーとの対比が曲にドラマを生みます。',
        try: 'Aメロで静かに始めたい時や、サビ後のクールダウン、感情的な歌詞に乗せて使ってみましょう。',
        theory: '構成音はR-2-b3-4-5-b6-b7。メジャースケールの6番目のモード(Aeolian)で、Im7、IVm7コードと相性抜群です。'
      }
    }
  },
  {
    id: 'dorian',
    categoryEn: 'Modes',
    categoryJa: 'モード',
    scaleEn: 'Dorian Scale',
    scaleJa: 'ドリアンスケール',
    degrees: ['R', '2', 'b3', '4', '5', '6', 'b7'],
    intervals: [0, 2, 3, 5, 7, 9, 10],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'Cool and stylish, sounding slightly bright for a minor scale. Its urban, floating quality is a staple in R&B and fusion.',
        use: 'A go-to for funk rhythm guitar and jazz improvisation. Santana\'s "Oye Como Va" is a famous example.',
        try: 'In a minor key song, change the IV chord to major (IV7). Using this scale over it will instantly create a Dorian world.',
        theory: 'Composed of R-2-b3-4-5-6-b7. It\'s a brighter minor scale where the b6 of natural minor is raised to a major 6th. Often used over IIm7.'
      },
      ja: {
        vibe: 'マイナーなのに少し明るい、クールでおしゃれな響き。R&Bやフュージョンで多用される、都会的な浮遊感が魅力です。',
        use: 'ファンクのカッティングギターや、ジャズのインプロヴィゼーションで定番。サンタナの"Oye Como Va"が有名です。',
        try: 'マイナーキーの曲で、IVのコードをメジャー(IV7)に変えてみましょう。その上でこのスケールを使うと、一気にドリアンの世界観になります。',
        theory: '構成音はR-2-b3-4-5-6-b7。ナチュラルマイナーのb6が6になった、明るい響きのマイナースケールです。IIm7でよく使われます。'
      }
    }
  },
  {
    id: 'phrygian',
    categoryEn: 'Modes',
    categoryJa: 'モード',
    scaleEn: 'Phrygian Scale',
    scaleJa: 'フリジアンスケール',
    degrees: ['R', 'b2', 'b3', '4', '5', 'b6', 'b7'],
    intervals: [0, 1, 3, 5, 7, 8, 10],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'Passionate, Spanish, and exotic. Used to create mystery or heighten tension.',
        use: 'Its unique character shines in Flamenco music and the heavy riffs of heavy metal.',
        try: 'Use the major chord a half step above the root (the bII chord). For example, over E Phrygian, using an F major chord will instantly create a Spanish sound.',
        theory: 'Composed of R-b2-b3-4-5-b6-b7. A very distinctive scale where the 2nd degree of natural minor is lowered to a b2.'
      },
      ja: {
        vibe: '情熱的でスパニッシュ、エキゾチックな雰囲気が特徴。ミステリアスな場面や、緊張感を高めたい時に使います。',
        use: 'フラメンコ音楽や、ヘヴィメタルの重いリフでその独特の世界観が活かされます。',
        try: 'ルートのすぐ半音上のメジャーコード(bII)を使ってみましょう。例えばE Phrygianなら、Fコードを使うと一気にスパニッシュな響きになります。',
        theory: '構成音はR-b2-b3-4-5-b6-b7。ナチュラルマイナーの2がb2になった、非常に個性的なスケールです。'
      }
    }
  },
  {
    id: 'lydian',
    categoryEn: 'Modes',
    categoryJa: 'モード',
    scaleEn: 'Lydian Scale',
    scaleJa: 'リディアンスケール',
    degrees: ['R', '2', '3', '#4', '5', '6', '7'],
    intervals: [0, 2, 4, 6, 7, 9, 11],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'A grand, dreamlike sound that adds a floating quality to the major scale. Evokes magic, space, and fantasy.',
        use: 'Often used in film and game scores to depict fantastical scenes or epic nature. Steve Vai is a frequent user.',
        try: 'Try using this scale over the IVmaj7 chord in a major key. Its dreamy effect will be maximized.',
        theory: 'Composed of R-2-3-#4-5-6-7. It\'s the major scale with a #4. This #4 note is the secret to its floating quality.'
      },
      ja: {
        vibe: 'メジャースケールに浮遊感を加えた、壮大で夢のような響き。魔法や宇宙を思わせる、幻想的なサウンドです。',
        use: '映画音楽やゲーム音楽で、幻想的なシーンや壮大な自然を描写するのによく使われます。スティーブ・ヴァイも多用します。',
        try: 'メジャーキーのIVmaj7コードの上で、このスケールを試してみましょう。ドリーミーな効果が最大限に発揮されます。',
        theory: '構成音はR-2-3-#4-5-6-7。メジャースケールの4が#4になったスケール。この#4の音が浮遊感の秘密です。'
      }
    }
  },
  {
    id: 'mixolydian',
    categoryEn: 'Modes',
    categoryJa: 'モード',
    scaleEn: 'Mixolydian Scale',
    scaleJa: 'ミクソリディアンスケール',
    degrees: ['R', '2', '3', '4', '5', '6', 'b7'],
    intervals: [0, 2, 4, 5, 7, 9, 10],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'A cheerful and funky scale that combines brightness with a bluesy feel. A laid-back, upbeat sound.',
        use: 'Essential for groovy music like blues, funk, country, and rock \'n\' roll. The Beatles used it extensively.',
        try: 'It fits perfectly over a dominant 7th chord (V7). Also, try it over the I7 and IV7 chords in a blues progression.',
        theory: 'Composed of R-2-3-4-5-6-b7. It\'s the major scale with a b7, making it the fundamental scale for V7 chords.'
      },
      ja: {
        vibe: '明るさとブルース感が同居した、陽気でファンキーなスケール。少しルーズで、ご機嫌な響きです。',
        use: 'ブルース、ファンク、カントリー、ロックンロールなど、ノリの良い音楽に欠かせません。ビートルズも多用しました。',
        try: 'ドミナントセブンスコード(V7)に完璧にフィットします。ブルース進行のI7、IV7の上でも使ってみましょう。',
        theory: '構成音はR-2-3-4-5-6-b7。メジャースケールの7がb7になったスケールで、V7コードの基本となります。'
      }
    }
  },
  {
    id: 'locrian',
    categoryEn: 'Modes',
    categoryJa: 'モード',
    scaleEn: 'Locrian Scale',
    scaleJa: 'ロクリアンスケール',
    degrees: ['R', 'b2', 'b3', '4', 'b5', 'b6', 'b7'],
    intervals: [0, 1, 3, 5, 6, 8, 10],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'The darkest, most unstable mode, with a tension that refuses to resolve. An unsettling sound, like a mystery or horror film.',
        use: 'While it exists in theory, it\'s rarely used as the main scale for a song. It appears in dissonant heavy metal riffs or for fleeting moments of tension in jazz.',
        try: 'Use this scale sparingly over a IIm7b5 chord in a minor key. It will make the transition to the following V7 more thrilling.',
        theory: 'Composed of R-b2-b3-4-b5-b6-b7. The 7th mode of the major scale. It\'s highly unstable due to the tritone between the root and the b5.'
      },
      ja: {
        vibe: '最も暗く不安定で、解決しない緊張感を持つ響き。ミステリーやホラー映画のような、落ち着かないサウンドです。',
        use: '理論上は存在するものの、楽曲の主役として使われることは稀。ヘヴィメタルの dissonant なリフや、ジャズで一瞬の緊張感を出すために使われます。',
        try: 'マイナーキーの IIm7b5 コードの上で、このスケールを部分的に使ってみましょう。次の V7 への移行を、よりスリリングに演出できます。',
        theory: '構成音は R-b2-b3-4-b5-b6-b7。メジャースケールの7番目のモード。ルートからb5がトライトーンを形成するため、非常に不安定です。'
      }
    }
  },
  {
    id: 'majPent',
    categoryEn: 'Pentatonic & Blues',
    categoryJa: 'ペンタ＆ブルース',
    scaleEn: 'Major Pentatonic',
    scaleJa: 'メジャーペンタトニック',
    degrees: ['R', '2', '3', '5', '6'],
    intervals: [0, 2, 4, 7, 9],
    tones: 5,
    heptatonic: false,
    romanException: true,
    comments: {
      en: {
        vibe: 'A bright and somewhat nostalgic sound, reminiscent of Japanese melodies. You can\'t hit a wrong note, allowing anyone to create pleasant phrases.',
        use: 'Very widely used, from J-Pop vocal melodies and folk songs to country music guitar solos.',
        try: 'Over a major chord in a bright song, just play these five notes without overthinking. You\'ll naturally create a catchy melody.',
        theory: 'Composed of R-2-3-5-6. It\'s the major scale with the unstable 4th and 7th degrees removed, resulting in a very stable scale.'
      },
      ja: {
        vibe: '明るく、どこか懐かしい日本のメロディ。音を外す心配がなく、誰が弾いても心地よいフレーズが作れます。',
        use: 'J-POPの歌メロ、童謡や民謡、カントリーミュージックのギターソロなど、非常に幅広く使われます。',
        try: '明るい曲のメジャーコードの上で、何も考えずにこの5音を弾いてみましょう。自然とキャッチーなメロディが生まれます。',
        theory: '構成音はR-2-3-5-6。メジャースケールから不安定な4度と7度を抜いた、安定感抜群の音階です。'
      }
    }
  },
  {
    id: 'minPent',
    categoryEn: 'Pentatonic & Blues',
    categoryJa: 'ペンタ＆ブルース',
    scaleEn: 'Minor Pentatonic',
    scaleJa: 'マイナーペンタトニック',
    degrees: ['R', 'b3', '4', '5', 'b7'],
    intervals: [0, 3, 5, 7, 10],
    tones: 5,
    heptatonic: false,
    romanException: true,
    comments: {
      en: {
        vibe: 'The soul of rock and blues. A slightly wild and emotional sound. The first step into improvisation starts here.',
        use: 'Most rock guitar solos are based on this scale. It\'s also a star player in blues, pop, and funk.',
        try: 'Over a minor or seventh chord, play these five notes in any order. That alone will create a bluesy solo.',
        theory: 'Composed of R-b3-4-5-b7. It\'s the natural minor scale with the unstable 2nd and b6th degrees removed.'
      },
      ja: {
        vibe: 'ロックやブルースの魂。少しワイルドで、感情的な響き。アドリブの第一歩はここからです。',
        use: 'ロックのギターソロは、ほとんどがこのスケールがベース。ブルース、ポップス、ファンクでも大活躍します。',
        try: 'マイナーコードやセブンスコードの上で、この5音を自由な順番で弾いてみましょう。それだけでブルージーなソロになります。',
        theory: '構成音はR-b3-4-5-b7。ナチュラルマイナーから不安定な2度とb6度を抜いた音階です。'
      }
    }
  },
  {
    id: 'bluesMinor',
    categoryEn: 'Pentatonic & Blues',
    categoryJa: 'ペンタ＆ブルース',
    scaleEn: 'Blues Scale (minor)',
    scaleJa: 'ブルーススケール（マイナー）',
    degrees: ['R', 'b3', '4', 'b5', '5', 'b7'],
    intervals: [0, 3, 5, 6, 7, 10],
    tones: 6,
    heptatonic: false,
    comments: {
      en: {
        vibe: 'The sound of the blues itself, adding a "blue note" to the minor pentatonic for a sultry, soulful feel. Perfect for creating "crying" phrases.',
        use: 'Used in many genres with roots in Black music, such as blues, rock, jazz, and funk.',
        try: 'Over dominant seventh chords (I7, IV7, V7), use the b5 blue note effectively. It will create emotionally resonant phrases.',
        theory: 'Composed of R-b3-4-b5-5-b7. It\'s a six-note scale formed by adding a b5 to the minor pentatonic.'
      },
      ja: {
        vibe: 'マイナーペンタに「ブルーノート」という妖しい響きを加えた、ブルースそのもの。泣きのフレーズが作れます。',
        use: 'ブルース、ロック、ジャズ、ファンクなど、黒人音楽にルーツを持つ多くのジャンルで使われます。',
        try: 'ドミナントセブンスコード(I7, IV7, V7)の上で、b5のブルーノートを効果的に使ってみましょう。感情に訴えるフレーズが生まれます。',
        theory: '構成音はR-b3-4-b5-5-b7。マイナーペンタにb5の音を追加した6音階です。'
      }
    }
  },
  {
    id: 'harmonicMinor',
    categoryEn: 'Minor family',
    categoryJa: 'マイナー系',
    scaleEn: 'Harmonic Minor',
    scaleJa: 'ハーモニックマイナー',
    degrees: ['R', '2', 'b3', '4', '5', 'b6', '7'],
    intervals: [0, 2, 3, 5, 7, 8, 11],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'Adds a dramatic, passionate tension, reminiscent of classical music, to the melancholy of a minor scale.',
        use: 'A highly distinctive sound frequently used in classical, heavy metal, tango, and gypsy jazz.',
        try: 'Use this scale over the dominant chord (V7) in a minor key to instantly create a passionate and powerful progression.',
        theory: 'Composed of R-2-b3-4-5-b6-7. The key feature is the major 7th, which is a half step higher than in natural minor. It fits perfectly over a V7(b9) chord.'
      },
      ja: {
        vibe: 'マイナーの哀愁に、クラシック音楽のようなドラマチックで情熱的な緊張感を加えた響きです。',
        use: 'クラシック、ヘヴィメタル、タンゴ、ジプシージャズで多用される、非常に特徴的なサウンドです。',
        try: 'マイナーキーのドミナントコード(V7)の上でこのスケールを使うと、一気に情熱的で力強い展開を作れます。',
        theory: '構成音はR-2-b3-4-5-b6-7。7度の音がナチュラルマイナーより半音高いのが特徴で、V7(b9)コードにフィットします。'
      }
    }
  },
  {
    id: 'melodicMinor',
    categoryEn: 'Minor family',
    categoryJa: 'マイナー系',
    scaleEn: 'Melodic Minor',
    scaleJa: 'メロディックマイナー',
    degrees: ['R', '2', 'b3', '4', '5', '6', '7'],
    intervals: [0, 2, 3, 5, 7, 9, 11],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'A smooth and sophisticated sound, despite being minor. It creates particularly beautiful ascending melody lines.',
        use: 'Essential knowledge for jazz improvisation. Also frequently used in modern R&B and fusion.',
        try: 'Use it over the tonic minor chord (Im). It will create an Im(maj7) sound, which is urban and has a floating quality.',
        theory: 'Composed of R-2-b3-4-5-6-7. It\'s the natural minor scale with a raised 6th and 7th. In jazz, it\'s often used in this form for both ascending and descending lines.'
      },
      ja: {
        vibe: 'マイナーでありながら、滑らかで洗練された響き。特に上昇するメロディラインが美しいスケールです。',
        use: 'ジャズのインプロヴィゼーションでは必須の知識。現代的なR&Bやフュージョンでも多用されます。',
        try: 'マイナーキーのトニックコード(Im)の上で使ってみましょう。Im(maj7)という、都会的で浮遊感のある響きを生み出します。',
        theory: '構成音はR-2-b3-4-5-6-7。ナチュラルマイナーの6度と7度を半音上げた形。ジャズでは下降時もこのまま使うことが多いです。'
      }
    }
  },
  {
    id: 'dimWholeHalf',
    categoryEn: 'Symmetrical',
    categoryJa: '対称系',
    scaleEn: 'Diminished Scale (Whole–Half)',
    scaleJa: 'ディミニッシュド（全–半）',
    degrees: ['R', '2', 'b3', '4', 'b5', 'b6', '6', '7'],
    intervals: [0, 2, 3, 5, 6, 8, 9, 11],
    tones: 8,
    heptatonic: false,
    comments: {
      en: {
        vibe: 'A thrilling, mechanical sound with a regular pattern. An intellectual, cool tension, like a puzzle or a spy movie.',
        use: 'The go-to scale for improvising over diminished 7th (dim7) chords in jazz and fusion.',
        try: 'Use it over a passing dim7 chord that connects two other chords. Its regular pattern makes it easy to create fast phrases.',
        theory: 'Composed of R-2-b3-4-b5-b6-6-7. An eight-note (octatonic) scale with an alternating pattern of whole (W) and half (H) steps.'
      },
      ja: {
        vibe: '規則正しく音が並ぶ、スリリングで機械的な響き。パズルやスパイ映画のような、知的でクールな緊張感です。',
        use: 'ジャズやフュージョンで、ディミニッシュセブンスコード(dim7)の上でアドリブをする際の定番スケールです。',
        try: 'コードとコードを繋ぐ経過的なdim7コードの上で使ってみましょう。規則的なので、速いフレーズも作りやすいです。',
        theory: '構成音はR-2-b3-4-b5-b6-6-7。全音(W)と半音(H)が交互に並ぶ8音階(Octatonic)です。'
      }
    }
  },
  {
    id: 'dimHalfWhole',
    categoryEn: 'Symmetrical',
    categoryJa: '対称系',
    scaleEn: 'Diminished Scale (Half–Whole)',
    scaleJa: 'ディミニッシュド（半–全）',
    degrees: ['R', 'b2', 'b3', '3', '#4/b5', '5', '6', 'b7'],
    intervals: [0, 1, 3, 4, 6, 8, 9, 10],
    tones: 8,
    heptatonic: false,
    comments: {
      en: {
        vibe: 'Also symmetrical and tense, but sounds more bluesy and funky than its WH counterpart. A cool sound with a hint of heat.',
        use: 'Used over dominant 7th chords in jazz, fusion, and funk. An alternative source of tension to the Altered scale.',
        try: 'Use it over a V7(b9) chord. You can create tense phrases that feel a little more "inside" and cooler than the Altered scale.',
        theory: 'Composed of R-b2-#2-3-#4-5-6-b7. An eight-note (octatonic) scale with an alternating pattern of half (H) and whole (W) steps.'
      },
      ja: {
        vibe: 'こちらも対称的で緊張感がありますが、WHよりもブルージーでファンキーな響き。クールな中に少し熱さを感じさせます。',
        use: 'ジャズ、フュージョン、ファンクで、ドミナントセブンスコードの上で使われます。Alteredとは違う緊張感の選択肢になります。',
        try: 'V7(b9)コードの上で使ってみましょう。Alteredスケールよりも少しだけ「インサイド」な、クールな緊張感のフレーズが作れます。',
        theory: '構成音はR-b2-#2-3-#4-5-6-b7。半音(H)と全音(W)が交互に並ぶ8音階(Octatonic)です。'
      }
    }
  },
  {
    id: 'lydianb7',
    categoryEn: 'Advanced',
    categoryJa: '高度',
    scaleEn: 'Lydian b7',
    scaleJa: 'リディアン♭7（リディアンドミナント）',
    aliasEn: ['Lydian Dominant'],
    degrees: ['R', '2', '3', '#4', '5', '6', 'b7'],
    intervals: [0, 2, 4, 6, 7, 9, 10],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'A modern, intelligent sound that merges the floating quality of Lydian with the bluesiness of Mixolydian. Like a gifted but quirky student.',
        use: 'A highly sophisticated sound frequently used in modern jazz and fusion, famously by guitarists like Scott Henderson.',
        try: 'Use it over dominant chords that aren\'t the main V7, such as a IV7 or a bVII7, to create a non-resolving, floating dominant sound.',
        theory: 'Composed of R-2-3-#4-5-6-b7. The 4th mode of the melodic minor scale. Also known as the Lydian Dominant scale.'
      },
      ja: {
        vibe: 'Lydianの浮遊感とMixolydianのブルース感が融合した、現代的で知的な響き。少しひねくれた優等生のようです。',
        use: 'モダンジャズやフュージョンで多用される、非常に洗練されたサウンド。ギタリストのスコット・ヘンダーソンなどが有名です。',
        try: 'V7以外のドミナントコード、例えばIV7やbVII7の上で使ってみましょう。解決しない、浮遊したままのドミナントサウンドを作れます。',
        theory: '構成音はR-2-3-#4-5-6-b7。メロディックマイナーの4番目のモード。Lydian Dominantとも呼ばれます。'
      }
    }
  },
  {
    id: 'mixolydianb6',
    categoryEn: 'Advanced',
    categoryJa: '高度',
    scaleEn: 'Mixolydian b6',
    scaleJa: 'ミクソリディアン♭6',
    degrees: ['R', '2', '3', '4', '5', 'b6', 'b7'],
    intervals: [0, 2, 4, 5, 7, 8, 10],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'A scale that adds a drop of minor-key sorrow to the bluesy Mixolydian. A poignant sound, like a sunset.',
        use: 'Used in blues, jazz, and soul to add depth and a unique "cry" to melodies.',
        try: 'Use it over the V7 chord in a major key blues. The b6 (or b13) note will add a gut-wrenching melancholy to your phrases.',
        theory: 'Composed of R-2-3-4-5-b6-b7. The 5th mode of the melodic minor scale. It fits perfectly over a 7(b13) chord.'
      },
      ja: {
        vibe: 'ブルージーなMixolydianに、マイナーキーのような哀愁を一滴加えた音階。夕暮れのような、切ない響きです。',
        use: 'ブルースやジャズ、ソウルで、メロディに深みと独特の「泣き」を与えたい時に使われます。',
        try: 'メジャーキーのブルースで、V7コードの上で使ってみましょう。b6(=b13)の音が、フレーズにグッとくる哀愁を加えます。',
        theory: '構成音はR-2-3-4-5-b6-b7。メロディックマイナーの5番目のモード。7(b13)コードに完璧にフィットします。'
      }
    }
  },
  {
    id: 'phrygDominant',
    categoryEn: 'Advanced',
    categoryJa: '高度',
    scaleEn: 'Phrygian Dominant',
    scaleJa: 'フリジアンドミナント',
    aliasEn: ['Spanish Phrygian'],
    degrees: ['R', 'b2', '3', '4', '5', 'b6', 'b7'],
    intervals: [0, 1, 4, 5, 7, 8, 10],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'Passionate and exotic. A highly dramatic sound reminiscent of Spanish flamenco or a Middle Eastern desert.',
        use: 'Heavily used in gypsy jazz, flamenco, and neoclassical metal. Its strong character instantly grabs the listener\'s ear.',
        try: 'Play this scale over the dominant chord (V7) in a minor key. For example, using it over an E7 in the key of A minor creates an instant passionate vibe.',
        theory: 'Composed of R-b2-3-4-5-b6-b7. The 5th mode of the harmonic minor scale. It fits perfectly over a V7(b9, b13) chord.'
      },
      ja: {
        vibe: '情熱的でエキゾチック。スペインのフラメンコや、中東の砂漠を思わせる、非常にドラマチックな響きです。',
        use: 'ジプシージャズ、フラメンコ、ネオクラシカルメタルで多用されます。聴き手の耳を惹きつける強烈な個性を持っています。',
        try: 'マイナーキーのドミナントコード(V7)の上でこのスケールを弾いてみましょう。AmキーのE7上で弾くと、一気に情熱的な雰囲気になります。',
        theory: '構成音はR-b2-3-4-5-b6-b7。ハーモニックマイナースケールの5番目のモード。V7(b9, b13)コードに完璧にフィットします。'
      }
    }
  },
  {
    id: 'altered',
    categoryEn: 'Advanced',
    categoryJa: '高度',
    scaleEn: 'Altered',
    scaleJa: 'オルタード（スーパー・ロクリアン）',
    aliasEn: ['Super‑Locrian'],
    degrees: ['R', 'b2', '#2', '3', 'b5', 'b6', 'b7'],
    intervals: [0, 1, 3, 4, 6, 8, 10],
    tones: 7,
    heptatonic: true,
    comments: {
      en: {
        vibe: 'The ultimate tension. A chaotic, thrilling sound, as if a chord is about to break apart. The epitome of an "outside" sound.',
        use: 'The ultimate weapon used over dominant 7th chords in jazz to maximize tension before resolution.',
        try: 'Use it over the V7 in a II-V-I progression. Even the wildest phrases will sound correct when you resolve to the Imaj7.',
        theory: 'Composed of R-b2-b3-3-b5-#5-b7. The 7th mode of the melodic minor scale. It corresponds perfectly with a V7alt chord.'
      },
      ja: {
        vibe: '究極の緊張感。コードが崩壊する寸前のような、カオスでスリリングな響き。「アウトサイド」なサウンドの代表格です。',
        use: 'ジャズのドミナントセブンスコード上で、解決前の緊張感を最大にするために使われる最終兵器です。',
        try: 'ジャズのII-V-I進行で、V7の上で使ってみましょう。めちゃくちゃなフレーズを弾いても、次のImaj7に解決すれば全てが正解に聞こえます。',
        theory: '構成音はR-b2-b3-3-b5-#5-b7。メロディックマイナーの7番目のモード。V7altコードに完全対応します。'
      }
    }
  },
  {
    id: 'wholeTone',
    categoryEn: 'Advanced',
    categoryJa: '高度',
    scaleEn: 'Whole‑Tone Scale',
    scaleJa: 'ホールトーンスケール',
    degrees: ['R', '2', '3', '#4', '#5', 'b7'],
    intervals: [0, 2, 4, 6, 8, 10],
    tones: 6,
    heptatonic: false,
    comments: {
      en: {
        vibe: 'A strange, floating sound, like drifting in a dream. An ambiguous and fantastical world with no sense of landing.',
        use: 'Used in impressionistic classical music (like Debussy), flashback scenes in movies, and jazz solos to create a floating effect.',
        try: 'Use it over an augmented (aug) or 7(#5) chord. When used like a sound effect, it can effectively signal a scene change.',
        theory: 'Composed of R-2-3-#4-#5-b7. A six-note symmetrical scale where all intervals are whole tones.'
      },
      ja: {
        vibe: '夢の中を漂うような、フワフワした不思議な響き。どこにも着地しない、曖昧で幻想的な世界観です。',
        use: 'ドビュッシーなどの印象派クラシックや、映画の回想シーン、ジャズのソロで浮遊感を出すために使われます。',
        try: 'オーギュメントコード(aug)や7(#5)コードの上で使ってみましょう。効果音のように使うと、場面転換を効果的に演出できます。',
        theory: '構成音はR-2-3-#4-#5-b7。全ての音程が全音(Whole Tone)で構成された6音階。対称的なスケールです。'
      }
    }
  }
];

// Helper functions
export function getScaleById(id: ScaleId): ScaleMeta | undefined {
  return SCALE_MASTER.find(scale => scale.id === id);
}

export function getScalesByCategory(category: ScaleCategory): ScaleMeta[] {
  return SCALE_MASTER.filter(scale => scale.categoryEn === category);
}

export function getAllCategories(): ScaleCategory[] {
  return Array.from(new Set(SCALE_MASTER.map(scale => scale.categoryEn)));
}

export function getScaleDisplayName(scale: ScaleMeta, locale: 'en' | 'ja' = 'en'): string {
  if (locale === 'ja') {
    return scale.scaleJa;
  }
  return scale.scaleEn;
}

export function getCategoryDisplayName(category: ScaleCategory, locale: 'en' | 'ja' = 'en'): string {
  const categoryMap = {
    'Basic': '基本',
    'Modes': 'モード',
    'Pentatonic & Blues': 'ペンタ＆ブルース',
    'Minor family': 'マイナー系',
    'Symmetrical': '対称系',
    'Advanced': '高度'
  };
  
  if (locale === 'ja') {
    return categoryMap[category] || category;
  }
  return category;
}

