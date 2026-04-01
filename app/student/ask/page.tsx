import { PageShell } from "@/components/shared/page-shell";
import { StudentAskClient } from "@/components/student/student-ask-client";

export default function StudentAskPage() {
  return (
    <PageShell title={"\u5b66\u751f\u95ee\u7b54"} subtitle={"\u5b66\u751f\u7aef\u7f51\u9875\uff1a\u57fa\u4e8e\u8bfe\u7a0b\u8d44\u6599\u8fdb\u884c\u5b89\u5168\u95ee\u7b54\uff0c\u8fd4\u56de\u7b54\u6848\u4e0e\u6765\u6e90\u6ce8\u8bb0\u3002"}>
      <StudentAskClient />
    </PageShell>
  );
}
