export function formatCapoPrimaryLabel(capo: number, shaped: string) {
  if (capo === 0) return `Open (no capo) · Play as ${shaped}`;
  return `Capo ${capo} · Play as ${shaped}`;
}
export function formatCapoAltLabel(capo: number, shaped: string) {
  if (capo === 0) return `Open · ${shaped}`;
  return `Capo ${capo} · ${shaped}`;
}










