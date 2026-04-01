export function PointSummary({ points }: { points: string[] }) {
  return (
    <ul className="grid gap-3">
      {points.map((point) => (
        <li key={point} className="rounded-2xl bg-slate-50 px-4 py-3 text-sm leading-6 text-slate-700">
          {point}
        </li>
      ))}
    </ul>
  );
}