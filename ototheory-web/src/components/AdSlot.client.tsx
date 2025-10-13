"use client";

import { useEffect, useState } from "react";
import { track } from "@/lib/telemetry";
import { usePro } from "@/components/ProProvider";

interface AdSlotProps {
  page: string;
  slot?: string; // AdSense広告スロットID（オプション）
  format?: "auto" | "rectangle" | "horizontal" | "vertical";
  style?: React.CSSProperties;
}

export default function AdSlot({ 
  page, 
  slot = "XXXXXXXXXX", // デフォルトの広告スロットID
  format = "auto",
  style = {}
}: AdSlotProps) {
  const { isPro } = usePro();
  const [mounted, setMounted] = useState(false);
  const [adLoaded, setAdLoaded] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    if (!mounted || isPro) return;

    // AdSenseの広告をロード
    try {
      // @ts-ignore
      if (window.adsbygoogle && !adLoaded) {
        // @ts-ignore
        (window.adsbygoogle = window.adsbygoogle || []).push({});
        setAdLoaded(true);
        track("ad_shown", { page });
      }
    } catch (error) {
      console.error("AdSense load error:", error);
    }
  }, [mounted, isPro, page, adLoaded]);

  if (isPro) {
    return null;
  }

  return (
    <div 
      style={{ minHeight: 110, ...style }} 
      aria-label="Advertisement"
      className="ad-container"
    >
      {mounted ? (
        <ins
          className="adsbygoogle"
          style={{ display: "block", ...style }}
          data-ad-client="ca-pub-XXXXXXXXXXXXXXXXX" // ここにあなたのAdSenseパブリッシャーIDを入力
          data-ad-slot={slot}
          data-ad-format={format}
          data-full-width-responsive="true"
        />
      ) : null}
    </div>
  );
}
