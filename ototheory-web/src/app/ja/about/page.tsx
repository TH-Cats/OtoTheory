import Link from "next/link";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "OtoTheoryについて – 音楽理論を学びながら作曲",
  description: "ギタリスト向けの音楽理論ツール。コード、進行、キー、スケールを視覚的に理解し、理論書に苦労することなく作曲を学べます。",
};

export default function AboutPage() {
  return (
    <div className="ot-page ot-stack">
      {/* Headline */}
      <section className="ot-card text-white" style={{background: 'linear-gradient(90deg, var(--brand-primary), var(--brand-secondary))'}}>
        <h1 className="text-2xl font-semibold mb-2">OtoTheory — 理論に苦労せずに音楽を学ぶ</h1>
        <p className="leading-relaxed opacity-90">
          ギタリスト向けの音楽理論駆動型作曲ツール。<br />
          作曲しながら理論を学ぶ。<br />
          コード、進行、キー、スケールを視覚的に理解し、<br />
          難しい理論書に苦労することなく。
        </p>
      </section>

      {/* What is OtoTheory? */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-3">OtoTheoryとは？</h2>
        <p className="mb-3 leading-relaxed">
          OtoTheoryは、ギタリスト専用に設計された実用的な音楽理論ツールです。
        </p>
        <p className="font-semibold mb-2">こんな時に使ってください：</p>
        <ul className="list-disc pl-5 space-y-1 mb-3 opacity-90">
          <li>初めてのコード進行を学ぶ</li>
          <li>オリジナル楽曲を作曲する</li>
          <li>どのコードが一緒に使えるかを調べる</li>
          <li>メロディーやソロに使う音を発見する</li>
        </ul>
        <p className="leading-relaxed opacity-90">
          OtoTheoryは、インタラクティブなギターフレットボード、自動コード提案、
          スマートなカポ提案で即座に答えを提供します。
        </p>
        <p className="mt-3 font-medium">
          音楽理論の学位は不要です。<br />
          好奇心とギターを持参するだけです。
        </p>
      </section>

      {/* Key Features */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">主な機能</h2>
        <div className="space-y-4">
          <div>
            <h3 className="font-semibold mb-1">🎸 キーとスケールからコードを探す</h3>
            <p className="text-sm opacity-90 leading-relaxed">
              任意のキーとスケールを入力すると、一緒に使えるコードが即座に表示されます。
              オープンとバレー両方のフォームでギターフレットボードに視覚化されます。
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">🎵 コード進行を作る</h3>
            <p className="text-sm opacity-90 leading-relaxed">
              自動再生で進行を作成し、聴くことができます。
              20以上のプリセットパターン（無料）または50以上（Pro）から選択できます。
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">🎯 カポ提案</h3>
            <p className="text-sm opacity-90 leading-relaxed">
              難しいキーを簡単に演奏できるスマートなカポ提案を取得。
              「Shaped」（指で押さえる形）と「Sounding」（聞こえる音）の両方の表記を確認できます。
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">🎨 ビジュアルフレットボードオーバーレイ</h3>
            <p className="text-sm opacity-90 leading-relaxed">
              2層表示でスケール（アウトライン）とコード（塗りつぶし）を同時に表示。
              音名と度数表示を切り替えできます。
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">📤 エクスポート＆共有</h3>
            <p className="text-sm opacity-90 leading-relaxed">
              進行をPNG画像（無料）またはコードトラック、セクションマーカー、
              ガイドトーン付きMIDIファイル（Pro）としてエクスポート。
            </p>
          </div>
        </div>
      </section>

      {/* Who is it for? */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">こんな方におすすめ</h2>
        <div className="space-y-3">
          <div>
            <h3 className="font-semibold mb-1">📚 初心者</h3>
            <p className="text-sm opacity-90">
              理論書を暗記することなく、どのコードが一緒に使えるかを学べます。
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">✍️ 作詞作曲者</h3>
            <p className="text-sm opacity-90">
              進行を素早く実験し、新しいコードの組み合わせを発見。
              コードに合う音を視覚化して、より良いメロディーやソロを作成できます。
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">🎓 独学者</h3>
            <p className="text-sm opacity-90">
              インタラクティブな視覚化を通じて実用的な理論概念を理解できます。
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">🎸 すべてのレベルのギタリスト</h3>
            <p className="text-sm opacity-90">
              「次のコードは何？」「ソロにどの音を使うべき？」に即座に答えを得られます。
            </p>
          </div>
        </div>
      </section>

      {/* Our Philosophy */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-3">私たちの理念</h2>
        <div className="space-y-3 leading-relaxed opacity-90">
          <p>音楽理論は障壁ではなく、ツールであるべきです。</p>
          <p>
            キー、スケール、コード進行を理解するのに、
            何年もの正式な訓練は必要ないと私たちは信じています。
          </p>
          <p>
            OtoTheoryは「音楽を作りたい」と「どこから始めればいいかわからない」
            の間のギャップを埋めるために作られました。
          </p>
          <p className="font-medium">
            私たちの目標はシンプルです：<br />
            初めての楽曲を書くときも、100曲目を書くときも、
            自信を持って音楽を作れるようお手伝いします。
          </p>
        </div>
      </section>

      {/* Free vs Pro */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">無料版 vs Pro版</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="rounded-lg border border-black/10 dark:border-white/10 p-4">
            <h3 className="font-semibold mb-2">🆓 無料版（Web & iOS）</h3>
            <ul className="text-sm space-y-1 opacity-90">
              <li>• 任意のキー/スケールからコードを探す</li>
              <li>• 進行を作る（最大12コード）</li>
              <li>• 20プリセットパターン</li>
              <li>• PNGエクスポート</li>
              <li>• 3スケッチ保存（ローカル）</li>
            </ul>
          </div>
          <div className="rounded-lg border border-black/10 dark:border-white/10 p-4 bg-gradient-to-br from-purple-50 to-blue-50 dark:from-purple-950/20 dark:to-blue-950/20">
            <h3 className="font-semibold mb-2">💎 Pro版（iOS、¥490/月）</h3>
            <ul className="text-sm space-y-1 opacity-90">
              <li>• 50プリセットパターン</li>
              <li>• セクション編集（Verse/Chorus/Bridge）</li>
              <li>• コードトラック＆マーカー付きMIDIエクスポート</li>
              <li>• 無制限クラウド保存スケッチ</li>
              <li>• 7日間無料トライアル</li>
            </ul>
          </div>
        </div>
        <div className="text-center mt-4">
          <Link 
            href="/ja/pricing" 
            className="inline-block text-sm underline hover:no-underline"
          >
            詳細な料金比較を見る →
          </Link>
        </div>
      </section>

      {/* Get Started */}
      <section className="ot-card text-center">
        <h2 className="text-xl font-semibold mb-4">始めてみませんか？</h2>
        <div className="mb-4">
          <Link 
            href="/ja/getting-started" 
            className="inline-block text-sm underline hover:no-underline mb-3"
          >
            📖 はじめにガイドを読む →
          </Link>
        </div>
        <div className="flex flex-col sm:flex-row gap-3 justify-center items-center">
          <Link 
            href="/ja/chord-progression" 
            className="px-6 py-3 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 text-white font-semibold hover:opacity-90 transition-opacity"
          >
            🌐 今すぐWebで試す
          </Link>
          <div className="relative">
            <button 
              disabled
              className="px-6 py-3 rounded-lg border-2 border-black/20 dark:border-white/20 font-semibold opacity-50 cursor-not-allowed"
            >
              📱 iOSアプリをダウンロード
            </button>
            <span className="absolute -top-2 -right-2 px-2 py-0.5 text-xs font-bold bg-yellow-400 text-black rounded-full">
              近日公開
            </span>
          </div>
        </div>
        <p className="text-sm opacity-70 mt-4">無料、Web版は登録不要</p>
      </section>
    </div>
  );
}