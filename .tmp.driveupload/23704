import Link from 'next/link';

export default function ResourcesPage() {
  return (
    <div className="ot-page ot-stack">
      <h1 className="text-xl font-semibold">Resources</h1>
      
      <p className="text-sm text-black/70 dark:text-white/70">
        Essential guitar theory resources, terminology, and references for musicians.
      </p>

      {/* Main Resource Cards */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {/* Learn Music Theory */}
        <Link 
          href="/resources/learn"
          className="group rounded-lg border p-5 hover:border-blue-500 dark:hover:border-blue-400 transition-all hover:shadow-lg"
        >
          <div className="flex items-start gap-3 mb-3">
            <span className="text-2xl">🎵</span>
            <h2 className="text-lg font-semibold group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">
              Learn Music Theory
            </h2>
          </div>
          <p className="text-sm text-black/70 dark:text-white/70 leading-relaxed">
            Turn your musical instinct into understanding. Learn the fundamentals through practical examples and real-world applications.
          </p>
          <div className="mt-3 text-sm text-blue-600 dark:text-blue-400 group-hover:underline">
            Start learning →
          </div>
        </Link>

        {/* Coming Soon - Artist Lab */}
        <div 
          className="group rounded-lg border p-5 border-gray-300 dark:border-gray-600 opacity-75"
        >
          <div className="flex items-start gap-3 mb-3">
            <span className="text-2xl">🎸</span>
            <h2 className="text-lg font-semibold text-gray-600 dark:text-gray-400">
              Artist Lab
            </h2>
          </div>
          <p className="text-sm text-gray-500 dark:text-gray-500 leading-relaxed">
            Analyze famous songs through music theory. Learn from The Beatles, Rolling Stones, and more.
          </p>
          <div className="mt-3 text-sm text-gray-500 dark:text-gray-500">
            Coming Soon
          </div>
        </div>

        {/* Coming Soon - Training */}
        <div 
          className="group rounded-lg border p-5 border-gray-300 dark:border-gray-600 opacity-75"
        >
          <div className="flex items-start gap-3 mb-3">
            <span className="text-2xl">🏃‍♂️</span>
            <h2 className="text-lg font-semibold text-gray-600 dark:text-gray-400">
              Training
            </h2>
          </div>
          <p className="text-sm text-gray-500 dark:text-gray-500 leading-relaxed">
            10-minute drills for ear training, interval recognition, and improvisation practice.
          </p>
          <div className="mt-3 text-sm text-gray-500 dark:text-gray-500">
            Coming Soon
          </div>
        </div>
      </div>
    </div>
  );
}

