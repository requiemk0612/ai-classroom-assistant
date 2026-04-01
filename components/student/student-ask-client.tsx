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

function getConfidenceTone(value: AskResult["confidence"]) {
  if (value === "high") return "bg-emerald-50 text-emerald-700";
  if (value === "medium") return "bg-amber-50 text-amber-700";
  return "bg-rose-50 text-rose-700";
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
          placeholder={"\u4f8b\u5982\uff1a\u4e3a\u4ec0\u4e48\u68af\u5ea6\u65b9\u5411\u4e0e\u7b49\u9ad8\u7ebf\u6b63\u4ea4\uff1f"}
        />

        <div className="mt-4 rounded-2xl bg-slate-50 px-4 py-3 text-sm text-slate-700">{statusText}</div>
        <div className="mt-4 rounded-2xl bg-brand-50 px-4 py-3 text-sm leading-6 text-brand-700">
          {"\u7b54\u6848\u53ea\u4f1a\u57fa\u4e8e\u5f53\u524d\u8bfe\u7a0b\u8d44\u6599\u751f\u6210\uff0c\u5e76\u9644\u4e0a\u6765\u6e90\u811a\u6ce8\uff1b\u5982\u679c\u4f9d\u636e\u4e0d\u8db3\uff0c\u7cfb\u7edf\u4f1a\u81ea\u52a8\u4f7f\u7528\u66f4\u8c28\u614e\u7684\u8bed\u6c14\u3002"}
        </div>
        <div className="mt-3 flex flex-wrap gap-2 text-xs text-slate-500">
          <span className="rounded-full bg-slate-100 px-3 py-1">{`\u5f53\u524d\u4e13\u6ce8\uff1a\u68af\u5ea6\u4e0e\u65b9\u5411\u5bfc\u6570`}</span>
          <span className="rounded-full bg-slate-100 px-3 py-1">{`\u8fd4\u56de\u5185\u5bb9\u5305\u542b\u6765\u6e90\u811a\u6ce8\u4e0e\u7f6e\u4fe1\u5ea6`}</span>
        </div>

        <button
          type="submit"
          disabled={loading || !question.trim()}
          className="mt-4 rounded-full bg-brand-600 px-5 py-3 text-sm font-semibold text-white transition hover:bg-brand-700 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {loading ? "\u6b63\u5728\u751f\u6210\u7b54\u6848" : "\u5f00\u59cb\u63d0\u95ee"}
        </button>
      </form>

      <div className="grid gap-6">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between gap-3">
            <h2 className="text-lg font-semibold text-slate-900">{"\u56de\u7b54\u7ed3\u679c"}</h2>
            <span className={`rounded-full px-3 py-1 text-xs font-medium ${getConfidenceTone(result.confidence)}`}>
              {`\u7f6e\u4fe1\u5ea6\uff1a${getConfidenceText(result.confidence)}`}
            </span>
          </div>
          <div className="mt-4 whitespace-pre-wrap text-sm leading-7 text-slate-700">{result.answer}</div>
          {result.safeNote ? (
            <div className="mt-4 rounded-2xl bg-amber-50 px-4 py-3 text-sm text-amber-700">{result.safeNote}</div>
          ) : (
            <div className="mt-4 rounded-2xl bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
              {"\u5f53\u524d\u56de\u7b54\u53ef\u4ee5\u4f5c\u4e3a\u8bfe\u5802\u4e0a\u7684\u5feb\u901f\u89e3\u91ca\uff0c\u5982\u9700\u8981\u66f4\u7ec6\u7684\u63a8\u5bfc\uff0c\u53ef\u4ee5\u7ee7\u7eed\u8ffd\u95ee\u3002"}
            </div>
          )}
        </div>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between gap-3">
            <h2 className="text-lg font-semibold text-slate-900">{"\u77e5\u8bc6\u811a\u6ce8"}</h2>
            <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">
              {`\u5171 ${result.sourceNotes.length} \u6761\u6765\u6e90`}
            </span>
          </div>
          <div className="mt-3 rounded-2xl border border-dashed border-slate-200 px-4 py-3 text-xs leading-6 text-slate-500">
            {"\u6f14\u793a\u65f6\u53ef\u5148\u63d0\u9884\u8bbe\u95ee\u9898\uff0c\u518d\u8ffd\u95ee\u201c\u4e3a\u4ec0\u4e48\u201d\u6216\u201c\u80fd\u4e0d\u80fd\u518d\u76f4\u89c2\u4e00\u70b9\u201d\uff0c\u66f4\u5bb9\u6613\u5c55\u793a\u95ee\u7b54\u7cfb\u7edf\u7684\u7a33\u5065\u6027\u3002"}
          </div>
          <div className="mt-4 space-y-3 text-sm text-slate-700">
            {result.sourceNotes.length > 0 ? (
              result.sourceNotes.map((item) => (
                <div key={`${item.sourceName}-${item.page}-${item.title}`} className="rounded-2xl bg-slate-50 px-4 py-3 leading-6">
                  {`${item.sourceName} / ${item.page} / ${item.title}`}
                </div>
              ))
            ) : (
              <div className="rounded-2xl bg-slate-50 px-4 py-3 text-slate-500">
                {"\u5f53\u524d\u8fd8\u6ca1\u6709\u6765\u6e90\u811a\u6ce8\u4fe1\u606f\u3002"}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
