"use client";

import { useEffect, useState } from "react";
import { track } from "@/lib/telemetry";
import { usePro } from "@/components/ProProvider";

export default function AdSlot({ page }: { page: string }) {
  const { isPro } = usePro();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    if (!mounted || isPro) return;
    track("ad_shown", { page });
  }, [mounted, isPro, page]);

  if (isPro) {
    return null;
  }

  return (
    <div style={{ minHeight: 110 }} aria-label="Advertisement placeholder">
      {mounted ? (
        <div id="ad-container" role="complementary">
          {/* TODO: insert ad SDK */}
          <div className="ot-ad-placeholder">Ad Placeholder</div>
        </div>
      ) : null}
    </div>
  );
}
