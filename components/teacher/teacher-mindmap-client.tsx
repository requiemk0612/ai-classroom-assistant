"use client";

import { useEffect, useRef, useState, type FormEvent } from "react";
import { PointSummary } from "@/components/shared/point-summary";
import { MindMapView } from "@/components/shared/mindmap-view";
import type { MindMapData } from "@/types/mindmap";
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

export function TeacherMindMapClient({ initialData }: { initialData: MindMapData }) {
  const [data, setData] = useState(initialData);
  const [courseName, setCourseName] = useState(initialData.courseName);
  const [pptFile, setPptFile] = useState<File | null>(null);
  const [statusText, setStatusText] = useState("\u53ef\u4ee5\u76f4\u63a5\u4e0a\u4f20 .pptx \u6587\u4ef6\uff0c\u6216\u4ec5\u66f4\u65b0\u8bfe\u7a0b\u540d\u79f0\u540e\u91cd\u65b0\u751f\u6210\u6458\u8981\u3002");
  const [submitting, setSubmitting] = useState(false);
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    let active = true;

    async function loadLatest() {
      try {
        const latest = await getJson<MindMapData>(`/api/mindmap?topicId=${initialData.topicId}`);
        if (active) {
          setData(latest);
          setCourseName(latest.courseName);
          setStatusText("\u5df2\u540c\u6b65\u5230\u6700\u65b0\u5bfc\u56fe\u6570\u636e\u3002");
        }
      } catch {
        if (active) {
          setStatusText("\u5f53\u524d\u4ecd\u5728\u4f7f\u7528\u672c\u5730\u5bfc\u56fe\u6570\u636e\u3002");
        }
      }
    }

    void loadLatest();

    return () => {
      active = false;
    };
  }, [initialData.topicId]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (pptFile && !pptFile.name.toLowerCase().endsWith(".pptx")) {
      setStatusText("\u8bf7\u4e0a\u4f20 .pptx \u683c\u5f0f\u7684\u6559\u5b66 PPT \u6587\u4ef6\u3002");
      return;
    }

    const formData = new FormData();
    formData.append("topicId", initialData.topicId);
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
        const payload = (await response.json().catch(() => null)) as { message?: string } | null;
        throw new Error(payload?.message || "Request failed");
      }
      const nextData = (await response.json()) as MindMapData;
      setData(nextData);
      setCourseName(nextData.courseName);
      setPptFile(null);
      if (fileInputRef.current) {
        fileInputRef.current.value = "";
      }
      setStatusText("\u5df2\u751f\u6210\u65b0\u7684\u8bfe\u7a0b\u6458\u8981\u4e0e\u5bfc\u56fe\uff0c\u5b66\u751f\u7aef\u4e5f\u53ef\u4ee5\u540c\u6b65\u67e5\u770b\u3002");
    } catch (error) {
      const message = error instanceof Error ? error.message : "\u672c\u6b21\u751f\u6210\u5931\u8d25\uff0c\u5f53\u524d\u7ee7\u7eed\u4fdd\u7559\u4e0a\u4e00\u7248\u5bfc\u56fe\u6570\u636e\u3002";
      setStatusText(message);
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="grid gap-6 lg:grid-cols-[0.95fr_1.05fr]">
      <div className="grid gap-6">
        <form onSubmit={handleSubmit} className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <label className="text-sm font-medium text-slate-700">{"\u8bfe\u7a0b\u540d\u79f0"}</label>
          <input
            value={courseName}
            onChange={(event) => setCourseName(event.target.value)}
            className="mt-3 w-full rounded-2xl border border-slate-200 px-4 py-3 text-sm text-slate-800 outline-none focus:border-brand-500"
          />

          <label className="mt-4 block text-sm font-medium text-slate-700">{"PPT \u6587\u4ef6"}</label>
          <input
            ref={fileInputRef}
            type="file"
            accept=".pptx"
            onChange={(event) => setPptFile(event.target.files?.[0] ?? null)}
            className="mt-3 block w-full rounded-2xl border border-slate-200 px-4 py-3 text-sm text-slate-700"
          />

          <div className="mt-4 rounded-2xl bg-slate-50 px-4 py-3 text-sm leading-6 text-slate-700">{statusText}</div>
          <div className="mt-4 rounded-2xl bg-brand-50 px-4 py-3 text-sm leading-6 text-brand-700">
            {"\u6f14\u793a\u5efa\u8bae\uff1a\u4f18\u5148\u4f7f\u7528\u6587\u672c\u578b .pptx \u6559\u5b66\u6587\u4ef6\uff0c\u7cfb\u7edf\u4f1a\u63d0\u53d6\u9875\u9762\u6587\u672c\u3001\u751f\u6210\u6458\u8981\u5e76\u540c\u6b65\u5230\u5b66\u751f\u7aef\u3002"}
          </div>
          <div className="mt-3 flex flex-wrap gap-2 text-xs text-slate-500">
            <span className="rounded-full bg-slate-100 px-3 py-1">{"\u652f\u6301 .pptx \u6587\u672c\u63d0\u53d6"}</span>
            <span className="rounded-full bg-slate-100 px-3 py-1">{"\u751f\u6210\u540e\u5b66\u751f\u7aef\u5bfc\u56fe\u4f1a\u540c\u6b65\u66f4\u65b0"}</span>
            <span className="rounded-full bg-slate-100 px-3 py-1">{`\u5f53\u524d\u4e3b\u9898\uff1a${initialData.topicId}`}</span>
          </div>

          <button
            type="submit"
            disabled={submitting}
            className="mt-4 rounded-full bg-brand-600 px-5 py-3 text-sm font-semibold text-white transition hover:bg-brand-700 disabled:cursor-not-allowed disabled:opacity-60"
          >
            {submitting ? "\u6b63\u5728\u751f\u6210" : "\u66f4\u65b0\u6458\u8981\u4e0e\u5bfc\u56fe"}
          </button>
        </form>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between gap-3">
            <h2 className="text-lg font-semibold text-slate-900">{"\u672c\u6b21\u6458\u8981"}</h2>
            <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">
              {`\u66f4\u65b0\u4e8e ${formatTime(data.updatedAt)}`}
            </span>
          </div>
          <div className="mt-4">
            <PointSummary points={data.summaryPoints} />
          </div>
        </div>
      </div>

      <div className="grid gap-6">
        <MindMapView data={data} />
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">{"\u63d0\u53d6\u9875\u9762\u9884\u89c8"}</h2>
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
