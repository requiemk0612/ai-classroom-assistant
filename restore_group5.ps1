$files = @{
  "D:\Projects\ai-classroom-assistant\app\page.tsx" = @'
import Link from "next/link";
import { PageShell } from "@/components/shared/page-shell";

const sections = [
  {
    title: "\u5b66\u751f\u4fa7",
    items: [
      { href: "/student/feedback", label: "\u5b66\u751f\u53cd\u9988", desc: "\u533f\u540d\u63d0\u4ea4\u542c\u61c2\u7a0b\u5ea6\u4e0e\u5370\u8c61\uff0c\u5b9e\u65f6\u540c\u6b65\u5230\u6559\u5e08\u7aef\u3002" },
      { href: "/student/ask", label: "\u8bfe\u5802\u95ee\u7b54", desc: "\u7ed3\u5408\u8bfe\u7a0b\u8d44\u6599\u751f\u6210\u7b54\u6848\uff0c\u5e76\u7ed9\u51fa\u5bf9\u5e94\u6765\u6e90\u811a\u6ce8\u3002" },
      { href: "/student/mindmap", label: "\u77e5\u8bc6\u5bfc\u56fe", desc: "\u67e5\u770b\u8001\u5e08\u4e0a\u4f20 PPT \u540e\u751f\u6210\u7684\u6458\u8981\u4e0e\u5bfc\u56fe\u3002" }
    ]
  },
  {
    title: "\u6559\u5e08\u4fa7",
    items: [
      { href: "/teacher/dashboard", label: "\u6559\u5e08\u4eea\u8868\u76d8", desc: "\u67e5\u770b\u5b9e\u65f6\u53cd\u9988\u3001\u56f0\u60d1\u8d8b\u52bf\u3001\u9884\u8b66\u4e0e\u6559\u5b66\u7b56\u7565\u3002" },
      { href: "/teacher/pressure", label: "\u538b\u529b\u611f\u77e5", desc: "\u57fa\u4e8e\u4f5c\u4e1a\u901f\u5ea6\u3001\u6b63\u786e\u7387\u548c\u60c5\u7eea\u8bcd\u8fdb\u884c\u7b80\u8981\u9884\u5224\u3002" },
      { href: "/teacher/mindmap", label: "PPT \u5bfc\u56fe", desc: "\u4e0a\u4f20 PPT \u6216\u76f4\u63a5\u5207\u6362\u8bfe\u7a0b\u540d\u79f0\uff0c\u751f\u6210\u6458\u8981\u4e0e\u5bfc\u56fe\u3002" }
    ]
  }
];

export default function HomePage() {
  return (
    <PageShell
      title="AI \u8bfe\u5802\u52a9\u6559 Demo"
      subtitle="\u8fd9\u4e2a\u6f14\u793a\u7248\u540c\u65f6\u8986\u76d6\u5b66\u751f\u53cd\u9988\u3001\u8bfe\u5802\u95ee\u7b54\u3001\u6559\u5e08\u4fa7\u9884\u8b66\u3001\u538b\u529b\u611f\u77e5\u4e0e PPT \u5bfc\u56fe\u4e09\u6761\u4e3b\u8981\u94fe\u8def\u3002"
    >
      <div className="grid gap-6 md:grid-cols-2">
        {sections.map((section) => (
          <div key={section.title} className="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200">
            <h2 className="text-xl font-semibold text-slate-900">{section.title}</h2>
            <div className="mt-4 grid gap-3">
              {section.items.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 transition hover:border-brand-500 hover:bg-brand-50"
                >
                  <div className="text-sm font-semibold text-slate-900">{item.label}</div>
                  <div className="mt-2 text-sm leading-6 text-slate-600">{item.desc}</div>
                </Link>
              ))}
            </div>
          </div>
        ))}
      </div>
    </PageShell>
  );
}
'@
  "D:\Projects\ai-classroom-assistant\app\student\mindmap\page.tsx" = @'
import { StudentMindMapClient } from "@/components/student/student-mindmap-client";
import { PageShell } from "@/components/shared/page-shell";
import { loadMindMapData } from "@/lib/file-store";

export default async function StudentMindMapPage() {
  const initialData = await loadMindMapData();

  return (
    <PageShell
      title="\u5b66\u751f\u77e5\u8bc6\u5bfc\u56fe"
      subtitle="\u7528\u7b80\u660e\u6458\u8981\u548c\u5173\u952e\u8282\u70b9\u5e2e\u52a9\u5b66\u751f\u5feb\u901f\u56de\u987e\u672c\u8282\u8bfe\u5185\u5bb9\u3002"
    >
      <StudentMindMapClient initialData={initialData} />
    </PageShell>
  );
}
'@
  "D:\Projects\ai-classroom-assistant\app\teacher\mindmap\page.tsx" = @'
import { TeacherMindMapClient } from "@/components/teacher/teacher-mindmap-client";
import { PageShell } from "@/components/shared/page-shell";
import { loadMindMapData } from "@/lib/file-store";

export default async function TeacherMindMapPage() {
  const initialData = await loadMindMapData();

  return (
    <PageShell
      title="PPT \u6458\u8981\u4e0e\u5bfc\u56fe"
      subtitle="\u6559\u5e08\u53ef\u4ee5\u4e0a\u4f20 PPT\uff0c\u8ba9\u7cfb\u7edf\u751f\u6210\u6458\u8981\u3001\u5bfc\u56fe\u548c\u6765\u6e90\u9875\u9762\u63d0\u793a\u3002"
    >
      <TeacherMindMapClient initialData={initialData} />
    </PageShell>
  );
}
'@
  "D:\Projects\ai-classroom-assistant\app\teacher\pressure\page.tsx" = @'
import { PageShell } from "@/components/shared/page-shell";
import { TeacherPressureClient } from "@/components/teacher/teacher-pressure-client";
import { loadPressureData } from "@/lib/file-store";

export default async function TeacherPressurePage() {
  const initialData = await loadPressureData();

  return (
    <PageShell
      title="\u8bfe\u540e\u538b\u529b\u611f\u77e5"
      subtitle="\u57fa\u4e8e\u4f5c\u4e1a\u901f\u5ea6\u3001\u6b63\u786e\u7387\u548c\u60c5\u7eea\u8bcd\uff0c\u7ed9\u51fa\u4e00\u4e2a\u7b80\u8981\u7684\u6559\u5b66\u4ecb\u5165\u5efa\u8bae\u3002"
    >
      <TeacherPressureClient initialData={initialData} />
    </PageShell>
  );
}
'@
  "D:\Projects\ai-classroom-assistant\components\shared\point-summary.tsx" = @'
export function PointSummary({ points }: { points: string[] }) {
  return (
    <ul className="grid gap-3">
      {points.map((point) => (
        <li key={point} className="rounded-2xl bg-slate-50 px-4 py-3 text-sm leading-6 text-slate-700">
          {point}
        </li>
      ))}
    </ul>
  );
}
'@
  "D:\Projects\ai-classroom-assistant\components\shared\mindmap-view.tsx" = @'
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
'@
  "D:\Projects\ai-classroom-assistant\components\student\student-mindmap-client.tsx" = @'
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
'@
  "D:\Projects\ai-classroom-assistant\components\teacher\teacher-mindmap-client.tsx" = @'
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
'@
  "D:\Projects\ai-classroom-assistant\components\teacher\teacher-pressure-client.tsx" = @'
"use client";

import { useEffect, useMemo, useState } from "react";
import type { PressureData } from "@/types/classroom";
import type { PressureResponse } from "@/types/api";
import { getWeatherLevel } from "@/lib/confidence";
import { getJson } from "@/lib/api-client";

export function TeacherPressureClient({ initialData }: { initialData: PressureData }) {
  const [data, setData] = useState(initialData);
  const [microStrategies, setMicroStrategies] = useState<string[]>([
    "\u53ef\u4ee5\u5148\u628a\u68af\u5ea6\u4e0e\u65b9\u5411\u5bfc\u6570\u7684\u5173\u7cfb\u7528\u4e00\u5f20\u56fe\u91cd\u65b0\u4e32\u4e00\u904d\u3002",
    "\u8865\u4e00\u4e2a\u7b80\u77ed\u4f8b\u9898\uff0c\u8ba9\u5b66\u751f\u533a\u5206\u201c\u65b9\u5411\u201d\u4e0e\u201c\u589e\u957f\u901f\u5ea6\u201d\u3002",
    "\u8bfe\u540e\u53d1\u4e00\u4e2a\u5fae\u7ec3\u4e60\uff0c\u5e2e\u5b66\u751f\u5de9\u56fa\u516c\u5f0f\u4e0e\u56fe\u50cf\u5173\u7cfb\u3002"
  ]);
  const [weather, setWeather] = useState(getWeatherLevel((1 - initialData.homeworkSpeed + (1 - initialData.accuracyRate)) / 2));
  const [statusText, setStatusText] = useState("\u5f53\u524d\u5c55\u793a\u7684\u662f\u8fd1\u671f\u8bfe\u540e\u538b\u529b\u7b80\u62a5\u3002");

  useEffect(() => {
    let active = true;

    async function loadPressure() {
      try {
        const response = await getJson<PressureResponse>("/api/pressure");
        if (!active) {
          return;
        }
        setData(response);
        setMicroStrategies(response.microStrategies);
        setWeather(response.weatherLevel);
        setStatusText("\u5df2\u540c\u6b65\u5230\u6700\u65b0\u538b\u529b\u611f\u77e5\u6570\u636e\u3002");
      } catch {
        if (active) {
          setStatusText("\u672a\u80fd\u5237\u65b0\u6700\u65b0\u6570\u636e\uff0c\u4ecd\u5728\u5c55\u793a\u672c\u5730\u793a\u4f8b\u7ed3\u679c\u3002");
        }
      }
    }

    void loadPressure();

    return () => {
      active = false;
    };
  }, []);

  const pressureScore = useMemo(() => (1 - data.homeworkSpeed + (1 - data.accuracyRate)) / 2, [data]);

  return (
    <div className="grid gap-6">
      <div className="rounded-[28px] bg-white p-4 text-sm text-slate-600 shadow-sm ring-1 ring-slate-200">{statusText}</div>

      <div className="grid gap-6 md:grid-cols-4">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">\u538b\u529b\u6307\u6570</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{pressureScore.toFixed(2)}</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">\u5929\u6c14\u72b6\u6001</div>
          <div className="mt-2 text-4xl font-bold text-brand-600">{weather}</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">\u6b63\u786e\u7387</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{Math.round(data.accuracyRate * 100)}%</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">\u4f5c\u4e1a\u8fdb\u5ea6</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{Math.round(data.homeworkSpeed * 100)}%</div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">\u60c5\u7eea\u5173\u952e\u8bcd</h2>
          <div className="mt-4 flex flex-wrap gap-3">
            {data.moodWords.map((item) => (
              <span key={item} className="rounded-full bg-slate-100 px-4 py-2 text-sm text-slate-700">
                {item}
              </span>
            ))}
          </div>

          <div className="mt-6">
            <h3 className="text-sm font-semibold text-slate-900">\u8fd1\u4e94\u6b21\u538b\u529b\u8d8b\u52bf</h3>
            <div className="mt-3 flex h-24 items-end gap-3 rounded-2xl bg-slate-50 px-4 py-4">
              {data.weeklyTrend.map((value, index) => (
                <div key={`${value}-${index}`} className="flex flex-1 flex-col items-center gap-2">
                  <div className="w-full rounded-full bg-brand-100" style={{ height: `${Math.max(14, Math.round(value * 100))}%` }} />
                  <div className="text-xs text-slate-500">{`\u7b2c${index + 1}\u6b21`}</div>
                </div>
              ))}
            </div>
          </div>

          <div className="mt-6">
            <h3 className="text-sm font-semibold text-slate-900">\u5fae\u7b56\u7565\u5efa\u8bae</h3>
            <ul className="mt-3 space-y-2 text-sm text-slate-700">
              {microStrategies.map((item) => (
                <li key={item} className="rounded-2xl bg-slate-50 px-4 py-3 leading-6">
                  {item}
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">\u77e5\u8bc6\u7b80\u5316\u5305</h2>
          <div className="mt-4 rounded-2xl bg-slate-50 px-4 py-4">
            <div className="text-sm font-semibold text-slate-900">{data.simplificationPack.title}</div>
            <div className="mt-2 text-sm leading-6 text-slate-700">{data.simplificationPack.summary}</div>
            <ul className="mt-3 space-y-2 text-sm text-slate-700">
              {data.simplificationPack.actions.map((item) => (
                <li key={item} className="rounded-xl bg-white px-3 py-2">
                  {item}
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
'@
  "D:\Projects\ai-classroom-assistant\data\mindmap-data.json" = @'
{
  "topicId": "gradient",
  "courseName": "\u9ad8\u7b49\u6570\u5b66\uff1a\u5168\u5fae\u5206\u3001\u65b9\u5411\u5bfc\u6570\u4e0e\u68af\u5ea6",
  "summaryPoints": [
    "\u5168\u5fae\u5206\u7528\u4e8e\u63cf\u8ff0\u591a\u5143\u51fd\u6570\u5728\u5c40\u90e8\u7684\u4e3b\u8981\u53d8\u5316\u90e8\u5206\u3002",
    "\u65b9\u5411\u5bfc\u6570\u8868\u793a\u51fd\u6570\u6cbf\u6307\u5b9a\u65b9\u5411\u7684\u53d8\u5316\u7387\u3002",
    "\u8ba1\u7b97\u65b9\u5411\u5bfc\u6570\u65f6\u8981\u5148\u786e\u5b9a\u5355\u4f4d\u5411\u91cf\u3002",
    "\u68af\u5ea6\u7531\u5404\u4e2a\u504f\u5bfc\u6570\u6784\u6210\uff0c\u6307\u5411\u503c\u589e\u957f\u6700\u5feb\u7684\u65b9\u5411\u3002",
    "\u68af\u5ea6\u7684\u6a21\u7b49\u4e8e\u6700\u5927\u65b9\u5411\u5bfc\u6570\u3002",
    "\u68af\u5ea6\u4e0e\u7b49\u9ad8\u7ebf\u5782\u76f4\uff0c\u6709\u52a9\u4e8e\u7406\u89e3\u51e0\u4f55\u610f\u4e49\u3002"
  ],
  "nodes": [
    { "id": "root", "data": { "label": "\u591a\u5143\u51fd\u6570\u5fae\u5206" }, "position": { "x": 420, "y": 40 } },
    { "id": "node_1", "data": { "label": "\u5168\u5fae\u5206" }, "position": { "x": 120, "y": 200 } },
    { "id": "node_2", "data": { "label": "\u65b9\u5411\u5bfc\u6570" }, "position": { "x": 300, "y": 200 } },
    { "id": "node_3", "data": { "label": "\u5355\u4f4d\u5411\u91cf" }, "position": { "x": 480, "y": 200 } },
    { "id": "node_4", "data": { "label": "\u68af\u5ea6" }, "position": { "x": 660, "y": 200 } },
    { "id": "node_5", "data": { "label": "\u6700\u5927\u53d8\u5316\u7387" }, "position": { "x": 840, "y": 200 } },
    { "id": "node_6", "data": { "label": "\u7b49\u9ad8\u7ebf\u5782\u76f4" }, "position": { "x": 1020, "y": 200 } }
  ],
  "edges": [
    { "id": "edge_1", "source": "root", "target": "node_1" },
    { "id": "edge_2", "source": "root", "target": "node_2" },
    { "id": "edge_3", "source": "root", "target": "node_3" },
    { "id": "edge_4", "source": "root", "target": "node_4" },
    { "id": "edge_5", "source": "root", "target": "node_5" },
    { "id": "edge_6", "source": "root", "target": "node_6" }
  ],
  "sourceSlides": [
    "\u7b2c1\u9875\uff1a\u591a\u5143\u51fd\u6570\u5fae\u5206\u4e0e\u51e0\u4f55\u76f4\u89c2",
    "\u7b2c2\u9875\uff1a\u5168\u5fae\u5206\u7684\u5b9a\u4e49\u4e0e\u610f\u4e49",
    "\u7b2c3\u9875\uff1a\u65b9\u5411\u5bfc\u6570\u7684\u516c\u5f0f\u4e0e\u56fe\u50cf",
    "\u7b2c4\u9875\uff1a\u68af\u5ea6\u7684\u5b9a\u4e49\u4e0e\u51e0\u4f55\u89e3\u91ca",
    "\u7b2c5\u9875\uff1a\u68af\u5ea6\u4e0e\u6700\u5927\u53d8\u5316\u7387"
  ],
  "updatedAt": "2026-04-01T03:55:55.690Z"
}
'@
  "D:\Projects\ai-classroom-assistant\server\socket.ts" = @'
import type { Server } from "socket.io";
import type { FeedbackItem } from "@/types/classroom";
import { canSendFeedback } from "@/lib/anti-fake";
import { buildStrategyResponse } from "@/lib/strategy-engine";
import { addFeedback, getMetrics } from "./state";

export function registerSocketHandlers(io: Server): void {
  io.on("connection", (socket) => {
    socket.on("feedback:send", async (payload: FeedbackItem) => {
      if (!payload?.studentId || !canSendFeedback(payload.studentId)) {
        socket.emit("feedback:rejected", { message: "\u53cd\u9988\u53d1\u9001\u8fc7\u4e8e\u9891\u7e41\uff0c\u8bf7\u7a0d\u540e\u518d\u8bd5\u3002" });
        return;
      }

      await addFeedback(payload);
      const metrics = getMetrics();
      io.emit("metrics:update", metrics);

      if (metrics.alert) {
        const strategy = await buildStrategyResponse(metrics.alert.topicId, metrics.confusionRate);
        io.emit("strategy:update", strategy);
      }
    });
  });
}
'@
}

foreach ($path in $files.Keys) {
  $dir = Split-Path -Parent $path
  if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }

  [System.IO.File]::WriteAllText($path, $files[$path], [System.Text.UTF8Encoding]::new($false))
}
