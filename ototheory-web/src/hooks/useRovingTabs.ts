"use client";

import { useEffect } from "react";

type Options = {
  itemSelector?: string;
  orientation?: "horizontal" | "vertical" | "both";
  includeHomeEnd?: boolean;
};

export function useRovingTabs(root: React.RefObject<HTMLElement | null>, options: Options = {}) {
  const {
    itemSelector = '[role="tab"],[data-roving="item"]',
    orientation = "horizontal",
    includeHomeEnd = true,
  } = options;

  useEffect(() => {
    const el = root.current;
    if (!el) return;

    const getItems = () => Array.from(el.querySelectorAll<HTMLElement>(itemSelector)).filter((node) => !node.hasAttribute("disabled"));
    const setTabIndex = (items: HTMLElement[], idx: number) => {
      items.forEach((node, i) => (node.tabIndex = i === idx ? 0 : -1));
    };

    const applyInitial = () => {
      const items = getItems();
      if (!items.length) return;
      let index = items.findIndex((node) => node.getAttribute("aria-selected") === "true" || node.tabIndex === 0 || node === document.activeElement);
      if (index < 0) index = 0;
      setTabIndex(items, index);
    };

    applyInitial();

    const onKey = (event: KeyboardEvent) => {
      const items = getItems();
      if (!items.length) return;
      const currentIndex = items.indexOf(document.activeElement as HTMLElement);
      if (currentIndex < 0) return;

      const { key } = event;
      const horizontal = orientation === "horizontal" || orientation === "both";
      const vertical = orientation === "vertical" || orientation === "both";
      let nextIndex = -1;

      if (horizontal && key === "ArrowRight") nextIndex = (currentIndex + 1) % items.length;
      if (horizontal && key === "ArrowLeft") nextIndex = (currentIndex - 1 + items.length) % items.length;
      if (vertical && key === "ArrowDown") nextIndex = (currentIndex + 1) % items.length;
      if (vertical && key === "ArrowUp") nextIndex = (currentIndex - 1 + items.length) % items.length;

      if (nextIndex >= 0) {
        event.preventDefault();
        setTabIndex(items, nextIndex);
        items[nextIndex].focus({ preventScroll: true });
        return;
      }

      if (includeHomeEnd && key === "Home") {
        event.preventDefault();
        setTabIndex(items, 0);
        items[0].focus({ preventScroll: true });
        return;
      }

      if (includeHomeEnd && key === "End") {
        event.preventDefault();
        const last = items.length - 1;
        setTabIndex(items, last);
        items[last].focus({ preventScroll: true });
      }
    };

    el.addEventListener("keydown", onKey);
    return () => {
      el.removeEventListener("keydown", onKey);
    };
  }, [root, itemSelector, orientation, includeHomeEnd]);
}





