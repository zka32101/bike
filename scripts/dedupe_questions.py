#!/usr/bin/env python3
"""同一問題の重複（選択肢の並びだけ違う複製）を取り除く。

assets/questions/*.json を対象に、同じファイル内で
  - 問題文が同じ
  - 正解の文言が同じ
の問題を1つのグループとみなし、先頭の1問だけ残す。

次は触らない（人が判断する）:
  - 問題文は同じだが正解の文言が違う問題（「…として正しいものはどれか」のように
    問いが曖昧で、別々の事実を答えにしている可能性がある）

使い方:
  python scripts/dedupe_questions.py           # 確認のみ（書き換えない）
  python scripts/dedupe_questions.py --apply   # 書き換える
"""
import argparse
import collections
import glob
import json
import os
import sys

QUESTIONS_GLOB = os.path.join(
    os.path.dirname(__file__), '..', 'assets', 'questions', '*.json'
)


def correct_text(q):
    return q['choices'][q['answer']].strip()


def dedupe(questions):
    """(残す問題のリスト, 取り除く問題のリスト, 曖昧な重複グループ) を返す。"""
    groups = collections.defaultdict(list)
    for q in questions:
        groups[q['questionText'].strip()].append(q)

    drop_ids = set()
    ambiguous = []
    for prompt, members in groups.items():
        if len(members) < 2:
            continue
        if len({correct_text(m) for m in members}) > 1:
            ambiguous.append((prompt, members))
            continue
        for m in members[1:]:
            drop_ids.add(m['id'])

    kept = [q for q in questions if q['id'] not in drop_ids]
    dropped = [q for q in questions if q['id'] in drop_ids]
    return kept, dropped, ambiguous


def main():
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('--apply', action='store_true', help='ファイルを書き換える')
    args = parser.parse_args()

    total_dropped = 0
    for path in sorted(glob.glob(QUESTIONS_GLOB)):
        with open(path, encoding='utf-8') as fh:
            questions = json.load(fh)
        kept, dropped, ambiguous = dedupe(questions)
        total_dropped += len(dropped)
        name = os.path.basename(path)
        print(f'{name}: {len(questions)}問 → {len(kept)}問'
              f'（取り除く {len(dropped)}、曖昧な重複 {len(ambiguous)}グループは残す）')
        for prompt, members in ambiguous:
            ids = ', '.join(m['id'] for m in members)
            print(f'    要確認: {prompt[:40]} [{ids}]')
        if args.apply and dropped:
            with open(path, 'w', encoding='utf-8', newline='\n') as fh:
                json.dump(kept, fh, ensure_ascii=False, indent=2)
                fh.write('\n')

    print(f'合計 {total_dropped}問を取り除く' + ('（適用済み）' if args.apply else '（確認のみ）'))
    return 0


if __name__ == '__main__':
    sys.exit(main())
