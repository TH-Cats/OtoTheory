# OtoTheory 要件定義 v2.3 — Audio Bridge（**Final**）

**更新日時**: 2025-09-25 10:15 UTC  
**対象**: Webアプリ（Find Chord / Find Key/Scale）  
**状態**: ✅ 受け入れ完了（Cursor 突合による確認済み）

---

## 0. 完了サマリ
- **SSOT（Scale Catalog, 14種）**: Ionian〜Dorian b2 + Diminished(WH/HW) を英語表記・度数で統一。両ページが同順・同一表記で参照。  
- **Pitch 導出 API**: `getScalePitchesById(rootPc, id)` を全ページで使用。5/7/8音に対応。  
- **非ヘプタ出し分け**: 5音/8音では Roman 非表示、Diatonic は Open 限定（Capo disabled）。ヒント文表示。  
- **ToneOverlay**: 色相保持の中空リング、8音は `ghost--dense` で密度調整。  
- **Info（i）**: Scale ラベル横。Degrees / Notes in C / About / Song examples を表示。  
- **Telemetry**: `track()` と `/api/telemetry` スタブで主要イベント送出（1操作=1発火）。  
- **Feature Flag**: `NEXT_PUBLIC_FEATURE_AUDIO_SUGGEST`（既定 false）。`isFeatureEnabled('audioSuggest')`。  
- **Docs/Reference**: `docs/ARCHITECTURE.md` 追記、`/reference#scales` アンカー追加。  
- **UI・A11y**: page-scoped gap=6px、roving tablist（矢印/Home/End/Enter/Space）。

---

## 1. 受け入れ基準（達成済）
1) スケール候補が **14件**で両ページ同順・英語表記。  
2) `getScalePitchesById(0, id)` が代表値と一致：  
   - Ionian → `[0,2,4,5,7,9,11]`  
   - Blues → `[0,3,5,6,7,10]`  
   - Diminished Whole–Half → `[0,2,3,5,6,8,9,11]`  
   - Diminished Half–Whole → `[0,1,3,4,6,7,9,10]`  
3) 非ヘプタで Roman 非表示・Diatonic Open 限定（Capo 行 disabled）。  
4) Info（i）で 4要素（Degrees/Notes in C/About/Examples）表示。  
5) Telemetry が Console/Network で 1操作=1送信。  
6) Feature Flag で録音導線が既定非表示。

---

## 2. 実装概要（確定仕様）
### 2.1 Scale Catalog（SSOT）
- `src/lib/scaleCatalog.ts`: `id, display.en, degrees[], group, info.oneLiner, info.examples[]`  
- Excel 英語版を真実のソースとし、`display.en` / `degrees` を一致させる。

### 2.2 Pitch 導出
- `getScalePitchesById(rootPc:number, id:ScaleId): number[]`  
- `DegreeToken → semitone` 変換で pitch-class を算出。

### 2.3 非ヘプタ時の UI
- Roman 非表示、Diatonic は Open 限定（Capo 行は `aria-disabled` / `tabIndex=-1` / `pointer-events:none`）。  
- Result セクション下にヒント文。

### 2.4 Info（i）
- 位置: Scale ラベル右の `InfoDot`。  
- 内容: Degrees・Notes in C・About・Song examples。Esc/外側クリックで閉。

### 2.5 Telemetry（最小）
- 送出関数: `track(event, payload)` → `sendBeacon` 優先、POST フォールバック。  
- イベント: `page_view, scale_pick, key_pick, diatonic_pick, overlay_reset, fb_toggle, overlay_shown`。  
- 受け口: `/api/telemetry`（200返却のスタブ）。

### 2.6 Feature Flag
- `.env.local`: `NEXT_PUBLIC_FEATURE_AUDIO_SUGGEST=false`（既定）  
- `isFeatureEnabled('audioSuggest')` で UI 表示を制御。

### 2.7 UI 指針
- 縦リズム: `--stack-gap: 6px`（SP/MD 共通）。  
- ToneOverlay: 色相保持の中空リング、8音は `ghost--dense`。  
- A11y: roving tablist（Key 行・Degrees/Names 行）。

---

## 3. 確認スニペット（DevTools）
**候補件数（どのページでも安全）**
```js
(() => {{
  const mains = [...document.querySelectorAll('main[data-page]')];
  return mains.map(m => {{
    const page = m.getAttribute('data-page');
    const sel  = m.querySelector('select[name="scale"]');
    if (sel) return {{ page, count: sel.options.length }};
    const row = m.querySelector('[role="tablist"][aria-label="Select scale"], [data-testid="scale-chips"]');
    const tabs = row ? [...row.querySelectorAll('[role="tab"],button')] : [];
    return {{ page, count: tabs.length }};
  }});
}})();
```
**代表ピッチ**
```js
const api = window.__SCALES_API__;
[
  ['Ionian',[0,2,4,5,7,9,11]],
  ['Blues',[0,3,5,6,7,10]],
  ['DiminishedWholeHalf',[0,2,3,5,6,8,9,11]],
  ['DiminishedHalfWhole',[0,1,3,4,6,7,9,10]],
].map(([id, expected]) => ({{ id, ok: JSON.stringify(api.getScalePitchesById(0,id))===JSON.stringify(expected) }}));
```

---

## 4. 運用メモ
- 個人環境は `.env.local` に `NEXT_PUBLIC_FEATURE_AUDIO_SUGGEST=false` を設定。  
- 開発中は `[ototelem]` ログが出ます。運用段階で console 抑止を検討。

---

## 5. 次フェーズ Preview（録音→解析）
- **入力**: `getUserMedia`、`audio/webm;codecs=opus`（iOS は aac フォールバック）。  
- **解析**: WebAudio → Chromagram/FFT → Key/Scale 推定 → Diatonic 提案（区間解析から開始）。  
- **方針**: まずローカル解析、サーバ送信はオプトイン。

---

## 6. 変更履歴
- v2.3 Final: Cursor 突合 OK。Telemetry/Flag/Docs/Reference/Info を反映し、受け入れ完了。
