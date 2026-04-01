$files = @{
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

  for (const part of chunk.content.split(/[\uFF0C\u3002\uFF1B\uFF1A]/)) {
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
