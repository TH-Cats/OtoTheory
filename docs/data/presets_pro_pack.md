# OtoTheory プリセット Pro パック（30種）

> **実装時参照用**: iOS/Web共通のProパック定義
> 
> **Free**: 既存20種（Rock 5 + Pop 5 + Blues 2 + Ballad 4 + Jazz 4）
> **Pro**: 追加30種（Rock 6 + Pop 8 + Ballad 5 + Jazz 5 + Blues 2 + Other 4）
> 
> **表記**: ローマ数字（大文字=メジャー／小文字=マイナー）、借用に `b`、副次ドミナントに `V/ii` など

---

## Rock（6種）

### 1. Backdoor Rock
```typescript
{
  category: "Rock",
  name: "Backdoor Rock",
  romanNumerals: ["IV", "bVII", "I"],
  description: "V→Iより柔らかな"バックドア"解決。ソウル〜ロックの終止に。",
  isPro: true
}
```

### 2. Aeolian Borrow (I–♭VI–♭VII–IV)
```typescript
{
  category: "Rock",
  name: "Aeolian Borrow",
  romanNumerals: ["I", "bVI", "bVII", "IV"],
  description: "メジャーIに短調借用を混ぜた大サビ感。アリーナ系に多い。",
  isPro: true
}
```

### 3. Minor Drive (i–♭VII–♭VI–♭VII)
```typescript
{
  category: "Rock",
  name: "Minor Drive",
  romanNumerals: ["i", "bVII", "bVI", "bVII"],
  description: "マイナー定番の下降系アンセム。"Watchtower"系の推進力。",
  isPro: true
}
```

### 4. Phrygian Tag (i–♭II–i–♭VII)
```typescript
{
  category: "Rock",
  name: "Phrygian Tag",
  romanNumerals: ["i", "bII", "i", "bVII"],
  description: "フリジアンの刺激をイントロ/間奏に一差し。スペイン風/メタル感。",
  isPro: true
}
```

### 5. Mixolydian Push (I–V–♭VII–IV)
```typescript
{
  category: "Rock",
  name: "Mixolydian Push",
  romanNumerals: ["I", "V", "bVII", "IV"],
  description: "Vの後に♭VIIで一段抜ける。プレコーラス〜タグで勢いを。",
  isPro: true
}
```

### 6. Pedal Home (I–♭VII–I–IV)
```typescript
{
  category: "Rock",
  name: "Pedal Home",
  romanNumerals: ["I", "bVII", "I", "IV"],
  description: "Iペダルで"家"を感じさせつつ外へ。90sオルタナ風味。",
  isPro: true
}
```

---

## Pop（8種）

### 1. Pop Walkdown
```typescript
{
  category: "Pop",
  name: "Pop Walkdown",
  romanNumerals: ["I", "V", "vi", "IV"],
  description: "C–G/B–Am–F系の滑らかなベース降下。世界標準のバラード土台。",
  isPro: true
}
```

### 2. Pre‑Chorus Lydian Lift
```typescript
{
  category: "Pop",
  name: "Pre‑Chorus Lydian Lift",
  romanNumerals: ["I", "II", "V", "I"],
  description: "I–IIの#4で明度アップ→Vで合図。J‑Pop風の"持ち上げ"。",
  isPro: true
}
```

### 3. Axis Flip (I–vi–V–IV)
```typescript
{
  category: "Pop",
  name: "Axis Flip",
  romanNumerals: ["I", "vi", "V", "IV"],
  description: "Axisの並び替え。明るく回るヴァース向け。",
  isPro: true
}
```

### 4. Canon (8‑bar)
```typescript
{
  category: "Pop",
  name: "Canon (8‑bar)",
  romanNumerals: ["I", "V", "vi", "iii", "IV", "I", "IV", "V"],
  description: "パッヘルベル系の8小節ロング。映画的/壮大な展開に。",
  isPro: true
}
```

### 5. Plagal Push (deceptive)
```typescript
{
  category: "Pop",
  name: "Plagal Push",
  romanNumerals: ["IV", "V", "I", "vi"],
  description: "IV→Vで押し出し、V→viでひとひねり（偽終止）。",
  isPro: true
}
```

### 6. Anticipation Pop
```typescript
{
  category: "Pop",
  name: "Anticipation Pop",
  romanNumerals: ["V", "vi", "IV", "V"],
  description: "Vを強調して前のめりに。サビ前の期待値を稼ぐ。",
  isPro: true
}
```

### 7. Lydian Chorus
```typescript
{
  category: "Pop",
  name: "Lydian Chorus",
  romanNumerals: ["I", "II", "IV", "I"],
  description: ""空が開く"Lydian色の大サビ。J‑Popコメントで響く配合。",
  isPro: true
}
```

### 8. Sunrise Pop (I–iii–vi–IV)
```typescript
{
  category: "Pop",
  name: "Sunrise Pop",
  romanNumerals: ["I", "iii", "vi", "IV"],
  description: "I→iiiの上昇で"夜明け"感→viで一息。朝系CMの定番感。",
  isPro: true
}
```

---

## Ballad（5種）

### 1. Circle Ballad
```typescript
{
  category: "Ballad",
  name: "Circle Ballad",
  romanNumerals: ["I", "vi", "ii", "V"],
  description: "やさしい循環（五度進行）。ジャズ/ポップの定番バラード。",
  isPro: true
}
```

### 2. Descending Thirds
```typescript
{
  category: "Ballad",
  name: "Descending Thirds",
  romanNumerals: ["I", "V", "iii", "vi"],
  description: "80〜90年代の"降り三度"系。メロが乗りやすい。",
  isPro: true
}
```

### 3. Deceptive End
```typescript
{
  category: "Ballad",
  name: "Deceptive End",
  romanNumerals: ["V", "vi", "IV", "V"],
  description: "V→viで"外す"終わり→戻す。ブリッジ→ラストサビに。",
  isPro: true
}
```

### 4. Borrowed iv Glow
```typescript
{
  category: "Ballad",
  name: "Borrowed iv Glow",
  romanNumerals: ["I", "IV", "iv", "I"],
  description: "借用ivで切なさを1滴。名曲感の陰影（J‑Popコメントで好相性）。",
  isPro: true
}
```

### 5. Gentle Rise
```typescript
{
  category: "Ballad",
  name: "Gentle Rise",
  romanNumerals: ["IV", "I", "V", "vi"],
  description: "プラガル始動→Iで落ち着き→viへ柔らかく上がる。",
  isPro: true
}
```

---

## Jazz（5種）

### 1. Rhythm Changes (Bridge)
```typescript
{
  category: "Jazz",
  name: "Rhythm Changes (Bridge)",
  romanNumerals: ["III", "VI", "II", "V"],
  description: ""I Got Rhythm"のB部。ドミナント連鎖で一気に前進。",
  isPro: true
}
```

### 2. Tadd Dameron Turnaround
```typescript
{
  category: "Jazz",
  name: "Tadd Dameron Turnaround",
  romanNumerals: ["I", "bIII", "bVI", "bII"],
  description: ""Lady Bird"系の名物ターン。クロマチックにIへ帰還。",
  isPro: true
}
```

### 3. ii–V Vamp
```typescript
{
  category: "Jazz",
  name: "ii–V Vamp",
  romanNumerals: ["ii", "V", "ii", "V"],
  description: "ii–Vの往復。ソロ/アドリブの土台に最適。",
  isPro: true
}
```

### 4. I→IV Turnaround
```typescript
{
  category: "Jazz",
  name: "I→IV Turnaround",
  romanNumerals: ["I", "IV", "ii", "V"],
  description: "プラガルの彩り→ii–V 着地。AABAの回しにも。",
  isPro: true
}
```

### 5. Secondary Chain (V/ii→…)
```typescript
{
  category: "Jazz",
  name: "Secondary Chain",
  romanNumerals: ["V/ii", "ii", "V", "I"],
  description: "V/iiで"助走"→ii→V→I。ポップジャズでも使いやすい。",
  isPro: true
}
```

---

## Blues（2種）

### 1. 12‑bar Blues (Quick IV)
```typescript
{
  category: "Blues",
  name: "12‑bar Blues (Quick IV)",
  romanNumerals: ["I","IV","I","I","IV","IV","I","I","V","IV","I","V"],
  description: "2小節目にIVを置くクイックIV型。より"ブルース"なうねり。",
  isPro: true
}
```

### 2. 12‑bar Minor
```typescript
{
  category: "Blues",
  name: "12‑bar Minor",
  romanNumerals: ["i","i","i","i","iv","iv","i","i","VI","V","i","V"],
  description: "マイナーブルースの定番。ソウル/バラードにも効く陰影。",
  isPro: true
}
```

---

## Other（4種）

> R&B/Soul/Gospel/Latin/EDMなど

### 1. Andalusian Cadence
```typescript
{
  category: "Other",
  name: "Andalusian Cadence",
  romanNumerals: ["i", "VII", "VI", "V"],
  description: "スペイン/ラテンの看板下降。ポップでも頻出（"Hit the Road Jack"系）。",
  isPro: true
}
```

### 2. EDM Minor Loop
```typescript
{
  category: "Other",
  name: "EDM Minor Loop",
  romanNumerals: ["i", "VI", "III", "VII"],
  description: "祭典系のAeolianループ。EDM/モダンポップの鉄板。",
  isPro: true
}
```

### 3. Gospel Walk‑up
```typescript
{
  category: "Other",
  name: "Gospel Walk‑up",
  romanNumerals: ["I", "ii", "iii", "IV"],
  description: "ベースの上行で高揚。プレコーラスの"持ち上げ"に最適。",
  isPro: true
}
```

### 4. Bossa Turnaround
```typescript
{
  category: "Other",
  name: "Bossa Turnaround",
  romanNumerals: ["ii", "V", "I", "VI"],
  description: "ボサの基本回し。maj7/9を足すと一気に都会的（Proの色付けに）。",
  isPro: true
}
```

---

## 実装メモ

### Free/Pro の切り分け

* **Free**: 既存20種をそのまま公開
  - おすすめプリセット: 3〜5件のショートリスト
  - 1タップで挿入 → **自動ループ再生**
  
* **Pro**: 追加30種を **「More presets（🔒Pro）」** で開放
  - 既存のFree/Pro方針に準拠
  - 操作2タップ以内、実装/計測イベント統合

### UIルール（SSOT v3準拠）

* **Diatonic → Fretboard（二層） → 試聴 → ＋Add**
* 追加後は **即ループ再生**
* Freeでは広告スロット、Proは非表示

### 計測

* `preset_inserted` / `progression_play` を既存テレメトリに統合
* **1操作=1発火** 原則
* PNG/MIDI出力: `export_png` / ProでMIDI有効

### 表記仕様

* **ローマ数字**: 大文字=メジャー／小文字=マイナー
* **借用**: `b` プレフィックス（例: `bVI`, `bVII`）
* **副次ドミナント**: `V/ii` 形式
* **品質**: maj7/7/sus等は「Proの色付け」で推奨テキストに留め、**プリセット本体は三和音基調**

### タグ（任意）

* `usecase: "Intro"|"Pre‑Chorus"|"Chorus"|"Bridge"|"Tag"` をメタに付けると並び替え/検索が便利
* UIは後回しでも可

### カテゴリ順序

既存の順序を維持:
1. Rock
2. Pop
3. Blues
4. Ballad
5. Jazz
6. Other

FreeとProの境界は **見た目ロック＋説明テキスト** で自然に誘導

---

## iOS/Web 実装パス

### iOS

```
OtoTheory-iOS/OtoTheory/Data/Presets.swift
または
OtoTheory-iOS/OtoTheory/Data/PresetsPro.swift
```

### Web

```
ototheory-web/src/lib/presets.ts
または
ototheory-web/src/lib/presetsPro.ts
```

**統一仕様**: TypeScript/Swift両方で同じ構造を維持


