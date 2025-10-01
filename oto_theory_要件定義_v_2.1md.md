# OtoTheory 要件定義 v2.1 — ToneOverlay（指板トーン可視化）統合

版: 2.1  
日付: 2025-09-17 (JST)  
対象: Find Chord / Find Key&Scale の両画面

---

## 0. サマリー（TL;DR）
- 新機能 **ToneOverlay（指板トーン可視化）** を追加し、**Find Chord** と **Find Key/Scale** の両方に統合。
- コードトーン（1/3/5/7等）とスケール音の視覚レイヤーを分離・強調、**“弾ける→理解できる”** を一貫体験に。
- 初期リリースは **Find Chord** に最小機能で導入 → 次に Key/Scale で文脈表示を拡張。
- Free/Pro の切り分け、計測、受入基準、NFR、リリース計画を明記。

---

## 1. スコープ / 目的
### 1.1 目的
- 選択中のコード/キー文脈に応じて、**指板上の「どれを押さえる・どこへ着地する」** を瞬時に可視化し、学習と作曲/演奏を加速する。

### 1.2 スコープ
- 対象画面: **Find Chord**, **Find Key/Scale**
- 対象要素: 指板表示、ローマ数字、Capo、度数/音名表示、Avoid/Tension（Pro）

---

## 2. v2 → v2.1 差分
- 新規: **ToneOverlay** 共有コンポーネントの追加（両画面で利用）
- 追加: ローマ数字の**キー依存表示**（例: C: I–ii–IV–V、G: I–ii–IV–V 等）
- 追加: **Shaped（形）/ Sounding（実音）** トグルと Capo 連動の定義を明確化
- 追加: Free/Pro のガード条件と UIロック/アンロック挙動
- 追加: テレメトリ/AB 設計、NFR、受入テスト

---

## 3. ユースケース（代表）
1) **コードフォームを選ぶ/弾く**（Find Chord）
   - 目的: その場で最短移動のボイシングに素早く決める
   - ゴール: コードトーンが強調され、3rd/7th ガイドで前後遷移が滑らか

2) **曲のキーを把握→機能理解→ソロ設計**（Find Key/Scale）
   - 目的: ダイアトニック機能とターゲット音を文脈で把握
   - ゴール: スケール下地＋選択コード強調＋ローマ数字で“何者か”が一目

---

## 4. 機能要件（ToneOverlay）
### 4.1 表示レイヤー
- **Chord layer（強調）**: 選択コードの度数（例: 1/3/5/7/9/11/13）を**塗りつぶし大ドット**で表示
- **Scale layer（下地）**: 現在のキー/スケールに含まれる音を**輪郭小ドット**で表示（Key/Scale 画面時のみ既定ON）
- **Avoid layer（任意/Pro）**: 回避推奨音を**点線**や**×ハッチ**で控えめ表示（既定OFF）
- **GuideTones（任意）**: 3rd/7th を**微グロー**または**太枠**で強調

### 4.2 画面別の既定挙動
- **Find Chord**: `emphasis = chord`（Chord layer優先表示、Scale layerはOFF）
- **Find Key/Scale**: `emphasis = scale`（Scale layer ON + Chord layer強調）

### 4.3 トグル/設定
- **表示モード**: 度数 ↔ 音名 ↔ 並列表示（スマホは度数/音名の単独表示を既定）
- **Shaped / Sounding**:
  - Shaped: カポ適用後の**押さえる形**基準
  - Sounding: 実際に**鳴っている音**基準
- **GuideTones（3rd/7th）**: ON/OFF（Find Chordは既定OFF、Key/Scaleは既定ON）
- **Avoid/Tension（Pro）**: ON/OFF（既定OFF、Pro解放で利用可能）

### 4.4 ローマ数字（Key依存）
- Key/Scale 画面で、進行リスト/タイムライン/カード上に **I, ii, iii, IV, V, vi, vii°** 等を**キー選択に同期**して表示
- 和声外/借用コードには **bVII**, **IV/5** 等の記法を適用（v2.1 では表示のみ。機能判定の自動付与はP3）

### 4.5 Capo連動
- Capo 値が変更された場合：
  - **Shaped**: 指板表示/フォームはカポ基準位置に再配置
  - **Sounding**: 実音表記/ローマ数字はカポで移調後のキーに追従

---

## 5. Find Chord 仕様（v2.1）
- 目的: **今のコードを即弾ける**ことに最適化
- 既定:
  - Chord layer ON（1/3/5/7 を濃表示）
  - Scale layer OFF（※Key 未指定前提でも機能する）
  - 表示モードは **度数既定**、音名トグルあり
  - GuideTones OFF（任意ON）
- 追加要素:
  - 近接ボイシング候補（P3 で導入）
  - 分数/転回形表示（Pro）

## 6. Find Key/Scale 仕様（v2.1）
- 目的: **キー文脈で機能理解と導線設計**
- 既定:
  - Scale layer ON（下地）＋選択コードは Chord layer で強調
  - ローマ数字 ON（キー依存）
  - 表示モードは **度数既定**、音名トグルあり
  - GuideTones ON（3rd/7th 強調）
- 追加要素:
  - Avoid/Tension 表示（Pro、既定OFF）
  - モード切替（Ionian/Dorian…）のスケール下地反映

---

## 7. UI/表示ルール（最小でわかりやすく）
- **優先度可視化**:
  - Chord tones = 塗り/大ドット、
  - Scale tones = 輪郭/小ドット、
  - Avoid = 点線/×、
  - GuideTones = 微グロー/太枠
- **視覚ノイズ制御**: スマホでは同時レイヤー数を2まで（Chord+Guide / Scale+Chord）
- **カラールール**: ブランドパレット準拠（ダーク/ライト両対応）。色弱配慮で形状も差別化。

---

## 8. データ/ロジック仕様
### 8.1 入力
- chord: root, quality, extensions（7/9/11/13/6/6add9…）, slash-bass（/bass）
- keyContext?: tonic, scaleType/mode
- capo: int（0–8 目安）
- view: degree|note|both
- emphasis: chord|scale
- flags: guideTones, showAvoid, showTension

### 8.2 処理
1) 指板マッピング（12音×弦×フレット）
2) chord formula / scale set 生成
3) レイヤー合成（優先順位: Avoid < Scale < Chord < Guide）
4) 表示モード変換（degree↔note）
5) Capo 移調（Shaped/Sounding 切替で座標/表記を分岐）

### 8.3 出力
- fretDots[]: { string, fret, type: chord|scale|avoid|guide, label: degree|note }
- romanNumeral?: { currentChord: "V7", … }

---

## 9. Free / Pro 切り分け（v2.1）
| 機能 | Free | Pro |
|---|---|---|
| Chord layer（1/3/5/7 強調） | ● | ● |
| 度数/音名トグル | ● | ● |
| Shaped/Sounding + Capo 連動 | ● | ● |
| GuideTones（3rd/7th） | ●（Key/Scale既定ON） | ● |
| Scale layer（下地） | ●（Key/Scale） | ● |
| Avoid/Tension 表示 | – | ● |
| 分数/転回形、6/9 等 | – | ● |
| 近接ボイシング候補 | – | ●（P3） |

- 備考: 表示自体は全ユーザー同一。Pro 機能はトグル/カード上にロック表示（簡易説明＋アップグレード動線）。

---

## 10. テレメトリ / AB 設計
- 主要イベント: `overlay_shown`, `view_mode_toggled`, `guide_toggled`, `capo_changed`, `shaped_sounding_toggled`, `pro_toggle_clicked`, `transition_chord→keyscale`
- KPI: Overlay 利用率、Find Chord→Key/Scale 遷移率、学習セッション継続時間、Pro 変換率
- AB 例: GuideTones 既定ON/OFF の比較（Find Chord）

---

## 11. アクセプタンス基準（抜粋）
1) **Find Chord 単体**
   - 条件: Chord=Cmaj7, Capo=0, Shaped/Sounding=Shaped
   - 期待: 1,3,5,7 が大ドット表示。Scale layer はOFF。度数↔音名トグルで表記が切替。

2) **Key/Scale 文脈**
   - 条件: Key=C Ionian、選択コード=G7
   - 期待: スケール下地にCメジャー、G7 の 1/3/5/b7 が強調、ローマ数字は **V7**。

3) **Capo 連動（Sounding）**
   - 条件: Key=C、Capo=2、Shaped=Am7 を選択
   - 期待: 実音は **Bm7** として表示、ローマ数字はキーCに対し **vii** 相当の表記（※P3で精緻化）。

4) **GuideTones**
   - 条件: 遷移 C→G7→C
   - 期待: 3rd/7th が強調され、“線路”が最短経路で視認可能。

5) **Pro ロック**
   - 条件: Avoid/Tension トグル押下（Free）
   - 期待: 機能説明+アップグレード導線が表示され、指板への影響は出ない。

---

## 12. エッジケース / 既知制約
- 和声外/借用/代理コード: v2.1 では手動指定/表示優先。自動分類はP3。
- 変則チューニング: 標準 EADGBE のみ（拡張要望は別チケット）。
- 表示過多: モバイルは最大2レイヤーまで自動制限（優先: Chord, Guide）。

---

## 13. NFR（非機能要件）
- パフォーマンス: 15フレット表示で Overlay 再計算 ≤ 8ms（95%tile）、再描画 ≤ 16ms。
- アクセシビリティ: 色覚多様性対応（形状/パターン併用）。
- 安定性: 例外時は Overlay を安全に無効化し、ベース表示は維持。

---

## 14. リリース計画
- **P1（v2.1.0）**: Find Chord に ToneOverlay（Chord layer/度数/音名/Capo/Guide 手動）
- **P2（v2.1.1）**: Key/Scale に Scale 下地+ローマ数字+Guide 既定ON
- **P3（v2.2）**: Avoid/Tension、近接ボイシング候補、自動機能判定の精緻化

---

## 15. 表記/Notation ルール（再掲）
- 初期値: **English（maj7）**
- 解放: **6/9**, **/bass** は Pro 機能
- 設定画面で地域表記切替を許容（将来対応）

---

## 16. 追補（開発向けメモ）
- 共有コンポーネント名: `ToneOverlay`
- props: `root, formula, keyContext?, capo, viewMode, emphasis, guide, showAvoid, showTension, shapedOrSounding`
- 出力: `fretDots[]`, `romanNumeral?`
- 単体テスト: フォーミュラ→度数変換、カポ移調、ローマ数字整合
- スナップショット: ダーク/ライト、モバイル/デスクトップ

