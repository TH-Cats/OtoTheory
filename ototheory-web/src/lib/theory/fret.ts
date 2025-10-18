import { noteToPc, PITCHES } from "../theory";

export type OverlayDot = {
  stringIndex: number; // 0 = high E, 5 = low E
  fret: number; // 0 = open
  type: "chord" | "scale" | "guide" | "avoid";
  label?: string;
};

const STD_STRINGS_HIGH_TO_LOW = ["E","B","G","D","A","E"] as const;
const OPEN_PCS = STD_STRINGS_HIGH_TO_LOW.map(noteToPc);

const DEGREE_LABELS: Record<number,string> = {
  0:"1",1:"b2",2:"2",3:"b3",4:"3",5:"4",6:"b5",7:"5",8:"b6",9:"6",10:"b7",11:"7"
};

export function buildChordOverlay(
  chordPcs: number[],
  chordRootPc: number,
  opts?: { frets?: number; view?: "degree"|"note" }
): OverlayDot[] {
  const frets = opts?.frets ?? 15;
  const view = opts?.view ?? "degree";
  const set = new Set(chordPcs.map((n)=>((n%12)+12)%12));
  const dots: OverlayDot[] = [];
  for (let s=0;s<OPEN_PCS.length;s++){
    const open = OPEN_PCS[s];
    for (let f=0; f<=frets; f++){
      const pc = (open + f) % 12;
      if (set.has(pc)){
        let label: string | undefined;
        if (view === "degree"){
          const iv = (pc - chordRootPc + 12) % 12;
          label = DEGREE_LABELS[iv];
        } else {
          label = PITCHES[pc];
        }
        dots.push({ stringIndex: s, fret: f, type: "chord", label });
      }
    }
  }
  return dots;
}
















