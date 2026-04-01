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
        <h2 className="text-lg font-semibold text-slate-900">{"\u9884\u8b66\u63d0\u793a"}</h2>
        <span className={`rounded-full px-3 py-1 text-xs font-medium ${badgeClass}`}>{levelText}</span>
      </div>
      <div className={`mt-4 rounded-2xl px-4 py-3 text-sm leading-6 ${messageClass}`}>
        {alert?.alertMessage ?? "\u5f53\u524d\u8bfe\u5802\u6574\u4f53\u72b6\u6001\u7a33\u5b9a\uff0c\u53ef\u4ee5\u6309\u7167\u539f\u5b9a\u8282\u594f\u7ee7\u7eed\u8bb2\u6388\u3002"}
      </div>
      <div className="mt-4 grid gap-3">
        <div className="rounded-2xl bg-slate-50 px-4 py-3 text-sm leading-6 text-slate-600">
          {alert
            ? "\u5efa\u8bae\u5148\u5728\u53f3\u4fa7\u67e5\u770b\u6559\u5b66\u7b56\u7565\uff0c\u4f18\u5148\u5904\u7406\u201c\u89c6\u89c9\u5316\u89e3\u91ca + \u5feb\u901f\u533f\u540d\u68c0\u6d4b\u201d\u8fd9\u4e24\u6b65\u3002"
            : "\u76ee\u524d\u5c1a\u672a\u8fbe\u5230\u52a8\u6001\u9608\u503c\uff0c\u53ef\u4ee5\u7ee7\u7eed\u89c2\u5bdf\u53cd\u9988\u5206\u5e03\u548c\u6700\u8fd1\u8d8b\u52bf\u3002"}
        </div>
        <div className="rounded-2xl border border-dashed border-slate-200 px-4 py-3 text-xs leading-6 text-slate-500">
          {alert
            ? "\u9884\u8b66\u89e6\u53d1\u540e\uff0c\u5efa\u8bae\u5148\u653e\u6162\u8282\u594f\uff0c\u518d\u7528\u4e00\u4e2a\u66f4\u76f4\u89c2\u7684\u56fe\u5f62\u6216\u4f8b\u5b50\u7a33\u4f4f\u7406\u89e3\u3002"
            : "\u8fd9\u91cc\u4f1a\u5728\u56f0\u60d1\u7387\u4e0a\u5347\u65f6\u51fa\u73b0\u663e\u6027\u63d0\u793a\uff0c\u9002\u5408\u73b0\u573a\u6f14\u793a\u9608\u503c\u89e6\u53d1\u6548\u679c\u3002"}
        </div>
      </div>
    </div>
  );
}
