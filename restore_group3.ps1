$files = @{
  "D:\Projects\ai-classroom-assistant\components\teacher\alert-card.tsx" = @'
import type { AlertInfo } from "@/types/classroom";

export function AlertCard({ alert }: { alert: AlertInfo | null }) {
  const levelText =
    alert?.alertLevel === "high"
      ? "\u9ad8\u7ea7\u9884\u8b66"
      : alert?.alertLevel === "medium"
        ? "\u4e2d\u7ea7\u9884\u8b66"
        : "\u8bfe\u5802\u72b6\u6001\u5e73\u7a33";

  const badgeClass = alert ? "bg-rose-50 text-rose-700" : "bg-emerald-50 text-emerald-700";
  const messageClass = alert ? "bg-amber-50 text-amber-700" : "bg-emerald-50 text-emerald-700";

  return (
    <div className="rounded-[28px] bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <div className="flex items-center justify-between gap-3">
        <h2 className="text-lg font-semibold text-slate-900">\u9884\u8b66\u63d0\u793a</h2>
        <span className={`rounded-full px-3 py-1 text-xs font-medium ${badgeClass}`}>{levelText}</span>
      </div>
      <div className={`mt-4 rounded-2xl px-4 py-3 text-sm leading-6 ${messageClass}`}>
        {alert?.alertMessage ?? "\u5f53\u524d\u8bfe\u5802\u6574\u4f53\u72b6\u6001\u7a33\u5b9a\uff0c\u53ef\u4ee5\u6309\u7167\u539f\u5b9a\u8282\u594f\u7ee7\u7eed\u8bb2\u6388\u3002"}
      </div>
      <div className="mt-3 text-sm leading-6 text-slate-500">
        {alert
          ? "\u5efa\u8bae\u7ed3\u5408\u53cd\u9988\u5206\u5e03\u548c\u7b56\u7565\u5361\u7247\uff0c\u5148\u7528\u4e00\u4e2a\u76f4\u89c2\u4f8b\u5b50\u7a33\u4f4f\u5b66\u751f\u7406\u89e3\u3002"
          : "\u53ef\u4ee5\u7ee7\u7eed\u4fdd\u6301\u5f53\u524d\u6559\u5b66\u8282\u594f\uff0c\u5fc5\u8981\u65f6\u518d\u8865\u4e00\u4e2a\u5feb\u901f\u68c0\u6d4b\u3002"}
      </div>
    </div>
  );
}
'@
  "D:\Projects\ai-classroom-assistant\components\teacher\strategy-list.tsx" = @'
import type { StrategyItem } from "@/types/strategy";

export function StrategyList({ items }: { items: StrategyItem[] }) {
  const labelMap: Record<StrategyItem["type"], string> = {
    analogy: "\u7c7b\u6bd4\u8bf4\u660e",
    visual: "\u53ef\u89c6\u5316",
    quick_check: "\u5feb\u901f\u68c0\u67e5"
  };

  return (
    <div className="rounded-[28px] bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <h2 className="text-lg font-semibold text-slate-900">\u6559\u5b66\u7b56\u7565\u5efa\u8bae</h2>
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
          <div className="rounded-2xl bg-slate-50 px-4 py-4 text-sm text-slate-500">
            \u5f53\u524d\u8fd8\u6ca1\u6709\u65b0\u7684\u7b56\u7565\u5efa\u8bae\uff0c\u53ef\u4ee5\u5148\u6309\u539f\u8ba1\u5212\u7ee7\u7eed\u8bb2\u89e3\u3002
          </div>
        )}
      </div>
    </div>
  );
}
'@
  "D:\Projects\ai-classroom-assistant\components\teacher\teacher-dashboard-client.tsx" = @'
"use client";

import { useEffect, useMemo, useState } from "react";
import ReactECharts from "echarts-for-react";
import type { DashboardMetrics } from "@/types/classroom";
import type { MetricsResponse, StrategyApiResponse } from "@/types/api";
import type { StrategyItem } from "@/types/strategy";
import { AlertCard } from "@/components/teacher/alert-card";
import { StrategyList } from "@/components/teacher/strategy-list";
import { getSocket } from "@/lib/socket-client";
import { getJson, postJson } from "@/lib/api-client";

const defaultStrategies: StrategyItem[] = [
  {
    type: "analogy",
    title: "\u7ecf\u5178\u7c7b\u6bd4",
    text: "\u53ef\u4ee5\u628a\u68af\u5ea6\u60f3\u8c61\u6210\u5c71\u5761\u4e0a\u5347\u5f97\u6700\u5feb\u7684\u65b9\u5411\uff0c\u5e2e\u52a9\u5b66\u751f\u5148\u5efa\u7acb\u76f4\u89c2\u56fe\u50cf\u3002"
  },
  {
    type: "visual",
    title: "\u753b\u4e00\u5f20\u7b49\u9ad8\u7ebf\u56fe",
    text: "\u5728\u7b49\u9ad8\u7ebf\u56fe\u4e0a\u6807\u51fa\u68af\u5ea6\u65b9\u5411\uff0c\u5f3a\u8c03\u5b83\u603b\u662f\u6307\u5411\u589e\u957f\u6700\u5feb\u7684\u4f4d\u7f6e\u3002"
  },
  {
    type: "quick_check",
    title: "\u505a\u4e00\u6b21 1 \u9898\u5c0f\u68c0\u6d4b",
    text: "\u8ba9\u5b66\u751f\u7528\u4e00\u53e5\u8bdd\u56de\u7b54\u201c\u68af\u5ea6\u7684\u65b9\u5411\u4e0e\u6a21\u5206\u522b\u8868\u793a\u4ec0\u4e48\u201d\uff0c\u5feb\u901f\u786e\u8ba4\u7406\u89e3\u60c5\u51b5\u3002"
  }
];

export function TeacherDashboardClient({ initialMetrics }: { initialMetrics: DashboardMetrics }) {
  const [metrics, setMetrics] = useState(initialMetrics);
  const [strategies, setStrategies] = useState<StrategyItem[]>(defaultStrategies);
  const [topicId] = useState("gradient");
  const [statusText, setStatusText] = useState("\u6b63\u5728\u83b7\u53d6\u5f53\u524d\u8bfe\u5802\u72b6\u6001...");
  const [socketReady, setSocketReady] = useState(false);

  useEffect(() => {
    let active = true;

    async function loadMetrics() {
      try {
        const data = await getJson<MetricsResponse>("/api/metrics");
        if (active) {
          setMetrics(data);
          setStatusText("\u5f53\u524d\u5c55\u793a\u7684\u662f\u6700\u65b0\u8bfe\u5802\u53cd\u9988\u6570\u636e\u3002");
        }
      } catch {
        if (active) {
          setStatusText("\u5f53\u524d\u672a\u80fd\u5237\u65b0\uff0c\u6b63\u5728\u5c55\u793a\u6700\u8fd1\u4e00\u6b21\u6210\u529f\u83b7\u53d6\u7684\u6570\u636e\u3002");
        }
      }
    }

    void loadMetrics();

    const socket = getSocket();

    function handleConnect() {
      setSocketReady(true);
    }

    function handleDisconnect() {
      setSocketReady(false);
    }

    function handleMetrics(data: DashboardMetrics) {
      setMetrics(data);
      setStatusText("\u5df2\u540c\u6b65\u5230\u5b9e\u65f6\u53cd\u9988\u3002");
    }

    function handleStrategy(data: { strategies: StrategyItem[] }) {
      setStrategies(data.strategies);
    }

    setSocketReady(socket.connected);
    socket.on("connect", handleConnect);
    socket.on("disconnect", handleDisconnect);
    socket.on("metrics:update", handleMetrics);
    socket.on("strategy:update", handleStrategy);

    return () => {
      active = false;
      socket.off("connect", handleConnect);
      socket.off("disconnect", handleDisconnect);
      socket.off("metrics:update", handleMetrics);
      socket.off("strategy:update", handleStrategy);
    };
  }, []);

  useEffect(() => {
    let active = true;

    async function loadStrategy() {
      if (!metrics.alert) {
        setStrategies(defaultStrategies);
        return;
      }

      try {
        const data = await postJson<StrategyApiResponse>("/api/strategy", {
          topicId: metrics.alert.topicId,
          confusionRate: metrics.confusionRate
        });
        if (active) {
          setStrategies(data.strategies);
        }
      } catch {
        if (active) {
          setStrategies(defaultStrategies);
        }
      }
    }

    void loadStrategy();

    return () => {
      active = false;
    };
  }, [metrics.alert, metrics.confusionRate]);

  const summaryOption = useMemo(
    () => ({
      tooltip: { trigger: "axis" },
      grid: { left: 40, right: 20, top: 20, bottom: 35 },
      xAxis: {
        type: "category",
        data: ["\u542c\u61c2\u4e86", "\u8282\u594f\u592a\u5feb", "\u8fd8\u662f\u56f0\u60d1", "\u60f3\u770b\u4f8b\u5b50"],
        axisTick: { show: false }
      },
      yAxis: { type: "value", splitLine: { lineStyle: { color: "#e2e8f0" } } },
      series: [
        {
          data: [
            metrics.feedbackSummary.understand ?? 0,
            metrics.feedbackSummary.too_fast ?? 0,
            metrics.feedbackSummary.confused ?? 0,
            metrics.feedbackSummary.clear_example ?? 0
          ],
          type: "bar",
          itemStyle: { color: "#2563eb", borderRadius: [10, 10, 0, 0] }
        }
      ]
    }),
    [metrics]
  );

  const trendOption = useMemo(
    () => ({
      tooltip: { trigger: "axis" },
      grid: { left: 40, right: 20, top: 20, bottom: 35 },
      xAxis: {
        type: "category",
        data: metrics.trendPoints.map((item) => item.time),
        axisTick: { show: false }
      },
      yAxis: {
        type: "value",
        min: 0,
        max: 1,
        splitLine: { lineStyle: { color: "#e2e8f0" } }
      },
      series: [
        {
          data: metrics.trendPoints.map((item) => item.value),
          type: "line",
          smooth: true,
          areaStyle: { color: "rgba(37, 99, 235, 0.18)" },
          lineStyle: { color: "#2563eb", width: 3 },
          itemStyle: { color: "#2563eb" }
        }
      ]
    }),
    [metrics]
  );

  return (
    <div className="grid gap-6">
      <div className="rounded-[28px] bg-white p-4 shadow-sm ring-1 ring-slate-200">
        <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div className="text-sm text-slate-600">{statusText}</div>
          <div
            className={`inline-flex rounded-full px-3 py-1 text-xs font-medium ${
              socketReady ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700"
            }`}
          >
            {socketReady ? "\u5b9e\u65f6\u94fe\u8def\u5df2\u8fde\u63a5" : "\u5f53\u524d\u4f7f\u7528\u8f6e\u8be2\u5c55\u793a"}
          </div>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-4">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">\u5f53\u524d\u4e3b\u9898</div>
          <select
            value={topicId}
            disabled
            className="mt-2 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-800"
          >
            <option value="gradient">\u68af\u5ea6\u4e0e\u65b9\u5411\u5bfc\u6570</option>
          </select>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">\u5728\u7ebf\u5b66\u751f</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{metrics.onlineCount}</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">\u7d2f\u8ba1\u53cd\u9988</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{metrics.feedbackCount}</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">\u56f0\u60d1\u7387</div>
          <div className="mt-2 text-4xl font-bold text-rose-500">{Math.round(metrics.confusionRate * 100)}%</div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between gap-3">
            <h2 className="text-lg font-semibold text-slate-900">\u53cd\u9988\u5206\u5e03</h2>
            <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">\u5b9e\u65f6\u7edf\u8ba1</span>
          </div>
          <div className="mt-4 h-80">
            <ReactECharts option={summaryOption} style={{ height: "100%", width: "100%" }} />
          </div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between gap-3">
            <h2 className="text-lg font-semibold text-slate-900">\u56f0\u60d1\u8d8b\u52bf</h2>
            <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">
              {metrics.alert ? "\u9700\u8981\u5173\u6ce8" : "\u6574\u4f53\u5e73\u7a33"}
            </span>
          </div>
          <div className="mt-4 h-80">
            <ReactECharts option={trendOption} style={{ height: "100%", width: "100%" }} />
          </div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-[0.9fr_1.1fr]">
        <AlertCard alert={metrics.alert} />
        <StrategyList items={strategies} />
      </div>
    </div>
  );
}
'@
  "D:\Projects\ai-classroom-assistant\lib\threshold.ts" = @'
import type { AlertInfo, DashboardMetrics, FeedbackType, SessionState } from "@/types/classroom";

const feedbackKeys: FeedbackType[] = ["understand", "too_fast", "confused", "clear_example"];

function buildSummary(log: SessionState["feedbackLog"]) {
  return feedbackKeys.reduce<Record<string, number>>((acc, item) => {
    acc[item] = log.filter((entry) => entry.feedbackType === item).length;
    return acc;
  }, {});
}

function buildTrend(log: SessionState["feedbackLog"]) {
  return log.slice(-6).map((item) => ({
    time: item.time.slice(11, 16),
    value: item.feedbackType === "too_fast" || item.feedbackType === "confused" ? 1 : 0
  }));
}

function getConfusionRate(log: SessionState["feedbackLog"]): number {
  if (log.length === 0) {
    return 0;
  }

  const confusedCount = log.filter((item) => item.feedbackType === "too_fast" || item.feedbackType === "confused").length;
  return confusedCount / log.length;
}

function buildAlert(log: SessionState["feedbackLog"], topicId: string): AlertInfo | null {
  const now = Date.now();
  const currentWindow = log.filter((item) => now - new Date(item.time).getTime() <= 30000);
  const lastWindow = log.filter((item) => {
    const diff = now - new Date(item.time).getTime();
    return diff > 30000 && diff <= 60000;
  });
  const currentRate = getConfusionRate(currentWindow);
  const lastRate = getConfusionRate(lastWindow);

  if (currentWindow.length < 8 || currentRate < 0.3 || currentRate - lastRate < 0.1) {
    return null;
  }

  return {
    alertLevel: currentRate > 0.5 ? "high" : "medium",
    alertMessage: `\u5f53\u524d\u4e3b\u9898\u8fd1 30 \u79d2\u7ea6\u6709 ${Math.round(
      currentRate * 100
    )}% \u7684\u53cd\u9988\u663e\u793a\u5b66\u751f\u4ecd\u7136\u56f0\u60d1\uff0c\u5efa\u8bae\u8001\u5e08\u5148\u653e\u7f13\u8282\u594f\uff0c\u8865\u4e00\u4e2a\u76f4\u89c2\u4f8b\u5b50\u518d\u7ee7\u7eed\u3002`,
    topicId
  };
}

export function buildDashboardMetrics(session: SessionState): DashboardMetrics {
  const feedbackCount = session.feedbackLog.length;
  const confusedCount = session.feedbackLog.filter(
    (item) => item.feedbackType === "too_fast" || item.feedbackType === "confused"
  ).length;
  const confusionRate = feedbackCount === 0 ? 0 : confusedCount / feedbackCount;

  return {
    onlineCount: session.onlineStudents.length,
    feedbackCount,
    confusionRate,
    feedbackSummary: buildSummary(session.feedbackLog),
    trendPoints: buildTrend(session.feedbackLog),
    alert: buildAlert(session.feedbackLog, session.topicId)
  };
}
'@
  "D:\Projects\ai-classroom-assistant\lib\strategy-engine.ts" = @'
import type { StrategyItem, StrategyResponse, StrategyTopic } from "@/types/strategy";
import { runDeepSeekChat } from "@/lib/deepseek";
import { loadStrategyLibrary } from "@/lib/file-store";

function buildItems(topic: StrategyTopic): StrategyItem[] {
  return [
    {
      type: "analogy",
      title: "\u7ecf\u5178\u7c7b\u6bd4",
      text: topic.analogy[0] ?? "\u53ef\u4ee5\u5148\u7528\u4e00\u4e2a\u751f\u6d3b\u573a\u666f\u505a\u7c7b\u6bd4\uff0c\u5e2e\u5b66\u751f\u5feb\u901f\u627e\u5230\u6570\u5b66\u6982\u5ff5\u7684\u76f4\u89c2\u652f\u70b9\u3002"
    },
    {
      type: "visual",
      title: "\u53ef\u89c6\u5316\u52a8\u4f5c",
      text: topic.visual[0] ?? "\u5728\u9ed1\u677f\u6216\u6295\u5f71\u4e0a\u753b\u51fa\u5173\u952e\u56fe\u5f62\uff0c\u7528\u7ebf\u6761\u548c\u7bad\u5934\u8865\u8db3\u7a7a\u95f4\u5173\u7cfb\u3002"
    },
    {
      type: "quick_check",
      title: "\u5feb\u901f\u533f\u540d\u68c0\u6d4b",
      text: topic.quickCheck[0] ?? "\u7528\u4e00\u9053\u5c0f\u9898\u6216\u4e00\u4e2a\u5224\u65ad\u9898\uff0c\u5feb\u901f\u786e\u8ba4\u5b66\u751f\u662f\u5361\u5728\u5b9a\u4e49\u8fd8\u662f\u5361\u5728\u516c\u5f0f\u3002"
    }
  ];
}

export async function buildStrategyResponse(topicId: string, confusionRate: number): Promise<StrategyResponse> {
  const library = await loadStrategyLibrary();
  const topic = library.topics.find((item) => item.topicId === topicId) ?? library.topics[0];
  const localResponse: StrategyResponse = {
    alertLevel: confusionRate > 0.5 ? "high" : "medium",
    alertMessage: `\u5f53\u524d\u4e3b\u9898\u201c${topic.topicName}\u201d\u7684\u56f0\u60d1\u53cd\u9988\u6b63\u5728\u4e0a\u5347\uff0c\u5efa\u8bae\u8001\u5e08\u5148\u7a33\u4f4f\u8282\u594f\uff0c\u518d\u8865\u4e00\u4e2a\u76f4\u89c2\u89e3\u91ca\u548c\u5feb\u901f\u68c0\u6d4b\u3002`,
    strategies: buildItems(topic)
  };

  const aiText = await runDeepSeekChat(
    [
      {
        role: "system",
        content:
          "\u4f60\u662f\u8bfe\u5802\u6559\u5b66\u7b56\u7565\u52a9\u624b\u3002\u8bf7\u6839\u636e\u7ed9\u5b9a\u7684\u8bfe\u5802\u4e3b\u9898\u548c\u56f0\u60d1\u7387\uff0c\u8fd4\u56de JSON\uff0c\u5b57\u6bb5\u4e3a alertMessage \u548c strategies\u3002strategies \u957f\u5ea6\u56fa\u5b9a\u4e3a 3\uff0c\u6bcf\u4e2a\u5143\u7d20\u5305\u542b title \u548c text\uff0c\u5168\u90e8\u4f7f\u7528\u4e2d\u6587\uff0c\u8bed\u6c14\u81ea\u7136\uff0c\u4e0d\u8981\u8131\u79bb\u63d0\u4f9b\u7684\u672c\u5730\u7b56\u7565\u3002"
      },
      {
        role: "user",
        content: JSON.stringify({
          topicName: topic.topicName,
          confusionRate,
          keyPoints: topic.keyPoints,
          strategies: localResponse.strategies
        })
      }
    ],
    { jsonMode: true, maxTokens: 500 }
  );

  if (!aiText) {
    return localResponse;
  }

  try {
    const parsed = JSON.parse(aiText) as {
      alertMessage?: string;
      strategies?: Array<{ title?: string; text?: string }>;
    };

    return {
      alertLevel: localResponse.alertLevel,
      alertMessage: parsed.alertMessage || localResponse.alertMessage,
      strategies:
        parsed.strategies?.slice(0, 3).map((item, index) => ({
          type: localResponse.strategies[index]?.type ?? "analogy",
          title: item.title || localResponse.strategies[index]?.title || "\u6559\u5b66\u7b56\u7565",
          text: item.text || localResponse.strategies[index]?.text || "\u5efa\u8bae\u8001\u5e08\u5148\u7528\u4e00\u4e2a\u76f4\u89c2\u4f8b\u5b50\u7a33\u4f4f\u7406\u89e3\u3002"
        })) ?? localResponse.strategies
    };
  } catch {
    return localResponse;
  }
}
'@
  "D:\Projects\ai-classroom-assistant\lib\retrieval.ts" = @'
import type { AskResult } from "@/types/api";
import { runDeepSeekChat } from "@/lib/deepseek";
import { loadCourseMaterials } from "@/lib/file-store";

interface MatchChunk {
  chunkId: string;
  topicId: string;
  title: string;
  content: string;
  sourceName: string;
  page: string;
  keywords: string[];
  score: number;
}

function scoreChunk(question: string, topicId: string, chunk: Omit<MatchChunk, "score">): number {
  let score = 0;

  if (chunk.topicId === topicId) {
    score += 3;
  }

  for (const keyword of chunk.keywords) {
    if (question.includes(keyword)) {
      score += 2;
    }
  }

  if (question.includes(chunk.title)) {
    score += 2;
  }

  for (const part of chunk.content.split(/[，。；：]/)) {
    const text = part.trim();
    if (text.length >= 4 && question.includes(text.slice(0, 4))) {
      score += 1;
      break;
    }
  }

  return score;
}

function buildLocalAnswer(matches: MatchChunk[], confidence: AskResult["confidence"]): string {
  if (matches.length === 0) {
    return "\u5f53\u524d\u8d44\u6599\u4e2d\u6ca1\u6709\u627e\u5230\u8db3\u591f\u76f4\u63a5\u7684\u4f9d\u636e\uff0c\u5efa\u8bae\u5148\u56de\u5230\u8bfe\u5802\u8bb2\u4e49\u4e2d\u7684\u5b9a\u4e49\u3001\u56fe\u50cf\u548c\u5178\u578b\u4f8b\u9898\u90e8\u5206\u3002";
  }

  const mainMatch = matches[0];
  const supportMatch = matches[1];

  if (confidence === "high" && supportMatch) {
    return `\u6839\u636e\u5f53\u524d\u8bfe\u7a0b\u8d44\u6599\uff0c${mainMatch.content} \u540c\u65f6\uff0c${supportMatch.content}`;
  }

  return `\u6839\u636e\u5f53\u524d\u8bfe\u7a0b\u8d44\u6599\uff0c${mainMatch.content} \u5efa\u8bae\u4f60\u518d\u7ed3\u5408\u8bfe\u5802\u4e0a\u5173\u4e8e\u56fe\u50cf\u610f\u4e49\u548c\u516c\u5f0f\u63a8\u5bfc\u7684\u8bb2\u89e3\u4e00\u8d77\u7406\u89e3\u3002`;
}

async function buildAiAnswer(question: string, matches: MatchChunk[]): Promise<string | null> {
  if (matches.length === 0) {
    return null;
  }

  const sourceText = matches
    .map((item, index) => `\u8d44\u6599${index + 1}\uff1a${item.title}\uff08${item.sourceName} ${item.page}\uff09\n${item.content}`)
    .join("\n\n");

  return runDeepSeekChat(
    [
      {
        role: "system",
        content:
          "\u4f60\u662f\u9ad8\u7b49\u6570\u5b66\u8bfe\u5802\u95ee\u7b54\u52a9\u624b\u3002\u53ea\u80fd\u6839\u636e\u63d0\u4f9b\u7684\u8bfe\u7a0b\u8d44\u6599\u56de\u7b54\uff0c\u4e0d\u8981\u7f16\u9020\u8d44\u6599\u4e4b\u5916\u7684\u7ed3\u8bba\u3002\u56de\u7b54\u4f7f\u7528\u4e2d\u6587\uff0c\u9002\u5408\u8bfe\u5802\u8bb2\u89e3\uff0c\u957f\u5ea6\u63a7\u5236\u5728 2 \u5230 4 \u53e5\u3002"
      },
      {
        role: "user",
        content: `\u5b66\u751f\u63d0\u95ee\uff1a${question}\n\n\u8bfe\u7a0b\u8d44\u6599\u5982\u4e0b\uff1a\n${sourceText}`
      }
    ],
    { maxTokens: 500 }
  );
}

export async function buildAskResult(topicId: string, question: string): Promise<AskResult> {
  const materials = await loadCourseMaterials();
  const matches = materials.chunks
    .map((chunk) => ({ ...chunk, score: scoreChunk(question, topicId, chunk) }))
    .filter((chunk) => chunk.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, 3) as MatchChunk[];

  const confidence = matches.length >= 2 ? "high" : matches.length === 1 ? "medium" : "low";
  const sourceNotes = matches.map((item) => ({
    sourceName: item.sourceName,
    page: item.page,
    title: item.title
  }));
  const aiAnswer = await buildAiAnswer(question, matches);

  return {
    answer: aiAnswer || buildLocalAnswer(matches, confidence),
    confidence,
    sourceNotes,
    safeNote:
      confidence === "low"
        ? "\u6839\u636e\u5f53\u524d\u8bfe\u7a0b\u8d44\u6599\uff0c\u8fd9\u4e00\u90e8\u5206\u53ef\u80fd\u8fd8\u9700\u8981\u7ed3\u5408\u8001\u5e08\u8bfe\u5802\u8bb2\u89e3\u8fdb\u4e00\u6b65\u786e\u8ba4\u3002"
        : ""
  };
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
