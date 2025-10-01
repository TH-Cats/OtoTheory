# OtoTheory v2.4 Addendum — Audio Engine (Server Execution Policy)

- 版: 2.4 Addendum (Server Execution)
- 日付: 2025-09-28
- オーナー: あなた

## 目的
Essentia.js 利用について、クライアントバンドルではなくサーバ実行（B方針）を採用する。

## 決定事項
- Essentia.js はクライアントにバンドルせず、録音データをサーバ（/api/analyze, Vercel Functions 等）で処理する。
- サーバ側では Essentia または librosa により Key/Scale 推定を行う。
- フロントは「録音停止 → Blob送信 → 結果（Key/Scale候補＋％）」の流れのみを担当する。
- Feature Flag（NEXT_PUBLIC_FEATURE_KEY_ENGINE / NEXT_PUBLIC_FEATURE_CHORD_ENGINE）で legacy / essentia-js 切替を維持する。
- Conf% が低い場合のフォールバックAPI利用は将来の選択肢として残す（現状は NEXT_PUBLIC_FEATURE_SERVER_FALLBACK=false）。
- 法務観点からも「社外配布前にサーバ実行へ切替」の既定方針に合致。

## UI/UX への影響
- 録音UI（録音バー、Analyzing… 演出、Last take 再生バー）は既存仕様を維持。
- Resultカードには Key/Scale 候補（％付）と Conf% を表示。
- Tools（Diatonic/Fretboard）の動作に変更なし。

## 実装メモ
- API エンドポイント: POST /api/analyze
- 入力: 音声 Blob (webm/opus, aac)
- 出力: { keyCandidates, scaleCandidates, conf, pcp12?, chordBeats? }
- Telemetry: audio_analyze_conf を追加（engine, conf, keyPc, mode）。

## リスク/留意点
- Essentia.js は AGPLv3。商用配布前に法務確認が必要。
- サーバ実行により端末負荷は軽減するが、通信遅延の影響を受ける可能性あり。
- サーバコストとスケーラビリティを考慮する必要がある。
