import { track as tel } from '@/lib/telemetry';

const COUNTIN = Number(process.env.NEXT_PUBLIC_COUNTIN_BEATS ?? 4);

export type PlayOpts = { bpm: number; loop?: boolean; source?: 'user'|'preset' };

export async function playProgression(chords: string[], opts: PlayOpts){
  const { bpm, loop = true, source = 'user' } = opts;
  const beatSec = 60 / Math.max(30, Math.min(300, bpm));
  await countIn(COUNTIN, beatSec);
  tel('progression_play', { count: chords.length, bpm, source });
  do {
    for (const ch of chords) {
      await playChordStub(ch, beatSec);
    }
  } while (loop);
}

async function countIn(beats: number, beatSec: number){
  for (let i=0;i<beats;i++) await wait(beatSec);
}
async function playChordStub(_ch: string, beatSec: number){
  await wait(beatSec);
}
function wait(sec: number){ return new Promise(r=>setTimeout(r, Math.max(10, sec*1000))); }



