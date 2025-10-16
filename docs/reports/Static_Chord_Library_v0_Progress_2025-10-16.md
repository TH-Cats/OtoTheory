タイトル: Static Chord Library v0 進捗レポート（2025-10-16）

概要:
- iOS版 Static Chord Library v0 の大幅拡充を実施。
- 7th / maj7 / m7 系を中心に Open, Root-6, Root-5, Root-4 を網羅（Triadは未着手）。
- UI でフォーム順を「Open → Root-6 → Root-5 → Root-4 → Triad-1 → Triad-2」に固定。タイトル自動推定を追加。

主な実装:
- C7, D7, E7, C#7, D#7, F#7, G7, G#7, A7, Bb7, B7（各4フォーム中心）
- CM7, C#M7, DM7, GM7, G#M7, AM7, EM7, FM7, F#M7 などの maj7 系
- Cm7, C#m7, Dm7, D#m7, Em7, F#m7, Fm7, Gm7, G#m7, Am7, Bbm7, Bm7 などの m7 系
- `StaticChordLibraryView` にフォーム並び替え・タイトル表示を追加
- `ChordLibrary` 変換層で shapeName がない場合に Open/Root-6/5/4 を推定

既知の制約:
- Triad-1/2 は自動推定のみ（定義データ未投入）
- フォームの Tips は英語簡易表現

次アクション候補:
- Triad 定義の投入と UI 強調（省スペース表示）
- sus2/sus4, add9, 6/9 の静的フォーム追加
- Web 版への同期（必要に応じて）

コミット/ブランチ:
- ブランチ: feat/chord-library-static-v0
- 代表コミット: Enforce form order and titles（6a853bb ほか多数）


