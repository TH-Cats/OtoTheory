import Link from 'next/link';

export default function ResourcesPage() {
  return (
    <div className="ot-page ot-stack">
      <h1 className="text-xl font-semibold">Resources</h1>
      
      <p className="text-sm text-black/70 dark:text-white/70">
        Essential guitar theory resources, terminology, and references for musicians.
      </p>

      {/* Main Resource Cards */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {/* Glossary */}
        <Link 
          href="/resources/glossary"
          className="group rounded-lg border p-5 hover:border-blue-500 dark:hover:border-blue-400 transition-all hover:shadow-lg"
        >
          <div className="flex items-start gap-3 mb-3">
            <span className="text-2xl">📚</span>
            <h2 className="text-lg font-semibold group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
              Glossary
            </h2>
          </div>
          <p className="text-sm text-black/70 dark:text-white/70 leading-relaxed">
            Quick reference for music theory terms. One-line definitions with guitar-specific notes and examples.
          </p>
          <div className="mt-3 text-sm text-blue-600 dark:text-blue-400 group-hover:underline">
            Browse terms →
          </div>
        </Link>

        {/* Music Theory */}
        <Link 
          href="/resources/music-theory"
          className="group rounded-lg border p-5 hover:border-purple-500 dark:hover:border-purple-400 transition-all hover:shadow-lg"
        >
          <div className="flex items-start gap-3 mb-3">
            <span className="text-2xl">🎸</span>
            <h2 className="text-lg font-semibold group-hover:text-purple-600 dark:group-hover:text-purple-400 transition-colors">
              Music Theory
            </h2>
          </div>
          <p className="text-sm text-black/70 dark:text-white/70 leading-relaxed">
            Complete theory guide for guitarists. Learn by numbers with practical 30-second recipes for immediate application.
          </p>
          <div className="mt-3 text-sm text-purple-600 dark:text-purple-400 group-hover:underline">
            Learn theory →
          </div>
        </Link>

      </div>

      {/* Quick Reference Section */}
      <section id="quick-reference" className="rounded-lg border p-4 space-y-3 mt-4">
        <h2 className="text-lg font-semibold">Quick Reference</h2>
        
        <div className="space-y-3">
          <div>
            <h3 className="font-medium text-sm mb-2">Roman Numerals</h3>
            <p className="text-sm text-black/70 dark:text-white/70">
              Uppercase = major triad, lowercase = minor triad, ° = diminished triad, ø = half‑diminished seventh (m7♭5).
            </p>
            <ul className="list-disc pl-5 text-xs space-y-1 text-black/60 dark:text-white/60 mt-2">
              <li>In major keys: <strong>vii°</strong> (triad) becomes <strong>viiø7</strong> (e.g., Bm7♭5 in C major)</li>
              <li><strong>VII</strong> denotes a major triad on the 7th degree; if borrowed, typically written as <strong>♭VII</strong></li>
            </ul>
          </div>

          <div>
            <h3 className="font-medium text-sm mb-2">Cadences</h3>
            <div className="grid sm:grid-cols-2 gap-2 text-sm">
              <div className="rounded border p-3">
                <strong className="text-xs">Perfect (V → I)</strong>
                <p className="text-xs text-black/60 dark:text-white/60 mt-1">Strong resolution</p>
              </div>
              <div className="rounded border p-3">
                <strong className="text-xs">Deceptive (V → vi)</strong>
                <p className="text-xs text-black/60 dark:text-white/60 mt-1">Surprised continuation</p>
              </div>
              <div className="rounded border p-3">
                <strong className="text-xs">Half (… → V)</strong>
                <p className="text-xs text-black/60 dark:text-white/60 mt-1">Open, unresolved</p>
              </div>
              <div className="rounded border p-3">
                <strong className="text-xs">Plagal (IV → I)</strong>
                <p className="text-xs text-black/60 dark:text-white/60 mt-1">Softer resolution</p>
              </div>
            </div>
          </div>

          <div>
            <h3 className="font-medium text-sm mb-2">Capo Quick Guide</h3>
            <p className="text-sm text-black/70 dark:text-white/70 mb-2">
              Adjust vocal range and make chord shapes easier.
            </p>
            <ul className="list-disc pl-5 text-xs space-y-1 text-black/60 dark:text-white/60">
              <li>Major: friendly shapes are C / G / D / A / E</li>
              <li>Minor: friendly shapes are Am / Em / Dm</li>
              <li>Roman numerals are always based on the sounding key</li>
            </ul>
          </div>
        </div>
      </section>

      <div className="rounded-lg border p-4 text-center text-sm opacity-70">Ad Placeholder</div>
    </div>
  );
}

