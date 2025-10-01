# OtoTheory v2.4 実装要件定義（最終版）

> 本文書は **v2.4 実装要件定義の最終版** です。過去の要件定義（v2.3以前および各Addendumドラフト）より本書が常に優先されます。\*\*。Cursorフィードバックを反映し、Next 15系／PCP12方式などを更新しました。

---

## 0. ゴール / スコープ

- **Analyze（Recording-first）** の体験を最小構成で完成（Key候補≤3＋%、Scale、Diatonic、Fretboard二層、音が鳴るUI）。
- **録音→停止後解析**は **サーバ実行（PCP12 JSON方式）**。Conf%表示、低信頼時のヒント。
- **Lite上限（12コード）/Undo=直前1手/プリセット/自動ループ**の完成。
- **Find Chord**の\*\*Scale table（MVP=各コード2スケール＋Why/Glossary＋下地切替＋短いアルペジオ）**と**Chord forms（Open/Barreのみ）\*\*の実装。
- **Modulate/Substitute／Compactフォーム**は **vNext**。

---

## 1. アーキテクチャ / 環境

- **Next.js 15.x + TypeScript**（App Router / Route Handlers）。
- **/api/analyze** は **Vercel Node.js Serverless（runtime='nodejs'）**。Edge対象外。
- **UI共通トークン/クラス**: `.ot-page` / `.ot-stack` / `.ot-card` / `.ot-h2` / `.ot-h3`。
- **音**: Web Audio API（単音/和音/軽ストラム、Attack≈4ms/Release≈120ms、最大6声）。
- **Feature Flags / ENV**
  - `NEXT_PUBLIC_FEATURE_AUDIO_SUGGEST`
  - `NEXT_PUBLIC_FEATURE_KEY_ENGINE=essentia-js`
  - `NEXT_PUBLIC_FEATURE_CHORD_ENGINE=essentia-js`
  - `NEXT_PUBLIC_FEATURE_SERVER_FALLBACK=false` ※Phase1未使用（予約）
  - `NEXT_PUBLIC_AUDIO_MAX_SEC=20`
  - `CONF_THRESHOLD_LOW=0.58`

---

## 2. 画面 / 主要フロー

### 2.1 Analyze（Recording-first）

- **入力チップ**: `[ 🎤 Record ] [ Key&Scale ]`（Chord入力はFind Key側へ集約）。
- 🎤Record: 録音停止時にPCP12を生成→`/api/analyze` へJSON送信。
- Key&Scale: 指定すると同じResultCardへ反映。
- **ResultCard**: Key候補（≤3, %）→ Scale → Diatonic(I–VII) → Fretboard二層 → Why/Glossary。
- **非ヘプタ**: Roman非表示、Capo行 disabled、ヒント表示。音が鳴る（Diatonic=和音 / Fretboard=単音）。

### 2.2 Find Key / Find Chords

- **Find Key**: 正規のChord入力UI。進行入力→解析→Key/Scale候補、Roman行、Cadence/Patterns検出、Fretboard、DiatonicCapoTable統合、Find Chordsへのリンク。
- **Find Chords**: Key/Scale選択→DiatonicCapoTable→Fretboard→InfoDot。
- **Scale table（MVP）**: 各コードに2スケール提示＋Why短文＋Glossary＋下地切替＋短いアルペジオ試聴。
- **Chord forms**: v2.4はOpen/Barreを右クリック/長押しで表示。CompactはvNext。
- **簡易Progression builder**: 「＋Add to progression」→Find Keyで編集。Lite制約適用。

### 2.3 Chord Progression Lite/Pro

- **Lite**: 12コード上限（9–12警告、13ブロック＋Pro誘導）、Undo=直前1手、プリセット3–5種、自動ループ。Freeは画像/テキストエクスポート可。
- **Pro**: 将来のセクション進行、MIDI出力。

---

## 3. コンポーネント / 仕様要点

- **ToneOverlay**: Scale層=輪郭/小/無地、Chord層=塗り/大/ラベル。ResetはChordのみ。Degrees/Namesトグル。色弱配慮。
- **Diatonic表**: Open行のみ選択可。押下で軽ストラム再生＋Chord層強調。
- **Scale table（MVP）**: Ionian/Lydian, Aeolian/Dorian, Mixolydian 等。Why短文、Glossary。Chip押下で下地切替＋アルペジオ再生。
- **Chord forms**: v2.4はOpen/Barre。Compactは付録で設計保持。
- **Progression Lite**: 12上限/Undo1手/プリセット（I–V–vi–IVなど）。
- **InfoDot**: Degrees/Notes in C/About/Examples。

---

## 4. 録音 / 解析 / 再生

### 4.1 録音

- `getUserMedia` + `MediaRecorder`。UIはREC点滅/進行バー/残り秒数。12s標準、4–20s。
- Last take再生可。

### 4.2 解析（Phase1: PCP12 JSON）

- クライアント: 録音停止時にデコード→PCP12算出。
- サーバ: `/api/analyze` にJSON送信し、キー投票＋Conf%合成。
- Request: `{ pcp12:[…12], lengthSec:8.4, snrHint:21.5 }`
- Response: `{ keyCandidates:[…], conf:0.64, pcp12:[…], advice:"…" }`
- Phase2: Essentia.js WASM導入／音声バイナリ対応。

### 4.3 再生

- 単音: Attack 3–5ms/Release 80–150ms。最大6声。
- 和音: 同時 or 軽ストラム。再生中は視覚強調。

### 4.4 Scale table試聴

- MVP=短いアルペジオ。将来=和音ブロック追加。

---

## 5. Free / Pro ガード

- **Lite**: 12コード上限（9–12警告、13ブロック）。Undo=直前1手。プリセット＋自動ループ。
- **Pro**: セクション進行/MIDI等（vNext）。

---

## 6. Telemetry

- 基本: `page_view, key_pick, scale_pick, diatonic_pick, overlay_shown, fb_toggle, overlay_reset`
- 再生: `play_note, play_chord, progression_play`
- 録音: `audio_record_start, audio_record_stop, audio_analyze_ok, audio_analyze_conf(level)`
- トースト/広告: `toast_shown(kind), ad_shown(page)`

---

## 7. A11y / i18n / 表記

- roving-tablist, フォーカスリング, 色以外の手掛かり。
- 英語UIラベル統一（Add/Preview/Capo等）。
- English表記=maj7初期値。非ヘプタ=Roman非表示。Pentatonic=欠落音を点線○。

---

## 8. NFR

- TTFI ≤2s、進行解析≤50ms、Overlay再描画≤16ms。
- 解析はWorker/サーバ非ブロック。例外時はベース表示維持。
- A11yコントラスト≥4.5。

---

## 9. 受け入れ基準（DoD 抜粋）

1. Analyzeは[Record/Key&Scale]入力、Find KeyはChord入力正規UI。両者は同一ResultCardを共有。
2. 二層Overlay。Reset=Chordのみ。Degrees/Names即時切替。
3. 録音停止→PCP12送信→Key候補≤3＋Conf%表示。“From recording”バッジ。低Conf時ヒント。
4. Diatonic押下で音が鳴る＆Chord層強調。ResetでScale残存。
5. Lite: 12上限/9–12警告/13ブロック＋Pro誘導。Undo1手。プリセット→自動ループ。
6. Find Chords: Scale table（2スケール＋Why＋切替＋アルペジオ）動作。Glossary参照可。
7. 非ヘプタ: Roman非表示、Capo行disabled、ヒント表示。
8. Telemetry: 全イベント1操作=1発火。

### 9.1 Conf% 表示/トースト

- Conf% High≥0.85, Medium0.58–0.84, Low<0.58。バッジ色差。
- トースト: 上限警告/ブロック/Undo/Low Conf文言を統一。Telemetryにlevel付加。

---

## 11. マイルストーン

- M0 Baseline
- M1 Playback
- M2 AudioSuggest（PCP12→サーバ）
- M3 Lite Polish（12上限/Undo/プリセット/広告）
- M4 Find Chord強化（Scale table, Chord forms, Builder）
- M5 Polish（録音UI拡張, A11y, 性能）
- vNext（Modulate, Compactフォーム, MIDI）

---

## 12. 決定事項（Cursor回答反映）

- `/api/analyze` Phase1=PCP12 JSON方式。Phase2=Essentia.js(WASM)+音声デコード。
- Conf%算出式: `22*scaleFit+42*rootStrength+20*KS+16*temporalVotes`。閾値0.58/0.85。
- Scale table試聴=MVPはアルペジオ。将来和音ブロック。
- Chord forms=Open/Barre実装。Compact=vNext。
- Liteエクスポート=PNG優先。SVG将来。
- 広告=Result直下、高さ96–120px。`!isPro`条件。
- 残オープン: Why短文テンプレ, Barre度数ラベル位置, PNG背景設定。

---

## 13. 付録（ENV例）

```bash
NEXT_PUBLIC_FEATURE_AUDIO_SUGGEST=true
NEXT_PUBLIC_FEATURE_KEY_ENGINE=essentia-js
NEXT_PUBLIC_FEATURE_CHORD_ENGINE=essentia-js
NEXT_PUBLIC_FEATURE_SERVER_FALLBACK=false
NEXT_PUBLIC_AUDIO_MAX_SEC=20
CONF_THRESHOLD_LOW=0.58
```

---

## 14. 参考実装スケルトン（Phase1／PCP12 JSON）

```ts
// src/app/api/analyze/route.ts
import { NextRequest, NextResponse } from 'next/server'
export const runtime = 'nodejs'

const CONF_THRESHOLD_LOW = Number(process.env.CONF_THRESHOLD_LOW ?? 0.58)

type AnalyzeReq = { pcp12: number[]; lengthSec?: number; snrHint?: number }

function voteKeysFromPCP(pcp12: number[]) {
  // TODO: 既存TSロジックに差し替え
  return [
    { key: 'C', mode: 'major', score: 87 },
    { key: 'G', mode: 'major', score: 62 },
    { key: 'A', mode: 'minor', score: 51 },
  ]
}

function computeConf(scores: { score:number }[]) {
  const [a,b,c] = scores
  const denom = (a?.score ?? 0) + (b?.score ?? 0) + (c?.score ?? 0) || 1
  return a.score / denom
}

export async function POST(req: NextRequest) {
  try {
    const body = (await req.json()) as AnalyzeReq
    if (!Array.isArray(body.pcp12) || body.pcp12.length !== 12) {
      return NextResponse.json({ error: 'pcp12_invalid' }, { status: 400 })
    }
    const scores = voteKeysFromPCP(body.pcp12)
    const top3 = [...scores].sort((x,y)=> y.score - x.score).slice(0,3)
    const conf = computeConf(top3)
    const advice = conf < CONF_THRESHOLD_LOW ?
      'Low signal quality. Try recording again in a quieter room for 4–12s.' : undefined

    return NextResponse.json({
      keyCandidates: top3.map(({key,mode,score})=>({ key, mode, confidence: score/100 })),
      conf,
      pcp12: body.pcp12,
      advice,
    })
  } catch (e) {
    console.error('[analyze] failed', e)
    return NextResponse.json({ error: 'analyze_failed' }, { status: 500 })
  }
}
```

---

*更新完了。Next15対応／PCP12方式などCursor指摘を反映済み。*

