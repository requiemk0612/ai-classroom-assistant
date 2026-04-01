import { NextResponse } from "next/server";
import { z } from "zod";
import { canSendFeedback, trimRepeatedFeedback } from "@/lib/anti-fake";
import { loadSessionState, saveSessionState } from "@/lib/file-store";

const bodySchema = z.object({
  sessionId: z.string().min(1),
  studentId: z.string().min(1),
  topicId: z.string().min(1),
  feedbackType: z.enum(["understand", "too_fast", "confused", "clear_example"]),
  time: z.string().min(1)
});

export async function POST(request: Request) {
  const body = bodySchema.parse(await request.json());
  if (!canSendFeedback(body.sessionId, body.studentId)) {
    return NextResponse.json({ ok: false, message: "\u53cd\u9988\u53d1\u9001\u8fc7\u4e8e\u9891\u7e41\uff0c\u8bf7\u95f4\u9694 3 \u79d2\u540e\u518d\u8bd5\u3002" }, { status: 429 });
  }

  const session = await loadSessionState();
  if (session.sessionId !== body.sessionId) {
    return NextResponse.json({ ok: false, message: "\u672a\u627e\u5230\u5bf9\u5e94\u7684\u8bfe\u5802\u573a\u6b21\u3002" }, { status: 404 });
  }

  if (!session.onlineStudents.includes(body.studentId)) {
    session.onlineStudents.push(body.studentId);
  }
  session.topicId = body.topicId;
  session.feedbackLog = trimRepeatedFeedback(session.feedbackLog, body.studentId, body.feedbackType, body.time);
  session.feedbackLog.push({
    studentId: body.studentId,
    feedbackType: body.feedbackType,
    time: body.time
  });
  await saveSessionState(session);

  return NextResponse.json({ ok: true, message: "\u53cd\u9988\u5df2\u8bb0\u5f55\uff0c\u6559\u5e08\u7aef\u5c06\u540c\u6b65\u66f4\u65b0\u3002" });
}