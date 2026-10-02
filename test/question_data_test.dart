import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 問題データ（assets/questions/*.json）の品質ガード。
///
/// 区分ごとの出題プールは1ファイルなので、重複や構造の不備はファイル単位で検査する。
/// 出典・法令版（lawVersion）の欄はまだ無く、別途 yourwish_kentei の検証で扱う。

/// 問題文は同じだが正解が異なる、既知の曖昧な問題（人が判断するまで許容）。
/// 新しく増やさないこと。
const _knownAmbiguousPrompts = {
  '駐停車禁止場所として正しいものはどれか。',
  '駐車禁止場所として正しいものはどれか。',
  '原付での片手運転について。',
};

List<Map<String, dynamic>> _load(File f) =>
    (jsonDecode(f.readAsStringSync()) as List<dynamic>)
        .cast<Map<String, dynamic>>();

void main() {
  final files = Directory('assets/questions')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('問題ファイルが5区分ぶんある', () {
    expect(files, hasLength(5));
  });

  for (final file in files) {
    final name = file.uri.pathSegments.last;

    group(name, () {
      final questions = _load(file);

      test('id が重複しない', () {
        final ids = questions.map((q) => q['id'] as String).toList();
        expect(ids.toSet().length, ids.length);
      });

      test('構造が正しい（4択・正解が範囲内・解説あり・選択肢が重複しない）', () {
        for (final q in questions) {
          final id = q['id'];
          final choices = (q['choices'] as List<dynamic>).cast<String>();
          expect(choices, hasLength(4), reason: '$id');
          expect(q['answer'], inInclusiveRange(0, choices.length - 1),
              reason: '$id');
          expect((q['explanation'] as String).trim(), isNotEmpty,
              reason: '$id');
          expect(choices.map((c) => c.trim()).toSet().length, choices.length,
              reason: '$id の選択肢が重複');
        }
      });

      test('同じ問題（問題文と正解が同じ）が選択肢の並び違いで繰り返されない', () {
        final seen = <String, String>{};
        for (final q in questions) {
          final choices = (q['choices'] as List<dynamic>).cast<String>();
          final key =
              '${(q['questionText'] as String).trim()}|${choices[q['answer'] as int].trim()}';
          final prev = seen[key];
          expect(prev, isNull, reason: '${q['id']} は $prev と同じ問題');
          seen[key] = q['id'] as String;
        }
      });

      test('問題文が同じで正解が違う問題は、既知の曖昧な問題だけ', () {
        final byPrompt = <String, Set<String>>{};
        for (final q in questions) {
          final choices = (q['choices'] as List<dynamic>).cast<String>();
          byPrompt
              .putIfAbsent((q['questionText'] as String).trim(), () => {})
              .add(choices[q['answer'] as int].trim());
        }
        final ambiguous = [
          for (final e in byPrompt.entries)
            if (e.value.length > 1) e.key,
        ];
        expect(_knownAmbiguousPrompts.containsAll(ambiguous), isTrue,
            reason: '新しい曖昧な重複: $ambiguous');
      });
    });
  }
}
