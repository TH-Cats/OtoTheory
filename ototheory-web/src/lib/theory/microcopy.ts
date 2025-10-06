export function oneLiner(
  kind: 'function'|'tritone'|'borrowed'|'secondary',
  roman: string | null,
  to: string,
  mode: 'major'|'minor'
): string {
  const map = {
    function:  (r: string | null) => `役割は同じ。色を変えて${r ?? '主'}の流れを保つ。Try：${to}。着地は3rd/7th。`,
    tritone:   () => `Vの代わりに緊張→解決を強く。Try：${to}。着地は3rd。`,
    borrowed:  () => `となりの色味を一瞬借りて陰影。Try：${to}。着地は3rd/7th。`,
    secondary: () => `次の和音へ引っぱる助走。Try：${to}。着地は目標3rd。`,
  } as const;
  const s = map[kind](roman);
  return s.length > 42 ? s.slice(0, 42) : s;
}





