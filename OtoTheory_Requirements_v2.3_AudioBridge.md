# OtoTheory 要件定義 v2.3 — Audio Bridge（Web版）

**更新日時**: 2025-09-25 08:11 UTC  
**対象**: Webアプリ（Find Chord / Find Key/Scale）  
**ゴール**: 既存UIの安定化を完了し、**「録音→キー/スケール/ダイアトニック提案」機能**へ接続できる下地（テレメトリ／フラグ／ドキュメント）を整備する。

---

## 1. ステータス要約（完了）
- **14スケールの単一カタログ（SSOT）**：Excel英語版準拠。Diminished（Whole–Half / Half–Whole）を追加（8音対応）。  
- **UI統一**：Find Chord / Find Key/Scale は同一カタログを参照（同順・英語表記）。  
- **非ヘプタの出し分け**：5音/8音では Roman 非表示、Diatonic は Open 限定。  
- **ToneOverlay**：色相保持の中空リング。8音時は `ghost--dense` で視認性調整。  
- **Info（i）**：Degrees / Notes in C / About / Song examples のポップアップ。  
- **縦リズム**：page-scoped `--stack-gap: 6px`。  
- **A11y**：ロービング tablist（矢印/Home/End/Enter/Space）。

---

## 2. 仕様の要点（v2.3）
### 2.1 Scale Catalog（SSOT）
- 定義ファイル：`src/lib/scaleCatalog.ts`  
- 項目：`id`, `display.en`, `degrees[]`, `group`, `info.oneLiner`, `info.examples[]`  
- **真実のソース**：Excel（英語版）。`display.en` と `degrees` は Excel を正とする。

### 2.2 Pitch 導出 API
- `getScalePitchesById(rootPc: number, id: ScaleId): number[]`  
- `DegreeToken → semitone` テーブルで半音配列へ変換し、rootPc（0=C）からの pitch-class 配列を返す。  
- 代表例（C）：  
  - Ionian `[0,2,4,5,7,9,11]`  
  - Blues `[0,3,5,6,7,10]`  
  - Diminished WH `[0,2,3,5,6,8,9,11]` / HW `[0,1,3,4,6,7,9,10]`

### 2.3 非ヘプタ時の挙動
- Roman 行：非表示（あるいは “—”）  
- Diatonic：Open 行のみ。Capo 行は `aria-disabled=true`。  
- ヒント文を Result 見出し下に表示。

### 2.4 Info（i）ポップアップ
- 位置：「Scale」ラベル右  
- 表示：**Degrees / Notes in C / About / Song examples**  
- UI：既存 `InfoDot` を利用（Esc/外側クリックで閉）。

---

## 3. テレメトリ（最小）
- ラッパ：`track(event, payload)`（SendBeacon→POST フォールバック）  
- エンドポイント：`/api/telemetry`（200固定のスタブ）  
- イベント：`page_view`, `scale_pick`, `key_pick`, `diatonic_pick`, `overlay_reset`, `fb_toggle`, `overlay_shown`  
- 受入：Network タブで **1操作=1送信**、重複なし。

---

## 4. フィーチャーフラグ
- 環境変数：`NEXT_PUBLIC_FEATURE_AUDIO_SUGGEST`（既定 false）  
- 関数：`isFeatureEnabled('audioSuggest')`  
- 将来の UI（録音導線）は flag で隠したままルーティングのみ作成可。

---

## 5. 参考設計（録音→解析）
- **入力**：`getUserMedia`（`audio/webm;codecs=opus` を優先、iOS は aac フォールバック）  
- **処理**：`WebAudio → Chromagram/FFT → Key/Scale 推定 → Diatonic 提案`（最初は区間解析）  
- **方針**：ローカル解析を基本。サーバ送信はオプトイン。

---

## 6. 受け入れ基準（抜粋）
1) 両ページのスケール候補が **14件**・同順・英語表記。  
2) 上記 API の代表値が一致（Ionian/Blues/Dim WH/HW）。  
3) 非ヘプタの Roman 非表示 ＆ Diatonic Open 限定。  
4) Info（i）が4要素を表示。  
5) Telemetry が Console/Network で 1操作=1発火。  
6) Feature flag が false のとき録音 UI は露出しない。

---

## 7. 既知の非目標（v2.3）
- 連続再生やリアルタイムトラッキングは範囲外（次フェーズ）。  
- モバイル実装は設計のみ（別要件で定義）。

