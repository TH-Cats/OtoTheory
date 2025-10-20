// M3.5: CTA related constants

export const APP_STORE_URL = 'https://apps.apple.com/app/ototheory';

export const CTA_MESSAGES = {
  header: 'Get iOS App',
  sticky: {
    title: 'Get Pro features on iOS',
    subtitle: 'MIDI • Sections • Unlimited',
    button: 'Get App',
  },
  footer: {
    title: 'Get the full experience on iOS',
    button: 'Download on App Store',
    features: '• Pro features: MIDI export, Section editing, Unlimited sketches',
  },
  toast: {
    limitWarn: '8+ chords recommended for better accuracy. Want unlimited? Get iOS Pro!',
    limitBlock: '12 chord limit reached (Web Lite). Upgrade to iOS Pro for unlimited!',
    sketchLimit: '3 sketch limit reached! Delete a sketch or upgrade to iOS Pro for unlimited sketches.',
    pngExport: 'PNG exported! Want MIDI export? Get iOS Pro for full DAW integration!',
    ctaButton: 'Get Pro',
  },
} as const;

export type CtaMessages = typeof CTA_MESSAGES;


