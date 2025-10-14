"use client";
import { useMemo, useState, useRef, useEffect } from "react";
import { DEFAULT_CONTEXT, type ChordContext, type ChordSpec, type Family, type Plan } from "@/lib/chords/types";
import { normalizeChordSpec } from "@/lib/chords/normalize";
import { formatChordSymbol } from "@/lib/chords/format";
import { canAddQuality, shouldShowProBadge } from "@/lib/pro/guard";

type Props = {
  plan?: Plan;
  onConfirm?: (symbol: string, spec: ChordSpec) => void;
  onBlock?: (reason: 'pro_quality' | 'pro_slash', quality?: string) => void;
  onPreview?: (symbol: string) => void;
};

const ROOTS = ['C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B'];

// Pro Badge component (small 👑 at top-right of chip)
const ProBadge = () => (
  <span className="absolute -top-1 -right-1 text-[10px]" title="Pro専用">👑</span>
);

export default function ChordBuilder({ plan = 'free', onConfirm, onBlock, onPreview }: Props){
  const baseSpec: ChordSpec = useMemo(() => ({
    root: 'C',
    family: 'maj',
    seventh: 'none',
    extMode: 'add',
    ext: {},
    alt: {},
    sus: null,
    slash: null,
  }), []);
  const [spec, setSpec] = useState<ChordSpec>(baseSpec);
  const ctx: ChordContext = { ...DEFAULT_CONTEXT, plan };
  
  // Session state for 11th warning (show once per session)
  const [has11thWarningShown, setHas11thWarningShown] = useState(false);

  const { spec: norm, warnings } = useMemo(() => normalizeChordSpec(spec, ctx), [spec, ctx]);
  const symbol = useMemo(() => formatChordSymbol(norm, ctx), [norm, ctx]);

  const setRoot = (r: string) => setSpec(s => ({ ...s, root: r }));
  
  // Show 11th warning once per session
  useEffect(() => {
    if (!has11thWarningShown && norm.ext.eleven && (norm.family === 'maj' || norm.family === 'dom')) {
      setHas11thWarningShown(true);
    }
  }, [norm.ext.eleven, norm.family, has11thWarningShown]);

  // Quick presets (follow root)
  const quickPresets = useMemo(() => {
    const presets: Array<{ label: string; apply: () => void; pro?: boolean; locked?: boolean }>= [
      { label: 'M', apply: () => setSpec(s => ({ ...s, family: 'maj', seventh: 'none', ext: {}, extMode: 'add', alt: {}, sus: null })) },
      { label: 'm', apply: () => setSpec(s => ({ ...s, family: 'min', seventh: 'none', ext: {}, extMode: 'add', alt: {}, sus: null })) },
      { label: 'M7', apply: () => setSpec(s => ({ ...s, family: 'maj', seventh: 'maj7', extMode: 'add', ext: {}, alt: {}, sus: null })) },
      { label: 'm7', apply: () => setSpec(s => ({ ...s, family: 'min', seventh: 'm7', extMode: 'add', ext: {}, alt: {}, sus: null })) },
      { label: '7', apply: () => setSpec(s => ({ ...s, family: 'dom', seventh: '7', extMode: 'tension', ext: {}, alt: {}, sus: null })) },
      { label: 'sus4', apply: () => setSpec(s => ({ ...s, family: 'sus', sus: 'sus4', seventh: 'none', extMode: 'add', ext: {}, alt: {} })) },
      { label: 'dim', apply: () => setSpec(s => ({ ...s, family: 'dim', seventh: 'none', ext: {}, extMode: 'add', alt: {}, sus: null })) },
      { label: 'aug', apply: () => setSpec(s => ({ ...s, family: 'aug', seventh: 'none', ext: {}, extMode: 'add', alt: {}, sus: null })) },
      { label: 'add9', apply: () => setSpec(s => ({ ...s, extMode: 'add', ext: { ...s.ext, add9: true } })) },
    ];
    // Pro-only 6/9 (locked in free)
    presets.push({ label: '6/9', pro: true, locked: plan==='free', apply: () => setSpec(s => ({ ...s, family: 'maj', seventh: '6', extMode: 'add', ext: { ...s.ext, add9: true } })) });
    return presets;
  }, [plan]);

  const renderChip = (
    label: string, 
    active: boolean, 
    onClick: () => void, 
    opts?: { disabled?: boolean; locked?: boolean; showProBadge?: boolean }
  ) => (
    <div key={label} className="relative inline-block">
      <button
        className={`h-9 px-3 rounded border text-xs ${active ? 'bg-[var(--brand-primary)] text-white' : ''} ${opts?.locked ? 'opacity-50' : ''}`}
        onClick={() => { if (!opts?.disabled && !opts?.locked) onClick(); }}
        title={opts?.locked ? 'Proで解放' : undefined}
        aria-disabled={opts?.disabled || opts?.locked}
      >{label}</button>
      {opts?.showProBadge && plan === 'free' && <ProBadge />}
    </div>
  );

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs opacity-70 mb-0.5">Root</div>
        <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2">
          {ROOTS.map(r => renderChip(r, norm.root === r, () => setRoot(r)))}
        </div>
      </div>

      <div>
        <div className="text-xs opacity-70 mb-0.5">Quick</div>
        <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2">
          {quickPresets.map(p => (
            <div key={p.label} className="relative">
              {renderChip(p.label, false, p.apply, { locked: !!p.locked })}
            </div>
          ))}
        </div>
      </div>

      <details>
        <summary className="cursor-pointer text-sm">Advanced</summary>
        <div className="mt-3 space-y-3">
          {/* Family */}
          <div>
            <div className="text-xs opacity-70 mb-0.5">Family</div>
            <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2">
              {(['maj','min','dom','sus','dim','aug','power'] as Family[]).map(f => (
                renderChip(
                  f === 'maj' ? 'M' : f === 'min' ? 'm' : f === 'dom' ? 'Dom' : f === 'sus' ? 'Sus' : f === 'dim' ? 'Dim' : f === 'aug' ? 'Aug' : '5',
                  norm.family === f,
                  () => setSpec(s => ({ ...s, family: f }))
                )
              ))}
            </div>
          </div>
          {/* Seventh */}
          <div>
            <div className="text-xs opacity-70 mb-0.5">Seventh</div>
            <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2">
              {['7','maj7','m7','6','m7b5','dim7'].map(sev => (
                renderChip(
                  sev === 'maj7' ? 'M7' : sev,
                  norm.seventh === (sev as any),
                  () => setSpec(s => ({ ...s, seventh: sev as any }))
                )
              ))}
            </div>
          </div>
          {/* Extensions: Add/Tension toggle */}
          <div>
            <div className="text-xs opacity-70 mb-0.5">Extensions</div>
            <div className="flex gap-2 items-center -mx-2 px-2">
              {renderChip('Add', norm.extMode==='add', () => setSpec(s => ({ ...s, extMode: 'add' })))}
              {renderChip('Tension', norm.extMode==='tension', () => setSpec(s => ({ ...s, extMode: 'tension' })))}
            </div>
            {norm.extMode === 'add' ? (
              <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2 mt-2">
                {renderChip('add9', !!norm.ext.add9, () => setSpec(s => ({ ...s, ext: { ...s.ext, add9: !s.ext.add9 } })))}
                {renderChip('add11', !!norm.ext.add11, () => setSpec(s => ({ ...s, ext: { ...s.ext, add11: !s.ext.add11 } })))}
                {renderChip('add13', !!norm.ext.add13, () => setSpec(s => ({ ...s, ext: { ...s.ext, add13: !s.ext.add13 } })))}
              </div>
            ) : (
              <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2 mt-2">
                {renderChip('9', !!norm.ext.nine, () => setSpec(s => ({ ...s, ext: { ...s.ext, nine: !s.ext.nine } })), { disabled: !['7','maj7','m7'].includes(norm.seventh) })}
                {renderChip('11', !!norm.ext.eleven, () => setSpec(s => ({ ...s, ext: { ...s.ext, eleven: !s.ext.eleven } })), { disabled: !['7','maj7','m7'].includes(norm.seventh) })}
                {renderChip('13', !!norm.ext.thirteen, () => setSpec(s => ({ ...s, ext: { ...s.ext, thirteen: !s.ext.thirteen, nine: !s.ext.thirteen ? true : s.ext.nine } })), { disabled: !['7','maj7','m7'].includes(norm.seventh), showProBadge: true })}
              </div>
            )}
          </div>
          {/* Alterations (always visible, with Pro badge for Free users) */}
          <div>
            <div className="text-xs opacity-70 mb-0.5">Alterations</div>
            <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2">
              {['b9','#9','#11','b13','alt'].map(label => (
                renderChip(
                  label,
                  plan === 'pro' && !!(label==='b9'? norm.alt.b9 : label==='#9'? norm.alt.s9 : label==='#11'? norm.alt.s11 : label==='b13'? norm.alt.b13 : norm.alt.alt),
                  () => {
                    if (plan === 'pro') {
                      setSpec(s => ({
                        ...s,
                        alt: s.family==='dom' ? {
                          ...s.alt,
                          b9: label==='b9' ? !s.alt.b9 : s.alt.b9,
                          s9: label==='#9' ? !s.alt.s9 : s.alt.s9,
                          s11: label==='#11' ? !s.alt.s11 : s.alt.s11,
                          b13: label==='b13' ? !s.alt.b13 : s.alt.b13,
                          alt: label==='alt' ? !s.alt.alt : s.alt.alt,
                        } : {}
                      }));
                    }
                  },
                  { disabled: norm.family !== 'dom', showProBadge: true }
                )
              ))}
            </div>
          </div>
          {/* Sus & /Bass */}
          <div>
            <div className="text-xs opacity-70 mb-0.5">Sus & /Bass</div>
            <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2">
              {renderChip('sus2', norm.sus==='sus2', () => setSpec(s => ({ ...s, sus: s.sus==='sus2' ? null : 'sus2' })))}
              {renderChip('sus4', norm.sus==='sus4', () => setSpec(s => ({ ...s, sus: s.sus==='sus4' ? null : 'sus4' })))}
              {/* /bass (Pro only) */}
              <div className="flex items-center gap-1 ml-2 relative">
                <span className="text-xs opacity-70">/bass</span>
                <select
                  className="rounded border px-2 py-1 text-xs bg-transparent"
                  disabled={plan==='free'}
                  value={norm.slash ?? ''}
                  onChange={(e) => setSpec(s => ({ ...s, slash: e.target.value || null }))}
                >
                  <option value="">-</option>
                  {ROOTS.map(r => (<option key={`b-${r}`} value={r}>{r}</option>))}
                </select>
                {plan==='free' && <ProBadge />}
              </div>
            </div>
          </div>
        </div>
      </details>

      {warnings.length > 0 && (
        <div className="text-xs text-yellow-600 dark:text-yellow-400">
          {warnings[0]}
        </div>
      )}

      <div className="flex items-center justify-between">
        <div className="text-sm">Preview: {symbol || '-'}</div>
        <div className="flex gap-2">
          <button 
            className="rounded border px-2 py-1.5 text-xs hover:bg-gray-100 dark:hover:bg-gray-700"
            onClick={() => onPreview?.(symbol)}
            disabled={!symbol}
          >
            ▶ Play
          </button>
          <button 
            className="rounded border px-2 py-1.5 text-xs" 
            onClick={() => setSpec(baseSpec)}
          >
            Clear
          </button>
          <button
            className="rounded bg-[var(--brand-primary)] text-white px-3 py-2 text-xs hover:opacity-90"
            onClick={() => {
              // Check if chord can be added
              const isPro = plan === 'pro';
              const hasSlash = !!norm.slash;
              
              // Simple quality extraction for guard check
              // (This is a simplified check - actual quality depends on full spec)
              let qualityToCheck = '';
              if (norm.ext.thirteen) qualityToCheck = '13';
              else if (norm.alt.b9) qualityToCheck = '7b9';
              else if (norm.alt.s9) qualityToCheck = '7#9';
              else if (norm.alt.s11) qualityToCheck = '7#11';
              else if (norm.alt.b13) qualityToCheck = '7b13';
              else if (norm.alt.alt) qualityToCheck = '7alt';
              
              const canAdd = canAddQuality(qualityToCheck, { isPro, hasSlash });
              
              if (!canAdd) {
                // Block and notify parent
                if (hasSlash) {
                  onBlock?.('pro_slash');
                } else {
                  onBlock?.('pro_quality', qualityToCheck);
                }
              } else {
                // Allow add
                onConfirm?.(symbol, norm);
              }
            }}
          >
            Add
          </button>
        </div>
      </div>
    </div>
  );
}



