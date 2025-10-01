# OtoTheory Architecture (v2.3)

この文書は Phase 2（録音解析ブリッジ）に向けた現在の技術土台を 1 枚で概観します。

## Single Source of Truth（SSOT）
- `src/lib/scaleCatalog.ts`: 14 スケールの定義（`id`, `display.en`, `degrees`, `group`, `info`）。
- 参照方針:
  - UI は必ず `SCALE_CATALOG` を直接参照（Find Chords の `<select>`, Find Key の chips）。
  - ラベルは `display.en` を使用し、順序もカタログ順に統一。

## Pitch 導出（5/7/8 音対応）
- API: `src/lib/scales.ts`
  - `getScalePitchesById(rootPc, id)` — `scaleCatalog.degrees` → `DEGREE_TO_SEMITONE` → 12 音 PC 配列。
  - 旧来の `getScalePitches` からも内部で上記を優先使用（後方互換）。
- 導出経路: `SCALE_CATALOG` → `getScalePitchesById` → `Fretboard`。

## 非ヘプタ（5/8 音）出し分けポリシー
- 判定: `SCALE_CATALOG.find(s=>s.id===selScaleId).degrees.length === 7`。
- 7 音以外のスケール:
  - Roman 行は非表示（Find Key）。
  - Diatonic テーブルは Open 行のみ選択可能（Capo 行は `aria-disabled` + `pointer-events:none`）。
  - Find Chords の見出し直下にヒント文を表示。

## Fretboard 可視化
- Ghost ring（スケール下地）:
  - CSS: `.fret-dot--ghost`（色相保持: `currentColor` × `color-mix`）
  - 8 音密度対応: `.ghost--dense`（少し小さく・細く）を自動付与。
- Chord layer は濃色・大きめ・ラベル付き。Scale layer は薄色・小さめ・輪郭のみ。

## Telemetry（最小）
- ラッパ: `src/lib/telemetry.ts`
  - `track(ev, payload)` — `navigator.sendBeacon` → `/api/telemetry`（fallback: `fetch`）。
  - `console.debug('[ototelem]', rec)` を開発時に残す。
- API: `src/app/api/telemetry/route.ts`（`POST 200` を返却）。
- 配線（例）:
  - `key_pick` / `scale_pick` / `diatonic_pick` / `overlay_reset` / `overlay_shown` / `fb_toggle` など。

## Feature Flag
- env: `NEXT_PUBLIC_FEATURE_AUDIO_SUGGEST=false`
- util: `src/lib/feature.ts` — `isFeatureEnabled('audioSuggest')`
- 録音 UI は flag で非表示（hidden/非マウント）にし、コードのみ接続可能に。

## 録音 → 解析（ブリッジ案）
- 最小構成:
  - WebAudio で `MediaRecorder` → `audio/webm` | `audio/wav`（設定可能）。
  - ローカル解析（推奨）: On-Device の簡易ピッチトラッキング（YIN/ACF ベース）で概形抽出。
- 解析入出力:
  - 入力: 16kHz mono, 16-bit PCM（WAV）/ あるいは WebM/Opus を一旦 PCM に復元。
  - 出力: `[{ tMs: number, pc: 0..11, conf: 0..1 }]` の時系列。
- 指板オーバーレイとの接続:
  - 解析結果 → 出現頻度/ウィンドウ平均 → 代表キー/スケール候補 → 既存 UI に流用。

---
この文書は開発者向けの概要です。更新は PR ベースで行い、SSOT（scaleCatalog）や可視化ポリシーの差異が出ないように保守します。



