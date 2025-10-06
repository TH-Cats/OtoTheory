// Scale fit utilities

// 1) PCPベース：録音由来のときに使う（0..100%）
export function fitScaleFromPCP(keyPc: number, scaleMask12: number[], pcp12: number[]): number {
  const rot = (arr: number[], n: number) => arr.map((_, i) => arr[(i - n + 12) % 12]);
  const pcp = rot(pcp12, keyPc);
  const total = pcp.reduce((a, b) => a + b, 0) || 1;
  const inSum = pcp.reduce((s, v, i) => s + (scaleMask12[i] ? v : 0), 0);
  return Math.round((inSum / total) * 100);
}

// 2) Chordsテキスト等の簡易版：音集合の被覆率（0..100%）
export function fitScaleFromTones(scaleMask12: number[], tonePcs: number[]): number {
  const uniq = Array.from(new Set(tonePcs.map(n => ((n % 12) + 12) % 12)));
  const hit = uniq.filter(pc => scaleMask12[pc]).length;
  return Math.round((hit / Math.max(1, uniq.length)) * 100);
}

import { listScales, getScaleMask12 } from "@/lib/scaleCatalog";

export function rankScalesForKey(params:{
  keyPc: number;
  origin: "record"|"manual"|"chords";
  pcp12?: number[] | null;
  tonePcs?: number[];
  limit?: number;
}){
  const { keyPc, origin, pcp12, tonePcs = [], limit } = params;
  // 元に戻す: カタログ全体からランク
  const scales = listScales();
  const items = scales
    .map(s => {
      const mask = getScaleMask12(s.id);
      const degreeCount = mask.reduce((a,b)=> a + (b?1:0), 0);
      // 録音由来のときはヘプタ/ペンタ以外を除外して誤検出を抑制（例：対称型ディミ系）
      if (origin === 'record' && !(degreeCount === 7 || degreeCount === 5)) return null as any;
      const pct = (origin === 'record' && Array.isArray(pcp12) && pcp12.length === 12)
        ? fitScaleFromPCP(keyPc, mask, pcp12 as number[])
        : fitScaleFromTones(mask, tonePcs);
      return { id: s.id, label: s.label, pct };
    })
    .filter(Boolean)
    .sort((a:any,b:any)=> b.pct - a.pct);
  return typeof limit === 'number' ? items.slice(0, limit) : items;
}


