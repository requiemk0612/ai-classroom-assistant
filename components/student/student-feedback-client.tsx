"use client";

import { useEffect, useMemo, useState } from "react";
import { v4 as uuidv4 } from "uuid";
import { getSocket } from "@/lib/socket-client";

const sessionId = "demo_session_001";

const feedbackItems = [
  { value: "understand", label: "\u542c\u61c2\u4e86", desc: "\u8fd9\u90e8\u5206\u8282\u594f\u5408\u9002\uff0c\u53ef\u4ee5\u7ee7\u7eed\u5f80\u4e0b\u8bb2\u3002", color: "bg-emerald-500", lightColor: "bg-emerald-50 text-emerald-700" },
  { value: "too_fast", label: "\u6709\u70b9\u5feb", desc: "\u80fd\u8ddf\u4e0a\u5927\u610f\uff0c\u4f46\u63a8\u5bfc\u901f\u5ea6\u53ef\u4ee5\u518d\u653e\u6162\u4e00\u4e9b\u3002", color: "bg-amber-500", lightColor: "bg-amber-50 text-amber-700" },
  { value: "confused", label: "\u6ca1\u542c\u61c2", desc: "\u5f53\u524d\u77e5\u8bc6\u70b9\u8fd8\u9700\u8981\u8001\u5e08\u91cd\u65b0\u89e3\u91ca\u6216\u6362\u4e2a\u89d2\u5ea6\u8bb2\u3002", color: "bg-rose-500", lightColor: "bg-rose-50 text-rose-700" },
  { value: "clear_example", label: "\u4f8b\u5b50\u5f88\u6e05\u695a", desc: "\u8fd9\u4e2a\u4f8b\u5b50\u6709\u5e2e\u52a9\uff0c\u53ef\u4ee5\u7ee7\u7eed\u8fd9\u79cd\u8bb2\u89e3\u65b9\u5f0f\u3002", color: "bg-sky-500", lightColor: "bg-sky-50 text-sky-700" }
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

function getFeedbackSuggestion(value: FeedbackValue | null) {
  if (value === "confused") return "\u7cfb\u7edf\u4f1a\u66f4\u503e\u5411\u89e6\u53d1\u91cd\u8bb2\u6216\u56fe\u5f62\u5316\u7b56\u7565\u5efa\u8bae\u3002";
  if (value === "too_fast") return "\u7cfb\u7edf\u4f1a\u66f4\u5173\u6ce8\u201c\u8282\u594f\u8fc7\u5feb\u201d\u4fe1\u53f7\uff0c\u5f15\u5bfc\u6559\u5e08\u7a33\u4f4f\u8bb2\u89e3\u901f\u5ea6\u3002";
  if (value === "clear_example") return "\u8fd9\u79cd\u53cd\u9988\u9002\u5408\u5728\u6f14\u793a\u65f6\u5c55\u793a\u201c\u4f8b\u5b50\u6709\u6548\u201d\u7684\u6b63\u5411\u95ed\u73af\u3002";
  if (value === "understand") return "\u8fd9\u6761\u4fe1\u53f7\u4f1a\u5e2e\u52a9\u6559\u5e08\u5224\u65ad\u5f53\u524d\u8282\u594f\u53ef\u4ee5\u7ee7\u7eed\u63a8\u8fdb\u3002";
  return "\u63d0\u4ea4\u4e00\u6b21\u53cd\u9988\u540e\uff0c\u53f3\u4fa7\u4f1a\u66f4\u9002\u5408\u5c55\u793a\u8fd9\u6b21\u53cd\u9988\u7684\u6f14\u793a\u610f\u4e49\u3002";
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
      setStatusText("\u5b9e\u65f6\u901a\u9053\u6682\u65f6\u65ad\u5f00\uff0c\u5f53\u524d\u4f1a\u4f7f\u7528 API \u63d0\u4ea4\u65b9\u5f0f\u3002");
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

    const payload = { sessionId, studentId, topicId, feedbackType, time: new Date().toISOString() };
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
    <div className="grid gap-6 lg:grid-cols-[1.12fr_0.88fr]">
      <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
        <div className="flex items-start justify-between gap-4">
          <div>
            <div className="text-sm text-slate-500">{"\u5f53\u524d\u4e3b\u9898"}</div>
            <div className="mt-1 text-xl font-semibold text-slate-900">{"\u65b9\u5411\u5bfc\u6570\u4e0e\u68af\u5ea6"}</div>
            <div className="mt-2 text-sm text-slate-600">
              {"\u4f60\u63d0\u4ea4\u7684\u53cd\u9988\u4f1a\u533f\u540d\u540c\u6b65\u5230\u6559\u5e08\u4eea\u8868\u76d8\uff0c\u4e0d\u4f1a\u5728\u5168\u73ed\u516c\u5f00\u663e\u793a\u3002"}
            </div>
          </div>
          <div className={`rounded-full px-3 py-1 text-xs font-medium ${socketReady ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700"}`}>
            {socketReady ? "\u5b9e\u65f6\u8fde\u63a5\u5df2\u5efa\u7acb" : "API \u63d0\u4ea4\u4fdd\u5e95\u4e2d"}
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
        <div className="mt-4 rounded-2xl bg-brand-50 px-4 py-3 text-sm leading-6 text-brand-700">
          {"\u6f14\u793a\u63d0\u793a\uff1a\u8fde\u7eed\u70b9\u51fb\u201c\u6709\u70b9\u5feb\u201d\u6216\u201c\u6ca1\u542c\u61c2\u201d\uff0c\u6559\u5e08\u7aef\u7684\u56f0\u60d1\u7387\u3001\u9884\u8b66\u5361\u548c\u7b56\u7565\u533a\u4f1a\u8ddf\u7740\u53d8\u5316\u3002"}
        </div>
      </div>

      <div className="grid gap-6">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u533f\u540d\u72b6\u6001"}</div>
          <div className="mt-2 text-sm text-slate-700">{`\u5b66\u751f\u6807\u8bc6\uff1a${studentId || "\u6b63\u5728\u751f\u6210\u533f\u540d\u7f16\u53f7"}`}</div>
          <div className="mt-3 rounded-2xl bg-brand-50 px-4 py-3 text-sm text-brand-700">{`\u6700\u8fd1\u4e00\u6b21\u53cd\u9988\uff1a${getFeedbackLabel(lastFeedback)}`}</div>
          <div className="mt-3 rounded-2xl border border-dashed border-slate-200 px-4 py-3 text-xs leading-6 text-slate-500">
            {getFeedbackSuggestion(lastFeedback)}
          </div>
          <div className="mt-3 text-xs leading-6 text-slate-500">
            {"\u8f7b\u91cf anti-fake \u89c4\u5219\uff1a\u540c\u4e00\u4eba 3 \u79d2\u5185\u53ea\u80fd\u63d0\u4ea4\u4e00\u6b21\uff0c\u8fd1\u65f6\u95f4\u91cd\u590d\u53cd\u9988\u53ea\u4fdd\u7559\u6700\u65b0\u4e00\u6761\u3002"}
          </div>
        </div>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between gap-3">
            <div>
              <div className="text-sm font-semibold text-slate-900">{"\u8fd1\u671f\u8bfe\u5802\u6c1b\u56f4\u6761"}</div>
              <div className="mt-1 text-xs text-slate-500">{"\u57fa\u4e8e\u6700\u8fd1 8 \u6b21\u53cd\u9988\u505a\u53ef\u89c6\u5316\u6bd4\u4f8b\u5c55\u793a"}</div>
            </div>
            <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">{"\u672c\u7aef\u6f14\u793a\u89c6\u56fe"}</span>
          </div>

          <div className="mt-4 flex h-4 overflow-hidden rounded-full bg-slate-100">
            {moodStats.map((item) => (
              <div key={item.value} className={item.color} style={{ width: `${item.percent}%` }} />
            ))}
          </div>

          <div className="mt-4 grid gap-3">
            {moodStats.map((item) => (
              <div
                key={item.value}
                className={`rounded-2xl border border-transparent px-4 py-3 text-sm ${item.lightColor} ${
                  lastFeedback === item.value ? "ring-2 ring-brand-100" : ""
                }`}
              >
                <div className="flex items-center justify-between gap-3">
                  <span className="font-semibold">{item.label}</span>
                  <span>{item.percent}%</span>
                </div>
                <div className="mt-2 h-2 overflow-hidden rounded-full bg-white/70">
                  <div className={item.color} style={{ width: `${item.percent}%`, height: "100%" }} />
                </div>
                <div className="mt-2 text-xs opacity-80">{`\u6700\u8fd1 8 \u6b21\u672c\u7aef\u53cd\u9988\u4e2d\u51fa\u73b0 ${item.count} \u6b21`}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
