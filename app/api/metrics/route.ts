import { NextResponse } from "next/server";
import { buildDashboardMetrics } from "@/lib/threshold";
import { loadSessionState } from "@/lib/file-store";

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const sessionId = searchParams.get("sessionId");
  const session = await loadSessionState();

  if (sessionId && sessionId !== session.sessionId) {
    return NextResponse.json({ message: "\u672a\u627e\u5230\u5bf9\u5e94\u8bfe\u5802\u573a\u6b21\u3002" }, { status: 404 });
  }

  return NextResponse.json(buildDashboardMetrics(session));
}