"use client";

import { useEffect, useState } from "react";
import type { PressureData } from "@/types/classroom";
import type { PressureResponse } from "@/types/api";
import { getJson } from "@/lib/api-client";

const sessionId = "demo_session_001";

function getWeatherHint(weather: string) {
  if (weather === "\u96f7\u66b4") return "\u9700\u8981\u660e\u786e\u51cf\u8f7b\u7b2c\u4e8c\u5929\u7684\u8bb2\u6388\u8d1f\u62c5\uff0c\u4f18\u5148\u7528\u56fe\u50cf\u548c\u5fae\u7ec3\u4e60\u7a33\u4f4f\u7406\u89e3\u3002";
  if (weather === "\u591a\u4e91") return "\u6574\u4f53\u6709\u4e00\u5b9a\u538b\u529b\uff0c\u5efa\u8bae\u7528\u7b80\u77ed\u590d\u4e60\u5e2e\u5b66\u751f\u628a\u601d\u8def\u4e32\u8d77\u6765\u3002";
  return "\u5f53\u524d\u72b6\u6001\u6bd4\u8f83\u5e73\u7a33\uff0c\u53ef\u4ee5\u4fdd\u6301\u6b63\u5e38\u6559\u5b66\u8282\u594f\u3002";
}

export function TeacherPressureClient({ initialData }: { initialData: PressureData }) {
  const [data, setData] = useState(initialData);
  const [pressureScore, setPressureScore] = useState((1 - initialData.homeworkSpeed + (1 - initialData.accuracyRate)) / 2);
  const [microStrategies, setMicroStrategies] = useState<string[]>([
    "\u53ef\u4ee5\u5148\u628a\u68af\u5ea6\u4e0e\u65b9\u5411\u5bfc\u6570\u7684\u5173\u7cfb\u7528\u4e00\u5f20\u56fe\u91cd\u65b0\u4e32\u4e00\u904d\u3002",
    "\u8865\u4e00\u4e2a\u7b80\u77ed\u4f8b\u9898\uff0c\u8ba9\u5b66\u751f\u533a\u5206\u201c\u65b9\u5411\u201d\u4e0e\u201c\u589e\u957f\u901f\u5ea6\u201d\u3002",
    "\u8bfe\u540e\u53d1\u4e00\u4e2a\u5fae\u7ec3\u4e60\uff0c\u5e2e\u5b66\u751f\u5de9\u56fa\u516c\u5f0f\u4e0e\u56fe\u50cf\u5173\u7cfb\u3002"
  ]);
  const [weather, setWeather] = useState("\u591a\u4e91");
  const [statusText, setStatusText] = useState("\u5f53\u524d\u5c55\u793a\u7684\u662f\u8fd1\u671f\u8bfe\u540e\u538b\u529b\u7b80\u62a5\u3002");

  useEffect(() => {
    let active = true;

    async function loadPressure() {
      try {
        const response = await getJson<PressureResponse>(`/api/pressure?sessionId=${sessionId}`);
        if (!active) {
          return;
        }
        setData(response);
        setPressureScore(response.pressureScore);
        setMicroStrategies(response.microStrategies);
        setWeather(response.weatherLevel);
        setStatusText("\u5df2\u540c\u6b65\u5230\u6700\u65b0\u538b\u529b\u611f\u77e5\u6570\u636e\u3002");
      } catch {
        if (active) {
          setStatusText("\u672a\u80fd\u5237\u65b0\u6700\u65b0\u6570\u636e\uff0c\u4ecd\u5728\u5c55\u793a\u672c\u5730\u793a\u4f8b\u7ed3\u679c\u3002");
        }
      }
    }

    void loadPressure();

    return () => {
      active = false;
    };
  }, []);

  return (
    <div className="grid gap-6">
      <div className="rounded-[28px] bg-white p-4 text-sm text-slate-600 shadow-sm ring-1 ring-slate-200">{statusText}</div>

      <div className="grid gap-6 md:grid-cols-4">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u538b\u529b\u6307\u6570"}</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{pressureScore.toFixed(2)}</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u5929\u6c14\u72b6\u6001"}</div>
          <div className="mt-2 text-4xl font-bold text-brand-600">{weather}</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u6b63\u786e\u7387"}</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{Math.round(data.accuracyRate * 100)}%</div>
        </div>
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm text-slate-500">{"\u4f5c\u4e1a\u8fdb\u5ea6"}</div>
          <div className="mt-2 text-4xl font-bold text-slate-900">{Math.round(data.homeworkSpeed * 100)}%</div>
        </div>
      </div>

      <div className="rounded-[28px] bg-white p-5 shadow-sm ring-1 ring-slate-200">
        <div className="text-sm text-slate-500">{"\u6559\u5b66\u89c2\u5bdf"}</div>
        <div className="mt-2 text-sm leading-6 text-slate-700">{getWeatherHint(weather)}</div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">{"\u60c5\u7eea\u5173\u952e\u8bcd"}</h2>
          <div className="mt-4 flex flex-wrap gap-3">
            {data.moodWords.map((item) => (
              <span key={item} className="rounded-full bg-slate-100 px-4 py-2 text-sm text-slate-700">
                {item}
              </span>
            ))}
          </div>

          <div className="mt-6">
            <h3 className="text-sm font-semibold text-slate-900">{"\u8fd1\u4e94\u6b21\u538b\u529b\u8d8b\u52bf"}</h3>
            <div className="mt-3 flex h-24 items-end gap-3 rounded-2xl bg-slate-50 px-4 py-4">
              {data.weeklyTrend.map((value, index) => (
                <div key={`${value}-${index}`} className="flex flex-1 flex-col items-center gap-2">
                  <div className="w-full rounded-full bg-brand-100" style={{ height: `${Math.max(14, Math.round(value * 100))}%` }} />
                  <div className="text-xs text-slate-500">{`\u7b2c${index + 1}\u6b21`}</div>
                </div>
              ))}
            </div>
          </div>

          <div className="mt-6">
            <h3 className="text-sm font-semibold text-slate-900">{"\u5fae\u7b56\u7565\u5efa\u8bae"}</h3>
            <ul className="mt-3 space-y-2 text-sm text-slate-700">
              {microStrategies.map((item) => (
                <li key={item} className="rounded-2xl bg-slate-50 px-4 py-3 leading-6">
                  {item}
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="rounded-[28px] bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-lg font-semibold text-slate-900">{"\u77e5\u8bc6\u7b80\u5316\u5305"}</h2>
          <div className="mt-4 rounded-2xl bg-slate-50 px-4 py-4">
            <div className="text-sm font-semibold text-slate-900">{data.simplificationPack.title}</div>
            <div className="mt-2 text-sm leading-6 text-slate-700">{data.simplificationPack.summary}</div>
            <ul className="mt-3 space-y-2 text-sm text-slate-700">
              {data.simplificationPack.actions.map((item) => (
                <li key={item} className="rounded-xl bg-white px-3 py-2">
                  {item}
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
