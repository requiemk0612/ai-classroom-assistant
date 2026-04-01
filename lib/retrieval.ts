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

const aliasMap: Record<string, string[]> = {
  "\u68af\u5ea6": ["grad", "\u589e\u957f\u6700\u5feb", "\u6700\u5feb\u4e0a\u5347", "\u6700\u5927\u53d8\u5316\u7387"],
  "\u65b9\u5411\u5bfc\u6570": ["\u6cbf\u67d0\u4e2a\u65b9\u5411", "\u6cbf\u6307\u5b9a\u65b9\u5411", "\u53d8\u5316\u7387"],
  "\u7b49\u9ad8\u7ebf": ["\u7b49\u503c\u7ebf", "\u7b49\u9ad8\u9762"],
  "\u5168\u5fae\u5206": ["\u5168\u589e\u91cf", "\u5c40\u90e8\u7ebf\u6027\u8fd1\u4f3c"],
  "\u5207\u5e73\u9762": ["\u5207\u5e73\u9762\u65b9\u7a0b", "\u7ebf\u6027\u8fd1\u4f3c"]
};

function normalizeQuestion(question: string): string {
  let next = question;
  for (const [canonical, aliases] of Object.entries(aliasMap)) {
    if (next.includes(canonical)) {
      continue;
    }

    if (aliases.some((alias) => next.includes(alias))) {
      next += ` ${canonical}`;
    }
  }

  return next;
}

function scoreChunk(question: string, topicId: string, chunk: Omit<MatchChunk, "score">): number {
  let score = 0;
  let evidence = 0;

  if (chunk.topicId === topicId) {
    score += 1;
  }

  for (const keyword of chunk.keywords) {
    if (question.includes(keyword)) {
      score += 2;
      evidence += 1;
    }
  }

  if (question.includes(chunk.title)) {
    score += 3;
    evidence += 1;
  }

  for (const part of chunk.content.split(/[\uFF0C\u3002\uFF1B\uFF1A]/)) {
    const text = part.trim();
    if (text.length >= 6 && question.includes(text.slice(0, 6))) {
      score += 1;
      evidence += 1;
      break;
    }
  }

  if (evidence === 0) {
    return 0;
  }

  return score;
}

function getConfidence(matches: MatchChunk[]): AskResult["confidence"] {
  const topScore = matches[0]?.score ?? 0;
  const secondScore = matches[1]?.score ?? 0;

  if (matches.length >= 2 && topScore >= 5 && secondScore >= 4) {
    return "high";
  }

  if (matches.length >= 1 && topScore >= 3) {
    return "medium";
  }

  return "low";
}

function buildLocalAnswer(matches: MatchChunk[], confidence: AskResult["confidence"]): string {
  if (matches.length === 0) {
    return "\u5f53\u524d\u8bfe\u5185\u8d44\u6599\u4e3b\u8981\u56f4\u7ed5\u5168\u5fae\u5206\u3001\u65b9\u5411\u5bfc\u6570\u3001\u68af\u5ea6\u548c\u5207\u5e73\u9762\u3002\u4f60\u8fd9\u4e2a\u95ee\u9898\u548c\u672c\u8282\u8bfe\u7684\u76f4\u63a5\u5bf9\u5e94\u4f9d\u636e\u8fd8\u4e0d\u591f\u591a\uff0c\u5982\u679c\u4f60\u60f3\u628a\u5b83\u548c\u8bfe\u5802\u5185\u5bb9\u8054\u7cfb\u8d77\u6765\uff0c\u53ef\u4ee5\u5148\u4ece\u201c\u6700\u5927\u53d8\u5316\u7387\u201d\u3001\u201c\u7b49\u9ad8\u7ebf\u201d\u6216\u201c\u68af\u5ea6\u7684\u51e0\u4f55\u610f\u4e49\u201d\u8fd9\u4e9b\u89d2\u5ea6\u91cd\u65b0\u63d0\u95ee\u3002";
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
    { maxTokens: 220 }
  );
}

export async function buildAskResult(topicId: string, question: string): Promise<AskResult> {
  const normalizedQuestion = normalizeQuestion(question);
  const materials = await loadCourseMaterials();
  const matches = materials.chunks
    .map((chunk) => ({ ...chunk, score: scoreChunk(normalizedQuestion, topicId, chunk) }))
    .filter((chunk) => chunk.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, 3) as MatchChunk[];

  const confidence = getConfidence(matches);
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
        ? "\u6839\u636e\u5f53\u524d\u8bfe\u7a0b\u8d44\u6599\uff0c\u8fd9\u4e00\u90e8\u5206\u6682\u65f6\u66f4\u9002\u5408\u4f5c\u4e3a\u201c\u8bfe\u5185\u8054\u60f3\u63d0\u95ee\u201d\u6765\u7ee7\u7eed\u8ffd\u95ee\uff0c\u6216\u7ed3\u5408\u8001\u5e08\u5f53\u5802\u8bb2\u89e3\u518d\u786e\u8ba4\u4e00\u6b21\u3002"
        : ""
  };
}
