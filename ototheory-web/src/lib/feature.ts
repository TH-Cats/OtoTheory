export const isFeatureEnabled = (k: 'audioSuggest'): boolean => {
  if (k === 'audioSuggest') return process.env.NEXT_PUBLIC_FEATURE_AUDIO_SUGGEST === 'true';
  return false;
};




