import type { FeedbackType, SessionState } from "@/types/classroom";

const studentCooldown = new Map<string, number>();
const repeatWindowMs = 30000;

function getKey(sessionId: string, studentId: string) {
  return `${sessionId}:${studentId}`;
}

export function canSendFeedback(sessionId: string, studentId: string): boolean {
  if (!sessionId || !studentId) {
    return false;
  }

  const now = Date.now();
  const key = getKey(sessionId, studentId);
  const lastTime = studentCooldown.get(key) ?? 0;
  if (now - lastTime < 3000) {
    return false;
  }

  studentCooldown.set(key, now);
  return true;
}

export function trimRepeatedFeedback(
  log: SessionState["feedbackLog"],
  studentId: string,
  feedbackType: FeedbackType,
  time: string
) {
  const currentTime = new Date(time).getTime();
  return log.filter((item) => {
    if (item.studentId !== studentId || item.feedbackType !== feedbackType) {
      return true;
    }

    return currentTime - new Date(item.time).getTime() > repeatWindowMs;
  });
}