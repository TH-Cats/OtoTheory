import { useRef, useState } from 'react';

export function useUndoOne<T>(initial: T){
  const [state, setStateInner] = useState<T>(initial);
  const prevRef = useRef<T | null>(null);

  function commit(next: T){
    prevRef.current = state;
    setStateInner(next);
  }

  function undo(): { ok: boolean; value: T }{
    if (prevRef.current === null) return { ok: false, value: state };
    const val = prevRef.current;
    prevRef.current = null;
    setStateInner(val);
    return { ok: true, value: val };
  }

  return { state, setState: commit, undo } as const;
}



