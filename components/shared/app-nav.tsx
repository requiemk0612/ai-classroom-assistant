"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const navGroups = [
  {
    title: "\u5b66\u751f\u7aef",
    items: [
      { href: "/student/feedback", label: "\u8bfe\u5802\u53cd\u9988" },
      { href: "/student/ask", label: "\u5b66\u751f\u95ee\u7b54" },
      { href: "/student/mindmap", label: "\u77e5\u8bc6\u5bfc\u56fe" }
    ]
  },
  {
    title: "\u6559\u5e08\u7aef",
    items: [
      { href: "/teacher/dashboard", label: "\u6559\u5e08\u4eea\u8868\u76d8" },
      { href: "/teacher/pressure", label: "\u538b\u529b\u611f\u77e5" },
      { href: "/teacher/mindmap", label: "PPT \u5bfc\u56fe" }
    ]
  }
];

export function AppNav() {
  const pathname = usePathname();

  return (
    <nav className="grid gap-4 md:grid-cols-2">
      {navGroups.map((group) => (
        <div key={group.title} className="rounded-3xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
          <div className="text-sm font-semibold text-slate-900">{group.title}</div>
          <div className="mt-3 flex flex-wrap gap-2">
            {group.items.map((item) => {
              const active = pathname === item.href;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`rounded-full px-4 py-2 text-sm font-medium transition ${
                    active ? "bg-brand-600 text-white shadow-sm" : "bg-slate-100 text-slate-700 hover:bg-brand-50 hover:text-brand-700"
                  }`}
                >
                  {item.label}
                </Link>
              );
            })}
          </div>
        </div>
      ))}
    </nav>
  );
}