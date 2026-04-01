import { PageShell } from "@/components/shared/page-shell";
import { TeacherPressureClient } from "@/components/teacher/teacher-pressure-client";
import { loadPressureData } from "@/lib/file-store";

export default async function TeacherPressurePage() {
  const initialData = await loadPressureData();

  return (
    <PageShell
      title="\u8bfe\u540e\u538b\u529b\u611f\u77e5"
      subtitle="\u57fa\u4e8e\u4f5c\u4e1a\u901f\u5ea6\u3001\u6b63\u786e\u7387\u548c\u60c5\u7eea\u8bcd\uff0c\u7ed9\u51fa\u4e00\u4e2a\u7b80\u8981\u7684\u6559\u5b66\u4ecb\u5165\u5efa\u8bae\u3002"
    >
      <TeacherPressureClient initialData={initialData} />
    </PageShell>
  );
}