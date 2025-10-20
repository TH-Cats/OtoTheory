"use client";
import { useEffect, useRef, useState, useLayoutEffect, type ReactNode, cloneElement } from "react";
import { createPortal } from "react-dom";

type Props = {
  text?: string;                    // plain text (optional when using children)
  title?: string;                   // optional title in the card
  children?: ReactNode;             // custom body content
  className?: string;
  linkHref?: string;
  linkLabel?: string;
  ariaLabel?: string;
  icon?: 'info' | 'graduation';    // icon type
  placement?: 'top' | 'bottom';     // popup placement
  trigger?: React.ReactElement;     // custom trigger element (e.g., lightbulb button)
};

export default function InfoDot({
  text,
  title,
  children,
  className = "",
  linkHref,
  linkLabel = "Learn more",
  ariaLabel = "More info",
  icon = 'info',
  placement = 'bottom',
  trigger,
}: Props) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const btnRef = useRef<HTMLElement>(null);
  const [coords, setCoords] = useState<{left:number; top:number; maxW:number}>({left:0, top:0, maxW:320});
  useEffect(() => {
    const onDoc = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    const onEsc = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpen(false);
    };
    document.addEventListener("click", onDoc);
    document.addEventListener("keydown", onEsc);
    return () => {
      document.removeEventListener("click", onDoc);
      document.removeEventListener("keydown", onEsc);
    };
  }, []);
  useLayoutEffect(() => {
    if (!open) return;
    const update = () => {
      if (!btnRef.current) return;
      const r = btnRef.current.getBoundingClientRect();
      const maxW = Math.min(Math.floor(window.innerWidth * 0.9), 360);
      const left = Math.min(window.innerWidth - 8 - maxW, Math.max(8, Math.round(r.right - maxW)));
      const top = placement === 'top' 
        ? Math.round(r.top) // 上部表示時は電球の上端を基準
        : Math.min(window.innerHeight - 8 - 120, Math.round(r.bottom + 6)); // 下部表示
      setCoords({ left, top, maxW });
    };
    update();
    window.addEventListener("resize", update);
    window.addEventListener("scroll", update, true);
    return () => {
      window.removeEventListener("resize", update);
      window.removeEventListener("scroll", update, true);
    };
  }, [open, placement]);

  // trigger があればそれを"正規トリガー"として内包
  const triggerEl = trigger
    ? cloneElement(trigger, {
        ref: (el: HTMLElement) => { btnRef.current = el; },
        onClick: (e: any) => { e.stopPropagation(); setOpen(v => !v); },
        'aria-label': ariaLabel
      })
    : (
      <button
        ref={btnRef as any}
        onClick={(e) => { e.stopPropagation(); setOpen(v => !v); }}
        className="info-dot"
        aria-label={ariaLabel}
      >
        {icon === 'graduation' ? (
          <svg className="w-3 h-3" viewBox="0 0 24 24" fill="currentColor">
            <path d="M5 13.18v4L12 21l7-3.82v-4L12 17l-7-3.82zM12 3L1 9l11 6 9-4.91V17h2V9L12 3z"/>
          </svg>
        ) : (
          'i'
        )}
      </button>
    );

  return (
    <div ref={ref} className={`relative inline-flex items-center ${className}`}>
      {triggerEl}
      {open && createPortal(
        (
          <div
            role="dialog"
            className="info-card"
            style={{
              position: "fixed",
              zIndex: 60,
              left: `${coords.left}px`,
              top: `${coords.top}px`,
              maxWidth: `${coords.maxW}px`,
              // 上側表示は transform で安定して持ち上げる
              transform: placement === 'top' ? 'translateY(-100%) translateY(-8px)' : 'none'
            }}
            onClick={(e) => e.stopPropagation()}
          >
            {title && <div className="font-medium mb-1">{title}</div>}
            {children ? (
              children
            ) : (
              (text ?? "").split("\n").map((line, i) => <div key={i}>{line}</div>)
            )}
            {linkHref && (
              <div className="mt-2 text-right">
                <a href={linkHref} className="underline text-[12px] opacity-80">
                  {linkLabel}
                </a>
              </div>
            )}
          </div>
        ),
        document.body
      )}
    </div>
  );
}


