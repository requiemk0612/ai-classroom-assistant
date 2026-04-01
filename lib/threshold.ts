import type { AlertInfo, DashboardMetrics, FeedbackType, SessionState } from "@/types/classroom";

const feedbackKeys: FeedbackType[] = ["understand", "too_fast", "confused", "clear_example"];

function buildSummary(log: SessionState["feedbackLog"]) {
  return feedbackKeys.reduce<Record<string, number>>((acc, item) => {
    acc[item] = log.filter((entry) => entry.feedbackType === item).length;
    return acc;
  }, {});
}

function buildTrend(log: SessionState["feedbackLog"]) {
  return log.slice(-6).map((item) => ({
    time: item.time.slice(11, 16),
    value: item.feedbackType === "too_fast" || item.feedbackType === "confused" ? 1 : 0
  }));
}

function getConfusionRate(log: SessionState["feedbackLog"]): number {
  if (log.length === 0) {
    return 0;
  }

  const confusedCount = log.filter((item) => item.feedbackType === "too_fast" || item.feedbackType === "confused").length;
  return confusedCount / log.length;
}

function buildAlert(log: SessionState["feedbackLog"], topicId: string): AlertInfo | null {
  const now = Date.now();
  const currentWindow = log.filter((item) => now - new Date(item.time).getTime() <= 30000);
  const lastWindow = log.filter((item) => {
    const diff = now - new Date(item.time).getTime();
    return diff > 30000 && diff <= 60000;
  });
  const currentRate = getConfusionRate(currentWindow);
  const lastRate = getConfusionRate(lastWindow);

  if (currentWindow.length < 8 || currentRate < 0.3 || currentRate - lastRate < 0.1) {
    return null;
  }

  return {
    alertLevel: currentRate > 0.5 ? "high" : "medium",
    alertMessage: `\u5f53\u524d\u4e3b\u9898\u8fd1 30 \u79d2\u7ea6\u6709 ${Math.round(
      currentRate * 100
    )}% \u7684\u53cd\u9988\u663e\u793a\u5b66\u751f\u4ecd\u7136\u56f0\u60d1\uff0c\u5efa\u8bae\u8001\u5e08\u5148\u653e\u7f13\u8282\u594f\uff0c\u8865\u4e00\u4e2a\u76f4\u89c2\u4f8b\u5b50\u518d\u7ee7\u7eed\u3002`,
    topicId
  };
}

export function buildDashboardMetrics(session: SessionState): DashboardMetrics {
  const feedbackCount = session.feedbackLog.length;
  const confusedCount = session.feedbackLog.filter(
    (item) => item.feedbackType === "too_fast" || item.feedbackType === "confused"
  ).length;
  const confusionRate = feedbackCount === 0 ? 0 : confusedCount / feedbackCount;

  return {
    onlineCount: session.onlineStudents.length,
    feedbackCount,
    confusionRate,
    feedbackSummary: buildSummary(session.feedbackLog),
    trendPoints: buildTrend(session.feedbackLog),
    alert: buildAlert(session.feedbackLog, session.topicId)
  };
}