import Link from "next/link";

export default function Home() {
  return (
    <main className="ot-page ot-stack">
      <section className="ot-card text-white" style={{background: 'linear-gradient(90deg, var(--brand-primary), var(--brand-secondary))'}}>
        <h1 className="text-2xl font-semibold">OtoTheory</h1>
        <p className="opacity-90">Use Theory Without Tears</p>
      </section>
      <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
        <Link href="/find-key" className="ot-card hover:bg-black/5 dark:hover:bg-white/5">
          <h2 className="font-semibold mb-1">Chord Progression</h2>
          <p className="text-sm opacity-80">Build chord progressions</p>
        </Link>
        <Link href="/find-chords" className="ot-card hover:bg-black/5 dark:hover:bg-white/5">
          <h2 className="font-semibold mb-1">Find Chords</h2>
          <p className="text-sm opacity-80">See chords from key &amp; scale</p>
        </Link>
        <Link href="/reference" className="ot-card hover:bg-black/5 dark:hover:bg-white/5">
          <h2 className="font-semibold mb-1">Reference</h2>
          <p className="text-sm opacity-80">Chords, cadences, and capo guide</p>
        </Link>
      </section>
      <div className="ot-card text-center text-sm opacity-70 ad-placeholder">
        Ad Placeholder
      </div>
    </main>
  );
}
