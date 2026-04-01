"use client";

import { useState } from "react";
import type { MindMapData } from "@/types/mindmap";
import { MindMapView } from "@/components/shared/mindmap-view";
import { PointSummary } from "@/components/shared/point-summary";

export function StudentMindMapClient({ initialData }: { initialData: MindMapData }) {
  const [data] = useState(initialData);

  return (
    <div className="grid gap-6 lg:grid-cols-[0.95fr_1.05fr]">
      <div className="grid gap-6">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">\u5f53\u524d\u8bfe\u7a0b</div>
          <div className="mt-2 text-2xl font-bold text-slate-900">{data.courseName}</div>
          <div className="mt-3 text-sm leading-6 text-slate-600">
            {"\u5bfc\u56fe\u4f1a\u628a\u5168\u5fae\u5206\u3001\u65b9\u5411\u5bfc\u6570\u3001\u68af\u5ea6\u4e0e\u5207\u5e73\u9762\u7b49\u5173\u952e\u77e5\u8bc6\u70b9\u4e32\u8054\u8d77\u6765\u3002"}
          </div>
        </div>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">\u77e5\u8bc6\u6458\u8981</h2>
          <div className="mt-4">
            <PointSummary points={data.summaryPoints} />
          </div>
        </div>
      </div>

      <div className="grid gap-6">
        <MindMapView data={data} />
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">\u6765\u6e90\u9875\u9762</h2>
          <div className="mt-4 grid gap-3">
            {data.sourceSlides.map((item) => (
              <div key={item} className="rounded-2xl bg-slate-50 px-4 py-3 text-sm leading-6 text-slate-700">
                {item}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}