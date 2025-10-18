# 日本語UI訳語マスター v3.1

変更履歴: v3.1 JP terminology alignment

本ファイルは iOS / Web 共通の日本語UI訳語のマスターです。SSOT（docs/SSOT/v3.1_SSOT.md）が最優先です。差分は必ず本ファイル（人間可読）と CSV（機械可読）を同時更新してください。

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

## コード辞典（Chord Library）

| key | EN | JA |
|---|---|---|
| chordLibrary.title | Chord Library | コード辞典 |
| chordLibrary.sub | Choose a Root and Quality to see 3 chord forms side by side with horizontal fretboard layout. Supports Eb, Ab, Bb and other practical keys. Hear them with ▶ Play (strum) and Arp (arpeggio). | ルートとコードタイプを選ぶと、押さえ方が横並びで複数表示されます。Eb、Ab、Bbなどの実用的なキーに対応。▶ Playでストローク、Arpでアルペジオを再生できます。 |
| chordLibrary.formNames | Form Names | フォーム名 |
| chordLibrary.open | Open | オープン |
| chordLibrary.root6 | Root-6 | ルート6弦 |
| chordLibrary.root5 | Root-5 | ルート5弦 |
| chordLibrary.root4 | Root-4 | ルート4弦 |
| chordLibrary.triad1 | Triad-1 | トライアド1 |
| chordLibrary.triad2 | Triad-2 | トライアド2 |

---

運用: 追加・変更時は本ファイルと v3.1_ja_master_terms.csv を同時に更新し、PR本文に「v3.1 JP terminology alignment」を明記してください。
