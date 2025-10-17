import type { Metadata } from 'next';
import Client from './Client';
import { ChordLibraryStructuredData } from '@/components/StructuredData';

export const metadata: Metadata = {
  title: 'Guitar Chord Library – Forms & Fingering | OtoTheory',
  description:
    'Interactive chord diagrams with finger numbers, strum/arpeggio preview, and compare mode for guitarists.',
  alternates: { canonical: '/chord-library' },
  openGraph: {
    title: 'Guitar Chord Library – OtoTheory',
    description:
      'Visual diagrams, audio preview, concise tips. Learn multiple forms per chord with swipe/compare view.',
    url: '/chord-library',
    type: 'website',
  },
};

export default function Page() {
  return (
    <>
      <ChordLibraryStructuredData />
      <Client />
    </>
  );
}

