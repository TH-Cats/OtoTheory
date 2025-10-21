"use client";
import { useMemo, useState, useRef, useEffect } from "react";
import { DEFAULT_CONTEXT, type ChordContext, type ChordSpec, type Family, type Plan } from "@/lib/chords/types";
import { normalizeChordSpec } from "@/lib/chords/normalize";
import { formatChordSymbol } from "@/lib/chords/format";
import { canAddQuality, shouldShowProBadge } from "@/lib/pro/guard";
import { QUALITY_MASTER, getQualityComment, getQualitiesByCategory, isProQuality } from "@/lib/quality-master";
import QualityInfo from "./QualityInfo";

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
  console.log('[debug] Slash On buttons should be disabled for plan:', plan);
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
  // Locale: auto-detect from pathname (/ja/* -> ja)
  const locale: 'ja' | 'en' = typeof window !== 'undefined' && window.location.pathname.startsWith('/ja') ? 'ja' : 'en';
  
  // Session state for 11th warning (show once per session)
  const [has11thWarningShown, setHas11thWarningShown] = useState(false);
  
  // Quality info modal state
  const [selectedQualityInfo, setSelectedQualityInfo] = useState<{ title: string; body: string } | null>(null);

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

    // Free qualities only
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
          comment: getQualityComment(quality.quality, locale),
          category: category
        });
      });
    });

    // Pro qualities - always add them but mark as pro
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
            if (plan === 'free') {
              // Show iOS promotion for free users
              onBlock?.('pro_quality', quality.quality);
              return;
            }
            const spec = getSpecFromQuality(quality.quality);
            if (spec) setSpec(spec);
          },
          pro: true,
          comment: getQualityComment(quality.quality, locale),
          category: category
        });
      });
    });

    console.log('🔍 Final presets count:', presets.length, 'Free count:', presets.filter(p => !p.pro).length, 'Pro count:', presets.filter(p => p.pro).length);
    return presets;
  }, [setSpec, plan, onBlock]);

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
        className={`h-9 px-3 rounded border text-xs transition-all flex items-center gap-2 ${
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
            // Pro quality clicked in free plan - redirect to iOS coming soon page
            window.open('https://www.ototheory.com/ios-coming-soon', '_blank');
          }
        }}
        title={opts?.locked ? 'Try Pro features on iOS!' : undefined}
        aria-disabled={opts?.disabled || opts?.locked}
      >
        <span>{label}</span>
        
        {/* Lightbulb icon inside the chip */}
        {opts?.comment && (
          <span
            className="text-yellow-500 hover:text-yellow-600 transition-colors cursor-pointer"
            onClick={(e) => {
              e.stopPropagation();
              setSelectedQualityInfo({ title: label, body: opts.comment! });
            }}
            title="Show quality info"
          >
            <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 24 24">
              <path d="M9 21c0 .55.45 1 1 1h4c.55 0 1-.45 1-1v-1H9v1zm3-19C8.14 2 5 5.14 5 9c0 2.38 1.19 4.47 3 5.74V17c0 .55.45 1 1 1h6c.55 0 1-.45 1-1v-2.26c1.81-1.27 3-3.36 3-5.74 0-3.86-3.14-7-7-7zm2.85 11.1l-.85.6V16h-4v-2.3l-.85-.6A4.997 4.997 0 0 1 7 9c0-2.76 2.24-5 5-5s5 2.24 5 5c0 1.63-.8 3.16-2.15 4.1z"/>
            </svg>
          </span>
        )}
      </button>
      {opts?.showProBadge && plan === 'free' && <ProBadge />}
    </div>
  );

  return (
    <div className="space-y-4">
      <div>
        <div className="text-xs opacity-70 mb-0.5">ルート</div>
        <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2">
          {ROOTS.map(r => renderChip(r, norm.root === r, () => setRoot(r)))}
        </div>
      </div>

      {(() => {
        const freeQualities = qualityPresets.filter(p => !p.pro);
        const proQualities = qualityPresets.filter(p => p.pro);
        
        return (
          <div>
            <div className="text-xs opacity-70 mb-0.5">コードタイプ ({freeQualities.length} types)</div>
            <div className="flex gap-1 overflow-x-auto whitespace-nowrap py-0 -mx-2 px-2">
              {freeQualities.map(p => {
                // Check if this quality is currently selected
                const currentQuality = spec ? getQualityFromSpec(spec) : null;
                const isSelected = currentQuality === p.label;
                return (
                  <div key={p.label} className="relative">
                    {renderChip(p.label, isSelected, p.apply, {
                      locked: false,
                      showProBadge: false,
                      comment: p.comment
                    })}
                  </div>
                );
              })}
            </div>
          </div>
        );
      })()}

      {/* Advanced (Pro) section - show for all users */}
      <details>
        <summary className="cursor-pointer text-sm">
          Advanced (Pro) 👑
        </summary>
        <div className="mt-3 space-y-3">
          {/* Pro qualities grouped by category with custom order */}
          {(() => {
            const proQualities = getQualitiesByCategory('Pro');
            const categoryOrder = ['✨ Sparkle & Float', '🌃 Stylish & Urban', '⚡️ Tension & Spice'];
            
            return categoryOrder.map(category => {
              const japaneseCategory = category === '✨ Sparkle & Float' ? '✨ キラキラ・浮遊感' :
                                     category === '🌃 Stylish & Urban' ? '🌃 おしゃれ・都会的' :
                                     category === '⚡️ Tension & Spice' ? '⚡️ 緊張感・スパイス' : category;
              const qualities = proQualities[japaneseCategory];
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
                            // Pro qualities should not be clickable for free users
                            console.log('Pro quality clicked:', quality.quality, 'Plan:', plan);
                          }, { 
                            comment: quality.commentJa,
                            locked: true, // Always locked for Pro qualities in Web version
                            showProBadge: false // Remove crown from individual chips
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
                className={`h-9 px-3 rounded border text-xs ${
                  plan === 'free' 
                    ? 'bg-gray-400 text-gray-200 cursor-not-allowed opacity-60' 
                    : 'bg-orange-500 text-white hover:bg-orange-600'
                }`}
                onClick={() => {
                  if (plan === 'free') {
                    // Redirect to iOS coming soon page
                    window.open('https://www.ototheory.com/ios-coming-soon', '_blank');
                    return;
                  }
                  setSpec({ ...spec, slash: undefined });
                }}
                disabled={plan === 'free'}
                title={plan === 'free' ? 'Try Pro features on iOS!' : undefined}
              >
                Clear
              </button>
              {['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'].map(bassNote => (
                <button
                  key={bassNote}
                  className={`h-9 px-3 rounded border text-xs ${
                    plan === 'free'
                      ? 'bg-gray-400 text-gray-200 cursor-not-allowed opacity-60'
                      : spec?.slash === bassNote 
                        ? 'bg-[var(--brand-primary)] text-white' 
                        : 'bg-gray-600 text-white hover:bg-gray-500'
                  }`}
                  onClick={() => {
                    if (plan === 'free') {
                      // Redirect to iOS coming soon page
                      window.open('https://www.ototheory.com/ios-coming-soon', '_blank');
                      return;
                    }
                    setSpec({ ...spec, slash: bassNote });
                  }}
                  disabled={plan === 'free'}
                  title={plan === 'free' ? 'Try Pro features on iOS!' : undefined}
                >
                  {bassNote}
                </button>
              ))}
            </div>
          </div>
          
        </div>
      </details>
      
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
              // iOS Coming Soon page
              window.open('https://www.ototheory.com/ios-coming-soon', '_blank');
            }}
          >
            Try iOS Version
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
          <div className="text-sm font-medium text-gray-700 dark:text-gray-300">プレビュー</div>
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
      
      {/* Quality Info Modal */}
      {selectedQualityInfo && (
        <QualityInfo
          title={selectedQualityInfo.title}
          body={selectedQualityInfo.body}
          isOpen={true}
          onClose={() => setSelectedQualityInfo(null)}
        />
      )}
    </div>
  );
}



