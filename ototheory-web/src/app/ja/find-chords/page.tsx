import { Suspense } from "react";
import FindChordsContentJA from "./FindChordsContentJA";
import ErrorBoundary from "@/components/dev/ErrorBoundary";

export default function FindChordsPageJA() {
  return (
    <Suspense fallback={<div className="ot-page">Loading...</div>}>
      <ErrorBoundary>
        <FindChordsContentJA />
      </ErrorBoundary>
    </Suspense>
  );
}
