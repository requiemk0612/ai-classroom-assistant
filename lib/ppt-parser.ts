import JSZip from "jszip";
import { XMLParser } from "fast-xml-parser";

function collectText(value: unknown, bucket: string[]): void {
  if (!value) {
    return;
  }

  if (typeof value === "string") {
    const text = value.trim();
    if (text) {
      bucket.push(text);
    }
    return;
  }

  if (Array.isArray(value)) {
    value.forEach((item) => collectText(item, bucket));
    return;
  }

  if (typeof value === "object") {
    Object.entries(value).forEach(([key, item]) => {
      if (key === "#text") {
        collectText(item, bucket);
      } else {
        collectText(item, bucket);
      }
    });
  }
}

export async function parsePpt(buffer: ArrayBuffer): Promise<string[]> {
  const zip = await JSZip.loadAsync(buffer);
  const parser = new XMLParser({ ignoreAttributes: false });
  const slides = Object.keys(zip.files)
    .filter((name) => name.startsWith("ppt/slides/slide") && name.endsWith(".xml"))
    .sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));

  const results: string[] = [];

  for (const slideName of slides) {
    const slideFile = zip.files[slideName];
    if (!slideFile) {
      continue;
    }
    const xmlText = await slideFile.async("text");
    const xml = parser.parse(xmlText);
    const texts: string[] = [];
    collectText(xml, texts);
    results.push(texts.join(" "));
  }

  return results;
}
