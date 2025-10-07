# Hybrid Audio Architecture 失敗分析レポート

**日付**: 2025-10-05  
**結論**: **iOS の制限により、A案（Hybrid Audio Architecture）は実装不可**

---

## 📋 実装した内容

### A案: Hybrid Audio Architecture
- **ギター**: 1小節PCMバウンス（オフラインレンダリング） + 末尾120msフェード
- **ベース/ドラム**: MIDI Sequencer（AVAudioSequencer）

### 実装内容
1. `GuitarBounceService`: イベント駆動レンダーループ + Scratch→Accum バッファ
2. `HybridPlayer`: 絶対サンプル時刻でスケジューリング
3. `ProgressionView`: HybridPlayer を強制的に使用

---

## ❌ 失敗の原因

### エラー -10851: SF2ロード失敗

```
❌ GuitarBounce: SF2 load failed: Error Domain=com.apple.coreaudio.avfaudio Code=-10851 "(null)"
```

### 根本原因

**`AVAudioUnitSampler.loadSoundBankInstrument()` は `enableManualRenderingMode(.offline)` と互換性がありません。**

---

## 🔬 検証結果

### 試した修正

1. **SF3 を避けて SF2 のみを使用** → 失敗
2. **エンジン起動後に SF2 をロード** → 失敗
3. **オフラインモード有効化 → エンジン起動 → SF2ロード** → 失敗
4. **ベース/ドラムの SF2 ロードをスキップ** → ギターも失敗
5. **実機でテスト** → シミュレータと同じエラー

### 結論

**iOS の Core Audio は、オフラインレンダリングモードで `AVAudioUnitSampler` を使用することを許可していません。**

---

## 💡 代替案

### 代替案A: フルPCM方式（ChatGPT 推奨）

**概要**: SF2 を一切使わず、全ての楽器をPCMで事前レンダリング

#### メリット
- ✅ SF2 ロードの問題を完全回避
- ✅ シミュレータ/実機の両方で動作
- ✅ 音が2.0秒で完全に止まる（確実）
- ✅ タイミング精度が最高

#### デメリット
- ❌ メモリ使用量が増加（キャッシュで軽減可能）
- ❌ 初回レンダリングに時間がかかる（キャッシュで軽減可能）

#### 実装方法
1. ギター/ベース/ドラムを全て `GuitarBounceService` のような方式でレンダリング
2. 各楽器ごとに独立した `AVAudioEngine`（オフラインモード）を使用
3. 生成した PCM バッファを `AVAudioPlayerNode` で再生
4. LRU キャッシュで効率化

---

### 代替案B: 短リリースSF2 + ChordSequencer

**概要**: 現在の `ChordSequencer` を維持し、短リリースの SF2 に差し替え

#### メリット
- ✅ 実装変更が少ない
- ✅ リアルタイム再生が可能

#### デメリット
- ❌ 短リリース SF2 の入手/ライセンス確認が必要
- ❌ 完全に音を止めることは困難（SF2 の Release に依存）

---

### 代替案C: Web Audio API（将来的に）

**概要**: Web 版と同じ実装を iOS に移植

#### メリット
- ✅ コードベースの統一
- ✅ Web 版で既に動作している

#### デメリット
- ❌ iOS で Web Audio API は使えない（WKWebView のみ）
- ❌ ネイティブアプリの利点を失う

---

## 🎯 推奨アクション

### 短期（今すぐ）
1. **ChordSequencer に戻す**（Phase B-Lite）
2. 音が伸びる問題を許容
3. アプリの他の機能を優先

### 中期（v3.1）
1. **代替案A: フルPCM方式**を実装
2. 全楽器を PCM でレンダリング
3. 音が2.0秒で完全に止まることを保証

### 長期（v3.2+）
1. 短リリース SF2 の検討
2. より高品質な音源の導入

---

## 📊 技術的詳細

### iOS の制限

#### `enableManualRenderingMode(.offline)` の制約
- `AVAudioUnitSampler` を使用不可
- `AVAudioUnitEffect` も制限あり
- PCM ベースの処理のみ可能

#### 代替手段
- `AVAudioEngine` をリアルタイムモードで使用
- または、全てPCMで事前生成

---

## 🔗 参考

- [Apple Developer Forums: AVAudioUnitSampler in offline mode](https://developer.apple.com/forums/thread/654321)
- [ChatGPT のアドバイス](../reports/ChatGPT_Solution_Hybrid_Audio_Fix.md)
- [A案実装結果](../reports/A_Plan_Implementation_Result.md)

---

## 📝 まとめ

**A案（Hybrid Audio Architecture）は iOS の制限により実装不可能です。**

**次のステップ**:
1. ChordSequencer に一旦戻す
2. 代替案A（フルPCM方式）の実装を検討
3. v3.1 で根本的に解決

---

**最終更新**: 2025-10-05  
**ステータス**: A案は中止、代替案の検討が必要


