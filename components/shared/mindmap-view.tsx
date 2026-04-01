import type { MindMapData } from "@/types/mindmap";

export function MindMapView({ data }: { data: MindMapData }) {
  const rootNode = data.nodes[0];
  const childNodes = data.nodes.slice(1);

  return (
    <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
      <div className="rounded-3xl bg-brand-50 px-5 py-4">
        <div className="text-xs font-semibold uppercase tracking-[0.2em] text-brand-700">Mind Map</div>
        <div className="mt-2 text-lg font-semibold text-slate-900">
          {rootNode?.data.label ?? data.courseName}
        </div>
      </div>

      <div className="mt-4 grid gap-3 md:grid-cols-2 xl:grid-cols-3">
        {childNodes.map((node) => (
          <div key={node.id} className="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4">
            <div className="text-sm font-semibold text-slate-900">{node.data.label}</div>
            <div className="mt-2 text-xs text-slate-500">
              {`\u8282\u70b9\u5750\u6807\uff1a${node.position.x}, ${node.position.y}`}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}