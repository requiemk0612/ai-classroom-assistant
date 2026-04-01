$root = "D:\Projects\ai-classroom-assistant"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom {
  param(
    [string]$Path,
    [string]$Content
  )

  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom "$root\app\page.tsx" @'
import Link from "next/link";
import { PageShell } from "@/components/shared/page-shell";

const sections = [
  {
    title: "学生端",
    items: [
      { href: "/student/feedback", label: "课堂反馈", desc: "匿名提交听课感受，实时反馈课堂节奏。" },
      { href: "/student/ask", label: "学生问答", desc: "基于课程资料进行安全问答，并附来源注记。" },
      { href: "/student/mindmap", label: "知识导图", desc: "查看老师最新生成的知识点摘要与导图。" }
    ]
  },
  {
    title: "教师端",
    items: [
      { href: "/teacher/dashboard", label: "教师仪表盘", desc: "查看困惑率、反馈趋势、预警和策略建议。" },
      { href: "/teacher/pressure", label: "压力感知", desc: "观察班级压力状态和下一节课的微策略。" },
      { href: "/teacher/mindmap", label: "PPT 导图", desc: "上传 PPT，生成知识点摘要和共享导图。" }
    ]
  }
];

export default function HomePage() {
  return (
    <PageShell
      title="AI 课堂教学辅助演示"
      subtitle="统一入口页面：从这里切换学生端与教师端演示流程，展示课堂实时感知、问答、压力分析和 PPT 导图能力。"
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

Write-Utf8NoBom "$root\app\student\feedback\page.tsx" @'
import { PageShell } from "@/components/shared/page-shell";
import { StudentFeedbackClient } from "@/components/student/student-feedback-client";

export default function StudentFeedbackPage() {
  return (
    <PageShell title="课堂实时反馈" subtitle="学生端网页：匿名反馈当前听课状态，帮助老师及时调整讲解节奏。">
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
    <PageShell title="学生问答" subtitle="学生端网页：基于课程资料进行安全问答，返回答案与来源注记。">
      <StudentAskClient />
    </PageShell>
  );
}
'@

Write-Utf8NoBom "$root\app\student\mindmap\page.tsx" @'
import { PageShell } from "@/components/shared/page-shell";
import { StudentMindMapClient } from "@/components/student/student-mindmap-client";
import { loadMindMapData } from "@/lib/file-store";

export default async function StudentMindMapPage() {
  const data = await loadMindMapData();

  return (
    <PageShell title="知识导图" subtitle="学生端网页：查看当前课程的知识点结构与老师最新生成的导图。">
      <StudentMindMapClient initialData={data} />
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
    <PageShell title="教师仪表盘" subtitle="教师端网页：实时查看课堂理解状态、预警信息和教学策略建议。">
      <TeacherDashboardClient initialMetrics={initialMetrics} />
    </PageShell>
  );
}
'@

Write-Utf8NoBom "$root\app\teacher\pressure\page.tsx" @'
import { PageShell } from "@/components/shared/page-shell";
import { TeacherPressureClient } from "@/components/teacher/teacher-pressure-client";
import { loadPressureData } from "@/lib/file-store";

export default async function TeacherPressurePage() {
  const data = await loadPressureData();

  return (
    <PageShell title="压力感知" subtitle="教师端网页：查看班级压力状态，并获得下一节课的微策略建议。">
      <TeacherPressureClient initialData={data} />
    </PageShell>
  );
}
'@

Write-Utf8NoBom "$root\app\teacher\mindmap\page.tsx" @'
import { PageShell } from "@/components/shared/page-shell";
import { TeacherMindMapClient } from "@/components/teacher/teacher-mindmap-client";
import { loadMindMapData } from "@/lib/file-store";

export default async function TeacherMindMapPage() {
  const data = await loadMindMapData();

  return (
    <PageShell title="PPT 知识导图" subtitle="教师端网页：上传 PPT，提炼知识点摘要并生成共享导图。">
      <TeacherMindMapClient initialData={data} />
    </PageShell>
  );
}
'@
