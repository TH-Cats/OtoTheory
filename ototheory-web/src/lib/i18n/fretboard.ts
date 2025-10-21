type Locale = 'ja' | 'en';

export function getFretboardLabel(type: 'degrees' | 'names', locale: Locale): string {
  const labels = {
    ja: {
      degrees: '度数',
      names: '音名',
    },
    en: {
      degrees: 'Degrees',
      names: 'Note Names',
    },
  };
  
  return labels[locale][type];
}

export function getFretboardTooltip(locale: Locale): string {
  const tooltips = {
    ja: 'クリックして表示を切り替え',
    en: 'Click to toggle display',
  };
  
  return tooltips[locale];
}
