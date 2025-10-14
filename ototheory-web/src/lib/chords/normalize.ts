import { ChordSpec, ChordContext } from './types';

export function normalizeChordSpec(input: ChordSpec, ctx: ChordContext, options: {autoCorrect11th?: boolean} = {}){
  const spec: ChordSpec = JSON.parse(JSON.stringify(input));
  const warnings: string[] = [];

  // dom は 7th 前提
  if (spec.family === 'dom') spec.seventh = '7';

  // Pro gating
  if (ctx.plan === 'free') {
    // Pro: Tension, Alter, 6/9, /bass をロック
    if (spec.extMode === 'tension') spec.ext = { nine:false, eleven:false, thirteen:false };
    spec.alt = {};
    // 6/9 は Pro 専用（6 と add9 の同時→6/9 変換を禁止）
    // slash も禁止
    if (spec.slash) spec.slash = null;
  }

  // Add/Tension 排他
  if (spec.extMode === 'add') {
    spec.ext.nine = spec.ext.eleven = spec.ext.thirteen = false;
  } else {
    spec.ext.add9 = spec.ext.add11 = spec.ext.add13 = false;
  }

  // 13 は 9 を内包
  if (spec.ext.thirteen) spec.ext.nine = true;

  // sus2/sus4 相互排他（後勝ち）
  if (spec.sus === 'sus2' && input.sus === 'sus4') spec.sus = 'sus4';
  if (spec.sus === 'sus4' && input.sus === 'sus2') spec.sus = 'sus2';

  // maj/dom の 11 は回避警告（オプションで自動是正）
  if (spec.ext.eleven) {
    if (spec.family === 'maj') {
      if (options.autoCorrect11th) {
        // 自動是正: 11 → #11 (Lydian)
        spec.ext.eleven = false;
        if (spec.alt) {
          spec.alt.sharpEleven = true;
        } else {
          spec.alt = { sharpEleven: true };
        }
        warnings.push('11 → #11 に自動調整しました（メジャーではavoid音のため）。');
      } else {
        warnings.push('メジャーでの11は3度と濁ります。#11（Lydian）を検討してください。');
      }
    }
    if (spec.family === 'dom') {
      if (options.autoCorrect11th) {
        // 自動是正: 11 → #11 または sus4 の提案（ここでは#11を選択）
        spec.ext.eleven = false;
        if (spec.alt) {
          spec.alt.sharpEleven = true;
        } else {
          spec.alt = { sharpEleven: true };
        }
        warnings.push('11 → #11 に自動調整しました（ドミナントでは3度と衝突するため）。');
      } else {
        warnings.push('ドミナントでの11は3度と衝突します。#11 または sus4 を検討してください。');
      }
    }
  }

  // 非 dom で Alterations は無効
  if (spec.family !== 'dom') spec.alt = {};

  // maj7 + sus は既定で無効
  if (spec.seventh === 'maj7' && spec.sus) {
    warnings.push('maj7 with sus is uncommon; use sus4(maj7) in advanced mode.');
    spec.sus = null;
  }

  // Tension は 7th を持つ時のみ活性
  if (spec.extMode === 'tension' && !['7','maj7','m7'].includes(spec.seventh)) {
    spec.ext = { nine:false, eleven:false, thirteen:false };
  }

  return { spec, warnings } as const;
}



