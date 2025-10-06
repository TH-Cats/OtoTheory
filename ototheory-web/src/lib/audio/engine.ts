import { player, type PlayStyle } from './player';

export const unlock = async () => {
  await player.resume();
};

export const playNote = async (freq: number, when = 0) => {
  await player.resume();
  player.playNote(60 + freq, 100); // 100ms duration
};

export const playChord = async (freqs: number[]) => {
  await player.resume();
  player.playChord(freqs.slice(0, 6), 'lightStrum', 200);
};
