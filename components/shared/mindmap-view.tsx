import type { MindMapData } from "@/types/mindmap";

export function MindMapView({ data }: { data: MindMapData }) {
  const rootNode = data.nodes[0];
  const childNodes = data.nodes.slice(1);

  return (
    <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
      <div className="rounded-3xl bg-brand-50 px-5 py-4">
        <div className="text-xs font-semibold tracking-[0.2em] text-brand-700">{"\u77e5\u8bc6\u4e3b\u5e72"}</div>
        <div className="mt-2 text-lg font-semibold text-slate-900">{rootNode?.data.label ?? data.courseName}</div>
        <div className="mt-2 text-sm text-slate-600">{data.courseName}</div>
      </div>

      <div className="mt-4 grid gap-3 md:grid-cols-2 xl:grid-cols-3">
        {childNodes.map((node) => (
          <div key={node.id} className="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4">
            <div className="text-xs font-semibold uppercase tracking-[0.2em] text-slate-400">Node</div>
            <div className="mt-2 text-sm font-semibold text-slate-900">{node.data.label}</div>
            <div className="mt-2 text-xs text-slate-500">{"\u53ef\u4f5c\u4e3a\u8bfe\u5802\u56de\u987e\u6216\u8bb2\u6388\u7ebf\u7d22\u7684\u4e3b\u8981\u5c0f\u8282\u70b9\u3002"}</div>
          </div>
        ))}
      </div>
    </div>
  );
}
