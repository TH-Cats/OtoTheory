import Link from "next/link";

export default function PricingPage() {
  return (
    <div className="ot-page ot-stack">
      {/* Header */}
      <section className="ot-card text-center">
        <h1 className="text-2xl font-semibold mb-2">Pricing</h1>
        <p className="leading-relaxed opacity-90">
          OtoTheory is free to start.<br />
          Upgrade to Pro when you need more advanced features.
        </p>
      </section>

      {/* Plan Comparison */}
      <section className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Free Plan */}
        <div className="ot-card">
          <div className="mb-4">
            <h2 className="text-xl font-semibold mb-1">🆓 Free Plan</h2>
            <p className="text-sm opacity-70">Available on Web &amp; iOS</p>
          </div>
          
          <div className="mb-4">
            <p className="text-3xl font-bold">$0</p>
            <p className="text-sm opacity-70">Forever free</p>
          </div>

          <div className="space-y-2 mb-6 text-sm">
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>Find chords from any key &amp; scale</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>Visual fretboard overlay</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>Capo suggestions (Top 2)</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>Build progressions (up to 12 chords)</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span><strong>Basic chords only</strong></span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>20 preset patterns</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>3 sketch saves (local)</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="opacity-50">✓</span>
              <span>PNG &amp; text export</span>
            </div>
          </div>

          <Link 
            href="/chord-progression" 
            className="block w-full text-center px-4 py-3 rounded-lg border-2 border-black/20 dark:border-white/20 font-semibold hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
          >
            Try Web Version
          </Link>
        </div>

        {/* Pro Plan */}
        <div className="ot-card bg-gradient-to-br from-purple-50 to-blue-50 dark:from-purple-950/20 dark:to-blue-950/20 border-2 border-purple-200 dark:border-purple-800">
          <div className="mb-4">
            <div className="flex items-center gap-2 mb-1">
              <h2 className="text-xl font-semibold">💎 Pro Plan</h2>
              <span className="text-xs px-2 py-0.5 rounded-full bg-purple-600 text-white font-medium">Popular</span>
            </div>
            <p className="text-sm opacity-70">iOS only</p>
          </div>
          
          <div className="mb-4">
            <p className="text-3xl font-bold">¥490<span className="text-lg font-normal">/month</span></p>
            <p className="text-sm opacity-70">7-day free trial</p>
          </div>

          <div className="space-y-2 mb-6 text-sm">
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>Everything in Free</strong></span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>Advanced chord selection</strong> (tensions, slash chords)</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>50 preset patterns</strong> (Free 20 + Pro 30)</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>Section editing</strong> (Verse/Chorus/Bridge)</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>MIDI export</strong> with chord tracks &amp; markers</span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>Unlimited cloud saves</strong></span>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-purple-600 dark:text-purple-400">★</span>
              <span><strong>Priority support</strong></span>
            </div>
          </div>

          <div className="relative">
            <button 
              disabled
              className="block w-full text-center px-4 py-3 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 text-white font-semibold opacity-50 cursor-not-allowed"
            >
              Download on iOS
            </button>
            <span className="absolute -top-2 -right-2 px-2 py-0.5 text-xs font-bold bg-yellow-400 text-black rounded-full">
              Coming Soon
            </span>
          </div>
        </div>
      </section>

      {/* Detailed Comparison Table */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">📊 Detailed Feature Comparison</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-black/10 dark:border-white/10">
                <th className="text-left py-3 pr-4 font-semibold">Feature</th>
                <th className="text-center py-3 px-2 font-semibold">Free</th>
                <th className="text-center py-3 px-2 font-semibold">Pro</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-black/5 dark:divide-white/5">
              <tr>
                <td className="py-3 pr-4">Find Chords</td>
                <td className="text-center py-3 px-2">✅</td>
                <td className="text-center py-3 px-2">✅</td>
              </tr>
              <tr>
                <td className="py-3 pr-4">Visual Fretboard</td>
                <td className="text-center py-3 px-2">✅</td>
                <td className="text-center py-3 px-2">✅</td>
              </tr>
              <tr>
                <td className="py-3 pr-4">Capo Suggestions</td>
                <td className="text-center py-3 px-2">Top 2</td>
                <td className="text-center py-3 px-2">Top 2</td>
              </tr>
              <tr>
                <td className="py-3 pr-4">Build Progressions</td>
                <td className="text-center py-3 px-2">Up to 12</td>
                <td className="text-center py-3 px-2">Up to 12</td>
              </tr>
              <tr className="bg-purple-50/50 dark:bg-purple-950/10">
                <td className="py-3 pr-4 font-medium">Chord Selection</td>
                <td className="text-center py-3 px-2">Basic only</td>
                <td className="text-center py-3 px-2"><strong className="text-purple-600 dark:text-purple-400">Complex &amp; slash</strong></td>
              </tr>
              <tr>
                <td className="py-3 pr-4">Preset Patterns</td>
                <td className="text-center py-3 px-2">20</td>
                <td className="text-center py-3 px-2"><strong>50</strong></td>
              </tr>
              <tr className="bg-purple-50/50 dark:bg-purple-950/10">
                <td className="py-3 pr-4 font-medium">Section Editing</td>
                <td className="text-center py-3 px-2">❌</td>
                <td className="text-center py-3 px-2"><strong className="text-purple-600 dark:text-purple-400">✅</strong></td>
              </tr>
              <tr>
                <td className="py-3 pr-4">Sketch Saves</td>
                <td className="text-center py-3 px-2">3 (local)</td>
                <td className="text-center py-3 px-2"><strong>Unlimited</strong></td>
              </tr>
              <tr>
                <td className="py-3 pr-4">PNG Export</td>
                <td className="text-center py-3 px-2">✅</td>
                <td className="text-center py-3 px-2">✅</td>
              </tr>
              <tr>
                <td className="py-3 pr-4">Text Export</td>
                <td className="text-center py-3 px-2">✅</td>
                <td className="text-center py-3 px-2">✅</td>
              </tr>
              <tr className="bg-purple-50/50 dark:bg-purple-950/10">
                <td className="py-3 pr-4 font-medium">MIDI Export</td>
                <td className="text-center py-3 px-2">❌</td>
                <td className="text-center py-3 px-2"><strong className="text-purple-600 dark:text-purple-400">✅</strong></td>
              </tr>
              <tr className="bg-purple-50/50 dark:bg-purple-950/10">
                <td className="py-3 pr-4 font-medium">Cloud Sync</td>
                <td className="text-center py-3 px-2">❌</td>
                <td className="text-center py-3 px-2"><strong className="text-purple-600 dark:text-purple-400">✅</strong></td>
              </tr>
              <tr>
                <td className="py-3 pr-4">Priority Support</td>
                <td className="text-center py-3 px-2">❌</td>
                <td className="text-center py-3 px-2">✅</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      {/* 7-Day Trial */}
      <section className="ot-card text-center">
        <h2 className="text-xl font-semibold mb-3">🎁 7-Day Free Trial</h2>
        <div className="max-w-2xl mx-auto space-y-2 text-sm opacity-90 mb-4">
          <p>Try Pro for 7 days, completely free.</p>
          <ul className="space-y-1">
            <li>✓ Full access to all Pro features</li>
            <li>✓ Credit card required, but cancel anytime during trial</li>
            <li>✓ Cancel at least 24 hours before trial ends to avoid any charges</li>
          </ul>
        </div>
        <div className="relative inline-block">
          <button 
            disabled
            className="px-6 py-3 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 text-white font-semibold opacity-50 cursor-not-allowed"
          >
            Start Free Trial
          </button>
          <span className="absolute -top-2 -right-2 px-2 py-0.5 text-xs font-bold bg-yellow-400 text-black rounded-full whitespace-nowrap">
            Coming Soon
          </span>
        </div>
      </section>

      {/* Which Plan */}
      <section className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="ot-card">
          <h3 className="font-semibold mb-3">Choose Free if you:</h3>
          <ul className="space-y-2 text-sm opacity-90">
            <li className="flex items-start gap-2">
              <span>🎸</span>
              <span>Are learning music theory</span>
            </li>
            <li className="flex items-start gap-2">
              <span>📝</span>
              <span>Want to experiment with chord progressions</span>
            </li>
            <li className="flex items-start gap-2">
              <span>🌐</span>
              <span>Want to try before committing</span>
            </li>
            <li className="flex items-start gap-2">
              <span>💻</span>
              <span>Web version is enough for your needs</span>
            </li>
          </ul>
        </div>

        <div className="ot-card">
          <h3 className="font-semibold mb-3">Choose Pro if you:</h3>
          <ul className="space-y-2 text-sm opacity-90">
            <li className="flex items-start gap-2">
              <span>✍️</span>
              <span>Compose music seriously</span>
            </li>
            <li className="flex items-start gap-2">
              <span>🎹</span>
              <span>Need MIDI files (for DAW editing)</span>
            </li>
            <li className="flex items-start gap-2">
              <span>📚</span>
              <span>Want to save many sketches</span>
            </li>
            <li className="flex items-start gap-2">
              <span>🎵</span>
              <span>Need section structure management</span>
            </li>
            <li className="flex items-start gap-2">
              <span>🔄</span>
              <span>Want to sync across devices</span>
            </li>
          </ul>
        </div>
      </section>

      {/* FAQ */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">❓ Frequently Asked Questions</h2>
        <div className="space-y-4 text-sm">
          <div>
            <p className="font-semibold mb-1">Q. Can I use Pro features on the web?</p>
            <p className="opacity-80">A. No, Pro is iOS-only. The web version offers free features only.</p>
          </div>
          <div>
            <p className="font-semibold mb-1">Q. Can I cancel during the trial period?</p>
            <p className="opacity-80">A. Yes, you can cancel anytime. Cancel at least 24 hours before trial ends to avoid charges.</p>
          </div>
          <div>
            <p className="font-semibold mb-1">Q. Is there an annual plan?</p>
            <p className="opacity-80">A. Currently, only monthly subscription is available. Annual plan is under consideration.</p>
          </div>
          <div>
            <p className="font-semibold mb-1">Q. Will my data transfer from Free to Pro?</p>
            <p className="opacity-80">A. Yes, your local sketches (up to 3) will be preserved when upgrading.</p>
          </div>
        </div>
        <div className="mt-4 pt-4 border-t border-black/10 dark:border-white/10 text-center">
          <p className="text-sm opacity-80">More questions?</p>
          <Link href="/faq" className="text-sm underline hover:no-underline">
            Visit FAQ page →
          </Link>
        </div>
      </section>

      {/* Subscription Details */}
      <section className="ot-card text-sm opacity-80">
        <h3 className="font-semibold mb-2 opacity-100">💳 Subscription Details</h3>
        <ul className="space-y-1">
          <li>• Payment via App Store (Apple ID)</li>
          <li>• Auto-renewing unless canceled at least 24 hours before period ends</li>
          <li>• Cancel anytime via Settings &gt; Apple ID &gt; Subscriptions</li>
          <li>• Refunds follow <a href="https://support.apple.com/en-us/HT204084" target="_blank" rel="noopener noreferrer" className="underline hover:no-underline">Apple&apos;s refund policy</a></li>
        </ul>
      </section>

      {/* Contact */}
      <section className="ot-card text-center text-sm opacity-80">
        <p>Questions about pricing or plans?</p>
        <p>
          <Link href="/support" className="underline hover:no-underline">Contact Support</Link> or email{' '}
          <a href="mailto:support@ototheory.com" className="underline hover:no-underline">support@ototheory.com</a>
        </p>
      </section>
    </div>
  );
}

