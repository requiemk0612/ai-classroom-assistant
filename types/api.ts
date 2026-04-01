import type { DashboardMetrics, PressureData } from "@/types/classroom";
import type { MindMapData } from "@/types/mindmap";
import type { StrategyResponse } from "@/types/strategy";

export interface AskResult {
  answer: string;
  confidence: "high" | "medium" | "low";
  sourceNotes: Array<{
    sourceName: string;
    page: string;
    title: string;
  }>;
  safeNote: string;
}

export interface MetricsResponse extends DashboardMetrics {}
export interface PressureResponse extends PressureData {
  weatherLevel: string;
  microStrategies: string[];
}
export interface MindMapResponse extends MindMapData {}
export interface StrategyApiResponse extends StrategyResponse {}
