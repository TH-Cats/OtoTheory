import { redirect } from 'next/navigation';

// M3.5: Analyze (録音) メニュー撤去
// Flag OFF方針と一致、/find-key（Chord Progression）へリダイレクト
export default function AnalyzePage() {
  redirect('/find-key');
}
