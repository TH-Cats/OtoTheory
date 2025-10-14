// /components/chords/ChordAudio.ts
export class ChordAudio {
  private static ctx: AudioContext | null = null;

  static async ensureStarted() {
    if (!ChordAudio.ctx) {
      ChordAudio.ctx = new (window.AudioContext || (window as any).webkitAudioContext)();
    }
    if (ChordAudio.ctx.state === 'suspended') await ChordAudio.ctx.resume();
  }

  static get context() {
    if (!ChordAudio.ctx) throw new Error('AudioContext not started');
    return ChordAudio.ctx;
  }

  static midiToFreq(midi: number) {
    return 440 * Math.pow(2, (midi - 69) / 12);
  }

  static TUNING = [40, 45, 50, 55, 59, 64];

  static shapeToMidiNotes(frets: (number | 0 | 'x')[]) {
    return frets.map((f, idx) =>
      f === 'x' ? null : typeof f === 'number' ? ChordAudio.TUNING[idx] + f : ChordAudio.TUNING[idx]
    );
  }

  static playNote(midi: number, when: number, duration = 1.15) {
    const ctx = ChordAudio.context;
    try {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      const filt = ctx.createBiquadFilter();

      osc.type = 'triangle';
      filt.type = 'lowpass';
      filt.frequency.value = 2200;

      gain.gain.setValueAtTime(0.0001, when);
      gain.gain.exponentialRampToValueAtTime(0.6, when + 0.006);
      gain.gain.exponentialRampToValueAtTime(0.0001, when + duration);

      osc.frequency.value = ChordAudio.midiToFreq(midi);
      osc.connect(filt).connect(gain).connect(ctx.destination);

      osc.start(when);
      osc.stop(when + duration + 0.05);

      // Cleanup
      const delay = Math.max(0, (when - ctx.currentTime + duration + 0.1) * 1000);
      setTimeout(() => {
        try {
          osc.disconnect();
          gain.disconnect();
          filt.disconnect();
        } catch {}
      }, delay);
    } catch (err) {
      console.error('Audio playback failed:', err);
      throw err;
    }
  }

  static async playShape(frets: (number | 0 | 'x')[], mode: 'strum' | 'arp' = 'strum') {
    await ChordAudio.ensureStarted();
    const ctx = ChordAudio.context;
    const notes = ChordAudio.shapeToMidiNotes(frets)
      .map((midi, idx) => ({ midi, idx }))
      .filter((n) => n.midi !== null) as { midi: number; idx: number }[];

    const start = ctx.currentTime + 0.03;
    const gap = mode === 'strum' ? 0.04 : 0.09;
    const order = mode === 'strum' ? notes : [...notes].reverse();

    order.forEach((n, i) => ChordAudio.playNote(n.midi, start + i * gap, mode === 'strum' ? 1.0 : 0.9));
  }
}



