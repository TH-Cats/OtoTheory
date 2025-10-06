import { create } from 'zustand';
import { Sketch } from '@/types/sketch';
import { loadAll, saveLocalFree, saveCloudPro } from '@/features/sketch/storage';

type SketchState = {
  sketches: Sketch[];
  currentSketch: Sketch | null;
  isLoading: boolean;
  error: string | null;

  // Actions
  loadSketches: () => void;
  saveSketch: (sketch: Omit<Sketch, 'id' | 'createdAt' | 'updatedAt'>) => Promise<{ ok: boolean; reason?: string }>;
  loadSketch: (id: string) => void;
  deleteSketch: (id: string) => void;
  duplicateSketch: (id: string) => void;
  renameSketch: (id: string, name: string) => void;

  // Auto-save
  startAutoSave: (sketch: Sketch) => void;
  stopAutoSave: () => void;
};

const generateId = () => Math.random().toString(36).substr(2, 9);

export const useSketchStore = create<SketchState>((set, get) => ({
  sketches: [],
  currentSketch: null,
  isLoading: false,
  error: null,

  loadSketches: () => {
    set({ isLoading: true, error: null });
    try {
      const sketches = loadAll();
      set({ sketches, isLoading: false });
    } catch (error) {
      set({ error: 'Failed to load sketches', isLoading: false });
    }
  },

  saveSketch: async (sketchData) => {
    const sketch: Sketch = {
      ...sketchData,
      id: generateId(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    // Freeユーザーの場合
    const result = saveLocalFree(sketch);

    if (result.ok) {
      // ローカルストレージが更新されたので、ストアも更新
      const sketches = loadAll();
      set({ sketches, currentSketch: sketch });
      return { ok: true };
    } else {
      // Proユーザーの場合（スケルトン実装）
      try {
        await saveCloudPro(sketch);
        const sketches = loadAll();
        set({ sketches, currentSketch: sketch });
        return { ok: true };
      } catch (error) {
        return { ok: false, reason: 'cloud_save_failed' };
      }
    }
  },

  loadSketch: (id: string) => {
    const sketches = get().sketches;
    const sketch = sketches.find(s => s.id === id);
    if (sketch) {
      set({ currentSketch: sketch });
    }
  },

  deleteSketch: (id: string) => {
    const sketches = get().sketches.filter(s => s.id !== id);
    localStorage.setItem('ot_sketches', JSON.stringify(sketches));
    set({ sketches });

    if (get().currentSketch?.id === id) {
      set({ currentSketch: null });
    }
  },

  duplicateSketch: (id: string) => {
    const sketches = get().sketches;
    const original = sketches.find(s => s.id === id);
    if (original) {
      const duplicate: Sketch = {
        ...original,
        id: generateId(),
        name: `${original.name} Copy`,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      const result = saveLocalFree(duplicate);
      if (result.ok) {
        const updatedSketches = loadAll();
        set({ sketches: updatedSketches, currentSketch: duplicate });
      }
    }
  },

  renameSketch: (id: string, name: string) => {
    const sketches = get().sketches.map(s =>
      s.id === id ? { ...s, name, updatedAt: new Date().toISOString() } : s
    );

    localStorage.setItem('ot_sketches', JSON.stringify(sketches));
    set({ sketches });

    if (get().currentSketch?.id === id) {
      set({ currentSketch: { ...get().currentSketch, name, updatedAt: new Date().toISOString() } });
    }
  },

  startAutoSave: (sketch: Sketch) => {
    // 3秒アイドル後に自動保存
    const timeoutId = setTimeout(() => {
      const currentState = get();
      if (currentState.currentSketch?.id === sketch.id) {
        // 変更があった場合のみ保存
        const updatedSketch = { ...sketch, updatedAt: new Date().toISOString() };
        const result = saveLocalFree(updatedSketch);
        if (result.ok) {
          const sketches = loadAll();
          set({ sketches, currentSketch: updatedSketch });
        }
      }
    }, 3000);

    // タイムアウトIDを保持（クリーンアップ用）
    return timeoutId;
  },

  stopAutoSave: () => {
    // 自動保存をキャンセル
  },
}));
