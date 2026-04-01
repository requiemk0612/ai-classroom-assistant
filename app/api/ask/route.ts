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
      answer:
        "\u5f53\u524d\u95ee\u7b54\u529f\u80fd\u6682\u65f6\u6ca1\u6709\u6210\u529f\u8fd4\u56de\uff0c\u5efa\u8bae\u5148\u56de\u5230\u8bfe\u7a0b\u8d44\u6599\u4e2d\u7684\u5b9a\u4e49\u3001\u56fe\u50cf\u548c\u516c\u5f0f\u90e8\u5206\u3002",
      confidence: "low",
      sourceNotes: [],
      safeNote: "\u5982\u679c\u8fd9\u4e2a\u95ee\u9898\u4ecd\u7136\u5b58\u5728\u7591\u60d1\uff0c\u5efa\u8bae\u7ed3\u5408\u8001\u5e08\u5f53\u5802\u8bb2\u89e3\u518d\u786e\u8ba4\u4e00\u6b21\u3002"
    });
  }
}