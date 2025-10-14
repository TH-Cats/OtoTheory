import Link from "next/link";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "iOS App Coming Soon – OtoTheory",
  description: "OtoTheory iOS app with Pro features is coming soon. Try the web version now for free!",
};

export default function iOSComingSoonPage() {
  return (
    <div className="ot-page ot-stack">
      {/* Header */}
      <section className="ot-card text-center py-10" style={{background: 'linear-gradient(90deg, var(--brand-primary), var(--brand-secondary))'}}>
        <div className="text-6xl mb-4">📱</div>
        <h1 className="text-3xl font-bold text-white mb-3">iOS App Coming Soon</h1>
        <p className="text-lg text-white/90 max-w-xl mx-auto">
          We&apos;re working hard to bring OtoTheory Pro to iOS. Stay tuned!
        </p>
      </section>

      {/* What to Expect */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">What to Expect in iOS Pro</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-sm">
          <div className="flex items-start gap-2">
            <span className="text-purple-600 dark:text-purple-400">★</span>
            <div>
              <p className="font-semibold">5-Track MIDI Export (SMF Type-1)</p>
              <p className="opacity-80">Guitar, Bass, Scale Guide×2, Guide Tones</p>
            </div>
          </div>
          <div className="flex items-start gap-2">
            <span className="text-purple-600 dark:text-purple-400">★</span>
            <div>
              <p className="font-semibold">Section Markers & Arrangements</p>
              <p className="opacity-80">Export song structure directly to your DAW</p>
            </div>
          </div>
          <div className="flex items-start gap-2">
            <span className="text-purple-600 dark:text-purple-400">★</span>
            <div>
              <p className="font-semibold">50 Genre-Specific Presets</p>
              <p className="opacity-80">Pop, Rock, Jazz, Blues, R&amp;B/Soul, Acoustic</p>
            </div>
          </div>
          <div className="flex items-start gap-2">
            <span className="text-purple-600 dark:text-purple-400">★</span>
            <div>
              <p className="font-semibold">Advanced Voicings & Alterations</p>
              <p className="opacity-80">7♭9, 7#9, 7#11, 13th, slash chords</p>
            </div>
          </div>
          <div className="flex items-start gap-2">
            <span className="text-purple-600 dark:text-purple-400">★</span>
            <div>
              <p className="font-semibold">Guide Tone Track for Improv</p>
              <p className="opacity-80">3rd/7th melodic line to guide solos</p>
            </div>
          </div>
          <div className="flex items-start gap-2">
            <span className="text-purple-600 dark:text-purple-400">★</span>
            <div>
              <p className="font-semibold">Unlimited Cloud Projects</p>
              <p className="opacity-80">Seamless sync across iPhone, iPad, Mac</p>
            </div>
          </div>
        </div>
      </section>

      {/* Meanwhile */}
      <section className="ot-card text-center">
        <h2 className="text-xl font-semibold mb-3">Meanwhile, Try the Web Version!</h2>
        <p className="mb-6 opacity-90">
          OtoTheory&apos;s core features are available now on the web, completely free.
        </p>
        <div className="space-y-3">
          <Link 
            href="/chord-progression" 
            className="inline-block px-6 py-3 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 text-white font-semibold hover:opacity-90 transition-opacity"
          >
            🌐 Try Web Version (Free)
          </Link>
          <p className="text-sm opacity-70">No signup required • Works on any device</p>
        </div>
      </section>

      {/* Web Features */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">Available Now on Web (Free)</h2>
        <ul className="space-y-2 text-sm">
          <li className="flex items-start gap-2">
            <span>✅</span>
            <span><strong>Find Chords</strong> - Discover chords from any key &amp; scale</span>
          </li>
          <li className="flex items-start gap-2">
            <span>✅</span>
            <span><strong>Visual Fretboard</strong> - Two-layer display (scales + chords)</span>
          </li>
          <li className="flex items-start gap-2">
            <span>✅</span>
            <span><strong>Capo Suggestions</strong> - Top 2 capo positions</span>
          </li>
          <li className="flex items-start gap-2">
            <span>✅</span>
            <span><strong>Build Progressions</strong> - Up to 12 chords</span>
          </li>
          <li className="flex items-start gap-2">
            <span>✅</span>
            <span><strong>20 Presets</strong> - Common progression patterns</span>
          </li>
          <li className="flex items-start gap-2">
            <span>✅</span>
            <span><strong>Auto-playback</strong> - Hear your progressions instantly</span>
          </li>
          <li className="flex items-start gap-2">
            <span>✅</span>
            <span><strong>3 Sketch Saves</strong> - Save locally in your browser</span>
          </li>
          <li className="flex items-start gap-2">
            <span>✅</span>
            <span><strong>PNG &amp; Text Export</strong> - Share your progressions</span>
          </li>
        </ul>
      </section>

      {/* Stay Updated */}
      <section className="ot-card text-center">
        <h2 className="text-xl font-semibold mb-3">Want to be notified when iOS launches?</h2>
        <p className="mb-4 opacity-90">
          Email us at <a href="mailto:support@ototheory.com" className="underline hover:no-underline">support@ototheory.com</a> with the subject &quot;iOS Launch Notification&quot;
        </p>
        <p className="text-sm opacity-70">
          We&apos;ll send you a quick email when the iOS app is available on the App Store.
        </p>
      </section>

      {/* Learn More */}
      <section className="ot-card text-center text-sm">
        <div className="flex flex-wrap justify-center gap-3">
          <Link href="/about" className="underline hover:no-underline">About OtoTheory</Link>
          <span>•</span>
          <Link href="/pricing" className="underline hover:no-underline">Pricing Plans</Link>
          <span>•</span>
          <Link href="/faq" className="underline hover:no-underline">FAQ</Link>
          <span>•</span>
          <Link href="/support" className="underline hover:no-underline">Support</Link>
        </div>
      </section>
    </div>
  );
}

