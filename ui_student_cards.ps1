$root = "D:\Projects\ai-classroom-assistant"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom {
  param(
    [string]$Path,
    [string]$Content
  )

  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom "$root\components\student\student-feedback-client.tsx" @'
"use client";

import { useEffect, useMemo, useState } from "react";
import { v4 as uuidv4 } from "uuid";
import { getSocket } from "@/lib/socket-client";

const feedbackItems = [
  {
    value: "understand",
    label: "听懂了",
    desc: "这部分节奏合适，可以继续往下讲。",
    color: "bg-emerald-500",
    lightColor: "bg-emerald-50 text-emerald-700"
  },
  {
    value: "too_fast",
    label: "有点快",
    desc: "能跟上大意，但推导速度可以再放慢一些。",
    color: "bg-amber-500",
    lightColor: "bg-amber-50 text-amber-700"
  },
  {
    value: "confused",
    label: "没听懂",
    desc: "当前知识点还需要老师重新解释或换个角度讲。",
    color: "bg-rose-500",
    lightColor: "bg-rose-50 text-rose-700"
  },
  {
    value: "clear_example",
    label: "这个例子很清楚",
    desc: "例子有帮助，希望继续用这种方式讲解。",
    color: "bg-sky-500",
    lightColor: "bg-sky-50 text-sky-700"
  }
] as const;

type FeedbackValue = (typeof feedbackItems)[number]["value"];

function getStudentId() {
  if (typeof window === "undefined") return "";
  const savedId = window.localStorage.getItem("studentId");
  if (savedId) return savedId;
  const nextId = `stu_${uuidv4().slice(0, 8)}`;
  window.localStorage.setItem("studentId", nextId);
  return nextId;
}

function getFeedbackLabel(value: FeedbackValue | null) {
  return feedbackItems.find((item) => item.value === value)?.label ?? "暂未提交";
}

export function StudentFeedbackClient() {
  const [statusText, setStatusText] = useState("等待发送课堂反馈。");
  const [topicId] = useState("gradient");
  const [studentId, setStudentId] = useState("");
  const [socketReady, setSocketReady] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [lastFeedback, setLastFeedback] = useState<FeedbackValue | null>(null);
  const [recentFeedback, setRecentFeedback] = useState<FeedbackValue[]>([
    "understand",
    "clear_example",
    "too_fast",
    "understand"
  ]);

  useEffect(() => {
    setStudentId(getStudentId());
    const socket = getSocket();

    function handleConnect() {
      setSocketReady(true);
      setStatusText("已连接实时反馈通道，可以直接提交匿名反馈。");
    }

    function handleDisconnect() {
      setSocketReady(false);
      setStatusText("实时通道暂时断开，当前会使用本地提交方式。");
    }

    function handleRejected(data: { message?: string }) {
      setSubmitting(false);
      setStatusText(data.message ?? "反馈发送失败，请稍后再试。");
    }

    setSocketReady(socket.connected);
    socket.on("connect", handleConnect);
    socket.on("disconnect", handleDisconnect);
    socket.on("feedback:rejected", handleRejected);

    return () => {
      socket.off("connect", handleConnect);
      socket.off("disconnect", handleDisconnect);
      socket.off("feedback:rejected", handleRejected);
    };
  }, []);

  const moodStats = useMemo(() => {
    const total = recentFeedback.length || 1;
    return feedbackItems.map((item) => {
      const count = recentFeedback.filter((value) => value === item.value).length;
      return {
        ...item,
        count,
        percent: Math.round((count / total) * 100)
      };
    });
  }, [recentFeedback]);

  async function sendFeedback(feedbackType: FeedbackValue) {
    if (!studentId || submitting) {
      return;
    }

    const payload = {
      sessionId: "demo_session_001",
      studentId,
      topicId,
      feedbackType,
      time: new Date().toISOString()
    };

    setSubmitting(true);

    try {
      const socket = getSocket();
      if (socket.connected) {
        socket.emit("feedback:send", payload);
      } else {
        const response = await fetch("/api/feedback", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(payload)
        });

        if (!response.ok) {
          const result = (await response.json()) as { message?: string };
          throw new Error(result.message ?? "反馈提交失败");
        }
      }

      setLastFeedback(feedbackType);
      setRecentFeedback((current) => [feedbackType, ...current].slice(0, 8));
      setStatusText("匿名反馈已提交，教师端会在几秒内刷新最新课堂状态。");
    } catch (error) {
      const message = error instanceof Error ? error.message : "发送失败，请稍后重试。";
      setStatusText(message);
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="grid gap-6 lg:grid-cols-[1.15fr_0.85fr]">
      <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
        <div className="flex items-start justify-between gap-4">
          <div>
            <div className="text-sm text-slate-500">当前主题</div>
            <div className="mt-1 text-xl font-semibold text-slate-900">方向导数与梯度</div>
            <div className="mt-2 text-sm text-slate-600">你提交的反馈会匿名同步到教师仪表盘，不会在全班公开显示。</div>
          </div>
          <div className={`rounded-full px-3 py-1 text-xs font-medium ${socketReady ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700"}`}>
            {socketReady ? "实时连接已建立" : "当前使用本地提交模式"}
          </div>
        </div>

        <div className="mt-6 grid gap-4 sm:grid-cols-2">
          {feedbackItems.map((item) => (
            <button
              key={item.value}
              type="button"
              onClick={() => sendFeedback(item.value)}
              disabled={!studentId || submitting}
              className={`rounded-[24px] ${item.color} px-5 py-5 text-left text-white shadow-sm transition hover:scale-[1.01] disabled:cursor-not-allowed disabled:opacity-60`}
            >
              <div className="text-lg font-semibold">{item.label}</div>
              <div className="mt-2 text-sm leading-6 text-white/90">{item.desc}</div>
            </button>
          ))}
        </div>

        <div className="mt-5 rounded-2xl bg-slate-50 px-4 py-3 text-sm text-slate-700">{statusText}</div>
      </div>

      <div className="grid gap-6">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">匿名状态</div>
          <div className="mt-2 text-sm text-slate-700">学生标识：{studentId || "正在生成匿名编号"}</div>
          <div className="mt-3 rounded-2xl bg-brand-50 px-4 py-3 text-sm text-brand-700">
            最近一次反馈：{getFeedbackLabel(lastFeedback)}
          </div>
        </div>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div>
            <div className="text-sm font-semibold text-slate-900">课堂氛围条</div>
            <div className="mt-1 text-xs text-slate-500">基于本端最近反馈做可视化展示，便于现场演示反馈类型差异。</div>
          </div>

          <div className="mt-4 flex h-3 overflow-hidden rounded-full bg-slate-100">
            {moodStats.map((item) => (
              <div key={item.value} className={item.color} style={{ width: `${item.percent}%` }} />
            ))}
          </div>

          <div className="mt-4 grid gap-3">
            {moodStats.map((item) => (
              <div
                key={item.value}
                className={`rounded-2xl px-4 py-3 text-sm ${item.lightColor} ${lastFeedback === item.value ? "ring-2 ring-offset-2 ring-offset-white ring-brand-200" : ""}`}
              >
                <div className="flex items-center justify-between gap-3">
                  <span className="font-semibold">{item.label}</span>
                  <span>{item.percent}%</span>
                </div>
                <div className="mt-1 text-xs opacity-80">最近 8 次本端反馈中出现 {item.count} 次</div>
              </div>
            ))}
          </div>
        </div>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm font-semibold text-slate-900">演示提示</div>
          <div className="mt-3 space-y-3 text-sm text-slate-700">
            <div className="rounded-2xl bg-slate-50 px-4 py-3">如果老师在讲梯度方向，可以连续点击“有点快”或“没听懂”，观察教师端的预警变化。</div>
            <div className="rounded-2xl bg-slate-50 px-4 py-3">如果老师举了一个更直观的例子，可以点击“这个例子很清楚”，帮助教师判断讲解方式是否有效。</div>
          </div>
        </div>
      </div>
    </div>
  );
}
'@

Write-Utf8NoBom "$root\components\student\student-ask-client.tsx" @'
"use client";

import { useState, type FormEvent } from "react";
import type { AskResult } from "@/types/api";
import { postJson } from "@/lib/api-client";

const sampleQuestions = [
  "梯度为什么表示函数增长最快的方向？",
  "方向导数和偏导数之间是什么关系？",
  "全微分的几何意义是什么？"
];

const initialResult: AskResult = {
  answer: "请输入问题后开始提问。",
  confidence: "medium",
  sourceNotes: [],
  safeNote: ""
};

function getConfidenceText(value: AskResult["confidence"]) {
  if (value === "high") return "高";
  if (value === "medium") return "中";
  return "低";
}

export function StudentAskClient() {
  const [question, setQuestion] = useState("梯度为什么表示函数增长最快的方向？");
  const [result, setResult] = useState<AskResult>(initialResult);
  const [loading, setLoading] = useState(false);
  const [statusText, setStatusText] = useState("可以直接输入关于全微分、方向导数或梯度的问题。");

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!question.trim()) {
      setStatusText("请先输入一个明确的问题。");
      return;
    }

    setLoading(true);
    setStatusText("正在读取课程资料并生成回答...");

    try {
      const data = await postJson<AskResult>("/api/ask", {
        topicId: "gradient",
        question: question.trim(),
        studentId: "demo_student"
      });
      setResult(data);
      setStatusText("回答已更新，可以继续追问更细的知识点。");
    } catch {
      setStatusText("当前回答生成失败，请稍后再试。");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="grid gap-6 lg:grid-cols-[1.02fr_0.98fr]">
      <form onSubmit={handleSubmit} className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
        <label className="text-sm font-medium text-slate-700">请输入问题</label>
        <div className="mt-3 flex flex-wrap gap-2">
          {sampleQuestions.map((item) => (
            <button
              key={item}
              type="button"
              onClick={() => setQuestion(item)}
              className="rounded-full bg-slate-100 px-3 py-2 text-xs font-medium text-slate-700 transition hover:bg-brand-50 hover:text-brand-700"
            >
              {item}
            </button>
          ))}
        </div>

        <textarea
          value={question}
          onChange={(event) => setQuestion(event.target.value)}
          className="mt-4 min-h-44 w-full rounded-[24px] border border-slate-200 px-4 py-3 text-sm leading-7 text-slate-800 outline-none focus:border-brand-500"
          placeholder="例如：为什么梯度方向与等高线正交？"
        />

        <div className="mt-4 rounded-2xl bg-slate-50 px-4 py-3 text-sm text-slate-700">{statusText}</div>
        <div className="mt-4 rounded-2xl bg-brand-50 px-4 py-3 text-sm text-brand-700">
          回答只会基于当前课程资料生成，并显示来源注记；如果依据不足，系统会自动使用更谨慎的表达。
        </div>

        <button
          type="submit"
          disabled={loading || !question.trim()}
          className="mt-4 rounded-full bg-brand-600 px-5 py-3 text-sm font-semibold text-white transition hover:bg-brand-700 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {loading ? "正在生成答案" : "开始提问"}
        </button>
      </form>

      <div className="grid gap-6">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between gap-3">
            <h2 className="text-lg font-semibold text-slate-900">回答结果</h2>
            <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-700">
              置信度：{getConfidenceText(result.confidence)}
            </span>
          </div>

          <div className="mt-4 whitespace-pre-wrap text-sm leading-7 text-slate-700">{result.answer}</div>

          {result.safeNote ? (
            <div className="mt-4 rounded-2xl bg-amber-50 px-4 py-3 text-sm text-amber-700">{result.safeNote}</div>
          ) : null}

          {!result.safeNote && result.sourceNotes.length > 0 ? (
            <div className="mt-4 rounded-2xl bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
              当前回答已基于课程资料生成，适合继续追问定义、公式关系或几何解释。
            </div>
          ) : null}
        </div>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">知识脚注</h2>
          <div className="mt-4 space-y-3 text-sm text-slate-700">
            {result.sourceNotes.length > 0 ? (
              result.sourceNotes.map((item) => (
                <div key={`${item.sourceName}-${item.page}-${item.title}`} className="rounded-2xl bg-slate-50 px-4 py-3 leading-6">
                  {item.sourceName} / {item.page} / {item.title}
                </div>
              ))
            ) : (
              <div className="rounded-2xl bg-slate-50 px-4 py-3 text-slate-500">当前还没有来源脚注信息。</div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
'@

Write-Utf8NoBom "$root\components\student\student-mindmap-client.tsx" @'
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
  const [statusText, setStatusText] = useState("当前展示的是最近一次生成的导图结果。");

  useEffect(() => {
    let active = true;

    async function loadLatest() {
      try {
        const latest = await getJson<MindMapData>("/api/mindmap");
        if (active) {
          setData(latest);
          setStatusText("已同步老师最新发布的课程导图。");
        }
      } catch {
        if (active) {
          setStatusText("当前仍在使用本地导图数据。");
        }
      }
    }

    void loadLatest();

    return () => {
      active = false;
    };
  }, []);

  return (
    <div className="grid gap-6 lg:grid-cols-[0.9fr_1.1fr]">
      <div className="grid gap-6">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">当前课程</div>
          <div className="mt-2 text-xl font-semibold text-slate-900">{data.courseName}</div>
          <div className="mt-4 rounded-2xl bg-slate-50 px-4 py-3 text-sm text-slate-700">
            最近更新时间：{formatTime(data.updatedAt)}
          </div>
          <div className="mt-4 rounded-2xl bg-brand-50 px-4 py-3 text-sm text-brand-700">{statusText}</div>
        </div>
        <PointSummary points={data.summaryPoints} />
      </div>
      <MindMapView data={data} />
    </div>
  );
}
'@

Write-Utf8NoBom "$root\components\teacher\alert-card.tsx" @'
import type { AlertInfo } from "@/types/classroom";

export function AlertCard({ alert }: { alert: AlertInfo | null }) {
  const levelText =
    alert?.alertLevel === "high" ? "高优先级预警" : alert?.alertLevel === "medium" ? "中优先级预警" : "课堂状态平稳";

  const boxClass = alert ? "bg-rose-50 text-rose-700" : "bg-emerald-50 text-emerald-700";
  const messageClass = alert ? "bg-amber-50 text-amber-700" : "bg-emerald-50 text-emerald-700";

  return (
    <div className="rounded-[28px] bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <div className="flex items-center justify-between gap-3">
        <h2 className="text-lg font-semibold text-slate-900">预警提示</h2>
        <span className={`rounded-full px-3 py-1 text-xs font-medium ${boxClass}`}>{levelText}</span>
      </div>
      <div className={`mt-4 rounded-2xl px-4 py-3 text-sm leading-6 ${messageClass}`}>
        {alert?.alertMessage ?? "当前课堂整体较平稳，暂未触发困惑率预警。"}
      </div>
      <div className="mt-3 text-sm leading-6 text-slate-500">
        {alert ? "建议优先查看右侧策略卡片，先稳住讲解节奏，再补一个更直观的解释或快速匿名检查。" : "可以继续观察学生反馈变化，必要时再切换讲解方式。"}
      </div>
    </div>
  );
}
'@

Write-Utf8NoBom "$root\components\teacher\strategy-list.tsx" @'
import type { StrategyItem } from "@/types/strategy";

export function StrategyList({ items }: { items: StrategyItem[] }) {
  const labelMap: Record<StrategyItem["type"], string> = {
    analogy: "类比解释",
    visual: "可视化动作",
    quick_check: "匿名检查"
  };

  return (
    <div className="rounded-[28px] bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <h2 className="text-lg font-semibold text-slate-900">教学策略建议</h2>
      <div className="mt-4 grid gap-3">
        {items.length > 0 ? (
          items.map((item) => (
            <div key={`${item.type}-${item.title}`} className="rounded-2xl bg-slate-50 px-4 py-4">
              <div className="flex items-center justify-between gap-3">
                <div className="text-sm font-semibold text-slate-900">{item.title}</div>
                <span className="rounded-full bg-brand-50 px-3 py-1 text-xs font-medium text-brand-700">
                  {labelMap[item.type]}
                </span>
              </div>
              <div className="mt-2 text-sm leading-6 text-slate-700">{item.text}</div>
            </div>
          ))
        ) : (
          <div className="rounded-2xl bg-slate-50 px-4 py-4 text-sm text-slate-500">当前还没有可展示的策略建议。</div>
        )}
      </div>
    </div>
  );
}
'@
