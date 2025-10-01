# 機能要件定義 v2.4（最終版・過去の要件定義より本書を優先する）

## 1. Analyze & Build with Theory

1.1 **Result（確定）**: **Key/Scale候補（≤3）**と**適合度%**を表示。Conf%は録音解析のみ。→ Toolsへ誘導。

1.2 **Tools（確定）**:
- **Diatonic表**（I〜VII／Openのみ）＋ **Fretboard**（二層Overlay: Scale輪郭／Chord塗り、Reset=Chordのみ）。
- **Roman表示**: 度数統一。非ヘプタは非表示。ペンタは7音仮定で表示、欠落音は**点線○**。Tooltip: *“Pentatonic = reduced Diatonic”*。
- **Patterns**:
  - **解説**: 入力進行の由来・機能。
  - **Next steps**: 代表的な展開（例: ループ／**ii–V–I**／**IV→ii**／**V/V**／休符）。
  - **Sound preview**（UI英語）: Tap to hear。
  - **＋Add to progression**（UI英語）: ワンタップ追加→即再生。
  - **Undo**（UI英語）: 直前操作を1タップで戻す（トースト “Undo”／⌘Z）。
  - **Glossary links (⒤)**: **Tritone**, **Secondary dominant (V/◯)**, **Modal interchange**, **Subdominant**, **Picardy third**。
- **Cadence advice**:
  - **Tips**: 1文＋例。
  - **Mini list**（UI英語）: **Perfect (V→I)** | **Deceptive (V→vi)** | **Half (...V)** | **Plagal (IV→I)**。
  - **Sound preview**: Tap to hear。
  - **＋Add to progression**: ワンタップで挿入／末尾追加→再生。
  - **Undo**: 直前操作を戻す。
  - **Glossary links (⒤)**: **Perfect cadence / Deceptive / Half / Plagal**。
- **Diatonic表折りたたみ**: 各行を開いて **Capo提案**／**基礎代理コード**を表示。
  - **Capo提案**（UI英語見出し: *“Capo positions easiest for open–chord shapes”*）: shaped名を表示。音は鳴らさない。ローコード適合度から最適2フレットを提示。
  - **代理コード（基礎）**: 最大3候補。試聴／＋追加／Undo。理由を1文表示。フレットボードに共通音強調。

1.3 **Chord Progression Lite**（シンプル進行）: 1行入力 → **Key/Scale候補（≤3、適合度%付き）**を提示。
- **コード数上限（確定）**: 最大12コード（推奨4〜8）。9〜12はソフト警告、13でブロック＋Pro誘導。
- **トースト文言**（UI英語）:
  > **You’ve reached the 12–chord limit. For more, go Pro. Pro unlocks sectional progression editing & MIDI export.**
- **編集操作**: 任意コード削除（×）／ドラッグで順序変更／全リセット（確認＋Undo）。
- **エクスポート（Free）**: コード譜（**選択したKey/Scale名**＋Diatonic＋Fretboard入り画像/テキスト）。**Liteでは明示JSONなし（自動ローカル保存のみ、vNextで再評価）**。
- **プリセット（確定）**: 3〜5種類。1タップで進行挿入→ **自動ループ再生（1小節カウントイン／既定BPM）**。
  - 推奨セット（UI英語ラベル）: **I–V–vi–IV** (Pop standard) / **ii–V–I** (Functional harmony) / **12–bar Blues (basic)** (Blues classic) / **I–II (Lydian flavor)** / **I–bVII–IV (Rock standard)**。
  - UI: 入力欄上に **“Recommended presets”**、右端に **“Start empty”**。再訪時は最後のプリセットを左端に固定。
  - 将来: Key/Tempo置換、スタイルタグ（bright/driving/melancholic）、ユーザープリセット（Pro）。
  - Telemetry: `preset_inserted {id}`, `preset_to_edit`, `preset_bounced`。

1.4 **Chord Progression Pro**（セクション進行）: Verse/Chorus/Bridgeなどセクション別入力 → Key/Scale候補提示。
- **編集操作**: 任意コード削除（×）／小節単位の挿入・削除／セクション内外ドラッグ並べ替え／全リセット（確認＋Undo）。
- **構成編集（確定）**: セクション並べ替え／反復／小節数調整。BPM/拍子はグローバル指定（将来はセクションごと）。
- **エクスポート（Pro）**: MIDI（Chord Track＋**section markers**＋ガイドトーン）。反復は展開して書き出し。将来: MusicXML/ChordPro、クラウド保存・共有リンク。

1.5 **Sound（確定）**: 再生統一ルール。
- **Diatonic表**: ▶試聴（ブロック/ストラム、Attack≈4ms/Release≈120ms、同時6声上限）。
- **Patterns/Cadence**: Add→Play→Undoの流れ。短く再生。
- **進行ビルダー（Lite/Pro）**: BPM、ループ、カウントイン、メトロノーム。反復／並べ替え反映。
- **Fretboard**: ドットクリックで正しいオクターブ音（例: E2/E4）。長押しでスケール上下（1–2oct）。
- **Scaleチップ**: Tapで下地切替＋短い試聴。
- **Capo**: 鳴らさない（shapedのみ）。
- **視覚**: 次コードを−1拍でハイライト。Capo使用時は「UI=形／音=実音」。
- **Telemetry**: `play_chord`, `play_note`, `progression_play`, `pattern_trial`, `cadence_trial`。

---

## 2. Find Chord with Theory

2.1 **Select Key & Scale**（UI英語）: KeyとScaleを選択。

2.2 **Result**: Diatonic (I–VII) → Fretboard（二層、Degrees/Names切替）。

2.3 **Scale table（確定）**: 各コードに**2〜3スケール**表示（例: Ionian/Dorian/Mixolydian）。
- **表示基準（確定）**: Major= **Ionian / Lydian**、Minor= **Aeolian / Dorian**、Dominant7= **Mixolydian**（学習注釈でb9/b13系は⒤誘導）、Half-dim/Dim= **Locrian / Whole–Half Diminished**。
- **Actions（UI英語）**: Tap chip → 下地切替（Chord layer維持）。任意で短い試聴。
- **Labels（UI英語）**: “Melodic” / “Improv.”
- **Why**: 短い理由文（例: Dorian = ♮6で明るく）。
- **Glossary links (⒤)**: 各スケール名にリンク。
- **Placement**: Result直下または各コード詳細折りたたみ（デフォルト閉）。

2.4 **Chord forms（確定）**: 右クリック／長押しで “View forms”。
- **Popup**: **3種（Open/Barre/Compact）**を表示。度数ラベル付き。
- **Reference**: 詳細は専用リファレンスページ。
- **Hint（UI英語）**: “Right–click/long–press to view”。

2.5 **Capo提案**: Find Key/Scaleと同仕様。

2.6 **Progression builder（簡易版）**: Chord/Subクリックで **＋Add to progression**（UI英語）。Find Key/Scale側と同期して再生。
- **移行（確定）**: 簡易版で作成した進行は **“Open in Find Key/Scale”**（UI英語）で移行。

---

## 3. Melody with Theory

3.1 録音→解析→Key/Scale候補（%＋Conf%、低Conf時ヒント）。**サーバ側解析**。

3.2 **Line‑in 推奨（UIバッジ）**: *“Best with line‑in”* を表示。**内蔵マイクは Beta** とし、品質ゲートを適用（例: **SNR ≥ 15dB / Clipping < 1% / 長さ ≥ 8s** 未満は再録ヒント）。

3.3 **Recording tips（UI説明）**: *“Record 10–15s and end on the tonic for better results.”*

3.4 **Lite**:
- 提供機能: Key/Scale候補の提示、Diatonic表とFretboardへの反映。
- 譜面化（Score/TAB）、コード提案（Chord suggestion）、MIDI出力、BPM設定は**利用不可**。UI上はこれらを**薄くマスク表示**し、クリック時にProメリット紹介ページへ誘導。

3.5 **Pro**:
- **Recording BPM（任意）**: 録音前にBPMを設定可能（省略可、既定120）。解析後も調整可。エクスポートに反映。
  - **Preview**（UI英語）: *“BPM preview”* でリアルタイム試聴（メトロノーム同期・1–2小節ループ・**Original / Adjusted** 切替）。選択BPMでの一時レンダーを聴き比べ可能。
- **Score（譜面化）**: Staff/TAB切替、譜頭にKey/Scale・BPM・Time、量子化1/8・1/16、頭出し補正・無音トリム・ベロシティ弱/中/強。Export=PNG、**Pro=MusicXML（将来MIDI）**。
- **Chord suggestion**: 録音メロディに基づき、小節ごとにコード候補を提示。密度1〜2/measure、Style (Pop/Jazz/Blues)、Cadence bias (None/Light/Strong)、Substitution (Off/Basic) の設定可。確定後はScoreにコードシンボルを反映し、MusicXML/MIDI出力に含める。
- **長尺録音対応**（例: 30s〜1分）、クラウド保存対応。

---

## 4. Progression Recording (Pro)

4.1 **統合位置**: Find Key/Scale ページ内の Progression セクション下部に表示。Liteでは薄いマスクカードで *“Record chords (Pro)”* を案内、クリックするとPro訴求ページへ。

4.2 **録音→解析→候補**: セクション単位で録音し、小節ごとに triad 候補（Top-2）を提示。録音由来のみ Conf% を表示。

4.3 **適用フロー**: **Preview A/B → Apply（小節単位またはセクション全体）→ Undo**。反復セクションには *“Apply to repeats”* トグルあり。

4.4 **条件**: v2.4は基本1小節=1コード固定。将来拡張として**1小節2コード**まで解析対応を検討。v2.4ではまず精度安定を優先し、柔軟性はvNextで段階導入。グローバルBPMを使用。Line-in推奨・品質ゲートあり。

4.5 **UI文言（英語）**: “Record chords (Pro)”, “Preview A/B”, “Apply to bars”, “Undo”, “Apply to repeats”。

4.6 **拡張（vNext）**: 1小節2コード、Style (Pop/Jazz/Blues)、Cadence bias、Basic substitutions、セクション別BPM/拍子、多段Undo/Redo。

---

## Notes

- **Undoの深さ（確定）**: Lite=直前1手のみ。Pro=多段Undo/RedoはvNextで検討。
- **Glossary（⒤）範囲ルール（確定）**: 学習でつまずきやすいポイントに限定（T/SD/D、Secondary dominant、Modal interchange、各種終止、Tritone、Picardy thirdなど）。派生はvNextで拡張。
- **UIラベル（英語）統一（確定）**: Add=“＋Add to progression”、Preview=“Sound preview”、移行=“Open in Find Key/Scale”、Capo見出し=“Capo positions easiest for open–chord shapes”。
- Resultカードの流れ（Key→Scale→Diatonic→Fretboard）はv2.4基準体験。
- 二層Overlay／Reset=Chordのみは共通ルール。
- 録音UI: REC点滅／進行バー／“Analyzing…”／Last take再生。
- 代理コード／転調Tipsはv2.4非表示、vNextで再検討。

---

## Backlog / vNext候補（メモ）

- 逆引き検索（Chord name → 属するKey/Scaleと機能）
- Ear Training（典型進行のブラインド再生→答え合わせ）
- まとめビュー（フォーム／代理／スケール対応を1画面集約）
- Humanize (1–5)、Strum feel（up/down比）
- Left‑handed / Drop‑D など簡易チューニング対応（Fretboard切替）
- PWA/オフライン（画像出力のみでも動作）

## QA観点・既知リスク（チェックリスト）

- **Audio再生**: モバイルAutoplay制限→初回タップでAudioContext resume。6声上限・voice stealing。Attack≈4ms/Release≈120msでクリック回避。
- **Capo**: shaped名=実音同一の注記がUIで伝わるか。フォーム参照との整合。
- **Roman（Pentatonic）**: 欠落音の**点線○**がライト/ダーク双方で視認可能か。
- **12コード上限**: Patterns/Cadence/代理のAddで即トースト＆Pro誘導が出るか。
- **画像出力**: Key/Scale名の表示、配色の可読性（ダーク/ライト）、PNG/SVG解像度。
- **i18n**: 英語UI用語の表記統一（Cadence/Scale名/ボタン文言）。
- **A11y**: キーボード操作（→次コード／Space再生）、フォーカスリング、ARIA属性。
- **BPM Preview**: プレビューのレイテンシ/ジッタ、メトロノームとクリックの位相ずれ、**Original/Adjusted** 切替のクリックノイズ、テンポ変更時のピッチアーティファクトが無いこと。

