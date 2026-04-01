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
    return NextResponse.json({ ok: false, message: "\u53cd\u9988\u53d1\u9001\u8fc7\u4e8e\u9891\u7e41\uff0c\u8bf7\u7a0d\u540e\u518d\u8bd5\u3002" }, { status: 429 });
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

  return NextResponse.json({ ok: true, message: "\u53cd\u9988\u5df2\u8bb0\u5f55\u3002" });
}