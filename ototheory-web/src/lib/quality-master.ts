// Quality Master Data - Single Source of Truth for chord qualities
// Generated from /Users/nh/App/OtoTheory/docs/content/Quality Master.csv

export type QualityInfo = {
  tier: 'Free' | 'Pro';
  categoryJa: string;
  categoryEn: string;
  quality: string;
  commentJa: string;
  commentEn: string;
};

export const QUALITY_MASTER: QualityInfo[] = [
  // Free - 基本 (Basics)
  {
    tier: 'Free',
    categoryJa: '基本',
    categoryEn: 'Basics',
    quality: 'Major',
    commentJa: 'Vibe: 明るくポジティブ。物語の始まりやサビにふさわしい、安定感と幸福感に満ちた響きです。\nUsage: J-POP、ロック、フォーク、童謡など、あらゆる音楽の基本となるコード。楽曲の骨格を形成します。\nTry: 曲の最も盛り上がる部分や、リスナーに安心感を与えたい場面で使ってみよう。ここぞという時の主役になります。\nTheory: 構成音はR-3-5。メジャースケール（イオニアン）上で完璧に調和し、ダイアトニックのI度、IV度、V度で登場します。',
    commentEn: 'Vibe: Bright and positive. A sound full of stability and happiness, perfect for the start of a story or a chorus.\nUsage: The fundamental chord in all music, from J-Pop and rock to folk. It forms the skeleton of a song.\nTry: Use it in the most climactic parts of a song or when you want to give the listener a sense of security.\nTheory: Composed of R-3-5. It harmonizes perfectly with the Major (Ionian) scale and appears as the I, IV, and V chords.'
  },
  {
    tier: 'Free',
    categoryJa: '基本',
    categoryEn: 'Basics',
    quality: 'm (minor)',
    commentJa: 'Vibe: 少し切なく、落ち着いた雰囲気。喜びだけでなく、哀愁や内省的な感情を表現するのに最適です。\nUsage: バラード、ロック、R&Bなど、深みのある楽曲には欠かせない存在。メジャーとの対比が曲にドラマを生みます。\nTry: Aメロで静かに始めたい時や、サビ後のクールダウン、感情的な歌詞に乗せて使ってみましょう。\nTheory: 構成音はR-b3-5。b3(短3度)の音が特徴です。ナチュラルマイナースケール（エオリアン）の基本コードになります。',
    commentEn: 'Vibe: Slightly sad and calm. Perfect for expressing not just joy, but also melancholy and introspection.\nUsage: Essential for deep songs like ballads, rock, and R&B. Its contrast with major chords creates drama.\nTry: Use it to start a verse quietly, to cool down after a chorus, or to accompany emotional lyrics.\nTheory: Composed of R-b3-5. The b3rd is its key feature. It\'s the basic chord of the Natural Minor (Aeolian) scale.'
  },
  {
    tier: 'Free',
    categoryJa: '基本',
    categoryEn: 'Basics',
    quality: '7',
    commentJa: 'Vibe: 少し不安定で、次へ進みたいという推進力を持つサウンド。ブルージーでおしゃれな緊張感が魅力です。\nUsage: ブルース、ジャズ、ファンク、ロックンロールの魂。楽曲にドライブ感と解決への期待感を与えます。\nTry: サビの直前（V7）に置いて、解決感を劇的に高めてみましょう。ブルース進行の主役としても活躍します。\nTheory: 構成音はR-3-5-b7。ミクソリディアンスケール上で自然に発生。V7→Iという最強の進行（ドミナントモーション）を作ります。',
    commentEn: 'Vibe: A slightly unstable sound with a drive to move forward. Its bluesy, stylish tension is captivating.\nUsage: The soul of blues, jazz, and funk. It gives a song drive and anticipation for resolution.\nTry: Place it right before the chorus (as a V7) to dramatically enhance the feeling of resolution.\nTheory: Composed of R-3-5-b7. It naturally occurs on the Mixolydian scale and creates the powerful V7→I progression (dominant motion).'
  },
  {
    tier: 'Free',
    categoryJa: '基本',
    categoryEn: 'Basics',
    quality: 'maj7',
    commentJa: 'Vibe: 明るさの中に洗練された都会的な響きが同居。爽やかな風が吹くような、開放的でおしゃれなサウンドです。\nUsage: J-POP、R&B、ジャズ、ボサノヴァの定番。楽曲の始まりや終わりに使うと、余韻のある雰囲気を演出できます。\nTry: 明るい曲のトニックコード(I)をこれ(Imaj7)に変えてみましょう。一瞬でサウンドが洗練され、シティポップ模が生まれます。\nTheory: 構成音はR-3-5-7。長7度の音が特徴です。メジャースケール（イオニアン）やリディアンスケールと相性抜群です。',
    commentEn: 'Vibe: A sophisticated, urban sound within a bright context. Open and stylish, like a fresh breeze.\nUsage: A staple in J-Pop, R&B, and jazz. Using it at the beginning or end of a song creates a lingering atmosphere.\nTry: Change the tonic chord (I) of a bright song to Imaj7. The sound will instantly become more refined.\nTheory: Composed of R-3-5-7. The major 7th is its key feature. It pairs perfectly with the Major (Ionian) and Lydian scales.'
  },
  {
    tier: 'Free',
    categoryJa: '基本',
    categoryEn: 'Basics',
    quality: 'm7',
    commentJa: 'Vibe: マイナーの切なさに、ジャズやソウルの香りを加えた、少し大人びた響き。クールで落ち着いています。\nUsage: ジャズのスタンダードやR&B、ファンク、AORで頻繁に使われる、マイナーキーの基本的な和音です。\nTry: マイナーキーの曲で、トニックコード(Im)をこれ(Im7)に変えてみましょう。ただ暗いだけでない、知的な雰囲気に変わります。\nTheory: 構成音はR-b3-5-b7。ナチュラルマイナー（エオリアン）やドリアンスケール上で発生します。',
    commentEn: 'Vibe: Adds a touch of jazz and soul to minor sadness, creating a mature, cool, and calm sound.\nUsage: The fundamental minor chord in jazz standards, R&B, and funk.\nTry: In a minor key song, change the tonic chord from Im to Im7. It will shift the mood from simply dark to something more intelligent.\nTheory: Composed of R-b3-5-b7. It occurs on the Natural Minor (Aeolian) and Dorian scales.'
  },

  // Free - 基本の飾り付け (Essential Colors)
  {
    tier: 'Free',
    categoryJa: '基本の飾り付け',
    categoryEn: 'Essential Colors',
    quality: 'sus4',
    commentJa: 'Vibe: メジャーでもマイナーでもない、解決を焦らす浮遊感。リスナーの期待感をグッと高める効果があります。\nUsage: ポップス、ロック、ファンクなどジャンルを問わず使われる。特にAメロからBメロへの繋ぎなどで効果的です。\nTry: V7の前に置き(V7sus4)、より劇的な解決感を演出してみましょう。アコギのストロークで使うと響きが豊かになります。\nTheory: 3度の音を4度にした(R-4-5)コード。susはSuspended(吊るされた)の略で、3度への解決を待ち望んでいます。',
    commentEn: 'Vibe: A floating feel, neither major nor minor, that delays resolution and builds anticipation in the listener.\nUsage: Used across all genres. Especially effective for transitions, like from a verse to a bridge.\nTry: Place it before a V7 (as V7sus4) to create a more dramatic resolution. It sounds rich in acoustic strumming.\nTheory: Replaces the 3rd with a 4th (R-4-5). \"Sus\" is short for Suspended, as it longs to resolve to the 3rd.'
  },
  {
    tier: 'Free',
    categoryJa: '基本の飾り付け',
    categoryEn: 'Essential Colors',
    quality: 'sus2',
    commentJa: 'Vibe: sus4よりも、さらに明るく爽やかで、キラキラした浮遊感。若々しさや純粋さを感じさせます。\nUsage: J-POPやロックバラードのイントロやアルペジオで多用される。澄んだ響きがアコースティックギターによく合います。\nTry: メジャーコードの代わりに一瞬だけ使ってみましょう。サウンドに爽やかな風が吹き込み、単調さがなくなります。\nTheory: 3度の音を2度にした(R-2-5)コード。ポップスではadd9に近い響きの飾り（embellishment）として使われます。',
    commentEn: 'Vibe: Brighter and fresher than sus4, with a sparkling floatiness that evokes youthfulness and purity.\nUsage: Often used in intros and arpeggios of J-Pop and rock ballads. Its clear sound suits acoustic guitars.\nTry: Briefly substitute it for a major chord. It will add a fresh breeze to your sound and break up monotony.\nTheory: Replaces the 3rd with a 2nd (R-2-5). In pop, it\'s often used as an embellishment with a sound similar to add9.'
  },
  {
    tier: 'Free',
    categoryJa: '基本の飾り付け',
    categoryEn: 'Essential Colors',
    quality: 'add9',
    commentJa: 'Vibe: 通常のコードに、透明感や希望の光を一筋加える、感動的な響き。サウンドに広がりと彩りを与えます。\nUsage: 現代のポップス、ロック、バラードではなくてはならない存在。特にピアノやギターのアルペジオで美しい響きを生みます。\nTry: サビの最後のコードをこれに変えてみましょう。曲のエンディングに、感動的な余韻と広がりが生まれます。\nTheory: メジャー(R-3-5)に9度の音を追加したコード。9度は2度と同じ音ですが、3度と共存しているのがポイントです。',
    commentEn: 'Vibe: An emotional sound that adds a layer of transparency and hope to a basic chord, creating spaciousness and color.\nUsage: An indispensable chord in modern pop, rock, and ballads. It sounds beautiful in piano or guitar arpeggios.\nTry: Change the last chord of the chorus to this one. It will create a moving, expansive finish to your song.\nTheory: Adds a 9th note to a major triad (R-3-5-9). The 9th is the same note as the 2nd, but the key is its coexistence with the 3rd.'
  },
  {
    tier: 'Free',
    categoryJa: '基本の飾り付け',
    categoryEn: 'Essential Colors',
    quality: 'dim',
    commentJa: 'Vibe: 不気味で、聴き手を不安にさせるスリリングな響き。物語にサスペンスやミステリーの要素を加えます。\nUsage: ジャズやクラシックで、コードとコードを滑らかに繋ぐ「経過コード」として使われるのが定石です。\nTry: Bdimのような経過コードをCとAmの間に挟んでみましょう。ベースラインが滑らかになり、プロっぽい響きになります。\nTheory: 構成音はR-b3-b5。不安定なトライトーン(b5)が強い緊張感を生み出します。',
    commentEn: 'Vibe: A spooky, thrilling sound that creates unease, adding an element of suspense or mystery to a story.\nUsage: A classic \"passing chord\" in jazz and classical music used to smoothly connect other chords.\nTry: Insert a passing chord like Bdim between C and Am. The bassline will become smoother and sound more professional.\nTheory: Composed of R-b3-b5. Its unstable tritone interval (b5) generates strong tension.'
  },

  // Pro - ✨ キラキラ・浮遊感 (Sparkle & Float)
  {
    tier: 'Pro',
    categoryJa: '✨ キラキラ・浮遊感',
    categoryEn: 'Sparkle & Float',
    quality: 'M9 (maj9)',
    commentJa: 'Vibe: maj7をさらに進化させた、優雅で甘美、夢見心地な響き。ラグジュアリーな空間を演出します。\nUsage: R&B、ネオソウル、フュージョンの王道サウンド。これ一つで曲のおしゃれ度が格段にアップします。\nTry: 静かなバラードのトニックコード(Imaj7)をこれ(Imaj9)にしてみましょう。サウンドに深みと極上の甘さが加わります。\nTheory: maj7(R-3-5-7)に9度の音を追加したコード。リディアンスケールとの相性は最高です。',
    commentEn: 'Vibe: An evolution of maj7, creating an elegant, sweet, and dreamy atmosphere. Evokes a sense of luxury.\nUsage: The quintessential sound of R&B, Neo-Soul, and Fusion. It instantly elevates the chicness of a song.\nTry: In a quiet ballad, change the tonic Imaj7 to Imaj9. It will add depth and a sublime sweetness to the sound.\nTheory: Adds a 9th to a maj7 chord (R-3-5-7-9). It has a fantastic compatibility with the Lydian scale.'
  },
  {
    tier: 'Pro',
    categoryJa: '✨ キラキラ・浮遊感',
    categoryEn: 'Sparkle & Float',
    quality: '6',
    commentJa: 'Vibe: maj7よりも少しだけ素朴で、温かくレトロな雰囲気。50-60年代のような、懐かしい響きです。\nUsage: 古き良き時代のジャズやポップス、ハワイアン音楽で多用される。サウンドを柔らかく、穏やかにします。\nTry: maj7の代わりに使ってみましょう。特に曲のエンディングで使うと、ハッピーエンドの映画のような、温かい余韻が残ります。\nTheory: メジャー(R-3-5)に長6度の音を加えたコード。トニックコード(I)のバリエーションとして使えます。',
    commentEn: 'Vibe: A bit simpler and warmer than maj7, with a nostalgic, retro vibe like the 50s-60s.\nUsage: Frequently used in old-time jazz, pop, and Hawaiian music. It softens the sound and makes it gentle.\nTry: Use it instead of maj7. Especially at the end of a song, it leaves a warm afterglow, like a happy-ending movie.\nTheory: Adds a major 6th to a major triad (R-3-5-6). It can be used as a variation of the tonic chord (I).'
  },
  {
    tier: 'Pro',
    categoryJa: '✨ キラキラ・浮遊感',
    categoryEn: 'Sparkle & Float',
    quality: '6/9',
    commentJa: 'Vibe: 6コードの温かさとadd9のキラキラ感を併せ持つ、非常に豊かでゴージャスな響き。\nUsage: ジャズピアノのエンディングなどで聴ける、幸福感に満ちたサウンド。フュージョンやAORでも使われます。\nTry: 曲の最後の最後、全ての音が消える直前のキメの和音として使ってみましょう。最高の多幸感を演出できます。\nTheory: R-3-5に6度と9度の両方を加えた贅沢なコード。構成音が多く、豊かな倍音を生み出します。',
    commentEn: 'Vibe: Combines the warmth of a 6 chord with the sparkle of an add9, creating a rich, gorgeous, and happy sound.\nUsage: A blissful sound often heard at the end of jazz piano pieces, also used in Fusion and AOR.\nTry: Use it as the final, ultimate chord of a song right before everything fades to silence for maximum euphoria.\nTheory: A luxurious chord adding both the 6th and 9th to a triad (R-3-5-6-9). Its many notes create rich overtones.'
  },
  {
    tier: 'Pro',
    categoryJa: '✨ キラキラ・浮遊感',
    categoryEn: 'Sparkle & Float',
    quality: 'add#11',
    commentJa: 'Vibe: 現代的でドリーミーな、まさに「浮遊感」のあるサウンド。宇宙的な広がりと神秘的な美しさを感じさせます。\nUsage: ニューエイジ、アンビエント、現代ジャズで使われる、未来感のあるサウンド。映画音楽やゲーム音楽でも効果的です。\nTry: 静かな曲のエンディングや、間奏のアクセントとして使ってみましょう。聴き手を別世界に連れて行く効果があります。\nTheory: R-3-5に#11度（4度の半音上）を加えたコード。リディアンスケールとの相性が抜群です。',
    commentEn: 'Vibe: A modern, dreamy sound that truly gives a "floating" feel. Evokes cosmic expansiveness and mystical beauty.\nUsage: A futuristic sound used in New Age, Ambient, and modern jazz. Also effective in film and game music.\nTry: Use it at the end of quiet songs or as accent chords in interludes. It has the effect of transporting listeners to another world.\nTheory: Adds a #11th (a semitone above the 4th) to R-3-5. It has an excellent compatibility with the Lydian scale.'
  },

  // Pro - 🌃 おしゃれ・都会的 (Stylish & Urban)
  {
    tier: 'Pro',
    categoryJa: '🌃 おしゃれ・都会的',
    categoryEn: 'Stylish & Urban',
    quality: 'm9',
    commentJa: 'Vibe: m7をさらにスムーズで洗練させた響き。大人の余裕と知的な魅力を感じさせます。\nUsage: ジャズ、フュージョン、AORの定番。特に都市的な雰囲気を演出したい時に威力を発揮します。\nTry: m7の代わりに使ってみましょう。サウンドがより洗練され、大人っぽい雰囲気になります。\nTheory: m7(R-b3-5-b7)に9度の音を追加したコード。ドリアンスケールとの相性が抜群です。',
    commentEn: 'Vibe: An even smoother and more refined sound than m7. Evokes adult sophistication and intellectual charm.\nUsage: A staple in jazz, fusion, and AOR. Particularly effective when creating an urban atmosphere.\nTry: Use it instead of m7. The sound will become more refined and mature.\nTheory: Adds a 9th to an m7 chord (R-b3-5-b7-9). It has an excellent compatibility with the Dorian scale.'
  },
  {
    tier: 'Pro',
    categoryJa: '🌃 おしゃれ・都会的',
    categoryEn: 'Stylish & Urban',
    quality: 'm11',
    commentJa: 'Vibe: Lo-fi Hip HopやR&Bで定番の、少しアンニュイなサウンド。都会の夜を思わせる大人の雰囲気です。\nUsage: 都市的な音楽、特にLo-fi、R&B、ネオソウルで多用される。落ち着いた夜の雰囲気を演出できます。\nTry: 静かな夜の曲や、大人の恋愛をテーマにした楽曲で使ってみましょう。深い感情を表現できます。\nTheory: m7に11度を加えたコード。エオリアンスケールとの相性が良く、複雑な感情を表現します。',
    commentEn: 'Vibe: A standard sound in Lo-fi Hip Hop and R&B, with a slightly melancholic vibe. Evokes the atmosphere of urban nights.\nUsage: Frequently used in urban music, especially Lo-fi, R&B, and Neo-Soul. Can create a calm night atmosphere.\nTry: Use it in quiet night songs or songs about adult romance. It can express deep emotions.\nTheory: Adds an 11th to an m7 chord. It pairs well with the Aeolian scale and expresses complex emotions.'
  },
  {
    tier: 'Pro',
    categoryJa: '🌃 おしゃれ・都会的',
    categoryEn: 'Stylish & Urban',
    quality: 'm7b5',
    commentJa: 'Vibe: ジャズの王道コード。少し不安定で、解決への期待感が強い、知的で洗練された響きです。\nUsage: ジャズスタンダードのIIm7b5として頻繁に使われる。特にマイナーキーの楽曲で重要な役割を果たします。\nTry: Dm7b5-G7-Cmのような進行で使ってみましょう。クラシックなジャズの雰囲気が演出できます。\nTheory: R-b3-b5-b7の構成音。ロクリアンスケール上で発生し、強い解決感を生み出します。',
    commentEn: 'Vibe: A classic jazz chord. Slightly unstable with a strong anticipation for resolution, creating an intellectual and refined sound.\nUsage: Frequently used as IIm7b5 in jazz standards. Plays an important role especially in minor key songs.\nTry: Use it in progressions like Dm7b5-G7-Cm to create a classic jazz atmosphere.\nTheory: Composed of R-b3-b5-b7. It occurs on the Locrian scale and creates a strong sense of resolution.'
  },
  {
    tier: 'Pro',
    categoryJa: '🌃 おしゃれ・都会的',
    categoryEn: 'Stylish & Urban',
    quality: 'mM7',
    commentJa: 'Vibe: マイナーの暗さとメジャー7の明るさが混在した、複雑で魅力的な響き。矛盾が生み出す美しさがあります。\nUsage: ジャズ、フュージョン、映画音楽で使われる、大人のサウンド。特に神秘的な雰囲気を演出したい時に効果的です。\nTry: 静かなバラードや、少し暗めの楽曲で使ってみましょう。独特の魅力が生まれます。\nTheory: R-b3-5-7の構成音。ハーモニックマイナースケールの特徴的なコードです。',
    commentEn: 'Vibe: A complex and attractive sound that mixes the darkness of minor with the brightness of major 7. The beauty of contradiction.\nUsage: An adult sound used in jazz, fusion, and film music. Particularly effective when creating a mysterious atmosphere.\nTry: Use it in quiet ballads or slightly dark songs. It creates a unique charm.\nTheory: Composed of R-b3-5-7. It\'s a characteristic chord of the Harmonic Minor scale.'
  },
  {
    tier: 'Pro',
    categoryJa: '🌃 おしゃれ・都会的',
    categoryEn: 'Stylish & Urban',
    quality: 'm6',
    commentJa: 'Vibe: m7よりも少し明るく、懐かしさを感じさせる響き。レトロな魅力と現代的な洗練さを併せ持ちます。\nUsage: ジャズ、ボサノヴァ、アンビエントで使われる。特に落ち着いた雰囲気を演出したい時に効果的です。\nTry: 静かな夜の曲や、大人の雰囲気の楽曲で使ってみましょう。深い余韻が生まれます。\nTheory: R-b3-5-6の構成音。ドリアンスケールとの相性が良く、安定感と動きのバランスが取れています。',
    commentEn: 'Vibe: A slightly brighter sound than m7, evoking a sense of nostalgia. Combines retro charm with modern sophistication.\nUsage: Used in jazz, bossa nova, and ambient music. Particularly effective when creating a calm atmosphere.\nTry: Use it in quiet night songs or songs with an adult atmosphere. It creates a deep afterglow.\nTheory: Composed of R-b3-5-6. It pairs well with the Dorian scale and balances stability with movement.'
  },

  // Pro - ⚡️ 緊張感・スパイス (Tension & Spice)
  {
    tier: 'Pro',
    categoryJa: '⚡️ 緊張感・スパイス',
    categoryEn: 'Tension & Spice',
    quality: '7sus4',
    commentJa: 'Vibe: V7の前に置くことで、解決感を劇的に高めるプロの技。緊張感と解決感のコントラストが美しいです。\nUsage: ジャズ、ファンク、ロックで使われる高度なテクニック。特にドラマチックな効果を演出したい時に威力を発揮します。\nTry: C-F-G7sus4-G7のような進行で使ってみましょう。解決感がより劇的になります。\nTheory: V7コードの3度を4度に置き換えたコード。sus4の浮遊感が解決への期待感を高めます。',
    commentEn: 'Vibe: A pro technique that dramatically enhances the feeling of resolution when placed before a V7 chord. The contrast between tension and resolution is beautiful.\nUsage: An advanced technique used in jazz, funk, and rock. Particularly effective when creating dramatic effects.\nTry: Use it in progressions like C-F-G7sus4-G7. The resolution will become more dramatic.\nTheory: Replaces the 3rd of a V7 chord with a 4th. The floating feel of sus4 enhances anticipation for resolution.'
  },
  {
    tier: 'Pro',
    categoryJa: '⚡️ 緊張感・スパイス',
    categoryEn: 'Tension & Spice',
    quality: 'aug',
    commentJa: 'Vibe: 不安定で、次のコードへ進む推進力が強い。緊張感と動きのエネルギーを感じさせます。\nUsage: ジャズ、クラシック、映画音楽で使われる。特に緊張感を高めたい時に効果的です。\nTry: C-Caug-Fのような進行で使ってみましょう。ベースラインが滑らかになり、プロっぽい響きになります。\nTheory: R-3-#5の構成音。増5度の音が強い緊張感を生み出し、解決への推進力を与えます。',
    commentEn: 'Vibe: An unstable sound with a strong drive to move to the next chord. Evokes tension and dynamic energy.\nUsage: Used in jazz, classical, and film music. Particularly effective when increasing tension.\nTry: Use it in progressions like C-Caug-F. The bassline will become smoother and sound more professional.\nTheory: Composed of R-3-#5. The augmented 5th creates strong tension and provides drive toward resolution.'
  },
  {
    tier: 'Pro',
    categoryJa: '⚡️ 緊張感・スパイス',
    categoryEn: 'Tension & Spice',
    quality: 'dim7',
    commentJa: 'Vibe: 経過コードとして非常に便利。緊張感を一気に高める、プロのテクニックです。\nUsage: ジャズ、クラシック、映画音楽で頻繁に使われる。コードとコードを滑らかに繋ぐのに最適です。\nTry: C-Bdim7-Cmのような進行で使ってみましょう。ベースラインが滑らかになり、プロっぽい響きになります。\nTheory: R-b3-b5-bb7の構成音。減7度の音が強い緊張感を生み出し、解決への期待感を高めます。',
    commentEn: 'Vibe: Very useful as a passing chord to instantly increase tension. A professional technique.\nUsage: Frequently used in jazz, classical, and film music. Perfect for smoothly connecting chords.\nTry: Use it in progressions like C-Bdim7-Cm. The bassline will become smoother and sound more professional.\nTheory: Composed of R-b3-b5-bb7. The diminished 7th creates strong tension and enhances anticipation for resolution.'
  },
  {
    tier: 'Pro',
    categoryJa: '⚡️ 緊張感・スパイス',
    categoryEn: 'Tension & Spice',
    quality: '7(#9)',
    commentJa: 'Vibe: ブルージーでロックな緊張感。エネルギッシュで情熱的な響きが特徴です。\nUsage: ブルース、ロック、ファンクで多用される。特に激しい感情を表現したい時に効果的です。\nTry: C7(#9)-Fのような進行で使ってみましょう。ブルージーで情熱的な雰囲気が演出できます。\nTheory: R-3-5-b7-#9の構成音。#9度の音がブルージーな緊張感を生み出します。',
    commentEn: 'Vibe: A bluesy and rock-oriented tension. Characterized by energetic and passionate sound.\nUsage: Frequently used in blues, rock, and funk. Particularly effective when expressing intense emotions.\nTry: Use it in progressions like C7(#9)-F. It can create a bluesy and passionate atmosphere.\nTheory: Composed of R-3-5-b7-#9. The #9th creates a bluesy tension.'
  },
  {
    tier: 'Pro',
    categoryJa: '⚡️ 緊張感・スパイス',
    categoryEn: 'Tension & Spice',
    quality: '7(b9)',
    commentJa: 'Vibe: ジャズで多用される強い緊張感。知的で洗練された響きが特徴です。\nUsage: ジャズスタンダードで頻繁に使われる。特にマイナーキーの楽曲で重要な役割を果たします。\nTry: Dm7b5-G7(b9)-Cmのような進行で使ってみましょう。クラシックなジャズの雰囲気が演出できます。\nTheory: R-3-5-b7-b9の構成音。b9度の音が強い緊張感を生み出し、解決への期待感を高めます。',
    commentEn: 'Vibe: A strong tension frequently used in Jazz. Characterized by an intellectual and refined sound.\nUsage: Frequently used in jazz standards. Plays an important role especially in minor key songs.\nTry: Use it in progressions like Dm7b5-G7(b9)-Cm. It can create a classic jazz atmosphere.\nTheory: Composed of R-3-5-b7-b9. The b9th creates strong tension and enhances anticipation for resolution.'
  },
  {
    tier: 'Pro',
    categoryJa: '⚡️ 緊張感・スパイス',
    categoryEn: 'Tension & Spice',
    quality: '7(#5)',
    commentJa: 'Vibe: augと同じ。解決先を強く示す、エネルギッシュな響きです。\nUsage: ジャズ、ロック、ファンクで使われる。特に緊張感を高めたい時に効果的です。\nTry: C7(#5)-Fのような進行で使ってみましょう。解決感がより劇的になります。\nTheory: R-3-#5-b7の構成音。増5度の音が強い緊張感を生み出し、解決への推進力を与えます。',
    commentEn: 'Vibe: Same as augmented. Strongly indicates the point of resolution with an energetic sound.\nUsage: Used in jazz, rock, and funk. Particularly effective when increasing tension.\nTry: Use it in progressions like C7(#5)-F. The resolution will become more dramatic.\nTheory: Composed of R-3-#5-b7. The augmented 5th creates strong tension and provides drive toward resolution.'
  },
  {
    tier: 'Pro',
    categoryJa: '⚡️ 緊張感・スパイス',
    categoryEn: 'Tension & Spice',
    quality: '7(b13)',
    commentJa: 'Vibe: 複雑でムーディーな緊張感。深みのある感情を表現するのに最適です。\nUsage: ジャズ、フュージョン、映画音楽で使われる。特に複雑な感情を表現したい時に効果的です。\nTry: C7(b13)-Fのような進行で使ってみましょう。深い余韻が生まれます。\nTheory: R-3-5-b7-b13の構成音。b13度の音が複雑な緊張感を生み出します。',
    commentEn: 'Vibe: A complex and moody tension. Perfect for expressing deep emotions.\nUsage: Used in jazz, fusion, and film music. Particularly effective when expressing complex emotions.\nTry: Use it in progressions like C7(b13)-F. It creates a deep afterglow.\nTheory: Composed of R-3-5-b7-b13. The b13th creates a complex tension.'
  }
];

// Helper functions
export const getQualityInfo = (quality: string): QualityInfo | undefined => {
  return QUALITY_MASTER.find(q => q.quality === quality);
};

export const getProQualities = (): string[] => {
  return QUALITY_MASTER.filter(q => q.tier === 'Pro').map(q => q.quality);
};

export const getFreeQualities = (): string[] => {
  return QUALITY_MASTER.filter(q => q.tier === 'Free').map(q => q.quality);
};

export const isProQuality = (quality: string): boolean => {
  return QUALITY_MASTER.some(q => q.quality === quality && q.tier === 'Pro');
};

export const getQualityComment = (quality: string, locale: 'ja' | 'en'): string => {
  const info = getQualityInfo(quality);
  if (!info) return '';
  return locale === 'ja' ? info.commentJa : info.commentEn;
};

export const getQualitiesByCategory = (tier: 'Free' | 'Pro'): Record<string, QualityInfo[]> => {
  const filtered = QUALITY_MASTER.filter(q => q.tier === tier);
  const grouped: Record<string, QualityInfo[]> = {};
  
  filtered.forEach(q => {
    if (!grouped[q.categoryJa]) {
      grouped[q.categoryJa] = [];
    }
    grouped[q.categoryJa].push(q);
  });
  
  return grouped;
};
