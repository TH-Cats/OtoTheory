export type ToastKind = "limit_warn" | "limit_block" | "undo" | "low_conf";

export type OverlayTelemetry = {
  control: string;
  open?: boolean;
  value?: string | number;
  page?: string;
};

export type CtaPlace = "header" | "sticky" | "limit_toast" | "png_toast" | "qr";

export type OtEvent =
  | "page_view"
  | "scale_pick"
  | "key_pick"
  | "diatonic_pick"
  | "overlay_reset"
  | "fb_toggle"
  | "overlay_shown"
  | "play_note"
  | "play_chord"
  | "progression_play"
  | "export_png"
  | "save_project"
  | "open_project"
  | "project_delete"
  | "preset_inserted"
  | "instrument_change"
  | "project_limit_warn"
  | "audio_record_start"
  | "audio_record_stop"
  | "audio_analyze_ok"
  | "audio_playback_last_take"
  | "audio_analyze_conf"
  | "audio_analyze_err"
  | "toast_shown"
  | "audio_unlock_try"
  | "audio_unlock_ok"
  | "audio_unlock_err"
  | "ad_shown"
  | "scale_arpeggio_play"
  | "chord_form_shown"
  | "substitute_shown"
  | "substitute_add"
  | "cta_appstore_click";

type TelemetryPayload =
  | { ev: "toast_shown"; kind: ToastKind }
  | { ev: "overlay_shown"; control: string; open?: boolean; value?: string | number; page?: string }
  | { ev: "ad_shown"; page: string }
  | { ev: "audio_unlock_try" }
  | { ev: "audio_unlock_ok" }
  | { ev: "audio_unlock_err"; message: string }
  | { ev: OtEvent; [key: string]: unknown };

// 二重発火対策用のキュー
let eventQueue: Set<string> = new Set();

// ページ名正規化マッピング（旧名 → 新名、互換性確保のため90日程度保持）
const PAGE_NAME_MAP: Record<string, string> = {
  "progression": "chord_progression",
  "find-key": "chord_progression",
  "find-key-scale": "chord_progression",
  "find-chord": "find_chords",
  "analyze": "melody_solo_analyze",
};

// ページ名正規化関数
const normalizePageName = (page: string): string => {
  return PAGE_NAME_MAP[page] || page;
};

export function track(ev: OtEvent, payload: Record<string, unknown> = {}) {
  const base: Record<string, unknown> = {
    page: normalizePageName(payload.page as string || "analyze"), // payloadで指定がない場合はanalyze、正規化適用
    keyPc: (typeof window!=="undefined" && (window as any).__OT_STATE__?.keyPc) ?? undefined,
    scaleId: (typeof window!=="undefined" && (window as any).__OT_STATE__?.scaleId) ?? undefined,
    page_language: (typeof window!=="undefined" && window.location?.pathname?.startsWith?.("/ja")) ? "ja" : "en",
    ts: Date.now(),
  };
  const rec: Record<string, unknown> = { ev, ...base, ...payload };

  // 二重発火対策（同tick同名は1回のみ）
  const eventKey = `${ev}:${performance.now().toFixed(0)}`;
  if (eventQueue.has(eventKey)) return;
  eventQueue.add(eventKey);
  setTimeout(() => eventQueue.delete(eventKey), 0);

  try {
    if (typeof navigator !== "undefined" && "sendBeacon" in navigator) {
      const blob = new Blob([JSON.stringify(rec)], { type: "application/json" });
      (navigator as any).sendBeacon?.("/api/telemetry", blob);
    } else if (typeof fetch !== "undefined") {
      fetch("/api/telemetry", {
        method: "POST",
        body: JSON.stringify(rec),
        headers: { "content-type": "application/json" },
        keepalive: true,
      }).catch(() => {});
    }
  } catch {}
  try {
    if (typeof localStorage !== "undefined" && localStorage.getItem("ot-debug-telemetry") === "1") {
      console.log("[ototelem]", rec);
    } else {
      console.debug?.("[ototelem]", rec);
    }
  } catch {}
}

export function trackToast(kind: ToastKind, extra: Record<string, unknown> = {}) {
  track("toast_shown", { kind, ...extra });
}

export function trackOverlayShown(payload: OverlayTelemetry) {
  track("overlay_shown", payload);
}

// M3.5: Web→iOS送客計測
export function trackCtaClick(place: CtaPlace, extra: Record<string, unknown> = {}) {
  track("cta_appstore_click", { place, ...extra });
}


