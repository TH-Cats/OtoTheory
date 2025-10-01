# OtoTheory 要件定義 v2.4 — Analyze統合 / 録音解析 / 音が鳴るUI / 転調・代理サジェスト（Final）

**版:** 2.4  
**日付:** 2025-09-25  
**対象:** Analyze 統合画面（Find Key/Scale + Find Chord 融合）／録音からのKey/Scale推定／音の再生（単音/和音）／Modulate（転調）・Substitute（代理）  
**オーナー:** あなた  
**実装:** Cursor（TS/React）  
**方針:** マイルストーン管理（期日なし）

---

## 0. TL;DR（今回の決定）
- **Analyze（統合）**：上部に *Chords / 🎤Record / Key&Scale* の3入力。下部は共通の結果カード（**Key候補＋% → スケール → Diatonic → Fretboard**）。  
- **録音（メロディ）→ Key/Scale**：停止後オフライン解析（chroma → Krumhansl）。**上位2–3候補＋%**で提示。  
- **音が鳴るUI**：フレット単音タップ＝短音、Diatonic/提案コードタップ＝和音（軽ストラム可）。  
- **機能追加**：① **Modulate（転調サジェスト）**、② **Substitute（代理コード）**。候補≤3・1行理由・ワンタップ反映・A/B試聴。  
- **Free/Pro**：ベース体験は共通、**深い表示/操作**（Top3・一括置換・A/B自動 等）をProで解放。  
- **Theory Provider**：現段階は **Default（Tonal+ルール）**のみ。**TonaIは未使用**だが、差し替え口を設置。  
- **スケジュール**：**マイルストーン型（M0–M5）**で運用、DoD達成で出荷可。

---

## 1. 目的 / 背景
- Find Key/Scale と Find Chord の**文法・見た目・操作**を統合し、**学ぶ→弾く**の移行コストをゼロにする。  
- 🎤メロディ録音からも**同じ結果カード**へ着地させ、**耳・目・指**で納得できる分析体験を完成させる。  
- 可視化は **ToneOverlay（二層）** を中核：**Scale＝輪郭/小/無地**＋**Chord＝塗り/大/ラベル**。**Reset＝Chordのみ解除**。

---

## 2. スコープ
### 2.1 In（v2.4）
- Analyze 統合（3入力 → 共通の結果カード）
- 🎤メロディ録音 → Key/Scale（停止後解析）
- Fretboard & Diatonic タップの**音再生**（単音/和音）
- Modulate（転調）・Substitute（代理）の**カード追加**
- Free/Pro 切り分け（深い表示/操作で差）

### 2.2 Out（次期以降検討）
- 鼻歌→TAB、演奏分析レポート、類似曲DB照合（小規模なExamplesは維持）

---

## 3. 画面・UX 仕様（Analyze）
- ページ骨格：`<main class="ot-page ot-stack">`、**2カード構成**  
  - **Card #1 – Analyze (Input)**：  
    入力チップ **[ Chords ] [ 🎤 Record ] [ Key&Scale ]**（roving-tablist、矢印/Home/End/Enter/Space対応）  
    - *Chords*：コード進行（1行=1セクション、Freeは12コードまで）  
    - *🎤Record*：録音開始/停止（Flagで露出制御）、録音後に解析実行  
    - *Key&Scale*：KeyとScaleを直接指定（Find Chordの入口を統合）
  - **Card #2 – Result**：  
    **Key候補（上位2–3＋%） → スケール選択 → Diatonic（I〜vii°） → Fretboard（ToneOverlay） → Why→Try→着地**  
- 非ヘプタ（例：Blues/MajPent 等）を選んだ場合は **Roman非表示**・**Diatonic Capo行は disabled**・**ヒント文**を表示。  
- トグル最小主義：**Degrees / Names** のみ。  
- カード角丸/縦リズム/色はデザイントークンに準拠（Light/Dark 両対応）。

---

## 4. 録音（🎤メロディ → Key/Scale）
### 4.1 方式
- `getUserMedia` + `MediaRecorder` で録音。**停止後**に解析（MVP）。  
- コーデック選択：`MediaRecorder.isTypeSupported` で **Opus優先 → AAC** フォールバック。  
- 既定の録音長：**12秒**（最短4秒／最長20秒、UIで調整可）。短すぎる場合は警告。  
- 解析は **Web Worker** で非ブロッキング実行。

### 4.2 解析アルゴリズム（MVP）
1) 音声デコード → 片チャネル化  
2) 0.1–0.2s 窓・50%ホップで **chroma（12次元ピッチクラス）** をフレーム計算  
3) 時間方向に**中央値/平均**で集約 → **グローバルPCP（12次元）**  
4) **Krumhansl–Schmuckler**：Major/Minorプロファイルを12半音回転し、相関最大の **Key/Mode** を取得  
5) **上位2–3候補＋%** をUIに表示（曖昧時はWhyに“曖昧要因”1文を付記）  
6) 選択Keyに基づき **Diatonic**（Triad/7th）と **ToneOverlay** を更新

> モード（Lydian/Mixo等）は判定を欲張らず、**ユーザー選択で切替**（下地のみ更新）。段階導入。

---

## 5. Fretboard & Audio（音が鳴るUI）
- **🔈ON/OFF**（初回タップで `AudioContext.resume()`）・**音量スライダー**（localStorage保存）  
- **単音**：タップ即発音（アタック3–5ms/リリース80–150ms、最大6声、voice stealing）  
- **和音**：一発同時 or **軽ストラム（10–20msディレイ）**  
- 再生中ノートは**視覚強調**（色/太枠）で音だけに依存しない  
- Phase1は **純正WebAudio（Oscillator/1ショット）**。Phase2でサンプル音色導入を検討。

---

## 6. Modulate（転調サジェスト）
- **入口**：Resultカード下部の「Modulate」サブカード  
- **候補≤3**（まずは *五度圏±1/±2*・*平行*・*同主* を得点化）  
- **スコア**（初期式）  
  `score = 0.4·FifthProximity + 0.2·(Parallel/Relative) + 0.2·CommonTones/Chords + 0.2·CadenceFit`  
- **出力**：`toKey/toMode/score` と **“乗り換え一手”**（V/新主、共通三和音、直行など）  
- **操作**：候補タップで**挿入**（Undo可）／短い**プレビュー再生**  
- **Free/Pro**：Free=Top1のみ／Pro=Top3＋**一括置換**（全該当箇所に適用）

---

## 7. Substitute（代理コード）
- **入口**：Diatonic 各コードの「…」または長押し相当から  
- **候補≤3**：  
  - 第1群＝**同機能**（T/SD/D内の代理：例 I ↔ I6/9, Imaj7 / V ↔ Vsus4→V）  
  - 第2群＝**tritone（bII7）**、**借用iv**、**二次ドミナント**（Freeでは第1群のみ表示）  
- **Fitメーター**：Diatonic=100 / 代理=80 / 副次=70 / 借用=60 / 外=30（目安）  
- **操作**：タップで置換、**A/B試聴**（置換前→置換後を2回）  
- **短文**：Why（なぜ効く）→Try（やる一手）→着地（3rd/7th）を自動生成（40字前後）

---

## 8. Free / Pro
- **共通（Free/Pro）**：Analyze 統合、🎤録音導線（Flag露出）、Key候補＋%（≤3）、スケール、Diatonic、ToneOverlay二層、**単発試聴**  
- **Pro**：  
  - Modulate：**Top3**＋**一括置換**  
  - Substitute：**候補拡張**（≤3）＋**Fit詳細**（代理/副次/借用区別）＋**A/B自動**  
  - 将来：ストラム/アルペジオ選択、連続プレビュー、ループ練習  
- **広告**：Resultカード直下 **Freeのみ**（Proは非表示）

---

## 9. ツール / ライブラリ
- **フレームワーク**：Next.js 14 + TypeScript（App Router, PWA可）  
- **理論**：**Tonal.js**（スケール・ダイアトニック・ローマ数字・移調）  
- **録音**：`getUserMedia` + `MediaRecorder`（Opus優先→AAC）  
- **解析（メロディ）**：**Meyda**（chroma 12次元）＋ **Krumhansl–Schmuckler** 相関  
- **音再生**：Web Audio API（`AudioContext`, `OscillatorNode` / `AudioBufferSourceNode`）  
- **UI可視化**：既存 **ToneOverlay**（Scale＝輪郭/小/無地、Chord＝塗り/大/ラベル、Reset＝Chordのみ解除）  
- **Feature Flag**：`NEXT_PUBLIC_FEATURE_AUDIO_SUGGEST`（録音導線をON/OFF）  
- **Telemetry**：`sendBeacon` 優先＋POSTフォールバック

> **TonaI**：現段階**未使用**。ただし **Theory Provider** で差し替え可能（§10）。

---

## 10. Theory Provider（差し替え口）
```ts
export interface TheoryProvider {
  findKeyFromChords(input: { chords: string[] }): Promise<KeyCandidate[]>;
  findKeyFromMelody(input: { pcp12: number[] }): Promise<KeyCandidate[]>;
  suggestSubstitutions(ctx: { key: string; mode: string; chord: string }): Promise<SubstituteSuggestion[]>;
  suggestModulations(ctx: { key: string; mode: string; progression?: string[] }): Promise<ModulationSuggestion[]>;
}

export const DefaultProvider: TheoryProvider = { /* Tonal + ルール + Krumhansl */ };
export const TonaIProvider: TheoryProvider = { /* 将来：外部推論で置換/併用 */ };
```
- **v2.4 は DefaultProvider のみ**を採用（TonaIは不使用）。  
- 将来は**アンサンブル**（一致→即決／乖離→上位3候補＋%）での併用を想定。

---

## 11. API / データ（内部）
```ts
type AnalysisInput =
  | { kind: 'chords'; chords: string[] }
  | { kind: 'melody'; audioBlob: Blob }
  | { kind: 'direct'; key: string; scaleId: string };

type KeyCandidate = { key: string; mode: string; confidence: number };
type DiatonicItem = { roman: string|null; chord: string; fit: number };

type ModulationSuggestion = {
  toKey: string; toMode: string; score: number;
  handoff: { type: 'VofNew'|'commonChord'|'direct'; chord: string; reason: string };
};

type SubstituteSuggestion = { from: string; to: string; reason: string; fit: number };

type PlaybackCmd =
  | { kind: 'note'; midi: number; durMs: number }
  | { kind: 'chord'; midis: number[]; style: 'hit'|'lightStrum' };
```

---

## 12. Telemetry
- 既存：`page_view, key_pick, scale_pick, diatonic_pick, overlay_shown, fb_toggle, overlay_reset`  
- 追加：`audio_record_start, audio_record_stop, audio_analyze_ok, play_note, play_chord, modulate_open, modulate_apply, substitute_open, substitute_apply`  
- ペイロード標準形：`{ page, control, value, keyPc, scaleId, ts }`（**1操作=1発火**）

---

## 13. 受け入れ基準（DoD 抜粋）
1) **Analyze統合**：3入力いずれも**同じ結果カード**（Key候補＋%→スケール→Diatonic→Fretboard）に着地  
2) **二層Overlay**：Scale=輪郭/小/無地＋Chord=塗り/大/ラベル、**Reset＝Chordのみ解除**、**Degrees/Names即時切替**  
3) **録音→Key候補**：停止後に**上位2–3候補（％付き）**が表示され、タップでUI全体が切替  
4) **音が鳴る**：フレット単音は100ms以内に発音／コード試聴はクリック無し・停止可  
5) **Modulate/Substitute**：候補≤3・1行理由・ワンタップ反映（Undo可）・A/B試聴が動作  
6) **非ヘプタ**：Roman非表示・Capo行disabled・ヒント文表示  
7) **A11y**：roving-tablist、フォーカスリング、色以外の手掛かりが機能

---

## 14. 非機能要件（NFR）
- **性能**：TTFI ≤ 2s、（テキスト進行）解析 ≤ 50ms/12コード、Overlay再計算 ≤ 8ms・再描画 ≤ 16ms（95%tile）  
- **安定**：録音解析はUIをブロックしない（Worker化）。例外時は安全に無効化してベース表示を維持。  
- **アクセシビリティ**：コントラスト ≥ 4.5、:focus-visible、視覚パターンでの冗長表現  
- **法務**：ユーザー入力のみ扱う。再生サンプルは自前収録 or CC0/商用可に限定。ログ/計測は同意に従う。

---

## 15. 既知のリスクと対処（確定）
- **録音の不確実性**：短尺/ノイズで精度低下 → **上位候補＋%**提示／Whyに曖昧要因を1文  
- **判定の過剰化**：モード過多・候補過多 → 常に**≤3**・短文・ワンタップ  
- **音クリック/レイテンシ**：初回 `resume()`、3–5msフェード、同時発音上限とノード再利用  
- **Free/Pro境界の曖昧**：深い操作だけPro（Top3・一括置換・A/B自動 等）に限定  
- **統合回帰**：共通クラス／トグル最小／Reset挙動を受入必須に固定

---

## 16. スケジュール（マイルストーン方式：期日なし）
**M0. Baseline（統合土台）**  
- Analyzeページ新設（2カード構成・共通クラス）／既存2ページから内部移行（URL互換）  
- 二層Overlay・Reset挙動・Degrees/Names即時切替の回帰

**M1. Playback（音が鳴る最小）**  
- 単音/和音一発・🔈トグル・音量永続・クリック対策

**M2. AudioSuggest（録音→Key/Scale）**  
- 停止後解析（chroma→Krumhansl）・Key候補＋%表示・結果カード連動

**M3. Substitute（代理コード・基本）**  
- 候補≤3＋Fit＋短文、ワンタップ置換・A/B試聴（Free=第1群のみ、Pro=拡張＋A/B自動）

**M4. Modulate（転調サジェスト・Lite→標準）**  
- Lite：五度/平行/同主＋“乗り換え一手”（Free=Top1、Pro=Top3）  
- 標準：共通音/和音の自動抽出をスコアに反映、**一括置換**を実装

**M5. Polish & Release**  
- 回帰/A11y/性能クリア、広告（Free）/非表示（Pro）確認、ドキュメント更新

---

## 17. 変更履歴（v2.3 → v2.4）
- Find Key/Scale と Find Chord を **Analyze** に統合（内部コンポーネント共通化）  
- 🎤録音導線（Flag露出）と停止後解析（Krumhansl）を追加  
- **音が鳴るUI**（単音/和音一発）を追加  
- **Modulate/Substitute** カードを追加（候補≤3・短文・ワンタップ反映）  
- **Theory Provider** を導入（TonaIは未使用／差し替え口のみ）  
