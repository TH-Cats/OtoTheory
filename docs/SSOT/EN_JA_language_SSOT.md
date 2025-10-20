# 日本語UI訳語マスター v3.1

変更履歴: v3.1 JP terminology alignment

本ファイルは iOS / Web 共通の日本語UI訳語のマスターです。SSOT（docs/SSOT/v3.1_SSOT.md）が最優先です。差分は必ず本ファイル（人間可読）と CSV（機械可読）を同時更新してください。

## ⚠️ 重要：翻訳作業の必須手順

**すべての翻訳作業を行う前に、必ず本ファイル（EN_JA_language_SSOT.md）を確認してください。**

1. 新しいUI要素の翻訳が必要な場合
2. 既存の翻訳を修正する場合  
3. コード内で日本語文字列を追加・変更する場合

**上記のいずれの場合も、まず本ファイルで該当する訳語が定義されているかを確認し、定義されていない場合は本ファイルに追加してから実装を行ってください。**

この手順により、一貫した翻訳品質と用語統一を保証します。

## スケールコメント翻訳ルール

スケール情報のコメントセクション名の翻訳ルール：

| 英語 | 日本語 |
|------|--------|
| Degrees | 構成度数 |
| Vibe | 雰囲気 |
| Usage | 利用シーン |
| Try | 使ってみよう |
| Theory | 理論 |

**参照ファイル**: `/Users/nh/App/OtoTheory/docs/content/OtoTheory Scale v.3.csv`

この翻訳ルールは、WebアプリケーションのScaleInfoBodyコンポーネントとCSVファイルの両方で使用されます。

## メニュー

| key | EN | JA | notes |
|---|---|---|---|
| nav.progression | Chord progression | コード進行 | |
| nav.findChords | Find chords | コードを探す | |
| nav.chordLibrary | Chord Library | コード辞典 | 「ライブラリ」→「辞典」 |
| nav.resources | Resources | 参考 | SSOT上も本表記に統一 |

## コード進行（Chord Progression）

| key | EN | JA | notes |
|---|---|---|---|
| progression.buildTitle | Build progression | コード進行を作る | |
| progression.chooseChords | Choose chords | コードを選ぶ | |
| action.reset | Reset | リセット | |
| nav.sketches | Sketches | My進行 | v3.1 用語 |
| nav.presets | Presets | プリセット | 綴り修正（Prisets→Presets） |
| action.add | Add | 追加 | |
| action.analyze | Analyze | 分析 | 録音UIは現状非露出（Flag OFF） |
| label.result | Result | 結果 | |
| hint.clickAnalyze | Click Analyze to see results. | 分析をクリック | 必要に応じて補足可 |
| section.tools | Tools | ツール | |
| section.fretboard | Fretboard | フレットボード | 綴り修正（Fretboad→Fretboard） |
| label.key | Key | キー | |
| label.scale | Scale | スケール | |
| tone.acousticSteel | Acoustic Steel | アコースティックギター | |
| tone.acousticNylon | Acoustic Nylon | クラシックギター | |
| tone.electricClean | Electric Clean | クリーントーン（エレキ） | |
| tone.distortion | Distortion | ディストーション | 綴り修正（Distorsion→Distortion） |
| tone.overDrive | Over Drive | オーバードライブ | |
| tone.muted | Muted | ミュート | 余分スペース除去 |
| tone.piano | Piano | ピアノ | |
| fb.degrees | Degrees | 度数 | |
| fb.names | Names | 音名 | |
| section.diatonic | Diatonic | ダイアトニック | |
| fb.open | Open | オープン | |
| section.roman | Roman | 度数進行 | 非ヘプタ時は非表示（SSOT準拠） |
| section.cadence | Cadence | カデンツ（終止形） | |

## スケール名

| key | EN | JA |
|---|---|---|
| scale.major | Major Scale | メジャースケール |
| scale.dorian | Dorian Scale | ドリアンスケール |
| scale.phrygian | Phrygian Scale | フリジアンスケール |
| scale.lydian | Lydian Scale | リディアンスケール |
| scale.mixolydian | Mixolydian Scale | ミクソリディアンスケール |
| scale.naturalMinor | Natural Minor Scale | ナチュラルマイナースケール |
| scale.locrian | Locrian Scale | ロクリアンスケール |
| scale.majorPentatonic | Major Pentatonic | メジャーペンタトニック |
| scale.minorPentatonic | Minor Pentatonic | マイナーペンタトニック |
| scale.bluesMinor | Blues Scale (minor) | ブルーススケール（マイナー） |
| scale.harmonicMinor | Harmonic Minor | ハーモニックマイナー |
| scale.melodicMinor | Melodic Minor Scale | メロディックマイナースケール |
| scale.diminishedWholeHalf | Diminished Scale (Whole-Half) | ディミニッシュスケール（ホール・ハーフ） |
| scale.diminishedHalfWhole | Diminished Scale (Half-Whole) | ディミニッシュスケール（ハーフ・ホール） |

## コードを探す（Find Chords）

| key | EN | JA |
|---|---|---|
| find.selectKeyScale | Select Key & Scale | キーとスケールを選択 |
| label.scale | Scale | スケール |
| label.result | Result | 結果 |
| section.diatonic | Diatonic | ダイアトニック |
| fb.open | Open | オープン |
| section.fretboard | Fretboard | フレットボード |
| fb.degrees | Degrees | 度数 |
| fb.names | Names | 音名 |

## 非ヘプタトニック（Pentatonic/Blues）注釈

| key | EN | JA |
|---|---|---|
| nonHepta.diatonicHeaderPent | Ionian (7-note) shown as scaffold with Major Pentatonic (5 notes) overlaid. Dotted circles mark missing degrees. | この表はIonian（7音）を土台に、Major Pentatonic（5音）を重ねて表示しています。点線○はPentで欠落する度です。 |
| nonHepta.diatonicHeaderBlues | Aeolian scaffold with Blues (6 notes). ◇ marks non-diatonic b5 (blue note). | Aeolian（7音）を土台に、Blues（6音）を重ねています。◇は非ダイアトニックのb5（ブルーノート）です。 |
| nonHepta.capoNote | Capo suggestions are based on the 7-note scaffold. Missing pent/blues degrees may not appear in the fingering. | Capo提案は7音の土台スケールに基づいています。Pent/Bluesの欠落度はボイシングに含まれない場合があります。 |
| nonHepta.scaffoldIonian | Ionian scaffold | Ionian土台 |
| nonHepta.scaffoldAeolian | Aeolian scaffold | Aeolian土台 |
| nonHepta.missingDegrees | Missing degrees | 欠落度 |
| nonHepta.blueNote | Blue note | ブルーノート |
| nonHepta.nonDiatonic | Non-diatonic | 非ダイアトニック |

---

運用: 追加・変更時は本ファイルと v3.1_ja_master_terms.csv を同時に更新し、PR本文に「v3.1 JP terminology alignment」を明記してください。
