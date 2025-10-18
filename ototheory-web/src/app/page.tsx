import { WebApplicationStructuredData, OrganizationStructuredData } from "@/components/StructuredData";
import AdSlot from "@/components/AdSlot.client";
import FeatureCard from "@/components/FeatureCard";
import { 
  MusicalNoteIcon, 
  MagnifyingGlassIcon, 
  BookOpenIcon, 
  AcademicCapIcon, 
  DocumentTextIcon 
} from "@heroicons/react/24/outline";

export default function Home() {
  return (
    <>
      <WebApplicationStructuredData 
        name="OtoTheory"
        description="Free guitar chord finder, key analyzer, and music theory tool. Build chord progressions, discover scales, and support composition and guitar improvisation theoretically."
        url="https://www.ototheory.com"
      />
      <OrganizationStructuredData />
      <main className="ot-page ot-stack">
      <section className="ot-card text-white" style={{background: 'linear-gradient(90deg, var(--brand-primary), var(--brand-secondary))'}}>
        <h1 className="text-2xl font-semibold">OtoTheory</h1>
        <p className="opacity-90">Use Theory Without Tears</p>
      </section>
      <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {/* Top row - 3 cards */}
        <div className="lg:col-span-1">
          <FeatureCard
            href="/chord-progression"
            icon={<MusicalNoteIcon />}
            title="Chord Progression"
            catchphrase="Create — and let theory click."
            description={[
              "Analyze your chord progressions and discover better paths.",
              "Explore scales and harmonies that fit your sound.",
              "Composition and practice become a natural theory lesson."
            ]}
          />
        </div>
        
        <div className="lg:col-span-1">
          <FeatureCard
            href="/find-chords"
            icon={<MagnifyingGlassIcon />}
            title="Find Chords"
            catchphrase="Find chords through scales — and train your ear."
            description={[
              "Pick a key and scale to reveal chords instantly.",
              "See them on the fretboard, hear them in context.",
              "Learn scale harmony by sound and intuition."
            ]}
          />
        </div>

        <div className="lg:col-span-1">
          <FeatureCard
            href="/chord-library"
            icon={<BookOpenIcon />}
            title="Chord Library"
            catchphrase="The chord library that plays back and teaches."
            description={[
              "Explore every major, minor, and seventh chord.",
              "See how finger shapes connect to intervals and sound.",
              "Learn guitar chords visually and by ear."
            ]}
          />
        </div>

        {/* Bottom row - 2 cards centered */}
        <div className="lg:col-start-2 lg:col-span-1">
          <FeatureCard
            href="/resources"
            icon={<AcademicCapIcon />}
            title="Resources"
            catchphrase="Refresh your music theory in a minute."
            description={[
              "Review Diatonic, Modes, and Cadence with clear visuals.",
              "A concise theory guide and glossary for quick recall.",
              "Your go-to resource for songwriting inspiration."
            ]}
          />
        </div>

        <div className="lg:col-span-1">
          <FeatureCard
            href="/chord-progression"
            icon={<DocumentTextIcon />}
            title="My Sketches"
            catchphrase="Capture your chord ideas in seconds."
            description={[
              "Save your chord progressions as sketches.",
              "Free users get 3 local saves; Pro syncs unlimited to the cloud.",
              "Reopen and loop instantly—never lose inspiration."
            ]}
          />
        </div>
      </section>
      <div className="ot-card">
        <AdSlot page="home" format="horizontal" />
      </div>
    </main>
    </>
  );
}
