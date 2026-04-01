import JSZip from "jszip";

function decodeXmlText(text: string): string {
  return text
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'");
}

function extractSlideText(xmlText: string): string {
  const matches = Array.from(xmlText.matchAll(/<a:t[^>]*>([\s\S]*?)<\/a:t>/g));
  const texts = matches
    .map((item) => decodeXmlText(item[1] ?? "").trim())
    .filter(Boolean);

  return Array.from(new Set(texts)).join(" ");
}

export async function parsePpt(buffer: ArrayBuffer): Promise<string[]> {
  const zip = await JSZip.loadAsync(buffer);
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
    const text = extractSlideText(xmlText);
    if (text) {
      results.push(text);
    }
  }

  return results;
}
