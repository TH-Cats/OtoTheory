# OtoTheory v2.4 Addendum — Audio Engine Plan (Key/Chord 精度向上)

**版:** 2.4 Addendum (Audio Engine)  
**日付:** 2025-09-28  
**対象:** v2.4 要件（Analyze 基盤：録音→解析→Result/Tools）  
**目的:** スマホ録音の **Key/Scale/Chord 判定精度** を上げつつ、将来の **MIDI/譜面/自動ベース** に無理なく拡張する。

---

## 1. 決定事項（Summary）
- **短期（本Addendum内で反映）**
  - **Essentia.js（WASM）** をクライアントの Key/Chord コアに採用。  
    - Key：HPCP＋KeyExtractor（**平均デチューニング補正**あり）。  
    - Chord：HPCP＋拍同期推定（ビート単位）を利用。  
  - 時間方向の**合議**（短チャンク多数決）＋**終止重み**（録音末尾に重み）。
  - 解析結果に **信頼度（Conf%）** を付与。低信頼のときは再録のヒントを表示。

- **中期（任意機能/段階導入）**
  - **フォールバックAPI**：Conf% が低い場合のみ **サーバ解析（Essentia / librosa）** を呼び、**安定した再判定**を返す（端末差の影響を回避）。
  - Chord 列の**時系列スムージング**（Viterbi）と **Key条件付き**（非ダイアトニック優先度ダウン）。

- **将来（vNext 構想）**
  - **Basic Pitch（音声→MIDI）** を併用して **譜面化/MIDIエクスポート/ベースライン提案** を提供（サーバ実行または高性能端末のみ）。

> ライセンス注意：Essentia.js は **AGPLv3**。商用リリース前に法務確認（別ライセンス/サーバ実行への切替等）を行う。

---

## 2. スコープと非スコープ
- **In（v2.4 Addendum）**
  - Key 判定：Essentia.js（HPCP＋KeyExtractor＋デチューニング補正）。
  - Chord 判定（ベースライン）：Essentia.js の拍同期クロマによる triad（maj/min）中心の推定。  
  - 合議＋終止重み、Conf% の算出と表示、再録ヒント文言。
- **Out（vNext）**
  - 7th/拡張和音のフルサポート（辞書拡張＋文法による段階導入）。
  - サーバ解析の常時利用（Conf% 低時のみフォールバック）。
  - Basic Pitch による MIDI/譜面/自動ベース生成。

---

## 3. 実装方針（非エンジニア向け）
### 3.1 Key 推定（Essentia.js）
- **やること**: 録音から HPCP を作り、**KeyExtractor** で **Key/Mode** を推定。**平均デチューニング補正**で A≠440Hz などのズレを吸収。  
- **ねらい**: 「半音隣に流れる」「倍音支配」の影響を軽減。端末差・騒音の影響を受けにくくする。

### 3.2 Chord 推定（Essentia.js＋拍同期）
- **やること**: ビート（拍）ごとに HPCP を代表化し、**拍単位で triad（maj/min）** を推定。  
- **注意**: 初期は triad を中心に安定化。7th 等は **辞書を段階的に追加**（後述）。

### 3.3 時間方向の合議＋終止重み
- **やること**: 0.5〜1.0s チャンクで Key/Chord を出し、**多数決**で最終決定。録音の**最後2秒**に**1.3〜1.5×重み**。  
- **ねらい**: 短い外れフレームに引っ張られない／人の演奏の自然な終止を反映。

### 3.4 Conf%（信頼度）と UX
- **Conf% の定義（例）**: 上位候補の差＋票の集中度から 0〜100% で出す。  
- **UX**: 低信頼では「**Uncertain**（もう少し長め／ルートで終えて録音）」を Result に表示。

### 3.5 録音設定の既定
- **getUserMedia**: `noiseSuppression=false, echoCancellation=false, autoGainControl=false`（音楽の倍音を守る）。  
- サンプリングレートは 44.1/48kHz を維持。

---

## 4. フィーチャーフラグ/設定
```
# エンジン切替
NEXT_PUBLIC_FEATURE_KEY_ENGINE=essentia-js   # legacy / ess-js
NEXT_PUBLIC_FEATURE_CHORD_ENGINE=essentia-js # legacy / ess-js

# サーバフォールバック（任意機能）
NEXT_PUBLIC_FEATURE_SERVER_FALLBACK=false    # true 時、低Conf%のみAPIへ
NEXT_PUBLIC_ANALYZE_API_BASE=https://...     # サーバURL
CONF_THRESHOLD_LOW=0.58                      # 例：この未満は不確実

# 録音とUI
NEXT_PUBLIC_AUDIO_MAX_SEC=20                 # 既定20s（社内/βで30s）
```

---

## 5. UI 変更（最小）
- **Result**（上段）:  
  - Key 候補（%）／Scale 候補（%）のみ。  
  - 録音由来は **“From recording”** バッジを表示。  
  - Conf% を見出し横に表示（例：**Confidence 82%**）。**低信頼**のときは「再録のコツ」をガイド。  
- **Tools**（下段）:  
  - Diatonic 表（クリックで音＋Chord層強調、Reset=Chordのみ）。  
  - Fretboard（二層 Overlay：Scale 下地＋Chord 強調）。  
  - Key/Scale 変更時は **“Updated”** バッジを 1.5s 表示（更新の見える化）。

---

## 6. Telemetry（追加/整理）
- 既存維持: `audio_record_start/stop`, `audio_analyze_ok`, `key_pick`, `scale_pick`, `diatonic_pick`, `play_chord`, `overlay_reset`。  
- 追加提案:  
  - `audio_analyze_conf` … Conf% と採用エンジン（ess-js/legacy/server）。  
  - `audio_conf_low_fallback` … 低信頼でサーバ再判定に送った場合。  
  - `chord_detect_ok` … 拍単位の推定件数と一致率（内部評価）。

> 目的：精度の実視化と、フォールバックの“効き”を把握。

---

## 7. 受入基準（DoD）
**環境**: iOS Safari / Android Chrome の実機、静音〜生活騒音レベルで検証。  
1. **Key**: スマホ録音の代表フレーズで **Top-1 正解率 ≥ 85%**、Top-2 ≥ 95%。  
2. **Mode**: 長短のブレが顕著に減る（既存比で誤判定 30% 以上減）。  
3. **Chord（triad）**: 1拍〜2拍単位の進行で、**明らかな外れ（半音隣・無関係調）**が大幅減。  
4. **Conf%**: 低信頼時に **分かりやすい再録ガイド**が表示される。  
5. **UX**: 解析は Worker で非ブロック。停止後 **Analyzing…** → Result へ自動スクロール。  
6. **Flag**: `essentia-js` を OFF に戻せば従来ロジックで動作。

> 数字はベンチの初期目標。実測で見直しOK。

---

## 8. リスク/留意
- **ライセンス**: Essentia.js は **AGPLv3**。配布形態/商用要件に応じて法務確認（別ライセンス/サーバ実行の選択肢）。  
- **パフォーマンス**: 端末依存（古い端末でCPU/電池を消費）。Conf%や録音長に応じて**フォールバックAPI**を用意。  
- **Chordの辞書**: 初期は triad 中心。7th/拡張は段階導入（辞書と遷移にバイアス）。

---

## 9. 将来計画（vNext）— 作曲支援へ
- **Basic Pitch（音声→MIDI）**：譜面化、**MIDI書き出し**、**ベースライン提案**（Key/Scale/Diatonic に沿った定番パターンの自動生成）。  
- **王道進行プリセット**：Result/Tools からワンタップで DAW に持ち込める **MIDI 進行**を提示。  
- **コード拡張**：7th/テンションの辞書を増やし、Viterbi の遷移に**ポピュラー文法**（五度圏/セカンダリドミナント）を反映。

---

## 10. ロールアウト手順
1) Feature Flag で **Essentia.js** を社内ON → 精度/CPU/電池を実測。  
2) Conf% と**再録ガイド文言**を調整。必要なら **終止重み**や**合議ウィンドウ**を微調整。  
3) ベータで **サーバフォールバック** を限定ON（プライバシー表記を明記）。  
4) リリース後に **MIDI系（Basic Pitch）** を段階導入。

---

## 付録：用語ざっくり
- **HPCP**: 周波数を 12音に畳み込んだ色（クロマ）。  
- **平均デチューニング補正**: 録音全体の“調律ズレ”を補正。  
- **拍同期**: ビート単位で代表化して推定。  
- **Viterbi**: 時系列の最尤系列を求める手法（ブレを平滑化）。

