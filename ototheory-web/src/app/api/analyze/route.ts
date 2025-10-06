import { NextRequest, NextResponse } from "next/server";

export const runtime = "nodejs";

type AnalyzeReq = {
  pcp12: number[];
  lengthSec?: number;
  snrHint?: number;
};

type Candidate = { keyPc: 0|1|2|3|4|5|6|7|8|9|10|11; mode: "major"|"minor"; score: number };

const LOW  = Number(process.env.CONF_THRESHOLD_LOW  ?? 0.58);
const HIGH = Number(process.env.CONF_THRESHOLD_HIGH ?? 0.85);
const LEN_GAIN    = Number(process.env.CONF_LEN_GAIN    ?? 0.03);
const SNR_GAIN    = Number(process.env.CONF_SNR_GAIN    ?? 0.03);
const SNR_PENALTY = Number(process.env.CONF_SNR_PENALTY ?? 0.08);

function normalizePCP12(raw: unknown): number[] | null {
  if (!Array.isArray(raw) || raw.length !== 12) return null;
  const clipped = raw.map(v => (Number.isFinite(v as number) ? Math.max(0, Number(v)) : NaN));
  if (clipped.some(v => !Number.isFinite(v))) return null;
  const sum = clipped.reduce((s, v) => s + v, 0);
  if (sum <= 0) return null;
  const norm = clipped.map(v => v / sum);
  if (norm.some(v => !Number.isFinite(v))) return null;
  return norm;
}

const DEG_MAJ = [0,2,4,5,7,9,11];
const DEG_MIN = [0,2,3,5,7,8,10];

function rotateMask(deg: number[], shift: number) {
  return deg.map(d => (d + shift) % 12);
}

function voteKeys(pcp12: number[]): Candidate[] {
  const score = (mask: number[]) => mask.reduce((s, ix) => s + pcp12[ix], 0);
  const majors: Candidate[] = Array.from({ length: 12 }, (_, k) => ({
    keyPc: k as Candidate["keyPc"],
    mode: "major" as const,
    score: score(rotateMask(DEG_MAJ, k)),
  }));
  const minors: Candidate[] = Array.from({ length: 12 }, (_, k) => ({
    keyPc: k as Candidate["keyPc"],
    mode: "minor" as const,
    score: score(rotateMask(DEG_MIN, k)),
  }));
  return [...majors, ...minors].sort((a,b)=> b.score-a.score).slice(0,3);
}

function synthesizeConf(top3: Candidate[], opts?: { lengthSec?: number; snrHint?: number }) {
  const s1 = top3[0]?.score ?? 0;
  const s2 = top3[1]?.score ?? 0;
  const s3 = top3[2]?.score ?? 0;
  let sum = s1 + s2 + s3;
  if (!Number.isFinite(sum) || sum <= 0) {
    return { conf: 0, level: "low" as const, candidates: top3.map(t => ({ keyPc: t.keyPc, mode: t.mode, confidence: 0 })) };
  }
  let conf = s1 / sum;
  if (typeof opts?.lengthSec === "number") {
    if (opts.lengthSec >= 6 && opts.lengthSec <= 14) conf += LEN_GAIN;
  }
  if (typeof opts?.snrHint === "number") {
    if (opts.snrHint > 18) conf += SNR_GAIN; else if (opts.snrHint < 8) conf -= SNR_PENALTY;
  }
  conf = Math.max(0, Math.min(1, Number.isFinite(conf) ? conf : 0));
  const level = conf < LOW ? "low" as const : conf >= HIGH ? "high" as const : "mid" as const;
  const candidates = top3.map(t => ({ keyPc: t.keyPc, mode: t.mode, confidence: (sum>0? t.score/sum : 0) }));
  return { conf, level, candidates };
}

function adviceForLowConf(snrHint?: number, lengthSec?: number): string {
  const tips: string[] = [];
  tips.push("Low signal quality. Try recording again in a quieter room for 4–12s. Record at least ~4 seconds.");
  if (typeof snrHint === "number" && snrHint < 8) tips.push("Avoid background noise and bring the instrument closer to the mic.");
  return tips.join(" ");
}

function tel(event: string, payload: Record<string, unknown> = {}) {
  try {
    void fetch("/api/telemetry", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ event, ...payload }),
    }).catch(() => {});
  } catch {}
}

export async function POST(req: NextRequest) {
  try {
    const body = (await req.json()) as AnalyzeReq;
    const pcp = normalizePCP12(body?.pcp12 as any);
    if (!pcp) {
      tel("audio_analyze_err", { code: "pcp12_invalid", status: 400 });
      return NextResponse.json({ error: "pcp12_invalid" }, { status: 400 });
    }

    const top3 = voteKeys(pcp);
    const { conf, level, candidates } = synthesizeConf(top3, { lengthSec: body?.lengthSec, snrHint: body?.snrHint });

    tel("audio_analyze_ok", { n: pcp.length });
    tel("audio_analyze_conf", { level, conf });

    const res = {
      keyCandidates: candidates,
      conf,
      pcp12: pcp,
      ...(conf < LOW ? { advice: adviceForLowConf(body?.snrHint, body?.lengthSec) } : {}),
    };
    return NextResponse.json(res, { status: 200 });
  } catch (e) {
    tel("audio_analyze_err", { code: "analyze_failed", status: 500 });
    return NextResponse.json({ error: "analyze_failed" }, { status: 500 });
  }
}



