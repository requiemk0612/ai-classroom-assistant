export interface StrategyTopic {
  topicId: string;
  topicName: string;
  analogy: string[];
  visual: string[];
  quickCheck: string[];
  keyPoints: string[];
}

export interface StrategyLibrary {
  topics: StrategyTopic[];
}

export interface StrategyItem {
  type: "analogy" | "visual" | "quick_check";
  title: string;
  text: string;
}

export interface StrategyResponse {
  alertLevel: "low" | "medium" | "high";
  alertMessage: string;
  strategies: StrategyItem[];
}
