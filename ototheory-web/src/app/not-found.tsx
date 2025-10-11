import Link from "next/link";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Page Not Found – OtoTheory",
  description: "The page you're looking for doesn't exist.",
};

export default function NotFound() {
  return (
    <div className="ot-page ot-stack">
      {/* Hero Section */}
      <section className="ot-card text-center py-12">
        <div className="text-8xl mb-6">🎸</div>
        <h1 className="text-4xl font-bold mb-3">404 - Page Not Found</h1>
        <p className="text-lg opacity-80 mb-6">
          Oops! Looks like this page hit a wrong note.
        </p>
        <p className="opacity-70 max-w-md mx-auto">
          The page you&apos;re looking for doesn&apos;t exist or may have been moved.
        </p>
      </section>

      {/* Quick Navigation */}
      <section className="ot-card">
        <h2 className="text-xl font-semibold mb-4 text-center">Where would you like to go?</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
          <Link 
            href="/"
            className="p-4 rounded-lg border border-black/10 dark:border-white/10 hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
          >
            <div className="text-2xl mb-2">🏠</div>
            <h3 className="font-semibold mb-1">Home</h3>
            <p className="text-sm opacity-70">Back to the top page</p>
          </Link>

          <Link 
            href="/chord-progression"
            className="p-4 rounded-lg border border-black/10 dark:border-white/10 hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
          >
            <div className="text-2xl mb-2">🎵</div>
            <h3 className="font-semibold mb-1">Chord Progression</h3>
            <p className="text-sm opacity-70">Build chord progressions</p>
          </Link>

          <Link 
            href="/find-chords"
            className="p-4 rounded-lg border border-black/10 dark:border-white/10 hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
          >
            <div className="text-2xl mb-2">🔍</div>
            <h3 className="font-semibold mb-1">Find Chords</h3>
            <p className="text-sm opacity-70">Explore chords by key</p>
          </Link>

          <Link 
            href="/resources"
            className="p-4 rounded-lg border border-black/10 dark:border-white/10 hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
          >
            <div className="text-2xl mb-2">📚</div>
            <h3 className="font-semibold mb-1">Resources</h3>
            <p className="text-sm opacity-70">Theory, glossary, chord library</p>
          </Link>

          <Link 
            href="/getting-started"
            className="p-4 rounded-lg border border-black/10 dark:border-white/10 hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
          >
            <div className="text-2xl mb-2">📖</div>
            <h3 className="font-semibold mb-1">Getting Started</h3>
            <p className="text-sm opacity-70">Learn how to use OtoTheory</p>
          </Link>

          <Link 
            href="/faq"
            className="p-4 rounded-lg border border-black/10 dark:border-white/10 hover:bg-black/5 dark:hover:bg-white/5 transition-colors"
          >
            <div className="text-2xl mb-2">❓</div>
            <h3 className="font-semibold mb-1">FAQ</h3>
            <p className="text-sm opacity-70">Common questions</p>
          </Link>
        </div>
      </section>

      {/* Help Section */}
      <section className="ot-card text-center">
        <h3 className="font-semibold mb-3">Need help?</h3>
        <p className="text-sm opacity-80 mb-4">
          If you think this is a mistake or need assistance, please contact us.
        </p>
        <Link 
          href="/support"
          className="inline-block px-6 py-3 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 text-white font-semibold hover:opacity-90 transition-opacity"
        >
          Contact Support
        </Link>
      </section>
    </div>
  );
}

