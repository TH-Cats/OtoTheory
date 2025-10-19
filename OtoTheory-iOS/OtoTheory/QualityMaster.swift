//
//  QualityMaster.swift
//  OtoTheory
//
//  Quality Master Data - Single Source of Truth for chord qualities
//  Generated from /Users/nh/App/OtoTheory/docs/content/Quality new commnt_v2.csv

import Foundation

struct QualityMasterInfo {
    let tier: String // "Free" or "Pro"
    let categoryJa: String
    let categoryEn: String
    let quality: String
    let commentJa: String
    let commentEn: String
}

struct QualityMaster {
    // Helper function to convert plain section headers to enhanced bullet point format
    private static func toMarkdown(_ text: String) -> String {
        // 1) 改行を統一
        var s = text.replacingOccurrences(of: "\r\n", with: "\n")
                    .replacingOccurrences(of: "\r", with: "\n")

        // 2) 「見出し:」のゆらぎ（半角/全角コロン、前後の空白、先頭の箇条書き記号）を正規化
        //   雰囲気 / 特徴 / Try / 理論（日本語） + Vibe / Usage / Theory（英語）をすべて対象
        let patterns = [
            (#"(?m)^\s*(?:[•\-\*]\s*)?(雰囲気)\s*[:：]\s*"#, "• **$1**\n"),
            (#"(?m)^\s*(?:[•\-\*]\s*)?(特徴)\s*[:：]\s*"#, "• **$1**\n"),
            (#"(?m)^\s*(?:[•\-\*]\s*)?(Try)\s*[:：]\s*"#, "• **$1**\n"),
            (#"(?m)^\s*(?:[•\-\*]\s*)?(理論)\s*[:：]\s*"#, "• **$1**\n"),
            (#"(?m)^\s*(?:[•\-\*]\s*)?(Vibe)\s*[:：]\s*"#, "• **$1**\n"),
            (#"(?m)^\s*(?:[•\-\*]\s*)?(Usage)\s*[:：]\s*"#, "• **$1**\n"),
            (#"(?m)^\s*(?:[•\-\*]\s*)?(Theory)\s*[:：]\s*"#, "• **$1**\n"),
        ]
        for (pattern, replacement) in patterns {
            if let re = try? NSRegularExpression(pattern: pattern) {
                s = re.stringByReplacingMatches(in: s, options: [], range: NSRange(s.startIndex..., in: s), withTemplate: replacement)
            }
        }

        // 3) 連続改行を少しだけ増やし、段落の読みやすさを確保（お好みで）
        s = s.replacingOccurrences(of: #"\n{2,}"#, with: "\n\n", options: .regularExpression)

        return s
    }
    
    static let allQualities: [QualityMasterInfo] = [
        // Free - 基本 (Basics)
        QualityMasterInfo(
            tier: "Free",
            categoryJa: "基本",
            categoryEn: "Basics",
            quality: "Major",
            commentJa: toMarkdown("雰囲気: 明るくポジティブ。物語の始まりやサビにふさわしい、安定感と幸福感に満ちた響きです。\n特徴: J-POP、ロック、フォーク、童謡など、あらゆる音楽の基本となるコード。楽曲の骨格を形成します。\nTry: 曲の最も盛り上がる部分や、リスナーに安心感を与えたい場面で使ってみよう。ここぞという時の主役になります。\n理論: 構成音はR-3-5。メジャースケール（イオニアン）上で完璧に調和し、ダイアトニックのI度、IV度、V度で登場します。"),
            commentEn: toMarkdown("Vibe: Bright and positive. A sound full of stability and happiness, perfect for the start of a story or a chorus.\nUsage: The fundamental chord in all music, from J-Pop and rock to folk. It forms the skeleton of a song.\nTry: Use it in the most climactic parts of a song or when you want to give the listener a sense of security.\nTheory: Composed of R-3-5. It harmonizes perfectly with the Major (Ionian) scale and appears as the I, IV, and V chords.")
        ),
        QualityMasterInfo(
            tier: "Free",
            categoryJa: "基本",
            categoryEn: "Basics",
            quality: "m (minor)",
            commentJa: toMarkdown("雰囲気: 少し切なく、落ち着いた雰囲気。喜びだけでなく、哀愁や内省的な感情を表現するのに最適です。\n特徴: バラード、ロック、R&Bなど、深みのある楽曲には欠かせない存在。メジャーとの対比が曲にドラマを生みます。\nTry: Aメロで静かに始めたい時や、サビ後のクールダウン、感情的な歌詞に乗せて使ってみましょう。\n理論: 構成音はR-b3-5。b3(短3度)の音が特徴です。ナチュラルマイナースケール（エオリアン）の基本コードになります。"),
            commentEn: toMarkdown("Vibe: Slightly sad and calm. Perfect for expressing not just joy, but also melancholy and introspection.\nUsage: Essential for deep songs like ballads, rock, and R&B. Its contrast with major chords creates drama.\nTry: Use it to start a verse quietly, to cool down after a chorus, or to accompany emotional lyrics.\nTheory: Composed of R-b3-5. The b3rd is its key feature. It's the basic chord of the Natural Minor (Aeolian) scale.")
        ),
        QualityMasterInfo(
            tier: "Free",
            categoryJa: "基本",
            categoryEn: "Basics",
            quality: "7",
            commentJa: toMarkdown("雰囲気: 少し不安定で、次へ進みたいという推進力を持つサウンド。ブルージーでおしゃれな緊張感が魅力です。\n特徴: ブルース、ジャズ、ファンク、ロックンロールの魂。楽曲にドライブ感と解決への期待感を与えます。\nTry: サビの直前（V7）に置いて、解決感を劇的に高めてみましょう。ブルース進行の主役としても活躍します。\n理論: 構成音はR-3-5-b7。ミクソリディアンスケール上で自然に発生。V7→Iという最強の進行（ドミナントモーション）を作ります。"),
            commentEn: toMarkdown("Vibe: A slightly unstable sound with a drive to move forward. Its bluesy, stylish tension is captivating.\nUsage: The soul of blues, jazz, and funk. It gives a song drive and anticipation for resolution.\nTry: Place it right before the chorus (as a V7) to dramatically enhance the feeling of resolution.\nTheory: Composed of R-3-5-b7. It naturally occurs on the Mixolydian scale and creates the powerful V7→I progression (dominant motion).")
        ),
        QualityMasterInfo(
            tier: "Free",
            categoryJa: "基本",
            categoryEn: "Basics",
            quality: "maj7",
            commentJa: toMarkdown("雰囲気: 明るさの中に洗練された都会的な響きが同居。爽やかな風が吹くような、開放的でおしゃれなサウンドです。\n特徴: J-POP、R&B、ジャズ、ボサノヴァの定番。楽曲の始まりや終わりに使うと、余韻のある雰囲気を演出できます。\nTry: 明るい曲のトニックコード(I)をこれ(Imaj7)に変えてみましょう。一瞬でサウンドが洗練され、シティポップ模が生まれます。\n理論: 構成音はR-3-5-7。長7度の音が特徴です。メジャースケール（イオニアン）やリディアンスケールと相性抜群です。"),
            commentEn: toMarkdown("Vibe: A sophisticated, urban sound within a bright context. Open and stylish, like a fresh breeze.\nUsage: A staple in J-Pop, R&B, and jazz. Using it at the beginning or end of a song creates a lingering atmosphere.\nTry: Change the tonic chord (I) of a bright song to Imaj7. The sound will instantly become more refined.\nTheory: Composed of R-3-5-7. The major 7th is its key feature. It pairs perfectly with the Major (Ionian) and Lydian scales.")
        ),
        QualityMasterInfo(
            tier: "Free",
            categoryJa: "基本",
            categoryEn: "Basics",
            quality: "m7",
            commentJa: toMarkdown("雰囲気: マイナーの切なさに、ジャズやソウルの香りを加えた、少し大人びた響き。クールで落ち着いています。\n特徴: ジャズのスタンダードやR&B、ファンク、AORで頻繁に使われる、マイナーキーの基本的な和音です。\nTry: マイナーキーの曲で、トニックコード(Im)をこれ(Im7)に変えてみましょう。ただ暗いだけでない、知的な雰囲気に変わります。\n理論: 構成音はR-b3-5-b7。ナチュラルマイナー（エオリアン）やドリアンスケール上で発生します。"),
            commentEn: toMarkdown("Vibe: Adds a touch of jazz and soul to minor sadness, creating a mature, cool, and calm sound.\nUsage: The fundamental minor chord in jazz standards, R&B, and funk.\nTry: In a minor key song, change the tonic chord from Im to Im7. It will shift the mood from simply dark to something more intelligent.\nTheory: Composed of R-b3-5-b7. It occurs on the Natural Minor (Aeolian) and Dorian scales.")
        ),
        
        // Free - 基本の飾り付け (Essential Colors)
        QualityMasterInfo(
            tier: "Free",
            categoryJa: "基本の飾り付け",
            categoryEn: "Essential Colors",
            quality: "sus4",
            commentJa: toMarkdown("雰囲気: メジャーでもマイナーでもない、解決を焦らす浮遊感。リスナーの期待感をグッと高める効果があります。\n特徴: ポップス、ロック、ファンクなどジャンルを問わず使われる。特にAメロからBメロへの繋ぎなどで効果的です。\nTry: V7の前に置き(V7sus4)、より劇的な解決感を演出してみましょう。アコギのストロークで使うと響きが豊かになります。\n理論: 3度の音を4度にした(R-4-5)コード。susはSuspended(吊るされた)の略で、3度への解決を待ち望んでいます。"),
            commentEn: toMarkdown("Vibe: A floating feel, neither major nor minor, that delays resolution and builds anticipation in the listener.\nUsage: Used across all genres. Especially effective for transitions, like from a verse to a bridge.\nTry: Place it before a V7 (as V7sus4) to create a more dramatic resolution. It sounds rich in acoustic strumming.\nTheory: Replaces the 3rd with a 4th (R-4-5). \"Sus\" is short for Suspended, as it longs to resolve to the 3rd.")
        ),
        QualityMasterInfo(
            tier: "Free",
            categoryJa: "基本の飾り付け",
            categoryEn: "Essential Colors",
            quality: "sus2",
            commentJa: toMarkdown("雰囲気: sus4よりも、さらに明るく爽やかで、キラキラした浮遊感。若々しさや純粋さを感じさせます。\n特徴: J-POPやロックバラードのイントロやアルペジオで多用される。澄んだ響きがアコースティックギターによく合います。\nTry: メジャーコードの代わりに一瞬だけ使ってみましょう。サウンドに爽やかな風が吹き込み、単調さがなくなります。\n理論: 3度の音を2度にした(R-2-5)コード。ポップスではadd9に近い響きの飾り（embellishment）として使われます。"),
            commentEn: toMarkdown("Vibe: Brighter and fresher than sus4, with a sparkling floatiness that evokes youthfulness and purity.\nUsage: Often used in intros and arpeggios of J-Pop and rock ballads. Its clear sound suits acoustic guitars.\nTry: Briefly substitute it for a major chord. It will add a fresh breeze to your sound and break up monotony.\nTheory: Replaces the 3rd with a 2nd (R-2-5). In pop, it's often used as an embellishment with a sound similar to add9.")
        ),
        QualityMasterInfo(
            tier: "Free",
            categoryJa: "基本の飾り付け",
            categoryEn: "Essential Colors",
            quality: "add9",
            commentJa: toMarkdown("雰囲気: 通常のコードに、透明感や希望の光を一筋加える、感動的な響き。サウンドに広がりと彩りを与えます。\n特徴: 現代のポップス、ロック、バラードではなくてはならない存在。特にピアノやギターのアルペジオで美しい響きを生みます。\nTry: サビの最後のコードをこれに変えてみましょう。曲のエンディングに、感動的な余韻と広がりが生まれます。\n理論: メジャー(R-3-5)に9度の音を追加したコード。9度は2度と同じ音ですが、3度と共存しているのがポイントです。"),
            commentEn: toMarkdown("Vibe: An emotional sound that adds a layer of transparency and hope to a basic chord, creating spaciousness and color.\nUsage: An indispensable chord in modern pop, rock, and ballads. It sounds beautiful in piano or guitar arpeggios.\nTry: Change the last chord of the chorus to this one. It will create a moving, expansive finish to your song.\nTheory: Adds a 9th note to a major triad (R-3-5-9). The 9th is the same note as the 2nd, but the key is its coexistence with the 3rd.")
        ),
        QualityMasterInfo(
            tier: "Free",
            categoryJa: "基本の飾り付け",
            categoryEn: "Essential Colors",
            quality: "dim",
            commentJa: toMarkdown("雰囲気: 不気味で、聴き手を不安にさせるスリリングな響き。物語にサスペンスやミステリーの要素を加えます。\n特徴: ジャズやクラシックで、コードとコードを滑らかに繋ぐ「経過コード」として使われるのが定石です。\nTry: Bdimのような経過コードをCとAmの間に挟んでみましょう。ベースラインが滑らかになり、プロっぽい響きになります。\n理論: 構成音はR-b3-b5。不安定なトライトーン(b5)が強い緊張感を生み出します。"),
            commentEn: toMarkdown("Vibe: A spooky, thrilling sound that creates unease, adding an element of suspense or mystery to a story.\nUsage: A classic \"passing chord\" in jazz and classical music used to smoothly connect other chords.\nTry: Insert a passing chord like Bdim between C and Am. The bassline will become smoother and sound more professional.\nTheory: Composed of R-b3-b5. Its unstable tritone interval (b5) generates strong tension.")
        ),
        
        // Pro - ✨ キラキラ・浮遊感 (Sparkling & Floating)
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "✨ キラキラ・浮遊感",
            categoryEn: "Sparkling & Floating",
            quality: "M9 (maj9)",
            commentJa: toMarkdown("雰囲気: maj7をさらに進化させた、優雅で甘美、夢見心地な響き。ラグジュアリーな空間を演出します。\n特徴: R&B、ネオソウル、フュージョンの王道サウンド。これ一つで曲のおしゃれ度が格段にアップします。\nTry: 静かなバラードのトニックコード(Imaj7)をこれ(Imaj9)にしてみましょう。サウンドに深みと極上の甘さが加わります。\n理論: maj7(R-3-5-7)に9度の音を追加したコード。リディアンスケールとの相性は最高です。"),
            commentEn: toMarkdown("Vibe: An evolution of maj7, creating an elegant, sweet, and dreamy atmosphere. Evokes a sense of luxury.\nUsage: The quintessential sound of R&B, Neo-Soul, and Fusion. It instantly elevates the chicness of a song.\nTry: In a quiet ballad, change the tonic Imaj7 to Imaj9. It will add depth and a sublime sweetness to the sound.\nTheory: Adds a 9th to a maj7 chord (R-3-5-7-9). It has a fantastic compatibility with the Lydian scale.")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "✨ キラキラ・浮遊感",
            categoryEn: "Sparkling & Floating",
            quality: "6",
            commentJa: toMarkdown("雰囲気: maj7よりも少しだけ素朴で、温かくレトロな雰囲気。50-60年代のような、懐かしい響きです。\n特徴: 古き良き時代のジャズやポップス、ハワイアン音楽で多用される。サウンドを柔らかく、穏やかにします。\nTry: maj7の代わりに使ってみましょう。特に曲のエンディングで使うと、ハッピーエンドの映画のような、温かい余韻が残ります。\n理論: メジャー(R-3-5)に長6度の音を加えたコード。トニックコード(I)のバリエーションとして使えます。"),
            commentEn: toMarkdown("Vibe: A bit simpler and warmer than maj7, with a nostalgic, retro vibe like the 50s-60s.\nUsage: Frequently used in old-time jazz, pop, and Hawaiian music. It softens the sound and makes it gentle.\nTry: Use it instead of maj7. Especially at the end of a song, it leaves a warm afterglow, like a happy-ending movie.\nTheory: Adds a major 6th to a major triad (R-3-5-6). It can be used as a variation of the tonic chord (I).")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "✨ キラキラ・浮遊感",
            categoryEn: "Sparkling & Floating",
            quality: "6/9",
            commentJa: toMarkdown("雰囲気: 6コードの温かさとadd9のキラキラ感を併せ持つ、非常に豊かでゴージャスな響き。\n特徴: ジャズピアノのエンディングなどで聴ける、幸福感に満ちたサウンド。フュージョンやAORでも使われます。\nTry: 曲の最後の最後、全ての音が消える直前のキメの和音として使ってみましょう。最高の多幸感を演出できます。\n理論: R-3-5に6度と9度の両方を加えた贅沢なコード。構成音が多く、豊かな倍音を生み出します。"),
            commentEn: toMarkdown("Vibe: Combines the warmth of a 6 chord with the sparkle of an add9, creating a rich, gorgeous, and happy sound.\nUsage: A blissful sound often heard at the end of jazz piano pieces, also used in Fusion and AOR.\nTry: Use it as the final, ultimate chord of a song right before everything fades to silence for maximum euphoria.\nTheory: A luxurious chord adding both the 6th and 9th to a triad (R-3-5-6-9). Its many notes create rich overtones.")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "✨ キラキラ・浮遊感",
            categoryEn: "Sparkling & Floating",
            quality: "add#11",
            commentJa: toMarkdown("雰囲気: メジャーコードに禁断の響き(#11)を加えた、現代的でドリーミーなサウンド。不思議な浮遊感が魅力です。\n特徴: 現代ジャズや映画音楽、ポストロックなどで、ミステリアスな雰囲気を出すために使われます。\nTry: Imaj7やIVmaj7のコードに、この#11の音をメロディで乗せてみましょう。リディアンスケールの世界観が広がります。\n理論: 構成音はR-3-5-#11。リディアンスケールの特徴音である#4(=#11)を含んだコードです。"),
            commentEn: toMarkdown("Vibe: A modern, dreamy sound that adds a \"forbidden\" note (#11) to a major chord, creating a unique floating feel.\nUsage: Used in contemporary jazz, film scores, and post-rock to create a mysterious atmosphere.\nTry: Try playing a #11 note in your melody over a Imaj7 or IVmaj7 chord to instantly evoke the Lydian scale.\nTheory: Composed of R-3-5-#11. It contains the characteristic #4 (=#11) note of the Lydian scale.")
        ),
        
        // Pro - 🌃 おしゃれ・都会的 (Stylish & Urban)
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "🌃 おしゃれ・都会的",
            categoryEn: "Stylish & Urban",
            quality: "m9",
            commentJa: toMarkdown("雰囲気: m7の切なさを、さらにスムーズで洗練させた響き。クールで知的な印象を与えます。\n特徴: Lo-fi Hip HopやR&Bの夜の雰囲気に完璧にマッチ。ジャズのマイナーコードとしても定番です。\nTry: マイナーキーの曲で、IIm7の代わりにIIm9を使ってみましょう。よりスムーズでおしゃれなコード進行になります。\n理論: m7(R-b3-5-b7)に9度の音を追加したコード。ドリアンスケールやエオリアンスケール上で使えます。"),
            commentEn: toMarkdown("Vibe: An even smoother and more refined version of m7's sadness, giving a cool and intelligent impression.\nUsage: Perfectly matches the nocturnal vibe of Lo-fi Hip Hop and R&B. A standard minor chord in jazz.\nTry: In a minor key song, use IIm9 instead of IIm7. The progression will become smoother and more stylish.\nTheory: Adds a 9th to an m7 chord (R-b3-5-b7-9). It can be used over the Dorian and Aeolian scales.")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "🌃 おしゃれ・都会的",
            categoryEn: "Stylish & Urban",
            quality: "m11",
            commentJa: toMarkdown("雰囲気: m9よりもさらにアンニュイで、複雑な感情を表現する響き。雨の日のサウンドトラックのようです。\n特徴: 現代のR&B、ネオソウルで頻繁に使われる。浮遊感がありながらも、落ち着いた響きが特徴です。\nTry: m9コードの代わりに使ってみましょう。特にエレピで弾くと、一気に今風のチルなサウンドになります。\n理論: m7に9度と11度を加えたコードで、特に11度の音がサウンドの鍵。ドリアンスケール上でよく使われます。"),
            commentEn: toMarkdown("Vibe: A more melancholic and complex sound than m9, like a soundtrack for a rainy day.\nUsage: Frequently used in modern R&B and Neo-Soul. It has a floating, yet calm, character.\nTry: Use it in place of an m9 chord. Especially when played on an electric piano, it creates a modern, chill sound.\nTheory: Adds the 9th and 11th to an m7 chord (R-b3-5-b7-9-11). The 11th is the key to its sound. Often used over the Dorian scale.")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "🌃 おしゃれ・都会的",
            categoryEn: "Stylish & Urban",
            quality: "m6",
            commentJa: toMarkdown("雰囲気: マイナーの切なさに、どこか懐かしい響きが加わったミステリアスなサウンド。古い映画のワンシーンのようです。\n特徴: 50-60年代のジャズやボサノヴァ、タンゴで頻繁に使われる。哀愁と気品が同居しています。\nTry: マイナーキーのトニックコード(Im)をこれ(Im6)に変えてみましょう。曲のエンディングで使うと、余韻を美しく表現できます。\n理論: 構成音はR-b3-5-6。実はAm7b5とCm6のように、m7b5コードの転回形と同じ構成音になるという面白い性質を持ちます。"),
            commentEn: toMarkdown("Vibe: A mysterious sound adding a nostalgic touch to minor sadness, reminiscent of a scene from an old movie.\nUsage: Frequently heard in 50-60s jazz, bossa nova, and tango, embodying both melancholy and elegance.\nTry: Change the tonic Im chord in a minor key to Im6. Using it at the end of a song beautifully expresses a lingering feeling.\nTheory: Composed of R-b3-5-6. It has the interesting property of sharing the same notes as an m7b5 chord inversion (e.g., Cm6 and Am7b5).")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "🌃 おしゃれ・都会的",
            categoryEn: "Stylish & Urban",
            quality: "m7b5",
            commentJa: toMarkdown("雰囲気: 不安定さと哀愁が同居した、ジャズへの入り口となるコード。物語が核心に迫るような、少し不穏な空気感。\n特徴: マイナーキーの楽曲に深みを与える重要な役割。通称ハーフディミニッシュと呼ばれます。\nTry: マイナーキーで定番のIIm7b5→V7→Imという進行を使ってみましょう。一気にジャズらしい、説得力のある流れが作れます。\n理論: 構成音はR-b3-b5-b7。ロクリアンスケール上で発生するコードです。"),
            commentEn: toMarkdown("Vibe: The gateway chord to jazz, combining instability and melancholy. Creates a slightly unsettling air, as if a story is reaching its core.\nUsage: Plays a crucial role in adding depth to minor key songs. Commonly known as the half-diminished chord.\nTry: Use the classic IIm7b5→V7→Im progression in a minor key. It will instantly create a convincing, jazzy flow.\nTheory: Composed of R-b3-b5-b7. This chord is generated from the Locrian scale.")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "🌃 おしゃれ・都会的",
            categoryEn: "Stylish & Urban",
            quality: "mM7",
            commentJa: toMarkdown("雰囲気: マイナーの暗さとmaj7の明るさがぶつかり合う、スパイ映画のような緊張感とドラマ性。\n特徴: 007のテーマ曲で有名。ジャズやプログレッシブロックで、ミステリアスな雰囲気を出すのに使われます。\nTry: マイナーキーのトニック(Im)で使ってみましょう。聴き手をハッとさせる、非常に印象的な響きになります。\n理論: 構成音はR-b3-5-7。ハーモニックマイナーやメロディックマイナーのI度で発生する特殊なコードです。"),
            commentEn: toMarkdown("Vibe: A dramatic, spy-movie-like sound where minor darkness clashes with major-seventh brightness.\nUsage: Famous from the James Bond theme. Used in jazz and prog-rock to create a mysterious atmosphere.\nTry: Use it as the tonic chord (Im) in a minor key. It will create a startling and highly memorable sound.\nTheory: Composed of R-b3-5-7. A special chord that occurs on the tonic of the Harmonic and Melodic Minor scales.")
        ),
        
        // Pro - ⚡️ 緊張感・スパイス (Tension & Spice)
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "7sus4",
            commentJa: toMarkdown("雰囲気: sus4の浮遊感と7thの不安定さを併せ持つ、解決寸前のじらされたような期待感。\n特徴: ファンクやフュージョンで、ドミナントコードの緊張感をさらに高めるために使われるプロの技です。\nTry: V7の前に置き、1〜2拍タメを作ってからV7に解決してみましょう。リスナーのカタルシスを最大限に引き出せます。\n理論: 構成音はR-4-5-b7。ドミナントモーションをより強力にする飛び道具。ミクソリディアンスケールの3度を4度に変えた形です。"),
            commentEn: toMarkdown("Vibe: Combines the floating feel of sus4 and the instability of a 7th, creating a teasing sense of anticipation just before resolution.\nUsage: A pro technique used in funk and fusion to further increase the tension of a dominant chord.\nTry: Place it before a V7 for a beat or two to build suspense, then resolve to V7 to maximize the listener's catharsis.\nTheory: Composed of R-4-5-b7. A powerful tool to strengthen dominant motion. It's a Mixolydian scale with the 3rd replaced by the 4th.")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "aug",
            commentJa: toMarkdown("雰囲気: 明るいのにどこか不穏で、次のコードに強制的に進みたくなる強い推進力を持つサウンド。\n特徴: 楽曲に意外性やフック（引っかかり）を作りたい時に使われる。少しサイケデリックな雰囲気も持ちます。\nTry: I→Iaug→IVのようなクリシェで使ってみましょう。半音で動く不思議なラインが生まれ、曲が単調になりません。\n理論: 構成音はR-3-#5。5度の音を半音上げた異質な響き。ホールトーンスケールと相性が良いです。"),
            commentEn: toMarkdown("Vibe: A strange, propulsive chord that sounds bright yet unsettling, forcing movement to the next chord.\nUsage: Used to create surprise or a \"hook\" in a song. It also has a slightly psychedelic feel.\nTry: Use it in a cliché like I→Iaug→IV. The strange chromatic line will prevent the song from becoming monotonous.\nTheory: Composed of R-3-#5. The altered 5th gives it a unique sound. It pairs well with the Whole Tone scale.")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "dim7",
            commentJa: toMarkdown("雰囲気: dimをさらに不安定にした、究極の緊張感を持つコード。どの音もルートになれる不思議な性質を持ちます。\n特徴: ジャズやクラシックで、半音でコードを繋ぐ時などに使うと、非常にスムーズで劇的な展開が作れます。\nTry: CとDmの間を繋ぐC#dim7として使ってみましょう。滑らかなベースラインと緊張感が生まれます。\n理論: 構成音はR-b3-b5-bb7。全ての音が短3度間隔で並ぶ対称的なコード。ディミニッシュスケール(WH)上で使います。"),
            commentEn: toMarkdown("Vibe: The ultimate tension chord, even more unstable than dim, with the unique property that any note can be the root.\nUsage: Used in jazz and classical music for chromatic transitions, creating smooth and dramatic progressions.\nTry: Use it as C#dim7 to connect C and Dm. It creates a smooth bassline and adds tension.\nTheory: Composed of R-b3-b5-bb7. A symmetrical chord where all notes are a minor third apart. Used with the Diminished (WH) scale.")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "7(#9)",
            commentJa: toMarkdown("雰囲気: 明るさ(3度)と暗さ(#9=b3)が激しくぶつかり合う、攻撃的でブルージーなサウンド。危険な香りがします。\n特徴: 「ジミヘンコード」として有名。ロック、ファンク、ブルースで、サウンドを荒々しくしたい時に使われます。\nTry: ドミナントコード(V7)をこれに変えてみましょう。ギターで弾けば、一瞬でサウンドにロックな歪みとエネルギーが加わります。\n理論: 構成音はR-3-5-b7-#9。ドミナントコードにオルタードテンション(#9)を加えたもの。オルタードスケールが使えます。"),
            commentEn: toMarkdown("Vibe: An aggressive, bluesy sound where brightness (3rd) and darkness (#9=b3) collide. It has a dangerous edge.\nUsage: Famous as the \"Hendrix Chord.\" Used in rock, funk, and blues to make the sound raw and edgy.\nTry: Substitute your dominant V7 chord with this. On guitar, it instantly adds rock distortion and energy.\nTheory: Composed of R-3-5-b7-#9. An altered dominant chord. The Altered or HW Diminished scales can be used over it.")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "7(b9)",
            commentJa: toMarkdown("雰囲気: 7thコードに、よりダークで緊張感の強い響きを加える。特にマイナーキーへの解決前は非常にドラマチック。\n特徴: ジャズのドミナントコードで頻繁に使われる定番の緊張。ラテン音楽やフュージョンでも多用されます。\nTry: マイナーキーのV7で使ってみましょう。トニックマイナーへの解決感がより一層、感動的になります。\n理論: 構成音はR-3-5-b7-b9。ハーモニックマイナーやディミニッシュスケール(HW)由来の緊張感です。"),
            commentEn: toMarkdown("Vibe: Adds a darker, more intense tension to a 7th chord. Sounds extremely dramatic, especially before resolving to a minor key.\nUsage: A staple tension in jazz dominant chords, also common in Latin music and fusion.\nTry: Use it as the V7 in a minor key. The resolution to the tonic minor will feel even more emotional and satisfying.\nTheory: Composed of R-3-5-b7-b9. Its tension is derived from the Harmonic Minor or the HW Diminished scales.")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "7(#5)",
            commentJa: toMarkdown("雰囲気: augコードに7thの響きを加えた、より不安定でジャジーなサウンド。フワフワした不思議な浮遊感があります。\n特徴: ジャズやフュージョンで、ホールトーンスケールとセットで使われることが多い。場面転換などで効果的です。\nTry: V7をこれに変えて、メロディでホールトーンスケールを弾いてみましょう。一気に夢の中のような世界観になります。\n理論: 構成音はR-3-#5-b7。7augとも表記される。ホールトーンスケールから作られるドミナントコードです。"),
            commentEn: toMarkdown("Vibe: A more unstable and jazzy version of an augmented chord, with a strange, floating feel.\nUsage: Often used in jazz and fusion in conjunction with the whole-tone scale. Effective for scene transitions.\nTry: Change a V7 to this and play a whole-tone scale melody over it. It will instantly create a dreamlike world.\nTheory: Composed of R-3-#5-b7, also written as 7aug. It's the dominant chord built from the Whole Tone scale.")
        ),
        QualityMasterInfo(
            tier: "Pro",
            categoryJa: "⚡️ 緊張感・スパイス",
            categoryEn: "Tension & Spice",
            quality: "7(b13)",
            commentJa: toMarkdown("雰囲気: ドミナントコードに物憂げな響き(b13)を加えた、非常に複雑でムーディーなサウンド。\n特徴: ジャズバラードなどで、切ないメロディに寄り添うように使われる。洗練された大人の緊張感です。\nTry: V7の代わりに使い、メロディでb13の音を強調してみましょう。サウンドに深い哀愁が生まれます。\n理論: 構成音はR-3-5-b7-b13。メロディックマイナースケール由来の、哀愁漂う緊張感を持ちます。"),
            commentEn: toMarkdown("Vibe: A complex, moody sound that adds a melancholic note (b13) to a dominant chord.\nUsage: Used in jazz ballads to accompany wistful melodies. A sophisticated, adult tension.\nTry: Use it instead of a V7 and emphasize the b13 note in your melody. It will create a deep sense of melancholy.\nTheory: Composed of R-3-5-b7-b13. It carries a wistful tension derived from the Melodic Minor scale.")
        )
    ]
    
    // Helper functions
    static func getQualityInfo(for quality: String) -> QualityMasterInfo? {
        return allQualities.first { $0.quality == quality }
    }
    
    static func isProQuality(_ quality: String) -> Bool {
        return getQualityInfo(for: quality)?.tier == "Pro"
    }
    
    static func getQualityComment(for quality: String, locale: String) -> String {
        guard let qualityInfo = getQualityInfo(for: quality) else { return "" }
        return locale == "ja" ? qualityInfo.commentJa : qualityInfo.commentEn
    }
    
    static func getQualitiesByCategory(tier: String) -> [String: [QualityMasterInfo]] {
        let filtered = allQualities.filter { $0.tier == tier }
        var grouped: [String: [QualityMasterInfo]] = [:]
        
        for quality in filtered {
            if grouped[quality.categoryJa] == nil {
                grouped[quality.categoryJa] = []
            }
            grouped[quality.categoryJa]?.append(quality)
        }
        
        return grouped
    }
    
    static func getEnglishCategoryName(_ japaneseCategory: String) -> String {
        let mapping: [String: String] = [
            "基本": "Basics",
            "基本の飾り付け": "Essential Colors",
            "✨ キラキラ・浮遊感": "Sparkling & Floating",
            "🌃 おしゃれ・都会的": "Stylish & Urban",
            "⚡️ 緊張感・スパイス": "Tension & Spice"
        ]
        return mapping[japaneseCategory] ?? japaneseCategory
    }
}