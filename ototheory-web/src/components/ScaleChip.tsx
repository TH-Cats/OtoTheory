"use client";

type Props = { label: string; score: number; size?: 'sm' | 'md' };
export default function ScaleChip({ label, score, size = 'md' }: Props) {
  const s = Math.max(0, Math.min(100, Math.round(score)));
  const color = s < 40 ? 'bg-red-500' : s < 70 ? 'bg-amber-500' : 'bg-emerald-500';
  return (
    <li
      className={["chip", size === 'sm' ? 'chip--sm' : ''].join(' ')}
      role="progressbar"
      aria-label={label}
      aria-valuemin={0}
      aria-valuemax={100}
      aria-valuenow={s}
    >
      <span>{label}</span>
      <span className="chip-pct">{s}%</span>
      <span className="chip-meter" aria-hidden="true">
        <span className={["chip-meter-fill", color].join(' ')} style={{ width: `${s}%` }} />
      </span>
    </li>
  );
}


