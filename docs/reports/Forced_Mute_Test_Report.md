# 強制ミュート試験（候補2）結果レポート

## 📋 実施日時
2025年10月7日

## 🎯 目的
「クロスフェードで動かしているつまみ（subMixA/B）が実際の音の通り道に効いているか」を検証する。

---

## 🧪 テスト内容

### 実施したテスト
各小節の開始時に、`subMixA.outputVolume` と `subMixB.outputVolume` を強制的に `0.0` に設定し、音が出るかどうかを確認。

### テストコード
```swift
// [TEST] 強制ミュート試験
subMixA.outputVolume = 0.0; subMixB.outputVolume = 0.0
audioTrace(String(format:"[TEST] forced mute A,B → A:%.2f B:%.2f", subMixA.outputVolume, subMixB.outputVolume))
```

---

## 📊 テスト結果

### 🔴 **結果: NG（音が出た）**

**現象**: 
- 強制ミュート（A:0.00 B:0.00）を設定したにもかかわらず、**途切れながら音が鳴った**
- 各小節で同じパターンが繰り返された

### ログの詳細分析

#### **小節1（C）**
```
[61708ms] [TEST] forced mute A,B → A:0.00 B:0.00
[61708ms] Playing chord: C bus:A
```
→ **A/B両方を0.0にしたのに音が出た**

#### **小節2（G）**
```
[63838ms] [TEST] forced mute A,B → A:0.00 B:0.00
[63838ms] Playing chord: G bus:B
```
→ **A/B両方を0.0にしたのに音が出た**

#### **小節3（Am）**
```
[65831ms] [TEST] forced mute A,B → A:0.00 B:0.00
[65831ms] Playing chord: Am bus:A
```
→ **A/B両方を0.0にしたのに音が出た**

#### **小節4（F）**
```
[67832ms] [TEST] forced mute A,B → A:0.00 B:0.00
[67833ms] Playing chord: F bus:B
```
→ **A/B両方を0.0にしたのに音が出た**

---

## 🔍 重要な発見

### 1. **サンプラーがミキサをバイパスしている**

グラフダンプのログから、**サンプラーが直接 MainMixer に接続されている**ことが判明：

```
🔌 <AVAudioUnitSampler: 0x60000000a820> -> MainMixer bus:0
🔌 <AVAudioUnitSampler: 0x600000010d10> -> MainMixer bus:0
🔌 <AVAudioMixerNode: 0x600000010de0> -> MainMixer bus:0
🔌 <AVAudioMixerNode: 0x600000011080> -> MainMixer bus:1
```

**問題点**:
- `samplerA` → `MainMixer` bus:0 （直接接続）
- `samplerB` → `MainMixer` bus:0 （直接接続）
- `subMixA` → `MainMixer` bus:0
- `subMixB` → `MainMixer` bus:1

**期待される配線**:
- `samplerA` → `subMixA` → `MainMixer` bus:0
- `samplerB` → `subMixB` → `MainMixer` bus:1

### 2. **二重配線（バイパス）が存在**

サンプラーが以下の2つの経路で MainMixer に接続されている：
1. **直接経路**: `samplerA/B` → `MainMixer` bus:0 （バイパス）
2. **間接経路**: `samplerA/B` → `subMixA/B` → `MainMixer` bus:0/1

このため、`subMixA/B.outputVolume` を 0.0 にしても、**直接経路から音が出続ける**。

### 3. **destination の値が異常**

```
🔎 [bar-head before xfade] A: out=1.00 vol=1.00 dest=1.00 | B: out=0.00 vol=1.00 dest=-1.00
```

- `subMixA.destination(forMixer: mainMixer, bus: 0)?.volume` = `1.00` （正常）
- `subMixB.destination(forMixer: mainMixer, bus: 0)?.volume` = `-1.00` （**異常：nil を -1 で表示**）

`subMixB` は bus:1 に接続されているため、bus:0 での destination は存在しない（nil）。

---

## 🚨 結論

### ❌ **候補2: NG（バイパス／二重配線が存在）**

**問題の本質**:
1. **サンプラーが MainMixer に直接接続されている**（バイパス経路）
2. **subMixA/B のボリューム制御が効かない**（バイパス経路から音が出る）
3. **クロスフェードが機能していない**（常に両方のサンプラーが MainMixer に直結）

**音が途切れる理由**:
- 強制ミュートで `subMixA/B.outputVolume = 0.0` にしても、バイパス経路から音が出る
- 300ms 後に `restore node out/vol to 1.0` で復帰するため、音が途切れながら鳴る

---

## 🔧 根本原因

### コード上の配線（意図）
```swift
engine.connect(samplerA, to: subMixA, format: nil)
engine.connect(samplerB, to: subMixB, format: nil)
engine.connect(subMixA, to: engine.mainMixerNode, format: nil)
engine.connect(subMixB, to: engine.mainMixerNode, format: nil)
```

### 実際の配線（実態）
```
samplerA → MainMixer bus:0 (直接)
samplerB → MainMixer bus:0 (直接)
samplerA → subMixA → MainMixer bus:0
samplerB → subMixB → MainMixer bus:1
```

**なぜこうなったか**:
- `AVAudioEngine` が自動的にサンプラーを MainMixer に接続した可能性
- または、どこかで `engine.connect(samplerA/B, to: mainMixerNode, ...)` が呼ばれている
- 明示的な接続の前に、デフォルトの自動接続が発生している可能性

---

## 💡 次のステップ（Step-2）

### 1. **バイパス経路を削除**

サンプラーから MainMixer への直接接続を切断する必要がある。

**方法**:
```swift
// 既存の接続を切断
engine.disconnectNodeOutput(samplerA)
engine.disconnectNodeOutput(samplerB)

// 正しい配線を再接続
engine.connect(samplerA, to: subMixA, format: nil)
engine.connect(samplerB, to: subMixB, format: nil)
```

### 2. **接続順序の確認**

`engine.attach()` の後、すぐに `engine.connect()` を呼ぶ前に、既存の接続を切断する。

### 3. **検証**

再度グラフダンプを確認し、以下の状態になることを確認：
```
samplerA → subMixA → MainMixer bus:0
samplerB → subMixB → MainMixer bus:1
```

---

## 📝 追加の観察事項

### 1. **Phase B-Lite の Note Duration 制御は動作している**
```
🎵 Phase B-Lite: Note Duration = 1.2s (60% of 2.0s)
⏹️ Phase B-Lite: Stopping notes after 1.2s
✅ Phase B-Lite: Notes stopped, CC120/123 sent
```

### 2. **クロスフェードのタイミングは正確**
```
[61708ms] Symmetric cross-fade start: 120ms  from:B to:A
```

### 3. **バス切り替えは正しく動作**
```
[61708ms] Playing chord: C bus:A
[63838ms] Playing chord: G bus:B
[65831ms] Playing chord: Am bus:A
[67832ms] Playing chord: F bus:B
```

---

## 🎯 まとめ

**テスト結果**: ❌ **NG（バイパス経路が存在）**

**判明した事実**:
- サンプラーが MainMixer に直接接続されている（二重配線）
- `subMixA/B.outputVolume` の制御が効かない
- クロスフェードが機能していない

**次のアクション**:
- **Step-2**: バイパス経路を削除し、正しい配線に修正する
- 修正後、再度強制ミュート試験を実施して検証する

**音が伸びる問題との関係**:
- バイパス経路が原因で、クロスフェードによる音の切り替えが機能していない
- これが「音が伸びる」問題の主要因である可能性が高い
- バイパス経路を修正すれば、クロスフェードが正常に動作し、音が伸びる問題が解決する可能性がある
