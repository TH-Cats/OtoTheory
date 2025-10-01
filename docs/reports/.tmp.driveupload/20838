# M0/M1 実装レポート

## 概要
v3-M0/M1の実装進行状況を記録。最小差分で実装を進め、毎回の更新を簡潔にまとめる。

## M0 実装状況 (2024-10-01 完了)
- **ブランチ**: `feat/v3-m0-baseline` 作成済み
- **コミット**: `feat(v3-m0): progression-first UI, two-layer overlay, Capo Top2 (Shaped), non-hepta rules, minimal telemetry`
- **実装内容**:
  - `/progression` ページ新規作成（2カード構成）
  - ResultCardをM0仕様に更新（ヘッダ/Key/Scale、ボディ/Diatonic→Fretboard→CapoFold）
  - DiatonicTableをOpen行のみ選択可能に制限
  - Fretboard二層Overlay（Scale層=輪郭/小/無地、Chord層=塗り/大/ラベル）
  - CapoFold新規作成（Top2/Shaped/無音/注記表示）
  - 非ヘプタ対応（Roman非表示・Diatonic=Open限定・Capo行disabled）
  - Analyze UI非表出設定（Melody/Solo Analyze）
  - Telemetry7イベント配線（1操作=1発火）

## M0 追加実装 (完了)
### A. src/app/progression/page.tsx 更新済み
- OverlayProviderで包む
- ヘッダを「Select Key & Scale」に変更

### B. src/state/overlay.ts 更新済み
- React Contextベースに変更
- 二層Overlayの単一ソース（Scale/Chord別管理）
- Reset=Chord層のみ、viewMode切替でfb_toggle発火
- overlay_shownはユーザ操作起因のみ

### C. src/components/ResultCard.tsx 更新済み
- ヘッダ体裁変更（Key/Scale≤3+%表示）
- 非ヘプタのRoman制御（isHeptatonic/isPentOrBlues判定）
- Capo折りたたみ配置

## M0 最終確認
- **二層Overlay**: Scale層=輪郭/小/無地、Chord層=塗り/大/ラベル ✓
- **Reset粒度**: Chord層のみ ✓
- **トグル最小**: Degrees/Namesのみ ✓
- **非ヘプタ対応**: Roman非表示・Diatonic=Open限定・Capo行disabled ✓
- **Capo提案**: Top2/Shaped/無音/注記表示 ✓
- **Telemetry**: 7イベント1操作=1発火 ✓

M0ベースライン完了。M1（Sketch/Playback/PNG）に移行可能。
