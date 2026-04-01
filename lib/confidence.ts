export function getWeatherLevel(score: number): string {
  if (score >= 0.7) return "\u96f7\u66b4";
  if (score >= 0.45) return "\u591a\u4e91";
  return "\u6674\u5929";
}