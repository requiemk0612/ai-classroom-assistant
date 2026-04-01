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
    .split(/[。；;\n]/)
    .map((item) => item.trim())
    .filter((item) => item.length >= 6);
  const uniqueParts = Array.from(new Set(parts));
  return uniqueParts.slice(0, 6);
}

function buildLocalGroups(points: string[]): SummaryGroup[] {
  return points.map((point) => {
    const clauses = point
      .split(/[，、]/)
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
          "你是课堂教学内容整理助手。请从 PPT 文本中提炼 4 到 6 个一级知识点，并为每个一级知识点生成 1 到 3 个二级短语。输出严格 JSON，字段名必须是 groups，groups 是数组，每项包含 title 和 children。全部使用中文短句。"
      },
      {
        role: "user",
        content: `课程名称：${courseName}\n\nPPT 文本：\n${slides.join("\n")}`
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

export async function GET() {
  return NextResponse.json(await loadMindMapData());
}

export async function POST(request: Request) {
  const formData = await request.formData();
  const courseName = String(formData.get("courseName") || "高等数学：全微分、方向导数与梯度");
  const file = formData.get("pptFile");
  const current = await loadMindMapData();

  try {
    if (file instanceof File && file.size > 0) {
      const slides = await parsePpt(await file.arrayBuffer());
      const summaryPoints = buildSummaryPoints(slides);
      const groups =
        (await buildAiGroups(courseName, slides)) ||
        buildLocalGroups(summaryPoints.length > 0 ? summaryPoints : current.summaryPoints);
      const nextData = buildMindMapFromGroups(current.topicId, courseName, groups);
      nextData.sourceSlides = slides.map((item, index) => `第${index + 1}页：${item.slice(0, 80)}`);
      await saveMindMapData(nextData);
      return NextResponse.json(nextData);
    }

    const nextData = buildMindMapFromPoints(current.topicId, courseName, current.summaryPoints);
    nextData.sourceSlides = current.sourceSlides;
    await saveMindMapData(nextData);
    return NextResponse.json(nextData);
  } catch {
    return NextResponse.json(current);
  }
}
