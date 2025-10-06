export const LITE_MAX = Number(process.env.NEXT_PUBLIC_FREE_CHORD_LIMIT ?? 12);
export const WARN_AT  = Number(process.env.NEXT_PUBLIC_FREE_WARN_START ?? 9);

export type ToastKind = 'limit_warn'|'limit_block'|'undo'|'low_conf';

export function guardAdd(currentLen: number, addLen: number){
  const next = currentLen + addLen;
  if (next > LITE_MAX) {
    return { allow: false as const, kind: 'limit_block' as const, used: currentLen, attempting: addLen, limit: LITE_MAX };
  }
  if (next >= WARN_AT) {
    return { allow: true as const, kind: 'limit_warn' as const, used: next, limit: LITE_MAX };
  }
  return { allow: true as const, kind: null as null, used: next, limit: LITE_MAX };
}

export const TOAST_TEXT = {
  limit_warn : (used:number, limit:number) => `Lite mode: up to ${limit} chords. ${used}/${limit} used.`,
  limit_block: (limit:number) => `Limit reached. Upgrade to Pro to add more than ${limit} chords.`,
  undo       : () => `Last change undone.`,
  low_conf   : () => `Low confidence. Try recording again in a quieter room.`,
};



