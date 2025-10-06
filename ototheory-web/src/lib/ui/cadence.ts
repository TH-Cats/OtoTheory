export type CadenceType = 'perfect' | 'deceptive' | 'half' | null;

export function formatCadenceLabel(
  t: CadenceType,
  tailRoman?: { from?: string; to?: string }
): string {
  if (!t) return 'Cadence: —';
  if (t === 'perfect')   return `Cadence: Perfect (${tailRoman?.from ?? 'V'} → ${tailRoman?.to ?? 'I'})`;
  if (t === 'deceptive') return `Cadence: Deceptive (${tailRoman?.from ?? 'V'} → ${tailRoman?.to ?? 'vi'})`;
  // half cadence ends on V
  return `Cadence: Half (${tailRoman?.from ? `${tailRoman.from} → ` : '… → '}V)`;
}

export function cadenceTooltip(t: CadenceType): string {
  if (!t) return 'No cadence detected.';
  if (t === 'perfect')   return 'Resolves to the Tonic: V → I. Feels fully resolved.';
  if (t === 'deceptive') return 'Surprises by avoiding I: V → vi (or similar).';
  return 'Phrase ends on the Dominant: … → V. Feels unresolved.';
}

// Short inline label for Roman box
export function formatCadenceShort(
  t: CadenceType,
  tail?: { from?: string; to?: string }
): string {
  if (!t) return '';
  if (t === 'perfect')   return `Perfect (${tail?.from ?? 'V'} → ${tail?.to ?? 'I'})`;
  if (t === 'deceptive') return `Deceptive (${tail?.from ?? 'V'} → ${tail?.to ?? 'vi'})`;
  return `Half (${tail?.from ? `${tail.from} → ` : '… → '}V)`;
}


