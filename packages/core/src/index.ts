/**
 * @ototheory/core
 * OtoTheory共通ロジックパッケージ
 */

// Music Theory
export * from './music-theory';

// Chords (includes getDiatonicChords)
export * from './chords';

// Theory (Diatonic) - only export types and detailed functions
export { DiatonicChord } from './theory/diatonic';

// Analysis
export { analyzeProgression, type KeyCandidate } from './analysis/keyAnalysis';
export { scoreScales, type ScaleCandidate } from './analysis/scaleAnalysis';

// TODO: 以下のモジュールは順次追加
// export * from './scales';
// export * from './progressions';
// export * from './roman';

