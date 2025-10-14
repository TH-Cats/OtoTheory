'use client';

export function H2({
  children,
  className = '',
  right,
  as: Tag = 'h2',
}: {
  children: React.ReactNode;
  className?: string;
  right?: React.ReactNode;
  as?: keyof JSX.IntrinsicElements;
}) {
  return (
    <div className={`mb-2 flex items-center gap-2 ${className}`}>
      <Tag className="text-xl md:text-2xl font-semibold tracking-tight text-foreground">
        {children}
      </Tag>
      {right ? <div className="ml-auto">{right}</div> : null}
    </div>
  );
}

export function H3({
  children,
  className = '',
  right,
  as: Tag = 'h3',
}: {
  children: React.ReactNode;
  className?: string;
  right?: React.ReactNode;
  as?: keyof JSX.IntrinsicElements;
}) {
  return (
    <div className={`mb-1.5 flex items-center gap-2 ${className}`}>
      <Tag className="text-sm md:text-base font-semibold tracking-wide text-foreground">
        {children}
      </Tag>
      {right ? (
        <div className="ml-auto text-xs md:text-sm text-muted-foreground">{right}</div>
      ) : null}
    </div>
  );
}















