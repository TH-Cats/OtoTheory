"use client";
import React from "react";
import AdSlot from "@/components/AdSlot.client";
import { useCallback, useEffect, useMemo, useRef, useState, useTransition } from "react";
import { useRovingTabs } from "@/hooks/useRovingTabs";
import Fretboard from "@/components/Fretboard";
import CapoFold from "@/components/CapoFold";
import { rankKeys, rankScales, type ScaleRank, PITCHES, detectCadence, noteToPc, romanToChordSymbol, type Mode } from "@/lib/theory";
import { getScalePitchesById, getScalePitches, scaleTypeLabel, normalizeScaleId, SCALE_INTERVALS, parentModeOf } from "@/lib/scales";
import { diatonicTriads, triadToChordSym } from "@/lib/theory/diatonic";
import { SCALE_CATALOG } from "@/lib/scaleCatalog";
import { toRoman, type RomanMode } from "@/lib/theory/roman";
import { useAnalysisStore } from "@/store/analysisStore";
import { formatCadenceLabel, cadenceTooltip, formatCadenceShort } from "@/lib/ui/cadence";
import type { CadenceType } from "@/lib/ui/cadence";
import SectionTitle from "@/components/SectionTitle";
import { H2, H3 } from "@/components/ui/Heading";
import InfoDot from "@/components/ui/InfoDot";
 
import { inferScaleIdFromLabel, scaleNotes, SCALE_DEFS, type ScaleId } from "@/lib/theory/scales";
import ScaleChip from "@/components/ScaleChip";
import { SCALE_MASTER, getScaleById, getScaleDisplayName, type ScaleId as NewScaleId } from "@/lib/scalesMaster";
import { getCategoryIcon } from "@/lib/scaleCategoryIcons";
import ScaleInfoBody from "@/components/ScaleInfoBody";
import { analyzeChordProgression } from "@/lib/music-theory";
import {
  ADVANCED_QUALITIES,
  ADV_EXTENSIONS, ADV_ALTERED_DOM, ADV_DIM_VARIANTS, ADV_SUS_ADDS, ADV_AUG_MAJMIN,
  isAdvanced, BASS_NOTES
} from "@/lib/chords";
import { usePro } from "@/components/ProProvider";
import { ProGate } from "@/components/ProGate";
import UpgradeModal from "@/components/UpgradeModal";
import { getBaseKind, isCompatible } from "@/lib/compat";
import { copy } from "@/lib/copy";
import DiatonicCapoTable from "@/components/DiatonicCapoTable";
import { matchPatterns } from "@/lib/theory/roman/match";
import { patternInfoEN } from "@/lib/theory/roman/patterns";
import { ChordFormsPopover } from "@/components/ChordFormsPopover";
import { player } from "@/lib/audio/player";
import { buildForm, type FormKind, type FormShape, type Quality } from "@/lib/chordForms";
import { useSketch } from "@/features/sketch/useSketch";
import { useSketchStore } from "@/store/sketchStore";
import { track, trackToast } from "@/lib/telemetry";
import { exportPng } from "@/lib/export/png";
import { chordToMidi } from "@/lib/music/chordParser";
import Toast from "@/components/Toast.client";
import { useCtaMessages } from "@/hooks/useCtaMessages";
import { useSearchParams } from "next/navigation";
import { useLocale } from "@/contexts/LocaleContext";
import ChordBuilder from "@/components/ChordBuilder";

export default function FindKeyPage() {
  const CTA_MESSAGES = useCtaMessages();
  const { isJapanese } = useLocale();
  const searchParams = useSearchParams();
  const rootRowRef = useRef<HTMLDivElement | null>(null);
  useRovingTabs(rootRowRef, { orientation: "horizontal" });
  const fbToggleRef = useRef<HTMLDivElement | null>(null);
  useRovingTabs(fbToggleRef, { orientation: "horizontal" });
  const presetRef = useRef<HTMLDivElement | null>(null);
  useRovingTabs(presetRef, { orientation: "horizontal" });
  const exportRef = useRef<HTMLDivElement | null>(null);
  const exportCardRef = useRef<HTMLDivElement | null>(null);
  // スロット固定の進行（空は空文字）。初期値は C–Am–F–G を 1〜4 に配置
  const [slots, setSlots] = useState<string[]>(() => {
    const a = new Array(12).fill("");
    a[0] = "C"; a[1] = "Am"; a[2] = "F"; a[3] = "G";
    return a;
  });
  // 表示用の詰めた配列と、元スロットのインデックス
  const filledIndices = useMemo(() => slots.reduce((acc:number[], v, i)=>{ if (v) acc.push(i); return acc; }, [] as number[]), [slots]);
  const progression = useMemo(() => filledIndices.map(i => slots[i]), [filledIndices, slots]);
  // 追加入力のカーソル位置（次の空スロット）
  const firstEmpty = useMemo(() => { const idx = slots.findIndex(s => !s); return idx === -1 ? 11 : idx; }, [slots]);
  const [cursorIndex, setCursorIndex] = useState<number>(0);
  useEffect(() => { setCursorIndex(firstEmpty); }, [firstEmpty]);
  const ROOTS = useMemo(() => [
    'C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B'
  ], []);
  const QUALITIES = useMemo(() => [
    { label: 'M', value: '' },
    { label: 'M7', value: 'maj7' },
    { label: '7', value: '7' },
    { label: '6', value: '6' },
    { label: 'add9', value: 'add9' },
    { label: 'sus4', value: 'sus4' },
    { label: 'sus2', value: 'sus2' },
    { label: 'm', value: 'm' },
    { label: 'm7', value: 'm7' },
    { label: 'dim', value: 'dim' },
    { label: 'm7b5', value: 'm7b5' },
    { label: 'aug', value: 'aug' },
  ], []);
  const [rootSel, setRootSel] = useState<string>('C');
  const [qualitySel, setQualitySel] = useState<string>('M');
  const [modifiers, setModifiers] = useState<string[]>([]);
  const TENSIONS = useMemo(() => [
    { label: 'sus2', value: 'sus2' },
    { label: 'sus4', value: 'sus4' },
    { label: 'add9', value: 'add9' },
    { label: 'add11', value: 'add11' },
    { label: 'add13', value: 'add13' },
  ], []);
  const [tensionsSel, setTensionsSel] = useState<string[]>([]);
  const [bassSel, setBassSel] = useState<string>('');

  const composeChord = (root: string, quality: string, tensions: string[], bass: string) => {
    if (!root) return '';
    const qualityPart = quality || '';
    const tensionPart = tensions.length ? tensions.join('') : '';
    const chord = `${root}${qualityPart}${tensionPart}`;
    return bass ? `${chord}/${bass}` : chord;
  };

  const toggleTension = (val: string) => {
    setTensionsSel((prev) => prev.includes(val) ? prev.filter(v => v !== val) : [...prev, val]);
  };
  const [result, setResult] = useState<ReturnType<typeof analyzeChordProgression> | null>(null);
  const [keys, setKeys] = useState<ReturnType<typeof rankKeys>>([]);
  const [scales, setScales] = useState<ScaleRank[]>([]);
  const [selectedScaleRank, setSelectedScaleRank] = useState<ScaleRank | null>(null);
  const [romanLine, setRomanLine] = useState<string[]>([]);
  const { keyCandidates, selectedKey: selFromStore, analyze: runAnalyze, selectKey, scaleCandidates, selectedScale, selectScale, reset: resetAnalysis } = useAnalysisStore();
  const [fbDisplay, setFbDisplay] = useState<'degrees'|'names'>('degrees');
  const [selectedCellId, setSelectedCellId] = useState<string | null>(null);
  const [overlayChordNotes, setOverlayChordNotes] = useState<string[]|null>(null);
  const [formsPop, setFormsPop] = useState<null | { at:{x:number;y:number}; rootPc:number; quality:Quality }>(null);
  const [formShape, setFormShape] = useState<FormShape | null>(null);
  const resetForms = useCallback(() => { setFormsPop(null); setFormShape(null); }, []);

  // 古いスケールIDを新しいスケールIDにマッピング
  const mapOldScaleToNewId = (oldId: string): NewScaleId => {
    const mapping: Record<string, NewScaleId> = {
      'Ionian': 'major',
      'Aeolian': 'naturalMinor',
      'Dorian': 'dorian',
      'Phrygian': 'phrygian',
      'Lydian': 'lydian',
      'Mixolydian': 'mixolydian',
      'Locrian': 'locrian',
      'MajorPentatonic': 'majPent',
      'MinorPentatonic': 'minPent',
      'Blues': 'bluesMinor',
      'HarmonicMinor': 'harmonicMinor',
      'MelodicMinor': 'melodicMinor',
      'DiminishedWH': 'dimWholeHalf',
      'DiminishedHW': 'dimHalfWhole',
      'Lydianb7': 'lydianb7',
      'Mixolydianb6': 'mixolydianb6',
      'PhrygianDominant': 'phrygDominant',
      'Altered': 'altered',
      'WholeTone': 'wholeTone'
    };
    return mapping[oldId] || 'major';
  };
  const isHeptatonic = useMemo(() => {
    const t = selectedScale?.type as any;
    const ivs = t ? (SCALE_INTERVALS as any)[t] : null;
    return !ivs || ivs.length === 7;
  }, [selectedScale?.type]);
  useEffect(() => {
    if (!isHeptatonic && fbDisplay !== 'degrees') setFbDisplay('degrees');
  }, [isHeptatonic]);
  const [selectedKey, setSelectedKey] = useState<{ tonic: string; mode: RomanMode } | null>(null);
  const gridRef = useRef<HTMLDivElement | null>(null);
  const leftWrapRef = useRef<HTMLDivElement | null>(null);
  const resultRef = useRef<HTMLElement | null>(null);
  const rightRef = useRef<HTMLElement | null>(null);
  const [dragIndex, setDragIndex] = useState<number | null>(null);
  
  // Mobile touch drag support
  const touchStartRef = useRef<{ index: number; startX: number; startY: number } | null>(null);
  const dragPreviewRef = useRef<HTMLDivElement | null>(null);
  
  // Playback state
  const [isPlaying, setIsPlaying] = useState(false);
  const [bpm, setBpm] = useState(120);
  const playbackTimerRef = useRef<NodeJS.Timeout | null>(null);
  const [currentChordIndex, setCurrentChordIndex] = useState<number>(-1);
  
  const moveSlot = useCallback((from: number, to: number) => {
    setSlots(prev => {
      if (from === to) return prev;
      const arr = prev.slice();
      const tmp = arr[from];
      arr[from] = arr[to];
      arr[to] = tmp;
      return arr;
    });
  }, []);

  // Mobile drag handlers
  const [touchDragTarget, setTouchDragTarget] = useState<number | null>(null);
  
  const handleTouchStartDrag = useCallback((e: React.TouchEvent, i: number) => {
    if (!slots[i]) return; // Only drag filled slots
    e.stopPropagation();
    const touch = e.touches[0];
    touchStartRef.current = { index: i, startX: touch.clientX, startY: touch.clientY };
    setDragIndex(i);
    setTouchDragTarget(null);
  }, [slots]);

  const handleTouchMoveDrag = useCallback((e: React.TouchEvent, currentIndex: number) => {
    if (touchStartRef.current === null || dragIndex === null) return;
    
    const touch = e.touches[0];
    const element = document.elementFromPoint(touch.clientX, touch.clientY);
    
    // Find the slot element
    let slotElement = element;
    while (slotElement && !slotElement.hasAttribute('data-slot-index')) {
      slotElement = slotElement.parentElement;
    }
    
    if (slotElement) {
      const targetIndex = parseInt(slotElement.getAttribute('data-slot-index') || '-1');
      if (targetIndex >= 0 && targetIndex !== dragIndex) {
        setTouchDragTarget(targetIndex);
      }
    }
  }, [dragIndex]);

  const handleTouchEndDrag = useCallback((e: React.TouchEvent) => {
    if (touchStartRef.current !== null && dragIndex !== null && touchDragTarget !== null && dragIndex !== touchDragTarget) {
      moveSlot(dragIndex, touchDragTarget);
    }
    touchStartRef.current = null;
    setDragIndex(null);
    setTouchDragTarget(null);
  }, [dragIndex, touchDragTarget, moveSlot]);
  
  // Playback state flag to ensure stopPlayback is effective
  const isPlayingRef = useRef(false);
  
  // Playback functions
  const stopPlayback = useCallback(() => {
    isPlayingRef.current = false;
    if (playbackTimerRef.current) {
      clearInterval(playbackTimerRef.current);
      playbackTimerRef.current = null;
    }
    setIsPlaying(false);
    setCurrentChordIndex(-1);
  }, []);
  
  const startPlayback = useCallback(async () => {
    const filledSlots = slots.map((s, i) => ({ chord: s, index: i })).filter(x => x.chord);
    if (filledSlots.length === 0) return;
    
    // 前回の再生が残っていたら確実に停止
    stopPlayback();
    
    await player.resume();
    isPlayingRef.current = true;
    setIsPlaying(true);
    setCurrentChordIndex(0);
    
    // Count-in: simple metronome click
    const countInBeats = 4;
    const beatDuration = (60 / bpm) * 1000;
    
    for (let i = 0; i < countInBeats; i++) {
      if (!isPlayingRef.current) return; // 停止されたらカウントイン中でも中断
      await new Promise(resolve => setTimeout(resolve, beatDuration));
      if (!isPlayingRef.current) return;
      // Play a simple click sound (high MIDI note, short duration)
      player.playNote(84, 100); // C6, 100ms
    }
    
    // Start progression playback (4 beats per chord)
    let chordIdx = 0;
    let beatCount = 0;
    const playBeat = async () => {
      if (!isPlayingRef.current) {
        // 停止フラグが立っていたらタイマーをクリア
        if (playbackTimerRef.current) {
          clearInterval(playbackTimerRef.current);
          playbackTimerRef.current = null;
        }
        return;
      }
      if (beatCount % 4 === 0) {
        // New chord every 4 beats
        if (chordIdx >= filledSlots.length) {
          chordIdx = 0; // Loop
        }
        const { chord, index } = filledSlots[chordIdx];
        setCurrentChordIndex(index);
        await playChordSymbol(chord);
        chordIdx++;
      } else {
        // Re-trigger the same chord
        if (chordIdx > 0 && chordIdx <= filledSlots.length) {
          const { chord } = filledSlots[chordIdx - 1];
          await playChordSymbol(chord);
        }
      }
      beatCount++;
    };
    
    if (!isPlayingRef.current) return;
    await playBeat(); // Play first beat immediately
    if (!isPlayingRef.current) return;
    playbackTimerRef.current = setInterval(playBeat, beatDuration);
    
    track('progression_play', { page: 'chord_progression', bpm, chordCount: filledSlots.length });
  }, [slots, bpm, stopPlayback]);
  
  const togglePlayback = useCallback(() => {
    if (isPlaying) {
      stopPlayback();
    } else {
      startPlayback();
    }
  }, [isPlaying, startPlayback, stopPlayback]);
  
  // Stop playback when component unmounts or slots change
  useEffect(() => {
    return () => {
      if (playbackTimerRef.current) {
        clearInterval(playbackTimerRef.current);
      }
    };
  }, []);
  
  useEffect(() => {
    if (isPlaying) {
      stopPlayback();
    }
  }, [slots]);
  
  const removeSlot = useCallback((idx: number) => {
    setSlots(prev => { const arr = prev.slice(); arr[idx] = ""; return arr; });
  }, []);
  const { isPro } = usePro();
  // Debug: Log isPro value
  console.log('[debug] isPro in page:', isPro);
  const { sketch, setSketch } = useSketch(isPro);
  const sketchIdRef = useRef<string | null>(null);
  const ensureSketchId = () => { if (!sketchIdRef.current) sketchIdRef.current = Math.random().toString(36).slice(2, 10); return sketchIdRef.current; };
  const { sketches, loadSketches, deleteSketch, saveSketch } = useSketchStore();
  const [showSketchList, setShowSketchList] = useState(false);
  const [selectedSketchForAction, setSelectedSketchForAction] = useState<any>(null);
  const sketchesDropRef = useRef<HTMLDivElement | null>(null);
  const [sketchName, setSketchName] = useState<string>("");
  
  // Preset popup state
  const [showPresetPopup, setShowPresetPopup] = useState(false);
  const [presetKey, setPresetKey] = useState<string>('C');
  const presetPopupRef = useRef<HTMLDivElement>(null);
  useEffect(() => { if (showSketchList) loadSketches(); }, [showSketchList, loadSketches]);
  useEffect(() => {
    const onDown = (e: MouseEvent) => {
      if (!showSketchList) return;
      const el = sketchesDropRef.current;
      if (el && !el.contains(e.target as Node)) setShowSketchList(false);
    };
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') setShowSketchList(false); };
    document.addEventListener('mousedown', onDown);
    document.addEventListener('keydown', onKey);
    return () => { document.removeEventListener('mousedown', onDown); document.removeEventListener('keydown', onKey); };
  }, [showSketchList]);
  
  // Close preset popup on outside click or ESC
  useEffect(() => {
    if (!showPresetPopup) return;
    const onDown = (e: MouseEvent) => {
      const el = presetPopupRef.current;
      if (el && !el.contains(e.target as Node)) setShowPresetPopup(false);
    };
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') setShowPresetPopup(false); };
    document.addEventListener('mousedown', onDown);
    document.addEventListener('keydown', onKey);
    return () => { document.removeEventListener('mousedown', onDown); document.removeEventListener('keydown', onKey); };
  }, [showPresetPopup]);

  // Save（Result内のプロンプト）
  const [showNamePrompt, setShowNamePrompt] = useState(false);
  const [nameInput, setNameInput] = useState("");
  const defaultSketchName = useMemo(() => (progression.length ? progression.join(" ") : `Untitled ${new Date().toLocaleString()}`), [progression]);

  // M3.5: Toast notifications
  const [toastConfig, setToastConfig] = useState<{
    message: string;
    type: 'info' | 'success' | 'warning';
    ctaText?: string;
    ctaHref?: string;
    ctaPlace?: 'limit_toast' | 'png_toast';
  } | null>(null);

  const toastShownRef = useRef<Set<string>>(new Set());

  // M3.5: Show toast when reaching 9-12 chords
  useEffect(() => {
    const filledCount = slots.filter(s => s !== "").length;
    if (filledCount === 9 && !toastShownRef.current.has('limit_warn')) {
      setToastConfig({
        message: CTA_MESSAGES.toast.limitWarn,
        type: 'info',
        ctaText: CTA_MESSAGES.toast.ctaButton,
        ctaHref: '/ios-coming-soon',
        ctaPlace: 'limit_toast'
      });
      trackToast('limit_warn', { page: 'chord_progression', chordCount: filledCount });
      toastShownRef.current.add('limit_warn');
    } else if (filledCount === 12 && !toastShownRef.current.has('limit_block')) {
      setToastConfig({
        message: CTA_MESSAGES.toast.limitBlock,
        type: 'warning',
        ctaText: CTA_MESSAGES.toast.ctaButton,
        ctaHref: '/ios-coming-soon',
        ctaPlace: 'limit_toast'
      });
      trackToast('limit_block', { page: 'chord_progression', chordCount: filledCount });
      toastShownRef.current.add('limit_block');
    }
  }, [slots]);
  
  // M3.5: Current sketch name for PNG export
  const [currentExportName, setCurrentExportName] = useState<string>("");

  const handleExportSketch = async (sk: any) => {
    try {
      // Sketchのデータからエクスポートカードを一時的に生成してPNG出力
      if (!exportCardRef.current) return;
      
      // Set the sketch name for export
      setCurrentExportName(sk.name || "Untitled Sketch");
      
      // Wait for state update
      await new Promise(resolve => setTimeout(resolve, 50));
      
      // 一時的にopacityを1にしてレンダリング
      const exportCard = exportCardRef.current;
      exportCard.style.opacity = '1';
      exportCard.style.visibility = 'visible';
      
      // レンダリング完了を待つ
      await new Promise(resolve => setTimeout(resolve, 200));
      
      // PNG出力
      await exportPng(exportCard, 'auto');
      
      // 元に戻す
      exportCard.style.opacity = '0.0001';
      exportCard.style.visibility = 'hidden';
      setCurrentExportName("");
      
      track('export_png', { page: 'chord_progression', source: 'sketch', id: sk.id });

      // M3.5: Show toast after PNG export
      if (!toastShownRef.current.has('png_export')) {
        setToastConfig({
          message: CTA_MESSAGES.toast.pngExport,
          type: 'success',
          ctaText: CTA_MESSAGES.toast.ctaButton,
          ctaHref: '/ios-coming-soon',
          ctaPlace: 'png_toast'
        });
        toastShownRef.current.add('png_export');
      }
    } catch (e) {
      console.error('Export failed:', e);
      setCurrentExportName("");
    }
  };
  
  const doSaveSketch = async () => {
    try {
      // M3.5: Check Free limit BEFORE saving (directly from localStorage)
      if (!isPro) {
        const existingSketches = JSON.parse(localStorage.getItem('ot_sketches') || '[]');
        console.log('[DEBUG] doSaveSketch - isPro:', isPro, 'existing sketches:', existingSketches.length);
        
        if (existingSketches.length >= 3) {
          console.log('[DEBUG] Blocking save - limit reached');
          setShowNamePrompt(false);
          setNameInput("");
          setToastConfig({
            message: CTA_MESSAGES.toast.sketchLimit,
            type: 'warning',
            ctaText: CTA_MESSAGES.toast.ctaButton,
            ctaHref: '/ios-coming-soon',
            ctaPlace: 'limit_toast'
          });
          trackToast('limit_block', { page: 'chord_progression', context: 'sketch_limit' });
          return;
        }
      }
      
      console.log('[DEBUG] Proceeding with save');

      const tonicGuess = (selFromStore ? PITCHES[selFromStore.tonic] : (selectedKey ? selectedKey.tonic : 'C')) as string;
      const scaleGuess = (selectedScale?.type as any) || (selFromStore ? (selFromStore.mode as any) : 'Ionian');
      const name = (nameInput.trim() || defaultSketchName).slice(0, 48);
      const data: any = {
        name,
        schema: 'sketch_v1',
        appVersion: '3.0.0',
        key: { tonic: tonicGuess, scaleId: String(scaleGuess) },
        capo: { fret: 0, note: 'Shaped' },
        progression: { items: progression.map((c, i) => ({ id: c, degree: '', quality: '' })) },
        fretboardView: { mode: fbDisplay === 'names' ? 'Names' : 'Degrees', guide: !!overlayChordNotes },
      };
      const r = await saveSketch(data);
      track('save_project', { page: 'chord_progression', ok: r?.ok });
      setShowNamePrompt(false); setNameInput("");
    } catch {}
  };
  const [showAdv, setShowAdv] = useState<boolean>(false);
  const [showUpgrade, setShowUpgrade] = useState<boolean>(false);
  const [addedFlash, setAddedFlash] = useState<boolean>(false);
  const [isAnalyzing, startAnalyze] = useTransition();
  const [patternHits, setPatternHits] = useState<{id:string;name:string;summary:string;start:number;end:number}[]>([]);
  type CadenceView = { type: CadenceType; tail?: { from?: string; to?: string } };
  const [cadences, setCadences] = useState<CadenceView[]>([]);
  // Romanハイライト: 範囲(start<=i<end)を保持
  const [romanHL, setRomanHL] = useState<{ start: number; end: number } | null>(null);
  // Romanボックスをスクロール対象に
  const romanBoxRef = useRef<HTMLDivElement | null>(null);
  // Romanの小文字(i,v,x)だけを大文字化。括弧の中だけに適用するユーティリティ。
  function upperRomansInParens(name: string): string {
    return name.replace(/\(([^)]+)\)/g, (_: any, inner: string) => {
      const up = inner.replace(/[ivx]+/g, (m: string) => m.toUpperCase());
      return `(${up})`;
    });
  }
  type ProgItem = { root: string; quality: string };
  const parseProg = (arr: string[]): ProgItem[] => arr.map((t) => {
    const m = t.match(/^([A-G](?:#|b)?)(.*)$/);
    return { root: m?.[1] || t, quality: (m?.[2] || '') };
  });

  // Quick: ベース品質の“選択のみ”
  const onPickBase = (q: string) => {
    setQualitySel(q);
    // ベース変更で矛盾する modifier は自動クリア
    setModifiers((prev) => prev.filter((m) => isCompatible(getBaseKind(q), m)));
    if (bassSel === rootSel) setBassSel('');
  };

  // Advanced: 要素のトグル（Pro以外はアップグレード誘導）
  const toggleModifier = (m: string) => {
    if (!isPro) { setShowUpgrade(true); return; }
    if (!isCompatible(getBaseKind(qualitySel), m)) return;
    setModifiers((prev) => (prev.includes(m) ? prev.filter((x) => x !== m) : [...prev, m]));
  };

  // Slash: ノートのみ（同音/同じノートで解除）
  const onPickBass = (n: string) => {
    if (!isPro) { setShowUpgrade(true); return; }
    if (n === rootSel || n === bassSel) setBassSel(''); else setBassSel(n);
  };
  
  // Preset helper: Roman numerals to actual chords based on key
  const applyPreset = (presetName: string, romans: string[], key: string) => {
    const keyPc = noteToPc(key);
    if (keyPc === undefined || keyPc < 0 || keyPc > 11) return;
    
    // プリセットは基本的にMajor keyで定義されている
    // （将来的にMinorプリセットを追加する場合は、ここで判定ロジックを追加）
    const mode: Mode = "Major";
    
    // theory.tsのromanToChordSymbol関数を使用（文脈化された変換）
    const chords = romans.map(roman => romanToChordSymbol(roman, keyPc, mode));
    
    // Append to existing progression (find first empty slot)
    setSlots(prev => {
      const arr = [...prev];
      let insertIdx = arr.findIndex(s => !s); // Find first empty slot
      if (insertIdx === -1) insertIdx = 0; // If all full, start from beginning
      
      chords.forEach((c, i) => {
        const targetIdx = (insertIdx + i) % 12;
        arr[targetIdx] = c;
      });
      return arr;
    });
    
    // Move cursor to next empty slot or wrap around
    setCursorIndex(prev => {
      const arr = [...slots];
      chords.forEach((c, i) => {
        const insertIdx = arr.findIndex(s => !s);
        if (insertIdx === -1) return 0;
        const targetIdx = (insertIdx + i) % 12;
        arr[targetIdx] = c;
      });
      const nextEmpty = arr.findIndex(s => !s);
      return nextEmpty === -1 ? 0 : nextEmpty;
    });
    
    // Don't auto-analyze - user must click Analyze button
    track('preset_inserted', { page: 'chord_progression', preset: presetName });
    setShowPresetPopup(false);
  };

  const analyze = () => {
    const res = analyzeChordProgression(progression);
    setResult(res);
    const ranked = rankKeys(progression);
    setKeys(ranked.slice(0,4));
    if (ranked.length > 0) {
      const mode: RomanMode = ranked[0].mode === "Major" ? "major" : "minor";
      const keyName = ranked[0].label.split(" ")[0];
      const sel = { tonic: keyName, mode } as const;
      setSelectedKey(sel);
      setRomanLine(progression.map(c => toRoman(c, sel.tonic, sel.mode, { showQuality: true, uppercase: true })));
    } else {
      setScales([]);
      setSelectedKey(null);
      setRomanLine([]);
    }
    // store-based analysis for Top3 candidates
    runAnalyze(progression);
    
    // Auto-scroll to result section
    setTimeout(() => {
      const resultElement = document.getElementById('result');
      if (resultElement) {
        resultElement.scrollIntoView({ 
          behavior: 'smooth', 
          block: 'start' 
        });
      }
    }, 100);
  };

  useEffect(() => {
    const current = selFromStore || selectedKey;
    if (!current) return;
    const tonic = typeof (current as any).tonic === 'number' ? PITCHES[(current as any).tonic] : (current as any).tonic;
    const mode = ((current as any).mode === 'Major' || (current as any).mode === 'Minor') ? ((current as any).mode === 'Major' ? 'major' : 'minor') : (current as any).mode;
    setRomanLine(progression.map(c => toRoman(c, tonic, mode as RomanMode, { showQuality: true, uppercase: true })));
  }, [selFromStore, selectedKey, progression]);

  // Roman pattern detection
  useEffect(() => {
    if (!selectedKey || romanLine.length === 0) { setPatternHits([]); return; }
    const mode = (selectedKey.mode as any) as 'major'|'minor';
    setPatternHits(matchPatterns(romanLine, mode));
  }, [romanLine, selectedKey]);

  // Cadence detection (rule-based; normalize tokens + loop-boundary)
  useEffect(() => {
    if (!romanLine || romanLine.length === 0) { setCadences([]); return; }
    const norm = romanLine.map((t) => {
      const m = t.replace(/\s+/g, "").match(/^(b|#)?([ivIV]+)(?:[°ø].*)?/);
      if (!m) return t.toUpperCase();
      const acc = m[1] ?? "";
      const core = (m[2] ?? "").toUpperCase();
      return `${acc}${core}`;
    });
    let raw: any = null;
    try { raw = (detectCadence as any)(norm); } catch {}
    const arr: any[] = Array.isArray(raw) ? raw : (raw ? [raw] : []);
    const views: CadenceView[] = arr.map((r) => {
      if (typeof r === 'string') return { type: r as CadenceType };
      const type = (r?.type ?? r) as CadenceType;
      const tail = r?.tailRoman ?? (r?.pair ? { from: r.pair[0], to: r.pair[1] } : undefined);
      return { type, tail };
    });
    if (norm.length >= 2) {
      const last = norm[norm.length - 1];
      const first = norm[0];
      if (!views.some(v => v.type === 'perfect') && last === 'V' && first === 'I')
        views.push({ type: 'perfect', tail: { from: 'V', to: 'I' } });
      if (!views.some(v => v.type === 'deceptive') && last === 'V' && first === 'VI')
        views.push({ type: 'deceptive', tail: { from: 'V', to: 'vi' } });
    }
    setCadences(views);
  }, [romanLine]);

  // Fallback cadence (render-time) in case state-based detection fails
  const fallbackCadence = useMemo(() => {
    if (!romanLine || romanLine.length === 0) return null as { type: CadenceType; tail?: {from?:string; to?:string} } | null;
    const norm = romanLine.map((t) => {
      const m = t.replace(/\s+/g, "").match(/^(b|#)?([ivIV]+)(?:[°ø].*)?/);
      if (!m) return t.toUpperCase();
      const acc = m[1] ?? "";
      const core = (m[2] ?? "").toUpperCase();
      return `${acc}${core}`;
    });
    if (norm.length < 2) return null;
    const first = norm[0];
    const last = norm[norm.length - 1];
    if (last === 'V' && first === 'I') return { type: 'perfect' as CadenceType, tail: { from: 'V', to: 'I' } };
    if (last === 'V' && first === 'VI') return { type: 'deceptive' as CadenceType, tail: { from: 'V', to: 'vi' } };
    if (last === 'V') return { type: 'half' as CadenceType, tail: { from: undefined, to: 'V' } };
    return null;
  }, [romanLine]);

  useEffect(() => {
    const compute = () => {
      if (!gridRef.current || !leftWrapRef.current || !resultRef.current) return;
      // Desktopのみmin-heightを計算。モバイルはstickyを使わないため0に戻す。
      const isDesktop = typeof window !== 'undefined' && window.matchMedia && window.matchMedia('(min-width: 1024px)').matches;
      if (!isDesktop) {
        leftWrapRef.current.style.minHeight = '0px';
        return;
      }
      // ループで伸び続けないよう、測定前に一旦0へ戻してから距離を測る
      const prevMin = leftWrapRef.current.style.minHeight;
      leftWrapRef.current.style.minHeight = '0px';
      // 強制リフローでレイアウト確定
      void leftWrapRef.current.offsetHeight;
      const gridTop = gridRef.current.getBoundingClientRect().top + window.scrollY;
      const rightBottom = rightRef.current ? (rightRef.current.getBoundingClientRect().bottom + window.scrollY) : 0;
      const resultTop = resultRef.current.getBoundingClientRect().top + window.scrollY;
      // two-col の下端を #result の直前に一致させる。誤差はceilで吸収
      const stopY = Math.max(rightBottom, resultTop);
      const minH = Math.max(0, Math.ceil(stopY - gridTop));
      const prevNum = parseFloat(prevMin || '0');
      if (Math.abs(minH - prevNum) > 1) {
        leftWrapRef.current.style.minHeight = `${minH}px`;
      }
    };
    // 初期・安定後
    requestAnimationFrame(compute);
    const t = setTimeout(compute, 120);
    // リサイズはデバウンス
    let rto: any = null;
    const onResize = () => {
      if (rto) clearTimeout(rto);
      rto = setTimeout(compute, 120);
    };
    window.addEventListener('resize', onResize);
    window.addEventListener('orientationchange', onResize);
    window.addEventListener('load', compute);
    // 右パネルサイズ変化を監視（デバウンス付き）
    let ro: ResizeObserver | null = null;
    let roResult: ResizeObserver | null = null;
    if (typeof ResizeObserver !== 'undefined' && rightRef.current) {
      let rt: any = null;
      ro = new ResizeObserver(() => {
        if (rt) clearTimeout(rt);
        rt = setTimeout(compute, 100);
      });
      ro.observe(rightRef.current);
    }
    if (typeof ResizeObserver !== 'undefined' && resultRef.current) {
      let rt2: any = null;
      roResult = new ResizeObserver(() => {
        if (rt2) clearTimeout(rt2);
        rt2 = setTimeout(compute, 100);
      });
      roResult.observe(resultRef.current);
    }
    return () => {
      clearTimeout(t);
      if (rto) clearTimeout(rto);
      window.removeEventListener('resize', onResize);
      window.removeEventListener('orientationchange', onResize);
      window.removeEventListener('load', compute);
      if (ro) ro.disconnect();
      if (roResult) roResult.disconnect();
    };
  }, []);

  // コンテンツが変わったときにも軽く再同期
  useEffect(() => {
    if (!leftWrapRef.current) return;
    const isDesktop = typeof window !== 'undefined' && window.matchMedia && window.matchMedia('(min-width: 1024px)').matches;
    if (!isDesktop) return;
    // 次フレームで再計算
    requestAnimationFrame(() => {
      const evt = new Event('resize');
      window.dispatchEvent(evt);
    });
  }, [result, showAdv, progression.length]);
  const previewLabel = (qualitySel === 'M' ? `${rootSel}` : `${rootSel}${qualitySel}`)
    + (modifiers.length ? ` ${modifiers.join(' ')}` : '')
    + (bassSel ? `/${bassSel}` : '');
  const previewPlay = async () => {
    if (!rootSel) return;
    const pc = PITCHES.indexOf(rootSel as any);
    if (pc < 0) return;
    const base = 60 + pc; // C4基準
    const q = qualitySel.toLowerCase();
    const has = (m: string) => modifiers.includes(m);
    let intervals: number[] = [0,4,7];
    if (q.includes('m') && !q.includes('maj')) intervals = [0,3,7];
    if (q.includes('dim')) intervals = [0,3,6];
    if (q.includes('maj7') || q.includes('mmaj7')) intervals = [...(q.includes('m')?[0,3,7]:[0,4,7]), 11];
    else if (q.includes('7')) intervals = [0,4,7,10];
    if (has('sus2')) intervals = [0,2,7];
    if (has('sus4')) intervals = [0,5,7];
    const midis = intervals.map(iv => base + (iv%12));
    try { await player.resume(); player.playChord(midis, 'lightStrum', 300); } catch {}
  };
  // 現在の編集内容をSketchへ反映（3秒アイドルで自動保存）
  useEffect(() => {
    try {
      const id = ensureSketchId();
      const name = progression.length ? progression.join(" ").slice(0, 48) : `Untitled ${new Date().toLocaleString()}`;
      const tonicGuess = (selFromStore ? PITCHES[selFromStore.tonic] : (selectedKey ? selectedKey.tonic : 'C')) as string;
      const scaleGuess = (selectedScale?.type as any) || (selFromStore ? selFromStore.mode : 'Ionian');
      setSketch({
        id,
        name,
        createdAt: sketch?.createdAt || new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        schema: 'sketch_v1',
        appVersion: '3.0.0',
        key: { tonic: tonicGuess, scaleId: String(scaleGuess) },
        capo: { fret: 0, note: 'Shaped' as any },
        progression: { items: progression.map((c, i) => ({ id: `${i+1}-${c}`, degree: '', quality: '' })) },
        fretboardView: { mode: fbDisplay === 'names' ? 'Names' : 'Degrees', guide: !!overlayChordNotes },
      } as any);
    } catch {}
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [slots, fbDisplay, overlayChordNotes, selFromStore, selectedKey, selectedScale]);
  // モバイル判定（SSRと一致させるため初期false、マウント後に判定）
  const [isTouchDevice, setIsTouchDevice] = useState(false);
  useEffect(() => {
    try {
      const touch = ('ontouchstart' in window) || ((navigator as any)?.maxTouchPoints ?? 0) > 0;
      setIsTouchDevice(!!touch);
    } catch { setIsTouchDevice(false); }
  }, []);

  // 進行チップ（"C", "Am", "F"...）を簡易解析して発音
  const playChordSymbol = async (symbol: string) => {
    try {
      await player.resume();
      const midis = chordToMidi(symbol);
      if (midis && midis.length > 0) {
        player.playChord(midis, 'lightStrum', 300);
      }
    } catch (error) {
      console.error('Failed to play chord:', symbol, error);
    }
  };
  return (
    <main ref={exportRef as any} className="ot-page ot-stack" data-page="find-key">
      {/* Progression card: iOS風シンプルデザイン */}
      <section id="progression" className={"ot-card"}>
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <H2 className="mb-0 text-left">{isJapanese ? "コード進行を作る" : "Build progression"}</H2>
              <InfoDot
                title={isJapanese ? "コード進行を作る" : "Build Progression"}
                text={isJapanese 
                  ? "コードを選ぶからコードを選んでスロットに追加ボタンから追加してください。上部のプリセットからコード進行を選択して追加することもできます。"
                  : "Select chords from Choose Chords and add them using the slot add button. You can also select chord progressions from the presets at the top to add them."
                }
              />
            </div>
          <div className="flex items-center gap-3">
              {/* Reset, Sketches - iOS風ボタン */}
            <button
                type="button"
                className="chip text-sm px-4 py-2 inline-flex items-center gap-2"
                title="Reset progression"
                onClick={() => {
                  setSlots(Array(12).fill(""));
                  setCursorIndex(0);
                  resetAnalysis();
                  setKeys([]);
                  setResult(null);
                  setOverlayChordNotes(null);
                  setSelectedCellId(null);
                  setFbDisplay('degrees');
                }}
              >
                <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                  <path d="M12 5V2L7 7l5 5V9c2.76 0 5 2.24 5 5a5 5 0 1 1-5-5z"/>
                </svg>
                <span>{isJapanese ? "リセット" : "Reset"}</span>
              </button>
              <button
                type="button"
                className="chip inline-flex items-center gap-2 px-4 py-2"
                title="Show sketches"
                onClick={() => setShowSketchList(v=>!v)}
                aria-expanded={showSketchList}
              >
                <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M3 6h18v2H3V6zm0 5h18v2H3v-2zm0 5h12v2H3v-2z"/></svg>
                {isJapanese ? "My進行" : "Sketches"}
              </button>
              {showSketchList && (
                <div ref={sketchesDropRef} className="fixed right-4 top-20 z-[10000] w-[320px] max-h-[70vh] overflow-auto rounded-md border bg-white dark:bg-neutral-900 shadow-2xl p-2 space-y-2">
                  {sketches.length === 0 ? (
                    <div className="text-xs opacity-70 p-2">{isJapanese ? "まだ進行がありません" : "No sketches yet"}</div>
                  ) : (
                    sketches.map((sk) => (
                      <div key={sk.id} className="flex items-center justify-between gap-2 px-2 py-1 rounded hover:bg-black/5 dark:hover:bg-white/10">
                        <button
                          className="text-left text-sm flex-1 truncate"
                          title={`${sk.name}`}
                          onClick={() => setSelectedSketchForAction(sk)}
                        >
                          {sk.name}
                        </button>
                        <button
                          className="ot-btn-ghost text-xs"
                          title="Delete"
                          onClick={(e) => { e.stopPropagation(); deleteSketch(sk.id); loadSketches(); track('project_delete', { page: 'chord_progression', id: sk.id }); }}
                        >
                          🗑️
            </button>
          </div>
                    ))
                  )}
                </div>
              )}
              
              {/* スペース */}
              <div className="w-4" aria-hidden="true"></div>
              
              {/* iOS風再生コントロール */}
              <div className="flex items-center gap-3">
                <button
                  type="button"
                  className="chip px-4 py-2 inline-flex items-center gap-2"
                  title={isPlaying ? "Stop playback" : "Play progression"}
                  onClick={togglePlayback}
                  disabled={progression.length === 0}
                  style={{ opacity: progression.length === 0 ? 0.5 : 1 }}
                >
                  {isPlaying ? (
                    <>
                      <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                        <rect x="5" y="5" width="14" height="14" rx="1"/>
                      </svg>
                      <span>{isJapanese ? "停止" : "Stop"}</span>
                    </>
                  ) : (
                    <>
                      <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M8 5v14l11-7z"/>
                      </svg>
                      <span>{isJapanese ? "再生" : "Play"}</span>
                    </>
                  )}
                </button>
                <div className="flex items-center gap-2">
                  <label htmlFor="bpm-input" className="text-sm font-medium">BPM:</label>
                  <input
                    id="bpm-input"
                    type="number"
                    min="40"
                    max="240"
                    value={bpm}
                    onChange={(e) => setBpm(Math.max(40, Math.min(240, parseInt(e.target.value) || 120)))}
                    className="w-20 px-3 py-1 text-sm rounded-lg border bg-transparent"
                    disabled={isPlaying}
                  />
                </div>
              </div>
              
              <select
                className="chip px-4 py-2"
                aria-label="Instrument"
                defaultValue={(typeof window!=="undefined" ? (localStorage.getItem('ot-instrument') || 'acoustic_guitar_steel') : 'acoustic_guitar_steel') as string}
                onChange={async (e)=>{ const v = e.currentTarget.value as any; await player.setInstrument(v); }}
              >
                <option value="acoustic_guitar_steel">{isJapanese ? "アコースティックギター" : "Acoustic Steel"}</option>
                <option value="acoustic_guitar_nylon">{isJapanese ? "クラシックギター" : "Acoustic Nylon"}</option>
                <option value="electric_guitar_clean">{isJapanese ? "クリーントーン（エレキ）" : "Electric Clean"}</option>
                <option value="distortion_guitar">{isJapanese ? "ディストーション" : "Distortion"}</option>
                <option value="overdriven_guitar">{isJapanese ? "オーバードライブ" : "Over Drive"}</option>
                <option value="electric_guitar_muted">{isJapanese ? "ミュート" : "Muted"}</option>
                <option value="acoustic_grand_piano">{isJapanese ? "ピアノ" : "Piano"}</option>
              </select>
            </div>
          </div>
          {/* 上段の旧進行チップ行は廃止 */}

          {/* iOS風12スロットグリッド */}
          <div className="prog-slots mt-6 flex flex-wrap gap-3" aria-label="Progression slots">
            {Array.from({ length: 12 }).map((_, i) => {
              const filled = Boolean(slots[i]);
              const tone = 16; // emerald hue base
              const alpha = i < 8 ? 0 : (i - 7) * 0.08; // 0,0.08,0.16,0.24 for 8..11
              const bg = `rgba(16,185,129,${alpha.toFixed(2)})`;
              const active = cursorIndex === i;
              const isCurrentlyPlaying = currentChordIndex === i && isPlaying;
              return (
                <div
                  key={`slot-${i}`}
                  data-slot-index={i}
                  className={[
                    "inline-flex items-center justify-center rounded-xl border text-sm select-none relative chip-pressable",
                    filled ? "bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800" : "bg-gray-50 dark:bg-gray-800/50 border-gray-200 dark:border-gray-700",
                    active ? "ring-2 ring-blue-400/60" : "",
                    isCurrentlyPlaying ? "ring-4 ring-blue-500/80 shadow-lg" : "",
                    dragIndex === i ? "opacity-50 scale-105" : "",
                    touchDragTarget === i ? "ring-2 ring-blue-400" : ""
                  ].join(" ")}
                  style={{ 
                    padding: '12px 16px', 
                    minWidth: 80, 
                    minHeight: 48, 
                    background: filled ? undefined : bg, 
                    transition: 'all 0.2s ease',
                    touchAction: filled ? 'none' : 'auto'
                  }}
                  onClick={() => { if (filled) { playChordSymbol(slots[i]); } else { setCursorIndex(i); } }}
                  draggable={filled}
                  onDragStart={() => setDragIndex(i)}
                  onDragOver={(e) => e.preventDefault()}
                  onDrop={() => { if (dragIndex !== null) { moveSlot(dragIndex, i); setDragIndex(null); } }}
                  onTouchStart={(e) => handleTouchStartDrag(e, i)}
                  onTouchMove={(e) => handleTouchMoveDrag(e, i)}
                  onTouchEnd={handleTouchEndDrag}
                >
                  {/* iOS風番号表示 */}
                  <span className="absolute left-2 top-2 text-xs opacity-60 select-none pointer-events-none font-medium">{String(i+1)}</span>
                  {filled ? (
                    <>
                      <span>{slots[i]}</span>
                <button
                  aria-label="Remove chord"
                        className="absolute -top-1 -right-1 w-6 h-6 rounded-full bg-red-500 text-white text-xs leading-6 hover:bg-red-600 transition-colors"
                        onClick={(e)=>{ e.stopPropagation(); removeSlot(i); }}
                >×</button>
                    </>
                  ) : null}
          </div>
              );
            })}
        </div>
          </section>
      
      {/* Sketch Library セクションはドロップダウンに移行 */}
      {/* Choose chords card: iOS風シンプルデザイン */}
      <section id="choose" ref={rightRef} className="ot-card">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-3">
              <H2 className="mb-0 text-left">{isJapanese ? "コードを選ぶ" : "Choose chords"}</H2>
              <InfoDot
                title={isJapanese ? "コードを選ぶ" : "Choose Chords"}
                text={isJapanese 
                  ? "ルートとコードタイプを選んでください。追加ボタンでコード進行のスロットに追加できます。\nProプランの場合、より複雑なコードタイプを選ぶことができます。"
                  : "Select a root note and chord type. Use the Add button to add to chord progression slots.\nPro plan allows you to select more complex chord types."
                }
              />
            </div>
            {/* iOS風プリセットボタン */}
            <button
              type="button"
              className="chip px-4 py-2 inline-flex items-center gap-2"
              title="Load preset progression"
              onClick={() => setShowPresetPopup(true)}
            >
              <span>📋</span>
              <span>{isJapanese ? "プリセット" : "Presets"}</span>
            </button>
        </div>
          {/* ChordBuilder component with Quality Master.csv integration */}
          <ChordBuilder
            plan={(() => {
              // Debug: Allow forced plan via query parameter
              const forcedPlan = searchParams.get('plan');
              if (forcedPlan === 'pro' || forcedPlan === 'free') {
                return forcedPlan;
              }
              return isPro ? 'pro' : 'free';
            })()}
            onPreview={async (symbol) => {
              // 既存の簡易プレビューと同等：symbol → MIDI 変換して再生
              try {
                await player.resume();
                const midis = chordToMidi(symbol); // 既存ユーティリティ
                if (midis) {
                  player.playChord(midis, 'lightStrum', 300);
                }
              } catch {}
            }}
            onBlock={(reason, quality) => {
              // Show iOS promotion instead of upgrade modal
              if (reason === 'pro_quality') {
                alert(`「${quality}」はPro機能です。\n\niOS版のOtoTheoryアプリでPro機能をお試しください！\n\nApp Storeでダウンロードできます。`);
              } else if (reason === 'pro_slash') {
                alert('Slash機能はPro機能です。\n\niOS版のOtoTheoryアプリでPro機能をお試しください！\n\nApp Storeでダウンロードできます。');
              }
            }}
            onConfirm={(symbol) => {
              // 12スロットに追加（最初の空きに入れてカーソルを進める）
              setSlots(prev => {
                const arr = [...prev];
                let idx = arr.findIndex(s => !s);
                if (idx === -1) idx = 0;
                arr[idx] = symbol;
                return arr;
              });
              setCursorIndex(prev => {
                // 直感的に "次の空スロット" へ
                const arr = [...slots];
                let i = arr.findIndex(s => !s);
                return i === -1 ? 0 : i;
              });
              setAddedFlash(true); // 既存の "Added" 演出があるなら
            }}
          />
          
          {/* iOS風分析ボタン */}
          <div className="mt-6">
                    <button
              className={`w-full px-6 py-3 text-base rounded-xl font-semibold text-white transition-all duration-200 active:scale-[.98] active:translate-y-px focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-300 ${isAnalyzing ? 'bg-gray-400 cursor-wait' : 'bg-blue-500 hover:bg-blue-600 shadow-lg'}`}
                    onClick={() => {
                      const items = parseProg(progression);
                      const hasAdv = items.some((i) => ADVANCED_QUALITIES.some((a) => i.quality.includes(a)));
                      if (hasAdv && !isPro) {
                        if (typeof window !== 'undefined') window.alert('Advanced chords detected. Remove them or upgrade to Pro.');
                        return;
                      }
                      startAnalyze(() => {
                        // Run analysis without auto-scroll (analyze function has its own scroll)
                        const res = analyzeChordProgression(progression);
                        setResult(res);
                        const ranked = rankKeys(progression);
                        setKeys(ranked.slice(0,4));
                        if (ranked.length > 0) {
                          const mode: RomanMode = ranked[0].mode === "Major" ? "major" : "minor";
                          const keyName = ranked[0].label.split(" ")[0];
                          const sel = { tonic: keyName, mode } as const;
                          setSelectedKey(sel);
                          setRomanLine(progression.map(c => toRoman(c, sel.tonic, sel.mode, { showQuality: true, uppercase: true })));
                        } else {
                          setScales([]);
                          setSelectedKey(null);
                          setRomanLine([]);
                        }
                        // store-based analysis for Top3 candidates
                        runAnalyze(progression);
                        
                        // Auto-scroll to result section
                        setTimeout(() => {
                          const resultElement = document.getElementById('result');
                          if (resultElement) {
                            resultElement.scrollIntoView({ 
                              behavior: 'smooth', 
                              block: 'start' 
                            });
                          }
                        }, 100);
                      });
                    }}
                    disabled={isAnalyzing}
                    aria-busy={isAnalyzing}
                  >
                    {isAnalyzing ? (
                      <span className="inline-flex items-center gap-2">
                        <svg className="h-4 w-4 animate-spin" viewBox="0 0 24 24" aria-hidden="true">
                          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="3"/>
                          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 0 1 8-8v4a4 4 0 0 0-4 4H4z"/>
                        </svg>
                        Analyzing…
                      </span>
                    ) : (isJapanese ? '分析' : 'Analyze')}
                  </button>
          </div>
      </section>
      <section id="result" ref={resultRef} className="ot-card">
        <div className="flex items-center justify-between mb-6">
          <H2 className="text-left mb-0">{isJapanese ? "結果" : "Result"}</H2>
          <div className="flex items-center gap-3">
            <button
              type="button"
              className="chip px-4 py-2 inline-flex items-center gap-2"
              onClick={() => setShowNamePrompt(true)}
              title="Save sketch"
            >
              <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M17 3H5a2 2 0 0 0-2 2v14l4-4h10a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2z"/></svg>
              {isJapanese ? "保存" : "Save"}
            </button>
          </div>
        </div>
        {showNamePrompt && (
          <div className="fixed inset-0 z-[10000]" role="dialog" aria-modal="true">
            <div className="absolute inset-0 bg-black/40" onClick={() => { setShowNamePrompt(false); setNameInput(""); }} />
            <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-white dark:bg-neutral-900 border rounded-lg shadow-xl p-4 w-[92vw] max-w-[420px]">
              <div className="text-base font-semibold mb-2">{isJapanese ? "スケッチを保存" : "Save sketch"}</div>
              <input
                type="text"
                className="chip px-2 py-2 text-sm w-full"
                placeholder={defaultSketchName}
                value={nameInput}
                onChange={(e)=>setNameInput(e.target.value)}
                aria-label="Sketch name"
                autoFocus
              />
              <div className="mt-3 flex items-center justify-end gap-2">
                <button
                  type="button"
                  className="chip-pressable inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm border"
                  onClick={() => { setShowNamePrompt(false); setNameInput(""); }}
                >{isJapanese ? "キャンセル" : "Cancel"}</button>
                <button
                  type="button"
                  className="chip-pressable inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm border"
                  onClick={doSaveSketch}
                >OK</button>
              </div>
            </div>
          </div>
        )}

        {/* Sketch Action Popup (Edit/Export/Cancel) */}
        {selectedSketchForAction && (
          <div className="fixed inset-0 z-[10001]" role="dialog" aria-modal="true">
            <div className="absolute inset-0 bg-black/40" onClick={() => setSelectedSketchForAction(null)} />
            <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-white dark:bg-neutral-900 border rounded-lg shadow-xl p-4 w-[92vw] max-w-[320px]">
              <div className="text-base font-semibold mb-3">{selectedSketchForAction.name}</div>
              <div className="space-y-2">
                <button
                  type="button"
                  className="w-full chip-pressable inline-flex items-center justify-center gap-1 px-4 py-2 rounded-lg text-sm border"
                  onClick={() => {
                    try {
                      const sk = selectedSketchForAction;
                      const arr = new Array(12).fill("");
                      (sk?.progression?.items || []).forEach((it: any, idx: number) => { if (idx < 12) arr[idx] = String(it?.id || ""); });
                      setSlots(arr);
                      setCursorIndex(arr.findIndex(s=>!s) === -1 ? 11 : arr.findIndex(s=>!s));
                      // 解析を実行して候補を生成
                      try { runAnalyze(arr.filter(Boolean) as any); } catch {}
                      // Apply key to analysis store if possible
                      const tonicPc = PITCHES.indexOf(sk.key.tonic as any);
                      if (tonicPc >= 0) {
                        try { selectKey?.({ tonic: tonicPc as any, mode: (String(sk.key.scaleId || '')?.toLowerCase().includes('aeolian') || String(sk.key.scaleId||'').toLowerCase().includes('minor') ? 'Minor' : 'Major') as any }); } catch {}
                      }
                      track('open_project', { page: 'chord_progression', id: sk.id });
                      setShowSketchList(false);
                      setSelectedSketchForAction(null);
                    } catch {}
                  }}
                >
                  {isJapanese ? "編集" : "Edit"}
                </button>
                <button
                  type="button"
                  className="w-full chip-pressable inline-flex items-center justify-center gap-1 px-4 py-2 rounded-lg text-sm border"
                  onClick={async () => {
                    try {
                      const sk = selectedSketchForAction;
                      // Export機能を実装（後で追加）
                      await handleExportSketch(sk);
                      setSelectedSketchForAction(null);
                    } catch {}
                  }}
                >
                  {isJapanese ? "エクスポート" : "Export"}
                </button>
                <button
                  type="button"
                  className="w-full chip-pressable inline-flex items-center justify-center gap-1 px-4 py-2 rounded-lg text-sm border"
                  onClick={() => setSelectedSketchForAction(null)}
                >
                  {isJapanese ? "キャンセル" : "Cancel"}
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Export-only compact card (offscreen) */}
        <div
          ref={exportCardRef}
          aria-hidden
          style={{
            position: 'fixed',
            left: 0,
            top: 0,
            zIndex: 9999,
            opacity: 0.0001,
            pointerEvents: 'none',
            width: 800,
            height: 600,
            background: '#ffffff',
            color: '#000000',
            padding: 24,
            borderRadius: 12,
            border: '2px solid #cbd5e1',
            boxShadow: '0 4px 6px rgba(0,0,0,0.1)'
          }}
        >
          {(() => {
            const exportName = currentExportName || (nameInput?.trim() ? nameInput : defaultSketchName);
            const keyLabel = (() => {
              const k = selFromStore;
              if (!k) return '-';
              return `${PITCHES[k.tonic]} ${k.mode}`;
            })();
            const progText = progression.join(' ');
            const scaleLabel = (() => {
              const s = selectedScale;
              if (!s) return '-';
              return scaleTypeLabel(s.type);
            })();
            const fb = (() => {
              const capoN = 0;
              const rootPc = selectedScale ? selectedScale.root : undefined;
              const notesSounding = (selectedScale && typeof rootPc === 'number')
                ? getScalePitchesById(rootPc, selectedScale.type as any).map(pc => PITCHES[pc])
                : [];
              const displayMode = isHeptatonic ? (fbDisplay as any) : ('degrees' as any);
              const quality: Quality = (() => {
                const q = selectedScale?.type;
                if (!q) return 'maj';
                return q.toLowerCase().includes('aeolian') || q.toLowerCase().startsWith('min') ? 'min' : 'maj';
              })();
              const rootForContext = typeof rootPc === 'number' ? rootPc : 0;
              return (
                <div style={{ marginTop: 8, background: '#ffffff', border: '2px solid #cbd5e1', borderRadius: '8px', padding: '12px', width: '100%' }}>
                  <Fretboard
                    overlay={{ viewMode: 'sounding', capo: capoN, notes: notesSounding, chordNotes: overlayChordNotes ?? undefined, showScaleGhost: Boolean(overlayChordNotes), display: displayMode, scaleRootPc: (typeof rootPc === 'number' ? rootPc : 0), scaleType: (selectedScale?.type ?? 'Ionian'), context: { chordRootPc: (typeof rootPc === 'number' ? rootPc : 0), quality } }}
                    onRequestForms={() => {}}
                  />
                </div>
              );
            })();
            return (
              <div style={{
                background: '#ffffff',
                color: '#000000',
                fontFamily: 'ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, sans-serif',
                width: '100%',
                height: '100%',
                display: 'flex',
                flexDirection: 'column',
                gap: '12px',
                padding: '8px'
              } as any}>
                <div style={{ fontWeight: 700, fontSize: 24, color: '#000000', lineHeight: 1.3 }}>{exportName}</div>
                <div style={{ fontSize: 18, color: '#000000', fontWeight: 600 }}>Key: <span style={{ color: '#1e40af' }}>{keyLabel}</span></div>
                <div style={{ fontSize: 16, color: '#000000', fontWeight: 500 }}>Progression: <span style={{ color: '#1e40af' }}>{progText || '-'}</span></div>
                <div style={{ fontSize: 16, color: '#000000', fontWeight: 500 }}>Scale: <span style={{ color: '#1e40af' }}>{scaleLabel}</span></div>
                <div style={{ flex: 1, background: '#ffffff', border: '2px solid #cbd5e1', borderRadius: '8px', padding: '12px', overflow: 'hidden' }}>
                  {fb}
                </div>
              </div>
            );
          })()}
        </div>
          {keyCandidates.length > 0 ? (
            <div className="space-y-4">
              {/* Low accuracy warning - only show after analyze */}
              {keyCandidates.length > 0 && progression.length < 8 && (
                <div className="text-xs px-3 py-2 rounded-lg bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 text-yellow-800 dark:text-yellow-200">
                  ⚠️ 精度向上のため、8コード以上の入力を推奨します（現在: {progression.length}コード）
                </div>
              )}
              {/* === Key === */}
              <H3>{isJapanese ? "キー" : "Key"}</H3>
              <div className="flex items-center justify-between gap-2">
                <div className="chip-row mb-2" role="tablist" aria-label="Key candidates">
                  {keyCandidates.map((k, idx) => {
                    const active = selFromStore && selFromStore.tonic === k.tonic && selFromStore.mode === k.mode;
                    const label = k.mode === 'Major' ? PITCHES[k.tonic] : `${PITCHES[k.tonic]}m`;
                    const reasons = k.reasons.join("\n");
                    return (
                      <button
                        key={`${label}-${idx}`}
                        role="tab"
                        aria-selected={active}
                        className={["chip","chip--key", active?"chip--active":""].join(" ")}
                        title={`Why this key\n${reasons}`}
                        onClick={() => selectKey({ tonic: k.tonic, mode: k.mode })}
                        data-roving="item"
                      >
                        {label} {Math.round(k.confidence)}%
                      </button>
                    );
                  })}
                </div>
              </div>
              {/* === Scale === */}
              <div className="result-block">
                <H3>{isJapanese ? "スケール" : "Scale"}</H3>
                <div className="chip-row mb-2" role="tablist" aria-label="Scale candidates">
                  {scaleCandidates.map((s, idx) => {
                    const type = normalizeScaleId(s.type as any);
                    const active = selectedScale?.type === type && selectedScale?.root === s.root;
                    const newScaleId = mapOldScaleToNewId(s.type as string);
                    const scaleInfo = getScaleById(newScaleId);
                    // 言語判定（LocaleContextベース）
                    const language = isJapanese ? 'ja' : 'en';
                    const label = `${PITCHES[s.root]} ${scaleInfo ? getScaleDisplayName(scaleInfo, language) : scaleTypeLabel(type as any)}`;
                    return (
                      <div key={`${label}-${idx}`} className="relative inline-block">
                      <button
                        role="tab"
                        aria-selected={active}
                          className={["chip", "chip--key", active ? "chip--active" : "", "flex items-center gap-2"].join(" ")}
                          onClick={(e) => { 
                            e.stopPropagation();
                            selectScale(s); 
                            track('scale_pick', { page:'find-key', scale: s.type, key: PITCHES[s.root] }); 
                          }}
                        data-roving="item"
                      >
                          <span>{label} {Math.round(s.score)}%</span>
                      </button>
                        {scaleInfo && (
                          <div className="absolute -top-1 -right-1">
                            <InfoDot
                              title={(() => {
                                const language = isJapanese ? 'ja' : 'en';
                                return getScaleDisplayName(scaleInfo, language);
                              })()}
                              placement="top"
                              trigger={
                                <button
                                  type="button"
                                  className="w-6 h-6 rounded-full bg-amber-50/90 hover:bg-amber-100 ring-1 ring-amber-300/60 shadow-sm flex items-center justify-center"
                                  aria-label="Scale info"
                                >
                                  <svg className="w-4 h-4 text-amber-500" fill="currentColor" viewBox="0 0 24 24">
                                    <path d="M9 21c0 .55.45 1 1 1h4c.55 0 1-.45 1-1v-1H9v1zm3-19C8.14 2 5 5.14 5 9c0 2.38 1.19 4.47 3 5.74V17c0 .55.45 1 1 1h6c.55 0 1-.45 1-1v-2.26c1.81-1.27 3-3.36 3-5.74 0-3.86-3.14-7-7-7zm2.85 11.1l-.85.6V16h-4v-2.3l-.85-.6A4.997 4.997 0 0 1 7 9c0-2.76 2.24-5 5-5s5 2.24 5 5c0 1.63-.8 3.16-2.15 4.1z"/>
                                  </svg>
                                </button>
                              }
                            >
                              <ScaleInfoBody scaleId={newScaleId} />
                            </InfoDot>
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
        ) : (
          <div className="text-sm opacity-70">{isJapanese ? "分析をクリック" : "Click Analyze to see results."}</div>
        )}
      </section>

      {/* Tools セクション（iOS風シンプルデザイン） */}
      <section className="ot-card">
        <H2>{isJapanese ? "ツール" : "Tools"}</H2>
        <div className="space-y-6">
              {/* === Fretboard === */}
              <div className="result-block">
                <H3
                  right={
                    <div ref={fbToggleRef} className="flex items-center gap-2 bg-transparent shadow-none fretboard-toggle" aria-label="Fretboard notation" role="tablist">
                      <button
                        role="tab"
                        aria-selected={fbDisplay === 'degrees'}
                        tabIndex={fbDisplay === 'degrees' ? 0 : -1}
                        className={["chip","chip--key", fbDisplay === 'degrees' ? "chip--active" : ""].join(" ")}
                        onClick={()=>setFbDisplay('degrees')}
                        data-roving="item"
                      >{isJapanese ? "度数" : "Degrees"}</button>
                      <button
                        role="tab"
                        aria-selected={fbDisplay === 'names'}
                        tabIndex={isHeptatonic && fbDisplay === 'names' ? 0 : -1}
                        aria-disabled={!isHeptatonic}
                        className={["chip","chip--key", fbDisplay === 'names' ? "chip--active" : "", !isHeptatonic ? "chip--disabled" : ""].join(" ")}
                        onClick={()=>{ if (isHeptatonic) setFbDisplay('names'); }}
                        data-roving="item"
                      >{isJapanese ? "音名" : "Names"}</button>
                      {/* Names右の音色選択は削除 */}
                    </div>
                  }
                >{isJapanese ? "フレットボード" : "Fretboard"}</H3>
                <div className="fret-wrap">
                  <div className="fret-inner">
                    {selectedScale ? (() => {
                      const capoN = 0;
                      const rootPc = selectedScale.root;
                      const notesSounding = getScalePitchesById(rootPc, selectedScale.type as any).map(pc => PITCHES[pc]);
                      const displayMode = isHeptatonic ? (fbDisplay as any) : ('degrees' as any);
                      const quality: Quality = (() => {
                        const q = selectedScale?.type;
                        if (!q) return 'maj';
                        return q.toLowerCase().includes('aeolian') || q.toLowerCase().startsWith('min') ? 'min' : 'maj';
                      })();
                      const rootForContext = rootPc;
                      return (
                        <Fretboard
                          overlay={{ viewMode: 'sounding', capo: capoN, notes: notesSounding, chordNotes: overlayChordNotes ?? undefined, showScaleGhost: Boolean(overlayChordNotes), display: displayMode, scaleRootPc: rootPc as any, scaleType: selectedScale.type as any, context: { chordRootPc: rootPc, quality } }}
                          onRequestForms={(at, ctx) => {
                            setFormsPop({ at, rootPc: ctx.rootPc ?? rootForContext, quality: ctx.quality });
                          }}
                          formShape={formShape}
                        />
                      );
                    })() : (
                      <div className="text-center text-sm opacity-50 py-8">
                        {isJapanese ? "分析をクリックしてフレットボードを表示" : "Click Analyze to see fretboard"}
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* === Diatonic (Capo-based table) === */}
              <section className="result-block space-y-2">
                <H3>
                  <span className="flex items-center gap-2">
                    <span>{isJapanese ? "ダイアトニック" : "Diatonic"}</span>
                    <InfoDot
                      className="ml-1"
                      title={isJapanese ? "ダイアトニックコード" : "Diatonic chords"}
                      linkHref="/resources/glossary"
                      linkLabel="Glossary"
                    >
                      <p className="text-sm">Chords built only from the key’s scale tones (I–ii–iii–IV–V–vi–vii°).</p>
                      <ul className="mt-2 list-disc pl-5 space-y-1 text-sm">
                        <li>Stable sound: everything stays inside the key.</li>
                        <li>Use: begin inside → add color with a borrowed chord (iv, bVII, bVI).</li>
                        <li>Try: ii–V–I or IV–V–I for clear motion.</li>
                      </ul>
                      <h4 className="mt-3 font-medium">Shaped vs. Sounding (Capo)</h4>
                      <ul className="mt-1 list-disc pl-5 space-y-1 text-sm">
                        <li>Shaped: labels show the shapes you fret after capo.</li>
                        <li>Sounding: labels show the actual pitch you hear.</li>
                      </ul>
                    </InfoDot>
                  </span>
                </H3>
                <DiatonicCapoTable
                  selectedId={selectedCellId}
                  onSelectId={(id)=> setSelectedCellId(id)}
                  onPick={async ({ id, pcs, isRightClick })=>{
                    // 右クリックの場合はコード進行に追加
                    if (isRightClick) {
                      // ダイアトニックテーブルからコード名を取得
                      const selectedKey = useAnalysisStore.getState().selectedKey;
                      const selectedScale = useAnalysisStore.getState().selectedScale;
                      if (!selectedKey || !selectedScale) return;
                      
                      let st = selectedScale.type as any;
                      let ivs = (SCALE_INTERVALS as any)[st] ?? [];
                      if (ivs.length !== 7) {
                        const parent = parentModeOf(st);
                        if (parent) ivs = (SCALE_INTERVALS as any)[parent] ?? [];
                      }
                      if (ivs.length !== 7) return;
                      
                      const tris = diatonicTriads({ tonicPc: selectedKey.tonic, scaleIntervals: ivs });
                      const degreeIndex = parseInt(id.replace('open-', ''));
                      const triad = tris[degreeIndex];
                      if (!triad) return;
                      
                      const chordSym = triadToChordSym({ rootPc: triad.rootPc, quality: triad.quality });
                      const newSlots = [...slots];
                      newSlots[cursorIndex] = chordSym;
                      setSlots(newSlots);
                      if (cursorIndex < 11) setCursorIndex(cursorIndex + 1);
                      track('diatonic_pick', { page:'find-key', action: 'right_click_add' });
                      return;
                    }
                    
                    // 同じセルを再選択 → リセット（スケールトーンのみ表示に戻す）
                    if (selectedCellId === id) {
                      setOverlayChordNotes(null);
                      setSelectedCellId(null);
                      resetForms();
                      return;
                    }
                    const mainNotes = pcs.map(pc => PITCHES[pc] as string);
                    setOverlayChordNotes(mainNotes);
                    setSelectedCellId(id);
                    resetForms();
                    track('diatonic_pick', { page:'find-key' });
                    // 和音再生（ピッチクラス→C4基準の実音に変換して3音同時）
                    try {
                      await player.resume();
                      const midis = pcs.map(pc => 60 + (pc % 12));
                      player.playChord(midis, 'lightStrum', 260);
                    } catch {}
                  }}
                />
              </section>
              
              {/* === Roman (hide for non-heptatonic scales) === */}
              {isHeptatonic && (
                <>
                  <H3>{isJapanese ? "度数進行" : "Roman"}</H3>
                  <div ref={romanBoxRef} className="rounded-md border px-3 py-2" aria-live="polite" data-testid="roman-row">
                    <div className="flex-1 overflow-x-auto whitespace-nowrap text-lg md:text-xl tracking-wide">
                      {romanLine.length === 0 ? (
                        <span>-</span>
                      ) : (
                        romanLine.map((tok, i) => (
                          <React.Fragment key={`rom-${i}`}>
                            <span
                              data-idx={i}
                              className={romanHL && i >= romanHL.start && i <= romanHL.end ? 'roman-mark' : undefined}
                            >
                              {String(tok || '').toUpperCase()}
                            </span>
                            {i < romanLine.length - 1 ? <span aria-hidden className="mx-1">–</span> : null}
                          </React.Fragment>
                        ))
                      )}
                    </div>
                  </div>
                </>
              )}

              {/* Patterns */}
              {patternHits.length > 0 && (
                <div className="mt-2 flex flex-wrap items-center gap-2">
                  <span className="text-xs opacity-70">{isJapanese ? "パターン" : "Patterns"}</span>
                  {(() => {
                    const h = patternHits[0];
                    const idToEn: Record<string, any> = {
                      'doo-wop': 'dooWop',
                      'axis': 'axis',
                      'canon': 'canon',
                      'ii-V-I': 'twoFiveOne',
                      'turnaround': 'turnaround',
                      'andalusian': 'andalusian',
                      'authentic': 'authentic',
                      'plagal': 'plagal',
                      'deceptive': 'deceptive',
                    };
                    const en = idToEn[h.id] ? patternInfoEN(idToEn[h.id]) : null;
                    const label = en?.label || upperRomansInParens(h.name).replace(/\(I–vi–IV–V\)/, "(I–VI–IV–V)");
                    const summary = en?.summary || (h.summary || h.name);
                    const isActive = !!(romanHL && romanHL.start === h.start && romanHL.end === h.end);
                    return (
                      <>
                        <button
                          key={`${h.id}-0`}
                          type="button"
                          className={["text-sm leading-tight font-medium hover:opacity-80 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400/50 rounded"].join(' ')}
                          title={summary}
                          onClick={() => {
                            setRomanHL(prev => (prev && prev.start === h.start && prev.end === h.end)
                              ? null
                              : { start: Math.max(0, h.start), end: Math.max(h.start, Math.min(romanLine.length - 1, h.end)) }
                            );
                            requestAnimationFrame(() => {
                              const box = romanBoxRef.current;
                              if (!box) return;
                              const mark = box.querySelector(`[data-idx="${h.start}"]`) as HTMLElement | null;
                              if (mark) box.scrollLeft = Math.max(0, mark.offsetLeft - 12);
                            });
                          }}
                        >
                          {label}
                        </button>
                        <InfoDot ariaLabel={`${label} – info`} text={`${label}\n\n${summary}`} />
                      </>
                    );
                  })()}
                </div>
              )}

              {/* Cadence row (keep label in sync with Patterns) */}
              {(cadences.length > 0 || fallbackCadence) && (
                <div className="mt-2 flex flex-wrap items-center gap-2">
                  <span className="text-xs opacity-70">{isJapanese ? "カデンツ" : "Cadence"}</span>
                  {(() => {
                    const c: any = cadences[0] ?? fallbackCadence;
                    const t = c?.type ?? c; // 'perfect' | 'deceptive' | 'half'
                    const tail = c?.tail ?? c?.tailRoman;
                    const label = formatCadenceShort(t, tail);
                    return (
                      <span className="inline-flex items-center gap-1.5 text-sm leading-tight">
                        <span className="font-medium">{label}</span>
                        <InfoDot text={cadenceTooltip(t)} />
                      </span>
                    );
                  })()}
                </div>
              )}
              
              
              {/* Capo block removed (feature gated off) */}
              
              
              {/* link to open in chords removed per spec */}
                </div>
        </section>
      <section className="ot-card" aria-label="Ad">
        <AdSlot page="chord_progression" format="horizontal" />
      </section>
      
      {/* Preset Popup */}
      {showPresetPopup && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40" style={{ backdropFilter: 'blur(4px)' }}>
          <div ref={presetPopupRef} className="bg-white dark:bg-gray-800 rounded-lg shadow-2xl p-6 max-w-md w-full mx-4">
            <h3 className="text-lg font-semibold mb-4">{isJapanese ? "プリセットを読み込み" : "Load Preset"}</h3>
            
            {/* Key selector */}
            <div className="mb-4">
              <label className="text-xs opacity-70 mb-1 block">{isJapanese ? "キー" : "Key"}</label>
              <div className="flex flex-wrap gap-1">
                {['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'].map(k => (
                  <button
                    key={k}
                    className={`chip ${presetKey === k ? 'chip--active' : ''}`}
                    onClick={() => setPresetKey(k)}
                  >
                    {k}
                  </button>
                ))}
              </div>
            </div>
            
            {/* Preset buttons */}
            <div className="space-y-2 max-h-[60vh] overflow-y-auto">
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-V-vi-IV', ['Ⅰ', 'Ⅴ', 'Ⅵm', 'Ⅳ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–Ⅴ–Ⅵm–Ⅳ</div>
                <div className="text-xs opacity-70">Pop progression</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('ii-V-I', ['Ⅱm', 'Ⅴ', 'Ⅰ'], presetKey)}
              >
                <div className="font-medium">Ⅱm–Ⅴ–Ⅰ</div>
                <div className="text-xs opacity-70">Jazz turnaround</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('12-bar-blues', ['Ⅰ', 'Ⅰ', 'Ⅰ', 'Ⅰ', 'Ⅳ', 'Ⅳ', 'Ⅰ', 'Ⅰ', 'Ⅴ', 'Ⅳ', 'Ⅰ', 'Ⅴ'], presetKey)}
              >
                <div className="font-medium">12-bar Blues</div>
                <div className="text-xs opacity-70">Classic blues form (all 12 slots)</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-II', ['Ⅰ', 'Ⅱ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–Ⅱ</div>
                <div className="text-xs opacity-70">Simple two-chord progression</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-bVII-IV', ['Ⅰ', '♭Ⅶ', 'Ⅳ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–♭Ⅶ–Ⅳ</div>
                <div className="text-xs opacity-70">Rock progression</div>
              </button>
              
              {/* 新規追加: 5つの有用なプリセット */}
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('vi-IV-I-V', ['Ⅵm', 'Ⅳ', 'Ⅰ', 'Ⅴ'], presetKey)}
              >
                <div className="font-medium">Ⅵm–Ⅳ–Ⅰ–Ⅴ</div>
                <div className="text-xs opacity-70">Emotional / Ballad (I-V-vi-IVの逆回転)</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-vi-IV-V', ['Ⅰ', 'Ⅵm', 'Ⅳ', 'Ⅴ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–Ⅵm–Ⅳ–Ⅴ</div>
                <div className="text-xs opacity-70">50's progression / Doo-wop</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-IV-V', ['Ⅰ', 'Ⅳ', 'Ⅴ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–Ⅳ–Ⅴ</div>
                <div className="text-xs opacity-70">Three-chord song / Rock classic</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('vi-ii-V-I', ['Ⅵm', 'Ⅱm', 'Ⅴ', 'Ⅰ'], presetKey)}
              >
                <div className="font-medium">Ⅵm–Ⅱm–Ⅴ–Ⅰ</div>
                <div className="text-xs opacity-70">Circle progression / Jazz standard</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-bVII-bVI-bVII', ['Ⅰ', '♭Ⅶ', '♭Ⅵ', '♭Ⅶ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–♭Ⅶ–♭Ⅵ–♭Ⅶ</div>
                <div className="text-xs opacity-70">Mixolydian vamp / Rock anthem</div>
              </button>
              
              {/* 新規追加: さらに10種類のプリセット */}
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-IVm-I-V', ['Ⅰ', 'Ⅳm', 'Ⅰ', 'Ⅴ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–Ⅳm–Ⅰ–Ⅴ</div>
                <div className="text-xs opacity-70">Borrowed chord / Minor IV</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('vi-IV-I-III', ['Ⅵm', 'Ⅳ', 'Ⅰ', 'Ⅲ'], presetKey)}
              >
                <div className="font-medium">Ⅵm–Ⅳ–Ⅰ–Ⅲ</div>
                <div className="text-xs opacity-70">Andalusian cadence / Spanish feel</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-bIII-bVII-IV', ['Ⅰ', '♭Ⅲ', '♭Ⅶ', 'Ⅳ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–♭Ⅲ–♭Ⅶ–Ⅳ</div>
                <div className="text-xs opacity-70">Modal interchange / Epic progression</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-iii-IV-V', ['Ⅰ', 'Ⅲm', 'Ⅳ', 'Ⅴ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–Ⅲm–Ⅳ–Ⅴ</div>
                <div className="text-xs opacity-70">Classic progression / Beatles style</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-V-vi-iii-IV-I-IV-V', ['Ⅰ', 'Ⅴ', 'Ⅵm', 'Ⅲm', 'Ⅳ', 'Ⅰ', 'Ⅳ', 'Ⅴ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–Ⅴ–Ⅵm–Ⅲm–Ⅳ–Ⅰ–Ⅳ–Ⅴ</div>
                <div className="text-xs opacity-70">Pachelbel's Canon / Wedding classic</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-bVI-bVII-I', ['Ⅰ', '♭Ⅵ', '♭Ⅶ', 'Ⅰ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–♭Ⅵ–♭Ⅶ–Ⅰ</div>
                <div className="text-xs opacity-70">Power ballad / 80s rock</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('vi-V-IV-III', ['Ⅵm', 'Ⅴ', 'Ⅳ', 'Ⅲ'], presetKey)}
              >
                <div className="font-medium">Ⅵm–Ⅴ–Ⅳ–Ⅲ</div>
                <div className="text-xs opacity-70">Descending progression / Melancholic</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-IV-bVII-IV', ['Ⅰ', 'Ⅳ', '♭Ⅶ', 'Ⅳ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–Ⅳ–♭Ⅶ–Ⅳ</div>
                <div className="text-xs opacity-70">Folk/Country vamp</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-bVII-IV-I', ['Ⅰ', '♭Ⅶ', 'Ⅳ', 'Ⅰ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–♭Ⅶ–Ⅳ–Ⅰ</div>
                <div className="text-xs opacity-70">Stadium anthem / Closing progression</div>
              </button>
              <button
                className="w-full text-left px-4 py-2.5 rounded-lg border hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                onClick={() => applyPreset('I-iii-vi-IV', ['Ⅰ', 'Ⅲm', 'Ⅵm', 'Ⅳ'], presetKey)}
              >
                <div className="font-medium">Ⅰ–Ⅲm–Ⅵm–Ⅳ</div>
                <div className="text-xs opacity-70">Smooth descent / R&B style</div>
              </button>
            </div>
            
            <button
              className="mt-4 w-full px-4 py-2 rounded-lg bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600"
              onClick={() => setShowPresetPopup(false)}
            >
              {isJapanese ? "キャンセル" : "Cancel"}
            </button>
          </div>
        </div>
      )}

      {/* M3.5: Toast notifications */}
      {toastConfig && (
        <Toast
          message={toastConfig.message}
          type={toastConfig.type}
          ctaText={toastConfig.ctaText}
          ctaHref={toastConfig.ctaHref}
          ctaPlace={toastConfig.ctaPlace}
          onClose={() => setToastConfig(null)}
        />
      )}


    </main>
  );
}

const AdvSection: React.FC<{title:string; children:React.ReactNode}> = ({ title, children }) => (
  <div>
    <div className="text-xs text-black/60 dark:text-white/60 mb-1">{title}</div>
    <div className="adv-grid">
      {children}
    </div>
  </div>
);

const Chip: React.FC<{label:string; onClick?:()=>void; disabled?:boolean; active?:boolean; small?:boolean}> = ({ label, onClick, disabled, active, small }) => (
  <button
    className={["chip", small ? "chip--sm" : "", active ? "chip--active" : "", disabled ? "chip--disabled" : ""].join(" ")}
    onClick={onClick}
    aria-disabled={disabled}
  >
    {label}
  </button>
);

// moved to components/ui/InfoDot


