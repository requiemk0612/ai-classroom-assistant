import type { MindMapData, MindMapNode, MindMapEdge } from "@/types/mindmap";

interface MindMapGroup {
  title: string;
  children: string[];
}

export function buildMindMapFromGroups(topicId: string, courseName: string, groups: MindMapGroup[]): MindMapData {
  const rootId = "root";
  const nodes: MindMapNode[] = [
    {
      id: rootId,
      data: { label: courseName },
      position: { x: 400, y: 40 }
    }
  ];
  const edges: MindMapEdge[] = [];
  const summaryPoints = groups.map((item) => item.title);

  groups.forEach((group, index) => {
    const nodeId = `node_${index + 1}`;
    const baseX = 120 + index * 180;
    nodes.push({
      id: nodeId,
      data: { label: group.title },
      position: { x: baseX, y: 200 }
    });
    edges.push({ id: `edge_${index + 1}`, source: rootId, target: nodeId });

    group.children.slice(0, 3).forEach((child, childIndex) => {
      const childId = `${nodeId}_child_${childIndex + 1}`;
      nodes.push({
        id: childId,
        data: { label: child },
        position: { x: baseX - 40 + childIndex * 110, y: 340 }
      });
      edges.push({ id: `${childId}_edge`, source: nodeId, target: childId });
    });
  });

  return {
    topicId,
    courseName,
    summaryPoints,
    nodes,
    edges,
    sourceSlides: [],
    updatedAt: new Date().toISOString()
  };
}

export function buildMindMapFromPoints(topicId: string, courseName: string, points: string[]): MindMapData {
  return buildMindMapFromGroups(
    topicId,
    courseName,
    points.map((point) => ({
      title: point,
      children: []
    }))
  );
}
