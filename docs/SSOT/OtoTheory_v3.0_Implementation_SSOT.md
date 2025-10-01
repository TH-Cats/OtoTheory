# OtoTheory v3.0 --- 実装要件定義（Implementation Requirements）

> 本書は **v3.0
> のSSOTに基づく実装向けドキュメント**です。v2.4系の文書は参照資料扱いとし、矛盾時は本書を優先します。

------------------------------------------------------------------------

## 0) TL;DR / ゴール

-   **メイン体験**を「Chord Progression」に統一。結果カード配下に
    *Diatonic→Fretboard（二層Overlay）→Patterns→Cadence→基礎代理*
    を並べ、いずれも「試聴→＋Add→即ループ再生」で動作させる。\
-   **Capo 提案**は折りたたみ内に
    **Top2（Shaped表記のみ）**、音は鳴らさない。*Shaped=fingered /
    Sounding=actual* 注記を常に併記。\
-   **非ヘプタ**は Roman 非表示・Diatonic=Open限定。**Pentatonic/Blues
    は Roman 例外表示**（欠落音は点線）。\
-   **保存単位**は
    "Sketch"。Free=ローカル3件、Pro=無制限クラウド同期。開くと即ループ再生できる。\
-   **出力**：Free=PNG/テキスト、Pro=MIDI（Chord
    Track＋セクションマーカー＋ガイドトーン）。PNG
    は背景既定＋テーマ自動反転、`export_png`
    は**保存成否に関わらず1回**送出。\
-   **ToneOverlay（二層）**：Scale=輪郭/小/無地、Chord=塗り/大/ラベル。Reset=Chordのみ。

------------------------------------------------------------------------

## 1) スコープ / 画面モジュール

### 1.1 Find Chords（キー/スケール → 使えるコード）

-   選択だけで
    **Diatonic（Openのみ選択可）→Fretboard（二層）**を即更新。トグルは
    **Degrees / Names** のみ。Resetは**Chord層のみ**解除。\
-   各ダイアトニック行に **Scale
    table（2〜3種＋Why一文＋ⓘGlossary＋短いアルペジオ）**、**基礎代理（Lite）**
    を搭載。\
-   Capo 提案（折りたたみ）は **Top2（Shaped）**のみ、**音出しなし**。\
-   非ヘプタ扱いルールを厳守（Roman 非表示、Capo 行 disabled。Pent/Blues
    例外）。

### 1.2 Melody/Solo Analyze（録音→Key/Scale｜βではUI非露出）

-   **Line-in 前提**。停止後 `/api/analyze` が **Key/Scale ≤3＋Conf%**
    を返却。低信頼時は再録ヒントを表示。（既定Flag OFF）\
-   結果カードは
    **Key候補→Scale→Diatonic（Open）→Fretboard（二層）**。録音由来に
    "From recording" バッジ。

### 1.3 Chord Progression（メイン｜Lite / Pro）

-   **結果＆ツール**：ヘッダに
    **Key/Scale（≤3＋%）＋Roman**（Pent/Blues例外）を表示。直下に
    **Diatonic＋Fretboard二層**、**Capo折りたたみ**、**Patterns/Cadence/基礎代理**（**試聴→＋Add
    を2タップ以内**）。\
-   **編集ツール**：削除／ドラッグ並べ替え／全リセット（Undo可）。**プリセット→自動ループ**。Lite=**12コード上限**（9--12警告、13ブロック＋Pro誘導）・Undo=**直前1手**。Proは**セクション編集＋MIDI出力**を追加。\
-   **他画面からの追加**：Find Chords→`＋Add to progression`
    で即挿入＆自動再生。

------------------------------------------------------------------------

## 2) 保存（Sketch Library）

-   **名称**："Sketch（ソングスケッチ）"。**進行＋Key/Scale＋Capo（Shaped）＋Fretboard表示**を一括保存。英UIは
    *Save as Sketch / My sketches*。\
-   **Free / Pro**：Free=**ローカル3件**（LRU上書きor
    Pro誘導）、Pro=**無制限クラウド同期**（オフラインはキュー→再接続マージ）。\
-   **スナップショット項目**（schema=sketch_v1）：`id/name/createdAt/updatedAt/appVersion`、採用中の
    Key/Scale、**Capo（capoFret +
    Shaped注記）**、**進行**（Lite上限/Proセクション）と
    **Fretboard表示（Degrees/Names, ガイド設定）**。\
-   **フロー**：Save→トースト、4件目は「上書き or Go Pro」。Open
    は最近順＋☆ピン・検索付き、**開いたら即ループまで1タップ**。自動保存は**3秒アイドル**or
    離脱時。\
-   **互換・注記**：非ヘプタの Roman 表示ポリシー、**Capoの
    Shaped/Sounding 注記**を出力・保存ともに明記。

------------------------------------------------------------------------

## 3) ToneOverlay と音の仕様

-   **二層ルール**：Scale 層=輪郭/小/無地、Chord
    層=塗り/大/ラベル。**Reset＝Chordのみ**。Degrees/Names は即時切替。\
-   **発音**：単音 Attack≒3--5ms /
    Release≒80--150ms、最大6声（voice-stealing）。和音は同時 or
    軽ストラム（10--20ms）。初回は Audio Unlocker。

------------------------------------------------------------------------

## 4) 出力 / 共有

-   **PNG（Free）**：背景（transparent/light/dark）既定＋**テーマ自動反転**。`export_png`
    は**保存成否に関わらず1回だけ**送出。\
-   **テキスト（Free）**：Key/Scale、Diatonic、進行（Roman/実音）、**Capo注記**をコピー可。\
-   **MIDI（Pro）**：**Chord Track＋セクションマーカー＋ガイドトーン**。

------------------------------------------------------------------------

## 5) Free / Pro 境界（アプリ内の振る舞い）

-   **Free**：Find Chords（Scale table / 二層 Overlay / Capo
    Top2）、Patterns/Cadence の **＋Add**、Progression
    Lite（12上限・プリセット・PNG/テキスト）、**Sketch=3件**。\
-   **Pro**：セクション進行、**MIDI出力**、Sketch無制限、将来の高度機能（近接ボイシング/Avoid/Tension/録音拡張）。

------------------------------------------------------------------------

## 6) テレメトリ（最小セット／イベント名はSSOT準拠）

-   共通：`page_view, key_pick, scale_pick, diatonic_pick, overlay_shown, fb_toggle, overlay_reset, play_note, play_chord, export_png`（**1操作=1発火**）。\
-   進行：`progression_play, preset_inserted, toast_shown(kind)`（limit_warn
    / limit_block / undo / low_conf）。\
-   保存：`save_project, open_project, project_rename, project_delete, project_duplicate, project_limit_warn, project_limit_block`。\
-   録音（将来露出）：`audio_record_start/stop, audio_analyze_ok, audio_analyze_conf(engine,conf)`。

------------------------------------------------------------------------

## 7) 受け入れ基準（DoD）

1.  **Find Chords**：Key/Scale 選択のみで Result 更新。Open
    行タップで**和音再生＋Chord層強調**。Reset は **Scale を保持**。\
2.  **Capo**：折りたたみ内に
    **Top2（Shaped）**＋注記。**音は鳴らさない**。\
3.  **Progression**：ドラッグ並べ替え／Undo（Lite=1手）／**プリセット→自動ループ**が動作。\
4.  **提案追加**：Patterns / Cadence / 基礎代理 は **試聴→＋Add
    が2タップ以内**、**直後に自動再生**。\
5.  **Sketch**：Key/Scale・Capo（Shaped）・進行・Overlay
    表示を**完全復元**。Free=3件、Pro=無制限。\
6.  **出力**：Free＝PNG/テキスト、Pro＝MIDI。PNG
    は背景既定＋テーマ反転、`export_png` は**必ず1回**。\
7.  **録音（Flag ON 時）**：Line-in
    のみ開始可。停止→**Key候補≤3＋Conf%**、低信頼は Advice。βでは UI
    非露出。

------------------------------------------------------------------------

## 8) データ / API / 永続化

### 8.1 Sketch スキーマ（`schema=sketch_v1`）

``` ts
type Sketch = {
  id: string; name: string; createdAt: string; updatedAt: string; schema: 'sketch_v1'; appVersion: string;
  key: { tonic: string; scaleId: string };
  capo: { capoFret: number; note: 'Shaped=fingered / Sounding=actual' };
  progression: Lite | Pro;
  fretboardView: { mode: 'Degrees'|'Names'; guide: boolean };
}
```

### 8.2 `/api/analyze`（β／録音UIは非露出）

-   **入力**：録音 Blob または PCP12（環境により）。\
-   **出力**：`{ keyCandidates: {key,mode,confidence}[] , conf, advice? }`。\
-   **Flag**：録音導線は既定OFF、将来ONに備えて Telemetry の `audio_*`
    を維持。

------------------------------------------------------------------------

## 9) UI/UX ルール（再掲）

-   **トグル最小**：Degrees / Names のみ。\
-   **非ヘプタ表示**：Roman 非表示、Capo 行は disabled、Pent/Blues のみ
    Roman 例外。欠落音は**点線○**。\
-   **Capo 注記**：*Shaped=fingered / Sounding=actual*
    を常に併記（出力・保存も）。

------------------------------------------------------------------------

## 10) 非機能要件（NFR）

-   **パフォーマンス**：Overlay 再計算 ≤ 8ms、再描画 ≤
    16ms（95%tile）／TTFI ≤ 2s。\
-   **A11y**：フォーカスリング、roving-tablist、色以外の手掛かり。\
-   **安定性**：録音解析は
    Worker/サーバで非ブロッキング、例外時はベース表示を維持。

------------------------------------------------------------------------

## 11) マイルストーン（DoD駆動）

-   **V3-M0｜ベース移行**：Chord Progression を中核に据えたUI骨格。Capo
    Top2（Shaped）折りたたみ。\
-   **V3-M1｜Sketch**：保存/呼び出し/自動保存（3秒）・LRU上書き・Pro同期・即ループ。\
-   **V3-M2｜Lite
    完了**：12上限/Undo1手/プリセット/自動ループ・PNG/テキスト出力・export_png
    Telemetry。\
-   **V3-M3｜Find Chords 強化**：Scale
    table（2〜3＋Why＋薄アルペジオ）、基礎代理の Add/Undo。\
-   **V3-M4｜Pro 追加**：セクション編集／MIDI 出力。\
-   **V3-M5｜Polish**：PNG反転/背景、A11y回帰、計測の最終化。

------------------------------------------------------------------------

## 12) リスク / 決めごと

-   **AGPL
    懸念（Essentia.js）**：商用配布は**サーバ実行（B方針）**で回避。\
-   **非ヘプタの整合**：Roman
    非表示・Capo無効・Pent/Blues例外をQAで検証。\
-   **Lite 制限の表現**：9--12警告/13ブロック＋Pro誘導のトーンを揃える。

------------------------------------------------------------------------

## 13) リポジトリ運用 / ファイル配置

-   **SSOT**：`docs/SSOT/OtoTheory_v3.0_SSOT.md`\
-   **実装要件**：`docs/SSOT/OtoTheory_v3.0_Implementation_SSOT.md`\
-   **レガシー**：v2.4 系は `docs/SSOT/legacy/` に移設。

------------------------------------------------------------------------

### 備考（非エンジニア向け）

-   **やることはシンプル**：①Chord Progression中心 →
    ②Diatonic＋Fretboard＋提案 → ③Add即ループ → ④Sketch保存。\
-   **迷ったらSSOT**：例外（Pent/Blues Roman・Capo Top2
    Shapedのみ等）だけ厳守すれば体験は自然に揃う。
