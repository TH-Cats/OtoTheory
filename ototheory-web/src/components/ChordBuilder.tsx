"use client";
import { useMemo, useState, useRef, useEffect } from "react";
import { DEFAULT_CONTEXT, type ChordContext, type ChordSpec, type Family, type Plan } from "@/lib/chords/types";
import { normalizeChordSpec } from "@/lib/chords/normalize";
import { formatChordSymbol } from "@/lib/chords/format";
import { canAddQuality, shouldShowProBadge } from "@/lib/pro/guard";
import { QUALITY_MASTER, getQualityComment, getQualitiesByCategory, isProQuality } from "@/lib/quality-master";

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
  // Debug: Log plan value
  console.log('[debug] plan in ChordBuilder:', plan);
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

  // Helper function to convert Japanese category names to English
  const getEnglishCategoryName = (japaneseCategory: string): string => {
    switch (japaneseCategory) {
      case '基本': return 'Basics';
      case '基本の飾り付け': return 'Essential Colors';
      case '✨ キラキラ・浮遊感': return '✨ Sparkle & Float';
      case '🌃 おしゃれ・都会的': return '🌃 Stylish & Urban';
      case '⚡️ 緊張感・スパイス': return '⚡️ Tension & Spice';
      default: return japaneseCategory;
    }
  };

  const getQualityFromSpec = (spec: ChordSpec): string => {
    if (!spec) return '';
    
    // Map spec properties to quality labels
    if (spec.seventh === 'none' && spec.extMode === 'add' && spec.ext.add9) return 'add9';
    if (spec.seventh === 'none' && spec.extMode === 'add' && spec.ext.add11) return 'add#11';
    if (spec.seventh === 'sus4') return 'sus4';
    if (spec.seventh === 'sus2') return 'sus2';
    if (spec.family === 'maj' && spec.seventh === 'none') return 'M';
    if (spec.family === 'min' && spec.seventh === 'none') return 'm';
    if (spec.family === 'maj' && spec.seventh === '7') return 'M7';
    if (spec.family === 'min' && spec.seventh === '7') return 'm7';
    if (spec.family === 'dom' && spec.seventh === '7') return '7';
    if (spec.family === 'dim' && spec.seventh === 'none') return 'dim';
    if (spec.family === 'aug' && spec.seventh === 'none') return 'aug';
    if (spec.family === 'maj' && spec.seventh === '9') return 'M9';
    if (spec.family === 'min' && spec.seventh === '9') return 'm9';
    if (spec.family === 'min' && spec.seventh === '11') return 'm11';
    if (spec.family === 'min' && spec.seventh === '7b5') return 'm7b5';
    if (spec.family === 'min' && spec.seventh === 'M7') return 'mM7';
    if (spec.family === 'min' && spec.seventh === '6') return 'm6';
    if (spec.family === 'maj' && spec.seventh === '6') return '6';
    if (spec.family === 'maj' && spec.seventh === '6/9') return '6/9';
    if (spec.family === 'dom' && spec.seventh === 'sus4') return '7sus4';
    if (spec.family === 'dim' && spec.seventh === '7') return 'dim7';
    if (spec.family === 'dom' && spec.seventh === '7' && spec.alt.s9) return '7(#9)';
    if (spec.family === 'dom' && spec.seventh === '7' && spec.alt.b9) return '7(b9)';
    if (spec.family === 'dom' && spec.seventh === '7' && spec.alt.s5) return '7(#5)';
    if (spec.family === 'dom' && spec.seventh === '7' && spec.alt.b13) return '7(b13)';
    
    return '';
  };

  // Quality presets based on Quality Master.csv
  const qualityPresets = useMemo(() => {
    console.log('🔍 ChordBuilder: Creating quality presets...');
    const freeQualities = getQualitiesByCategory('Free');
    const proQualities = getQualitiesByCategory('Pro');
    
    // Debug: Log the qualities
    console.log('🔍 Free qualities:', freeQualities);
    console.log('🔍 Pro qualities:', proQualities);
    console.log('🔍 Total qualities in QUALITY_MASTER:', QUALITY_MASTER.length);
    
    const presets: Array<{ 
      label: string; 
      apply: () => void; 
      pro?: boolean; 
      locked?: boolean;
      comment?: string;
      category?: string;
    }> = [];

    // Free qualities only - show Japanese category names for Japanese version
    Object.entries(freeQualities).forEach(([category, qualities]) => {
      qualities.forEach(quality => {
        const qualityLabel = quality.quality === 'm (minor)' ? 'm' : 
                           quality.quality === 'Major' ? 'M' : 
                           quality.quality === 'maj7' ? 'M7' : quality.quality;
        
        presets.push({
          label: qualityLabel,
          apply: () => {
            const spec = getSpecFromQuality(quality.quality);
            if (spec) setSpec(spec);
          },
          pro: false, // Free quality
          comment: quality.commentJa,
          category: category // Use Japanese category names
        });
      });
    });

    // Pro qualities - show Japanese category names, only if user has Pro
    if (plan === 'pro') {
      Object.entries(proQualities).forEach(([category, qualities]) => {
        qualities.forEach(quality => {
          const qualityLabel = quality.quality === 'M9 (maj9)' ? 'M9' : 
                             quality.quality === 'm7b5' ? 'm7b5' :
                             quality.quality === 'mM7' ? 'mM7' :
                             quality.quality === 'm6' ? 'm6' :
                             quality.quality === '7(#9)' ? '7(#9)' :
                             quality.quality === '7(b9)' ? '7(b9)' :
                             quality.quality === '7(#5)' ? '7(#5)' :
                             quality.quality === '7(b13)' ? '7(b13)' :
                             quality.quality;
          
          presets.push({
            label: qualityLabel,
            apply: () => {
              const spec = getSpecFromQuality(quality.quality);
              if (spec) setSpec(spec);
            },
            pro: true,
            comment: quality.commentJa,
            category: category // Use Japanese category names
          });
        });
      });
    }

    console.log('🔍 Final presets count:', presets.length, 'Free count:', presets.filter(p => !p.pro).length, 'Pro count:', presets.filter(p => p.pro).length);
    return presets;
  }, [setSpec, plan]);

  // Helper function to convert quality string to ChordSpec
  const getSpecFromQuality = (quality: string): ChordSpec | null => {
    const baseSpec = { ext: {}, alt: {}, sus: null, slash: null };
    
    switch (quality) {
      case 'Major': return { ...baseSpec, root: 'C', family: 'maj', seventh: 'none', extMode: 'add' };
      case 'm (minor)': return { ...baseSpec, root: 'C', family: 'min', seventh: 'none', extMode: 'add' };
      case '7': return { ...baseSpec, root: 'C', family: 'dom', seventh: '7', extMode: 'tension' };
      case 'maj7': return { ...baseSpec, root: 'C', family: 'maj', seventh: 'maj7', extMode: 'add' };
      case 'm7': return { ...baseSpec, root: 'C', family: 'min', seventh: 'm7', extMode: 'add' };
      case 'sus4': return { ...baseSpec, root: 'C', family: 'maj', seventh: 'sus4', extMode: 'add' };
      case 'sus2': return { ...baseSpec, root: 'C', family: 'maj', seventh: 'sus2', extMode: 'add' };
      case 'add9': return { ...baseSpec, root: 'C', family: 'maj', seventh: 'none', extMode: 'add', ext: { add9: true } };
      case 'dim': return { ...baseSpec, root: 'C', family: 'dim', seventh: 'none', extMode: 'add' };
      case 'M9 (maj9)': return { ...baseSpec, root: 'C', family: 'maj', seventh: 'maj7', extMode: 'add', ext: { add9: true } };
      case '6': return { ...baseSpec, root: 'C', family: 'maj', seventh: '6', extMode: 'add' };
      case '6/9': return { ...baseSpec, root: 'C', family: 'maj', seventh: '6', extMode: 'add', ext: { add9: true } };
      case 'add#11': return { ...baseSpec, root: 'C', family: 'maj', seventh: 'none', extMode: 'add', ext: { add11: true }, alt: { s11: true } };
      case 'm9': return { ...baseSpec, root: 'C', family: 'min', seventh: 'm7', extMode: 'add', ext: { add9: true } };
      case 'm11': return { ...baseSpec, root: 'C', family: 'min', seventh: 'm7', extMode: 'add', ext: { add9: true, add11: true } };
      case 'm7b5': return { ...baseSpec, root: 'C', family: 'min', seventh: 'm7b5', extMode: 'add' };
      case 'mM7': return { ...baseSpec, root: 'C', family: 'min', seventh: 'maj7', extMode: 'add' };
      case 'm6': return { ...baseSpec, root: 'C', family: 'min', seventh: '6', extMode: 'add' };
      case '7sus4': return { ...baseSpec, root: 'C', family: 'dom', seventh: '7', sus: 'sus4', extMode: 'tension' };
      case 'aug': return { ...baseSpec, root: 'C', family: 'aug', seventh: 'none', extMode: 'add' };
      case 'dim7': return { ...baseSpec, root: 'C', family: 'dim', seventh: 'dim7', extMode: 'add' };
      case '7(#9)': return { ...baseSpec, root: 'C', family: 'dom', seventh: '7', extMode: 'tension', alt: { sharp9: true } };
      case '7(b9)': return { ...baseSpec, root: 'C', family: 'dom', seventh: '7', extMode: 'tension', alt: { flat9: true } };
      case '7(#5)': return { ...baseSpec, root: 'C', family: 'dom', seventh: '7', extMode: 'tension', alt: { sharp5: true } };
      case '7(b13)': return { ...baseSpec, root: 'C', family: 'dom', seventh: '7', extMode: 'tension', alt: { flat13: true } };
      default: return null;
    }
  };

  const renderChip = (
    label: string, 
    active: boolean, 
    onClick: () => void, 
    opts?: { disabled?: boolean; locked?: boolean; showProBadge?: boolean; comment?: string }
  ) => (
    <div key={label} className="relative inline-block">
      <button
        className={`h-9 px-3 rounded border text-xs transition-all ${
          active 
            ? 'bg-[var(--brand-primary)] text-white' 
            : opts?.locked 
              ? 'bg-gray-200 dark:bg-gray-700 text-gray-500 dark:text-gray-400 border-gray-300 dark:border-gray-600 cursor-not-allowed hover:bg-gray-300 dark:hover:bg-gray-600' 
              : 'bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-700'
        }`}
        onClick={() => { 
          if (!opts?.disabled && !opts?.locked) {
            onClick(); 
          } else if (opts?.locked) {
            // Pro quality clicked in free plan
            onBlock?.('pro_quality', label);
          }
        }}
        title={opts?.locked ? 'iOS版でPro機能をお試しください！' : opts?.comment}
        aria-disabled={opts?.disabled || opts?.locked}
        onContextMenu={(e) => {
          e.preventDefault();
          if (opts?.comment) {
            // Show comment tooltip on right-click/long-press
            // For now, we'll use the title attribute, but this could be enhanced with a custom tooltip
          }
        }}
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

      {(() => {
        const quick = (plan === 'free')
          ? qualityPresets.filter(p => !p.pro) // ← Pro項目を隠す
          : qualityPresets;
        return (
          <div>
            <div className="text-xs opacity-70 mb-0.5">Quality ({quick.length} types)</div>
            <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2">
              {quick.map(p => {
                // Check if this quality is currently selected
                const currentQuality = spec ? getQualityFromSpec(spec) : null;
                const isSelected = currentQuality === p.label;
                return (
                  <div key={p.label} className="relative">
                    {renderChip(p.label, isSelected, p.apply, {
                      locked: false,    // FreeプランではProクオリティは表示されないのでlockedは不要
                      showProBadge: false,  // FreeプランではProクオリティは表示されないのでbadgeは不要
                      comment: p.comment
                    })}
                  </div>
                );
              })}
            </div>
          </div>
        );
      })()}

      {/* Advanced (Pro) section - only show for Pro users */}
      {plan === 'pro' && (
        <details>
          <summary className="cursor-pointer text-sm">
            Advanced (Pro)
          </summary>
        <div className="mt-3 space-y-3">
          {/* Pro qualities grouped by category with custom order */}
          {(() => {
            const proQualities = getQualitiesByCategory('Pro');
            const categoryOrder = ['✨ キラキラ・浮遊感', '🌃 おしゃれ・都会的', '⚡️ 緊張感・スパイス'];
            
            return categoryOrder.map(category => {
              const qualities = proQualities[category];
              if (!qualities) return null;
              
              return (
                <div key={category}>
                  <div className="text-xs opacity-70 mb-0.5">{category}</div>
            <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2">
                    {qualities.map(quality => {
                      const qualityLabel = quality.quality === 'M9 (maj9)' ? 'M9' : 
                                         quality.quality === 'm7b5' ? 'm7b5' :
                                         quality.quality === 'mM7' ? 'mM7' :
                                         quality.quality === 'm6' ? 'm6' :
                                         quality.quality === '7(#9)' ? '7(#9)' :
                                         quality.quality === '7(b9)' ? '7(b9)' :
                                         quality.quality === '7(#5)' ? '7(#5)' :
                                         quality.quality === '7(b13)' ? '7(b13)' :
                                         quality.quality;
                      
                      return (
                        <div key={quality.quality} className="relative">
                          {renderChip(qualityLabel, false, () => {
                            const spec = getSpecFromQuality(quality.quality);
                            if (spec) setSpec(spec);
                          }, { 
                            comment: quality.commentJa,
                            locked: false,
                            showProBadge: false
                          })}
                        </div>
                      );
                    })}
            </div>
          </div>
              );
            });
          })()}
          
          {/* Slash (On) section after all categories */}
          <div className="mt-3">
            <div className="text-xs opacity-70 mb-0.5">Slash (On)</div>
            <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2">
              <button
                className="h-9 px-3 rounded border text-xs bg-orange-500 text-white hover:bg-orange-600"
                onClick={() => {
                  setSpec({ ...spec, slash: undefined });
                }}
              >
                クリア
              </button>
              {['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'].map(bassNote => (
                <button
                  key={bassNote}
                  className={`h-9 px-3 rounded border text-xs ${
                    spec?.slash === bassNote 
                      ? 'bg-[var(--brand-primary)] text-white' 
                      : 'bg-gray-600 text-white hover:bg-gray-500'
                  }`}
                  onClick={() => {
                    setSpec({ ...spec, slash: bassNote });
                  }}
                >
                  {bassNote}
                </button>
              ))}
            </div>
          </div>
          
        </div>
      </details>
      )}
      
      {/* Free plan Pro promotion */}
      {plan === 'free' && (
        <div className="bg-gray-100 dark:bg-gray-800 rounded-lg p-4 text-center">
          <div className="text-sm font-medium mb-2">📱 Try Pro features on iOS!</div>
          <div className="text-xs opacity-70 mb-3">
            Advanced chord qualities and Slash features are available in the iOS Pro version.
          </div>
          <button
            className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
            onClick={() => {
              // iOS App Store link
              window.open('https://apps.apple.com/app/ototheory/id1234567890', '_blank');
            }}
          >
            Download on App Store
          </button>
        </div>
      )}

      {warnings.length > 0 && (
        <div className="text-xs text-yellow-600 dark:text-yellow-400">
          {warnings[0]}
        </div>
      )}

      <div className="bg-gray-50 dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
        <div className="flex items-center justify-between mb-3">
          <div className="text-sm font-medium text-gray-700 dark:text-gray-300">Preview</div>
          <div className="text-xl font-bold text-gray-900 dark:text-white bg-white dark:bg-gray-700 px-3 py-1 rounded border">
            {symbol || 'Select a chord'}
          </div>
        </div>
        <div className="flex gap-2 justify-center">
          <button 
            className="flex items-center gap-1 rounded-lg bg-green-500 hover:bg-green-600 text-white px-4 py-2 text-sm font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            onClick={() => onPreview?.(symbol)}
            disabled={!symbol}
          >
            <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path d="M8 5v10l8-5-8-5z"/>
            </svg>
            Play
          </button>
          <button 
            className="rounded-lg border border-gray-300 dark:border-gray-600 px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors" 
            onClick={() => setSpec(baseSpec)}
          >
            Clear
          </button>
          <button
            className="rounded-lg bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white px-6 py-2 text-sm font-medium transition-all transform hover:scale-105"
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



