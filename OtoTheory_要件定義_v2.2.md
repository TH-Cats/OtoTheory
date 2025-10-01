# OtoTheory 要件定義 v2.2 — UI統一 / ToneOverlay 安定化
**版:** 2.2  
**日付:** 2025-09-21 (JST)  
**対象:** Find Chord / Find Key&Scale  
**オーナー:** あなた  
**実装:** Cursor（TS/React）

> 本書は v2（Free/Pro・AI・Section対応）および v2.1（ToneOverlay統合）の差分集約です。  
> 参照: v2（基準方針・機能一覧）, v2.1（ToneOverlay設計・受入基準）。

---

## 0. TL;DR（今回の要点）
- **画面構造の統一**：Find Chord を「Select Key & Scale」「Result（Diatonic→Fretboard）」の2カード構成へ。大見出し「Find Chords」は廃止。  
- **トグル整理**：**Degrees / Names** のみ残し、**Sounding / Shaped / Compare** は **削除**（Find Chord）。  
- **ToneOverlay の振る舞い確定**：  
  - Chord 選択時＝**Chord layer（塗り/大/ラベル有）**＋**Scale layer（輪郭/小/ラベル無）**を同時表示。  
  - **Reset** は Chord layer のみ解除。Scale 下地は**必ず残す/復帰**。  
- **Diatonic**：Open 行のみ選択可能（Capo 行は表示のみ）。押下エフェクト・選択中ハイライトを付与。  
- **Fretboard**：Find Key&Scale と同じドット色。**Degrees/Names** の即切替を保証。  
- **スケール選択**：Ionian（Major）/ Aeolian（Natural Minor）に **Lydian / Mixolydian / Major Pentatonic** を追加（段階導入）。  
- **操作感**：Show Chords に押下アニメ。モバイルの Chip 行は横スクロール・内テキストの溢れ対策。  
- **レイアウト規約導入**：`.ot-page`（幅/左右余白）・`.ot-stack`（縦リズム）・`.ot-card`（カード）・`.ot-h2/.ot-h3`（見出し）の**共通クラス**を全画面で使用。  
- **テーマ・トークン修復**：`--bg/--surface/--line` を Light/Dark/OS 追従すべてに定義。`body` 背景は常に `var(--bg)` を参照。

---

## 1. スコープ / 目的（v2.2差分）
- **目的**：Find Chord を Find Key&Scale のデザイン／挙動に寄せ、**学ぶ→弾く**の移行コストをゼロにする。  
- **対象**：Find Chord（主）＋ Find Key&Scale（共通化の影響範囲）。

---

## 2. 画面・UI 仕様（更新）
### 2.1 ページ構造（Find Chord）
- `<main class="ot-page ot-stack">`
- **Card #1 – Select Key & Scale**  
  - H2: **Select Key & Scale**（`.ot-h2`）  
  - Key（12ボタン） / Scale（セレクト） / **Show Chords**（押下アニメ: 120ms, focus-visible あり）
- **Card #2 – Result**  
  - H2: **Result**（`.ot-h2`）  
  - **Diatonic**（H3）: I〜VII（Open 行のみ選択可／Capo 行は表示）  
  - **Fretboard**（H3）: **Degrees / Names** チップ（同サイズ）

### 2.2 Chip / ボタン
- Degrees / Names は **同サイズ** Chip。  
- Show Chords は **縮小→リリース**の短アニメ＋フォーカスリング。  

### 2.3 Fretboard（ToneOverlay）
- **Chord layer**：選択コードの 1/3/5/7… を **塗り/大/ラベル有**。  
- **Scale layer**：キー/スケール構成音を **輪郭/小/ラベル無**。  
- **Reset**：Chord layer だけをクリアし、Scale layer を**フル表示**に戻す。  
- **Labels**：Degrees/Names の切替は **Chord layer のみ**に反映（Scale は常に無地）。  
- **Dot 色**：Find Key&Scale の色規約に完全一致。

### 2.4 Diatonic
- **Open 行のみ選択可**。選択中は **縮小→ハイライト**で示す。  
- Capo 行は**非活性**（将来の「Capo Advisor」採用時に連動）。

### 2.5 見出し・リズム・カード
- H2: **20/28（SP）→24/32（MD）**、H3: **18/26**。  
- `.ot-card`：角丸 16px、内側 1px ライン（詳細は 4.1）。  
- 縦リズム：`.ot-stack` の `gap = 24px（SP）/ 32px（MD）` **のみ**で管理（個別 `mt-*` は原則禁止）。

---

## 3. スケール（今回反映）
- 既存: Ionian（Major）, Aeolian（Natural Minor）。  
- 追加: **Lydian / Mixolydian / Major Pentatonic**。  
- 今後（計画）：Dorian 他モード、Minor Pent / Blues、Harmonic / Melodic Minor（Pro）。（v2 で定義済のロードマップに沿って段階導入）

---

## 4. 実装差分（CSS/構造）
### 4.1 共通クラス（新規）
```css
.ot-page{{max-width:64rem;margin-inline:auto;padding-inline:1rem}}
@media (min-width:768px){{.ot-page{{padding-inline:1.5rem}}}}

.ot-stack{{display:flex;flex-direction:column;gap:1.5rem}}
@media (min-width:768px){{.ot-stack{{gap:2rem}}}}

.ot-card{{
  background:var(--surface);
  border-radius:16px;
  /* 1pxを確実に見せるためのinset線。必要に応じて実borderを併用 */
  box-shadow:inset 0 0 0 1px var(--line);
  padding:1rem;
}}
@media (min-width:768px){{.ot-card{{padding:1.5rem}}}}

.ot-h2{{font-weight:600;font-size:20px;line-height:28px;letter-spacing:-.01em;margin-bottom:.75rem}}
@media (min-width:768px){{.ot-h2{{font-size:24px;line-height:32px}}}
.ot-h3{{font-weight:600;font-size:18px;line-height:26px;margin-bottom:.5rem}}
```

### 4.2 テーマ・トークン
- Light/Dark/OS 追従で `--bg / --surface / --line` を **常時定義**。  
- `body` は常に `background: var(--bg)`。

---

## 5. 受入基準（追加/更新）
1) **Degrees/Names** が即時切替（欠落0）。  
2) **Reset** で **Chord layer のみ**消え、Scale layer は**元のフル表示**へ復帰。  
3) Diatonic **Open** 押下で Fretboard に **Chord+Scale の二層**。Capo 行は押せない。  
4) 見出し・カード角丸・内パディング・**縦間隔（24/32）**が Find Key&Scale と**一致**。  
5) Show Chords 押下アニメ＋フォーカスリング表示。  
6) **ドット色**は Find Key&Scale と一致。

---

## 6. 既知の未解決事項（必ず引き継ぐ）
### 6.1 枠線（カードの 1px ライン）が消える/薄く見える
- 症状: **Select Key & Scale** のカード枠が場面により消失/薄化。  
- 現状観測:
  - `getComputedStyle(el).borderTopWidth` は **`0px`**（`.ot-card` は `box-shadow` による内側線のため）。  
  - `getComputedStyle(el).boxShadow` は `inset 0 0 0 1px var(--line)` で返るが、**`--line` が空**のタイミングが存在した履歴あり。  
  - Light/Dark の切替や初期ロード順で **一時的に未定義**→可視性低下の可能性。
- 暫定対処（提案）:
  - `.ot-card` に **実 border を併用**し可視を担保  
    ```css
    .ot-card{{ border:1px solid var(--line); box-shadow:inset 0 0 0 1px var(--line); }}
    ```
  - トークン定義を **最上流（globals.css の冒頭）**へ移動し、**あとから上書きされない**順序を保証。  
  - `:root,[data-theme="dark"],@media(prefers-color-scheme:dark)` の **三系**すべてに `--line` を定義。
- 検証手順（DevTools コンソール）:
  ```js
  // 1) トークン健在性
  getComputedStyle(document.documentElement).getPropertyValue('--line').trim()
  // 2) カード線の実体
  const el = document.querySelector('section.ot-card'); const cs = getComputedStyle(el);
  ({ boxShadow: cs.boxShadow, borderTopWidth: cs.borderTopWidth, borderTopColor: cs.borderTopColor })
  ```

### 6.2 マージン（カード間の縦間隔）が一致しないように見える
- 観測: `getComputedStyle(main).gap` は **`32px`**（MD）で計測上は一致。見た目差は**個別の `mt-*`** が混在しうる。  
- 対処（提案）:
  - `main` 直下の**子セクションのみ**で縦リズムを管理（`.ot-stack` の `gap` に一本化）。  
  - ページ内の `mt-* / mb-* / space-y-*` を廃し、`ot-stack` に寄せる。  
- 検証スニペット:
  ```js
  const main = document.querySelector('main.ot-page.ot-stack');
  const cards = [...main.querySelectorAll(':scope > section.ot-card')];
  ({ gap: getComputedStyle(main).gap,
     distanceBetweenCards: (cards[1].getBoundingClientRect().top - cards[0].getBoundingClientRect().bottom)+'px' })
  ```

---

## 7. テレメトリ / QA
- 主要イベント: `overlay_shown`, `view_mode_toggled`, `reset_clicked`, `diatonic_selected`, `show_chords_pressed`。  
- QA観点: ドット欠落0 / Reset後のスケール復帰 / Openのみ選択可 / スマホで Chip 行がはみ出さない。

---

## 8. 今後（P2→P3）
- **スケールの追加**：Dorian 他モード、Minor Pent / Blues、Harmonic/Melodic Minor（Pro）。  
- **Capo Advisor** の導入（Find Key/Scale 近くのサブカード）。  
- **GuideTones レール**（3rd/7th の線路表示）。  
- **Avoid/Tension**（Pro）と**近接ボイシング候補**（Pro）。

---

## 9. 変更履歴（v2.1 → v2.2）
- 画面の 2カード化／見出し・順序の統一。  
- Sounding/Shaped/Compare の **削除**（Find Chord）。  
- Reset の挙動を **Chordのみ解除** に変更。  
- Diatonic の **Open限定選択**化。  
- スケールの **段階追加**（Lydian/Mixolydian/MajPent）。  
- `.ot-page / .ot-stack / .ot-card / .ot-h2 / .ot-h3` を導入。  
- テーマトークン（`--bg/--surface/--line`）の**安定化**。

---

## 付録：コミット/配置方針
- **パス**: `docs/SSOT/OtoTheory_要件定義_v2.2.md`  
- コード側: `globals.css`（共通トークン・クラス）、`find-chords/page.tsx`（構造移行）、`Fretboard.tsx`（Reset/Overlay合成）。