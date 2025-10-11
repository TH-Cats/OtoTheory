import Link from "next/link";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Getting Started – OtoTheory",
  description: "Learn how to use OtoTheory to create chord progressions, find keys and scales, and save your work.",
};

export default function GettingStartedPage() {
  return (
    <div className="ot-page ot-stack">
      {/* Header */}
      <section className="ot-card text-center">
        <h1 className="text-2xl font-semibold mb-2">Getting Started with OtoTheory</h1>
        <p className="leading-relaxed opacity-90">
          With OtoTheory, you can create chord progressions and find notes that fit your chords<br />
          immediately, even without music theory knowledge.
        </p>
      </section>

      {/* 3 Steps */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">🎯 Get Started in 3 Steps</h2>
        
        {/* Step 1 */}
        <div className="mb-8">
          <h3 className="text-lg font-semibold mb-3">Step 1️⃣: Build a Chord Progression</h3>
          
          <div className="space-y-4 text-sm">
            <div>
              <p className="font-semibold mb-2">Method 1: Use Presets (Recommended)</p>
              <ol className="list-decimal pl-5 space-y-1 opacity-90">
                <li>Click &quot;Chord Progression&quot; from the menu</li>
                <li>Open the &quot;Presets&quot; section</li>
                <li>Tap a pattern you like (e.g., &quot;I - V - vi - IV&quot;)</li>
                <li>Chords are inserted and auto-play</li>
              </ol>
            </div>

            <div>
              <p className="font-semibold mb-2">Method 2: Build Manually</p>
              <ol className="list-decimal pl-5 space-y-1 opacity-90">
                <li>Click &quot;Chord Progression&quot; from the menu</li>
                <li>Tap the <strong>+ Add</strong> button</li>
                <li>Select and add chords you like</li>
              </ol>
            </div>

            <div className="bg-blue-50 dark:bg-blue-950/20 p-3 rounded-lg">
              <p className="font-semibold mb-1">💡 Beginner Tip:</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li>Try the preset &quot;<strong>I - V - vi - IV</strong>&quot; first (very popular progression)</li>
                <li>Choose from 20 presets (50 in Pro)</li>
                <li>Sound plays immediately so you can hear how it sounds</li>
              </ul>
            </div>

            <div>
              <p className="font-semibold mb-2">Get Key &amp; Scale Suggestions with Result Button</p>
              <ol className="list-decimal pl-5 space-y-1 opacity-90">
                <li>After creating your progression, tap the <strong>&quot;Result&quot;</strong> button</li>
                <li>Key and scale candidates with <strong>high compatibility</strong> are displayed</li>
                <li>Choose from multiple candidates</li>
              </ol>
              <p className="mt-2 opacity-80">
                <strong>Key Point</strong>: Keys are automatically detected from your chord progression. No music theory knowledge needed!
              </p>
            </div>
          </div>
        </div>

        {/* Step 2 */}
        <div className="mb-8 pt-6 border-t border-black/10 dark:border-white/10">
          <h3 className="text-lg font-semibold mb-3">Step 2️⃣: Choose a Key and Scale</h3>
          
          <div className="space-y-4 text-sm">
            <div>
              <p className="font-semibold mb-2">Select a Key</p>
              <ol className="list-decimal pl-5 space-y-1 opacity-90">
                <li>Choose from the key candidates shown in <strong>Result</strong></li>
                <li><strong>Scale options change</strong> based on the selected key</li>
              </ol>
            </div>

            <div>
              <p className="font-semibold mb-2">Select a Scale</p>
              <ol className="list-decimal pl-5 space-y-1 opacity-90">
                <li>Choose from scale candidates for your key</li>
                <li>Select Major (bright), Minor (dark), etc.</li>
              </ol>
            </div>

            <div className="bg-blue-50 dark:bg-blue-950/20 p-3 rounded-lg">
              <p className="font-semibold mb-1">💡 Key Point:</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li>Displayed in <strong>order of compatibility</strong></li>
                <li>If unsure, choose the top candidate</li>
              </ul>
            </div>

            <div>
              <p className="font-semibold mb-2">Fretboard Display</p>
              <p className="mb-2 opacity-90">When you choose a key and scale:</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li><strong>Scale notes are displayed on the fretboard</strong></li>
                <li>You can visually see which notes work well</li>
                <li>Makes it easier to create melodies and solos that fit your chord progression</li>
              </ul>
              <p className="mt-2 opacity-80">
                <strong>When to Use</strong>: Creating melodies, finding solo notes, learning scale patterns
              </p>
            </div>
          </div>
        </div>

        {/* Step 3 */}
        <div className="pt-6 border-t border-black/10 dark:border-white/10">
          <h3 className="text-lg font-semibold mb-3">Step 3️⃣: Save and Export</h3>
          
          <div className="space-y-4 text-sm">
            <div>
              <p className="font-semibold mb-2">Edit Progression (Before Saving)</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li><strong>Drag &amp; drop</strong> to reorder</li>
                <li>Tap a chord to delete</li>
                <li>Long-press to replace</li>
                <li>Add up to 12 chords (Free plan)</li>
              </ul>
            </div>

            <div>
              <p className="font-semibold mb-2">Save (Sketch)</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li>Saves <strong>progression, key, scale, and fretboard display together</strong></li>
                <li>Free: Up to 3 local saves</li>
                <li>Pro: Unlimited cloud saves</li>
              </ul>
            </div>

            <div>
              <p className="font-semibold mb-2">Export</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li><strong>PNG Image</strong>: Save progression as image (for sharing)</li>
                <li><strong>Text</strong>: Copy &amp; paste chord names, key, and scale info</li>
                <li><strong>MIDI</strong>: Edit in DAW (Pro only, with chord tracks &amp; markers)</li>
              </ul>
            </div>

            <div className="bg-blue-50 dark:bg-blue-950/20 p-3 rounded-lg">
              <p className="font-semibold mb-1">💡 Beginner Tip:</p>
              <ul className="list-disc pl-5 space-y-1 opacity-90">
                <li>Save progressions you like immediately</li>
                <li>PNG export lets you share with band members</li>
                <li>Saved sketches can be reopened to continue working</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Useful Features */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">🎸 Useful Features</h2>
        
        <div className="space-y-4 text-sm">
          <div>
            <h3 className="font-semibold mb-2">Find Chords (Chord Explorer)</h3>
            <p className="mb-2 opacity-90">Choose a key and scale to explore available chords in detail.</p>
            <p className="opacity-80">
              <strong>When to Use</strong>: Learn which chords work together, check fingerings, understand scales visually
            </p>
          </div>

          <div>
            <h3 className="font-semibold mb-2">Capo Suggestions</h3>
            <p className="mb-2 opacity-90">Get suggestions for making difficult keys easier to play.</p>
            <p className="opacity-80">
              <strong>When to Use</strong>: Play difficult keys with easy shapes, use more open string chords
            </p>
          </div>
        </div>
      </section>

      {/* Common Terms */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">📚 Common Terms</h2>
        
        <div className="space-y-3 text-sm">
          <div>
            <p className="font-semibold">Key</p>
            <p className="opacity-80">The central note of a song. Examples: C, G, Am</p>
          </div>
          <div>
            <p className="font-semibold">Scale</p>
            <p className="opacity-80">The set of notes used in a song. Examples: Major, Minor</p>
          </div>
          <div>
            <p className="font-semibold">Diatonic Chords</p>
            <p className="opacity-80">The core chords for a given key/scale. Choosing from these creates natural-sounding progressions.</p>
          </div>
          <div>
            <p className="font-semibold">Roman Numerals</p>
            <p className="opacity-80">Symbols indicating chord function (I, V, vi, IV). Uppercase = major, lowercase = minor.</p>
          </div>
          <div>
            <p className="font-semibold">Capo</p>
            <p className="opacity-80">A device attached to guitar fret to raise pitch. Makes difficult keys playable with easy shapes.</p>
          </div>
        </div>
      </section>

      {/* Next Steps */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">🎓 Next Steps</h2>
        
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-sm">
          <Link href="/faq" className="underline hover:no-underline">FAQ</Link>
          <Link href="/resources" className="underline hover:no-underline">Resources</Link>
          <Link href="/about" className="underline hover:no-underline">About OtoTheory</Link>
          <Link href="/pricing" className="underline hover:no-underline">Pricing</Link>
        </div>
      </section>

      {/* CTA */}
      <section className="ot-card text-center">
        <h2 className="text-xl font-semibold mb-4">Ready to start? Let&apos;s go!</h2>
        <div className="flex flex-col sm:flex-row gap-3 justify-center items-center">
          <Link 
            href="/chord-progression" 
            className="px-6 py-3 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 text-white font-semibold hover:opacity-90 transition-opacity"
          >
            🌐 Open Web Version (Free)
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
        <p className="text-sm opacity-70 mt-4">Web version: Free, no signup required</p>
      </section>

      {/* Support */}
      <section className="ot-card text-center text-sm opacity-80">
        <p className="mb-2">Need help?</p>
        <p>
          Check the <Link href="/faq" className="underline hover:no-underline">FAQ page</Link> or{' '}
          <Link href="/support" className="underline hover:no-underline">contact support</Link>
        </p>
      </section>
    </div>
  );
}

