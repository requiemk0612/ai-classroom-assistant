$root = "D:\Projects\ai-classroom-assistant"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom {
  param(
    [string]$Path,
    [string]$Content
  )

  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

Write-Utf8NoBom "$root\app\api\feedback\route.ts" @'
import { NextResponse } from "next/server";
import { z } from "zod";
import { canSendFeedback } from "@/lib/anti-fake";
import { loadSessionState, saveSessionState } from "@/lib/file-store";

const bodySchema = z.object({
  sessionId: z.string(),
  studentId: z.string(),
  topicId: z.string(),
  feedbackType: z.enum(["understand", "too_fast", "confused", "clear_example"]),
  time: z.string()
});

export async function POST(request: Request) {
  const body = bodySchema.parse(await request.json());
  if (!canSendFeedback(body.studentId)) {
    return NextResponse.json({ ok: false, message: "反馈发送过快，请稍后再试。" }, { status: 429 });
  }

  const session = await loadSessionState();
  if (!session.onlineStudents.includes(body.studentId)) {
    session.onlineStudents.push(body.studentId);
  }
  session.topicId = body.topicId;
  session.feedbackLog.push({
    studentId: body.studentId,
    feedbackType: body.feedbackType,
    time: body.time
  });
  await saveSessionState(session);

  return NextResponse.json({ ok: true, message: "反馈已记录。" });
}
'@

Write-Utf8NoBom "$root\app\api\ask\route.ts" @'
import { NextResponse } from "next/server";
import { z } from "zod";
import { buildAskResult } from "@/lib/retrieval";

const bodySchema = z.object({
  topicId: z.string(),
  question: z.string(),
  studentId: z.string()
});

export async function POST(request: Request) {
  try {
    const body = bodySchema.parse(await request.json());
    const result = await buildAskResult(body.topicId, body.question);
    return NextResponse.json(result);
  } catch {
    return NextResponse.json({
      answer: "当前问答服务暂时不可用，建议先回到课堂讲义中的定义、图像和典型例题部分。",
      confidence: "low",
      sourceNotes: [],
      safeNote: "根据当前系统状态，这次回答仍需要结合老师课堂讲解进一步确认。"
    });
  }
}
'@

Write-Utf8NoBom "$root\app\api\pressure\route.ts" @'
import { NextResponse } from "next/server";
import { loadPressureData } from "@/lib/file-store";
import { getWeatherLevel } from "@/lib/confidence";

export async function GET() {
  const data = await loadPressureData();
  const pressureScore = (1 - data.homeworkSpeed + (1 - data.accuracyRate)) / 2;

  return NextResponse.json({
    ...data,
    weatherLevel: getWeatherLevel(pressureScore),
    microStrategies: [
      "建议先放慢梯度几何意义的推导节奏，让学生稳住直观理解。",
      "建议补一张等高线示意图，帮助学生把梯度方向和方向导数联系起来。",
      "建议课后发两个微练习，巩固方向导数公式和单位方向向量的使用。"
    ]
  });
}
'@

Write-Utf8NoBom "$root\lib\confidence.ts" @'
export function getWeatherLevel(score: number): string {
  if (score >= 0.7) return "雷暴";
  if (score >= 0.45) return "多云";
  return "晴天";
}
'@

Write-Utf8NoBom "$root\lib\threshold.ts" @'
import type { SessionState, DashboardMetrics, AlertInfo, FeedbackType } from "@/types/classroom";

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
    alertMessage: `当前最近 30 秒中约有 ${Math.round(currentRate * 100)}% 的反馈显示学生理解压力偏高，建议立刻切换讲解策略。`,
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

Write-Utf8NoBom "$root\lib\strategy-engine.ts" @'
import type { StrategyItem, StrategyResponse, StrategyTopic } from "@/types/strategy";
import { runDeepSeekChat } from "@/lib/deepseek";
import { loadStrategyLibrary } from "@/lib/file-store";

function buildItems(topic: StrategyTopic): StrategyItem[] {
  return [
    {
      type: "analogy",
      title: "经典类比",
      text: topic.analogy[0] ?? "建议先用一个贴近生活的类比，帮助学生建立直觉。"
    },
    {
      type: "visual",
      title: "可视化动作",
      text: topic.visual[0] ?? "建议立刻补一张图像化展示，帮助学生把公式和几何意义联系起来。"
    },
    {
      type: "quick_check",
      title: "快速匿名检查",
      text: topic.quickCheck[0] ?? "建议发起一个一分钟匿名小测，快速确认学生卡住的位置。"
    }
  ];
}

export async function buildStrategyResponse(topicId: string, confusionRate: number): Promise<StrategyResponse> {
  const library = await loadStrategyLibrary();
  const topic = library.topics.find((item) => item.topicId === topicId) ?? library.topics[0];
  const localResponse: StrategyResponse = {
    alertLevel: confusionRate > 0.5 ? "high" : "medium",
    alertMessage: `当前主题“${topic.topicName}”的困惑反馈正在上升，建议老师先稳住节奏，再补一个更直观的解释和快速检查。`,
    strategies: buildItems(topic)
  };

  const aiText = await runDeepSeekChat(
    [
      {
        role: "system",
        content:
          "你是课堂教学助手。请基于给定的教学策略，输出严格 JSON，字段为 alertMessage 和 strategies。strategies 必须是长度为 3 的数组，每项包含 title 和 text。全部内容使用简洁中文，不要编造未提供的教学事实。"
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
          title: item.title || localResponse.strategies[index]?.title || "教学建议",
          text: item.text || localResponse.strategies[index]?.text || "建议老师补一个更清晰的解释。"
        })) ?? localResponse.strategies
    };
  } catch {
    return localResponse;
  }
}
'@

Write-Utf8NoBom "$root\lib\retrieval.ts" @'
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

  for (const part of chunk.content.split(/[。；，、]/)) {
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
    return "当前课程资料里没有直接覆盖这个问题。建议先回看“梯度定义、最大方向导数、等高线关系”这几个知识点，再结合老师课堂讲解理解。";
  }

  const mainMatch = matches[0];
  const supportMatch = matches[1];

  if (confidence === "high" && supportMatch) {
    return `根据当前课程资料，${mainMatch.content} 另外，${supportMatch.content}`;
  }

  return `根据当前课程资料，${mainMatch.content} 建议你再结合课堂上的图像示意和公式推导一起理解。`;
}

async function buildAiAnswer(question: string, matches: MatchChunk[]): Promise<string | null> {
  if (matches.length === 0) {
    return null;
  }

  const sourceText = matches
    .map((item, index) => `资料${index + 1}：${item.title}（${item.sourceName} ${item.page}）\n${item.content}`)
    .join("\n\n");

  return runDeepSeekChat(
    [
      {
        role: "system",
        content:
          "你是高等数学课堂问答助手。只能根据提供的课程资料回答，不要补充资料之外的结论。请使用简洁中文，适合课堂答疑，长度控制在 2 到 4 句。"
      },
      {
        role: "user",
        content: `学生问题：${question}\n\n可用资料：\n${sourceText}`
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
        ? "根据当前课程资料，这一部分还需要结合老师课堂讲解进一步确认。"
        : ""
  };
}
'@

Write-Utf8NoBom "$root\server\socket.ts" @'
import type { Server } from "socket.io";
import type { FeedbackItem } from "@/types/classroom";
import { canSendFeedback } from "@/lib/anti-fake";
import { buildStrategyResponse } from "@/lib/strategy-engine";
import { addFeedback, getMetrics } from "./state";

export function registerSocketHandlers(io: Server): void {
  io.on("connection", (socket) => {
    socket.on("feedback:send", async (payload: FeedbackItem) => {
      if (!payload?.studentId || !canSendFeedback(payload.studentId)) {
        socket.emit("feedback:rejected", { message: "反馈发送过快，请稍后再试。" });
        return;
      }

      await addFeedback(payload);
      const metrics = getMetrics();
      io.emit("metrics:update", metrics);

      if (metrics.alert) {
        const strategy = await buildStrategyResponse(metrics.alert.topicId, metrics.confusionRate);
        io.emit("strategy:update", strategy);
      }
    });
  });
}
'@
