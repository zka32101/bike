#!/usr/bin/env python3
"""標識の形・色を文章で説明して問う問題を取り除く。

対象: topicTag が signs で、問題文が標識の外見を文章で描写している問題。
  例）「円形で青地に白のPマークの『駐車可』の標識について、正しい説明はどれか。」

理由:
  - 標識の絵は「標識クイズ」（lib/models/traffic_sign.dart。コード描画の図）で出題する。
    外見を文章で説明する問題は不要で、説明が実際の標識とずれるリスクだけが残る。
    AI査読では 274 問中 112 問に事実誤りの疑いが付き、実際に「優先道路」「徐行」などで
    形・色の記述が誤っていた。
  - 標識の「意味」や「その場での行動」を問う問題（外見の描写なし）は取り除かない。

使い方:
  python scripts/remove_sign_description_questions.py           # 確認のみ
  python scripts/remove_sign_description_questions.py --apply   # 書き換える
"""
import argparse
import glob
import json
import os
import re
import sys

QUESTIONS_GLOB = os.path.join(
    os.path.dirname(__file__), '..', 'assets', 'questions', '*.json'
)

# 問題文での「形で」「色の地」「絵・Pマーク」といった外見の描写。
DESCRIPTION = re.compile(
    r'(円形|三角形|四角形|長方形|正方形|菱形|ひし形)で'  # 「円形で…」「逆三角形で…」
    r'|円形の中'
    r'|[青赤黄白黒緑]地'  # 青地・赤地・白地…
    r'|の絵'  # 「ラッパの絵」「バスの絵」
    r'|Pマーク'
    r'|追越し禁止マーク'
)


def is_description_question(q):
    return q.get('topicTag') == 'signs' and bool(DESCRIPTION.search(q['questionText']))


def main():
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('--apply', action='store_true', help='ファイルを書き換える')
    args = parser.parse_args()

    total = 0
    for path in sorted(glob.glob(QUESTIONS_GLOB)):
        with open(path, encoding='utf-8') as fh:
            questions = json.load(fh)
        kept = [q for q in questions if not is_description_question(q)]
        removed = len(questions) - len(kept)
        total += removed
        print(f'{os.path.basename(path)}: {len(questions)}問 → {len(kept)}問（取り除く {removed}）')
        if args.apply and removed:
            with open(path, 'w', encoding='utf-8', newline='\n') as fh:
                json.dump(kept, fh, ensure_ascii=False, indent=2)
                fh.write('\n')

    print(f'合計 {total}問を取り除く' + ('（適用済み）' if args.apply else '（確認のみ）'))
    return 0


if __name__ == '__main__':
    sys.exit(main())
