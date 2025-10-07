export default function ReferencePage() {
  return (
    <main className="ot-page ot-stack" data-page="reference">
      <section id="scales" className="ot-card">
        <h1 className="ot-h2">Scale Reference</h1>
        <p className="text-sm opacity-80">Degrees and example notes for each scale. See in‑app Info (i) for details and songs.</p>
        <ul className="list-disc pl-5 text-sm mt-2">
          <li>Degrees use 1, b2, 2, b3, 3, 4, #4, b5, 5, #5, b6, 6, bb7, b7, 7 tokens.</li>
          <li>Notes in C are derived by <code>getScalePitchesById(0, scaleId)</code>.</li>
        </ul>
      </section>
    </main>
  );
}






