export const messages = {
  en: {
    nav: {
      chordProgression: 'Chord Progression',
      findChords: 'Find Chords',
      chordLibrary: 'Chord Library',
      resources: 'Resources',
    },
    actions: { analyze: 'Analyze' },
    chordLibrary: {
      title: 'Chord Library',
      sub: 'Choose a Root and Quality to see 3 chord forms side by side with horizontal fretboard layout. Supports Eb, Ab, Bb and other practical keys. Hear them with ▶ Play (strum) and Arp (arpeggio).',
      quality: 'Quality:',
      showAdvanced: 'Show Advanced',
      hideAdvanced: 'Hide Advanced',
      display: 'Display:',
      finger: 'Finger',
      roman: 'Roman',
      note: 'Note',
      tip: 'Tip: Forms with × on 1st or 6th string should not be strummed there, or lightly muted with your fretting hand.',
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
      findChords: 'Find Chords',
      chordLibrary: 'Chord Library',
      resources: 'リソース',
    },
    actions: { analyze: '分析' },
    chordLibrary: {
      title: 'Chord Library',
      sub: 'ルートとクオリティを選ぶと、横向きのフレットボードで3つのフォームを並べて表示します。Eb, Ab, Bb など実用キーにも対応。▶ Play（ストラム）と Arp（アルペジオ）で音を確認できます。',
      quality: 'Quality:',
      showAdvanced: '高度なフォームを表示',
      hideAdvanced: '高度なフォームを隠す',
      display: '表示:',
      finger: '指番号',
      roman: 'ローマ',
      note: '音名',
      tip: 'ヒント：1弦または6弦に×が付くフォームは、その弦を弾かないか、左手で軽くミュートしてください。',
    },
    chordBuilder: {
      proOnlyToast: 'Pro専用：このコードタイプは追加できません。iOS Proで無制限＋MIDI出力。',
      proOnlyToastCta: 'Proを入手',
      eleventhWarning: '11はmaj/domでは3rdと衝突しがち。#11またはsus4を検討',
    },
  },
} as const;

export type Locale = keyof typeof messages;

