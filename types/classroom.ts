export type FeedbackType = "understand" | "too_fast" | "confused" | "clear_example";

export interface FeedbackItem {
  sessionId: string;
  studentId: string;
  topicId: string;
  feedbackType: FeedbackType;
  time: string;
}

export interface SessionState {
  sessionId: string;
  topicId: string;
  onlineStudents: string[];
  feedbackLog: Array<{
    studentId: string;
    feedbackType: FeedbackType;
    time: string;
  }>;
}

export interface AlertInfo {
  alertLevel: "low" | "medium" | "high";
  alertMessage: string;
  topicId: string;
}

export interface DashboardMetrics {
  onlineCount: number;
  feedbackCount: number;
  confusionRate: number;
  feedbackSummary: Record<string, number>;
  trendPoints: Array<{ time: string; value: number }>;
  currentWindowCount: number;
  lastWindowRate: number;
  rateDelta: number;
  alert: AlertInfo | null;
}

export interface PressureData {
  sessionId: string;
  homeworkSpeed: number;
  accuracyRate: number;
  moodWords: string[];
  weeklyTrend: number[];
  simplificationPack: {
    title: string;
    summary: string;
    actions: string[];
  };
}
