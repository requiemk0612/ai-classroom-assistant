import Link from "next/link";
import type { ReactNode } from "react";
import { AppNav } from "@/components/shared/app-nav";

export function PageShell({ title, subtitle, children }: { title: string; subtitle: string; children: ReactNode }) {
  return (
    <main className="min-h-screen px-4 py-6 md:px-8">
      <div className="mx-auto flex max-w-6xl flex-col gap-6">
        <div className="rounded-3xl bg-white p-6 shadow-sm ring-1 ring-slate-200 md:p-8">
          <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
            <div className="max-w-3xl">
              <div className="inline-flex items-center rounded-full bg-brand-50 px-3 py-1 text-xs font-semibold text-brand-700">
                {"\u8bfe\u5802\u6f14\u793a\u7248"}
              </div>
              <div className="mt-4">
                <Link href="/" className="text-sm font-medium text-brand-600 transition hover:text-brand-700">
                  {"\u8fd4\u56de\u9996\u9875"}
                </Link>
              </div>
              <h1 className="mt-3 text-3xl font-bold tracking-tight text-slate-900 md:text-4xl">{title}</h1>
              <p className="mt-3 max-w-2xl text-sm leading-7 text-slate-600 md:text-base">{subtitle}</p>
            </div>
            <div className="rounded-3xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-600">
              {"\u6f14\u793a\u91cd\u70b9\uff1a\u5b9e\u65f6\u611f\u77e5\u3001\u6559\u5b66\u5efa\u8bae\u3001\u5b89\u5168\u95ee\u7b54\u3001PPT \u5bfc\u56fe"}
            </div>
          </div>
        </div>
        <AppNav />
        {children}
      </div>
    </main>
  );
}