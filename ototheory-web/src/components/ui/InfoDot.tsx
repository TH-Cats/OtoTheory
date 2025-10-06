"use client";
import { useEffect, useRef, useState, useLayoutEffect, type ReactNode } from "react";
import { createPortal } from "react-dom";

type Props = {
  text?: string;                    // plain text (optional when using children)
  title?: string;                   // optional title in the card
  children?: ReactNode;             // custom body content
  className?: string;
  linkHref?: string;
  linkLabel?: string;
  ariaLabel?: string;
};

export default function InfoDot({
  text,
  title,
  children,
  className = "",
  linkHref,
  linkLabel = "Learn more",
  ariaLabel = "More info",
}: Props) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const btnRef = useRef<HTMLButtonElement>(null);
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
      const top = Math.min(window.innerHeight - 8 - 120, Math.round(r.bottom + 6));
      setCoords({ left, top, maxW });
    };
    update();
    window.addEventListener("resize", update);
    window.addEventListener("scroll", update, true);
    return () => {
      window.removeEventListener("resize", update);
      window.removeEventListener("scroll", update, true);
    };
  }, [open]);

  return (
    <div ref={ref} className={`relative inline-flex items-center ${className}`}>
      <button ref={btnRef} type="button" className="info-dot" aria-label={ariaLabel} onClick={() => setOpen((o) => !o)}>
        i
      </button>
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
            }}
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


