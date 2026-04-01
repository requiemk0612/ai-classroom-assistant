export function PointSummary({ points }: { points: string[] }) {
  return (
    <div className="grid gap-3">
      {points.map((point, index) => (
        <div key={point} className="rounded-2xl bg-slate-50 px-4 py-3 text-sm leading-6 text-slate-700">
          <div className="flex items-start gap-3">
            <span className="mt-0.5 flex h-6 w-6 items-center justify-center rounded-full bg-white text-xs font-semibold text-brand-600">
              {index + 1}
            </span>
            <span>{point}</span>
          </div>
        </div>
      ))}
    </div>
  );
}