$root = "D:\Projects\ai-classroom-assistant"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom {
  param([string]$Path,[string]$Content)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom "$root\components\student\student-feedback-client.tsx" @'
"use client";

import { useEffect, useMemo, useState } from "react";
import { v4 as uuidv4 } from "uuid";
import { getSocket } from "@/lib/socket-client";

const feedbackItems = [
  { value: "understand", label: "\u542c\u61c2\u4e86", desc: "\u8fd9\u90e8\u5206\u8282\u594f\u5408\u9002\uff0c\u53ef\u4ee5\u7ee7\u7eed\u5f80\u4e0b\u8bb2\u3002", color: "bg-emerald-500", lightColor: "bg-emerald-50 text-emerald-700" },
  { value: "too_fast", label: "\u6709\u70b9\u5feb", desc: "\u80fd\u8ddf\u4e0a\u5927\u610f\uff0c\u4f46\u63a8\u5bfc\u901f\u5ea6\u53ef\u4ee5\u518d\u653e\u6162\u4e00\u4e9b\u3002", color: "bg-amber-500", lightColor: "bg-amber-50 text-amber-700" },
  { value: "confused", label: "\u6ca1\u542c\u61c2", desc: "\u5f53\u524d\u77e5\u8bc6\u70b9\u8fd8\u9700\u8981\u8001\u5e08\u91cd\u65b0\u89e3\u91ca\u6216\u6362\u4e2a\u89d2\u5ea6\u8bb2\u3002", color: "bg-rose-500", lightColor: "bg-rose-50 text-rose-700" },
  { value: "clear_example", label: "\u8fd9\u4e2a\u4f8b\u5b50\u5f88\u6e05\u695a", desc: "\u4f8b\u5b50\u6709\u5e2e\u52a9\uff0c\u5e0c\u671b\u7ee7\u7eed\u7528\u8fd9\u79cd\u65b9\u5f0f\u8bb2\u89e3\u3002", color: "bg-sky-500", lightColor: "bg-sky-50 text-sky-700" }
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
  return feedbackItems.find((item) => item.value === value)?.label ?? "\u6682\u672a\u63d0\u4ea4";
}

export function StudentFeedbackClient() {
  const [statusText, setStatusText] = useState("\u7b49\u5f85\u53d1\u9001\u8bfe\u5802\u53cd\u9988\u3002");
  const [topicId] = useState("gradient");
  const [studentId, setStudentId] = useState("");
  const [socketReady, setSocketReady] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [lastFeedback, setLastFeedback] = useState<FeedbackValue | null>(null);
  const [recentFeedback, setRecentFeedback] = useState<FeedbackValue[]>(["understand", "clear_example", "too_fast", "understand"]);

  useEffect(() => {
    setStudentId(getStudentId());
    const socket = getSocket();

    function handleConnect() {
      setSocketReady(true);
      setStatusText("\u5df2\u8fde\u63a5\u5b9e\u65f6\u53cd\u9988\u901a\u9053\uff0c\u53ef\u4ee5\u76f4\u63a5\u63d0\u4ea4\u533f\u540d\u53cd\u9988\u3002");
    }

    function handleDisconnect() {
      setSocketReady(false);
      setStatusText("\u5b9e\u65f6\u901a\u9053\u6682\u65f6\u65ad\u5f00\uff0c\u5f53\u524d\u4f1a\u4f7f\u7528\u672c\u5730\u63d0\u4ea4\u65b9\u5f0f\u3002");
    }

    function handleRejected(data: { message?: string }) {
      setSubmitting(false);
      setStatusText(data.message ?? "\u53cd\u9988\u53d1\u9001\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u518d\u8bd5\u3002");
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
      return { ...item, count, percent: Math.round((count / total) * 100) };
    });
  }, [recentFeedback]);

  async function sendFeedback(feedbackType: FeedbackValue) {
    if (!studentId || submitting) {
      return;
    }

    const payload = { sessionId: "demo_session_001", studentId, topicId, feedbackType, time: new Date().toISOString() };
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
          throw new Error(result.message ?? "\u53cd\u9988\u63d0\u4ea4\u5931\u8d25");
        }
      }

      setLastFeedback(feedbackType);
      setRecentFeedback((current) => [feedbackType, ...current].slice(0, 8));
      setStatusText("\u533f\u540d\u53cd\u9988\u5df2\u63d0\u4ea4\uff0c\u6559\u5e08\u7aef\u4f1a\u5728\u51e0\u79d2\u5185\u5237\u65b0\u6700\u65b0\u8bfe\u5802\u72b6\u6001\u3002");
    } catch (error) {
      const message = error instanceof Error ? error.message : "\u53d1\u9001\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5\u3002";
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
            <div className="text-sm text-slate-500">{"\u5f53\u524d\u4e3b\u9898"}</div>
            <div className="mt-1 text-xl font-semibold text-slate-900">{"\u65b9\u5411\u5bfc\u6570\u4e0e\u68af\u5ea6"}</div>
            <div className="mt-2 text-sm text-slate-600">{"\u4f60\u63d0\u4ea4\u7684\u53cd\u9988\u4f1a\u533f\u540d\u540c\u6b65\u5230\u6559\u5e08\u4eea\u8868\u76d8\uff0c\u4e0d\u4f1a\u5728\u5168\u73ed\u516c\u5f00\u663e\u793a\u3002"}</div>
          </div>
          <div className={`rounded-full px-3 py-1 text-xs font-medium ${socketReady ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700"}`}>
            {socketReady ? "\u5b9e\u65f6\u8fde\u63a5\u5df2\u5efa\u7acb" : "\u5f53\u524d\u4f7f\u7528\u672c\u5730\u63d0\u4ea4\u6a21\u5f0f"}
          </div>
        </div>

        <div className="mt-6 grid gap-4 sm:grid-cols-2">
          {feedbackItems.map((item) => (
            <button key={item.value} type="button" onClick={() => sendFeedback(item.value)} disabled={!studentId || submitting} className={`rounded-[24px] ${item.color} px-5 py-5 text-left text-white shadow-sm transition hover:scale-[1.01] disabled:cursor-not-allowed disabled:opacity-60`}>
              <div className="text-lg font-semibold">{item.label}</div>
              <div className="mt-2 text-sm leading-6 text-white/90">{item.desc}</div>
            </button>
          ))}
        </div>

        <div className="mt-5 rounded-2xl bg-slate-50 px-4 py-3 text-sm text-slate-700">{statusText}</div>
      </div>

      <div className="grid gap-6">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u533f\u540d\u72b6\u6001"}</div>
          <div className="mt-2 text-sm text-slate-700">{`\u5b66\u751f\u6807\u8bc6\uff1a${studentId || "\u6b63\u5728\u751f\u6210\u533f\u540d\u7f16\u53f7"}`}</div>
          <div className="mt-3 rounded-2xl bg-brand-50 px-4 py-3 text-sm text-brand-700">{`\u6700\u8fd1\u4e00\u6b21\u53cd\u9988\uff1a${getFeedbackLabel(lastFeedback)}`}</div>
        </div>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm font-semibold text-slate-900">{"\u8bfe\u5802\u6c1b\u56f4\u6761"}</div>
          <div className="mt-4 flex h-3 overflow-hidden rounded-full bg-slate-100">
            {moodStats.map((item) => (
              <div key={item.value} className={item.color} style={{ width: `${item.percent}%` }} />
            ))}
          </div>
          <div className="mt-4 grid gap-3">
            {moodStats.map((item) => (
              <div key={item.value} className={`rounded-2xl px-4 py-3 text-sm ${item.lightColor}`}>
                <div className="flex items-center justify-between gap-3">
                  <span className="font-semibold">{item.label}</span>
                  <span>{item.percent}%</span>
                </div>
                <div className="mt-1 text-xs opacity-80">{`\u6700\u8fd1 8 \u6b21\u672c\u7aef\u53cd\u9988\u4e2d\u51fa\u73b0 ${item.count} \u6b21`}</div>
              </div>
            ))}
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
  "\u68af\u5ea6\u4e3a\u4ec0\u4e48\u8868\u793a\u51fd\u6570\u589e\u957f\u6700\u5feb\u7684\u65b9\u5411\uff1f",
  "\u65b9\u5411\u5bfc\u6570\u548c\u504f\u5bfc\u6570\u4e4b\u95f4\u662f\u4ec0\u4e48\u5173\u7cfb\uff1f",
  "\u5168\u5fae\u5206\u7684\u51e0\u4f55\u610f\u4e49\u662f\u4ec0\u4e48\uff1f"
];

const initialResult: AskResult = {
  answer: "\u8bf7\u8f93\u5165\u95ee\u9898\u540e\u5f00\u59cb\u63d0\u95ee\u3002",
  confidence: "medium",
  sourceNotes: [],
  safeNote: ""
};

function getConfidenceText(value: AskResult["confidence"]) {
  if (value === "high") return "\u9ad8";
  if (value === "medium") return "\u4e2d";
  return "\u4f4e";
}

export function StudentAskClient() {
  const [question, setQuestion] = useState(sampleQuestions[0]);
  const [result, setResult] = useState<AskResult>(initialResult);
  const [loading, setLoading] = useState(false);
  const [statusText, setStatusText] = useState("\u53ef\u4ee5\u76f4\u63a5\u8f93\u5165\u5173\u4e8e\u5168\u5fae\u5206\u3001\u65b9\u5411\u5bfc\u6570\u6216\u68af\u5ea6\u7684\u95ee\u9898\u3002");

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!question.trim()) {
      setStatusText("\u8bf7\u5148\u8f93\u5165\u4e00\u4e2a\u660e\u786e\u7684\u95ee\u9898\u3002");
      return;
    }

    setLoading(true);
    setStatusText("\u6b63\u5728\u8bfb\u53d6\u8bfe\u7a0b\u8d44\u6599\u5e76\u751f\u6210\u56de\u7b54...");

    try {
      const data = await postJson<AskResult>("/api/ask", {
        topicId: "gradient",
        question: question.trim(),
        studentId: "demo_student"
      });
      setResult(data);
      setStatusText("\u56de\u7b54\u5df2\u66f4\u65b0\uff0c\u53ef\u4ee5\u7ee7\u7eed\u8ffd\u95ee\u66f4\u7ec6\u7684\u77e5\u8bc6\u70b9\u3002");
    } catch {
      setStatusText("\u5f53\u524d\u56de\u7b54\u751f\u6210\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u518d\u8bd5\u3002");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="grid gap-6 lg:grid-cols-[1.02fr_0.98fr]">
      <form onSubmit={handleSubmit} className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
        <label className="text-sm font-medium text-slate-700">{"\u8bf7\u8f93\u5165\u95ee\u9898"}</label>
        <div className="mt-3 flex flex-wrap gap-2">
          {sampleQuestions.map((item) => (
            <button key={item} type="button" onClick={() => setQuestion(item)} className="rounded-full bg-slate-100 px-3 py-2 text-xs font-medium text-slate-700 transition hover:bg-brand-50 hover:text-brand-700">
              {item}
            </button>
          ))}
        </div>

        <textarea value={question} onChange={(event) => setQuestion(event.target.value)} className="mt-4 min-h-44 w-full rounded-[24px] border border-slate-200 px-4 py-3 text-sm leading-7 text-slate-800 outline-none focus:border-brand-500" />
        <div className="mt-4 rounded-2xl bg-slate-50 px-4 py-3 text-sm text-slate-700">{statusText}</div>

        <button type="submit" disabled={loading || !question.trim()} className="mt-4 rounded-full bg-brand-600 px-5 py-3 text-sm font-semibold text-white transition hover:bg-brand-700 disabled:cursor-not-allowed disabled:opacity-60">
          {loading ? "\u6b63\u5728\u751f\u6210\u7b54\u6848" : "\u5f00\u59cb\u63d0\u95ee"}
        </button>
      </form>

      <div className="grid gap-6">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between gap-3">
            <h2 className="text-lg font-semibold text-slate-900">{"\u56de\u7b54\u7ed3\u679c"}</h2>
            <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-700">{`\u7f6e\u4fe1\u5ea6\uff1a${getConfidenceText(result.confidence)}`}</span>
          </div>
          <div className="mt-4 whitespace-pre-wrap text-sm leading-7 text-slate-700">{result.answer}</div>
          {result.safeNote ? <div className="mt-4 rounded-2xl bg-amber-50 px-4 py-3 text-sm text-amber-700">{result.safeNote}</div> : null}
        </div>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">{"\u77e5\u8bc6\u811a\u6ce8"}</h2>
          <div className="mt-4 space-y-3 text-sm text-slate-700">
            {result.sourceNotes.length > 0 ? (
              result.sourceNotes.map((item) => (
                <div key={`${item.sourceName}-${item.page}-${item.title}`} className="rounded-2xl bg-slate-50 px-4 py-3 leading-6">
                  {`${item.sourceName} / ${item.page} / ${item.title}`}
                </div>
              ))
            ) : (
              <div className="rounded-2xl bg-slate-50 px-4 py-3 text-slate-500">{"\u5f53\u524d\u8fd8\u6ca1\u6709\u6765\u6e90\u811a\u6ce8\u4fe1\u606f\u3002"}</div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
'@
