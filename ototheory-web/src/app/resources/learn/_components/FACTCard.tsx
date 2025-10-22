'use client';

interface FACTCardProps {
  source: string;
  children: React.ReactNode;
}

export default function FACTCard({ source, children }: FACTCardProps) {
  return (
    <blockquote className="border-l-4 border-blue-500 pl-4 py-3 my-6 bg-blue-50 dark:bg-blue-900/20 rounded-r-lg">
      <div className="flex items-start gap-3">
        <span className="text-2xl">🎙️</span>
        <div className="flex-1">
          <div className="font-semibold text-blue-700 dark:text-blue-300 mb-2">
            FACT
          </div>
          <div className="text-gray-800 dark:text-gray-200 italic mb-2">
            "{children}"
          </div>
          <div className="text-sm text-gray-600 dark:text-gray-400">
            出典：{source}
          </div>
        </div>
      </div>
    </blockquote>
  );
}
