import { player } from "@/lib/audio/player";

export async function abPreview(before: number[], after: number[]) {
  await player.resume();
  player.playChord(before, "lightStrum"); await new Promise(r=>setTimeout(r, 450));
  player.playChord(after,  "lightStrum"); await new Promise(r=>setTimeout(r, 600));
  player.playChord(before, "lightStrum"); await new Promise(r=>setTimeout(r, 450));
  player.playChord(after,  "lightStrum");
}






