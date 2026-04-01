export interface MindMapNode {
  id: string;
  data: { label: string };
  position: { x: number; y: number };
}

export interface MindMapEdge {
  id: string;
  source: string;
  target: string;
}

export interface MindMapData {
  topicId: string;
  courseName: string;
  summaryPoints: string[];
  nodes: MindMapNode[];
  edges: MindMapEdge[];
  sourceSlides: string[];
  updatedAt: string;
}
