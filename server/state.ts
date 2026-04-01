import type { DashboardMetrics, FeedbackItem, SessionState } from "@/types/classroom";
import { buildDashboardMetrics } from "@/lib/threshold";
import { loadSessionState, saveSessionState } from "@/lib/file-store";
import { trimRepeatedFeedback } from "@/lib/anti-fake";

let cache: SessionState | null = null;

async function ensureState(): Promise<SessionState> {
  if (!cache) {
    cache = await loadSessionState();
  }
  return cache;
}

export async function addFeedback(item: FeedbackItem): Promise<void> {
  const state = await ensureState();
  if (!state.onlineStudents.includes(item.studentId)) {
    state.onlineStudents.push(item.studentId);
  }

  state.topicId = item.topicId;
  state.feedbackLog = trimRepeatedFeedback(state.feedbackLog, item.studentId, item.feedbackType, item.time);
  state.feedbackLog.push({
    studentId: item.studentId,
    feedbackType: item.feedbackType,
    time: item.time
  });
  cache = state;
  await saveSessionState(state);
}

export function getMetrics(): DashboardMetrics {
  if (!cache) {
    return {
      onlineCount: 0,
      feedbackCount: 0,
      confusionRate: 0,
      feedbackSummary: {},
      trendPoints: [],
      currentWindowCount: 0,
      lastWindowRate: 0,
      rateDelta: 0,
      alert: null
    };
  }

  return buildDashboardMetrics(cache);
}
