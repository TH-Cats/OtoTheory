import { ChordSpec, ChordContext } from './types';

export function formatChordSymbol(s: ChordSpec, ctx: ChordContext): string {
  const parts: string[] = [s.root];

  // family: output english by default
  const fam =
    s.family === 'maj' ? '' :
    s.family === 'min' ? 'm' :
    s.family === 'dom' ? '' :
    s.family === 'sus' ? 'sus' :
    s.family === 'dim' ? 'dim' :
    s.family === 'aug' ? 'aug' : '5';
  parts.push(fam);

  // seventh
  const sev =
    s.seventh === 'maj7' ? (ctx.notationStyle==='compact' ? 'M7' : 'maj7') :
    s.seventh === '7'    ? '7' :
    s.seventh === 'm7'   ? 'm7' :
    s.seventh === '6'    ? '6' :
    s.seventh === 'm7b5' ? 'm7b5' :
    s.seventh === 'dim7' ? 'dim7' : '';
  parts.push(sev);

  // extensions
  if (s.extMode === 'tension') {
    if (s.ext.thirteen) parts.push('13');
    else if (s.ext.eleven) parts.push('11');
    else if (s.ext.nine) parts.push('9');
  } else {
    const adds = [s.ext.add9 && 'add9', s.ext.add11 && 'add11', s.ext.add13 && 'add13'].filter(Boolean) as string[];
    if (adds.length) parts.push(`(${adds.join(',')})`);
  }

  // alterations
  const alt = [s.alt.b9 && 'b9', s.alt.s9 && '#9', s.alt.s11 && '#11', s.alt.b13 && 'b13']
    .filter(Boolean).join('');
  parts.push(alt);

  // sus
  if (s.sus) parts.push(s.sus);

  // /bass
  if (s.slash) parts.push(`/${s.slash}`);

  return parts.join('');
}



