import type { AlertInfo } from "@/types/classroom";

export function AlertCard({ alert }: { alert: AlertInfo | null }) {
  const levelText =
    alert?.alertLevel === "high"
      ? "\u9ad8\u7ea7\u9884\u8b66"
      : alert?.alertLevel === "medium"
        ? "\u4e2d\u7ea7\u9884\u8b66"
        : "\u8bfe\u5802\u72b6\u6001\u5e73\u7a33";

  const badgeClass = alert ? "bg-rose-50 text-rose-700" : "bg-emerald-50 text-emerald-700";
  const messageClass = alert ? "bg-amber-50 text-amber-700" : "bg-emerald-50 text-emerald-700";

  return (
    <div className="rounded-[28px] bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <div className="flex items-center justify-between gap-3">
        <h2 className="text-lg font-semibold text-slate-900">\u9884\u8b66\u63d0\u793a</h2>
        <span className={`rounded-full px-3 py-1 text-xs font-medium ${badgeClass}`}>{levelText}</span>
      </div>
      <div className={`mt-4 rounded-2xl px-4 py-3 text-sm leading-6 ${messageClass}`}>
        {alert?.alertMessage ?? "\u5f53\u524d\u8bfe\u5802\u6574\u4f53\u72b6\u6001\u7a33\u5b9a\uff0c\u53ef\u4ee5\u6309\u7167\u539f\u5b9a\u8282\u594f\u7ee7\u7eed\u8bb2\u6388\u3002"}
      </div>
      <div className="mt-3 text-sm leading-6 text-slate-500">
        {alert
          ? "\u5efa\u8bae\u7ed3\u5408\u53cd\u9988\u5206\u5e03\u548c\u7b56\u7565\u5361\u7247\uff0c\u5148\u7528\u4e00\u4e2a\u76f4\u89c2\u4f8b\u5b50\u7a33\u4f4f\u5b66\u751f\u7406\u89e3\u3002"
          : "\u53ef\u4ee5\u7ee7\u7eed\u4fdd\u6301\u5f53\u524d\u6559\u5b66\u8282\u594f\uff0c\u5fc5\u8981\u65f6\u518d\u8865\u4e00\u4e2a\u5feb\u901f\u68c0\u6d4b\u3002"}
      </div>
    </div>
  );
}