# OtoTheory v3.0 — システム構成 SSOT（正本）

> **この文書が最新版の"正本（Single Source of Truth）"です。** v2.4 系を含む旧版は参照資料とし、矛盾する場合は本書を優先します。非エンジニア向けに、画面・データ・ルールを一枚にまとめています。

---

## 0. 本版での主要決定（v2.4 からの差分だけ抜粋）

- **メインは「Chord Progression」**。決定後に使う"結果＆ツール群"を明示（Diatonic → Fretboard（二層 Overlay）→ Patterns → Cadence → 基礎代理）。どれも**ワンタップで追加→即ループ再生**に統一。
- **Capo 提案**は **Diatonic の折りたたみ**内に **Top2（Shaped 表記）のみ**。**音は鳴らさない**。注記は *Shaped=fingered / Sounding=actual* を併記。
- **非ヘプタ（7音以外）**は原則 **Roman（Ⅰ〜Ⅶ）非表示**・Diatonic は **Open 限定**。ただし **Pentatonic / Blues は Roman を例外的に表示**（Pent の欠落音は点線表現）。
- **Melody/Solo Analyze** は **Line‑in 前提**・**サーバ解析**。β段階は **録音 UI を非露出（Flag 既定 OFF）**。結果は Key/Scale 候補（≤3）と **Conf%** を返し、低信頼時は録り直しアドバイス。
- **出力**：Free＝**PNG/テキスト**（PNG は**背景既定＋テーマ自動反転**・`export_png` は**1回だけ**計測）。Pro＝**MIDI（Chord Track＋セクションマーカー＋ガイドトーン）**。
- **保存単位は "Sketch（ソングスケッチ）"** に統一。Free＝**3件・ローカル保存**／Pro＝**無制限・クラウド同期**。呼び出し後は**即ループ再生**までワンタップ。

---

## 1. 画面モジュールと責務

### 1.1 Find Chords（キー/スケールから使えるコードを即見せる）
- Key/Scale を選ぶと **Diatonic（Ⅰ〜Ⅶ｜Open のみ）→ Fretboard（二層 Overlay）**が即更新。**Reset は "Chord 層のみ" を解除**し、Scale 下地は残す。表示トグルは **Degrees / Names** の最小構成。
- **Scale table**：各コードに関連スケール（例：Maj＝Ionian/Lydian、Min＝Aeolian/Dorian、Dom7＝Mixolydian）を 2〜3 件。**Why（一文）**と **Glossary**、短い**アルペジオ試聴**付き。
- **Capo 提案**：折りたたみ内に **Top2（Shaped 表記）**のみ、**音は鳴らない**。
- **基礎代理（Lite）**：各行に**一文理由＋代表曲（2–3）**→試聴→**＋Add / 置換**（Undo 可）。
- **非ヘプタの扱い**：Roman 非表示・Diatonic は Open 限定・Capo 行は disabled。**Pent/Blues は Roman 例外表示**。

### 1.2 Melody/Solo Analyze（録音→Key/Scale｜βでは UI 非露出）
- **入力**：**Line‑in 前提**（内蔵マイクは正式対象外）。録音停止→`/api/analyze` が **Key/Scale 候補（≤3）＋Conf%** を返す（Flag 既定 OFF）。
- **結果表示**：Key 候補→Scale→Diatonic（Open 限定）→Fretboard（二層）。録音由来には **"From recording" バッジ**。
- **音の方針**：単音タップ／和音（軽ストラム）を共通ポリシーで再生（Attack≈3–5ms／Release≈80–150ms／最大6声）。

### 1.3 Chord Progression（メイン画面｜Lite / Pro）

**A. 決定後に使う"結果＆ツール群"**  
- **概要ヘッダ**：選択中の **Key/Scale（≤3＋%）** と Roman（**Pent/Blues は例外で Roman 表示**）。  
- **Diatonic＋Fretboard（二層）**：Open 行タップで**和音再生＆Chord 層強調**。Reset は Chord のみ。**Degrees/Names** トグル。  
- **Capo**：折りたたみ内に **Top2（Shaped）＋注記**。  
- **Patterns / Cadence / 基礎代理**：**試聴 → ＋Add** を**2 タップ以内**で統一（Glossary ⒤ 付き）。

**B. 編集ツール**  
- 共通：**削除／ドラッグ並べ替え／全リセット（確認＋Undo）**、**プリセット**（I–V–vi–IV / ii–V–I / 12‑bar Blues / I–II / I–♭VII–IV）→**自動ループ再生**（カウントイン＋メトロノーム）。  
- Lite：**12 コード上限**（9–12 で警告、13 でブロック＋Pro 誘導）。**Undo＝直前 1 手**。**PNG/テキスト出力**。  
- Pro：**セクション編集**（Verse/Chorus/Bridge…）・小節単位の操作・**MIDI 出力**（Chord Track＋section markers＋ガイドトーン）。

**C. 他画面からの追加**  
- **Find Chords →** `＋Add to progression` で即挿入→**自動再生**。`Open in Chord Progression` で本編へ。  
- **Melody/Solo Analyze →**（将来）**Chord suggestion を確定→Open in Chord Progression**。βでは録音 UI 非露出。

---

## 2. Sketch Library（保存・呼び出し）

> 保存物は **"Sketch（ソングスケッチ）"**。内容は **進行＋Key/Scale＋Capo（Shaped）＋Fretboard 表示状態**。英 UI：*Save as Sketch / My sketches*。

### 2.1 Free / Pro と保存場所
- **Free**：**3 件まで**。サインイン不要の**ローカル保存**（最古 LRU 上書き or Pro 案内）。  
- **Pro**：**無制限**。**クラウド同期**（オフライン時はローカルにキュー→再接続で双方向マージ）。

### 2.2 スナップショット項目
- Meta：`id / name / createdAt / updatedAt / schema=sketch_v1 / appVersion`  
- 選択中 **Key/Scale**、**Capo**（`capoFret` と **Shaped 基準**の注記）、**進行**（Lite＝最大 12／Pro＝セクション＋小節＋グローバル BPM/拍子）、**Fretboard 表示**（Degrees/Names、ガイド設定）。

### 2.3 UI フロー
- **Save as Sketch**：未命名は自動命名→トースト *Saved*。Free 4 件目は「上書き or Go Pro」。  
- **Open（My sketches）**：最近順＋☆ピン留め／名前・Key/Scale 検索。開いたら**即ループ再生**までワンタップ。  
- **Auto‑save**：コード追加・並べ替え・Capo/Key 切替後 **3 秒アイドル** or ページ離脱で差分保存。

### 2.4 復元ルール（互換）
- **Roman 表示**は **Pent/Blues のみ例外的に有効**。その他の非ヘプタは Roman 非表示・Capo disabled（復元もこの規則で）。  
- **Capo 注記**：*Shaped=fingered / Sounding=actual pitch* を**保存・出力の両方**に明記。

---

## 3. ToneOverlay（二層）と"音が鳴る UI"の共通ルール

- **二層 Overlay**：**Scale 層＝輪郭・小・無地**／**Chord 層＝塗り・大・ラベル**。**Reset＝Chord 層のみ**解除。**Degrees/Names** は即時切替。  
- **発音**：単音 Attack≈3–5ms／Release≈80–150ms、最大 6 声（voice‑stealing）。和音は同時 or **軽ストラム（≈10–20ms）**。初回は **Audio Unlocker** で解錠。

---

## 4. 出力・共有

- **PNG（Free）**：背景（transparent / light / dark）を既定切替＋**テーマ自動反転**。`export_png` は**成功/失敗を問わず 1 回だけ**送出。  
- **テキスト（Free）**：Key/Scale、Diatonic、進行（Roman/実音）、**Capo 注記**をコピー可。  
- **MIDI（Pro）**：**Chord Track＋セクションマーカー＋ガイドトーン**を生成。

---

## 5. Free / Pro の境界

- **Free**：Find Chords（Scale table／二層 Overlay／Capo Top2）、Cadence/Patterns の **＋Add**、Progression Lite（12 上限・プリセット・PNG/テキスト）、**Sketch＝3 件**。  
- **Pro**：セクション進行、**MIDI 出力**、Sketch 無制限、今後の高度機能（近接ボイシング／Avoid／Tension／録音拡張）。

---

## 6. Telemetry（最小セット）

- 共通：`page_view, key_pick, scale_pick, diatonic_pick, overlay_shown, fb_toggle, overlay_reset, play_note, play_chord, export_png`（**1 操作＝1 発火**）。  
- 進行：`progression_play, preset_inserted, toast_shown(kind)`（`limit_warn` / `limit_block` / `undo` / `low_conf`）。  
- 保存：`save_project, open_project, project_rename, project_delete, project_duplicate, project_limit_warn, project_limit_block`（内部キーは *project* を継続使用）。  
- 録音（将来露出）：`audio_record_start/stop, audio_analyze_ok, audio_analyze_conf(engine, conf)`。

---

## 7. 受け入れ基準（DoD）

1. **Find Chords**：Key/Scale 選択のみで結果が更新。Open 行タップで**和音再生＆Chord 層強調**。**Reset で Scale は保持**。  
2. **Capo**：折りたたみ内に **Top2（Shaped）**と注記を表示。**音は鳴らさない**。  
3. **Progression**：**ドラッグ並べ替え／Undo（Lite＝1 手）／プリセット→自動ループ**が動く。  
4. **提案追加**：Patterns / Cadence / 基礎代理は **試聴 → ＋Add** を**2 タップ以内**。追加直後に**自動再生**。  
5. **Sketch**：Key/Scale・Capo（Shaped）・進行・Overlay 表示が**完全復元**。Free＝**3 件制限**、Pro＝**無制限**。  
6. **出力**：Free＝PNG/テキスト、Pro＝MIDI。PNG は背景既定＋テーマ反転、`export_png` は**必ず 1 回**。  
7. **録音（Flag ON 時）**：Line‑in のみ開始可。停止→**Key 候補 ≤3 ＋ Conf%** 表示、低信頼時は**再録アドバイス**。βでは録音 UI 非露出。

---

## 8. 参考（出典ポインタ）

- v3.0 SSOT 正本：本書（このページ）。  
- 旧版（v2.4 系）は参考として残存：ToneOverlay 二層、UI 統一、Scale Catalog 14 種、PNG 出力、サーバ解析方針などの経緯確認にのみ使用。**判断は必ず本書を優先**。

---

### 付録 A：運用ガイド（リポジトリ反映）

```bash
git switch -c feat/v3.0-ssot
mkdir -p docs/SSOT
# このファイルを docs/SSOT/OtoTheory_v3.0_SSOT.md として追加
git add docs/SSOT/OtoTheory_v3.0_SSOT.md
git commit -m "docs: add OtoTheory v3.0 SSOT"

# 旧版の扱い（任意）：docs/SSOT/legacy/ へ移動し README に「参照目的のみ」と明記
# PR 作成時：テンプレの「SSOT」欄は「更新が必要」にチェック
git push -u origin feat/v3.0-ssot
```
