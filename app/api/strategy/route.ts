import { NextResponse } from "next/server";
import { z } from "zod";
import { buildStrategyResponse } from "@/lib/strategy-engine";

const bodySchema = z.object({
  topicId: z.string(),
  confusionRate: z.number().default(0)
});

export async function POST(request: Request) {
  const body = bodySchema.parse(await request.json());
  const result = await buildStrategyResponse(body.topicId, body.confusionRate);
  return NextResponse.json(result);
}