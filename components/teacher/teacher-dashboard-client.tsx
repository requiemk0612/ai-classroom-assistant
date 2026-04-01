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