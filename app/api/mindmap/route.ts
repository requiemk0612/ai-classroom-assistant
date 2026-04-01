import { NextResponse } from "next/server";
import { runDeepSeekChat } from "@/lib/deepseek";
import { loadMindMapData, saveMindMapData } from "@/lib/file-store";
import { buildMindMapFromGroups, buildMindMapFromPoints } from "@/lib/mindmap-layout";
import { parsePpt } from "@/lib/ppt-parser";

interface SummaryGroup {
  title: string;
  children: string[];
}

class MindMapBuildError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "MindMapBuildError";
  }
}

function looksLikeNoise(text: string): boolean {
  const lower = text.toLowerCase();
  const digitCount = (text.match(/\d/g) ?? []).length;

  return (
    lower.includes("http://schemas") ||
    lower.includes("open sans") ||
    lower.includes("utf-8") ||
    lower.includes("rectangle") ||
    lower.includes("connsitex") ||
    lower.includes("times new roman") ||
    digitCount > Math.max(24, Math.floor(text.length * 0.25))
  );
}

function splitTerms(text: string): string[] {
  return text
    .split(/[\u3002\uFF0C\u3001\uFF1B\uFF1A\(\)\s]/)
    .map((item) => item.trim())
    .filter((item) => item.length >= 2);
}

function buildSummaryPoints(slides: string[]): string[] {
  const merged = slides.join(" ");
  const parts = merged
    .split(/[\u3002\uFF1B;\n]/)
    .map((item) => item.trim())
    .filter((item) => item.length >= 6 && !looksLikeNoise(item));
  const uniqueParts = Array.from(new Set(parts));
  return uniqueParts.slice(0, 6);
}

function buildFallbackPoints(slides: string[]): string[] {
  const chunks = slides
    .flatMap((slide) =>
      slide
        .split(/[\u3002\uFF1B;\n]/)
        .map((item) => item.trim())
        .filter((item) => item.length >= 4 && !looksLikeNoise(item))
    )
    .map((item) => item.replace(/\s+/g, " ").trim());

  return Array.from(new Set(chunks)).slice(0, 6);
}

function buildLocalGroups(points: string[]): SummaryGroup[] {
  return points.map((point) => {
    const clauses = point
      .split(/[\uFF0C\u3001]/)
      .map((item) => item.trim())
      .filter((item) => item.length >= 4)
      .slice(0, 3);
    const title = clauses[0]?.slice(0, 18) || point.slice(0, 18);
    const extraChildren =
      clauses.length > 1
        ? clauses.slice(1)
        : point
            .split(/[\u662f\u4e3a\u53ef\u4e0e]/)
            .map((item) => item.trim())
            .filter((item) => item.length >= 4)
            .slice(1, 3);

    return {
      title,
      children: extraChildren
    };
  });
}

async function buildAiGroups(courseName: string, slides: string[]): Promise<SummaryGroup[] | null> {
  const localPoints = buildSummaryPoints(slides);
  const sourceTerms = new Set(splitTerms(slides.join(" ")));

  if (slides.length === 0 || localPoints.length === 0 || sourceTerms.size === 0) {
    return null;
  }

  const aiText = await runDeepSeekChat(
    [
      {
        role: "system",
        content:
          "\u4f60\u662f\u8bfe\u5802\u6559\u5b66\u5185\u5bb9\u6574\u7406\u52a9\u624b\u3002\u53ea\u80fd\u91cd\u7ec4\u672c\u5730\u63d0\u4f9b\u7684\u77e5\u8bc6\u70b9\uff0c\u4e0d\u80fd\u5f15\u5165 PPT \u4e2d\u672a\u51fa\u73b0\u7684\u65b0\u4e3b\u9898\u3001\u65b0\u5e94\u7528\u6216\u8bfe\u5916\u77e5\u8bc6\u3002\u8bf7\u628a\u5df2\u6709\u77e5\u8bc6\u70b9\u6574\u7406\u6210 4 \u5230 6 \u4e2a\u4e00\u7ea7\u8282\u70b9\uff0c\u6bcf\u4e2a\u8282\u70b9\u914d 1 \u5230 2 \u4e2a\u4e8c\u7ea7\u77ed\u8bed\u3002\u8f93\u51fa\u4e25\u683c JSON\uff0c\u5b57\u6bb5\u540d\u5fc5\u987b\u662f groups\uff0cgroups \u662f\u6570\u7ec4\uff0c\u6bcf\u9879\u5305\u542b title \u548c children\u3002\u5168\u90e8\u4f7f\u7528\u4e2d\u6587\u77ed\u53e5\u3002"
      },
      {
        role: "user",
        content: `\u8bfe\u7a0b\u540d\u79f0\uff1a${courseName}\n\n\u672c\u5730\u63d0\u70bc\u77e5\u8bc6\u70b9\uff1a\n${localPoints.join("\n")}\n\nPPT \u539f\u59cb\u6587\u672c\uff1a\n${slides.join("\n")}`
      }
    ],
    { jsonMode: true, maxTokens: 320 }
  );

  if (!aiText) {
    return null;
  }

  try {
    const parsed = JSON.parse(aiText) as { groups?: SummaryGroup[] };
    const groups =
      parsed.groups
        ?.filter((item) => item.title)
        .slice(0, 6)
        .map((item) => {
          const title = item.title.trim();
          const titleTerms = splitTerms(title);
          if (!title || !titleTerms.some((term) => sourceTerms.has(term))) {
            return null;
          }

          return {
            title,
            children: (item.children ?? [])
              .map((child) => child.trim())
              .filter((child) => {
                if (!child) {
                  return false;
                }

                const terms = splitTerms(child);
                return terms.some((term) => sourceTerms.has(term));
              })
              .slice(0, 3)
          };
        })
        .filter((item): item is SummaryGroup => Boolean(item)) ?? [];
    return groups.length > 0 ? groups : null;
  } catch {
    return null;
  }
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const topicId = searchParams.get("topicId");
  const current = await loadMindMapData();

  if (topicId && topicId !== current.topicId) {
    return NextResponse.json({ message: "\u672a\u627e\u5230\u5bf9\u5e94\u4e3b\u9898\u7684\u5bfc\u56fe\u3002" }, { status: 404 });
  }

  return NextResponse.json(current);
}

export async function POST(request: Request) {
  const formData = await request.formData();
  const current = await loadMindMapData();
  const topicId = String(formData.get("topicId") || current.topicId);
  const courseName = String(formData.get("courseName") || current.courseName);
  const file = formData.get("pptFile");

  try {
    if (file instanceof File && file.size > 0) {
      const slides = (await parsePpt(await file.arrayBuffer()))
        .map((item) => item.replace(/\s+/g, " ").trim())
        .filter((item) => item.length >= 4 && !looksLikeNoise(item));

      if (slides.length === 0) {
        throw new MindMapBuildError("\u672a\u80fd\u4ece\u8fd9\u4efd PPT \u4e2d\u63d0\u53d6\u5230\u53ef\u7528\u6587\u672c\uff0c\u8bf7\u6362\u4e00\u4efd\u6587\u672c\u578b .pptx \u518d\u8bd5\u3002");
      }

      const summaryPoints = buildSummaryPoints(slides);
      const fallbackPoints = summaryPoints.length > 0 ? summaryPoints : buildFallbackPoints(slides);

      if (fallbackPoints.length === 0) {
        throw new MindMapBuildError("\u8fd9\u4efd PPT \u5df2\u8bfb\u53d6\u6210\u529f\uff0c\u4f46\u6ca1\u6709\u63d0\u70bc\u51fa\u7a33\u5b9a\u7684\u77e5\u8bc6\u70b9\uff0c\u8bf7\u4f18\u5148\u4f7f\u7528\u6587\u5b57\u66f4\u6e05\u6670\u7684\u6559\u5b66\u5e7b\u706f\u7247\u3002");
      }

      const groups = (await buildAiGroups(courseName, slides)) || buildLocalGroups(fallbackPoints);
      const nextData = buildMindMapFromGroups(topicId, courseName, groups);
      nextData.summaryPoints = fallbackPoints;
      nextData.sourceSlides = slides.map((item, index) => `\u7b2c${index + 1}\u9875\uff1a${item.slice(0, 80)}`);
      await saveMindMapData(nextData);
      return NextResponse.json(nextData);
    }

    const nextData = buildMindMapFromPoints(topicId, courseName, current.summaryPoints);
    nextData.sourceSlides = current.sourceSlides;
    await saveMindMapData(nextData);
    return NextResponse.json(nextData);
  } catch (error) {
    if (error instanceof MindMapBuildError) {
      return NextResponse.json({ message: error.message }, { status: 400 });
    }

    return NextResponse.json(
      { message: "\u751f\u6210\u5bfc\u56fe\u65f6\u53d1\u751f\u9519\u8bef\uff0c\u5df2\u4fdd\u7559\u4e0a\u4e00\u7248\u7ed3\u679c\u3002" },
      { status: 500 }
    );
  }
}
