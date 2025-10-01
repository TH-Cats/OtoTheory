# OtoTheory v3 — マイルストーン & 範囲（期日なし方式）

> **参照: v3.0 SSOT 正本**

---

## M0. Baseline（統合の土台）
- **Chord Progression を主導線**に統一
- 共通 Result カード: Key ≤3候補＋% → Scale → Diatonic → Fretboard 二層
- ToneOverlay 二層（Scale=輪郭/Chord=塗り）、Reset=Chordのみ解除
- Free 制限: 12コード上限／Undo=1／広告表示

## M1. Sketch Library（保存・呼び出し）
- 保存/呼び出し/自動保存（3秒アイドル）
- Free: 3件ローカル保存（LRU上書き or Pro誘導）
- Pro: 無制限クラウド同期
- 開いたら即ループ再生まで1タップ

## M2. Progression Lite 完了
- 12コード上限／Undo=直前1手／プリセット／自動ループ
- 単音/和音の再生（Attack≈4ms/Release≈120ms、最大6声）
- PNG/テキスト出力（背景既定＋テーマ自動反転）
- export_png Telemetry（必ず1回計測）

## M3. Find Chords 強化
- **Scale Table**: 各コードに 2–3 スケール＋Why一文＋Glossary＋短いアルペジオ試聴
- **Chord Forms**: Open / Barre 表示（Compactは vNext）
- **Capo 提案**: 折りたたみ内に Top2（Shaped）を提示。音は鳴らさず
- **基礎代理コード**: 代表2–3候補＋理由文、Add/Undo付き

## M4. Pro 追加機能
- **セクション編集**（Verse/Chorus/Bridge 等）
- **MIDI出力**（Chord Track＋セクションマーカー＋ガイドトーン）
- 他画面（Find Chords 等）からの「＋Add to progression」で即再生
- Sketch 無制限クラウド同期

## M5. Polish & Release
- PNG反転/背景の最終調整
- A11y: roving-tablist／focus-visible／色以外の手掛かり
- Telemetry 最終化: 各操作＝1発火。export_png / progression_play / project_save 等を計測
- QA: 非ヘプタ例外（Pent/Bluesのみ Roman 表示）、Capo注記（Shaped vs Sounding）

---

## スコープ整理

**In（v3）**
- Analyze統合（録音は除外して後回し）
- 音が鳴るUI／Scale Table／Chord Forms（Open/Barre）／Capo提案Top2
- Progression Lite/Pro／Sketch Library／PNG・MIDI 出力

**vNext以降**
- Substitute/Modulate 拡張
- Compactフォーム・多段Undo／Ear Training
- Score/TAB Export／ベース自動生成
- Melody→Chord Suggestion・学習モード
- **録音解析機能（Audio Analysis全般）**
- **モバイルアプリ版（React Native移植・iOS/Android配信）**

