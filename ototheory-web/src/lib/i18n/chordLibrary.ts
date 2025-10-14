import { usePathname } from 'next/navigation';

export type Locale = 'en' | 'ja';

export function useLocale(): Locale {
  const pathname = usePathname() || '/';
  return pathname.startsWith('/ja') ? 'ja' : 'en';
}

const tipMap: Record<string, string> = {
  'Versatile barre form for any key.': 'どのキーでも使える汎用的なバレー・フォーム。',
  'Light muting on 6th string with distortion.': '歪み時は6弦を軽くミュートすると締まった音に。',
  'Release grip briefly between measures to reduce fatigue.': '小節間で一瞬グリップを緩めて疲労を抑えます。',
  'Bright highs, great for arpeggios.': '高域が明るく、アルペジオに最適。',
  '1st string can be muted (x-?-?-?-?-x).': '1弦はミュート可（x-?-?-?-?-x）。',
  "Bright highs, clear voicing.": '高域が明るく、明瞭なボイシング。',
  "Mini form that won't muddy vocals.": 'ボーカルを濁らせないミニ・フォーム。',
  'Mute 5th & 6th strings.': '5・6弦はミュート。',
  'Mute 6th string.': '6弦はミュート。',
  'Open 1st rings beautifully.': '1弦の開放が美しく響きます。',
  'Thick low end.': '低域が太いサウンド。',
  '3rd fret on 1st can be muted if needed.': '必要に応じて1弦3フレットはミュート可。',
  'Top 3 strings cut through.': '上の3弦が抜ける音。',
  'Full strumming power.': 'ストロークで力強く鳴る。',
  'Rock foundation bright E.': 'ロックの基礎、明るいE。',
  'Fingerpicking friendly.': 'フィンガーピッキングに好相性。',
  'Top 3 string calm depth.': '上の3弦に落ち着いた深み。',
  'Gentle F (partial barre).': 'やさしいF（部分バレー）。',
  'Soft dissolve.': '柔らかな溶け方。',
  'Top 3 bright afterglow.': '上の3弦に明るい残響。',
  'Classic blues sound.': 'クラシックなブルースの響き。',
  'Wants to resolve to F.': 'Fへ解決したくなる緊張感。',
  'Bright dominant 7th.': '明るいドミナント7th。',
  'Top 3 strings ring clearly.': '上の3弦がクリアに鳴る。',
  'Easy open E7.': '簡単なオープンE7。',
  'Blues standard.': 'ブルースの定番。',
  'Full-bodied dominant.': '芯の太いドミナント。',
  'Adds tension.': '適度なテンションを追加。',
  'Fingerpicking-friendly 7th.': 'フィンガーピッキング向きの7th。',
  'Open strings resonate.': '開放弦が共鳴。',
  'Smooth minor 7th.': '滑らかなm7。',
  'Jazz and soul staple.': 'ジャズ／ソウルの定番。',
  'Mellow depth.': '穏やかな深み。',
  'Easy barre on 1st fret.': '1フレットのバレーが容易。',
  'One-finger wonder.': 'ワンフィンガーで鳴る。',
  'Dreamy resonance.': '夢見心地の共鳴。',
  'Dark, tight minor sound.': '引き締まったダークなマイナー。',
  'Balance low end with bass.': '低域はベースとバランスを取る。',
  'Thin mid-high focus lifts vocals.': '中高域を絞ってボーカルを持ち上げる。',
  'Jazz and soul foundation.': 'ジャズとソウルの礎。',
  'Relaxed, mellow vibe.': 'リラックスした柔らかな雰囲気。',
  'Bright 6th sound.': '明るい6thの響き。',
  'Jazz and vintage pop.': 'ジャズ／ヴィンテージポップ向き。',
  'Sweet resolution chord.': '甘い解決感。',
  'Classic dominant 7th sound.': 'クラシックなドミナント7th。',
  'Tension that wants to resolve.': '解決を求めるテンション。',
  'Blues and jazz staple.': 'ブルース／ジャズの定番。',
  'Jazzy, sophisticated M7 sound.': 'ジャジーで洗練されたM7。',
  'Common in R&B and neo-soul.': 'R&B／ネオソウルで一般的。',
  'Add light vibrato on high E for shimmer.': '1弦に軽いビブラートで煌びやかに。',
  'Tension → resolution pattern.': '緊張→解決のパターン。',
  'Use briefly in fast songs for impact.': '速い曲では短く使って効果的に。',
  'Floating feel (#5).': '浮遊感のある#5。',
  'Perfect for short accent moments.': '短いアクセントに最適。',
  'Anxious spice.': '不安げなスパイス。',
  'Insert for just one beat as bridge.': '1拍だけ挟むブリッジに。',
  'Subtle depth and calm.': '控えめな深みと落ち着き。',
  "Won't interfere with melody.": 'メロディを邪魔しにくい。',
  'Bright 6th chord.': '明るい6thコード。',
  'All high strings = barre.': '高音弦はまとめてバレー。',
  'Great for ending phrases.': 'フレーズの終止に好適。',
  'Sophisticated minor sound.': '洗練されたマイナー感。',
  'Bossa nova classic.': 'ボサノバの定番。',
  'Melancholic beauty.': '物憂げな美しさ。',
  'R&B and neo-soul favorite.': 'R&B／ネオソウルの人気形。',
  'Easy to transition from.': '移行が容易。',
  'Great for blues and funk.': 'ブルース／ファンクに好適。',
  'Easier fingering than E-shape.': 'Eフォームより押さえやすい。',
  'Soft dissolve M7.': '柔らかく溶けるM7。',
  'Perfect for ballads and city pop.': 'バラード／シティポップに最適。',
  'Build tension.': '緊張感を作る。',
  'Return to 3rd for clean resolution.': '3度へ戻してクリーンに解決。',
  '#5 for floating feel.': '浮遊感のある#5。',
  'Short accent moments.': '短いアクセントに最適。',
  'One-beat bridge.': '1拍のブリッジに。',
  'Arpeggio passage sounds elegant.': 'アルペジオのパッセージは上品に。',
  'Compact 7th voicing.': 'コンパクトな7thボイシング。',
  'Easy barre form.': 'バレーしやすい形。',
  'Simple 6th voicing.': 'シンプルな6thボイシング。',
  'Easy barre on top 4 strings.': '上位4弦のバレーが簡単。',
  'Mellow m7 sound.': '穏やかなm7。',
  'Jazz-friendly voicing.': 'ジャズ向きのボイシング。',
  'Soft M7 voicing.': '柔らかなM7ボイシング。',
  'Dreamy atmosphere.': '夢見心地の空気感。',
  'Suspended tension.': 'サスペンドの緊張感。',
  'Wants to resolve.': '解決へ向かう性質。'
};

const labelMap: Record<string, string> = {
  'Open': 'オープン',
  'Barre (E-shape)': 'バレー（Eフォーム）',
  'Barre (E-shape, m)': 'バレー（Eフォーム, m）',
  'Barre (E-shape, m7)': 'バレー（Eフォーム, m7）',
  'Barre (E-shape, 6)': 'バレー（Eフォーム, 6）',
  'Barre (E-shape, 7)': 'バレー（Eフォーム, 7）',
  'Barre (E-shape, M7)': 'バレー（Eフォーム, M7）',
  'Barre (E-shape, sus4)': 'バレー（Eフォーム, sus4）',
  'Barre (E-shape, aug)': 'バレー（Eフォーム, aug）',
  'Barre (E-shape, dim triad)': 'バレー（Eフォーム, dim）',
  'Barre (A-shape)': 'バレー（Aフォーム）',
  'Barre (A-shape, m)': 'バレー（Aフォーム, m）',
  'Barre (A-shape, 6)': 'バレー（Aフォーム, 6）',
  'Barre (A-shape, m6)': 'バレー（Aフォーム, m6）',
  'Barre (A-shape, m7)': 'バレー（Aフォーム, m7）',
  'Barre (A-shape, 7)': 'バレー（Aフォーム, 7）',
  'Barre (A-shape, M7)': 'バレー（Aフォーム, M7）',
  'Barre (A-shape, sus4)': 'バレー（Aフォーム, sus4）',
  'Barre (A-shape, aug)': 'バレー（Aフォーム, aug）',
  'Barre (A-shape, dim triad)': 'バレー（Aフォーム, dim）',
  'Compact (Top 4)': 'コンパクト（上位4弦）',
  'Compact (Top 4, m)': 'コンパクト（上位4弦, m）',
  'Compact (Top 4, 6)': 'コンパクト（上位4弦, 6）',
  'Compact (Top 4, m6)': 'コンパクト（上位4弦, m6）',
  'Compact (Top 4, 7)': 'コンパクト（上位4弦, 7）',
  'Compact (Top 4, m7)': 'コンパクト（上位4弦, m7）',
  'Compact (Top 4, M7)': 'コンパクト（上位4弦, M7）',
  'Compact (Top 4, sus4)': 'コンパクト（上位4弦, sus4）',
  'Compact (Top 4, aug)': 'コンパクト（上位4弦, aug）',
  'Compact (Top 4, dim)': 'コンパクト（上位4弦, dim）',
};

export function tTip(text: string, locale: Locale): string {
  if (locale === 'ja') return tipMap[text] || text;
  return text;
}

export function tLabel(text: string, locale: Locale): string {
  if (locale === 'ja') return labelMap[text] || text;
  return text;
}

export function tButton(text: 'Play'|'Arp', locale: Locale): string {
  if (locale === 'ja') return text === 'Play' ? 'Play' : 'Arp';
  return text;
}


