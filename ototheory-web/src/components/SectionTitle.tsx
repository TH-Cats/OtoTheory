'use client';
export default function SectionTitle({
  children,
  right,
  className = ''
}: { children: React.ReactNode; right?: React.ReactNode; className?: string }) {
  return (
    <div className={`mb-1 flex items-center gap-2 ${className}`}>
      <h3 className="text-sm font-semibold tracking-wide text-foreground">{children}</h3>
      <div className="ml-auto text-xs text-muted-foreground">{right}</div>
    </div>
  );
}










