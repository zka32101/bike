#!/usr/bin/env python3
"""CI 回帰ガード。失敗件数がベースラインを超えたら exit 1。

  ci_guard.py tests   <flutter test --machine の出力(JSON行)> <baseline file>
  ci_guard.py analyze <flutter analyze の出力>                <baseline file>

ベースラインのルール: 失敗/エラー件数を減らしたら、同じPRでベースライン
ファイル(ci/*.txt)の数値も下げること。増やしてはいけない（超えたらCIが赤になる）。
"""
import json
import re
import sys


def baseline(path):
    return int(open(path).read().split()[0])


def count_test_failures(path):
    names, suites, test_suite, failed, done = {}, {}, {}, set(), 0
    for line in open(path, errors="replace"):
        line = line.strip()
        if not line.startswith("{"):
            continue
        try:
            ev = json.loads(line)
        except ValueError:
            continue
        if isinstance(ev, dict) and ev.get("type") == "suite":
            suites[ev["suite"]["id"]] = ev["suite"].get("path", "")
        elif isinstance(ev, dict) and ev.get("type") == "testStart":
            names[ev["test"]["id"]] = ev["test"].get("name", "")
            test_suite[ev["test"]["id"]] = ev["test"].get("suiteID")
        elif isinstance(ev, dict) and ev.get("type") == "testDone":
            if ev.get("hidden") and ev.get("result") == "success":
                continue
            done += 1
            if ev.get("result") in ("failure", "error") and not ev.get("skipped"):
                failed.add(ev["testID"])
    lines = sorted(
        f"{suites.get(test_suite.get(i)) or '(unknown file)'}: {names.get(i, '') or '(unknown test)'}"
        for i in failed
    )
    return len(failed), done, lines


def main():
    mode, log, base_path = sys.argv[1:4]
    base = baseline(base_path)
    if mode == "tests":
        n, done, failed_lines = count_test_failures(log)
        print(f"flutter test: 失敗 {n} 件 / 実行 {done} 件 (ベースライン {base})")
        if done == 0:
            print("::error::テスト結果を集計できません（テスト実行自体が失敗）")
            return 1
        if failed_lines:
            print("::group::失敗したテスト一覧")
            for ln in failed_lines:
                print(ln.replace("\n", " "))
            print("::endgroup::")
    else:
        n = len(re.findall(r"^\s*error\s+•", open(log, errors="replace").read(), re.M))
        print(f"flutter analyze: error {n} 件 (ベースライン {base})")
    if n > base:
        print(f"::error::{mode}: 失敗件数 {n} がベースライン {base} を超えました（回帰）")
        return 1
    if n < base:
        print(f"::notice::{mode}: {n} < ベースライン {base}。{base_path} を {n} に下げてください")
    return 0


if __name__ == "__main__":
    sys.exit(main())
