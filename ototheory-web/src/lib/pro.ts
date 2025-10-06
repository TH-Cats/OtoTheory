export type ProState = { isPro: boolean };

export const getInitialPro = (): ProState => {
  if (typeof window === "undefined") return { isPro: false };
  const v = window.localStorage.getItem("isPro");
  return { isPro: v === "1" };
};

export const setPro = (on: boolean) => {
  if (typeof window !== "undefined") window.localStorage.setItem("isPro", on ? "1" : "0");
};



