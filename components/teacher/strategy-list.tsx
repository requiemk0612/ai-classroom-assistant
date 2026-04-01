import type { StrategyItem } from "@/types/strategy";

export function StrategyList({ items }: { items: StrategyItem[] }) {
  const labelMap: Record<StrategyItem["type"], string> = {
    analogy: "\u7c7b\u6bd4\u8bf4\u660e",
    visual: "\u53ef\u89c6\u5316",
    quick_check: "\u5feb\u901f\u68c0\u67e5"
  };

  return (
    <div className="rounded-[28px] bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <div className="flex items-center justify-between gap-3">
        <h2 className="text-lg font-semibold text-slate-900">{"\u6559\u5b66\u7b56\u7565\u5efa\u8bae"}</h2>
        <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">
          {`\u5f53\u524d ${items.length} \u6761`}
        </span>
      </div>

      <div className="mt-4 grid gap-3">
        {items.length > 0 ? (
          items.map((item, index) => (
            <div key={`${item.type}-${item.title}`} className="rounded-2xl bg-slate-50 px-4 py-4">
              <div className="flex items-center justify-between gap-3">
                <div className="flex items-center gap-3">
                  <span className="flex h-7 w-7 items-center justify-center rounded-full bg-white text-xs font-semibold text-slate-500">
                    {index + 1}
                  </span>
                  <div className="text-sm font-semibold text-slate-900">{item.title}</div>
                </div>
                <span className="rounded-full bg-brand-50 px-3 py-1 text-xs font-medium text-brand-700">
                  {labelMap[item.type]}
                </span>
              </div>
              <div className="mt-2 text-sm leading-6 text-slate-700">{item.text}</div>
            </div>
          ))
        ) : (
          <div className="rounded-2xl bg-slate-50 px-4 py-4 text-sm text-slate-500">
            {"\u5f53\u524d\u8fd8\u6ca1\u6709\u65b0\u7684\u7b56\u7565\u5efa\u8bae\uff0c\u53ef\u4ee5\u5148\u6309\u539f\u8ba1\u5212\u7ee7\u7eed\u8bb2\u89e3\u3002"}
          </div>
        )}
      </div>
    </div>
  );
}
