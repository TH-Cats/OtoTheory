# ChordSequencer destination().volume 実装後も無音継続問題

**作成日**: 2025-10-08  
**対象**: ChordSequencer.swift の destination().volume 実装  
**状態**: ❌ ChatGPT 推奨の修正を実装したが、1コード目以降は無音（一瞬だけ鳴る）

---

## 🎯 実装した変更（ChatGPT 推奨）

### 1. `destination` をプロパティとして保持

```swift
// プロパティ追加
private var destA: AVAudioMixingDestination!
private var destB: AVAudioMixingDestination!

// init() で一度だけ取得
guard let destA = subMixA.destination(forMixer: engine.mainMixerNode, bus: 0),
      let destB = subMixB.destination(forMixer: engine.mainMixerNode, bus: 1) else {
    throw NSError(...)
}
self.destA = destA
self.destB = destB

// 初期ボリューム
destA.volume = 1.0
destB.volume = 0.0
```

### 2. 小節頭で固定参照をキャプチャ

```swift
// ① 小節頭で参照を確定（キャプチャ）
let useA = currentBusIsA
let nextSampler = useA ? samplerA : samplerB
let prevSampler = useA ? samplerB : samplerA
let nextDest = useA ? destA! : destB!  // 保持済みの destination を使用
let prevDest = useA ? destB! : destA!  // 保持済みの destination を使用
```

### 3. 新バスは即時 1.0、旧バスは小節末にフェードアウト

```swift
// ② 新バスは即時1.0
nextDest.volume = 1.0

// ③ 旧バスのフェードアウトは小節末のみ
let fadeStartSec = barSec - (fadeMs / 1000.0)  // 1.92s
xfadeQ.asyncAfter(deadline: .now() + fadeStartSec) { [weak self, prevDest, prevSampler] in
    guard let self = self else { return }
    self.fadeOutDestination(prevDest, ms: self.fadeMs)
    
    // CC64 のみ送信（reset は呼ばない）
    let ccDelay = (self.fadeMs / 1000.0) + 0.010
    self.xfadeQ.asyncAfter(deadline: .now() + ccDelay) { [weak self] in
        for ch: UInt8 in 0...1 {
            prevSampler.sendController(64, withValue: 0, onChannel: ch)
        }
    }
}
```

### 4. `fadeOutDestination` 関数（片側フェードアウト専用）

```swift
private func fadeOutDestination(_ dest: AVAudioMixingDestination, ms: Double) {
    let steps = 4          // 20ms × 4 = 80ms
    let interval = ms / Double(steps) / 1000.0
    
    let start = dest.volume
    var i = 0
    let timer = DispatchSource.makeTimerSource(queue: xfadeQ)
    timer.setEventHandler { [weak self] in
        i += 1
        let t = Float(i) / Float(steps)
        dest.volume = max(0, start * (1 - t))
        if i >= steps {
            timer.cancel()
            if let self = self {
                audioTrace(String(format: "Fade complete: dest.volume = %.2f", dest.volume))
            }
        }
    }
    timer.schedule(deadline: .now(), repeating: interval)
    timer.resume()
}
```

### 5. その他の変更

- ✅ `outputVolume` / `volume` の使用を完全削除
- ✅ `hardKillSampler` を小節間から撤去
- ✅ 診断ログを追加（`[Bar N] next=X.XX prev=X.XX`）
- ✅ 不要なデバッグ関数を削除

---

## ❌ 実際のログ（問題発生）

```
[14316ms] [Bar 0] next=1.00 prev=0.00
[14317ms] destNext.volume = 1.00 (full gain)
[14317ms] Playing chord: C bus:A (4 beats)
[14317ms] startNote: first note of bar 0          ← ✅ 1小節目は鳴る

[16329ms] Fade-out start: 80ms (prevDest)
[16329ms] [Bar 1] next=0.00 prev=1.00             ← ❌ next=0.00 になっている！
[16330ms] destNext.volume = 1.00 (full gain)      ← 1.0 に設定しているが...
[16330ms] Playing chord: G bus:B (4 beats)
[16330ms] startNote: first note of bar 1          ← startNote は実行されている
[16390ms] Fade complete: dest.volume = 0.00

[18344ms] Fade-out start: 80ms (prevDest)
[18345ms] [Bar 2] next=0.75 prev=0.00             ← ❌ next=0.75 になっている
[18345ms] destNext.volume = 1.00 (full gain)
[18345ms] Playing chord: Am bus:A (4 beats)
[18345ms] startNote: first note of bar 2

[20359ms] Fade-out start: 80ms (prevDest)
[20359ms] [Bar 3] next=0.00 prev=0.00             ← ❌ next=0.00 になっている
[20359ms] destNext.volume = 1.00 (full gain)
[20359ms] Playing chord: F bus:B (4 beats)
[20359ms] startNote: first note of bar 3
```

---

## 🔍 問題の分析

### 重大な発見：`nextDest.volume` が設定前の値を表示している

#### 小節1（Bar 1）

```
[16329ms] [Bar 1] next=0.00 prev=1.00    ← next=0.00 (バスB) が設定前に読まれている
[16330ms] destNext.volume = 1.00 (full gain)
```

**問題**:
- `[Bar 1] next=0.00` のログが出た時点で、`nextDest.volume` は **0.00** になっている
- これは、**前の小節でフェードアウトされた値**
- その直後に `nextDest.volume = 1.0` を設定しているが、**すでに `startNote` がスケジュールされている**

#### 小節2（Bar 2）

```
[18345ms] [Bar 2] next=0.75 prev=0.00    ← next=0.75 (バスA) が設定前に読まれている
[18345ms] destNext.volume = 1.00 (full gain)
```

**問題**:
- `[Bar 2] next=0.75` のログが出た時点で、`nextDest.volume` は **0.75** になっている
- これは、**前の小節のフェードアウト途中の値**
- バスA は小節0で使用され、小節1の最後（1.92s～2.0s）にフェードアウトされているはず
- しかし、小節2の開始時点（t=4.0s）で **0.75** になっている

---

## 💡 推測される原因

### 仮説1: `fadeOutDestination` のタイマーが小節をまたいで実行されている（最有力）

**タイミング図**:

```
小節0 (t=0.000s～2.000s):
  t=0.000s: [Bar 0] useA=true, nextDest=destA, prevDest=destB
  t=0.000s: destA.volume = 1.0 ← バスA を 1.0 に設定
  t=0.000s: startNote × N ← バスA で音を鳴らす
  t=1.920s: fadeOutDestination(destB) 開始 ← バスB をフェードアウト
  t=2.000s: 小節1へ

小節1 (t=2.000s～4.000s):
  t=2.000s: [Bar 1] useA=false, nextDest=destB, prevDest=destA
  t=2.000s: destB.volume を読む → 0.00（フェード完了後）← ❌ ここが問題！
  t=2.000s: destB.volume = 1.0 ← バスB を 1.0 に設定
  t=2.000s: startNote × N を xfadeQ に予約 ← しかし、destB.volume がまだ低い？
  t=3.920s: fadeOutDestination(destA) 開始 ← バスA をフェードアウト
  t=4.000s: 小節2へ

小節2 (t=4.000s～6.000s):
  t=4.000s: [Bar 2] useA=true, nextDest=destA, prevDest=destB
  t=4.000s: destA.volume を読む → 0.75（フェード途中）← ❌ ここが問題！
  t=4.000s: destA.volume = 1.0 ← バスA を 1.0 に設定
  t=4.000s: startNote × N を xfadeQ に予約
```

**問題点**:
- 小節1の開始時点（t=2.000s）で `destB.volume` を読むと **0.00**（小節0の最後でフェードアウト完了）
- その後、`destB.volume = 1.0` を設定しているが、**`startNote` の予約が `xfadeQ.asyncAfter` で遅延**している
- `startNote` が実行される時点で、`destB.volume` がまだ **0.0 または低い値**になっている可能性

---

### 仮説2: `xfadeQ.asyncAfter` の遅延が原因

**問題**:
```swift
// ② 新バスは即時1.0
nextDest.volume = 1.0

// 4) 4拍分のストラムを予約（直列キュー）
for beat in 0..<4 {
    let beatDelay = Double(beat) * beatSec
    
    // 各拍でストラム
    for (i, note) in playedNotes.enumerated() {
        let d = beatDelay + (Double(i) * strumMs / 1000.0)
        xfadeQ.asyncAfter(deadline: .now() + d) { [weak self, weak nextSampler, bar] in
            if beat == 0 && i == 0 {
                self?.audioTrace("startNote: first note of bar \(bar)")
            }
            nextSampler?.startNote(note, withVelocity: 80, onChannel: 0)
        }
    }
}
```

**タイミング図**:
```
t=2.000s: nextDest.volume = 1.0 を設定
t=2.000s: xfadeQ.asyncAfter(deadline: .now() + 0.0) { startNote } を予約
t=2.000s: ... （他のタスクが xfadeQ に入っている）
t=2.010s: ようやく startNote が実行される
```

**問題点**:
- `nextDest.volume = 1.0` を設定してから、`startNote` が実行されるまでに **遅延がある**
- その間に、別のタスク（前の小節のフェードアウトやCC送信）が `xfadeQ` で実行されている
- → `startNote` が実行される時点で、`nextDest.volume` がまだ **0.0 または低い値**になっている

---

### 仮説3: `fadeOutDestination` のタイマーが `xfadeQ` と競合している

**問題**:
```swift
private func fadeOutDestination(_ dest: AVAudioMixingDestination, ms: Double) {
    let timer = DispatchSource.makeTimerSource(queue: xfadeQ)
    timer.setEventHandler { [weak self] in
        i += 1
        let t = Float(i) / Float(steps)
        dest.volume = max(0, start * (1 - t))
        if i >= steps {
            timer.cancel()
        }
    }
    timer.schedule(deadline: .now(), repeating: interval)
    timer.resume()
}
```

**タイミング図**:
```
t=1.920s: fadeOutDestination(destB) 開始
t=1.920s: timer を xfadeQ に登録
t=1.940s: timer イベント1 → destB.volume = 0.75
t=1.960s: timer イベント2 → destB.volume = 0.50
t=1.980s: timer イベント3 → destB.volume = 0.25
t=2.000s: timer イベント4 → destB.volume = 0.00
t=2.000s: 小節1の開始処理（nextDest.volume = 1.0）
t=2.000s: startNote の予約
```

**問題点**:
- `fadeOutDestination` のタイマーが `xfadeQ` で実行されている
- 小節1の開始処理（`nextDest.volume = 1.0`）も `xfadeQ` ではなく、**メインスレッド**で実行されている
- → **競合が発生**している可能性

---

### 仮説4: `nextDest` と `prevDest` のキャプチャが間違っている（最有力候補2）

**問題のコード**:
```swift
let useA = currentBusIsA
let nextDest = useA ? destA! : destB!  // 保持済みの destination を使用
let prevDest = useA ? destB! : destA!  // 保持済みの destination を使用

// ログ：確定値を出す
audioTrace(String(format: "[Bar %d] next=%.2f prev=%.2f", bar, nextDest.volume, prevDest.volume))

// ② 新バスは即時1.0
nextDest.volume = 1.0
```

**実際のログ**:
```
[16329ms] [Bar 1] next=0.00 prev=1.00    ← nextDest.volume が 0.00 になっている
[16330ms] destNext.volume = 1.00 (full gain)
```

**問題点**:
- ログの時点で `nextDest.volume` が **0.00** になっている
- これは、**前の小節でフェードアウトされた値**
- → `nextDest` と `prevDest` のキャプチャが**正しくない**可能性

**検証**:
```
小節0: useA=true
  nextDest = destA (正しい)
  prevDest = destB (正しい)
  
小節1: useA=false
  nextDest = destB (正しい)
  prevDest = destA (正しい)
  
しかし、ログでは:
  [Bar 1] next=0.00 prev=1.00
  
これは、destB.volume=0.00, destA.volume=1.00 を意味する。
```

**結論**:
- `nextDest` と `prevDest` のキャプチャは**正しい**
- 問題は、**ログの時点で `nextDest.volume` がまだフェードアウト後の値（0.00）になっている**こと
- → **`nextDest.volume = 1.0` を設定する前に、ログを出している**

**しかし、ログを見ると**:
```
[16329ms] [Bar 1] next=0.00 prev=1.00    ← ログを出した時点
[16330ms] destNext.volume = 1.00 (full gain) ← 1ms 後に設定
```

**問題**:
- ログと設定の間に **1ms の差**がある
- これは、**2つの `audioTrace` 呼び出しが別々のタイミングで実行されている**ことを意味する
- → **タイミングの問題ではなく、設定が効いていない**可能性

---

## 🔧 推奨される修正案（ChatGPT への質問）

### 質問1: `destination().volume` の設定タイミング

**現在の実装**:
```swift
let nextDest = useA ? destA! : destB!
audioTrace(String(format: "[Bar %d] next=%.2f prev=%.2f", bar, nextDest.volume, prevDest.volume))
nextDest.volume = 1.0
audioTrace(String(format: "destNext.volume = %.2f (full gain)", nextDest.volume))
```

**問題**:
- `nextDest.volume = 1.0` を設定しているが、**ログでは設定前の値（0.00）が表示されている**
- その後、`startNote` が `xfadeQ.asyncAfter` で予約されているが、**実行時点で `nextDest.volume` がまだ低い**可能性

**質問**:
- `destination().volume` の設定は、**即座に反映される**か？
- それとも、**オーディオエンジンのレンダリングサイクル**まで待つ必要があるか？
- `xfadeQ.asyncAfter` で `startNote` を予約する前に、**`nextDest.volume = 1.0` を確実に反映させる**方法はあるか？

---

### 質問2: `fadeOutDestination` のタイマーと `xfadeQ` の競合

**現在の実装**:
```swift
private func fadeOutDestination(_ dest: AVAudioMixingDestination, ms: Double) {
    let timer = DispatchSource.makeTimerSource(queue: xfadeQ)
    timer.setEventHandler { [weak self] in
        dest.volume = max(0, start * (1 - t))
    }
    timer.schedule(deadline: .now(), repeating: interval)
    timer.resume()
}
```

**問題**:
- `fadeOutDestination` のタイマーが `xfadeQ` で実行されている
- 小節の開始処理（`nextDest.volume = 1.0`）はメインスレッドで実行されている
- → **競合が発生**している可能性

**質問**:
- `fadeOutDestination` のタイマーを `xfadeQ` で実行するのは正しいか？
- それとも、別のキュー（`fadeQ`）で実行すべきか？
- または、`nextDest.volume = 1.0` の設定も `xfadeQ` で実行すべきか？

---

### 質問3: `xfadeQ.asyncAfter` の遅延

**現在の実装**:
```swift
for beat in 0..<4 {
    let beatDelay = Double(beat) * beatSec
    
    for (i, note) in playedNotes.enumerated() {
        let d = beatDelay + (Double(i) * strumMs / 1000.0)
        xfadeQ.asyncAfter(deadline: .now() + d) { [weak self, weak nextSampler, bar] in
            nextSampler?.startNote(note, withVelocity: 80, onChannel: 0)
        }
    }
}
```

**問題**:
- `xfadeQ.asyncAfter(deadline: .now() + d)` で `startNote` を予約している
- `d = 0.0` の場合、**即座に実行される**はずだが、実際には**遅延**している可能性
- → `xfadeQ` のタスクキューが詰まっている？

**質問**:
- `xfadeQ.asyncAfter(deadline: .now() + 0.0)` は、**即座に実行される**か？
- それとも、**キューの末尾に追加される**か？
- `xfadeQ` のタスクキューを**クリアする**方法はあるか？
- または、`startNote` を `xfadeQ` ではなく、**メインスレッドで直接実行**すべきか？

---

### 質問4: `destination().volume` の取得タイミング

**現在の実装**:
```swift
// init() で一度だけ取得
guard let destA = subMixA.destination(forMixer: engine.mainMixerNode, bus: 0),
      let destB = subMixB.destination(forMixer: engine.mainMixerNode, bus: 1) else {
    throw NSError(...)
}
self.destA = destA
self.destB = destB
```

**問題**:
- `destination()` を `init()` で一度だけ取得している
- しかし、`destination()` は**接続ごとに一意**のインスタンスを返すか？
- それとも、**毎回新しいインスタンス**を返すか？

**質問**:
- `destination(forMixer:bus:)` は、**同じインスタンス**を返すか？
- それとも、**毎回新しいインスタンス**を返すか？
- `init()` で一度だけ取得した `destA` と `destB` を使い続けることは正しいか？
- それとも、**小節ごとに再取得**すべきか？

---

## 📊 期待される動作 vs 実際の動作

### 期待される動作

```
[Bar 0] next=1.00 prev=0.00
destNext.volume = 1.00
startNote: first note of bar 0
→ 音が鳴る ✅

[Bar 1] next=1.00 prev=1.00    ← nextDest.volume が 1.00 になっているはず
destNext.volume = 1.00
startNote: first note of bar 1
→ 音が鳴る ✅

[Bar 2] next=1.00 prev=0.00    ← nextDest.volume が 1.00 になっているはず
destNext.volume = 1.00
startNote: first note of bar 2
→ 音が鳴る ✅
```

### 実際の動作

```
[Bar 0] next=1.00 prev=0.00
destNext.volume = 1.00
startNote: first note of bar 0
→ 音が鳴る ✅

[Bar 1] next=0.00 prev=1.00    ← ❌ nextDest.volume が 0.00 になっている
destNext.volume = 1.00
startNote: first note of bar 1
→ 音が鳴らない（一瞬だけ） ❌

[Bar 2] next=0.75 prev=0.00    ← ❌ nextDest.volume が 0.75 になっている
destNext.volume = 1.00
startNote: first note of bar 2
→ 音が鳴らない（一瞬だけ） ❌
```

---

## 🎯 結論

**問題の核心**:
- `nextDest.volume = 1.0` を設定しているが、**設定前のログで低い値（0.00, 0.75）が表示されている**
- これは、**前の小節でフェードアウトされた値**がそのまま残っている
- → **`nextDest.volume = 1.0` の設定が効いていない**か、**設定が遅延している**

**最も可能性が高い原因**:
1. **仮説1**: `fadeOutDestination` のタイマーが小節をまたいで実行され、`nextDest.volume` を上書きしている
2. **仮説2**: `xfadeQ.asyncAfter` の遅延により、`startNote` が実行される時点で `nextDest.volume` がまだ低い
3. **仮説4**: `nextDest` と `prevDest` のキャプチャが間違っている（可能性は低い）

**推奨される対策**:
1. **最優先**: `nextDest.volume = 1.0` の設定を `xfadeQ` で実行し、`startNote` と同期させる
2. **次点**: `fadeOutDestination` のタイマーを別のキュー（`fadeQ`）で実行する
3. **代替案**: `xfadeQ` を使わず、`Task.sleep` で直接待つ方法に変更する

---

**次のステップ**: ChatGPT の回答を待って、修正方針を決定する。

---

## 📎 関連コード

### ChordSequencer.swift（問題箇所）

```swift
// 小節頭で参照を確定
let useA = currentBusIsA
let nextDest = useA ? destA! : destB!
let prevDest = useA ? destB! : destA!

// ログ：確定値を出す
audioTrace(String(format: "[Bar %d] next=%.2f prev=%.2f", bar, nextDest.volume, prevDest.volume))

// ② 新バスは即時1.0
nextDest.volume = 1.0
audioTrace(String(format: "destNext.volume = %.2f (full gain)", nextDest.volume))

// 発音（ストラム）- 即座に開始
for beat in 0..<4 {
    let beatDelay = Double(beat) * beatSec
    
    for (i, note) in playedNotes.enumerated() {
        let d = beatDelay + (Double(i) * strumMs / 1000.0)
        xfadeQ.asyncAfter(deadline: .now() + d) { [weak self, weak nextSampler, bar] in
            if beat == 0 && i == 0 {
                self?.audioTrace("startNote: first note of bar \(bar)")
            }
            nextSampler?.startNote(note, withVelocity: 80, onChannel: 0)
        }
    }
}

// ③ 旧バスのフェードアウト
let fadeStartSec = barSec - (fadeMs / 1000.0)
xfadeQ.asyncAfter(deadline: .now() + fadeStartSec) { [weak self, prevDest, prevSampler] in
    guard let self = self else { return }
    self.fadeOutDestination(prevDest, ms: self.fadeMs)
}
```
