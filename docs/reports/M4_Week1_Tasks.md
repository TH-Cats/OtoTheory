# M4 Week 1: 環境構築 & 共通ロジック抽出

**期間**: 2025-10-04 〜 2025-10-11（7日間）  
**目標**: iOS開発環境セットアップ + 共通ロジックパッケージ化 + Bridge実装 + Audio Engine基礎

---

## 📋 Week 1の目標

1. ✅ **共通ロジックの抽出**（`packages/core`）
2. ✅ **Xcodeプロジェクト作成**（`ototheory-ios`）
3. ✅ **JavaScriptCore Bridge実装**
4. ✅ **Audio Engine基礎**（単音・和音再生）
5. ✅ **Navigation & Routing**（Tab Bar）

---

## 🎯 あなたがするべきこと（ステップバイステップ）

### Day 1-2: 環境確認 & 共通ロジック抽出

#### ✅ Step 1: 開発環境の確認

```bash
# ターミナルで以下を実行して確認
xcodebuild -version
# 期待: Xcode 15.0 以上

swift --version
# 期待: Swift 5.9 以上

# Apple Developer Programの確認
# https://developer.apple.com/account/
# ログインして、有効なメンバーシップを確認
```

**✅ 確認事項**:
- [ ] Xcode 15.0+ インストール済み
- [ ] Apple Developer Program 登録済み
- [ ] 物理iOSデバイス（推奨）or Simulator（開発用）

---

#### ✅ Step 2: 共通ロジックパッケージの作成

**目的**: Web/iOSで共有する音楽理論ロジックを抽出

```bash
cd /Users/nh/App/OtoTheory

# packages/core ディレクトリを作成
mkdir -p packages/core/src

# 初期化
cd packages/core
npm init -y
```

**package.json の設定**:

```json
{
  "name": "@ototheory/core",
  "version": "1.0.0",
  "description": "OtoTheory shared music theory logic",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "watch": "tsc --watch",
    "clean": "rm -rf dist"
  },
  "keywords": ["music", "theory", "chords", "scales"],
  "author": "TH Quest",
  "license": "UNLICENSED",
  "devDependencies": {
    "typescript": "^5.0.0"
  }
}
```

**tsconfig.json の作成**:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "node",
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**実行**:

```bash
npm install
```

---

#### ✅ Step 3: 共通ロジックの抽出（コピー）

以下のファイルを `packages/core/src/` にコピーして整理します。

**コピー対象リスト**:

1. **Music Theory基礎**
   - `ototheory-web/src/lib/music-theory.ts` → `packages/core/src/music-theory/index.ts`
   
2. **Chords**
   - `ototheory-web/src/lib/chords/` → `packages/core/src/chords/`
   - `ototheory-web/src/lib/chordForms.ts` → `packages/core/src/chords/forms.ts`
   
3. **Scales**
   - `ototheory-web/src/lib/scales.ts` → `packages/core/src/scales/index.ts`
   - `ototheory-web/src/lib/scaleCatalog.ts` → `packages/core/src/scales/catalog.ts`
   
4. **Progressions**
   - `ototheory-web/src/lib/presets.ts` → `packages/core/src/progressions/presets.ts`
   
5. **Roman Numerals**
   - `ototheory-web/src/lib/roman.ts` → `packages/core/src/roman/index.ts`
   - `ototheory-web/src/lib/theory/roman/` → `packages/core/src/roman/`

6. **Theory Utilities**
   - `ototheory-web/src/lib/theory/` → `packages/core/src/theory/`

**ディレクトリ構成**:

```
packages/core/src/
├── index.ts              # メインエントリポイント
├── music-theory/
│   └── index.ts
├── chords/
│   ├── index.ts
│   ├── format.ts
│   ├── normalize.ts
│   ├── types.ts
│   └── forms.ts
├── scales/
│   ├── index.ts
│   └── catalog.ts
├── progressions/
│   ├── index.ts
│   └── presets.ts
├── roman/
│   ├── index.ts
│   ├── match.ts
│   └── patterns.ts
└── theory/
    ├── index.ts
    ├── capo.ts
    ├── diatonic.ts
    ├── fret.ts
    ├── scaleFit.ts
    └── transform.ts
```

**packages/core/src/index.ts**（メインエクスポート）:

```typescript
// Music Theory
export * from './music-theory';

// Chords
export * from './chords';

// Scales
export * from './scales';

// Progressions
export * from './progressions';

// Roman Numerals
export * from './roman';

// Theory Utilities
export * from './theory';
```

**ビルドして確認**:

```bash
cd /Users/nh/App/OtoTheory/packages/core
npm run build

# dist/ ディレクトリが生成され、.js と .d.ts ファイルが作成されることを確認
ls -la dist/
```

---

### Day 3-4: Xcodeプロジェクト作成 & Bridge実装

#### ✅ Step 4: Xcodeプロジェクト作成

1. **Xcodeを起動**
2. **File > New > Project...**
3. **iOS > App** を選択
4. **プロジェクト設定**:
   - Product Name: `OtoTheory`
   - Team: あなたのApple Developer Team
   - Organization Identifier: `com.thquest` (or your own)
   - Bundle Identifier: `com.thquest.ototheory`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**（後でCoreDataやSwiftDataを追加可能）
   - Include Tests: ✅ チェック
5. **保存場所**: `/Users/nh/App/OtoTheory/ototheory-ios/`

**ディレクトリ構成確認**:

```bash
ls -la /Users/nh/App/OtoTheory/ototheory-ios/
# 期待: OtoTheory.xcodeproj/, OtoTheory/, OtoTheoryTests/
```

---

#### ✅ Step 5: プロジェクト構造の整理

Xcode内で以下のグループ（フォルダ）を作成:

```
OtoTheory/
├── App/
│   ├── OtoTheoryApp.swift
│   └── ContentView.swift
├── Features/
│   └── (後で追加)
├── Core/
│   ├── Audio/
│   ├── Theory/
│   └── Telemetry/
├── Shared/
│   ├── Models/
│   ├── Extensions/
│   └── Utilities/
└── Resources/
    └── Assets.xcassets
```

**手順**:
1. Xcodeの左サイドバーで `OtoTheory` グループを右クリック
2. **New Group** を選択
3. 上記の名前でグループを作成

---

#### ✅ Step 6: JavaScriptCore Bridgeの実装

**目的**: TypeScriptロジックをSwiftから呼び出す

**Step 6-1: CoreロジックのJSバンドル作成**

```bash
cd /Users/nh/App/OtoTheory/packages/core

# dist/index.js を単一ファイルにバンドル（Webpackやesbuild使用）
# 簡易版: distファイルをそのままコピー

# Xcodeプロジェクトにコピー
mkdir -p ../ototheory-ios/OtoTheory/Resources/JS
cp dist/index.js ../ototheory-ios/OtoTheory/Resources/JS/ototheory-core.js
```

**Step 6-2: XcodeでJSファイルを追加**

1. Xcodeで `OtoTheory/Resources/` グループを右クリック
2. **Add Files to "OtoTheory"...**
3. `ototheory-core.js` を選択
4. **Copy items if needed** にチェック
5. **Add**

**Step 6-3: TheoryBridge.swift の作成**

Xcodeで `Core/Theory/` に新しいファイルを作成:

**TheoryBridge.swift**:

```swift
import Foundation
import JavaScriptCore

class TheoryBridge {
    private let context: JSContext
    
    init?() {
        guard let context = JSContext() else {
            print("Failed to create JSContext")
            return nil
        }
        self.context = context
        
        // エラーハンドリング
        context.exceptionHandler = { context, exception in
            if let exc = exception {
                print("JS Error: \(exc)")
            }
        }
        
        // JSファイルの読み込み
        guard let jsPath = Bundle.main.path(forResource: "ototheory-core", ofType: "js"),
              let jsCode = try? String(contentsOfFile: jsPath) else {
            print("Failed to load JS bundle")
            return nil
        }
        
        // JS実行
        context.evaluateScript(jsCode)
        
        print("TheoryBridge initialized successfully")
    }
    
    // Chord parsing example
    func parseChord(_ symbol: String) -> ChordInfo? {
        let script = """
        (function() {
            try {
                const result = parseChord('\(symbol)');
                return JSON.stringify(result);
            } catch (e) {
                return JSON.stringify({ error: e.message });
            }
        })()
        """
        
        guard let result = context.evaluateScript(script),
              let jsonString = result.toString(),
              let jsonData = jsonString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return nil
        }
        
        return ChordInfo(
            root: dict["root"] as? String ?? "",
            quality: dict["quality"] as? String ?? "",
            bass: dict["bass"] as? String
        )
    }
    
    // Diatonic chords example
    func getDiatonicChords(key: String, scale: String) -> [String] {
        let script = """
        (function() {
            try {
                const result = getDiatonicChords('\(key)', '\(scale)');
                return JSON.stringify(result);
            } catch (e) {
                return JSON.stringify([]);
            }
        })()
        """
        
        guard let result = context.evaluateScript(script),
              let jsonString = result.toString(),
              let jsonData = jsonString.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: jsonData) as? [String] else {
            return []
        }
        
        return array
    }
}

// Models
struct ChordInfo {
    let root: String
    let quality: String
    let bass: String?
}
```

**Step 6-4: テスト実行**

`ContentView.swift` を編集して動作確認:

```swift
import SwiftUI

struct ContentView: View {
    @State private var testResult = "Testing..."
    
    var body: some View {
        VStack(spacing: 20) {
            Text("OtoTheory iOS")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(testResult)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Test Bridge") {
                testBridge()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            testBridge()
        }
    }
    
    func testBridge() {
        guard let bridge = TheoryBridge() else {
            testResult = "Failed to initialize TheoryBridge"
            return
        }
        
        // Test chord parsing
        if let chord = bridge.parseChord("Cmaj7") {
            testResult = "✅ Chord parsed: \(chord.root) \(chord.quality)"
        } else {
            testResult = "❌ Failed to parse chord"
        }
        
        // Test diatonic chords
        let diatonic = bridge.getDiatonicChords(key: "C", scale: "ionian")
        if !diatonic.isEmpty {
            testResult += "\n✅ Diatonic: \(diatonic.joined(separator: ", "))"
        }
    }
}
```

**実行**:
1. Xcode上部の **Run** ボタンをクリック（または ⌘R）
2. Simulatorが起動し、アプリが表示される
3. "Test Bridge" ボタンをクリックして動作確認

**期待結果**:
```
✅ Chord parsed: C maj7
✅ Diatonic: C, Dm, Em, F, G, Am, Bdim
```

---

### Day 5-6: Audio Engine基礎

#### ✅ Step 7: Audio Engineの実装

**目的**: 単音・和音を再生できるようにする

**Step 7-1: AudioPlayer.swift の作成**

Xcodeで `Core/Audio/` に新しいファイルを作成:

**AudioPlayer.swift**:

```swift
import AVFoundation

class AudioPlayer: ObservableObject {
    private var engine: AVAudioEngine
    private var sampler: AVAudioUnitSampler
    private var isSetup = false
    
    init() {
        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        setupAudio()
    }
    
    private func setupAudio() {
        // Attach sampler to engine
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        
        // Load SoundFont (for now, use General MIDI)
        loadDefaultSoundFont()
        
        // Start engine
        do {
            try engine.start()
            isSetup = true
            print("Audio Engine started successfully")
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func loadDefaultSoundFont() {
        // Load default instrument (Acoustic Guitar Steel = 25)
        do {
            try sampler.loadInstrument(at: URL(fileURLWithPath: "/System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls"),
                                       program: 25, // Acoustic Guitar (steel)
                                       bankMSB: kAUSampler_DefaultMelodicBankMSB,
                                       bankLSB: kAUSampler_DefaultBankLSB)
            print("SoundFont loaded successfully")
        } catch {
            print("Failed to load SoundFont: \(error)")
        }
    }
    
    // Play single note
    func playNote(midiNote: UInt8, velocity: UInt8 = 100, duration: Double = 1.0) {
        guard isSetup else { return }
        
        // Note On
        sampler.startNote(midiNote, withVelocity: velocity, onChannel: 0)
        
        // Note Off (after duration)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.sampler.stopNote(midiNote, onChannel: 0)
        }
    }
    
    // Play chord (simultaneous notes)
    func playChord(midiNotes: [UInt8], velocity: UInt8 = 100, duration: Double = 1.0) {
        guard isSetup else { return }
        
        // Note On for all notes
        for note in midiNotes {
            sampler.startNote(note, withVelocity: velocity, onChannel: 0)
        }
        
        // Note Off for all notes (after duration)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            for note in midiNotes {
                self.sampler.stopNote(note, onChannel: 0)
            }
        }
    }
    
    // Convert note name to MIDI number (C4 = 60)
    func noteNameToMIDI(_ noteName: String, octave: Int = 4) -> UInt8? {
        let noteMap: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1,
            "D": 2, "D#": 3, "Eb": 3,
            "E": 4,
            "F": 5, "F#": 6, "Gb": 6,
            "G": 7, "G#": 8, "Ab": 8,
            "A": 9, "A#": 10, "Bb": 10,
            "B": 11
        ]
        
        guard let offset = noteMap[noteName] else { return nil }
        let midiNote = (octave + 1) * 12 + offset
        return UInt8(midiNote)
    }
}
```

**Step 7-2: ContentView でテスト**

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var audioPlayer = AudioPlayer()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("OtoTheory iOS Audio Test")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button("Play C note") {
                if let midi = audioPlayer.noteNameToMIDI("C", octave: 4) {
                    audioPlayer.playNote(midiNote: midi, duration: 1.0)
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Play C Major Chord") {
                let cMajor: [UInt8] = [60, 64, 67] // C4, E4, G4
                audioPlayer.playChord(midiNotes: cMajor, duration: 2.0)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

**実行**:
1. **Run** (⌘R)
2. ボタンをクリックして音が鳴ることを確認

**期待結果**:
- "Play C note" → C音が1秒鳴る
- "Play C Major Chord" → Cメジャーコードが2秒鳴る

---

### Day 7: Navigation & Routing

#### ✅ Step 8: Tab Bar Navigationの実装

**目的**: Progression, Find Chords, Settings の3画面を切り替えられるようにする

**Step 8-1: 各画面のPlaceholder作成**

`Features/Progression/` に:

**ProgressionView.swift**:

```swift
import SwiftUI

struct ProgressionView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Chord Progression")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Progression")
        }
    }
}
```

`Features/FindChords/` に:

**FindChordsView.swift**:

```swift
import SwiftUI

struct FindChordsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Find Chords")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Find Chords")
        }
    }
}
```

`Features/Settings/` に:

**SettingsView.swift**:

```swift
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("App") {
                    Text("Version 1.0.0")
                }
                
                Section("Legal") {
                    Link("Privacy Policy", destination: URL(string: "https://ototheory.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://ototheory.com/terms")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
```

**Step 8-2: MainTabView の作成**

`App/` に:

**MainTabView.swift**:

```swift
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ProgressionView()
                .tabItem {
                    Label("Progression", systemImage: "music.note.list")
                }
            
            FindChordsView()
                .tabItem {
                    Label("Find Chords", systemImage: "magnifyingglass")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
```

**Step 8-3: OtoTheoryApp.swift を更新**

```swift
import SwiftUI

@main
struct OtoTheoryApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
```

**実行**:
1. **Run** (⌘R)
2. 下部のTab Barで3画面が切り替わることを確認

---

## ✅ Week 1 完了チェックリスト

- [ ] Xcode 15.0+ インストール確認
- [ ] Apple Developer Program 確認
- [ ] `packages/core` 作成 & ビルド成功
- [ ] Xcodeプロジェクト作成完了
- [ ] TheoryBridge 実装 & テスト成功
- [ ] AudioPlayer 実装 & 音再生確認
- [ ] Tab Bar Navigation 実装完了

---

## 📝 Week 1 完了報告

Week 1が完了したら、以下を確認してください:

1. **共通ロジックが動作する**
   - `packages/core/dist/` にビルド成果物が存在
   - Bridge経由でChord parsingが動作

2. **音が鳴る**
   - 単音・和音が再生できる
   - AVAudioEngineが正常に動作

3. **画面遷移ができる**
   - Tab Barで3画面を切り替えられる

---

## 🚀 次のステップ（Week 2）

Week 1が完了したら、**Week 2: M4-A UI実装**に進みます:

1. **Progression View**（12スロット、D&D、Playback）
2. **Find Chords View**（Key/Scale picker、Diatonic table）
3. **Fretboard View**（二層、Degrees/Names、Tap to play）

---

**Week 1の準備が整いました！上記の手順を順番に実行してください。** 🚀

質問があれば、いつでもお聞きください！

