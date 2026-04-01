"use client";

import { useEffect, useState } from "react";
import type { MindMapData } from "@/types/mindmap";
import { MindMapView } from "@/components/shared/mindmap-view";
import { PointSummary } from "@/components/shared/point-summary";
import { getJson } from "@/lib/api-client";

function formatTime(value: string) {
  return new Intl.DateTimeFormat("zh-CN", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false
  }).format(new Date(value));
}

export function StudentMindMapClient({ initialData }: { initialData: MindMapData }) {
  const [data, setData] = useState(initialData);
  const [statusText, setStatusText] = useState("\u5f53\u524d\u5c55\u793a\u7684\u662f\u6700\u8fd1\u4e00\u6b21\u751f\u6210\u7684\u5bfc\u56fe\u7ed3\u679c\u3002");

  useEffect(() => {
    let active = true;

    async function loadLatest() {
      try {
        const latest = await getJson<MindMapData>(`/api/mindmap?topicId=${initialData.topicId}`);
        if (active) {
          setData(latest);
          setStatusText("\u5df2\u540c\u6b65\u5230\u6559\u5e08\u6700\u65b0\u53d1\u5e03\u7684\u8bfe\u7a0b\u5bfc\u56fe\u3002");
        }
      } catch {
        if (active) {
          setStatusText("\u5f53\u524d\u4ecd\u5728\u4f7f\u7528\u672c\u5730\u5bfc\u56fe\u6570\u636e\u3002");
        }
      }
    }

    void loadLatest();
    const timer = window.setInterval(() => {
      void loadLatest();
    }, 5000);

    return () => {
      active = false;
      window.clearInterval(timer);
    };
  }, [initialData.topicId]);

  return (
    <div className="grid gap-6 lg:grid-cols-[0.95fr_1.05fr]">
      <div className="grid gap-6">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u5f53\u524d\u8bfe\u7a0b"}</div>
          <div className="mt-2 text-2xl font-bold text-slate-900">{data.courseName}</div>
          <div className="mt-3 text-sm leading-6 text-slate-600">
            {"\u5bfc\u56fe\u4f1a\u628a\u5168\u5fae\u5206\u3001\u65b9\u5411\u5bfc\u6570\u3001\u68af\u5ea6\u4e0e\u5207\u5e73\u9762\u7b49\u5173\u952e\u77e5\u8bc6\u70b9\u4e32\u8054\u8d77\u6765\u3002"}
          </div>
          <div className="mt-4 rounded-2xl bg-slate-50 px-4 py-3 text-sm text-slate-700">{`\u6700\u8fd1\u66f4\u65b0\u65f6\u95f4\uff1a${formatTime(data.updatedAt)}`}</div>
          <div className="mt-3 rounded-2xl bg-brand-50 px-4 py-3 text-sm text-brand-700">{statusText}</div>
        </div>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">{"\u77e5\u8bc6\u6458\u8981"}</h2>
          <div className="mt-4">
            <PointSummary points={data.summaryPoints} />
          </div>
        </div>
      </div>

      <div className="grid gap-6">
        <MindMapView data={data} />
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">{"\u6765\u6e90\u9875\u9762"}</h2>
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
