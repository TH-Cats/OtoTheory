import { Suspense } from "react";
import FindChordsContentJA from "./FindChordsContentJA";

export default function FindChordsPageJA() {
  return (
    <Suspense fallback={<div className="ot-page">Loading...</div>}>
      <FindChordsContentJA />
    </Suspense>
  );
}
