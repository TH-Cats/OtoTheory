"use client";

import { useEffect, useRef, useState } from "react";
import { track } from "@/lib/telemetry";
import { player } from "@/lib/audio/player";

export default function AudioUnlocker() {
  const [unlocked, setUnlocked] = useState(false);
  const lockedRef = useRef(true);

  useEffect(() => {
    if (unlocked) return;

    const tryUnlock = async () => {
      if (!lockedRef.current) return;
      lockedRef.current = false;
      try {
        track("audio_unlock_try", {});
        await player.resume?.();
        setUnlocked(true);
        track("audio_unlock_ok", {});
      } catch (e) {
        lockedRef.current = true;
        track("audio_unlock_err", { message: (e as Error)?.message ?? "unknown" });
      }
    };

    const opts: AddEventListenerOptions = { once: true, capture: true };
    const w = window;

    w.addEventListener("pointerdown", tryUnlock, opts);
    w.addEventListener("keydown", tryUnlock, opts);
    w.addEventListener("touchstart", tryUnlock, opts);

    const onVisibility = () => {
      if (document.visibilityState === "visible" && !unlocked) {
        lockedRef.current = true;
      }
    };
    document.addEventListener("visibilitychange", onVisibility);

    return () => {
      w.removeEventListener("pointerdown", tryUnlock, opts);
      w.removeEventListener("keydown", tryUnlock, opts);
      w.removeEventListener("touchstart", tryUnlock, opts);
      document.removeEventListener("visibilitychange", onVisibility);
    };
  }, [unlocked]);

  return null;
}


