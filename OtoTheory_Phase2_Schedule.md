# OtoTheory – Phase 2 Schedule (v2.2 baseline)

> Scope: stabilize UI/overlay, align page rhythm, then layer Capo Advisor & Pro features.  
> Management: milestone-based (no time estimates). Owners — **Owner**: You (spec/acceptance), **Dev**: Cursor (TS/React), **QA**: You (manual + snippets).

## 0) Baseline (locked)
- Unified layout tokens: `.ot-page / .ot-stack / .ot-card / .ot-h2/.ot-h3`.
- Page rhythm: **Find Key/Scale = 12px**, **Find Chord = 6px** (page-scoped).
- ToneOverlay behavior: **Chord (filled/large/label)** + **Scale (hollow/small/no label)**; **Reset** clears Chord only — Scale remains.
- Ads: **Result** card just below (Free), hidden on Pro.
- Theme tokens: `--bg / --surface / --line` stabilized for light/dark.

---

## M1. v2.2.1 “Stabilize Tag”
**Goal:** Ship the tightened rhythm + visible ghosts as a stable tag.

**Scope**
- Enforce page-scoped gaps (Key=12px, Chord=6px) only via `.ot-stack` / page selectors.
- Ad placeholder: consistent card look on both pages.
- Ghost dots: *hue-preserving*, small **hollow rings** using `currentColor` (works in dark).

**DoD**
- Card distances equal measured `gap` (Key 12px / Chord 6px).
- Chord selected → **filled Chord** over **hollow Scale** (two-layer).  
- Reset → Scale stays, Chord layer cleared.
- No A11y console warnings.

---

## M2. v2.2.2 “UI Consistency + A11y”
**Scope**
- Degrees / Names chips — same size; instant toggle on both pages.
- Diatonic table — **Open row only selectable**; Capo rows clearly inactive.
- Low-vision support: duplicate cues (line + size) on Scale ghosts.
- Hairline border: 1px real border + inset fallback; tokens defined at top of `globals.css`.

**DoD**
- Headings, card radii, paddings, and rhythm identical across pages (light/dark).

---

## M3. v2.2 “Instrumentation (Minimal)”
**Events**
- `overlay_shown`, `view_mode_toggled`, `reset_clicked`, `diatonic_selected`, `show_chords_pressed`.

**DoD**
- Events fire on primary actions; basic session log available.

---

## M4. v2.3 “Capo Advisor (Minimum)”
**Scope**
- Add **Top1** suggestion near Find Key/Scale (folded sub-card).
- Card shows: “Capo n | Play as X”, Open% / Barre↓ indicators.
- **Apply** syncs Fretboard & labels to **shape key** (Shaped/Sounding ready).

**DoD**
- From current key/progression, Top1 appears and **Apply** updates UI consistently.

---

## M5. v2.3+ “Guide‑Tone Rails / Avoid・Tension (Pro)”
**Scope**
- Optional **3rd/7th rails** on the fretboard.
- **Avoid/Tension** (Pro): subtle visuals; priority `Avoid < Scale < Chord < Guide`.

**DoD**
- C→G7→C demo: rails clearly visible; Free users see locked toggle + upgrade hint.

---

## M6. Scales (Staged)
**Scope**
- Keep: Ionian/Aeolian; Add: **Lydian / Mixolydian / (opt) Pent/Blues** in stages.
- Reflect selection in Scale candidates + fretboard base layer.

**DoD**
- Switching scales updates base overlay & Roman/diatonic context consistently.

---

## Operational notes
- **Docs**: update `docs/SSOT/OtoTheory_要件定義_v2.2.md` when exceptions (12px/6px) are applied.
- **CSS**: keep page overrides at the **EOF** of `globals.css` to avoid collisions.
- **Acceptance snippets** (safe version):
```js
const main = document.querySelector('main.ot-page.ot-stack'); 
const cards = [...main.querySelectorAll(':scope > section.ot-card')];
const dist = (a,b)=> (a&&b) ? (b.getBoundingClientRect().top - a.getBoundingClientRect().bottom)+'px':'n/a';
({ gap: getComputedStyle(main).gap, d12: dist(cards[0],cards[1]), d23: dist(cards[1],cards[2]) });
```
