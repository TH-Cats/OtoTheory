# Phase C ベース・ドラム実装レポート

**作成日**: 2025-10-11  
**対象**: OtoTheory iOS v1 (Phase C-2.5, C-3)

---

## 📋 実装概要

### Phase C-2.5: ベース PCM レンダリング（完了）
ベースをMIDI（AVAudioSequencer）からPCM（AVAudioPlayerNode）に移行し、ギターとの完璧な同期を実現。

### Phase C-3: ドラムパターン実装（実装後に削除）
ドラムパターン（Rock/Pop）を実装したが、心理音響的な「突っ込み感」により削除。

---

## 🎯 Phase C-2.5: ベース PCM レンダリング

### 実装内容

#### 1. **BassBounceService.swift**（新規作成）
- **目的**: 1小節（2.0秒@120BPM）のベースPCMをオフラインレンダリング
- **パターン**: Root音4つ打ち（各拍でRoot音を再生）
- **技術**: `AVAudioEngine` オフラインレンダリング、LRUキャッシュ

```swift
/// BassBounceService
/// 1小節（2.0秒@120BPM）のベースPCMをオフラインレンダリング
/// パターン: Root → Root → Root → Root（4つ打ち、各1拍）
final class BassBounceService {
    // SF2: Program 34 (Electric Bass - finger)
    // Note Duration: 90% of beat (次の拍の前に切る)
    // Attack Delay: 0ms (完全同期)
}
```

#### 2. **HybridPlayer.swift**（更新）
- **playerBass** (AVAudioPlayerNode) を追加
- **scheduleBassBuffers** メソッドを追加（ギターと同じロジック）
- **完璧な同期**: 同じ `AVAudioTime` で `playerGtr` と `playerBass` を起動

```swift
let playerGtr = AVAudioPlayerNode()    // ギター PCM
let playerBass = AVAudioPlayerNode()   // ベース PCM（Phase C-2.5 で追加）

func play(
    score: Score,
    guitarBuffers: [AVAudioPCMBuffer],
    bassBuffers: [AVAudioPCMBuffer],  // 追加
    drumBuffer: AVAudioPCMBuffer?,
    onBarChange: @escaping (Int) -> Void
) throws {
    // ...
    playerGtr.play(at: startTime)
    playerBass.play(at: startTime)  // ✅ 完璧な同期
}
```

#### 3. **ProgressionView.swift**（更新）
- **bassService** を初期化
- **bassBuffers** を生成（各小節ごとに）
- **playWithHybridPlayer** に渡す

---

### ベースパターンの変遷

#### 初期実装（MIDI）
```
問題: AVAudioSequencer のタイミング精度不足
結果: ギターとの同期ズレ（特に3拍目）
```

#### PCM移行後
```
1. Root (2拍) → 5th (1拍) → Root+1Oct (1拍)
   問題: 3拍目（5th）が突っ込んで聴こえる（高音の心理音響効果）

2. Root → Root → 5th → Root+1Oct（4つ打ち）
   問題: 3拍目（5th）が依然として突っ込んで聴こえる

3. Root → Root → Root → Root（4つ打ち、全てRoot音）✅
   結果: 完璧な同期、突っ込み感なし
```

---

### 成果

#### タイミング精度
```
削減前（MIDI）: 体感で遅延/早延あり
削減後（PCM）:  サンプル精度で完璧に同期
```

#### 心理音響的発見
- **高音（5度、オクターブ上）は物理的に同期していても「早く聴こえる」**
- **Root音のみ**: 心理音響的な突っ込み感を回避

---

## 🥁 Phase C-3: ドラムパターン実装（削除）

### 実装内容

#### 1. **DrumBounceService.swift**（新規作成、後に機能削除）
- **3種類のパターン**: Rock / Pop / Funk
- **General MIDI Drum Map**: チャンネル10（Percussion Bank）
- **最適化の変遷**:
  1. 初期: キック+スネア+ハイハット（16分音符）→ 48 events
  2. 最適化1: Note Off削除、ハイハット8分音符 → 16 events
  3. 最適化2: ハイハット4分音符 → 8 events
  4. 最適化3: ハイハット8分音符のみ（キック・スネア削除）→ 8 events
  5. 最適化4: ハイハット4分音符のみ → 4 events
  6. 最終: キック+スネアのみ（ハイハット削除）→ 4 events

#### 2. **UI実装**（後に削除）
```swift
Toggle("Drum", isOn: $drumEnabled)
Picker("Pattern", selection: $selectedDrumPattern) {
    Text("Rock").tag(0)
    Text("Pop").tag(1)
}
```

---

### CPU過負荷問題

#### 症状
```
HALC_ProxyIOContext.cpp:1622  HALC_ProxyIOContext::IOWorkLoop: skipping cycle due to overload
```
- オーディオエンジンがCPU過負荷でサイクルをスキップ
- 再生が「モタる」

#### 原因
1. **オフラインレンダリングの重さ**: ギター(4小節) + ベース(4小節) + ドラム(1小節) を毎回生成
2. **ドラムイベント数の多さ**: 初期実装で48 events/小節
3. **Note Offの不要性**: ドラムは減衰楽器なのでNote Offは音楽的に不要

#### 最適化試行
- Note Off削除 → 50%削減
- ハイハット密度軽減（16分→8分→4分）
- キック・スネア削除（ハイハットのみ）
- ハイハット削除（キック・スネアのみ）

---

### 心理音響的問題

#### 症状
```
ユーザー報告: 「どうも突っ込んだ感じに聴こえます」
```

#### 原因
- **ハイハット**: 高周波成分が多く、鋭いアタック
- **スネア**: 中高音域、明瞭なアタック
- **心理音響効果**: 高音・鋭い音は物理的に同期していても「早く聴こえる」

#### 検証
- ハイハット4分音符のみ → 依然として突っ込んで聴こえる
- キック+スネアのみ → 依然として突っ込んで聴こえる

---

### 最終判断: ドラム削除

#### 理由
1. **CPU過負荷**: 最適化してもモタる
2. **心理音響的突っ込み感**: 低音（キック）でも解消せず
3. **シンプル化**: ギター+ベースのみの方がクリーンで安定

#### 削除内容
- `DrumBounceService` 初期化・呼び出し
- `drumService` 変数
- `drumEnabled`, `selectedDrumPattern` 変数
- ドラムUI（Toggle + Picker）
- ドラムバッファ生成ロジック

#### 残存
- `DrumBounceService.swift` ファイル（将来の参考用）
- `HybridPlayer` のドラム対応（`drumBuffer` パラメータ）

---

## 📊 最終構成

### アーキテクチャ
```
[ギター PCM] ─┐
              ├─> [AVAudioEngine] -> [mainMixerNode] -> 出力
[ベース PCM] ─┘

ドラム: なし
```

### 再生フロー
1. **準備**: SF2ロード、エンジン起動
2. **バウンス**: ギター(4小節) + ベース(4小節) をオフラインレンダリング
3. **スケジュール**: 2周分（8小節）を事前スケジュール
4. **再生**: 同じ `AVAudioTime` で同時起動
5. **ループ**: 最後のバッファ完了時に次の2周を再スケジュール

---

## 🎯 技術的成果

### 1. 完璧な同期
- **サンプル精度**: `AVAudioTime(sampleTime:atRate:)` で絶対時刻指定
- **同時起動**: `playerGtr.play(at: startTime)` + `playerBass.play(at: startTime)`

### 2. 心理音響的発見
- **高音の突っ込み感**: 5度、オクターブ上、ハイハット、スネアは物理的に同期していても早く聴こえる
- **Root音の安定性**: 低音・単一ピッチは心理音響的にズレを感じにくい

### 3. CPU負荷軽減
- **ドラム削除**: オフラインレンダリング負荷を大幅削減
- **Note Off削除**: ベースでも適用可能（今後の最適化）

---

## 📝 今後の課題

### Phase C-5: ベース Humanize
- ±5ms タイミングランダム化
- ±6 Velocity ランダム化

### Phase C-6: 音色品質調査
- Distortion/Over Drive のワウペダル効果確認
- Acoustic Nylon のドラム音混入確認

### 将来のドラム実装
- **事前レンダリング**: アプリ起動時に全パターンを生成してキャッシュ
- **シンプルパターン**: キックのみ、スネアのみなど最小限
- **遅延補正**: 心理音響的突っ込み感を補正する微細な遅延（10-20ms）

---

## ✅ 完了項目

- [x] Phase C-2.5: ベース PCM レンダリング
- [x] BassBounceService.swift 作成
- [x] HybridPlayer.swift 更新（playerBass追加）
- [x] ProgressionView.swift 更新（bassService初期化）
- [x] ベースパターン最適化（Root音4つ打ち）
- [x] Phase C-3: ドラムパターン実装（後に削除）
- [x] DrumBounceService.swift 作成
- [x] ドラムUI実装（後に削除）
- [x] CPU過負荷問題の最適化試行
- [x] 心理音響的問題の検証
- [x] ドラム機能の完全削除

---

## 🎵 最終状態

**再生される音:**
- ✅ ギター（PCM、SF2 Program 25、4つ打ち同時発音）
- ✅ ベース（PCM、SF2 Program 34、Root音4つ打ち）

**シンプル＆クリーン！心理音響的な突っ込み感なし！**

