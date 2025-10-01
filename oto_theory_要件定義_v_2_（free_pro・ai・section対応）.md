# OtoTheory 要件定義 v2（Free/Pro・AI・Section対応）

最終更新: 2025-09-14 オーナー: あなた / 実装: Cursor 前提（TS/React想定）

---

## 0. 目的 / コンセプト（改）

- **シンプル＝直感的**：画面と一文を見た瞬間に「何をすればいいか」が分かる。**高校生でも理解できる平易な書き方**を原則にする（専門語は初出のみカッコで補足＋⒤辞書リンク）。
- **コア体験は Find Key / Scale**：コードを入れる → ①**一文解説** ②**やってみる一手（度数/コード）** ③**着地の目印（3rd/7th）** を即返す。
  - **Section Analyze はこのコア体験の“セクション別レイヤー”**。A/Pre/Chorus/Bridge など各行に対して同じ3点セットを返し、さらに曲全体のサマリ（Keyタイムライン/エナジー/境界の一手）を追加する。
  - **Find Chord** と **Fretboard** は、上記コア体験を補助するツール（ダイアトニックの可視化と指板での即プレイ）。
- **UX原則（Time-to-Value）**
  1. **3–15秒**で1つ学べる（TTFI：一文解説）。
  2. **30–90秒**で1つ弾ける（Try＋着地）。
  3. どの提案も**2タップ以内でA/B**できる（テキスト置換→弾く）。
  4. 一文は**40字前後**、段落禁止。比喩は**1つまで**。
- **情報設計（Find→See→Do→Deepen）**
  - **Find**：Find Key/Scale でキーとモードを掴む。
  - **See**：Diatonic Palette と Fretboard（度数/音名・T/SD/D・ガイドトーン線路）で“見える化”。
  - **Do**：Why→Try と **着地**で即プレイ（A/B）。
  - **Deepen（任意）**：AIの**詳しく知る**で深掘り解説・実例・もう一手（回数制限）。
- **マイクロコピー規範**
  - 文章テンプレ：**「何が起きてる」→「なぜ気持ちいい」→「Try：◯◯」→「着地：◯/◯」**。
  - NG：専門語だけの説明／長い段落／曖昧な助言（“いい感じに”など）。
- **学びの姿勢**：ルールは**候補を絞る道具**、最後は**耳と手が審判**。A/Bで「自分の正解」を決める設計にする。
- **モバイル前提の一貫性**：1カラム＋折りたたみ。親指導線（主要ボタンは下寄せ）。フォーカス順は**入力→解説→Try→着地**。
- **成功指標（KPIの方向性）**：TTFI<5s、**Tryクリック率>40%**、保存/コピー発生率>20%、W1継続↑。

---

## 1. ターゲット / ジョブ

- 既存曲をコピー/分析→**なぜ良いかを言語化したい**。
- 作曲/アレンジ→**一手の提案と理論の裏付け**がほしい。
- ソロ→**ペンタ以外も含めた着地の目印**で“歌えるライン”を作りたい。

---

## 2. プラン設計（Free / Pro / トライアル）

### Free（学びの入口）

- **入力**: 1セクション / 最大 **12コード**
- **許可コード**: **Basic** のみ（スクショ区分を踏襲）
  - Root: A–G（# / b 可）
  - Quick: **M, m, 7, M7, m7, sus4, dim**
- **解析**: キー候補、ダイアトニック一覧、**一文解説**、**やってみる一手**、**着地(3rd/7th)**、Fretboard(度数/音名トグル、コードトーン強調)
- **スケール**: Ionian / Aeolian / Major&Minor Pent / Blues
- **AI**: なし（※Pro体験期間のみ利用可）

### Pro（Founders \$1.99/月）

- **入力**: 複数セクション、コード数実質無制限（内部上限64程度）
- **許可コード**: **Advanced** を含む全て
  - Extensions: **6, m6, 9, M9, m9, 11, M11, 13, M13**
  - Altered: **7b5, 7#5, 7b9, 7#9, 7#11, 7b13, 7alt**
  - Diminished / Variants: **dim7, m7b5**
  - Susp/Add: **sus2, add9, add11, add13, 6/9**
  - Aug / mM7: **aug, mM7**
  - **Slash**: C/E 等のベース指定
- **解析追加**: Section Analyze（A/Pre/Chorus/Bridge…）＋ Song Overview（Keyタイムライン / Energy / Color / カデンツ / 境界の一手）
- **スケール**: Ionian〜Locrian, Harmonic Minor, Melodic Minor（Pent/Blues含む）
- **AI**: 「詳しく知る」ボタンで **Deep解説 / Reharm案 / Melody Fix / Solo Coach**。月 **30回**（同一入力はキャッシュで無料再表示）

### 7日間 Pro 体験（Free → Pro誘導）

- 体験中に **Advanced/セクション/AI** を解放。
- **AI 上限**: 合計 **10回 / 7日**（日次上限なし）。
- 終了後は Free に自動ダウングレード（データは閲覧可）。
- **アップグレード誘導トリガー**: 13個目のコード追加、Advancedタップ、2つ目のセクション追加、AIボタン押下時。

### 認証 / 課金連携（Web × モバイル）

- **Free**: ゲストOK（ローカル保存のみ）。

- **体験/Proは認証必須**。**まずは Google アカウントでログイン（Web/モバイル共通）**。

- **iOS配信前に**「Sign in with Apple」を**追加実装**（ストア審査対応のため）。

- **Web課金（Stripe 等）とアプリ内課金**を**共通アカウント**で連携（サーバでサブスクリプション状態を保持）。

- サインインを促す場面：**Pro体験開始 / Pro購入 / クラウド同期 / 保存上限超過（>3プロジェクト）**。

- 体験中に **Advanced/セクション/AI** を解放。

- **AI 上限**: 合計 **10回 / 7日**（日次上限なし）。

- 終了後は Free に自動ダウングレード（データは閲覧可）。

- **アップグレード誘導トリガー**: 13個目のコード追加、Advancedタップ、2つ目のセクション追加、AIボタン押下時。

---

## 3. 主要機能

### 3.0 Chord Reference（コード辞書・3パターン）

**目的**: 各コードに対して「すぐ弾ける3ボイシング」と「高校生OKの一文解説」を提示し、学び→即プレイを繋ぐ。

- **表示**: 1コードにつき **3パターン**
  - **Open/Easy**（開放 or 低フレットの握りやすい形。なければ上位3弦のコンパクト三和音）
  - **Barre（E-shape/A-shape）**（中域ポジション：移調しやすい）
  - **Shell（3rd+7th+root/5th）**（ガイドトーン主体。コードチェンジが滑らか）
- **解説（一文）**: そのコードの「色」と「使いどころ」を40字前後で。例：
  - **Cmaj7**: 明るく穏やか。“家”の響き。長居するF（4th）は主役にしない。
  - **G7**: 次へ引っぱる力（ドミナント）。**C**に進める前の助走に。
  - **Am7**: やわらかい短調。**Dm→G**の前に置くと流れる。
- **Try（1手）**: 例「**Cmaj7 → C6/9**でポップに」（Proで詳細）
- **Fretboard連携**: 選択ボイシングの **1/3/5/7 を濃色**、他のスケール音は薄表示。前後コードの**ガイドトーン線路**を重ねる。
- **Free/Pro**:
  - **Free**: Basicコードのみ（maj, m, 7, maj7, m7, sus4, dim）。各3パターン。
  - **Pro**: Advanced（9/11/13, add/altered, slash, dim7, m7b5…）も3パターン。**代替セット**（drop-2/上位弦セット）を追加表示。
- **Progression連携**: 形をタップで進行に**挿入**。Section Analyze 中は**移動量が最小**のボイシングを優先提案。
- **データ設計（例）**:

```ts
export type ChordShape = {
  id: string;             // "Cmaj7_open_1" など
  quality: string;        // "maj7" | "m7" | "7" ...
  shape: "Open"|"BarreE"|"BarreA"|"Shell";
  rootString: 6|5|4;      // ルートの弦
  baseFret: number;       // ルートのフレット（movableは可変）
  frets: number[];        // 6→1弦。-1=ミュート
  fingers?: (0|1|2|3|4)[];
  intervals: ("1"|"b3"|"3"|"5"|"b7"|"7")[]; // 各弦の度数
  stringSet: "6543"|"5432"|"4321";             // 主に鳴らすセット
};
```

- **生成方針**:
  - Openは**個別定義**（12Key×主要Qual）。
  - Barreは**相対オフセット**で自動生成（E/Aフォーム）。
  - Shellは **4–3–2 弦**中心の drop-2 由来の簡易形。
  - 直前・直後コードから**最短移動**の候補に⭐を付ける（声部連結）。
- **受け入れ基準**:
  - コードを選ぶと**3ボイシング**と**一文解説**が出る。
  - 「挿入」すると進行に追加され、Fretboardと同期。
  - Proでは Advancedでも3ボイシングが出る（slashは**ベース音も強調**）。

---

### 3.1 Find Key + Scale Viewer

- **入力**: コード列（例: `C Am F G | C Am Dm G`）
- **出力**:
  - キー候補（上位3＋確信度%）
  - 推奨スケール（モード）
  - **Diatonic Palette**: I〜vii°（Triad/7th切替、ローマ数字↔実音、T/SD/D色分け）
  - **Fretboard Overlay**: 度数/音名/両方トグル、コードトーン(1,3,5,7)濃色、テンション中抜き
  - **Harmonic Lens**: T/SD/D 色分け＋ **Guide-Tone Rails(3rd/7th の線路)**
  - **Borrowable Palette**: よく使う借用（♭VII / iv / ♭VI など）をサブ表示（タップで薄色表示）

### 3.2 Find Chord++（ダイアトニック拡張）

- ダイアトニック一覧（Triad/7th）を常時表示。
- **Fitメーター**: 追加した任意コードの近縁度（代理/二次ドミナント/借用/完全外）。
- **Idea Chips**: 「推進力↑: ii–V」「明るく: I–II(Lydian)」「ロック感: I–♭VII–IV(Mixo)」などワンタップ提案。

### 3.3 Why → Try（デフォルト表示: 高校生OK）

- **一文解説**（40字前後・用語はカッコで補足）：例「最後の **G→C** で“帰ってきた”感じ（**カデンツ**）が強まる。」
- **やってみる一手**（度数/コードで1案）：例「**G の前に Dm を入れて ii–V** を作る。」
- **着地の目印**（各小節 3rd/7th 1〜2音）：例「**CではE, GではB** に着地。」
- **用語⒤**: タップで1行辞書＋1小節の度数例。

### 3.4 Section Analyze（Pro）

- **入力**: 1行=1セクション。`[A] C Am F G | ...` / `[Chorus] ...`
- **各セクションカード**: Key/Mode、Diatonic、Cadence(完全/偽/半)、Color指数（借用/副次の割合）、Why→Try、着地、ミニメーター。
- **Song Overview**: Keyタイムライン、Energy(T=1/SD=2/D=3 合算)、Contrast(A↔Chorus)、Boundary Coach（境界での“一手”）。

### 3.5 AI Deep Features（Pro / ボタン式）

- **Deep解説**（150–220字）: やさしい言い換え＋作法Tips＋代表例（**最大3件**／日本向けは**日本2 + 海外1**を推奨）＋“もう一手”。
- **Reharm Lab**: 目的（明るく/切なく/ジャジー）→ 度数案を2〜3つ＋短い理由。
- **Melody Fit & Fix**: メロ輪郭（↑→↓）or 着地2〜3音 → 合う/ぶつかる箇所の指摘と“直し方”。
- **Solo Coach**: 2小節の度数ラインを3案（ガイドトーン/テンション/ペンタ）＋推奨CAGED 1つ。
- **品質ガード**: ルールのJSONを渡して言語化のみ。出力は度数ベース。キー外は“借用色”で表示。

---

### 3.6 Capo Advisor（カポ提案）

**目的**: 初心者でも押さえやすい“開放弦多め”の形で弾けるように、\*\*最適なカポ位置とプレイ用キー（CAGED形）\*\*を提案。伴奏の押さえ替え負荷を下げ、録り/ライブの安定度を上げる。

- **入力**

  - 解析済み：Key/Mode、Progression（ローマ数字化）、Chord Reference（押さえやすさ指標）
  - 設定：**Max Capo fret**（0–7, 既定4）、**Prefer Open chords**（ON既定）、**Keep shapes within fret 1–5**（ON）
  - Pro追加：**Singer shift**（±3半音まで試算）、**Left‑handed**（V0.1で対応）

- **出力**

  - **Free**：**Top 1** 提案のみ
    - 例：**Capo 3｜Play as G**（Sounding key: **Bb**）
    - 指標：**Open%**、**Barre減少数**、サンプル1–2小節の**形の対応表**（`I=C→G形` など）
  - **Pro**：**Top 3** 提案＋**Singer shift**候補（±3）／**一括トランスポーズ出力**（Shaped/Sounding 並記）

- **UI**

  - Find Key/Scale の近くに **「Capo Advisor」** ボタン → 提案カード（折りたたみ）。
  - **適用**すると、画面上部に **Capoバッジ**（例：`Capo 3 · Play as G`）を表示。Fretboard/Chord Reference/Progressionの**表記と指板**が**形キー**に同期。
  - Shaped（弾く形）/ Sounding（実音）を**トグル**で切替可能。

- **アルゴリズム（簡易）**

  1. 半音 0–7 の各 **capo=n** を走査 → **形キー = 実キー − n**
  2. 形キーが **C/G/D/A/E/Am/Em/Dm** に近いほど加点（Open候補）
  3. 各コードの**Open可率**、**Barre要否**、\*\*ベース維持（slash）\*\*を評価して **Score**
  4. **Score** 上位を提示。Proは**Singer shift**（±3）も同様にスコアリングして併記

- **マッピング表示**（例）

  - 入力（実音）：`[A] Bb Gm Eb F`
  - 提案：**Capo 3｜Play as G**
  - **Shaped**：`G Em C D`（Open 75% / Barre −2）
  - **Sounding**：`Bb Gm Eb F`

- **Free/Proの境界**

  - Free：Top1のみ・適用可・出力は画面のみ
  - Pro：Top3・Singer shift・**Export**（テキスト/JSON）・**印刷用PDF**（1枚）

- **受け入れ基準（抜粋）**

  - 検出キー/進行から **Top1/Top3** のカポ提案が表示される
  - **適用**で Progression/Chord Reference/Fretboard が**形キー**に同期
  - **Shaped/Sounding** の切替ができる（ローマ数字は常に共有）

## 4. アルゴリズム（ルールベースの骨格）

- **キー推定**: ダイアトニック一致率 + IV–V–I, ii–V–I 加点 – 不自然な外れ減点。
- **Cadence**: 末尾2コードで 完全(V→I)/偽(V→vi)/半(...V)。
- **二次ドミナント**: `X7` → 完全4度上がダイアトニックなら `V/その和音`。
- **借用**: メジャーで `iv, ♭VII, ♭VI` など、マイナーで `V, ピカルディ(Iメジャー)` 等を検出。
- **下降ベース**: 分数含むベース列の連続 −1/−2 半全音が **3音以上** → マーク。
- **Energy**: 小節ごとに T=1/SD=2/D=3 を合算。
- **Fitメーター**: （ダイア内=100 / 代理=80 / 二次=70 / 借用=60 / その他=30 目安）。

---

## 5. 用語リファレンス（アプリ内）

各項目 8行以内＋1小節の度数例。

1. ダイアトニック  2) カデンツ  3) 二次ドミナント  4) 借用(iv/♭VII/♭VI)  5) モード早見(Ionian/Dorian/Mixo/Aeolian/Lydian)  6) ガイドトーン(3rd/7th)  7) ペンタとテンション  8) 下降ベース/分数コード

### 5.1 ダイアトニック（Diatonic）

- **定義**: あるキー/スケールの**構成音だけ**で作った和音と進行。外の音は使わない。
- **仕組み**: 音階の各音を根音に**三度重ね**で7つのコード（**I〜vii°**）。例: **Key C** → C, Dm, Em, F, G, Am, Bm7♭5。
- **印象**: 同じ「家」の中＝**安定して耳なじみ**。進みにくい所は **ii–V–I** で前に押す。
- **見分け方**: 各コードの**構成音が全てスケール内**かを確認。1音でも外れたら**非ダイアトニック**（借用/副次）。
- **使い所**: Aメロや落ち着かせたい場面の**土台**に。色が欲しい時は**少しだけ外側**（借用/副次）を混ぜる。
- **1小節例**: **Key C** → `I–vi–ii–V = C–Am–Dm–G`（全てダイアトニック）。
- **Try**: `G`の前に`Dm`で **ii–V**／`F→Fm→C` で**借用iv**の陰影。
- **EN note**: *Diatonic = chords built only from the key’s scale tones; e.g., C major → C, Dm, Em, F, G, Am, Bm7b5.*

---

## 6. UI/UX ルール

- 1カード= **一文解説 / 一手 / 着地** の3行まで。
- 専門語は **最初だけ（カッコ）補足**＋ ⒤ で辞書へ。
- 画面は **1カラム**。セクションは**縦の折りたたみカード**。AIは折りたたみの中のみ。
- **ローマ数字↔実音**トグルは指板/パレットと連動。

---

## 7. 入力バリデーション / 制限

- **Basic 判定**: `M, m, 7, M7, m7, sus4, dim` のみ（rootは [A–G][#|b]?）。
- **Advanced 判定**: `add9|add11|add13|6/9|sus2|m6|6|9|11|13|M9|M11|M13|m9|aug|mM7|dim7|m7b5|7alt|7b5|7#5|7b9|7#9|7#11|7b13|/` を含む。
- Free は **12コード**まで、**1セクション**のみ。超過/Advanced/セクション追加時はトライアル誘導。
- **丸め表示**（FreeでAdvancedを入力した時）: 例 `E7b9→E7`, `Cadd9→C`, `G/B→G` を提案。

---

## 8. 技術・実装メモ（Cursor向け）

- **スタック**: TypeScript + React（単一ページ開始）/ CSS。外部APIなしでV0可。
- **Auth**: **Google Identity Services (GIS)** で Google ログイン（Web）。モバイルは **Firebase Auth** 経由で Google Provider を利用可。**iOS配信前に Sign in with Apple** を追加し、**アカウント連携**（Google⇄Apple のリンク）を提供。
- **データ**: localStorage にプロジェクト保存、`ai_calls_month` とトライアル進行を保持。ハッシュでAIキャッシュ。
- **フォールバック**: AI失敗/超過時はルール生成文を表示。UXを止めない。
- **多言語**: **英語版先行**（US表記）。日本語は後追いローカライズ。
- **描画**: モバイルは **RNSVG / Skia** を比較検証して最適を採用。
- **オーディオ**: **MVPでは再生なし**（将来はコード/ベースの簡易MIDI再生を追加）。
- **テスト**: 代表進行 **10本**のスナップショットテストで後方互換性を担保。

---

## 9. KPI / イベント

- `free_limit_hit`（13個目/Advanced/Section追加/AI押下）
- `trial_start` / `trial_to_pro`
- `ai_used`（機能別カウント）
- `try_clicked`（置換実行）
- `save_project` / `open_project`
- `weekly_active` / `w1_retention`

---

## 10. 受け入れ基準（抜粋）

-

---

## 11. マイルストーン

- **V0 (Web)**: Freeフロー一式 + Basic解析 + Fretboard + 一文解説/一手/着地 + 用語辞書（最小） + **Googleログイン**（Pro体験/Pro解放用）。
- **V0.1 (Web/Pro)**: Advanced/セクション解放，Song Overview，Idea Chips，Fitメーター。
- **V1 (Web+Mobile)**: AI Deep（10/30回上限）、Reharm/Melody/Solo、キャッシュ、トライアル導線、**iOS向け Sign in with Apple 追加**、Capo Advisor、同期/課金連携強化。

---

- **V0**: Freeフロー一式 + Basic解析 + Fretboard + 一文解説/一手/着地 + 用語辞書（最小）。
- **V0.1**: Pro解放（Advanced/セクション），Song Overview，Idea Chips，Fitメーター。
- **V1**: AI Deep（10/30回上限）、Reharm/Melody/Solo 各機能、キャッシュ、トライアル導線。

---

## 12. リスクと手当て

- **複雑さ**: 画面は1カラム＋折りたたみ。文は短く固定。
- **誤誘導**: AIは“言い換え＋例”に限定し、度数で返させる。ルールが常に根拠。
- **権利**: ユーザー入力のコードのみ扱い。歌詞/音源アップロードは非対応。

---

## 13. デザインシステム（Web/Mobile 共通）

### 13.1 ムード / ブランド

- **雰囲気**: 静かに集中できる“スタジオ感”。クリーン、落ち着き、実験的すぎない。
- **キーワード**: Calm / Focus / Friendly / Musical
- **ボイス**: 短く、動詞から。高校生OKの語彙。専門語はカッコ補足。

### 13.2 カラーパレット（Light/Dark 両対応）

**役割ベースで定義（HEX）**

- **Primary / Brand**: `#4C6EF5`（Blue 500） / Hover `#3B5BDB`
- **Accent**: `#15AABF`（Cyan 600）
- **Success**: `#12B886`
- **Warning**: `#F59F00`
- **Danger**: `#E03131`
- **Neutral**: text `#111827` / muted `#6B7280` / line `#E5E7EB` / bg `#F8FAFC` / surface `#FFFFFF`

**機能和声の色（T/SD/D）**

- **Tonic (T)**: `#4263EB`（安定）
- **Subdominant (SD)**: `#12B886`（広がり）
- **Dominant (D)**: `#F76707`（推進）
- **Borrowed**: `#A78BFA`（借用の外側）
- **Non-diatonic alert**: `#FF8787`（薄色で点線の縁）

**Dark モード**

- bg `#0B1220` / surface `#111827` / text `#E5E7EB` / muted `#94A3B8` / line `#1F2937`
- primary `#748FFC` / accent `#22B8CF` / success `#51CF66` / warning `#FFA94D` / danger `#FF6B6B`

> すべて **WCAG AAA/AA** を満たすように、テキストはコントラスト比 **≥ 4.5** を守る（ボタン文字は ≥ 4.5, 12px 以上）。

### 13.3 タイポグラフィ

- **英語版（先行）**: `Inter, SF Pro Text, Segoe UI, system-ui, sans-serif`
- **日本語版（後追い）**: `Noto Sans JP, Hiragino Sans, system-ui, sans-serif`
- **スケール**（行間含む）
  - H1 24/32, H2 20/28, H3 18/26, Body 14/22, Small 12/18, Mono 13/20
- **数式/度数**はモノスペース可：`ui-monospace, SFMono-Regular, Menlo, Consolas, monospace`

### 13.4 スペーシング / 角丸 / 影

- **グリッド**: 4pt ベース（4, 8, 12, 16, 24, 32, 48）
- **角丸**: Button/Chip 12px, Card 16px, Modal 20px
- **影**: x-small `0 1px 2px rgba(0,0,0,.06)` / small `0 2px 8px rgba(0,0,0,.08)` / medium `0 6px 16px rgba(0,0,0,.10)`

### 13.5 コンポーネントの見た目（抜粋）

- **WhyCard**: Card16px / Primary左縁 3px / 見出しH3 / 本文Body / “Try”は右端のボタン（Primary）
- **Idea Chip**: Chip12px / アイコン＋ラベル / Hoverで`accent`薄塗り
- **Buttons**: Primary=brand, Secondary=surface 輪郭, Ghost=透明（hoverで薄塗り）
- **Inputs**: 12px角丸 / フォーカスリング 2px `#4C6EF5`（`focus-visible`）
- **Icon**: Lucide（24pxライン）を採用

### 13.6 フレットボードの表現

- **ベース**: 背景 `surface`、フレット線 Light=`#CBD5E1` / Dark=`#334155`、ポジションマークは白/薄グレー
- **ノート表示**:
  - **Chord tones (1/3/5/7)**: **塗りつぶし丸**（T/SD/D 色を継承）
  - **Scale tones**: **輪郭のみ**（細線）
  - **Avoid**: **点線の輪郭**＋薄赤
  - **度数/音名トグル**: 中央に `1｜C` の二層表示可
- **ガイドトーン線路**: 細い曲線で 3rd/7th を連結（色はT/SD/Dに準拠、透明度0.6）

### 13.7 グラフ（Energy/Color/Timeline）

- **Energy**: 折れ線（T=1/SD=2/D=3の合計）— `primary`色、点は小
- **Color**: 積み上げバー（Diatonic / Borrowed / Secondary）— 色は上記トークン
- **Key Timeline**: セクションごとにラベル＋確信度バー（灰→色）

### 13.8 モーション

- **Durations**: Toggle 120ms / Card展開 180–220ms / Toast 240ms
- **Easing**: 進入 `cubic-bezier(.2,.7,.2,1)`、退出 `cubic-bezier(.4,0,.2,1)`
- **Reduce Motion**: `prefers-reduced-motion` に従いアニメを最小化

### 13.9 アクセシビリティ

- コントラスト ≥ 4.5 / フォーカスリング常時 / キーボード操作OK
- アイコンには `aria-label` / 重要情報は色だけに依存しない（テキスト/パターン併記）

### 13.10 デザイントークン（CSS変数例）

```css
:root{
  --bg:#F8FAFC; --surface:#FFFFFF; --text:#111827; --muted:#6B7280; --line:#E5E7EB;
  --primary:#4C6EF5; --primary-600:#3B5BDB; --accent:#15AABF;
  --success:#12B886; --warning:#F59F00; --danger:#E03131;
  --t:#4263EB; --sd:#12B886; --d:#F76707; --borrow:#A78BFA; --nondia:#FF8787;
}
[data-theme="dark"]{
  --bg:#0B1220; --surface:#111827; --text:#E5E7EB; --muted:#94A3B8; --line:#1F2937;
  --primary:#748FFC; --primary-600:#5C7CFA; --accent:#22B8CF;
  --success:#51CF66; --warning:#FFA94D; --danger:#FF6B6B;
}
```

### 13.11 クロスプラットフォーム整合

- コンポーネントの**名前・プロップ**を共通化（Web/React Native）
- トークンは**JSON**で管理し、WebはCSS変数、MobileはStyleSheetへ変換
- 1pxラインは**ヘアライン対応**（RNはPixelRatio）

---

## 14. マイクロコピー・テンプレ集（JP）

> ルール：**40字前後・1文**。専門語は（カッコ）で補足。{…}は差し込み。

### 14.1 基本の一文解説（Progression）

- **V→I**：最後の **V→I** で“帰ってくる”（カデンツ）。
- **…V**：**V**で止めて、次に進みたくなる（半終止）。
- **V→vi**：**V→vi** は“ちょっと外す”終わり（偽終止）。
- **ii–V–I**：**ii–V–I** は“助走→ゴール”の王道。
- **IV–V–I**：**IV–V–I** は前に押し出して着地。
- **I–V–vi–IV**：よく聴く並び。耳に残りやすい（Axis）。
- **V/◯**：**V/{target}** は次のコードへ引っぱる“助走”。
- **下降ベース**：ベース **{F→E→D→C}** で“家に近づく”。
- **分数コード**：**{C/E}** は音を下に滑らせてなめらか。
- **トライトーン**：**3rd↔7th**の入れ替わりで緊張が解ける。
- **ペダル**：ベースを据え置くと、上の動きが際立つ（ペダル）。
- **和声リズム**：ここはコードを**長め**に保つと安定。

### 14.2 Try（やってみる一手）

- **ii–V 追加**：**{V}** の前に **{ii}** を入れて **ii–V** を作る。
- **副次ドミナント**：**{X7}** を入れて **V/{target}** の助走を作る。
- **借用 iv**：**{IV}** を **{iv}** にして切なさを足す（借用）。
- **♭VII**：**{I–♭VII–IV}** でロック感（Mixolydian）。
- **Lydian**：**{I–II}** で“空が開く”（#4）。
- **Dorian**：**{i–IV}** で爽やかな短調（♮6）。
- **Aeolian**：**{bVI}** を挟んで陰り（自然短）。
- **Turnaround**：**{V/ii→ii}** を差し込んで回す。
- **半音アプローチ**：目標音へ**半音**で寄せる。
- **Passing dim**：**{C–C#°–Dm}** で滑らかにつなぐ。
- **Slash**：**{G/B}** にしてベースを下げ、つながりを良くする。
- **リズム**：**{G}** を**1拍早く**入れて勢いを出す。

### 14.3 着地の目印（Guide tones）

- **I上**：**I** では **3rd（{E}）** に着地。
- **V上**：**V** は **3rd（{B}）/7th（{F}）** が安定。
- **ii上**：**ii** は **3rd（{F}）** に寄ると滑らか。
- **vi上**：**vi** は **3rd（{C}）** に落ち着く。
- **共通**：拍頭は **3rd/7th**、他は隣接で動かす。

### 14.4 Melody Fit & Fix（直し方）

- **拍頭テンション**：拍頭がテンションなら **3rd** に寄せる。
- **衝突**：ぶつかる音は**半音**ずらして解消。
- **着地**：フレーズ終わりは **3rd/7th** に置く。
- **Lydian**：**#4** は“飾り”。**5th** に帰ると安心。
- **Mixolydian**：**b7** は長居せず **1st/3rd** に戻す。

### 14.5 モードの色（一文）

- **Lydian**：**#4** が光る。**I–II** で明るく開く。
- **Mixolydian**：**b7** でゆるむ。**I–♭VII–IV** が看板。
- **Dorian**：**♮6** が爽やか。**i–IV** が似合う。
- **Aeolian**：**b6** で物憂げ。**i–bVII–bVI**。
- **Phrygian**：**b2** でエキゾチック。扱いは短めに。
- **Harmonic minor**：**#7** で **V7→i** が強く決まる。

### 14.6 Section境界（A→Chorus など）

- **押し出す**：サビ前に **ii–V** を作って前のめりに。
- **切なさ**：**V/vi→vi** を一瞬だけ差す。
- **決める**：**…V→I** で強い着地を作る。
- **静→動**：直前1拍を**休符/保持**してコントラスト。

### 14.7 ベース/分数の言い回し

- **下降**：**{F→E→D→C}** の“滑り台”で家に帰る。
- **分数**：**{C/E}** は軽く下がって滑らかに。
- **ペダル**：**{C}** を据え置き、上だけ動かす（ペダル）。

### 14.8 品質別の一文（Chord）

- **maj7**：明るく穏やか。“家”の響き。
- **7**：次へ引っぱる力（ドミナント）。
- **m7**：やわらかい短調。前後をつなぐ役。
- **dim/dim7**：すべり台。次へ半音で誘導。
- **m7b5**：静かな緊張。**iiø–V–i** によく合う。
- **sus2/4**：にごりを避け、開いた響き。
- **add9 / 6/9**：明るい彩り。長居しすぎない。
- **aug**：上ずる感じ。次で解いて安心を作る。
- **mM7**：切ない光。**i–IV** で映える。
- **alt**：強い緊張。**V** の力を最大化。

### 14.9 Fitメーターの言い回し

- **Diatonic**：そのキーの“ど真ん中”。
- **代理**：役割が近い“入れ替え候補”。
- **副次**：次へ強く引っぱる“助走”。
- **借用**：となりの世界の“色味”。
- **外**：狙って外す。戻り先を用意して。

### 14.10 エラー/ガード（優しく）

- **上限**：Freeは **12コード**まで。続きはPro体験で。
- **Advanced**：このコードはProで解析できます。今は**簡易形**で試せます。
- **AI回数**：AIはあと **{n}回** 使えます（体験）。
- **保存**：ゲスト保存は端末だけ。サインインで同期。

### 14.11 英語版への置換指針（覚書）

- cadence / borrowed / secondary dominant / guide tones / pedal / passing dim などは EN 表記に置換。
- 記号は **I–vi–IV–V, b7, #11** を基本。

---

## 14-Appendix. マイクロコピー・テンプレ集（JP拡張）

> 既存14章のボリュームを約2倍にするための追加テンプレ。40字前後・1文。

### A. 一文解説（Progression 追加）

- **I–vi–IV–V**：懐かしさと前進が両立する定番。
- **vi–IV–I–V**：切なさ→開放→帰還の循環。
- **IV→iv→I**：明→陰→帰りの“名曲手”（借用iv）。
- **bVII→IV→I**：背面から帰る“バックドア”風味。
- **iiø–V–i**：静かな緊張からの短調解決。
- **V/IV→IV**：一度寄せてから落ち着く着地。
- **Imaj7→I6/9**：主和の彩りを明るく継続。
- **bVI→V**：影を作ってから決める強い解決。
- **I→III**：早い明度上げ。歌い出しに映える。
- **I–Imaj7–I7–IV**：主和の段階変化で物語る。

### B. Try（やってみる一手 追加）

- **トライトーン置換**：**{V}** を **{bII7}** に置き換える。
- **vii°/V**：**{vii°/V→V}** で吸引を強く。
- **借用 bVI**：**{bVI→V}** で陰影→解決。
- **bIII**：**{bIII}** を挟んで一瞬だけ外す。
- **サス解決**：**{sus4→3rd}** で解く快感を作る。
- **先取り**：**{次コード}** を**1拍早く**鳴らす（アンティシペーション）。
- **保持**：**{現コード}** を**1拍伸ばす**（サスペンション）。
- **下降パッシング**：**{I–Imaj7–I7–IV}** を試す。
- **bIIdim**：**{I–bII°–ii}** で半音連結。
- **ペダルD**：**{V}** をベースに保ち上だけ動かす。

### C. 着地（Guide tones 追加）

- **IV上**：**IV** は **3rd/7th（{A}/{E}）** が目印。
- **iii上**：**iii** は **3rd（{G#}）** に短く触れる。
- **bVII上**：**bVII** は **3rd（{D}）**、長居しすぎない。
- **借用iv上**：**iv** では **b3（{Ab}）** に落とすと哀感。
- **共通2**：長い音は **3rd/7th**、速い音は**隣接で装飾**。

### D. Melody Fit & Fix（追加）

- **近隣音**：外れたら**隣の音**へ寄せる（隣接音）。
- **逃避音**：外したら**すぐ隣に戻る**（エスケープ）。
- **経過音**：**拍弱で外し→拍強で戻す**。
- **ユニゾン**：ベースと**同音で太く**、次で分かれる。
- **終止**：最後は**長めに置く**（伸ばして着地）。

### E. モードの色（追加）

- **Locrian**：**b5** が不安定。短いスパイスに。
- **Phrygian dominant**：**b2 & #3** で民族的（和声的短由来）。
- **Lydian b7**：**#4 & b7** で都会的（Melodic minor 4th）。
- **Dorian b2**：暗さを足しても**軽やか**。
- **Mixolydian b6**：**b6** でレトロ感。

### F. Section境界（追加）

- **ブレイク**：直前で**全停止**→サビ頭を強調。
- **上昇**：**分数で上向き**にして持ち上げる。
- **逆行**：**下降ベース**で静かに回収して入る。
- **引き算**：ドラム/ベースを一瞬抜き**和音だけ**。
- **合図**：**V** を**2拍伸ばして**合図にする。

### G. ベース/分数（追加）

- **上行**：**{C→D/C→E/C}** で持ち上げる。
- **歩行**：**{C–B–A–G}** と歩いて V へ。
- **反行**：上がるメロに対し**下がるベース**で厚み。
- **オクターブ**：**ベース1→8**で広がり。
- **ドローン**：**5度**のドローンで土台を作る。

### H. 品質（Chord 追加）

- **6**：主和に軽い明るさ。ポップに連続可。
- **9**：キラッとする彩り。強拍は控えめに。
- **11**：IV系で自然。I上は注意（4th衝突）。
- **13**：開放的。ドミナントに合う。
- **7sus4**：緊張は保ちつつ柔らかい。
- **7b9/#9**：スリルを一瞬だけ。
- **7#11**：明るいまま緊張を足す。
- **add11**：アコギで伸びやかに。

### I. Fitメーター文言（追加）

- **近縁内**：同じ家の別部屋。すぐ馴染む。
- **半歩外**：色は足せる。戻り先を意識。
- **強い外**：狙って外す日。着地を決める。

### J. エラー/ガード（追加）

- **未対応表記**：この書き方は未対応です。別表記でお試しを。
- **長文ペースト**：行ごとに分けてください（1行=1セクション）。
- **記号ミス**：`b/#` の半角を使ってください。

---

## 15. Microcopy Templates (EN)

> Rule: \~1 sentence (\~12–18 words). Use US chord/accidental notation.

### 15.1 Core one‑liners (Progression)

- **V→I**: Strong “homecoming” cadence.
- **…V**: Stop on V to keep it hanging (half cadence).
- **V→vi**: Fake ending for a soft twist (deceptive).
- **ii–V–I**: Run‑up then land; the classic move.
- **IV–V–I**: Push forward, then resolve.
- **I–V–vi–IV**: Familiar loop that sticks.
- **V/◯**: A runway pulling into the next chord.
- **Descending bass {F–E–D–C}**: Slides you gently home.
- **Slash {C/E}**: Smooths the step downward.
- **Tritone swap**: bII7 instead of V adds spice.
- **Backdoor (bVII7→I)**: Softer way back to I.
- **I–Imaj7–I7–IV**: Story by shading the tonic.

### 15.2 Try (do one thing)

- Add **ii** before **V** to make **ii–V**.
- Insert **{X7}** as **V/{target}** for extra pull.
- Borrow **iv**: **IV→iv→I** for gentle sorrow.
- Go **I–II** for Lydian brightness (#4).
- Rock it with **I–bVII–IV** (Mixolydian).
- Use **bVI→V** to cast shadow then resolve.
- Tritone sub: **bII7→I** in place of **V→I**.
- **sus4→3**: Resolve the suspension for release.
- Early hit: strike **{next chord}** a beat earlier.
- Passing dim: **I–bII°–ii** for chromatic glue.

### 15.3 Landing (guide tones)

- Over **I**: aim for **3rd**; hold it longer.
- Over **V**: **3rd/7th** are safe targets.
- Over **ii**: slide into the **3rd**.
- Over **IV**: **3rd/7th** outline it clearly.
- Borrowed **iv**: land on **b3** for wistfulness.

### 15.4 Melody Fit & Fix

- If clash on a strong beat, steer to the **3rd**.
- Nudge by **semitone** to clear collisions.
- End phrases on **3rd/7th** for closure.
- Use neighbor tones on weak beats.
- Unison with bass, then split next beat.

### 15.5 Mode color

- **Lydian**: #4 opens the sky. Try **I–II**.
- **Mixolydian**: b7 relaxes. **I–bVII–IV**.
- **Dorian**: nat6 freshens minor. **i–IV**.
- **Aeolian**: b6 adds gloom. **i–bVII–bVI**.
- **Locrian**: b5 is unstable—use briefly.
- **Phrygian dom.**: b2 + #3 = exotic pull.
- **Lydian b7**: #4 + b7 = urban shimmer.

### 15.6 Section boundaries

- Pre‑chorus: build **ii–V** to lean forward.
- Add a one‑beat **break** before the chorus.
- Hold **V** longer as a cue to land.
- Drop bass for a bar to clear space.
- Walk up with slashes into the chorus.

### 15.7 Bass / slash lines

- **C→B→A→G** walks to **V**.
- **C–D/C–E/C** lifts the floor upward.
- Oppose melody: up top, down low for depth.
- Drone the **5th** for a solid bed.

### 15.8 Chord quality blurbs

- **maj7**: bright and calm—homey.
- **7**: pulls forward—dominant force.
- **m7**: soft minor—connective.
- **dim/dim7**: slide by half‑steps.
- **m7b5**: quiet tension; **iiø–V–i** fit.
- **sus2/4**: open, de‑smeared color.
- **add9 / 6/9**: fresh sparkle—don’t overstay.
- **aug**: rising feel—resolve after.
- **mM7**: bittersweet glow.
- **alt**: maximum dominant tension.
- **9/11/13**: color tones; place on weak beats.

### 15.9 Fit meter phrases

- **Diatonic**: center of the key.
- **Substitute**: same job, different look.
- **Secondary**: a runway into its target.
- **Borrowed**: color from a neighbor world.
- **Outside**: aim, then return clearly.

### 15.10 Errors & guards

- Free limits to **12 chords**. Try Pro trial!
- Advanced chord requires Pro; try a **basic preview**.
- You have **{n} AI uses** left in trial.
- Guest saves live on this device. Sign in to sync.

---

## 16. スタイル別マイクロコピー（JP）

> ブルース / ジャズ ii–V–I / City Pop / J‑Pop 専用のテンプレ。各1文・40字前後。{…}は差し込み。

### 16.1 Blues（12小節 / Shuffle / Blues語彙）

**一文解説（進行）**

- **I7–IV7–I7**：主和も7thで、最初から渋い。
- **V–IV–I–V**：最後の合図。コール&レスポンス。
- **Quick IV**：2小節目に **IV7** でブルース加速。
- **I–VI7–ii7–V7**：ジャズ寄りの回し（ターンアラウンド）。
- **bVI→V**：影を作ってからVへ。歌が映える。

**Try（一手）**

- **♭3→3** を**素早く**行き来して表情を作る。
- **I7** 上で **mixolydian**、所々 **blues scale**。
- **V7** に **b9/#9** を一瞬だけ（スリル）。
- **IV7→I7** は **sus4→3rd** で解く。
- **終わり**は **I7–IV7–I7–V7** で回す。

**着地（目印）**

- **I7**：**3rd（{E}}）/b7（{Bb}）**。
- **IV7**：**3rd（{A}）/b7（{Db}）**。
- **V7**：**3rd（{B}）/b7（{F}）**。

**ソロ/メロ（度数）**

- **Blues**：`b3–3–1–b7–5` を軸に。
- **Mixolydian**：`1–2–3–5–6–b7` を回す。
- **Call&Response**：`(1小節) フレーズ → (次) 返答`。

**ベース/リズム**

- **Shuffle**：跳ねる8分。**ベース 1–3–5–6** の型。
- **Stop time**：**I** を長く保持して歌を前へ。

### 16.2 Jazz ii–V–I（Bebop / Tritone / Minor iiø–V–i）

**一文解説**

- **ii–V–I**：助走→着地。ガイドトーンで繋ぐ。
- **V→I**：**3rd↔7th** の入替で解ける。
- **iiø–V–i**：静かな緊張から短調に落ちる。
- **Tritone**：**bII7** でVの代わり。外から着地。

**Try**

- **Enclosure**：目標 **3rd** を上下から挟む。
- **Bebop scale**：**V7** 上で **Mixo+b7** に **maj7** 追加。
- **V/II**：**V/ii→ii** で前のめりに。
- **SubV**：**bII7→I**（ベース半音下行）を試す。

**着地**

- **Imaj7**：**3rd（{E}）/7th（{B}）**。
- **V7**：**3rd（{B}）/b9処理→3rd**。
- **ii7**：**3rd（{F}）** に寄せる。
- **i**（短調）：**3rd（{C}）/7th（{B}）**。

**ライン例（度数）**

- **ii–V–I**：`(ii) 1–2–b3–3 | (V) 5–#5–6–b7 | (I) 7–1–2–3`。
- **iiø–V–i**：`(iiø) 1–b2–b5 | (V) 3–b9–1 | (i) 5–b3–1`。

**リズム**

- **シンコペ**：弱拍で外して、強拍で帰る。

### 16.3 City Pop（Mixo / Lydian / 9th多用 / Slash）

**一文解説**

- **I–bVII–IV**：余裕のある抜け感（Mixo）。
- **I–II**：#4で空が開く（Lydian）。
- **maj7/9**：長く鳴らして都会的に。
- **Slash**：**C–C/B–Am–G** と滑らかに降りる。

**Try**

- **add9** を主和に足して**キラッ**と彩る。
- **V/IV→IV** で一度寄せて落ち着かせる。
- **E7→Am** を一瞬で“切なさ”を足す。
- **Upper-structure**：**V7(#11)** を軽く香らせる。

**着地**

- **Imaj7**：**3rd** を長めに。
- **IVmaj7**：**7th→6th** でスムース降下。
- **bVII**：**3rd** に短く触れて戻る。

**モチーフ/ライン**

- `1–2–5–6`（add9感）/ `3–2–1–7`（帰還）。

**ベース**

- **分数**で半音/全音の**階段**を作る。

### 16.4 J‑Pop（Axis / 借用iv / 偽終止 / Key↑）

**一文解説**

- **I–V–vi–IV**：耳に残る王道（Axis）。
- **IV–V–I**：サビに向けて押し出す準備。
- **IV→iv→I**：名曲感の陰影（借用iv）。
- **V→vi**：少し外して切なさ（偽終止）。
- **半音上げ**：ラストでKeyを上げて高揚。

**Try**

- サビ頭に **I–II** を置き、明度を一段上げる。
- A→サビの直前に **ii–V** を作る。
- **E7→Am** を一瞬だけ（V/vi）。
- 間奏は **I–V/IV–IV** で広げる。

**着地**

- **I**：**3rd**、**V**：**3rd/7th** を確実に。
- **vi**：**3rd** で柔らかく降りる。

**ライン/メロ**

- 大きめの跳躍→**3rd着地**で歌い上げ。
- サビ終わりは **5→3** で決める。

---

## 17. Style Microcopy Packs (EN)

> Blues / Jazz ii–V–I / City Pop / J‑Pop. One‑liners \~12–18 words.

### 17.1 Blues

**Progression**

- **I7–IV7–I7**: tonic is gritty from bar one.
- **V–IV–I–V**: call and response into the tag.
- **Quick IV**: hit IV7 in bar 2 for lift.
- **I–VI7–ii7–V7**: jazzy turnaround.
- **bVI→V**: cast shade, then resolve hard.

**Try**

- Snap **b3→3** often—instant blues face.
- **I7**: mixolydian with blues notes sprinkled.
- Touch **b9/#9** on **V7** briefly.
- Resolve **sus4→3** on IV7→I7.
- Tag with **I7–IV7–I7–V7**.

**Landings**

- **I7**: **3rd/b7**; **IV7**: **3rd/b7**; **V7**: **3rd/b7**.

**Lines**

- Blues cell: `b3–3–1–b7–5`.
- Mixo run: `1–2–3–5–6–b7`.

**Feel**

- Shuffle 8ths; bass **1–3–5–6**.

### 17.2 Jazz ii–V–I

**Progression**

- **ii–V–I**: link by guide tones.
- **iiø–V–i**: quiet tension to minor.
- **Tritone**: **bII7** in place of V.

**Try**

- **Enclose** the **3rd** above/below.
- **Bebop**: add **maj7** to V mixolydian.
- **bII7→I** with chromatic bass.

**Landings**

- **Imaj7**: **3rd/7th**; **V7**: **3rd**; **ii7**: **3rd**; **i**: **3rd/7th**.

**Lines**

- `ii: 1–2–b3–3 | V: 5–#5–6–b7 | I: 7–1–2–3`.

### 17.3 City Pop

**Progression**

- **I–bVII–IV**: relaxed Mixolydian ease.
- **I–II**: Lydian open sky (#4).
- **maj7/9** held longer = urban sheen.

**Try**

- Add **add9** to tonic; keep it airy.
- **V/IV→IV** as a gentle settle.
- **E7→Am** pinch for melancholy.

**Landings**

- Hold **3rd** on **Imaj7**; skim **3rd** on **bVII**.

**Bass**

- Use slashes to make stepwise stairs.

### 17.4 J‑Pop

**Progression**

- **I–V–vi–IV**: sticky earworm loop.
- **IV–V–I**: pre‑chorus push.
- **IV→iv→I**: classic bittersweet turn.
- **V→vi**: soft twist (deceptive).
- **Up‑key**: last chorus lift.

**Try**

- Chorus head: **I–II** for brightness.
- Build **ii–V** right before chorus.
- Flash **E7→Am** (V/vi) quickly.

**Landings**

- Aim **3rd** on **I**; **3rd/7th** on **V**; **3rd** on **vi**.

**Melody**

- Big leap then **3rd landing**; end **5→3**.

---

## 18. 運用・法務・計測ガイド（実装前に決めておく）

### 18.1 プロダクト/UX

- **Onboarding**：サンプル進行で「貼る→解説→Try→着地」を1回体験。
- **空状態**：Paste/Picker誘導の短文、ボタンは下寄せ。
- **失敗時**：AI失敗/超過、未対応表記、Free上限のガード文（14章テンプレ使用）。
- **個人設定**：表記（EN/JA）、ヒント量（Basic/Advanced）、左利き/カポはV0.1。
- **共有/出力**：JSONエクスポート、ProはPDFワンシート。

### 18.2 理論エンジン/解析

- **パーサ仕様**：半角 b/#、`♭/♯` は自動置換。空白/改行の扱い、`/`のベース指定、Enharmonic丸め（Db↔C#）。
- **スナップショット**：代表10本＋エッジケース（分数連発/7alt連打/表記ゆれ/Locrian）。
- **スキーマ**：`analysis_v1` を付与し後方互換。

### 18.3 AI運用

- **I/O固定JSON**・**出力上限**厳守。**UIは即ルール表示**、AIは非ブロッキング表示。
- **キャッシュ**：`hash(key+mode+facts)`、保持30日。実例は**辞書優先**、AIは補完で**断定回避**。

### 18.4 決済/アカウント

- **連携**：Stripe/StoreKit/Playをサーバで統合。レシート検証と定期リコンシリエーション。
- **体験の乱用**：端末+アカウント+支払手段で重複検知。再体験は不可。
- **解約**：即時ダウングレード。データは閲覧可。

### 18.5 同期/保存

- **ゲスト**=localStorage、**Pro**=クラウド同期。壊れたJSONは救済読み込み（未知トークンはスキップしログ）。

### 18.6 計測/実験

- 追加イベント：`onboarding_complete`, `empty_try_clicked`, `export_json`, `copy_try`, `ai_cache_hit`。
- A/B：体験の出し所（Advanced/セクション/AIボタン）、価格（Founders後）。

### 18.7 性能/品質

- **TTFI ≤ 2s**、解析 ≤ 50ms（12コード）。AIは背景ではなく**任意発火**。
- **ログ/クラッシュ**：Web/モバイルで Sentry 等を導入。
- **描画**：低解像度端末で指板の視認性を検証。

### 18.8 アクセシビリティ/翻訳

- **コントラスト ≥ 4.5**, `:focus-visible`、色以外の手掛かり。EN/JAの用語マッピングJSON。JPは+20%長文を見込む。

### 18.9 法務/ポリシー

- ToS/Privacy/EULA：教育目的、**ユーザー入力のコードのみ解析**を明記。13歳未満不可（COPPA）。
- ライセンス：フォント/アイコン（Inter/Noto/Lucide）台帳。

### 18.10 ブランド/ストア/サポート

- タグライン：EN “See the music. Play smarter.” / JA “見える→弾ける”。
- ストアSS：貼る→解説→Try→着地の4枚で統一。
- フィードバック：簡易フォーム＋状態JSON添付（同意制）。FAQ整備（AI回数/Pro範囲/保存先）。

---

