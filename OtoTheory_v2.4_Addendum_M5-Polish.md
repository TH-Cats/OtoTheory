# OtoTheory v2.4 追補 — M5 / Polish（録音UI拡張・プレビュー・将来の可視化）

**版:** 2.4 Addendum (M5 / Polish)  
**日付:** 2025-09-25  
**対象:** Analyze 統合画面の録音UI拡張・プレビュー再生・Telemetry/DoD追補（仕様は v2.4 の範囲内）  
**SSOT:** 本追補は *v2.4 要件定義（MD/DOCX）* と *v2.3 Final（Scale/Flag/Telemetry/非ヘプタUI）* を前提に、**UI/UX 強化**のみを追加する。

---

## 1. 位置づけ / 影響範囲
- **対象機能**: 🎤Record タブ（Analyze / Input）と Result カード直下の操作群。  
- **既存仕様の維持**: 録音は *停止後解析（Worker化）*、既定長 **12s**、**最短4s / 最長20s**（UI調整可）、**上位2–3候補＋%** 提示。  
- **非影響**: 解析アルゴリズム（chroma→Krumhansl）、二層ToneOverlay、Free/Pro 境界は変更なし。

---

## 2. 録音UIの拡張（表示・操作）
**目的**: 録音中の状態と残り時間を視覚化し、操作の不安を減らす（Polish）。  
**方式**: 既存の MediaRecorder + 停止後解析に付随する UI 強化のみ。

### 2.1 UI 仕様
- **録音中インジケータ**: `● REC`（赤点の点滅）。
- **進行バー**: 残り時間のプログレス（**更新 ≤ 250ms**）。残り **≤3s** で Warning 色に切替。
- **残り秒数**: `00:12 → 00:00` のカウントダウン（`aria-live="polite"`）。
- **状態表示**: `idle / recording / processing` を明示（recording 時のみバー表示）。
- **A11y**: `aria-pressed` の適用、Space/Enter で開始/停止。

### 2.2 設定 / 露出
- **既存 Flag**: `NEXT_PUBLIC_FEATURE_AUDIO_SUGGEST`（Record タブ露出）。
- **新規 ENV**: `NEXT_PUBLIC_AUDIO_MAX_SEC` … UI の上限秒数（**既定 20**）。社内/βは **30** を許可。  
  *注: 本番の受入範囲は 4–20s のまま。*

### 2.3 DoD（受入）
- 録音中、赤点・プログレス・残り秒数が**同期**して表示される。
- 残り **≤3s** で色が変わる（終了予告）。
- `processing` 中も UI が**固まらない**（Workerで非ブロッキング）。

### 2.4 Telemetry（追加）
- `audio_record_len_sec`（実記録長）
- `recording_indicator_shown`（REC開始時1回）
- 既存: `audio_record_start / audio_record_stop / audio_analyze_ok` は継続。

---

## 3. 「最後のテイクを再生」プレビュー
**目的**: 録音結果をその場で試聴し、Key/Scale 推定と聴感の一致を確認。  
**方式**: 直前テイクの `Blob` を `AudioBufferSourceNode` で一発再生（新規録音で上書き）。

### 3.1 UI 仕様
- **ボタン**: `▶︎ Last take`（再生中は `⏹︎ Stop` にトグル）。
- **自動停止**: 新規録音開始でプレビューを止める。
- **フェード**: 既存 Attack/Release（3–5ms / 80–150ms）に準拠。

### 3.2 DoD（受入）
- 直前テイクが**必ず**再生でき、録音開始で**自動停止**。
- クリックノイズ無し（既定 Attack/Release を遵守）。

### 3.3 Telemetry（追加）
- `audio_playback_last_take`（1操作=1発火、長さms同梱）

---

## 4. 将来検討（Out）— 録音→音符化（可視化）
- **内容**: ピッチ輪郭の可視化（時間×半音の短冊/点）。スケール外音は薄赤。
- **最小要件**: 輪郭（↑→↓）＋着地（3rd/7th）マーキング＋ヒット率（Scale 内 %）。
- **位置**: Why/着地と連携し「どこが合って/外れているか」を視覚に反映。  
*注: 本項は v2.4 の範囲外。次期で扱う。*

---

## 5. 非機能（NFR）追補
- **30s 録音（社内検証）**でも Worker 解析で UI ブロックなし。
- 典型デバイスで **20s** 録音のデコード+PCP集約+相関が体感即時（Progress UI は常時稼働）。
- 既存 NFR（TTFI ≤ 2s / Overlay 再計算 ≤ 8ms・再描画 ≤ 16ms）を維持。

---

## 6. 受入基準（DoD） 追補まとめ
- 録音中インジケータ（赤点）と**進行バー**・**残り秒数**が同期、**≤3s** で色変化。
- `▶︎ Last take` で**直前テイクを試聴**でき、**再録音で自動停止**。
- 30s 録音は **社内/βのみ**（`NEXT_PUBLIC_AUDIO_MAX_SEC=30`）。本番受入は **4–20s**。

---

## 7. 実装メモ（軽量サンプル）
- 赤点: CSS `@keyframes` で 1s パルス。プログレスは `width: elapsed/dur*100%`。
- ENV 読み: `process.env.NEXT_PUBLIC_AUDIO_MAX_SEC ?? '20'`。
- 直前テイク再生: `AudioBufferSourceNode` を 1ショットで接続。録音開始で `.stop()`。

---

## 8. 変更履歴
- v2.4 Addendum 初版（M5 / Polish 追補） — 2025-09-25
