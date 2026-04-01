import type { StrategyItem, StrategyResponse, StrategyTopic } from "@/types/strategy";
import { runDeepSeekChat } from "@/lib/deepseek";
import { loadStrategyLibrary } from "@/lib/file-store";

function buildItems(topic: StrategyTopic): StrategyItem[] {
  return [
    {
      type: "analogy",
      title: "\u7ecf\u5178\u7c7b\u6bd4",
      text: topic.analogy[0] ?? "\u53ef\u4ee5\u5148\u7528\u4e00\u4e2a\u751f\u6d3b\u573a\u666f\u505a\u7c7b\u6bd4\uff0c\u5e2e\u5b66\u751f\u5feb\u901f\u627e\u5230\u6570\u5b66\u6982\u5ff5\u7684\u76f4\u89c2\u652f\u70b9\u3002"
    },
    {
      type: "visual",
      title: "\u53ef\u89c6\u5316\u52a8\u4f5c",
      text: topic.visual[0] ?? "\u5728\u9ed1\u677f\u6216\u6295\u5f71\u4e0a\u753b\u51fa\u5173\u952e\u56fe\u5f62\uff0c\u7528\u7ebf\u6761\u548c\u7bad\u5934\u8865\u8db3\u7a7a\u95f4\u5173\u7cfb\u3002"
    },
    {
      type: "quick_check",
      title: "\u5feb\u901f\u533f\u540d\u68c0\u6d4b",
      text: topic.quickCheck[0] ?? "\u7528\u4e00\u9053\u5c0f\u9898\u6216\u4e00\u4e2a\u5224\u65ad\u9898\uff0c\u5feb\u901f\u786e\u8ba4\u5b66\u751f\u662f\u5361\u5728\u5b9a\u4e49\u8fd8\u662f\u5361\u5728\u516c\u5f0f\u3002"
    }
  ];
}

export async function buildStrategyResponse(topicId: string, confusionRate: number): Promise<StrategyResponse> {
  const library = await loadStrategyLibrary();
  const topic = library.topics.find((item) => item.topicId === topicId) ?? library.topics[0];
  const localResponse: StrategyResponse = {
    alertLevel: confusionRate > 0.5 ? "high" : "medium",
    alertMessage: `\u5f53\u524d\u4e3b\u9898\u201c${topic.topicName}\u201d\u7684\u56f0\u60d1\u53cd\u9988\u6b63\u5728\u4e0a\u5347\uff0c\u5efa\u8bae\u8001\u5e08\u5148\u7a33\u4f4f\u8282\u594f\uff0c\u518d\u8865\u4e00\u4e2a\u76f4\u89c2\u89e3\u91ca\u548c\u5feb\u901f\u68c0\u6d4b\u3002`,
    strategies: buildItems(topic)
  };

  const aiText = await runDeepSeekChat(
    [
      {
        role: "system",
        content:
          "\u4f60\u662f\u8bfe\u5802\u6559\u5b66\u7b56\u7565\u52a9\u624b\u3002\u8bf7\u6839\u636e\u7ed9\u5b9a\u7684\u8bfe\u5802\u4e3b\u9898\u548c\u56f0\u60d1\u7387\uff0c\u8fd4\u56de JSON\uff0c\u5b57\u6bb5\u4e3a alertMessage \u548c strategies\u3002strategies \u957f\u5ea6\u56fa\u5b9a\u4e3a 3\uff0c\u6bcf\u4e2a\u5143\u7d20\u5305\u542b title \u548c text\uff0c\u5168\u90e8\u4f7f\u7528\u4e2d\u6587\uff0c\u8bed\u6c14\u81ea\u7136\uff0c\u4e0d\u8981\u8131\u79bb\u63d0\u4f9b\u7684\u672c\u5730\u7b56\u7565\u3002"
      },
      {
        role: "user",
        content: JSON.stringify({
          topicName: topic.topicName,
          confusionRate,
          keyPoints: topic.keyPoints,
          strategies: localResponse.strategies
        })
      }
    ],
    { jsonMode: true, maxTokens: 500 }
  );

  if (!aiText) {
    return localResponse;
  }

  try {
    const parsed = JSON.parse(aiText) as {
      alertMessage?: string;
      strategies?: Array<{ title?: string; text?: string }>;
    };

    return {
      alertLevel: localResponse.alertLevel,
      alertMessage: parsed.alertMessage || localResponse.alertMessage,
      strategies:
        parsed.strategies?.slice(0, 3).map((item, index) => ({
          type: localResponse.strategies[index]?.type ?? "analogy",
          title: item.title || localResponse.strategies[index]?.title || "\u6559\u5b66\u7b56\u7565",
          text: item.text || localResponse.strategies[index]?.text || "\u5efa\u8bae\u8001\u5e08\u5148\u7528\u4e00\u4e2a\u76f4\u89c2\u4f8b\u5b50\u7a33\u4f4f\u7406\u89e3\u3002"
        })) ?? localResponse.strategies
    };
  } catch {
    return localResponse;
  }
}