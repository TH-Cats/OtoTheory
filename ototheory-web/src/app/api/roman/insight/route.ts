import { NextResponse } from "next/server";

export async function POST(req: Request) {
  const body = await req.json().catch(()=>({}));
  const { key, mode, romanLine, patterns = [], cadences = [] } = body ?? {};
  const paras: string[] = [];
  if (Array.isArray(patterns) && patterns.length) {
    paras.push(`Detected patterns: ${patterns.map((p:any)=>p?.name ?? p?.id ?? '').filter(Boolean).join(', ')}.`);
  }
  if (Array.isArray(cadences) && cadences.length) {
    paras.push(`Cadences: ${cadences.map((c:any)=>c?.label ?? c?.id ?? '').filter(Boolean).join(', ')}.`);
  }
  if (Array.isArray(romanLine)) {
    paras.push(`Roman: ${romanLine.join(' – ')}.`);
  }
  paras.push(`In ${key ?? ''} ${mode ?? ''}, consider ii–V–I or a deceptive cadence (V–vi) to extend the phrase.`);
  return NextResponse.json({ paragraphs: paras });
}















