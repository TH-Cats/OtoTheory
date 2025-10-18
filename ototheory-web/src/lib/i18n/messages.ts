export const messages = {
  en: {
    nav: {
      chordProgression: 'Chord Progression',
      findChords: 'コードを探す',
      chordLibrary: 'コード辞典',
      resources: 'Resources',
    },
    actions: { analyze: 'Analyze' },
    chordLibrary: {
      title: 'Chord Library',
      sub: '',
      quality: 'コードタイプ:',
      showAdvanced: 'Show Advanced',
      hideAdvanced: 'Hide Advanced',
      display: 'Display:',
      finger: 'Finger',
      roman: 'Intervals',
      note: 'Note',
      tip: 'Tip: Forms with × on 1st or 6th string should not be strummed there, or lightly muted with your fretting hand.',
      // UX simplified: value props & help
      benefits: [
        'Chord forms that inspire composition and arranging',
        'Visual learning: see chord tones/intervals at a glance',
        'Try fast: play/arp with one click',
      ],
      // Interactive cards for detailed explanations
      cards: [
        {
          title: '🎯 How to Use',
          description: 'Simply select a root note and chord type to display various chord forms. Switch between detailed information using "Finger", "Intervals", and "Note Names" buttons.',
        },
        {
          title: '🎵 Practical Chord Forms',
          description: 'Carefully selected forms useful for composition and arranging, including open chords, 6/5/4 string roots, and triads (high/mid range). Quickly compare forms that fit your song\'s flow.',
        },
        {
          title: '👁️ Visualization & Audio Preview',
          description: 'Shows chord tones and intervals in the top-left. Visualize on the fretboard using "Intervals" and "Note Names" buttons. Preview audio with Play/Arp and save to chord progression slots with right-click.',
        },
      ],
      tryNow: '',
      detailsSummary: 'Open details (How to use · Visuals · More)',
      info: {
        fingerHelp: '1 Index, 2 Middle, 3 Ring, 4 Pinky, T Thumb',
        romanHelp: 'Intervals view (Root=1, Major 3rd=3, Minor 7th=b7, etc.)',
        noteHelp: 'Shows actual note names on the fretboard',
      },
      details: {
        how: {
          title: 'How to Use',
          bullets: [
            'Select a root and a quality',
            'Use buttons to show Finger / Intervals / Note names',
          ],
        },
        forms: {
          title: 'Practical Forms',
          bullets: [
            'Open, root on 6/5/4 strings, Triad (upper/middle)',
            'Quickly compare forms that fit your song',
          ],
        },
        visual: {
          title: 'Visual Learning',
          bullets: [
            'Chord tones and intervals shown at top-left',
            'Use Intervals/Note Names to visualize on fretboard',
          ],
        },
        more: {
          title: 'More',
          bullets: [
            'Play/Arp to hear voicing; right-click to add to progression slots',
          ],
        },
      },
    },
    chordBuilder: {
      proOnlyToast: 'Pro only: This chord type can\'t be added. Get iOS Pro for unlimited + MIDI.',
      proOnlyToastCta: 'Get Pro',
      eleventhWarning: '11 clashes with the 3rd on maj/dom. Consider #11 or sus4.',
    },
  },
  ja: {
    nav: {
      chordProgression: 'コード進行',
      findChords: 'コードを探す',
      chordLibrary: 'コード辞典',
      resources: 'リソース',
    },
    actions: { analyze: '分析' },
    chordLibrary: {
      title: 'Chord Library',
      sub: '',
      quality: 'コードタイプ:',
      showAdvanced: '高度なフォームを表示',
      hideAdvanced: '高度なフォームを隠す',
      display: '表示:',
      finger: '指番号',
      roman: '度数',
      note: '音名',
      tip: 'ヒント：1弦または6弦に×が付くフォームは、その弦を弾かないか、左手で軽くミュートしてください。',
      // UX簡素化: 価値訴求とヘルプ
      benefits: [
        '作曲やアレンジのヒントになるフォームを紹介',
        '視覚で理解: 構成音/度数を一目で確認',
        'すぐ試せる: ワンクリックで再生・アルペジオ',
      ],
      // インタラクティブカード（詳細説明用）
      cards: [
        {
          title: '🎯 使い方',
          description: 'ルート音とコードタイプを選択するだけで、様々なコードフォームが表示されます。「指」「度数」「音名」ボタンで詳細情報を切り替えられます。',
        },
        {
          title: '🎵 実用的なコードフォーム',
          description: 'オープンコード、6/5/4弦ルート、トライアド（高/中域）など、作曲やアレンジに役立つフォームを厳選。曲の流れに合うフォームを素早く比較できます。',
        },
        {
          title: '👁️ 視覚化と音の確認',
          description: '左上に構成音と度数を表示。「度数」「音名」ボタンでフレット上に可視化できます。Play/Arpで音を確認し、右クリックでコード進行スロットへ保存できます。',
        },
      ],
      tryNow: '',
      detailsSummary: '詳しい説明を開く（使い方・視覚化・その他）',
      info: {
        fingerHelp: '①人差し指 ②中指 ③薬指 ④小指 T親指',
        romanHelp: '度数表示（ルート=1、長3度=3、短7度=b7 など）',
        noteHelp: 'フレットボード上の実際の音名を表示します',
      },
      details: {
        how: {
          title: '使い方',
          bullets: [
            'ルート音とコードタイプを選ぶだけ',
            '指/度数/音名はボタンで確認',
          ],
        },
        forms: {
          title: '実用フォーム',
          bullets: [
            'オープン、6/5/4弦ルート、トライアド（高/中域）を表示',
            '曲の流れに合うフォームを素早く比較できます',
          ],
        },
        visual: {
          title: '視覚的に理解',
          bullets: [
            '左上に構成音と度数を表示',
            '「度数」「音名」ボタンでフレット上に可視化',
          ],
        },
        more: {
          title: 'その他',
          bullets: [
            'Play/Arpで音を確認、右クリックで進行スロットへ保存',
          ],
        },
      },
    },
    chordBuilder: {
      proOnlyToast: 'Pro専用：このコードタイプは追加できません。iOS Proで無制限＋MIDI出力。',
      proOnlyToastCta: 'Proを入手',
      eleventhWarning: '11はmaj/domでは3rdと衝突しがち。#11またはsus4を検討',
    },
  },
} as const;

export type Locale = keyof typeof messages;

