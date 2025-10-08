import Link from "next/link";

export default function SupportPage() {
  return (
    <div className="ot-page ot-stack">
      {/* Header */}
      <section className="ot-card">
        <h1 className="text-2xl font-semibold mb-2">Contact &amp; Support</h1>
        <p className="leading-relaxed opacity-90">
          Thank you for using OtoTheory.<br />
          If you have any questions or issues, please don&apos;t hesitate to reach out.
        </p>
      </section>

      {/* Contact Information */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-3">📧 Contact Information</h2>
        <div className="space-y-2">
          <p>
            <strong>Email</strong>:{' '}
            <a href="mailto:support@ototheory.com" className="underline hover:no-underline">
              support@ototheory.com
            </a>
          </p>
          <p className="text-sm opacity-80">
            <strong>Response Time</strong>: We typically respond within 2 business days.<br />
            (Excluding weekends and holidays)
          </p>
        </div>
      </section>

      {/* Before You Contact Us */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-3">🔍 Before You Contact Us</h2>
        <h3 className="font-semibold mb-2">Frequently Asked Questions (FAQ)</h3>
        <p className="mb-3 leading-relaxed opacity-90">
          Many common questions are answered on our <Link href="/faq" className="underline hover:no-underline">FAQ page</Link>.
          Please check for:
        </p>
        <ul className="list-disc pl-5 space-y-1 text-sm opacity-90 mb-3">
          <li>How to cancel subscription</li>
          <li>How to delete account</li>
          <li>Data retention period</li>
          <li>Difference between Shaped and Sounding</li>
          <li>Export features</li>
          <li>Offline usage</li>
        </ul>
        <Link 
          href="/faq" 
          className="inline-block px-4 py-2 rounded-lg border border-black/20 dark:border-white/20 text-sm font-medium hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
        >
          Visit FAQ page →
        </Link>
      </section>

      {/* Common Inquiries */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4">💬 Common Inquiries</h2>
        <div className="space-y-4">
          {/* Features */}
          <div>
            <h3 className="font-semibold mb-2">🎵 Features</h3>
            <div className="text-sm space-y-2 opacity-90">
              <div>
                <p className="font-medium">Q. Which features are Free/Pro?</p>
                <p>→ See our Pricing page (coming soon) for a detailed comparison table.</p>
              </div>
            </div>
          </div>

          {/* Billing */}
          <div>
            <h3 className="font-semibold mb-2">💳 Billing &amp; Subscription</h3>
            <div className="text-sm space-y-2 opacity-90">
              <div>
                <p className="font-medium">Q. I want to cancel my subscription</p>
                <p>→ Go to Apple ID &gt; Subscriptions &gt; OtoTheory to cancel.</p>
              </div>
              <div>
                <p className="font-medium">Q. I want a refund</p>
                <p>
                  → App Store purchases follow Apple&apos;s refund policy.{' '}
                  <a 
                    href="https://support.apple.com/en-us/HT204084" 
                    target="_blank" 
                    rel="noopener noreferrer"
                    className="underline hover:no-underline"
                  >
                    Visit Apple&apos;s support page
                  </a>
                </p>
              </div>
            </div>
          </div>

          {/* Account & Data */}
          <div>
            <h3 className="font-semibold mb-2">🔐 Account &amp; Data</h3>
            <div className="text-sm space-y-2 opacity-90">
              <div>
                <p className="font-medium">Q. I want to delete my account</p>
                <p>→ Go to Settings &gt; Delete Account in the app, or email us at support@ototheory.com.</p>
              </div>
              <div>
                <p className="font-medium">Q. Can I backup my data?</p>
                <p>→ Pro version includes automatic cloud sync backup. Free version is local storage only.</p>
              </div>
            </div>
          </div>

          {/* Troubleshooting */}
          <div>
            <h3 className="font-semibold mb-2">🐛 Issues &amp; Troubleshooting</h3>
            <div className="text-sm space-y-2 opacity-90">
              <div>
                <p className="font-medium">Q. App won&apos;t launch / crashes</p>
                <p>→ Please try:</p>
                <ol className="list-decimal pl-5 mt-1 space-y-0.5">
                  <li>Force quit and restart the app</li>
                  <li>Restart your device</li>
                  <li>Update to the latest version from App Store</li>
                  <li>If issue persists, contact support@ototheory.com</li>
                </ol>
              </div>
              <div>
                <p className="font-medium">Q. No sound output</p>
                <p>→ Please check:</p>
                <ol className="list-decimal pl-5 mt-1 space-y-0.5">
                  <li>Device volume level</li>
                  <li>Silent mode is off</li>
                  <li>Sound works in other apps</li>
                  <li>Restart the app</li>
                </ol>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Information to Include */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-3">📝 Information to Include When Contacting Us</h2>
        <p className="mb-3 leading-relaxed opacity-90">
          For faster support, please provide:
        </p>
        <ul className="list-disc pl-5 space-y-1 text-sm opacity-90">
          <li><strong>Platform</strong>: iOS app / Web version</li>
          <li><strong>Version</strong>: App version number (shown in Settings)</li>
          <li><strong>Device</strong>: iPhone/iPad model, OS version</li>
          <li><strong>Issue Details</strong>: When it started, what actions trigger it</li>
          <li><strong>Screenshots</strong>: If possible, please attach</li>
        </ul>
      </section>

      {/* Other Resources */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-3">🌐 Other Resources</h2>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
          <Link href="/about" className="text-sm underline hover:no-underline">About</Link>
          <Link href="/faq" className="text-sm underline hover:no-underline">FAQ</Link>
          <Link href="/privacy" className="text-sm underline hover:no-underline">Privacy Policy</Link>
          <Link href="/terms" className="text-sm underline hover:no-underline">Terms of Service</Link>
        </div>
      </section>

      {/* Feedback */}
      <section className="ot-card text-center">
        <h2 className="text-xl font-semibold mb-2">💌 Feedback &amp; Feature Requests</h2>
        <p className="mb-4 leading-relaxed opacity-90">
          We welcome your feedback and suggestions to make OtoTheory better.<br />
          Feature requests, UI improvements, or any other ideas are appreciated.
        </p>
        <a 
          href="mailto:support@ototheory.com" 
          className="inline-block px-6 py-3 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 text-white font-semibold hover:opacity-90 transition-opacity"
        >
          Email Us
        </a>
      </section>

      {/* Company Info */}
      <section className="ot-card text-center text-sm opacity-70">
        <p>
          <strong>Provider</strong>: TH Quest<br />
          <strong>Location</strong>: Kamakura, Kanagawa, Japan<br />
          <strong>Email</strong>: <a href="mailto:support@ototheory.com" className="underline">support@ototheory.com</a>
        </p>
      </section>
    </div>
  );
}

