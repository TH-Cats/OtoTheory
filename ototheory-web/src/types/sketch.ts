// src/types/sketch.ts
export type Sketch = {
  id: string;
  name: string;
  createdAt: string;
  updatedAt: string;
  schema: 'sketch_v1';
  appVersion: string;
  key: { tonic: string; scaleId: string };
  capo: { fret: number; note: 'Shaped' }; // 注記: Shaped=fingered / Sounding=actual
  progression: { items: { id: string; degree: string; quality?: string }[] };
  fretboardView: { mode: 'Degrees'|'Names'; guide: boolean };
};

// 保存単位は Sketch に統一（Free=3件ローカル／Pro=無制限クラウド）。
