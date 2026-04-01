import { NextResponse } from "next/server";
import { loadPressureData } from "@/lib/file-store";
import { getWeatherLevel } from "@/lib/confidence";

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const sessionId = searchParams.get("sessionId");
  const data = await loadPressureData();
  const pressureScore = (1 - data.homeworkSpeed + (1 - data.accuracyRate)) / 2;

  if (sessionId && sessionId !== data.sessionId) {
    return NextResponse.json({ message: "\u672a\u627e\u5230\u5bf9\u5e94\u7684\u538b\u529b\u4f1a\u8bdd\u3002" }, { status: 404 });
  }

  return NextResponse.json({
    ...data,
    pressureScore,
    weatherLevel: getWeatherLevel(pressureScore),
    microStrategies: [
      "\u5efa\u8bae\u5148\u653e\u6162\u68af\u5ea6\u51e0\u4f55\u610f\u4e49\u7684\u63a8\u5bfc\u901f\u5ea6\u3002",
      "\u5efa\u8bae\u8865\u4e00\u5f20\u7b49\u9ad8\u7ebf\u56fe\u5e2e\u52a9\u5b66\u751f\u7406\u89e3\u65b9\u5411\u5173\u7cfb\u3002",
      "\u5efa\u8bae\u8bfe\u540e\u53d1\u4e00\u4e2a\u4e24\u9898\u5fae\u7ec3\u4e60\u5de9\u56fa\u65b9\u5411\u5bfc\u6570\u516c\u5f0f\u3002"
    ]
  });
}