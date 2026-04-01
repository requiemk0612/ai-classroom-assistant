import Link from "next/link";
import { PageShell } from "@/components/shared/page-shell";

const sections = [
  {
    title: "\u5b66\u751f\u4fa7",
    items: [
      { href: "/student/feedback", label: "\u5b66\u751f\u53cd\u9988", desc: "\u533f\u540d\u63d0\u4ea4\u542c\u61c2\u7a0b\u5ea6\u4e0e\u5370\u8c61\uff0c\u5b9e\u65f6\u540c\u6b65\u5230\u6559\u5e08\u7aef\u3002" },
      { href: "/student/ask", label: "\u8bfe\u5802\u95ee\u7b54", desc: "\u7ed3\u5408\u8bfe\u7a0b\u8d44\u6599\u751f\u6210\u7b54\u6848\uff0c\u5e76\u7ed9\u51fa\u5bf9\u5e94\u6765\u6e90\u811a\u6ce8\u3002" },
      { href: "/student/mindmap", label: "\u77e5\u8bc6\u5bfc\u56fe", desc: "\u67e5\u770b\u8001\u5e08\u4e0a\u4f20 PPT \u540e\u751f\u6210\u7684\u6458\u8981\u4e0e\u5bfc\u56fe\u3002" }
    ]
  },
  {
    title: "\u6559\u5e08\u4fa7",
    items: [
      { href: "/teacher/dashboard", label: "\u6559\u5e08\u4eea\u8868\u76d8", desc: "\u67e5\u770b\u5b9e\u65f6\u53cd\u9988\u3001\u56f0\u60d1\u8d8b\u52bf\u3001\u9884\u8b66\u4e0e\u6559\u5b66\u7b56\u7565\u3002" },
      { href: "/teacher/pressure", label: "\u538b\u529b\u611f\u77e5", desc: "\u57fa\u4e8e\u4f5c\u4e1a\u901f\u5ea6\u3001\u6b63\u786e\u7387\u548c\u60c5\u7eea\u8bcd\u8fdb\u884c\u7b80\u8981\u9884\u5224\u3002" },
      { href: "/teacher/mindmap", label: "PPT \u5bfc\u56fe", desc: "\u4e0a\u4f20 PPT \u6216\u76f4\u63a5\u5207\u6362\u8bfe\u7a0b\u540d\u79f0\uff0c\u751f\u6210\u6458\u8981\u4e0e\u5bfc\u56fe\u3002" }
    ]
  }
];

export default function HomePage() {
  return (
    <PageShell
      title="AI \u8bfe\u5802\u52a9\u6559 Demo"
      subtitle="\u8fd9\u4e2a\u6f14\u793a\u7248\u540c\u65f6\u8986\u76d6\u5b66\u751f\u53cd\u9988\u3001\u8bfe\u5802\u95ee\u7b54\u3001\u6559\u5e08\u4fa7\u9884\u8b66\u3001\u538b\u529b\u611f\u77e5\u4e0e PPT \u5bfc\u56fe\u4e09\u6761\u4e3b\u8981\u94fe\u8def\u3002"
    >
      <div className="grid gap-6 md:grid-cols-2">
        {sections.map((section) => (
          <div key={section.title} className="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200">
            <h2 className="text-xl font-semibold text-slate-900">{section.title}</h2>
            <div className="mt-4 grid gap-3">
              {section.items.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 transition hover:border-brand-500 hover:bg-brand-50"
                >
                  <div className="text-sm font-semibold text-slate-900">{item.label}</div>
                  <div className="mt-2 text-sm leading-6 text-slate-600">{item.desc}</div>
                </Link>
              ))}
            </div>
          </div>
        ))}
      </div>
    </PageShell>
  );
}