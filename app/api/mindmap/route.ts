import { NextResponse } from "next/server";
import { runDeepSeekChat } from "@/lib/deepseek";
import { loadMindMapData, saveMindMapData } from "@/lib/file-store";
import { buildMindMapFromGroups, buildMindMapFromPoints } from "@/lib/mindmap-layout";
import { parsePpt } from "@/lib/ppt-parser";

interface SummaryGroup {
  title: string;
  children: string[];
}

function buildSummaryPoints(slides: string[]): string[] {
  const merged = slides.join(" ");
  const parts = merged
    .split(/[\u3002\uFF1B;\n]/)
    .map((item) => item.trim())
    .filter((item) => item.length >= 6);
  const uniqueParts = Array.from(new Set(parts));
  return uniqueParts.slice(0, 6);
}

function buildLocalGroups(points: string[]): SummaryGroup[] {
  return points.map((point) => {
    const clauses = point
      .split(/[\uFF0C\u3001]/)
      .map((item) => item.trim())
      .filter((item) => item.length >= 4)
      .slice(0, 3);

    return {
      title: point,
      children: clauses.length > 1 ? clauses.slice(1) : []
    };
  });
}

async function buildAiGroups(courseName: string, slides: string[]): Promise<SummaryGroup[] | null> {
  const aiText = await runDeepSeekChat(
    [
      {
        role: "system",
        content:
          "\u4f60\u662f\u8bfe\u5802\u6559\u5b66\u5185\u5bb9\u6574\u7406\u52a9\u624b\u3002\u8bf7\u4ece PPT \u6587\u672c\u4e2d\u63d0\u70bc 4 \u5230 6 \u4e2a\u4e00\u7ea7\u77e5\u8bc6\u70b9\uff0c\u5e76\u4e3a\u6bcf\u4e2a\u4e00\u7ea7\u77e5\u8bc6\u70b9\u751f\u6210 1 \u5230 3 \u4e2a\u4e8c\u7ea7\u77ed\u8bed\u3002\u8f93\u51fa\u4e25\u683c JSON\uff0c\u5b57\u6bb5\u540d\u5fc5\u987b\u662f groups\uff0cgroups \u662f\u6570\u7ec4\uff0c\u6bcf\u9879\u5305\u542b title \u548c children\u3002\u5168\u90e8\u4f7f\u7528\u4e2d\u6587\u77ed\u53e5\u3002"
      },
      {
        role: "user",
        content: `\u8bfe\u7a0b\u540d\u79f0\uff1a${courseName}\n\nPPT \u6587\u672c\uff1a\n${slides.join("\n")}`
      }
    ],
    { jsonMode: true, maxTokens: 700 }
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
        .map((item) => ({
          title: item.title.trim(),
          children: (item.children ?? []).map((child) => child.trim()).filter(Boolean).slice(0, 3)
        })) ?? [];
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
      const slides = await parsePpt(await file.arrayBuffer());
      const summaryPoints = buildSummaryPoints(slides);
      const groups =
        (await buildAiGroups(courseName, slides)) ||
        buildLocalGroups(summaryPoints.length > 0 ? summaryPoints : current.summaryPoints);
      const nextData = buildMindMapFromGroups(topicId, courseName, groups);
      nextData.sourceSlides = slides.map((item, index) => `\u7b2c${index + 1}\u9875\uff1a${item.slice(0, 80)}`);
      await saveMindMapData(nextData);
      return NextResponse.json(nextData);
    }

    const nextData = buildMindMapFromPoints(topicId, courseName, current.summaryPoints);
    nextData.sourceSlides = current.sourceSlides;
    await saveMindMapData(nextData);
    return NextResponse.json(nextData);
  } catch {
    return NextResponse.json(current);
  }
}