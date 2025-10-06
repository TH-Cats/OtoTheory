// src/lib/export/png.ts
import * as t from '@/lib/telemetry';
import { toPng } from 'html-to-image';

let exporting = false;

export async function exportPng(el: HTMLElement, theme:'auto'|'light'|'dark'='auto') {
  if (exporting) return; // 重複防止
  exporting = true;
  try {
    // 一時的に可視化してレンダリングを確実にする
    const originalOpacity = el.style.opacity;
    const originalVisibility = el.style.visibility;
    el.style.opacity = '1';
    el.style.visibility = 'visible';
    
    // Fretboard内の全てのテキスト要素を強制的に黒色にし、フレット番号ボックスの背景を調整
    const allElements = el.querySelectorAll('*');
    const originalStyles: Array<{ elem: HTMLElement; color: string; fill: string; bg: string }> = [];
    allElements.forEach((elem) => {
      const htmlElem = elem as HTMLElement;
      const originalColor = htmlElem.style.color;
      const originalFill = htmlElem.style.fill;
      const originalBg = htmlElem.style.background;
      originalStyles.push({ elem: htmlElem, color: originalColor, fill: originalFill, bg: originalBg });
      
      // 全てのテキストを黒色に
      htmlElem.style.color = '#000000';
      if (htmlElem.tagName === 'text' || htmlElem.tagName === 'tspan') {
        htmlElem.style.fill = '#000000';
      }
      
      // フレット番号を含むspan要素の背景を薄いグレーに変更
      if (htmlElem.tagName === 'SPAN' && htmlElem.className.includes('inline-block')) {
        const text = htmlElem.textContent?.trim();
        if (text && /^\d+$/.test(text)) {
          htmlElem.style.background = '#f3f4f6'; // 薄いグレー (Tailwind gray-100相当)
          htmlElem.style.color = '#000000';
        }
      }
    });
    
    // レンダリング完了を待つ
    await new Promise(resolve => setTimeout(resolve, 150));
    
    el.dataset.export = theme; // CSSでテーマ反転を制御
    const dataUrl = await toPng(el, { pixelRatio: 2, backgroundColor: '#ffffff', cacheBust: true });
    
    // 元に戻す
    el.style.opacity = originalOpacity;
    el.style.visibility = originalVisibility;
    originalStyles.forEach(({ elem, color, fill, bg }) => {
      elem.style.color = color;
      elem.style.fill = fill;
      elem.style.background = bg;
    });
    
    const a = document.createElement('a');
    a.href = dataUrl; a.download = 'ot-progression.png'; a.click();
    t.track('export_png', { page: 'chord_progression', ok: true });
  } catch (e) {
    t.track('export_png', { page: 'chord_progression', ok: false, err: String(e) });
  } finally {
    el.removeAttribute('data-export');
    exporting = false;
  }
}
