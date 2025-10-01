# OtoTheory v3.0 — Single Source of Truth（仕様 正本）

> **この文書が最新版の正本（SSOT）です。** 旧版（v2.4〜v2.4.1 ほか）は参照資料扱いとし、本書と矛盾する場合は本書を優先します。:contentReference[oaicite:0]{index=0}

---

## 0. 本版での主要な決定（v2.4 系からの差分）

- **Chord Progression をメインに据え、決定後に使える “結果＆ツール群” を明示。** Diatonic→Fretboard（二層Overlay）、Patterns、Cadence、基礎代理の提案をワンタップ追加→即ループ再生で統一。:contentReference[oaicite:1]{index=1}
- **Capo 提案**は Diatonic 表の折りたたみ内に **Top2（Shaped表記）**のみ提示。音は鳴らさず、注記 *Shaped=fingered / Sounding=actual* を併記。Free/Pro の差は設けない。:contentReference[oaicite:2]{index=2}
- **非ヘプタの扱い**：原則 Roman 非表示・Diatonic は Open 限定。ただし **Pentatonic / Blues は例外的に Roman 表示**（Pent の欠落音は点線）。:contentReference[oaicite:3]{index=3}
- **Melody/Solo Analyze**：録音は **Line‑in 前提**。解析はサーバ実行（`/api/analyze`）；**βでは録音UIを非露出**（Flag 既定OFF）。Conf% を返し、低信頼時は再録ヒントを表示。
- **出力**：Free は PNG/テキスト（PNG は**背景既定＋テーマ自動反転**・`export_png` を1回だけ計測）、Pro は **MIDI（Chord Track＋セクションマーカー＋ガイドトーン）**に対応。
- **保存単位の名称を “Sketch（ソングスケッチ）” に統一。** Free=3件まで（ローカル保存）、Pro=無制限（クラウド同期）。呼び出しで直ちにループ再生可。:contentReference[oaicite:6]{index=6}

---

## 1. 画面モジュール

### 1.1 Find Chords（キー/スケールから使えるコード）
- **Select → Result 即反映**：Key/Scale 選択だけで **Diatonic（I–VII｜Openのみ）→Fretboard（二層）**が更新。Reset は **Chord層のみ解除**。トグルは **Degrees / Names** 最小構成。:contentReference[oaicite:7]{index=7}
- **Scale table**：各コードに 2〜3 スケール（例：Maj=Ionian/Lydian、Min=Aeolian/Dorian、Dom7=Mixolydian）。*Why 一文*と ⒤Glossary、**短いアルペジオ試聴**付き。:contentReference[oaicite:8]{index=8}
- **Capo 提案（折りたたみ）**：ローコードが多い **Top2** を **Shaped 表記**で表示。音は鳴らさない。:contentReference[oaicite:9]{index=9}
- **基礎代理（Lite）**：各行に **一文理由＋代表曲（2–3件）**→試聴→**＋Add / 置換**（Undo 可）。:contentReference[oaicite:10]{index=10}
- **非ヘプタ**：原則 Roman 非表示・Diatonic=Open 限定・Capo 行 disabled。**Pent/Blues は例外で Roman 表示**。:contentReference[oaicite:11]{index=11}

### 1.2 Melody/Solo Analyze（録音→Key/Scale｜βでは非露出）
- **入力**：**Line‑in 前提**（内蔵マイクは正式対象外）。録音停止→`/api/analyze` で Key/Scale 候補（≤3＋Conf%）を返す。Flag 既定OFF。
- **結果カード**：Key候補→Scale→Diatonic（Openのみ）→Fretboard（二層）。録音由来には “From recording” バッジ。:contentReference[oaicite:13]{index=13}
- **音が鳴るUI**：単音タップ／和音（軽ストラム）を一貫ポリシーで再生（Attack≈4ms / Release≈120ms / 最大6声）。:contentReference[oaicite:14]{index=14}

### 1.3 Chord Progression（メイン｜Lite / Pro）
**A. 決定後に使える結果＆ツール**
- **概要ヘッダ**：選択中の **Key/Scale（≤3＋%）** と Roman（Pent/Blues は例外で表示）。:contentReference[oaicite:15]{index=15}
- **Diatonic＋Fretboard（二層 Overlay）**：Open 行タップで和音試聴＆Chord層強調。Reset=Chordのみ。**Degrees/Names** トグル。:contentReference[oaicite:16]{index=16}
- **Capo（折りたたみ）**：**Top2（Shaped）**＋注記。:contentReference[oaicite:17]{index=17}
- **Patterns / Cadence / 基礎代理**：**試聴→＋Add** を**2タップ以内**に統一。Glossary⒤付き。:contentReference[oaicite:18]{index=18}

**B. 編集ツール**
- 共通：**削除／ドラッグ並べ替え／全リセット（確認＋Undo）**、**プリセット**（I–V–vi–IV / ii–V–I / 12‑bar Blues / I–II / I–♭VII–IV）→**自動ループ再生**（カウントイン＋メトロノーム）。:contentReference[oaicite:19]{index=19}
- Lite 制約：**12コード上限**（9–12警告、13ブロック＋Pro誘導）。Undo=**直前1手**。**画像/テキスト出力**対応。
- Pro 追加：**セクション編集**（Verse/Chorus/Bridge…）・小節単位の操作・**MIDI 出力**（Chord Track＋section markers＋ガイドトーン）。:contentReference[oaicite:21]{index=21}

**C. 他画面からの追加**
- **Find Chords →** `＋Add to progression` 即挿入→**自動再生**。`Open in Chord Progression` で本編へ移送。:contentReference[oaicite:22]{index=22}
- **Melody/Solo Analyze →**（将来）**Chord suggestion 確定→Open in Chord Progression**。βでは録音UI非露出。:contentReference[oaicite:23]{index=23}

---

## 2. Sketch Library（保存・呼び出し）

> **保存物は “Sketch（ソングスケッチ）”** と呼び、**進行＋Key/Scale＋Capo（Shaped）＋Fretboard表示状態**を一括保存します。英UI：**Save as Sketch / My sketches**。:contentReference[oaicite:24]{index=24}

### 2.1 Free / Pro と保存場所
- **Free**：**3件まで**。サインイン不要の **ローカル保存**（最古 LRU 上書き or Pro 誘導）。:contentReference[oaicite:25]{index=25}
- **Pro**：**無制限**。**クラウド同期**（オフライン時はローカルにキュー→再接続で二方向マージ）。:contentReference[oaicite:26]{index=26}

### 2.2 スナップショット項目
- Meta：`id / name / createdAt / updatedAt / schema=sketch_v1 / appVersion`
- Key/Scale（採用中の1組）、**Capo**（`capoFret` と **Shaped基準**注記）、**進行**（Lite=最大12／Pro=セクション＋小節＋グローバル BPM/拍子）、**Fretboard表示**（Degrees/Names、ガイド設定）。:contentReference[oaicite:27]{index=27}

### 2.3 UI フロー
- **Save as Sketch**：未命名は自動命名→トースト *Saved*。Free 4件目で「上書き or Go Pro」。:contentReference[oaicite:28]{index=28}
- **Open（My sketches）**：最近順＋☆ピン留め／名前・Key/Scale 検索。開いたら**即ループ再生**までワンタップ。:contentReference[oaicite:29]{index=29}
- **Auto‑save**：コード追加・並べ替え・Capo/Key 切替後 **3秒アイドル** or ページ離脱で差分保存。:contentReference[oaicite:30]{index=30}

### 2.4 互換・注記
- **Roman 表示**は **Pent/Blues のみ例外で有効**。その他の非ヘプタは Roman 非表示・Capo disabled（復元もこの規則で）。:contentReference[oaicite:31]{index=31}
- **Capo 注記**：*Shaped=fingered / Sounding=actual pitch* を出力・保存とも明記。:contentReference[oaicite:32]{index=32}

---

## 3. ToneOverlay（二層）と音のポリシー

- **二層ルール**：**Scale 層=輪郭・小・無地**／**Chord 層=塗り・大・ラベル**。**Reset＝Chordのみ解除**。Degrees/Names 即時切替。:contentReference[oaicite:33]{index=33}
- **音**：単音 Attack≈3–5ms / Release≈80–150ms、最大6声（voice‑stealing）。和音は同時 or 軽ストラム（≈10–20ms）。初回解錠は Audio Unlocker。

---

## 4. 出力・共有

- **PNG（Free）**：背景（transparent/light/dark）の既定切替＋**テーマ自動反転**。`export_png` は**保存成功/失敗に関わらず1回だけ**送出。:contentReference[oaicite:35]{index=35}
- **テキスト（Free）**：Key/Scale、Diatonic、進行（Roman/実音）、**Capo 注記**をコピー可。:contentReference[oaicite:36]{index=36}
- **MIDI（Pro）**：**Chord Track＋セクションマーカー＋ガイドトーン**を書き出し。:contentReference[oaicite:37]{index=37}

---

## 5. Free / Pro 境界

- **Free**：Find Chords（Scale table／二層 Overlay／Capo Top2）、Cadence/Patterns の **＋Add**、Progression Lite（12上限・プリセット・PNG/テキスト）、**Sketch=3件**。
- **Pro**：セクション進行、**MIDI 出力**、Sketch 無制限、将来の高度機能（近接ボイシング/Avoid/Tension/録音拡張）。:contentReference[oaicite:39]{index=39}

---

## 6. Telemetry（最小セット）

- 共通：`page_view, key_pick, scale_pick, diatonic_pick, overlay_shown, fb_toggle, overlay_reset, play_note, play_chord, export_png`。**1操作=1発火**。
- 進行：`progression_play, preset_inserted, toast_shown(kind)`（limit_warn / limit_block / undo / low_conf）。:contentReference[oaicite:41]{index=41}
- 保存：`save_project, open_project, project_rename, project_delete, project_duplicate, project_limit_warn, project_limit_block`（内部キーは既存 *project* を継続）。:contentReference[oaicite:42]{index=42}
- 録音（将来露出）：`audio_record_start/stop, audio_analyze_ok, audio_analyze_conf(engine,conf)`。:contentReference[oaicite:43]{index=43}

---

## 7. 受け入れ基準（DoD）

1) **Find Chords**：Key/Scale 選択のみで Result 更新。Open 行タップで和音再生＆Chord層強調。Reset で **Scale は保持**。:contentReference[oaicite:44]{index=44}  
2) **Capo**：折りたたみ内に **Top2（Shaped）**＋注記。音は鳴らさない。:contentReference[oaicite:45]{index=45}  
3) **Progression**：**ドラッグ並べ替え／Undo（Lite=1手）／プリセット→自動ループ**が動作。  
4) **提案追加**：Patterns / Cadence / 基礎代理は**試聴→＋Add**が**2タップ以内**。直後に自動再生。:contentReference[oaicite:47]{index=47}  
5) **Sketch**：Key/Scale・Capo（Shaped）・進行・Overlay 表示が**完全復元**。Free=3件制限、Pro=無制限。:contentReference[oaicite:48]{index=48}  
6) **出力**：Free＝PNG/テキスト、Pro＝MIDI。PNG は背景既定＋テーマ反転、`export_png` は**必ず1回**。:contentReference[oaicite:49]{index=49}  
7) **録音（Flag ON 時）**：Line‑in のみ開始可。停止→**Key候補≤3＋Conf%** 表示、低信頼時は Advice。βでは UI 非露出。:contentReference[oaicite:50]{index=50}

---

## 8. 参考（ソース根拠）

- v2.1：ToneOverlay（二層）・Reset=Chordのみ・Shaped/Sounding。:contentReference[oaicite:51]{index=51}  
- v2.2：UI統一／トグル最小化／共通クラス・レイアウト。:contentReference[oaicite:52]{index=52}  
- v2.3 Final：**Scale Catalog 14種／非ヘプタUI／Info(i)／Flag=audioSuggest**。:contentReference[oaicite:53]{index=53}  
- v2.4（最終）：Analyze統合／音が鳴るUI／Progression Lite/Pro／Capo/Patterns/Cadence。:contentReference[oaicite:54]{index=54}  
- 追補：Scope Trim（Sub/Mod は vNext）／Audio Engine Plan（Conf%/終止重み）／Server Execution（サーバ実行）。  
- v2.4.1：PNG出力（背景既定＋テーマ自動反転）・`export_png`。:contentReference[oaicite:56]{index=56}  
- 実施ログ：/api/analyze・Lite 上限/Undo/プリセット・Scale table 実装・A11y/Telemetry。:contentReference[oaicite:57]{index=57}

# 1) 新版SSOTの運用ガイド
git switch -c feat/v3.0-ssot
mkdir -p docs/spec
git add docs/SSOT/OtoTheory_v3.0_SSOT.md
git commit -m "docs: add OtoTheory v3.0 SSOT"

# 2) 参照の衝突回避（任意）：
#    旧版v2.4系を残す場合は 'docs/SSOT/legacy/' などへ移動し README に参照目的を明記

# 3) PR 作成（テンプレのSSOT欄は「更新が必要」にチェック）
git push -u origin feat/v3.0-ssot