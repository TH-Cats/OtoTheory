export default function PrivacyPage() {
  return (
    <div className="ot-page ot-stack">
      <h1 className="text-2xl font-semibold">Privacy Policy (OtoTheory)</h1>
      
      <section className="ot-card space-y-4">
        <div>
          <p><strong>Controller</strong>: TH Quest (Kamakura, Kanagawa, Japan)</p>
          <p><strong>Contact</strong>: <a href="mailto:support@ototheory.com" className="underline">support@ototheory.com</a></p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">1. Data We Collect</h2>
          <p className="text-sm leading-relaxed">
            Contact (email incl. Apple private relay), identifiers (user/device), in‑app purchase status, 
            usage events (e.g., progression_play, export_png), diagnostics (crash/perf), approximate location 
            (derived from IP; no precise location), no access to contacts/photos/files.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">2. Purposes</h2>
          <p className="text-sm leading-relaxed">
            Provide app features (sync, sketch, MIDI), product analytics, customer support and important notices.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">3. Sharing</h2>
          <p className="text-sm leading-relaxed">
            No sale of personal data. We use Vercel for hosting/CDN; minimal operational logs may be processed.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">4. Retention</h2>
          <p className="text-sm leading-relaxed">
            Sketch: until account deletion (purged within 30 days after deletion). 
            Logs: kept 90 days then deleted/anonymized.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">5. Security / Region</h2>
          <p className="text-sm leading-relaxed">
            HTTPS, access control. Data region: Tokyo.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">6. Your Rights</h2>
          <p className="text-sm leading-relaxed">
            Delete your account in‑app (Settings &gt; Delete Account) or email us at{' '}
            <a href="mailto:support@ototheory.com" className="underline">support@ototheory.com</a>.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">7. Children</h2>
          <p className="text-sm leading-relaxed">
            Not directed to children under 13.
          </p>
        </div>

        <div>
          <h2 className="text-lg font-semibold mb-2">8. Changes</h2>
          <p className="text-sm leading-relaxed">
            We will announce material changes here. Continued use constitutes acceptance.
          </p>
        </div>

        <p className="text-xs opacity-70 mt-4">
          <strong>(Last updated: 2025‑10‑03)</strong>
        </p>
      </section>
    </div>
  );
}

