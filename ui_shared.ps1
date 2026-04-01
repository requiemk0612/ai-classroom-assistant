$root = "D:\Projects\ai-classroom-assistant"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom {
  param(
    [string]$Path,
    [string]$Content
  )

  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom "$root\app\layout.tsx" @'
import type { Metadata } from "next";
import type { ReactNode } from "react";
import "./globals.css";

export const metadata: Metadata = {
  title: "AI 课堂教学辅助演示",
  description: "面向课堂场景的 AI 教学辅助演示系统"
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="zh-CN">
      <body>{children}</body>
    </html>
  );
}
'@

Write-Utf8NoBom "$root\app\globals.css" @'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  color-scheme: light;
}

body {
  margin: 0;
  min-height: 100vh;
  background:
    radial-gradient(circle at top left, rgba(59, 130, 246, 0.14), transparent 34%),
    radial-gradient(circle at top right, rgba(14, 165, 233, 0.12), transparent 28%),
    linear-gradient(180deg, #f8fbff 0%, #eef4ff 48%, #f7f9fc 100%);
  color: #0f172a;
  font-family: "PingFang SC", "Noto Sans SC", "Microsoft YaHei", sans-serif;
}

a {
  color: inherit;
  text-decoration: none;
}

* {
  box-sizing: border-box;
}

::selection {
  background: rgba(37, 99, 235, 0.18);
}
'@

Write-Utf8NoBom "$root\components\shared\page-shell.tsx" @'
import Link from "next/link";
import type { ReactNode } from "react";
import { AppNav } from "@/components/shared/app-nav";

export function PageShell({
  title,
  subtitle,
  children
}: {
  title: string;
  subtitle: string;
  children: ReactNode;
}) {
  return (
    <main className="min-h-screen px-4 py-6 md:px-8">
      <div className="mx-auto flex max-w-6xl flex-col gap-6">
        <div className="overflow-hidden rounded-[32px] bg-white/90 p-6 shadow-[0_24px_60px_rgba(15,23,42,0.08)] ring-1 ring-white/70 backdrop-blur md:p-8">
          <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
            <div className="max-w-3xl">
              <div className="inline-flex items-center rounded-full bg-brand-50 px-3 py-1 text-xs font-semibold text-brand-700">
                课堂演示版
              </div>
              <div className="mt-4">
                <Link href="/" className="text-sm font-medium text-brand-600 transition hover:text-brand-700">
                  返回首页
                </Link>
              </div>
              <h1 className="mt-3 text-3xl font-bold tracking-tight text-slate-900 md:text-4xl">{title}</h1>
              <p className="mt-3 max-w-2xl text-sm leading-7 text-slate-600 md:text-base">{subtitle}</p>
            </div>
            <div className="rounded-3xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-600">
              演示重点：实时感知、教学建议、安全问答、PPT 导图
            </div>
          </div>
        </div>
        <AppNav />
        {children}
      </div>
    </main>
  );
}
'@

Write-Utf8NoBom "$root\components\shared\app-nav.tsx" @'
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const navGroups = [
  {
    title: "学生端",
    items: [
      { href: "/student/feedback", label: "课堂反馈" },
      { href: "/student/ask", label: "学生问答" },
      { href: "/student/mindmap", label: "知识导图" }
    ]
  },
  {
    title: "教师端",
    items: [
      { href: "/teacher/dashboard", label: "教师仪表盘" },
      { href: "/teacher/pressure", label: "压力感知" },
      { href: "/teacher/mindmap", label: "PPT 导图" }
    ]
  }
];

export function AppNav() {
  const pathname = usePathname();

  return (
    <nav className="grid gap-4 md:grid-cols-2">
      {navGroups.map((group) => (
        <div key={group.title} className="rounded-3xl bg-white/90 p-5 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm font-semibold text-slate-900">{group.title}</div>
          <div className="mt-3 flex flex-wrap gap-2">
            {group.items.map((item) => {
              const active = pathname === item.href;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`rounded-full px-4 py-2 text-sm font-medium transition ${
                    active
                      ? "bg-brand-600 text-white shadow-sm"
                      : "bg-slate-100 text-slate-700 hover:bg-brand-50 hover:text-brand-700"
                  }`}
                >
                  {item.label}
                </Link>
              );
            })}
          </div>
        </div>
      ))}
    </nav>
  );
}
'@

Write-Utf8NoBom "$root\components\shared\point-summary.tsx" @'
export function PointSummary({ points }: { points: string[] }) {
  return (
    <div className="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <h2 className="text-lg font-semibold text-slate-900">知识点总结</h2>
      <ul className="mt-4 space-y-2 text-sm text-slate-700">
        {points.length > 0 ? (
          points.map((point, index) => (
            <li key={`${point}-${index}`} className="rounded-2xl bg-slate-50 px-4 py-3 leading-6">
              {index + 1}. {point}
            </li>
          ))
        ) : (
          <li className="rounded-2xl bg-slate-50 px-4 py-3 text-slate-500">当前还没有可展示的知识点摘要。</li>
        )}
      </ul>
    </div>
  );
}
'@

Write-Utf8NoBom "$root\components\shared\mindmap-view.tsx" @'
"use client";

import { useMemo } from "react";
import ReactFlow, { Background, Controls } from "reactflow";
import "reactflow/dist/style.css";
import type { MindMapData } from "@/types/mindmap";

export function MindMapView({ data }: { data: MindMapData }) {
  const nodes = useMemo(() => data.nodes, [data.nodes]);
  const edges = useMemo(() => data.edges, [data.edges]);

  return (
    <div className="overflow-hidden rounded-[28px] border border-slate-200 bg-white shadow-sm">
      <div className="flex items-center justify-between border-b border-slate-100 px-5 py-4">
        <div>
          <div className="text-sm font-semibold text-slate-900">知识结构图</div>
          <div className="mt-1 text-xs text-slate-500">根节点为课程主题，分支节点用于展示当前课堂知识结构。</div>
        </div>
        <div className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">
          {data.nodes.length} 个节点
        </div>
      </div>
      <div className="h-[460px] bg-[linear-gradient(180deg,#ffffff_0%,#f8fbff_100%)]">
        <ReactFlow fitView nodes={nodes} edges={edges} nodesDraggable={false} elementsSelectable={false}>
          <Background gap={18} size={1} color="#dbeafe" />
          <Controls showInteractive={false} />
        </ReactFlow>
      </div>
    </div>
  );
}
'@
