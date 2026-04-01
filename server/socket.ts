import type { Server } from "socket.io";
import type { FeedbackItem } from "@/types/classroom";
import { canSendFeedback } from "@/lib/anti-fake";
import { buildStrategyResponse } from "@/lib/strategy-engine";
import { addFeedback, getMetrics } from "./state";

export function registerSocketHandlers(io: Server): void {
  io.on("connection", (socket) => {
    socket.on("feedback:send", async (payload: FeedbackItem) => {
      if (!payload?.studentId || !canSendFeedback(payload.studentId)) {
        socket.emit("feedback:rejected", { message: "\u53cd\u9988\u53d1\u9001\u8fc7\u4e8e\u9891\u7e41\uff0c\u8bf7\u7a0d\u540e\u518d\u8bd5\u3002" });
        return;
      }

      await addFeedback(payload);
      const metrics = getMetrics();
      io.emit("metrics:update", metrics);

      if (metrics.alert) {
        const strategy = await buildStrategyResponse(metrics.alert.topicId, metrics.confusionRate);
        io.emit("strategy:update", strategy);
      }
    });
  });
}