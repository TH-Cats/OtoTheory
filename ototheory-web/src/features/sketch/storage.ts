// src/features/sketch/storage.ts
import { Sketch } from '@/types/sketch';

const KEY = 'ot_sketches';
const FREE_LIMIT = 3;

export const loadAll = (): Sketch[] =>
  JSON.parse(localStorage.getItem(KEY) || '[]');

export const saveLocalFree = (sk: Sketch): { ok: boolean; reason?: string } => {
  const list = loadAll().filter(s => s.id !== sk.id);
  list.unshift(sk); // 先頭が最新
  if (list.length > FREE_LIMIT) {
    // LRU超過 → Pro誘導
    localStorage.setItem(KEY, JSON.stringify(list.slice(0, FREE_LIMIT)));
    return { ok: false, reason: 'limit_exceeded' };
  }
  localStorage.setItem(KEY, JSON.stringify(list));
  return { ok: true };
};

// Pro同期はスケルトン（実装済みAPIがあれば差し替え）
export const saveCloudPro = async (sk: Sketch) => {
  // await fetch('/api/sketch', { method:'POST', body: JSON.stringify(sk) })
  return { ok: true };
};

// Free/Proの境界はSSOTの通り。保存/呼び出し/自動保存の3点がM1の核。
