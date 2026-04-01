$root = "D:\Projects\ai-classroom-assistant"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom {
  param(
    [string]$Path,
    [string]$Content
  )

  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom "$root\components\teacher\teacher-dashboard-client.tsx" @'
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
    title: "先用生活类比稳住理解",
    text: "可以把梯度理解成山坡上“上升最快”的箭头，先让学生建立直观感受，再回到公式。"
  },
  {
    type: "visual",
    title: "补一张等高线或箭头图",
    text: "建议立刻补一个等高线示意图，帮助学生把梯度方向、等高线正交和方向导数联系起来。"
  },
  {
    type: "quick_check",
    title: "做一次 1 分钟匿名检查",
    text: "可以发起一个快速判断题，确认学生是否分清“方向导数”和“梯度方向”这两个概念。"
  }
];

export function TeacherDashboardClient({ initialMetrics }: { initialMetrics: DashboardMetrics }) {
  const [metrics, setMetrics] = useState(initialMetrics);
  const [strategies, setStrategies] = useState<StrategyItem[]>(defaultStrategies);
  const [topicId] = useState("gradient");
  const [statusText, setStatusText] = useState("正在读取课堂状态...");
  const [socketReady, setSocketReady] = useState(false);

  useEffect(() => {
    let active = true;

    async function loadMetrics() {
      try {
        const data = await getJson<MetricsResponse>("/api/metrics");
        if (active) {
          setMetrics(data);
          setStatusText("当前展示的是最新课堂数据。");
        }
      } catch {
        if (active) {
          setStatusText("当前接口未更新，先展示本地课堂数据。");
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
      setStatusText("已收到实时课堂更新。");
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
        data: ["听懂了", "有点快", "没听懂", "例子清楚"],
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
          <div className={`inline-flex rounded-full px-3 py-1 text-xs font-medium ${socketReady ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700"}`}>
            {socketReady ? "实时链路已连接" : "当前使用接口轮询展示"}
          </div>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-4">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">当前主题</div>
          <select
            value={topicId}
            disabled
            className="mt-2 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-800"
          >
            <option value="gradient">方向导数与梯度</option>
          </select>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">在线人数</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{metrics.onlineCount}</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">累计反馈</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{metrics.feedbackCount}</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">困惑率</div>
          <div className="mt-2 text-4xl font-bold text-rose-500">{Math.round(metrics.confusionRate * 100)}%</div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between gap-3">
            <h2 className="text-lg font-semibold text-slate-900">反馈分布</h2>
            <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">实时更新</span>
          </div>
          <div className="mt-4 h-80">
            <ReactECharts option={summaryOption} style={{ height: "100%", width: "100%" }} />
          </div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="flex items-center justify-between gap-3">
            <h2 className="text-lg font-semibold text-slate-900">最近趋势</h2>
            <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">
              {metrics.alert ? "需要关注" : "整体平稳"}
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

Write-Utf8NoBom "$root\components\teacher\teacher-pressure-client.tsx" @'
"use client";

import { useEffect, useMemo, useState } from "react";
import type { PressureData } from "@/types/classroom";
import type { PressureResponse } from "@/types/api";
import { getWeatherLevel } from "@/lib/confidence";
import { getJson } from "@/lib/api-client";

export function TeacherPressureClient({ initialData }: { initialData: PressureData }) {
  const [data, setData] = useState(initialData);
  const [microStrategies, setMicroStrategies] = useState<string[]>([
    "建议先把方向导数和偏导数的特殊关系讲清楚，再引入梯度。",
    "建议补一张等高线示意图，帮助学生理解梯度与等高线正交。",
    "建议课后发两个微练习，降低学生对公式的陌生感。"
  ]);
  const [weather, setWeather] = useState(getWeatherLevel((1 - initialData.homeworkSpeed + (1 - initialData.accuracyRate)) / 2));
  const [statusText, setStatusText] = useState("当前展示的是本地压力示例数据。");

  useEffect(() => {
    let active = true;

    async function loadPressure() {
      try {
        const response = await getJson<PressureResponse>("/api/pressure");
        if (!active) {
          return;
        }
        setData(response);
        setMicroStrategies(response.microStrategies);
        setWeather(response.weatherLevel);
        setStatusText("已加载最新压力数据。");
      } catch {
        if (active) {
          setStatusText("接口暂未更新，当前展示本地示例数据。");
        }
      }
    }

    void loadPressure();

    return () => {
      active = false;
    };
  }, []);

  const pressureScore = useMemo(() => (1 - data.homeworkSpeed + (1 - data.accuracyRate)) / 2, [data]);

  return (
    <div className="grid gap-6">
      <div className="rounded-[28px] bg-white p-4 text-sm text-slate-600 shadow-sm ring-1 ring-slate-200">{statusText}</div>

      <div className="grid gap-6 md:grid-cols-4">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">压力指数</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{pressureScore.toFixed(2)}</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">天气状态</div>
          <div className="mt-2 text-4xl font-bold text-brand-600">{weather}</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">正确率</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{Math.round(data.accuracyRate * 100)}%</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">作业速度</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{Math.round(data.homeworkSpeed * 100)}%</div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">情绪线索</h2>
          <div className="mt-4 flex flex-wrap gap-3">
            {data.moodWords.map((item) => (
              <span key={item} className="rounded-full bg-slate-100 px-4 py-2 text-sm text-slate-700">
                {item}
              </span>
            ))}
          </div>

          <div className="mt-6">
            <h3 className="text-sm font-semibold text-slate-900">最近五次压力趋势</h3>
            <div className="mt-3 flex h-24 items-end gap-3 rounded-2xl bg-slate-50 px-4 py-4">
              {data.weeklyTrend.map((value, index) => (
                <div key={`${value}-${index}`} className="flex flex-1 flex-col items-center gap-2">
                  <div className="w-full rounded-full bg-brand-100" style={{ height: `${Math.max(14, Math.round(value * 100))}%` }} />
                  <div className="text-xs text-slate-500">第{index + 1}次</div>
                </div>
              ))}
            </div>
          </div>

          <div className="mt-6">
            <h3 className="text-sm font-semibold text-slate-900">微策略建议</h3>
            <ul className="mt-3 space-y-2 text-sm text-slate-700">
              {microStrategies.map((item) => (
                <li key={item} className="rounded-2xl bg-slate-50 px-4 py-3 leading-6">
                  {item}
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">知识简化包</h2>
          <div className="mt-4 rounded-2xl bg-slate-50 px-4 py-4">
            <div className="text-sm font-semibold text-slate-900">{data.simplificationPack.title}</div>
            <div className="mt-2 text-sm leading-6 text-slate-700">{data.simplificationPack.summary}</div>
            <ul className="mt-3 space-y-2 text-sm text-slate-700">
              {data.simplificationPack.actions.map((item) => (
                <li key={item} className="rounded-xl bg-white px-3 py-2">
                  {item}
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
'@

Write-Utf8NoBom "$root\components\teacher\teacher-mindmap-client.tsx" @'
"use client";

import { useEffect, useState, type FormEvent } from "react";
import { PointSummary } from "@/components/shared/point-summary";
import { MindMapView } from "@/components/shared/mindmap-view";
import type { MindMapData } from "@/types/mindmap";
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

export function TeacherMindMapClient({ initialData }: { initialData: MindMapData }) {
  const [data, setData] = useState(initialData);
  const [courseName, setCourseName] = useState(initialData.courseName);
  const [statusText, setStatusText] = useState("当前展示的是最近一次生成的导图结果。");
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    let active = true;

    async function loadLatest() {
      try {
        const latest = await getJson<MindMapData>("/api/mindmap");
        if (active) {
          setData(latest);
          setCourseName(latest.courseName);
          setStatusText("已同步最新导图数据。");
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

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    const file = formData.get("pptFile");

    if (file instanceof File && file.size > 0 && !file.name.endsWith(".pptx")) {
      setStatusText("请上传 .pptx 格式的教学 PPT。");
      return;
    }

    setSubmitting(true);
    setStatusText("正在处理 PPT，并生成知识点摘要...");

    try {
      const response = await fetch("/api/mindmap", {
        method: "POST",
        body: formData
      });
      const result = (await response.json()) as MindMapData;
      setData(result);
      setCourseName(result.courseName);
      setStatusText("导图数据已刷新，学生端也可以同步查看。");
    } catch {
      setStatusText("当前导图生成失败，请稍后重试。");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="grid gap-6">
      <form onSubmit={handleSubmit} className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
        <div className="grid gap-4 lg:grid-cols-[1fr_1fr_auto]">
          <div>
            <label className="text-sm font-medium text-slate-700">课程名称</label>
            <input
              name="courseName"
              value={courseName}
              onChange={(event) => setCourseName(event.target.value)}
              className="mt-2 w-full rounded-2xl border border-slate-200 px-4 py-3 text-sm outline-none focus:border-brand-500"
            />
          </div>
          <div>
            <label className="text-sm font-medium text-slate-700">上传 PPT</label>
            <input
              name="pptFile"
              type="file"
              accept=".pptx"
              className="mt-2 block w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-700"
            />
          </div>
          <button
            type="submit"
            disabled={submitting}
            className="mt-7 rounded-full bg-brand-600 px-5 py-3 text-sm font-semibold text-white transition hover:bg-brand-700 disabled:cursor-not-allowed disabled:opacity-60"
          >
            {submitting ? "正在生成导图" : "生成导图"}
          </button>
        </div>
        <div className="mt-4 rounded-2xl bg-slate-50 px-4 py-3 text-sm text-slate-700">{statusText}</div>
        <div className="mt-4 rounded-2xl bg-brand-50 px-4 py-3 text-sm text-brand-700">
          支持文本型 .pptx 文件。生成结果会同步到学生端知识导图页面。
        </div>
      </form>

      <div className="grid gap-6 lg:grid-cols-[0.9fr_1.1fr]">
        <div className="grid gap-6">
          <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
            <div className="flex items-center justify-between gap-3">
              <h2 className="text-lg font-semibold text-slate-900">提取结果预览</h2>
              <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">
                更新于 {formatTime(data.updatedAt)}
              </span>
            </div>
            <div className="mt-4 space-y-3 text-sm text-slate-700">
              {data.sourceSlides.length > 0 ? (
                data.sourceSlides.map((item) => (
                  <div key={item} className="rounded-2xl bg-slate-50 px-4 py-3 leading-6">
                    {item}
                  </div>
                ))
              ) : (
                <div className="rounded-2xl bg-slate-50 px-4 py-3 text-slate-500">当前还没有可展示的 PPT 提取内容。</div>
              )}
            </div>
          </div>
          <PointSummary points={data.summaryPoints} />
        </div>
        <MindMapView data={data} />
      </div>
    </div>
  );
}
'@
