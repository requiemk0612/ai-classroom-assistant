import { promises as fs } from "fs";
import path from "path";
import type { SessionState, PressureData } from "@/types/classroom";
import type { MindMapData } from "@/types/mindmap";
import type { StrategyLibrary } from "@/types/strategy";

interface CourseMaterialChunk {
  chunkId: string;
  topicId: string;
  title: string;
  content: string;
  sourceName: string;
  page: string;
  keywords: string[];
}

interface CourseMaterialData {
  chunks: CourseMaterialChunk[];
}

const dataDir = path.join(process.cwd(), "data");

async function readJsonFile<T>(fileName: string): Promise<T> {
  const filePath = path.join(dataDir, fileName);
  const content = await fs.readFile(filePath, "utf-8");
  const normalized = content.replace(/^\uFEFF/, "").replace(/\u0000/g, "");
  return JSON.parse(normalized) as T;
}

async function writeJsonFile<T>(fileName: string, data: T): Promise<void> {
  const filePath = path.join(dataDir, fileName);
  await fs.writeFile(filePath, JSON.stringify(data, null, 2), "utf-8");
}

export async function loadSessionState(): Promise<SessionState> {
  return readJsonFile<SessionState>("session-state.json");
}

export async function saveSessionState(data: SessionState): Promise<void> {
  return writeJsonFile("session-state.json", data);
}

export async function loadPressureData(): Promise<PressureData> {
  return readJsonFile<PressureData>("pressure-data.json");
}

export async function loadMindMapData(): Promise<MindMapData> {
  return readJsonFile<MindMapData>("mindmap-data.json");
}

export async function saveMindMapData(data: MindMapData): Promise<void> {
  return writeJsonFile("mindmap-data.json", data);
}

export async function loadStrategyLibrary(): Promise<StrategyLibrary> {
  return readJsonFile<StrategyLibrary>("strategy-library.json");
}

export async function loadCourseMaterials(): Promise<CourseMaterialData> {
  return readJsonFile<CourseMaterialData>("course-materials.json");
}
