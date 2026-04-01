import type { MindMapData, MindMapNode } from "@/types/mindmap";

interface TreeBranch {
  node: MindMapNode;
  children: MindMapNode[];
}

function buildTree(data: MindMapData): { root: MindMapNode | null; branches: TreeBranch[] } {
  const nodeMap = new Map(data.nodes.map((node) => [node.id, node]));
  const childMap = new Map<string, string[]>();

  data.edges.forEach((edge) => {
    const list = childMap.get(edge.source) ?? [];
    list.push(edge.target);
    childMap.set(edge.source, list);
  });

  const root = nodeMap.get("root") ?? data.nodes[0] ?? null;
  if (!root) {
    return { root: null, branches: [] };
  }

  const branches = (childMap.get(root.id) ?? [])
    .map((childId) => {
      const node = nodeMap.get(childId);
      if (!node) {
        return null;
      }

      const children = (childMap.get(childId) ?? [])
        .map((grandChildId) => nodeMap.get(grandChildId))
        .filter((item): item is MindMapNode => Boolean(item));

      return { node, children };
    })
    .filter((item): item is TreeBranch => Boolean(item));

  return { root, branches };
}

export function MindMapView({ data }: { data: MindMapData }) {
  const { root, branches } = buildTree(data);

  return (
    <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
      <div className="text-xs font-semibold tracking-[0.2em] text-brand-700">{"\u601d\u7ef4\u5bfc\u56fe"}</div>
      <div className="mt-4 flex justify-center">
        <div className="max-w-[560px] rounded-[24px] bg-brand-50 px-6 py-5 text-center shadow-sm ring-1 ring-brand-100">
          <div className="text-xs font-semibold tracking-[0.2em] text-brand-700">{"\u77e5\u8bc6\u4e3b\u9898"}</div>
          <div className="mt-2 text-lg font-semibold text-slate-900">{root?.data.label ?? data.courseName}</div>
          <div className="mt-2 text-sm leading-6 text-slate-600">
            {"\u4ee5\u8bfe\u7a0b\u4e3b\u9898\u4e3a\u4e2d\u5fc3\uff0c\u5c06\u5173\u952e\u6982\u5ff5\u6536\u675f\u4e3a\u53ef\u5feb\u901f\u56de\u987e\u7684\u5206\u652f\u7ed3\u6784\u3002"}
          </div>
        </div>
      </div>

      <div className="mt-4 flex justify-center">
        <div className="h-8 w-px bg-brand-200" />
      </div>

      <div className="grid gap-4 xl:grid-cols-2">
        {branches.map((branch) => (
          <div key={branch.node.id} className="rounded-[24px] border border-slate-200 bg-slate-50 p-5">
            <div className="flex items-start gap-3">
              <div className="mt-1 h-3 w-3 rounded-full bg-brand-500" />
              <div className="min-w-0">
                <div className="text-xs font-semibold tracking-[0.18em] text-slate-500">{"\u4e00\u7ea7\u5206\u652f"}</div>
                <div className="mt-2 text-base font-semibold leading-7 text-slate-900">{branch.node.data.label}</div>
              </div>
            </div>

            {branch.children.length > 0 ? (
              <div className="mt-4 space-y-3 border-l-2 border-brand-100 pl-5">
                {branch.children.map((child) => (
                  <div key={child.id} className="rounded-2xl bg-white px-4 py-3 ring-1 ring-slate-200">
                    <div className="text-xs font-semibold tracking-[0.18em] text-brand-700">{"\u5b50\u8282\u70b9"}</div>
                    <div className="mt-1 text-sm leading-6 text-slate-700">{child.data.label}</div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="mt-4 rounded-2xl bg-white px-4 py-3 text-sm leading-6 text-slate-600 ring-1 ring-slate-200">
                {"\u8be5\u5206\u652f\u6682\u65f6\u6ca1\u6709\u5c55\u5f00\u5b50\u8282\u70b9\uff0c\u53ef\u76f4\u63a5\u4f5c\u4e3a\u8bfe\u5802\u56de\u987e\u7684\u4e00\u7ea7\u7ebf\u7d22\u3002"}
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
