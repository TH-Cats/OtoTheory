export type Degree = '1'|'b2'|'2'|'b3'|'3'|'4'|'b5'|'5'|'#5'|'6'|'b7'|'7';
export type FormKind = 'open'|'barreE'|'barreA';
export type Quality = 'maj'|'min';

export type ShapeDot = {
  string: 1|2|3|4|5|6;   // 1 = highest (thin) string
  fret: number;           // 0 = open string
  deg: Degree;
  muted?: boolean;
};

export type FormShape = {
  kind: FormKind;
  quality: Quality;
  rootPc: number;         // 0=C, 1=C#, ... 11=B
  rootString: 6|5;        // 6 = E-shape, 5 = A-shape
  dots: ShapeDot[];
  barre?: { stringFrom: 6|5; fret: number };
};

const OPEN_E_PC = 4; // E
const OPEN_A_PC = 9; // A

function mod12(n: number): number {
  return ((n % 12) + 12) % 12;
}

function nearestBarreFretForRoot(openPc: number, targetPc: number): number {
  const tgt = mod12(targetPc);
  for (let f = 1; f <= 12; f++) {
    if (mod12(openPc + f) === tgt) return f;
  }
  return 1;
}

export function getOpenShapeE(quality: Quality, rootPc: number): FormShape {
  const dots: ShapeDot[] =
    quality === 'maj'
      ? [
          { string: 6, fret: 0, deg: '1' },
          { string: 5, fret: 2, deg: '5' },
          { string: 4, fret: 2, deg: '1' },
          { string: 3, fret: 1, deg: '3' },
          { string: 2, fret: 0, deg: '5' },
          { string: 1, fret: 0, deg: '1' },
        ]
      : [
          { string: 6, fret: 0, deg: '1' },
          { string: 5, fret: 2, deg: '5' },
          { string: 4, fret: 2, deg: '1' },
          { string: 3, fret: 0, deg: 'b3' },
          { string: 2, fret: 0, deg: '5' },
          { string: 1, fret: 0, deg: '1' },
        ];

  return { kind: 'open', quality, rootPc, rootString: 6, dots };
}

export function makeBarreEShape(quality: Quality, rootPc: number): FormShape {
  const f = nearestBarreFretForRoot(OPEN_E_PC, rootPc);
  const dots: ShapeDot[] = [
    { string: 6, fret: f, deg: '1' },
    { string: 5, fret: f + 2, deg: '5' },
    { string: 4, fret: f + 2, deg: '1' },
    { string: 3, fret: quality === 'maj' ? f + 1 : f, deg: quality === 'maj' ? '3' : 'b3' },
    { string: 2, fret: f, deg: '5' },
    { string: 1, fret: f, deg: '1' },
  ];

  return {
    kind: 'barreE',
    quality,
    rootPc,
    rootString: 6,
    dots,
    barre: { stringFrom: 6, fret: f },
  };
}

export function makeBarreAShape(quality: Quality, rootPc: number): FormShape {
  const f = nearestBarreFretForRoot(OPEN_A_PC, rootPc);
  const dots: ShapeDot[] = [
    { string: 5, fret: f, deg: '1' },
    { string: 4, fret: f + 2, deg: '5' },
    { string: 3, fret: quality === 'maj' ? f + 2 : f, deg: quality === 'maj' ? '3' : 'b3' },
    { string: 2, fret: f + 2, deg: '1' },
    { string: 1, fret: f, deg: '5' },
  ];

  return {
    kind: 'barreA',
    quality,
    rootPc,
    rootString: 5,
    dots,
    barre: { stringFrom: 5, fret: f },
  };
}

export function buildForm(kind: FormKind, quality: Quality, rootPc: number): FormShape {
  if (kind === 'open') return getOpenShapeE(quality, rootPc);
  if (kind === 'barreE') return makeBarreEShape(quality, rootPc);
  return makeBarreAShape(quality, rootPc);
}


