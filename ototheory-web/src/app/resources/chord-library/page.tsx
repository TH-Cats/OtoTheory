import Link from 'next/link';

export default function ChordLibraryPage() {
  return (
    <div className="ot-page ot-stack">
      <Link href="/resources" className="text-sm text-blue-600 dark:text-blue-400 hover:underline mb-4 inline-block">
        ← Back to Resources
      </Link>

      <h1 className="text-xl font-semibold">Chord Library</h1>
      
      <div className="rounded-lg border p-8 text-center space-y-4">
        <div className="text-6xl">🎼</div>
        <h2 className="text-2xl font-bold">Coming Soon</h2>
        <p className="text-sm text-black/70 dark:text-white/70 max-w-md mx-auto">
          We're building a comprehensive chord library with diagrams, voicings, and fingering patterns.
          Check back soon for updates!
        </p>
        <p className="text-sm text-black/70 dark:text-white/70 max-w-md mx-auto">
          包括的なコードライブラリ（ダイアグラム、ボイシング、運指パターン付き）を準備中です。
          しばらくお待ちください！
        </p>
        <div className="pt-4">
          <Link 
            href="/resources" 
            className="inline-block px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium"
          >
            Browse Other Resources
          </Link>
        </div>
      </div>
    </div>
  );
}

