# OtoTheory v2.4.1 — Release Canvas（移行用）

> **主目的**：v2.4の未決オープン3点のクローズと、出力・計測の仕上げ（体験は踏襲）

---

## 0) TL;DR / 合意事項
- 大きな仕様変更なし。Essentia.js の導入は v2.4.2 以降（必要ならプレビューを旗付きで用意）。
- 2.4.1 のスコープ：
  1. Why短文テンプレ最終化（Scale table）
  2. Barre 度数ラベル位置の確定（Open/Barre E/A）
  3. PNG出力の背景既定＋テーマ自動反転
  4. E2Eスモーク（最小1本）
  5. Telemetry 拡張（export_png）

---

## 1) スコープ（やること）

### 1.1 MUST（必須タスク）
- **V241-1｜Why短文テンプレ最終化**：i18nキー化（EN/JA）、Glossaryと整合。DoD: 各コードで「2スケール＋Why一文」が安定表示。
- **V241-2｜Barre度数ラベルの確定**：表示・読み上げをルート基準に統一。DoD: Open/Barre(E/A)で視覚と読み上げが一致。
- **V241-3｜PNG出力の背景既定＋テーマ自動反転 — Done**  
  
  **実装サマリ（Cursor完了報告反映）**  
  - `Fretboard` を `forwardRef` 化し、書き出し対象 `div` に `ref` を付与（PNGターゲット）。フォームdotの座標は **`ZERO_COL_W` を考慮**して補正。  
  - 出力対象外のUI（`Forms`ボタンやモーダル等）には **`data-export-ignore=\"true\"`** を付与。  
  - `renderFormOverlay` を更新し、**12F以降のズレ解消**／**度数テキストの視認性**／**読み上げ文言**を統一。  
  - `Analyze` / `Find Chords` の両ページで、書き出し対象ラッパに `ref` を渡し、`<ExportPNGButton targetRef={...} fileName=… background={process.env.NEXT_PUBLIC_EXPORT_BG} />` を配置。  
  - `globals.css` に **輸出モード用スタイル**を追加：  
    - `data-export-ignore` 要素は `visibility:hidden`。  
    - `.ot-exporting[data-export-mode=\"light|dark\"]` で **テーマ強制**・見栄え調整（ダーク時のストローク/文字色補正含む）。  
    - エクスポート中はフォーカス輪郭/影を抑制してノイズを排除。  
  
  **DoD（達成）**  
  - `NEXT_PUBLIC_EXPORT_BG`（`transparent|light|dark`）で **背景既定の切替が反映**。  
  - **ライト/ダークの両テーマで視認性◎**（細線はストローク補強／文字可読）。  
  - 広告・一時UI（トグル/ポップ/ラベル等）が **PNGに混入しない**（`data-export-ignore` 機構）。  
  - CLS/水和不一致なし（既存描画順・計測を維持）。  
  
  **QA チェック（簡易）**  
  1. Analyze/FindChords の Fretboardで **Export** 実行 → 3種背景それぞれでコントラストOK。  
  2. `Forms` ボタンやモーダルが **出力に含まれない**。  
  3. 12F以降のフォームdot位置が **ズレない**。  
  4. テーマを切替（dark/light）→ それぞれの PNG で **文字/線の可読**を目視。  
  
  **ブランチ/PR**  
  - PR: `feat/v2.4.1-v241-3-export-png` → `release/v2.4.1`（マージ済み/予定を記入）


- **V241-4｜E2Eスモーク（Playwright） — Done**  
  
  **実装サマリ（Cursor完了報告反映）**  
  - **基盤整備**：`playwright.config.ts` を追加し `tests/e2e` 配下をテストディレクトリ化。出力先は `test-results`。CIではリトライ1回、trace/screenshot/videoを失敗時に保存。`npm run e2e` でローカル/CI共通実行可能に。  
  - **スモークテスト**：`tests/e2e/smoke-v241.spec.ts` を新規。`/api/analyze` をモックし、録音処理はフェイク実装で代替。結果カード表示→スケール選択→ダイアトニック/フォーム操作→PNG保存までを検証。  
  - **スクショ**：ライト/ダーク両テーマでスクリーンショットを保存。フォームdot表示も `expect` で担保。  
  - **DoD（達成）**：`npm run e2e` がローカル/CIで成功。失敗時に `test-results` 配下へ trace/screenshot/video が保存される。PNGダウンロードイベントを検知し保存確認。


- **V241-5｜Telemetry拡張（export_png） — Done**  
  
  **実装サマリ（Cursor完了報告反映）**  
  - `OtEvent` に `export_png` を追加し、`track()` SSOT経由で送出できるよう型・ユニオンを拡張。  
  - PNG出力ユーティリティ（`exportNodeToPng`）で `trackExportPng({ theme,bg,dpr,size })` を呼び出し、**保存成功/失敗どちらでも1回だけ**発火するように実装。`sendBeacon`優先、フォールバックは既存`track()`が担保。  
  - `trackExportPng` ヘルパーを導入し、テーマ/背景/スケール/DPR/描画領域をペイロードとして送信。  
  
  **DoD（達成）**  
  - PNG保存時に **必ず1回だけ** `export_png` が発火。  
  - Networkログで重複なし。既存のTelemetryイベント（`overlay_shown`, `ad_shown`, `audio_*` 等）と順序整合を確認。  
  
  **ブランチ/PR**  
  - PR: `feat/v2.4.1-v241-5-telemetry-export` → `release/v2.4.1`（マージ済み/予定を記入）  

- **V241-6｜Essentia.js プレビュー導入（flag付き） — Done**  
  
  **実装サマリ（Cursor完了報告反映）**  
  - Flag判定を `NEXT_PUBLIC_FEATURE_KEY_ENGINE === 'essentia-js'` に単純化し、プレビュー環境で **Essentia 経路を起動可能**に。  
  - `record.client.tsx` に解析フローを集約：`submitToApi()` / `finishProcessing()` を追加し、**Essentia / PCP12 いずれでも同じ API コール／UI後処理**を実行。`__OT_LAST_*` は SSOT に更新。  
  - **Essentiaワーカー経路**：Folded PCP を API へ送信し、成功時は完了／失敗時は **PCP12インライン解析へフォールバック**。  
  - **PCP12インライン経路**も同ヘルパーに統合し、**後処理を一元化**。  
  - Telemetry：Essentia時は `audio_analyze_conf` に `engine: 'ess-js'` を付与。  
  
  **DoD（達成）**  
  - `NEXT_PUBLIC_FEATURE_KEY_ENGINE=essentia-js` で **Essentia.js プレビューが動作**／OFFでは **従来PCP12サーバ投票**が動作。  
  - Safari/Chrome/Edge での安定を確認（メモリリーク無し）。  
  - フォールバックにより **失敗時もユーザー体験を維持**（回帰差異なし）。  
  
  **ブランチ/PR**  
  - PR: `feat/v2.4.1-v241-6-essentia-preview` → `release/v2.4.1`（マージ済み/予定を記入）

