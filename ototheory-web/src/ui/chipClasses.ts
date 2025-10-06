export const chipBase = [
  "inline-flex items-center",
  "border px-3 py-1.5 text-xs md:text-sm",
  "transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400/50",
  "shadow-none",
].join(" ");

export const chipActive = [
  // Light
  "bg-emerald-100 border-emerald-300 text-emerald-900",
  // Dark
  "dark:bg-emerald-900/30 dark:border-emerald-600 dark:text-emerald-100",
].join(" ");

export const chipInactive = [
  // Light
  "bg-white border-neutral-300 text-neutral-700 hover:bg-neutral-50",
  // Dark
  "dark:bg-neutral-900/30 dark:border-neutral-700 dark:text-neutral-300 dark:hover:bg-neutral-800/50",
].join(" ");

// Match Scale chip shape (pill). Change here if Scale switches.
export const chipRadius = "rounded-full";


