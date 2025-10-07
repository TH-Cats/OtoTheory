# ChatGPT Solution — Hybrid Audio "伸びる"問題の修正

**日付**: 2025-10-05  
**ソース**: ChatGPT 相談結果  
**ステータス**: 実装準備完了

---

## 🧭 TL;DR（結論）

* **伸びる主因①**：GuitarBounceService のオフラインレンダリングで **ノート開始を `DispatchQueue.asyncAfter` に頼っている**ため、**manual rendering のサンプル位置と同期していない**（「レンダリング進行に合わせて」ノートを打つ必要あり）。
* **伸びる主因②**：`renderOffline` に **総尺サイズのバッファを渡して繰り返し呼んでいる**ため、**書き込み位置を進めずに上書き**している（Scratch→Accum 方式にし、**オフセットにコピー**する必要あり）。
* **拍ズレ/無音の火種**：HybridPlayer が **completionチェーンで次バッファをスケジュール**している（安全だが、**完了後スケジュール**は小さな隙間が起き得る）。**絶対サンプル時刻**で**全バッファを先に並べる**のが堅牢。

---

## ✅ Cursorへの依頼文（コピペOK）

> タイトル：**Hybrid（Guitar=PCM, Bass/Drums=MIDI）— "伸びる"修正パッチ適用**

### 0) 目的

* ギターの1小節PCMが**必ず2.000秒で終わり**、**末尾120msで0まで落ちる**状態を保証する。
* PlayerNode には **絶対サンプル時刻**で全小節PCMを**隙間なく連結**する。
* Sequencer（Bass/Drums）は従来通りでOK（将来のMIDI書き出しとも整合）。

---

### 1) GuitarBounceService.swift の修正（**最重要**）

**現状の問題点：**

* ノート開始が `DispatchQueue.global().asyncAfter` で「壁時計（wall‑clock）」に紐づいている。**manual rendering** はリアルタイムで動かないため、**レンダされたサンプル位置と一致しない**。
* `renderOffline(framesToRender, to: renderBuffer)` を**大きな1本のバッファ**で繰り返し呼んでいる。APIは**先頭から書く**ため、**累積にならず上書き**となる。

**やること（差分方針）：**

1. **イベント駆動のレンダーループ**に変更

   * `events = [(startFrame, note)]` を作る（startFrame = i * strumFrames）。
   * ループで `framesUntilNext = min(block, nextStart - framesRendered)` を計算し、**次イベント直前まで**`renderOffline`。
   * `framesRendered == nextStart` になった**その瞬間に `sampler.startNote`** を呼ぶ。
   * すべてのイベントを打ち終えたら**残りのフレーム**を `renderOffline`。
2. **バッファは Scratch→Accum 方式**

   * `scratch = AVAudioPCMBuffer(capacity: manualRenderingMaximumFrameCount)` を作る。
   * `accum = AVAudioPCMBuffer(capacity: totalFrames)` を用意し、`accum.frameLength = totalFrames` を設定。
   * 各 `renderOffline` の後に **`memcpy` で `scratch` → `accum` の**該当オフセットへコピー。
3. **フェードは `accum` の末尾に適用**（120ms → 0.0）。
4. **Bank指定をGMに揃える**

   * `bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB)`、`bankLSB: UInt8(kAUSampler_DefaultBankLSB)` を明示（`FluidR3_GM.sf2` で安全側）。
5. **完成検証**

   * 末尾1,024サンプルの**最大振幅が -90dB以下**になることを簡易チェック（RMS or maxAbs）。

**備考**：`asyncAfter` は**全削除**。ノート開始は**「フレーム数ベース」**でレンダーループ内に組み込むこと。

---

### 2) HybridPlayer.swift の修正（**小節境界の連結をサンプル時刻で固定**）

**現状の問題点：**

* `scheduleGuitarBuffers` が **completion内で次を登録**している（**完了後登録**）。負荷やスレッド状況次第で**僅かな隙間**が起き得る。

**やること（差分方針）：**

1. **全小節PCMを"絶対サンプル時刻"で先に並べる**

   * `let sr = 44100.0` / `barFrames = AVAudioFrameCount(2.0 * sr)`（BPMに応じて計算）。
   * `var cursor: AVAudioFramePosition = countInFrames`（カウントインの後ろから開始）。
   * 各 `buffer` を `when = AVAudioTime(sampleTime: cursor, atRate: sr)` で `playerGtr.scheduleBuffer(buffer, at: when, options: [])`。
   * `cursor += AVAudioFramePosition(barFrames)` を繰り返す。
2. **`play(at:)` は0.2s先の hostTime**に予約（現状維持）。
3. **onBarChange** は `scheduleBuffer` の `completionHandler` でOK（が、**すでに次バッファは登録済**）。
4. **Sequencerの開始タイミング**

   * **プレイヤの `startHostTime + countInSeconds`** に合わせる（`DispatchQueue`で0.2+countIn後に `sequencer.start()` はOK）。

---

### 3) クリーンアップ＆安全策

* **AUの `reset()` の多用はやめる**（Stop時のみ）。小節ごとの `reset` はボイス破綻の原因。
* **直結が残っていないか**を確認（必ず **Sampler → SubMix → MainMixer** に一元化）。
* **Drum（Percussion）**は BankMSB を `kAUSampler_DefaultPercussionBankMSB` に固定。HybridPlayerの既存設定はOK。

---

### 4) 動作確認手順（簡易）

1. **Bounce単体テスト**（GuitarBounceService）

   * C / G / Am / F を `buffer(for:)` で作り、**`frameLength` が2.0s相当**になっていることをログに出す。
   * 末尾1,024サンプルの**最大値が-90dB以下**を確認。
2. **Playerの連結テスト**（HybridPlayer）

   * カウントイン後、**各小節が2.000±0.005秒**で切り替わる（クリックと一致）。
   * **ループ**で隙間がない（無音もポップも発生なし）。
3. **Bass（Sequencer）との同期**

   * 小節頭に**Kick/Rootが揃う**（Drumは後日、現在はBassのみ）。

---

## 🔧 参考：修正に関わる該当箇所

* **GuitarBounceService.swift**

  * `DispatchQueue.global(...).asyncAfter` でノートを鳴らしている箇所を**撤去**。**レンダーループ内で `startNote`** に変更。
  * `renderOffline(..., to: renderBuffer)` を**Scratch→Accum**へ。最後にフェード。
* **HybridPlayer.swift**

  * `scheduleGuitarBuffers(...)` を**絶対サンプル時刻**スケジューリングに変更。
  * `play(at:)` と **Sequencer.start() の整列**は現状の方針でOK。
* **SequencerBuilder.swift**

  * 現状はテンポ＋ベースのみ。将来のドラム追加はPercussion Bank (ch10) を使用。

---

## 🪙 代替案（今回の実装が重い/間に合わない場合）

### B案：**AVMIDIPlayer で「1小節SMF→PCM」化してから PlayerNode に渡す**

* `MusicSequence` に**ギター和音だけ**の1小節SMFを作成（ストラム15ms／NoteOff=小節長-120ms／頭にCC120）。
* `AVMIDIPlayer(data: sf2)` で **1小節だけ再生→`AVAudioEngine`のmanual rendering** で**PCM化**。
* 得たPCMを PlayerNode で連結。**イベントスケジューラを自前で書かず**に済む。
* Pros: 実装が短い／「レンダとイベント同期」の罠を避けられる。
* Cons: SMF生成の小物コードは必要。

### C案：**短リリースのSF2（Program25だけ）を同梱して暫定回避**

* Polyphone等で Program25の **VolEnv Releaseを≒120ms** に調整したSF2を1本用意し、**当面それを採用**。
* Pros: 既存実装の改修が最小。
* Cons: ライセンス/配布の取り扱いと音質のチューニングが必要。
* ※ 最終的にはA（バウンス）かB（SMF→PCM）を推奨。

---

## 🧪 不具合が続く場合に欲しい情報

* GuitarBounceService の**レンダーループ**の最終コード（イベント挿入部分）と、`accum` への**コピー処理**。
* HybridPlayer の**新しい schedule 部分**（絶対サンプル時刻での連結）。
* 2秒PCMバッファの `frameLength` / `sampleRate` / **ピーク値ログ**。
* 実機/シミュレータいずれでの症状か（シミュレータは負荷でズレやすい）。

---

### 最後に

いまのハイブリッド方針自体は**正しい**です。
問題は **「オフライン・レンダ」と「ノート開始」**を**サンプル位置で同期**していない点と、**`renderOffline` の書き込み先管理**です。上の2点を直せば、**ギターは物理的に2.000秒で止まる**ようになります。
この指示文をそのまま Cursor に渡して実装・パッチ適用を進めてください。必要なら、差分パッチの形（該当行の前後付き）でさらに細かく書き起こします。

---

## 📝 実装ステータス

- [ ] GuitarBounceService.swift の修正
- [ ] HybridPlayer.swift の修正
- [ ] 動作確認テスト
- [ ] Phase B 完了レポート更新

**次のステップ**: GuitarBounceService.swift の修正から開始


