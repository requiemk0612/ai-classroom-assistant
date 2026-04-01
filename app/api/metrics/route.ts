import { NextResponse } from "next/server";
import { buildDashboardMetrics } from "@/lib/threshold";
import { loadSessionState } from "@/lib/file-store";

export async function GET() {
  const session = await loadSessionState();
  return NextResponse.json(buildDashboardMetrics(session));
}
