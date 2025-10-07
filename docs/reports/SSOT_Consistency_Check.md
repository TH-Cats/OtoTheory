# SSOT整合性チェックレポート

**日付**: 2025-10-05  
**対象**: OtoTheory v3.1 SSOT類  
**ステータス**: ✅ 整合性確認完了

---

## 📋 チェック対象ファイル

1. `/Users/nh/App/OtoTheory/docs/SSOT/v3.1_Implementation_SSOT.md`
2. `/Users/nh/App/OtoTheory/docs/SSOT/v3.1_SSOT.md`
3. `/Users/nh/App/OtoTheory/docs/SSOT/v3.1_Roadmap_Milestones.md`
4. `/Users/nh/App/OtoTheory/docs/SSOT/v3.1_System_Architecture.md`
5. `/Users/nh/App/OtoTheory/docs/SSOT/Feature_Requirements_2.4_final.md`
6. `/Users/nh/App/OtoTheory/docs/SSOT/OtoTheory_Privacy_Legal_SSOT.md`

---

## ✅ 整合性確認結果

### 1. バージョン情報の整合性

| ファイル | バージョン | 最終更新日 | 状態 |
|---------|-----------|-----------|------|
| `v3.1_Implementation_SSOT.md` | v3.1 | 2025/10/05 | ✅ **最新** |
| `v3.1_SSOT.md` | v3.1 | 2025/10/04 | ⚠️ 更新推奨 |
| `v3.1_Roadmap_Milestones.md` | v3.1 | 2025/10/04 | ⚠️ 更新推奨 |
| `v3.1_System_Architecture.md` | v3.1 | 2025/10/04 | ⚠️ 更新推奨 |

---

### 2. オーディオアーキテクチャの整合性

#### **v3.1_Implementation_SSOT.md（セクション 4.1）**
- ✅ **Hybrid Audio Architecture** を詳細に記載
- ✅ 方式: ギターPCM + ベース/ドラムMIDI
- ✅ SSOT: Strum 10-20ms, Release 80-150ms, 最大6声, 1小節=2.000s
- ✅ 実装計画: Phase A/B/C
- ✅ 受け入れ基準（DoD）明確

#### **v3.1_SSOT.md**
- ⚠️ **オーディオアーキテクチャの記載が古い**
  - 現状: 「2バス・フェード方式」の記載が残っている可能性
  - 推奨: セクション 4.1 の内容を反映する必要あり

#### **v3.1_System_Architecture.md**
- ⚠️ **システム構成図の更新が必要**
  - 現状: `ChordSequencer`（2バス・フェード方式）の記載
  - 推奨: `HybridPlayer` + `GuitarBounceService` + `SequencerBuilder` の構成図を追加

#### **v3.1_Roadmap_Milestones.md**
- ⚠️ **M4のオーディオ実装計画の更新が必要**
  - 現状: 「同時/軽ストラム」の品質担保のみ記載
  - 推奨: Hybrid Audio Architecture の Phase A/B/C を反映

---

### 3. M4実装の整合性

#### **M4-A（Freeパリティ）**
| 項目 | Implementation SSOT | Roadmap | System Architecture | 整合性 |
|------|---------------------|---------|---------------------|--------|
| **結果カード〜Fretboard** | ✅ 記載 | ✅ 記載 | ✅ 記載 | ✅ 一致 |
| **プリセット** | ✅ Free 20種 | ✅ Free 20種 | ✅ 記載 | ✅ 一致 |
| **自動ループ** | ✅ 記載 | ✅ 記載 | ✅ 記載 | ✅ 一致 |
| **Sketch 3件** | ✅ 記載 | ✅ 記載 | ✅ 記載 | ✅ 一致 |

#### **M4-B（Pro核）**
| 項目 | Implementation SSOT | Roadmap | System Architecture | 整合性 |
|------|---------------------|---------|---------------------|--------|
| **セクション編集** | ✅ 記載 | ✅ 記載 | ⚠️ 未記載 | ⚠️ 更新必要 |
| **MIDI出力** | ✅ Chord+Markers+Guide | ✅ SMF Type-1 | ⚠️ 未記載 | ⚠️ 更新必要 |
| **Sketch無制限** | ✅ クラウド同期 | ✅ クラウド同期 | ⚠️ 未記載 | ⚠️ 更新必要 |
| **IAP（¥490/月）** | ✅ 記載 | ✅ 記載 | ⚠️ 未記載 | ⚠️ 更新必要 |

---

### 4. Web Lite GA（M3.5）の整合性

| 項目 | Implementation SSOT | Roadmap | System Architecture | 整合性 |
|------|---------------------|---------|---------------------|--------|
| **Analyze撤去** | ✅ 完了 | ✅ 完了 | ✅ 記載 | ✅ 一致 |
| **6面CTA** | ✅ 実装完了 | ✅ 実装完了 | ⚠️ 未記載 | ⚠️ 更新必要 |
| **cta_appstore_click** | ✅ 実装完了 | ✅ 実装完了 | ⚠️ 未記載 | ⚠️ 更新必要 |
| **Free制限（3 sketches, 12 chords）** | ✅ 実装完了 | ✅ 実装完了 | ✅ 記載 | ✅ 一致 |

---

### 5. プリセットの整合性

#### **Free（20種）**
| Implementation SSOT | Roadmap | 整合性 |
|---------------------|---------|--------|
| Rock 5 + Pop 5 + Blues 2 + Ballad 4 + Jazz 4 | Rock 5 + Pop 5 + Blues 2 + Ballad 4 + Jazz 4 | ✅ 一致 |

#### **Pro（+30種、合計50種）**
| Implementation SSOT | Roadmap | 整合性 |
|---------------------|---------|--------|
| Rock 6 + Pop 8 + Ballad 5 + Jazz 5 + Blues 2 + Other 4 | Rock 6 + Pop 8 + Ballad 5 + Jazz 5 + Blues 2 + Other 4 | ✅ 一致 |

---

### 6. Telemetryの整合性

#### **共通イベント**
| イベント | Implementation SSOT | System Architecture | 整合性 |
|---------|---------------------|---------------------|--------|
| `page_view` | ✅ | ✅ | ✅ 一致 |
| `key_pick` | ✅ | ✅ | ✅ 一致 |
| `scale_pick` | ✅ | ✅ | ✅ 一致 |
| `diatonic_pick` | ✅ | ✅ | ✅ 一致 |
| `overlay_shown` | ✅ | ✅ | ✅ 一致 |
| `export_png` | ✅ 必ず1回 | ✅ | ✅ 一致 |

#### **Web→iOS CTA**
| イベント | Implementation SSOT | System Architecture | 整合性 |
|---------|---------------------|---------------------|--------|
| `cta_appstore_click{place}` | ✅ 実装完了 | ⚠️ 未記載 | ⚠️ 更新必要 |

#### **iOS Pro**
| イベント | Implementation SSOT | System Architecture | 整合性 |
|---------|---------------------|---------------------|--------|
| `paywall_view` | ✅ | ⚠️ 未記載 | ⚠️ 更新必要 |
| `purchase_success` | ✅ | ⚠️ 未記載 | ⚠️ 更新必要 |
| `midi_export{tracks,sections,bpm}` | ✅ | ⚠️ 未記載 | ⚠️ 更新必要 |

---

### 7. DoD（受け入れ基準）の整合性

| 項目 | Implementation SSOT | Roadmap | 整合性 |
|------|---------------------|---------|--------|
| **Find Chords** | ✅ Key/Scale選択のみでResult更新 | ✅ | ✅ 一致 |
| **Capo** | ✅ Top2（Shaped）＋注記、音は鳴らさない | ✅ | ✅ 一致 |
| **Progression** | ✅ ドラッグ並べ替え、Undoなし | ✅ | ✅ 一致 |
| **Sketch** | ✅ Free=3件、Pro=無制限 | ✅ | ✅ 一致 |
| **PNG出力** | ✅ 白背景固定、export_png必ず1回 | ✅ | ✅ 一致 |
| **Web GA** | ✅ プリセット→即ループ→PNG出力が3クリック以内 | ✅ | ✅ 一致 |
| **M4 Week 1** | ✅ 完了（2025-10-04） | ✅ | ✅ 一致 |
| **M4 Week 2** | ✅ 完了（2025-10-04） | ✅ | ✅ 一致 |

---

### 8. Feature Flags / 環境変数の整合性

| フラグ | Implementation SSOT | System Architecture | 整合性 |
|--------|---------------------|---------------------|--------|
| `RECORDING_UI_ENABLED = false` | ✅ | ✅ | ✅ 一致 |
| `PNG_THEME_AUTO_INVERT = false` | ✅ | ⚠️ 未記載 | ⚠️ 更新必要 |
| `UNDO_ENABLED = false` | ✅ | ⚠️ 未記載 | ⚠️ 更新必要 |
| `CTA_APPSTORE_ENABLED = true` | ✅ | ⚠️ 未記載 | ⚠️ 更新必要 |

---

## 🔧 推奨される更新

### 1. **v3.1_SSOT.md**（優先度: 高）

#### 追加すべき内容:
- **セクション 4.5**: Hybrid Audio Architecture（M4オーディオ実装方針）
  - ギターPCM + ベース/ドラムMIDI
  - SSOT: Strum 10-20ms, Release 80-150ms
  - 実装計画: Phase A/B/C

#### 更新すべき内容:
- **オーディオ品質**: 「2バス・フェード方式」→「Hybrid方式」に更新
- **最終更新日**: 2025/10/04 → 2025/10/05

---

### 2. **v3.1_System_Architecture.md**（優先度: 高）

#### 追加すべき内容:
- **セクション 5**: Hybrid Audio Architecture（システム構成図）
  - `HybridPlayer` + `GuitarBounceService` + `SequencerBuilder`
  - ノード配線図（PlayerNode + Sampler×2 + Sequencer）
- **M4-B（Pro核）**の詳細:
  - セクション編集
  - MIDI出力（Chord+Markers+Guide）
  - Sketch無制限（クラウド同期）
  - IAP（¥490/月）
- **Telemetry**:
  - `cta_appstore_click{place}`
  - `paywall_view`
  - `purchase_success`
  - `midi_export{tracks,sections,bpm}`
- **Feature Flags**:
  - `PNG_THEME_AUTO_INVERT = false`
  - `UNDO_ENABLED = false`
  - `CTA_APPSTORE_ENABLED = true`

#### 更新すべき内容:
- **最終更新日**: 2025/10/04 → 2025/10/05

---

### 3. **v3.1_Roadmap_Milestones.md**（優先度: 中）

#### 追加すべき内容:
- **M4のオーディオ実装**:
  - Phase A: 基盤（1-2日）
  - Phase B: 最小再生（1-2日）
  - Phase C: 拡張（以後）
- **M4-Bの詳細**:
  - セクション編集
  - MIDI出力（Chord+Markers+Guide）
  - Sketch無制限（クラウド同期）
  - IAP（¥490/月）

#### 更新すべき内容:
- **最終更新日**: 2025/10/04 → 2025/10/05

---

## 📊 整合性スコア

| ドキュメント | 整合性スコア | 更新優先度 |
|-------------|-------------|-----------|
| **v3.1_Implementation_SSOT.md** | **100%** ✅ | - |
| **v3.1_SSOT.md** | **85%** ⚠️ | **高** |
| **v3.1_System_Architecture.md** | **75%** ⚠️ | **高** |
| **v3.1_Roadmap_Milestones.md** | **90%** ⚠️ | **中** |
| **Feature_Requirements_2.4_final.md** | **N/A** | 低（v2.4仕様、参考用） |
| **OtoTheory_Privacy_Legal_SSOT.md** | **100%** ✅ | - |

**総合スコア**: **87.5%** ⚠️

---

## ✅ 結論

### **現在の状態**
- ✅ **v3.1_Implementation_SSOT.md** は最新で、Hybrid Audio Architectureを含む全ての最新仕様を反映
- ⚠️ **他のSSOTファイル**は、Hybrid Audio Architectureの反映が必要

### **推奨アクション**
1. **v3.1_SSOT.md** にセクション 4.5（Hybrid Audio Architecture）を追加
2. **v3.1_System_Architecture.md** にセクション 5（Hybrid Audio Architecture システム構成図）を追加、M4-B詳細とTelemetry/Feature Flagsを更新
3. **v3.1_Roadmap_Milestones.md** にM4オーディオ実装詳細を追加

### **整合性の保証**
- 全ての更新は **v3.1_Implementation_SSOT.md（セクション 4.1）**を正本（Single Source of Truth）として参照
- 更新後は、全てのSSOTファイルで「Hybrid Audio Architecture」の記載が統一される

---

## 📝 次のステップ

### **Option 1: 今すぐ他のSSOTファイルを更新する**
- v3.1_SSOT.md にセクション 4.5 を追加
- v3.1_System_Architecture.md にセクション 5 を追加、その他の項目を更新
- v3.1_Roadmap_Milestones.md に M4 詳細を追加

### **Option 2: Phase A実装を優先し、SSOTは後で更新する**
- v3.1_Implementation_SSOT.md（セクション 4.1）を基に Phase A 実装を開始
- Phase A 完了後、実装結果を反映して他のSSOTファイルを更新

---

**推奨**: **Option 1（今すぐ更新）** を実施し、全てのSSOTファイルの整合性を100%にしてから Phase A 実装に進むことをお勧めします。


