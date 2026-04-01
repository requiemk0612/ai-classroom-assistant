"use client";

import { useState, type FormEvent } from "react";
import type { MindMapData } from "@/types/mindmap";
import { MindMapView } from "@/components/shared/mindmap-view";
import { PointSummary } from "@/components/shared/point-summary";

export function TeacherMindMapClient({ initialData }: { initialData: MindMapData }) {
  const [data, setData] = useState(initialData);
  const [courseName, setCourseName] = useState(initialData.courseName);
  const [pptFile, setPptFile] = useState<File | null>(null);
  const [statusText, setStatusText] = useState("\u53ef\u4ee5\u76f4\u63a5\u4e0a\u4f20 PPT\uff0c\u6216\u4ec5\u66f4\u65b0\u8bfe\u7a0b\u540d\u79f0\u540e\u91cd\u65b0\u751f\u6210\u6458\u8981\u3002");
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData();
    formData.append("courseName", courseName);
    if (pptFile) {
      formData.append("pptFile", pptFile);
    }

    setSubmitting(true);
    setStatusText("\u6b63\u5728\u751f\u6210\u6458\u8981\u4e0e\u5bfc\u56fe...");

    try {
      const response = await fetch("/api/mindmap", {
        method: "POST",
        body: formData
      });
      if (!response.ok) {
        throw new Error("Request failed");
      }
      const nextData = (await response.json()) as MindMapData;
      setData(nextData);
      setStatusText("\u5df2\u751f\u6210\u65b0\u7684\u8bfe\u7a0b\u6458\u8981\u4e0e\u5bfc\u56fe\u3002");
    } catch {
      setStatusText("\u672c\u6b21\u751f\u6210\u5931\u8d25\uff0c\u5f53\u524d\u7ee7\u7eed\u4fdd\u7559\u4e0a\u4e00\u7248\u5bfc\u56fe\u6570\u636e\u3002");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="grid gap-6 lg:grid-cols-[0.95fr_1.05fr]">
      <div className="grid gap-6">
        <form onSubmit={handleSubmit} className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <label className="text-sm font-medium text-slate-700">\u8bfe\u7a0b\u540d\u79f0</label>
          <input
            value={courseName}
            onChange={(event) => setCourseName(event.target.value)}
            className="mt-3 w-full rounded-2xl border border-slate-200 px-4 py-3 text-sm text-slate-800 outline-none focus:border-brand-500"
          />

          <label className="mt-4 block text-sm font-medium text-slate-700">PPT \u6587\u4ef6</label>
          <input
            type="file"
            accept=".ppt,.pptx"
            onChange={(event) => setPptFile(event.target.files?.[0] ?? null)}
            className="mt-3 block w-full rounded-2xl border border-slate-200 px-4 py-3 text-sm text-slate-700"
          />

          <div className="mt-4 rounded-2xl bg-slate-50 px-4 py-3 text-sm leading-6 text-slate-700">{statusText}</div>

          <button
            type="submit"
            disabled={submitting}
            className="mt-4 rounded-full bg-brand-600 px-5 py-3 text-sm font-semibold text-white transition hover:bg-brand-700 disabled:cursor-not-allowed disabled:opacity-60"
          >
            {submitting ? "\u6b63\u5728\u751f\u6210" : "\u66f4\u65b0\u6458\u8981\u4e0e\u5bfc\u56fe"}
          </button>
        </form>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">\u672c\u6b21\u6458\u8981</h2>
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