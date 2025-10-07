# @ototheory/core

OtoTheory共通ロジックパッケージ - Web/iOSで共有する音楽理論ロジック

## 概要

このパッケージは、OtoTheoryのWebアプリとiOSアプリで共通して使用する音楽理論ロジックを含んでいます。

## 含まれる機能

- **Music Theory**: 音名、音程、移調
- **Chords**: コード解析、正規化、フォーマット
- **Scales**: スケール定義、ダイアトニックコード生成
- **Progressions**: プリセットパターン、進行検証
- **Roman Numerals**: ローマ数字とコードの変換

## セットアップ

```bash
npm install
npm run build
```

## 使用方法

### TypeScript/JavaScript (Web)

```typescript
import { parseChord, getDiatonicChords } from '@ototheory/core';

const chord = parseChord('Cmaj7');
console.log(chord); // { root: 'C', quality: 'maj7', bass: null }

const diatonic = getDiatonicChords('C', 'ionian');
console.log(diatonic); // ['C', 'Dm', 'Em', 'F', 'G', 'Am', 'Bdim']
```

### Swift (iOS via JavaScriptCore)

```swift
import JavaScriptCore

let bridge = TheoryBridge()
let chord = bridge.parseChord("Cmaj7")
let diatonic = bridge.getDiatonicChords(key: "C", scale: "ionian")
```

## ビルド

```bash
npm run build      # dist/にビルド
npm run watch      # ファイル変更を監視
npm run clean      # distディレクトリを削除
```

## ライセンス

UNLICENSED - OtoTheory専用


