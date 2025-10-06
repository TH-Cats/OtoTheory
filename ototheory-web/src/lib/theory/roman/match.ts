import { PATTERNS } from "./patterns";

export function normalizeRomanToken(tok: string): string {
  const t = (tok || "").toString().trim().toUpperCase();
  // Remove qualities/extensions, keep degree with optionally B/#
  return t
    .replace(/MAJ7|M7|7|MAJ|MIN|MI|DIM|AUG|SUS\d?|ADD\d+|Ø|O/g, "")
    .replace(/\(|\)/g, "")
    .replace(/[^IVB#]+/g, "")
    .replace(/B/g, "B");
}

export type Match = {
  id: string; name: string; summary: string;
  start: number; end: number; // [start, end)
};

export function matchPatterns(
  romanLine: string[], mode: 'major'|'minor'
): Match[] {
  const rom = romanLine.map(normalizeRomanToken);
  const hits: Match[] = [];

  for (const p of PATTERNS) {
    const seqs = [p.seq, ...(p.variants ?? [])].map(s => s.map(normalizeRomanToken));
    for (const seq of seqs) {
      const L = seq.length;
      // slide over roman tokens
      for (let i = 0; i + L <= rom.length; i++) {
        let ok = true;
        for (let k = 0; k < L; k++) {
          if (rom[i + k] !== seq[k]) { ok = false; break; }
        }
        if (ok) {
          hits.push({ id: p.id, name: p.name, summary: p.tooltip, start: i, end: i + L });
          break; // prefer first longest match for this pattern
        }
      }
    }
  }
  hits.sort((a,b)=> (b.end-b.start)-(a.end-a.start));
  return dedupe(hits);
}

function dedupe(xs: Match[]): Match[] {
  const res: Match[] = [];
  for (const m of xs) {
    if (res.some(r => !(m.end <= r.start || r.end <= m.start))) continue;
    res.push(m);
  }
  return res;
}


