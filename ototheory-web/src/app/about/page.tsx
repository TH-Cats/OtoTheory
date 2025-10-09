import Link from "next/link";

export default function AboutPage() {
  return (
    <div className="ot-page ot-stack">
      {/* Headline */}
      <section className="ot-card text-white" style={{background: 'linear-gradient(90deg, var(--brand-primary), var(--brand-secondary))'}}>
        <h1 className="text-2xl font-semibold mb-2">OtoTheory — Use Theory Without Tears</h1>
        <p className="leading-relaxed opacity-90">
          A music theory-powered composition tool for guitarists.<br />
          Learn theory while you create.<br />
          Understand chords, progressions, keys, and scales visually,<br />
          without struggling through dense theory books.
        </p>
      </section>

      {/* What is OtoTheory? */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-3">What is OtoTheory?</h2>
        <p className="mb-3 leading-relaxed">
          OtoTheory is a practical music theory tool designed specifically for guitarists.
        </p>
        <p className="font-semibold mb-2">Use it when you want to:</p>
        <ul className="list-disc pl-5 space-y-1 mb-3 opacity-90">
          <li>Learn your first chord progressions</li>
          <li>Compose original songs</li>
          <li>Find out which chords work together</li>
          <li>Discover which notes to use for melodies and solos</li>
        </ul>
        <p className="leading-relaxed opacity-90">
          OtoTheory provides instant answers with interactive guitar fretboards, 
          automatic chord suggestions, and smart capo recommendations.
        </p>
        <p className="mt-3 font-medium">
          No music theory degree required.<br />
          Just bring your curiosity and your guitar.
        </p>
      </section>

      {/* Key Features */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">Key Features</h2>
        <div className="space-y-4">
          <div>
            <h3 className="font-semibold mb-1">🎸 Find Chords from Key &amp; Scale</h3>
            <p className="text-sm opacity-90 leading-relaxed">
              Enter any key and scale to instantly see which chords work together. 
              Visualized on guitar fretboard with both open and barre forms.
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">🎵 Build Chord Progressions</h3>
            <p className="text-sm opacity-90 leading-relaxed">
              Create and listen to progressions with automatic playback. 
              Choose from 20+ preset patterns (Free) or 50+ with Pro.
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">🎯 Capo Suggestions</h3>
            <p className="text-sm opacity-90 leading-relaxed">
              Get smart capo recommendations that make difficult keys easier to play. 
              See both &quot;Shaped&quot; (what you finger) and &quot;Sounding&quot; (what you hear) notation.
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">🎨 Visual Fretboard Overlay</h3>
            <p className="text-sm opacity-90 leading-relaxed">
              Two-layer display shows scales (outline) and chords (filled) simultaneously. 
              Toggle between note names and scale degrees.
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">📤 Export &amp; Share</h3>
            <p className="text-sm opacity-90 leading-relaxed">
              Export progressions as PNG images (Free) or MIDI files with chord tracks, 
              section markers, and guide tones (Pro).
            </p>
          </div>
        </div>
      </section>

      {/* Who is it for? */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">Who is it for?</h2>
        <div className="space-y-3">
          <div>
            <h3 className="font-semibold mb-1">📚 Beginners</h3>
            <p className="text-sm opacity-90">
              Learn which chords belong together without memorizing theory books.
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">✍️ Songwriters &amp; Composers</h3>
            <p className="text-sm opacity-90">
              Experiment with progressions quickly and discover fresh chord combinations. 
              Visualize which notes match your chords for better melodies and solos.
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">🎓 Self-learners</h3>
            <p className="text-sm opacity-90">
              Understand practical theory concepts through interactive visualization.
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-1">🎸 Guitarists of All Levels</h3>
            <p className="text-sm opacity-90">
              Get instant answers to &quot;What chord comes next?&quot; and &quot;Which notes should I use for my solo?&quot;
            </p>
          </div>
        </div>
      </section>

      {/* Our Philosophy */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-3">Our Philosophy</h2>
        <div className="space-y-3 leading-relaxed opacity-90">
          <p>Music theory should be a tool, not a barrier.</p>
          <p>
            We believe that understanding keys, scales, and chord progressions 
            shouldn&apos;t require years of formal training.
          </p>
          <p>
            OtoTheory was created to bridge the gap between &quot;I want to create music&quot; 
            and &quot;I don&apos;t know where to start.&quot;
          </p>
          <p className="font-medium">
            Our goal is simple:<br />
            Help you make music with confidence, whether you&apos;re writing your first song or your hundredth.
          </p>
        </div>
      </section>

      {/* Free vs Pro */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">Free vs Pro</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="rounded-lg border border-black/10 dark:border-white/10 p-4">
            <h3 className="font-semibold mb-2">🆓 Free (Web &amp; iOS)</h3>
            <ul className="text-sm space-y-1 opacity-90">
              <li>• Find chords from any key/scale</li>
              <li>• Build progressions (up to 12 chords)</li>
              <li>• 20 preset patterns</li>
              <li>• PNG export</li>
              <li>• 3 saved sketches (local)</li>
            </ul>
          </div>
          <div className="rounded-lg border border-black/10 dark:border-white/10 p-4 bg-gradient-to-br from-purple-50 to-blue-50 dark:from-purple-950/20 dark:to-blue-950/20">
            <h3 className="font-semibold mb-2">💎 Pro (iOS, ¥490/month)</h3>
            <ul className="text-sm space-y-1 opacity-90">
              <li>• 50 preset patterns</li>
              <li>• Section editing (Verse/Chorus/Bridge)</li>
              <li>• MIDI export with chord tracks &amp; markers</li>
              <li>• Unlimited cloud-saved sketches</li>
              <li>• 7-day free trial</li>
            </ul>
          </div>
        </div>
        <div className="text-center mt-4">
          <Link 
            href="/pricing" 
            className="inline-block text-sm underline hover:no-underline"
          >
            View detailed pricing comparison →
          </Link>
        </div>
      </section>

      {/* Get Started */}
      <section className="ot-card text-center">
        <h2 className="text-xl font-semibold mb-4">Ready to explore?</h2>
        <div className="mb-4">
          <Link 
            href="/getting-started" 
            className="inline-block text-sm underline hover:no-underline mb-3"
          >
            📖 Read Getting Started Guide →
          </Link>
        </div>
        <div className="flex flex-col sm:flex-row gap-3 justify-center items-center">
          <Link 
            href="/find-key" 
            className="px-6 py-3 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 text-white font-semibold hover:opacity-90 transition-opacity"
          >
            🌐 Try it now on the web
          </Link>
          <div className="relative">
            <button 
              disabled
              className="px-6 py-3 rounded-lg border-2 border-black/20 dark:border-white/20 font-semibold opacity-50 cursor-not-allowed"
            >
              📱 Download iOS App
            </button>
            <span className="absolute -top-2 -right-2 px-2 py-0.5 text-xs font-bold bg-yellow-400 text-black rounded-full">
              Coming Soon
            </span>
          </div>
        </div>
        <p className="text-sm opacity-70 mt-4">Free, no signup required for web version</p>
      </section>
    </div>
  );
}

