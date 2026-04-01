$root = "D:\Projects\ai-classroom-assistant"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom {
  param([string]$Path,[string]$Content)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom "$root\app\layout.tsx" @'
import type { Metadata } from "next";
import type { ReactNode } from "react";
import "./globals.css";

export const metadata: Metadata = {
  title: "AI Classroom Assistant Demo",
  description: "AI classroom assistant demo"
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="zh-CN">
      <body>{children}</body>
    </html>
  );
}
'@

Write-Utf8NoBom "$root\components\shared\page-shell.tsx" @'
import Link from "next/link";
import type { ReactNode } from "react";
import { AppNav } from "@/components/shared/app-nav";

export function PageShell({ title, subtitle, children }: { title: string; subtitle: string; children: ReactNode }) {
  return (
    <main className="min-h-screen px-4 py-6 md:px-8">
      <div className="mx-auto flex max-w-6xl flex-col gap-6">
        <div className="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200 md:p-8">
          <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
            <div className="max-w-3xl">
              <div className="inline-flex items-center rounded-full bg-brand-50 px-3 py-1 text-xs font-semibold text-brand-700">
                {"\u8bfe\u5802\u6f14\u793a\u7248"}
              </div>
              <div className="mt-4">
                <Link href="/" className="text-sm font-medium text-brand-600 transition hover:text-brand-700">
                  {"\u8fd4\u56de\u9996\u9875"}
                </Link>
              </div>
              <h1 className="mt-3 text-3xl font-bold tracking-tight text-slate-900 md:text-4xl">{title}</h1>
              <p className="mt-3 max-w-2xl text-sm leading-7 text-slate-600 md:text-base">{subtitle}</p>
            </div>
            <div className="rounded-3xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-600">
              {"\u6f14\u793a\u91cd\u70b9\uff1a\u5b9e\u65f6\u611f\u77e5\u3001\u6559\u5b66\u5efa\u8bae\u3001\u5b89\u5168\u95ee\u7b54\u3001PPT \u5bfc\u56fe"}
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
    title: "\u5b66\u751f\u7aef",
    items: [
      { href: "/student/feedback", label: "\u8bfe\u5802\u53cd\u9988" },
      { href: "/student/ask", label: "\u5b66\u751f\u95ee\u7b54" },
      { href: "/student/mindmap", label: "\u77e5\u8bc6\u5bfc\u56fe" }
    ]
  },
  {
    title: "\u6559\u5e08\u7aef",
    items: [
      { href: "/teacher/dashboard", label: "\u6559\u5e08\u4eea\u8868\u76d8" },
      { href: "/teacher/pressure", label: "\u538b\u529b\u611f\u77e5" },
      { href: "/teacher/mindmap", label: "PPT \u5bfc\u56fe" }
    ]
  }
];

export function AppNav() {
  const pathname = usePathname();

  return (
    <nav className="grid gap-4 md:grid-cols-2">
      {navGroups.map((group) => (
        <div key={group.title} className="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm font-semibold text-slate-900">{group.title}</div>
          <div className="mt-3 flex flex-wrap gap-2">
            {group.items.map((item) => {
              const active = pathname === item.href;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`rounded-full px-4 py-2 text-sm font-medium transition ${
                    active ? "bg-brand-600 text-white shadow-sm" : "bg-slate-100 text-slate-700 hover:bg-brand-50 hover:text-brand-700"
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

Write-Utf8NoBom "$root\app\student\feedback\page.tsx" @'
import { PageShell } from "@/components/shared/page-shell";
import { StudentFeedbackClient } from "@/components/student/student-feedback-client";

export default function StudentFeedbackPage() {
  return (
    <PageShell title="\u8bfe\u5802\u5b9e\u65f6\u53cd\u9988" subtitle="\u5b66\u751f\u7aef\u7f51\u9875\uff1a\u533f\u540d\u53cd\u9988\u5f53\u524d\u542c\u8bfe\u72b6\u6001\uff0c\u5e2e\u52a9\u8001\u5e08\u53ca\u65f6\u8c03\u6574\u8bb2\u89e3\u8282\u594f\u3002">
      <StudentFeedbackClient />
    </PageShell>
  );
}
'@

Write-Utf8NoBom "$root\app\student\ask\page.tsx" @'
import { PageShell } from "@/components/shared/page-shell";
import { StudentAskClient } from "@/components/student/student-ask-client";

export default function StudentAskPage() {
  return (
    <PageShell title="\u5b66\u751f\u95ee\u7b54" subtitle="\u5b66\u751f\u7aef\u7f51\u9875\uff1a\u57fa\u4e8e\u8bfe\u7a0b\u8d44\u6599\u8fdb\u884c\u5b89\u5168\u95ee\u7b54\uff0c\u8fd4\u56de\u7b54\u6848\u4e0e\u6765\u6e90\u6ce8\u8bb0\u3002">
      <StudentAskClient />
    </PageShell>
  );
}
'@

Write-Utf8NoBom "$root\app\teacher\dashboard\page.tsx" @'
import { PageShell } from "@/components/shared/page-shell";
import { TeacherDashboardClient } from "@/components/teacher/teacher-dashboard-client";
import { buildDashboardMetrics } from "@/lib/threshold";
import { loadSessionState } from "@/lib/file-store";

export default async function TeacherDashboardPage() {
  const session = await loadSessionState();
  const initialMetrics = buildDashboardMetrics(session);

  return (
    <PageShell title="\u6559\u5e08\u4eea\u8868\u76d8" subtitle="\u6559\u5e08\u7aef\u7f51\u9875\uff1a\u5b9e\u65f6\u67e5\u770b\u8bfe\u5802\u7406\u89e3\u72b6\u6001\uff0c\u9884\u8b66\u4fe1\u606f\u548c\u6559\u5b66\u7b56\u7565\u5efa\u8bae\u3002">
      <TeacherDashboardClient initialMetrics={initialMetrics} />
    </PageShell>
  );
}
'@
