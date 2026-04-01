import { TeacherMindMapClient } from "@/components/teacher/teacher-mindmap-client";
import { PageShell } from "@/components/shared/page-shell";
import { loadMindMapData } from "@/lib/file-store";

export default async function TeacherMindMapPage() {
  const initialData = await loadMindMapData();

  return (
    <PageShell
      title={"PPT \u6458\u8981\u4e0e\u5bfc\u56fe"}
      subtitle={"\u6559\u5e08\u53ef\u4ee5\u4e0a\u4f20 PPT\uff0c\u8ba9\u7cfb\u7edf\u751f\u6210\u6458\u8981\u3001\u5bfc\u56fe\u548c\u6765\u6e90\u9875\u9762\u63d0\u793a\u3002"}
    >
      <TeacherMindMapClient initialData={initialData} />
    </PageShell>
  );
}
