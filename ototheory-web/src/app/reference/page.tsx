export default function ReferencePage() {
  const chords = [
    'C','D','E','F','G','A','B',
    'Cm','Dm','Em','Fm','Gm','Am','Bm',
    'C7','D7','E7','F7','G7','A7','B7',
    'Cmaj7','Dmaj7','Fmaj7','Gmaj7','Amaj7',
    'Csus4','Dsus4','Asus4','Asus2'
  ];
  return (
    <div className="ot-page ot-stack">
      <h1 className="text-xl font-semibold">Reference</h1>
      <nav className="text-sm opacity-80">
        <a href="#cadences" className="underline">Cadences</a>
      </nav>
      <section className="rounded-lg border p-4 text-sm leading-relaxed">
        <h2 className="font-semibold mb-2">Roman Numerals Quick Guide</h2>
        <p className="mb-1">Uppercase = major triad, lowercase = minor triad, ° = diminished triad, ø = half‑diminished seventh (m7♭5).</p>
        <ul className="list-disc pl-5 space-y-1 text-black/80 dark:text-white/80">
          <li>In a major key, the chord built on the 7th degree is <strong>vii°</strong> (triad). As a seventh chord it becomes <strong>viiø7</strong> (e.g., Bm7♭5 in C major).</li>
          <li><strong>VII</strong> denotes a major triad on the 7th degree and is not diatonic in a major key; if borrowed, it is typically written as <strong>♭VII</strong>.</li>
          <li>In minor keys, depending on the scale form (e.g., harmonic minor), symbols like <strong>VII</strong> or <strong>ii°</strong> can legitimately appear.</li>
        </ul>
      </section>
      <section id="cadences" className="rounded-lg border p-4 space-y-3">
        <h2 className="text-lg font-semibold">Cadences</h2>
        <p className="text-sm text-black/70 dark:text-white/70">A cadence is how a phrase "ends". Roman numerals below assume the selected key.</p>
        <div className="space-y-3">
          <div>
            <h3 className="font-medium">Perfect (Authentic)</h3>
            <p className="text-sm">Resolves Dominant to Tonic: <code>V → I</code> (in minor often <code>V → i</code>). Feels fully resolved.</p>
            <p className="text-xs opacity-70">Example in C Major: <code>G → C</code> / Roman: <code>V → I</code></p>
          </div>
          <div>
            <h3 className="font-medium">Deceptive</h3>
            <p className="text-sm">Avoids the expected I by moving to vi (or a substitute): <code>V → vi</code>. Creates a "surprised" continuation.</p>
            <p className="text-xs opacity-70">Example in C Major: <code>G → Am</code> / Roman: <code>V → vi</code></p>
          </div>
          <div>
            <h3 className="font-medium">Half</h3>
            <p className="text-sm">Ends on the Dominant: <code>… → V</code>. Feels open and unresolved.</p>
            <p className="text-xs opacity-70">Example in C Major: <code>F → G</code> / Roman: <code>IV → V</code></p>
          </div>
        </div>
        <p className="text-xs opacity-70">Tip: Cadence detection in OtoTheory is heuristic. For mixed keys or modal borrowing, the label indicates the dominant tendency at the phrase end.</p>
      </section>
      <section id="capo" className="rounded-lg border p-4 space-y-3">
        <h2 className="text-lg font-semibold">Capo Quick Guide</h2>
        <p className="text-sm text-black/70 dark:text-white/70">Why capo: adjust vocal range, gain more open strings, and make shapes easier.</p>
        <ul className="list-disc pl-5 text-sm space-y-1">
          <li>Major: friendly shapes are C / G / D / A / E (many open strings)</li>
          <li>Minor: friendly shapes are Am / Em / Dm</li>
        </ul>
        <div className="text-sm space-y-2">
          <div>
            <div className="font-medium">Minor example</div>
            <p>B♭ minor → Capo 1 + Am, Capo 6 + Em, Capo 8 + Dm</p>
          </div>
          <div>
            <div className="font-medium">Major example</div>
            <p>E♭ major → Capo 3 + C, Capo 1 + D, Capo 6 + G</p>
          </div>
        </div>
        <div className="pt-2">
          <h3 className="font-medium text-sm">Shaped vs Sounding</h3>
          <ul className="list-disc pl-5 text-sm space-y-1 text-black/70 dark:text-white/70">
            <li>Roman numerals are always based on the sounding key.</li>
            <li>The display toggle switches only the chord/scale symbols: Sounding shows actual pitches; Shaped shows forms with capo.</li>
            <li>Fretboard: in Shaped, positions are relative from the capo; in Sounding, open strings reflect E–A–D–G–B–E actual pitches.</li>
          </ul>
        </div>
      </section>
      <div className="grid grid-cols-2 sm:grid-cols-6 gap-2">
        {chords.map((c) => (
          <div key={c} className="rounded border p-3 text-center text-sm">
            {c}
          </div>
        ))}
      </div>
      <div className="rounded-lg border p-4 text-center text-sm opacity-70">Ad Placeholder</div>
    </div>
  );
}
