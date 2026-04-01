import { NextResponse } from "next/server";
import { z } from "zod";
import { buildStrategyResponse } from "@/lib/strategy-engine";

const bodySchema = z.object({
  topicId: z.string().min(1),
  confusionRate: z.number().default(0),
  trendUp: z.boolean().default(false),
  feedbackSummary: z.record(z.number()).default({})
});

export async function POST(request: Request) {
  const body = bodySchema.parse(await request.json());
  const result = await buildStrategyResponse(body.topicId, body.confusionRate, {
    trendUp: body.trendUp,
    feedbackSummary: body.feedbackSummary
  });
  return NextResponse.json(result);
}