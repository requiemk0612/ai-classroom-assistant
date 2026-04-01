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

const sessionId = "demo_session_001";

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

function getTrendUp(points: DashboardMetrics["trendPoints"]) {
  if (points.length < 2) {
    return false;
  }

  const last = points[points.length - 1]?.value ?? 0;
  const prev = points[points.length - 2]?.value ?? 0;
  return last > prev;
}

export function TeacherDashboardClient({ initialMetrics }: { initialMetrics: DashboardMetrics }) {
  const [metrics, setMetrics] = useState(initialMetrics);
  const [strategies, setStrategies] = useState<StrategyItem[]>(defaultStrategies);
  const [topicId] = useState("gradient");
  const [statusText, setStatusText] = useState("\u6b63\u5728\u83b7\u53d6\u5f53\u524d\u8bfe\u5802\u72b6\u6001...");
  const [socketReady, setSocketReady] = useState(false);

  useEffect(() => {
    let active = true;
    let timer: ReturnType<typeof setInterval> | null = null;

    async function loadMetrics() {
      try {
        const data = await getJson<MetricsResponse>(`/api/metrics?sessionId=${sessionId}`);
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
    timer = setInterval(() => {
      void loadMetrics();
    }, 4000);

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
      if (timer) {
        clearInterval(timer);
      }
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
          confusionRate: metrics.confusionRate,
          trendUp: metrics.rateDelta > 0,
          feedbackSummary: metrics.feedbackSummary
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
  }, [metrics.alert, metrics.confusionRate, metrics.feedbackSummary, metrics.trendPoints]);

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

  const trendUp = getTrendUp(metrics.trendPoints);
  const currentWindowCount = metrics.currentWindowCount;
  const thresholdReady = currentWindowCount >= 8 && metrics.confusionRate >= 0.3 && metrics.rateDelta >= 0.1;

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
          <div className="text-sm text-slate-500">{"\u5f53\u524d\u4e3b\u9898"}</div>
          <select
            value={topicId}
            disabled
            className="mt-2 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-800"
          >
            <option value="gradient">{"\u68af\u5ea6\u4e0e\u65b9\u5411\u5bfc\u6570"}</option>
          </select>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u5728\u7ebf\u5b66\u751f"}</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{metrics.onlineCount}</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u7d2f\u8ba1\u53cd\u9988"}</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{metrics.feedbackCount}</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u56f0\u60d1\u7387"}</div>
          <div className="mt-2 text-4xl font-bold text-rose-500">{Math.round(metrics.confusionRate * 100)}%</div>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        <div className="rounded-[28px] bg-white p-5 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u8bfe\u5802\u89c2\u5bdf"}</div>
          <div className="mt-2 text-sm leading-6 text-slate-700">
            {trendUp ? "\u6700\u8fd1\u56f0\u60d1\u8d8b\u52bf\u4ecd\u5728\u4e0a\u5347\uff0c\u5efa\u8bae\u4f18\u5148\u7a33\u4f4f\u8282\u594f\u3002" : "\u56f0\u60d1\u8d8b\u52bf\u6682\u65f6\u53ef\u63a7\uff0c\u53ef\u4ee5\u7ed3\u5408\u4f8b\u5b50\u7ee7\u7eed\u63a8\u8fdb\u3002"}
          </div>
        </div>
        <div className="rounded-[28px] bg-white p-5 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u5f53\u524d\u9700\u8981\u5173\u6ce8\u7684\u53cd\u9988"}</div>
          <div className="mt-2 text-sm leading-6 text-slate-700">
            {`\u201c\u6709\u70b9\u5feb\u201d ${metrics.feedbackSummary.too_fast ?? 0} \u6b21\uff0c\u201c\u6ca1\u542c\u61c2\u201d ${metrics.feedbackSummary.confused ?? 0} \u6b21`}
          </div>
        </div>
        <div className="rounded-[28px] bg-white p-5 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u6f14\u793a\u63d0\u793a"}</div>
          <div className="mt-2 text-sm leading-6 text-slate-700">
            {"\u53ef\u4ee5\u5148\u5728\u5b66\u751f\u7aef\u8fde\u7eed\u70b9\u51fb\u201c\u6709\u70b9\u5feb\u201d\u548c\u201c\u6ca1\u542c\u61c2\u201d\uff0c\u518d\u56de\u5230\u8fd9\u91cc\u89c2\u5bdf\u56fe\u8868\u3001\u9884\u8b66\u548c\u7b56\u7565\u533a\u3002"}
          </div>
        </div>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <div className="rounded-[24px] border border-sky-100 bg-sky-50/80 p-4 text-sm leading-6 text-sky-800">
          {"\u89c6\u89c9\u63d0\u793a\uff1a\u53cd\u9988\u5206\u5e03\u66f4\u9002\u5408\u5c55\u793a\u5f53\u4e0b\u5168\u73ed\u72b6\u6001\uff0c\u56f0\u60d1\u8d8b\u52bf\u66f4\u9002\u5408\u8bb2\u89e3\u201c\u53d8\u5316\u8fc7\u7a0b\u201d\u3002"}
        </div>
        <div className="rounded-[24px] border border-amber-100 bg-amber-50/90 p-4 text-sm leading-6 text-amber-800">
          {metrics.alert
            ? "\u5f53\u524d\u5df2\u89e6\u53d1\u9884\u8b66\uff0c\u4e0a\u53f0\u6f14\u793a\u65f6\u53ef\u4ee5\u76f4\u63a5\u8bb2\u201c\u7cfb\u7edf\u5df2\u5efa\u8bae\u8f6c\u5165\u53ef\u89c6\u5316\u91cd\u8bb2\u201d\u3002"
            : "\u5f53\u524d\u672a\u89e6\u53d1\u9884\u8b66\uff0c\u53ef\u4ee5\u5148\u5728\u5b66\u751f\u7aef\u518d\u8fde\u7eed\u63d0\u4ea4 2 \u5230 3 \u6b21\u8d1f\u5411\u53cd\u9988\u3002"}
        </div>
        <div className="rounded-[24px] border border-emerald-100 bg-emerald-50/80 p-4 text-sm leading-6 text-emerald-800">
          {socketReady
            ? "\u5f53\u524d\u4e3a Socket \u5b9e\u65f6\u540c\u6b65\uff0c\u9002\u5408\u76f4\u63a5\u73b0\u573a\u64cd\u4f5c\u5c55\u793a\u3002"
            : "\u5f53\u524d\u4e3a\u8f6e\u8be2\u4fdd\u5e95\u6a21\u5f0f\uff0c\u867d\u7136\u4ecd\u53ef\u6f14\u793a\uff0c\u4f46\u53d8\u5316\u4f1a\u6bd4\u5b9e\u65f6\u94fe\u8def\u7a0d\u6162\u4e00\u70b9\u3002"}
        </div>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <div className="rounded-[24px] bg-white p-4 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u5f53\u524d 30 \u79d2\u53cd\u9988\u6570"}</div>
          <div className="mt-2 text-3xl font-bold text-slate-900">{currentWindowCount}</div>
          <div className="mt-2 text-xs leading-6 text-slate-500">{"\u8fbe\u5230 8 \u6761\u540e\uff0c\u9884\u8b66\u5224\u5b9a\u624d\u4f1a\u8fdb\u5165\u9608\u503c\u68c0\u67e5\u3002"}</div>
        </div>
        <div className="rounded-[24px] bg-white p-4 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u9608\u503c\u5224\u5b9a"}</div>
          <div className={`mt-2 inline-flex rounded-full px-3 py-1 text-sm font-semibold ${thresholdReady ? "bg-rose-50 text-rose-700" : "bg-slate-100 text-slate-700"}`}>
            {thresholdReady ? "\u5df2\u8fdb\u5165\u9884\u8b66\u89c2\u5bdf\u533a" : "\u6682\u672a\u6ee1\u8db3\u9884\u8b66\u6761\u4ef6"}
          </div>
          <div className="mt-3 text-xs leading-6 text-slate-500">
            {`\u6761\u4ef6\uff1a30 \u79d2\u5185 >= 8 \u6761\u53cd\u9988\uff0c\u56f0\u60d1\u7387 >= 30%\uff0c\u4e14\u8f83\u4e0a\u4e00\u4e2a 30 \u79d2\u7a97\u53e3\u4e0a\u5347 >= 10%`}
          </div>
        </div>
        <div className="rounded-[24px] bg-white p-4 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u7b56\u7565\u8054\u52a8\u72b6\u6001"}</div>
          <div className="mt-2 text-sm leading-6 text-slate-700">
            {metrics.alert
              ? "\u5f53\u524d\u7b56\u7565\u5df2\u6839\u636e\u56f0\u60d1\u7387\u4e0e\u53cd\u9988\u5206\u5e03\u91cd\u7ec4\uff0c\u9002\u5408\u76f4\u63a5\u5c55\u793a\u201cAI \u5efa\u8bae\u6559\u5b66\u8c03\u6574\u201d\u3002"
              : "\u5f53\u524d\u5c55\u793a\u7684\u662f\u57fa\u7840\u7b56\u7565\u6a21\u677f\uff0c\u53ef\u4ee5\u5148\u8bb2\u4e3b\u9898\uff0c\u518d\u901a\u8fc7\u5b66\u751f\u53cd\u9988\u89e6\u53d1\u52a8\u6001\u7b56\u7565\u3002"}
          </div>
          <div className="mt-3 text-xs leading-6 text-slate-500">
            {`\u5f53\u524d\u7a97\u53e3\u56f0\u60d1\u7387 ${Math.round(metrics.confusionRate * 100)}%\uff0c\u4e0a\u4e00\u7a97\u53e3 ${Math.round(metrics.lastWindowRate * 100)}%\uff0c\u53d8\u5316 ${metrics.rateDelta >= 0 ? "+" : ""}${Math.round(metrics.rateDelta * 100)}%`}
          </div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between gap-3">
            <h2 className="text-lg font-semibold text-slate-900">{"\u53cd\u9988\u5206\u5e03"}</h2>
            <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">{"\u5b9e\u65f6\u7edf\u8ba1"}</span>
          </div>
          <div className="mt-4 h-80">
            <ReactECharts option={summaryOption} style={{ height: "100%", width: "100%" }} />
          </div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between gap-3">
            <h2 className="text-lg font-semibold text-slate-900">{"\u56f0\u60d1\u8d8b\u52bf"}</h2>
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
