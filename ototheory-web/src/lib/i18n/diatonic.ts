type Locale = 'ja' | 'en';

export function getDiatonicLabel(degree: number, locale: Locale): string {
  const labels = {
    ja: {
      1: 'I',
      2: 'II',
      3: 'III',
      4: 'IV',
      5: 'V',
      6: 'VI',
      7: 'VII',
    },
    en: {
      1: 'I',
      2: 'II',
      3: 'III',
      4: 'IV',
      5: 'V',
      6: 'VI',
      7: 'VII',
    },
  };
  
  return labels[locale][degree as keyof typeof labels.ja] || degree.toString();
}

export function getDiatonicTooltip(degree: number, locale: Locale): string {
  const tooltips = {
    ja: {
      1: 'トニック（主音）',
      2: 'スーパートニック（上主音）',
      3: 'メディアント（中音）',
      4: 'サブドミナント（下属音）',
      5: 'ドミナント（属音）',
      6: 'サブメディアント（下中音）',
      7: 'リーディングトーン（導音）',
    },
    en: {
      1: 'Tonic',
      2: 'Supertonic',
      3: 'Mediant',
      4: 'Subdominant',
      5: 'Dominant',
      6: 'Submediant',
      7: 'Leading Tone',
    },
  };
  
  return tooltips[locale][degree as keyof typeof tooltips.ja] || '';
}
