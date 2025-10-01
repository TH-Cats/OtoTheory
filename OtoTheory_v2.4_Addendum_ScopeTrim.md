# OtoTheory v2.4 Addendum – Scope Trim

**版:** 2.4 Addendum (Scope Trim)  
**日付:** 2025-09-26  
**対象:** v2.4 要件定義（Analyze 統合 / AudioSuggest / ToneOverlay / 基礎UI）  
**目的:** 代理コード（Substitute）および転調（Modulate）の実装を vNext へ移行し、リリース範囲をシンプルな Analyze 基盤に絞る。

---

## 1. スコープ整理

### 移行（Out → vNext）
- **Substitute（代理コード）**
  - 候補≤3＋短文アドバイス  
  - A/B 試聴／置換／Undo／プレビュー  
  - 💡ヒントボタン／ポップアップ  
  → **すべて削除／非表示**、設計は保持して vNext 検討へ。

- **Modulate（転調アドバイス）**
  - 候補≤3＋スコア式＋乗り換え一手表示  
  - プレビュー／一括置換／Free/Pro差分  
  → **すべて削除／非表示**、設計は保持して vNext 検討へ。

### 維持（In）
- **Analyze 基盤**
  - Key候補 ≤3＋%（録音/Chords入力/Key直指定）  
  - Scale選択（ヘプタ・非ヘプタ対応）  
  - Diatonic表（I〜VII × 行=Open/Capo…）  
  - Fretboard 二層 Overlay（Scale下地＋Chord強調、Reset=Chordのみ）  
  - Degrees/Names 切替  
  - Audio Suggest（録音→停止後解析、Worker化、Krumhansl法、Feature Flag管理）

- **Telemetry**
  - 維持：`diatonic_pick`, `play_note`, `play_chord`, `overlay_reset`, `overlay_shown`, `audio_record_start`, `audio_record_stop`, `audio_analyze_ok`  
  - 削除：`substitute_*`, `modulate_*`, `hint_open`

- **Free/Pro**
  - Base体験は共通。広告は Free のみ。  
  - 深い分析（代理コード/転調）は Pro 専用機能候補として vNext。

---

## 2. UI の修正方針
- Diatonic：**表形式のチップのみ**。  
  - クリック → 軽ストラム再生＋Chord層強調  
  - Reset → Chord層解除（Scale下地は残る）  
  - Degrees / Names 切替は即時反映
- Resultカード：**Substitute / Modulate セクションを撤去**  
- ヘッダやReference内リンクも「Coming soon」表記に差し替え

---

## 3. QA / DoD（更新版）
- Key候補 ≤3＋% が表示され、タップで一括反映できる  
- Scale切替で Diatonic表が更新され、列ズレがない  
- Diatonicチップクリック → 音が鳴り、指板にChord層が強調（Resetで解除、Scale下地は残る）  
- Degrees / Names 切替が即時反映される  
- 録音→停止後解析→Key候補（≤3＋%）表示（Feature Flag ON時）  
- Telemetry：  
  - `diatonic_pick`, `play_note`, `play_chord`, `overlay_reset`, `audio_record_start`, `audio_record_stop`, `audio_analyze_ok`  
  - **すべて 1操作=1発火**

---

## 4. 今後の検討（vNext）
- Substitute：代理コード候補、アドバイス、プレビュー適用  
- Modulate：転調候補、プレビュー、一括置換、Pro解放  
- Reference：代理コード/転調の理論解説を追加

---

## 5. 変更履歴
- **2025-09-26:** v2.4 Addendum (Scope Trim) を発行。Substitute / Modulate を vNext に移動。
