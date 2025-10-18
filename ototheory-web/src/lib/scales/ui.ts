export const UI_SCALES = [
  { label: 'Ionian (Major)',          value: { quality: 'major' as const, scale: 'Ionian' as const } },
  { label: 'Aeolian (Natural Minor)', value: { quality: 'minor' as const, scale: 'Aeolian' as const } },
  { label: 'Lydian',                  value: { quality: 'major' as const, scale: 'Lydian' as const } },
  { label: 'Mixolydian',              value: { quality: 'major' as const, scale: 'Mixolydian' as const } },
  { label: 'Major Pentatonic',        value: { quality: 'major' as const, scale: 'MajorPentatonic' as const } },
  // もしUIで採用する場合は下記を有効化して両ページで同順にしてください。
  // { label: 'Minor Pentatonic',        value: { quality: 'minor' as const, scale: 'MinorPentatonic' as const } },
  // { label: 'Blues',                   value: { quality: 'minor' as const, scale: 'Blues' as const } },
] as const;

export type UiScaleItem = typeof UI_SCALES[number];










