export type ChordToken = string;
export type Preset = { id: string; name: string; tokens: ChordToken[] };

export const PRESETS: Preset[] = [
  { id:'I-V-vi-IV',    name:'I–V–vi–IV',        tokens:['I','V','vi','IV'] },
  { id:'ii-V-I',       name:'ii–V–I',           tokens:['ii','V','I'] },
  { id:'12-bar',       name:'12-bar Blues',     tokens:['I','I','I','I','IV','IV','I','I','V','IV','I','V'] },
  { id:'I-II',         name:'I–II',             tokens:['I','II'] },
  { id:'I-bVII-IV',    name:'I–♭VII–IV',        tokens:['I','bVII','IV'] },
];



