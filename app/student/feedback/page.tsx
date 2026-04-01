import { PageShell } from "@/components/shared/page-shell";
import { StudentFeedbackClient } from "@/components/student/student-feedback-client";

export default function StudentFeedbackPage() {
  return (
    <PageShell title={"\u8bfe\u5802\u5b9e\u65f6\u53cd\u9988"} subtitle={"\u5b66\u751f\u7aef\u7f51\u9875\uff1a\u533f\u540d\u53cd\u9988\u5f53\u524d\u542c\u8bfe\u72b6\u6001\uff0c\u5e2e\u52a9\u8001\u5e08\u53ca\u65f6\u8c03\u6574\u8bb2\u89e3\u8282\u594f\u3002"}>
      <StudentFeedbackClient />
    </PageShell>
  );
}
