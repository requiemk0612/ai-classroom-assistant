import { StudentMindMapClient } from "@/components/student/student-mindmap-client";
import { PageShell } from "@/components/shared/page-shell";
import { loadMindMapData } from "@/lib/file-store";

export default async function StudentMindMapPage() {
  const initialData = await loadMindMapData();

  return (
    <PageShell
      title={"\u5b66\u751f\u77e5\u8bc6\u5bfc\u56fe"}
      subtitle={"\u7528\u7b80\u660e\u6458\u8981\u548c\u5173\u952e\u8282\u70b9\u5e2e\u52a9\u5b66\u751f\u5feb\u901f\u56de\u987e\u672c\u8282\u8bfe\u5185\u5bb9\u3002"}
    >
      <StudentMindMapClient initialData={initialData} />
    </PageShell>
  );
}
