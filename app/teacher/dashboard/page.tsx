import { PageShell } from "@/components/shared/page-shell";
import { TeacherDashboardClient } from "@/components/teacher/teacher-dashboard-client";
import { buildDashboardMetrics } from "@/lib/threshold";
import { loadSessionState } from "@/lib/file-store";

export default async function TeacherDashboardPage() {
  const session = await loadSessionState();
  const initialMetrics = buildDashboardMetrics(session);

  return (
    <PageShell title="\u6559\u5e08\u4eea\u8868\u76d8" subtitle="\u6559\u5e08\u7aef\u7f51\u9875\uff1a\u5b9e\u65f6\u67e5\u770b\u8bfe\u5802\u7406\u89e3\u72b6\u6001\uff0c\u9884\u8b66\u4fe1\u606f\u548c\u6559\u5b66\u7b56\u7565\u5efa\u8bae\u3002">
      <TeacherDashboardClient initialMetrics={initialMetrics} />
    </PageShell>
  );
}