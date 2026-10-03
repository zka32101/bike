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

/// 標識の外見（形・色・図柄）を文章で描写している問題文。標識の絵は標識クイズ
/// （コード描画）で出題するため、文章での描写は禁止。
/// scripts/remove_sign_description_questions.py と同じ判定。
final _signDescription = RegExp(
  r'(円形|三角形|四角形|長方形|正方形|菱形|ひし形)で'
  r'|円形の中'
  r'|[青赤黄白黒緑]地'
  r'|の絵'
  r'|Pマーク'
  r'|追越し禁止マーク',
);

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

      test('標識の問題で、外見（形・色・図柄）を文章で描写していない', () {
        for (final q in questions) {
          if (q['topicTag'] != 'signs') continue;
          expect(_signDescription.hasMatch(q['questionText'] as String), isFalse,
              reason: '${q['id']}: 標識の外見は標識クイズ(画像)で出題する');
        }
      });

      test('出典がある問題は、出典の確認日（lawVersion）も持つ', () {
        for (final q in questions) {
          final src = q['sourceRef'] as String?;
          if (src == null) continue;
          expect(src.trim(), isNotEmpty, reason: '${q['id']}');
          expect(src.contains('。'), isFalse, reason: '${q['id']} の出典は短い参照だけにする');
          expect(q['lawVersion'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
              reason: '${q['id']}');
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

  // 法令で確認した事実の回帰テスト（docs/question_review/README.md の「法令で確認した結果」）
  group('法令で確認した事実', () {
    final all = [for (final f in files) ..._load(f)];
    String correct(Map<String, dynamic> q) =>
        (q['choices'] as List<dynamic>)[q['answer'] as int] as String;

    test('二人乗り: 大型二輪でも、一般道路で「免許取得直後から条件なし」を正解にしない', () {
      for (final q in all) {
        final text = q['questionText'] as String;
        if (!text.contains('二人乗り')) continue;
        expect(correct(q), isNot(contains('免許取得直後から可能')), reason: '${q['id']}');
        expect(correct(q), isNot(contains('年齢・経験年数の条件なく')), reason: '${q['id']}');
      }
    });

    test('携帯電話: 「停止中でも禁止」を正解にしない（道路交通法71条5号の5は停止中を除く）', () {
      for (final q in all) {
        if (!(q['questionText'] as String).contains('携帯電話') &&
            !(q['questionText'] as String).contains('スマートフォン')) {
          continue;
        }
        expect(correct(q), isNot(contains('停止中でも禁止')), reason: '${q['id']}');
        expect(correct(q), isNot(contains('停止中でも一切')), reason: '${q['id']}');
        expect(correct(q), isNot(equals('完全禁止')), reason: '${q['id']}');
      }
    });

    test('125ccの二輪車は、最高出力4.0kW以下なら原付（新基準原付）。結論が変わる問題では250ccなどで出題する', () {
      const ids = {
        'kg005', 'kg120', 'kg121', 'kg136', 'kg137', 'kg145', 'kg155',
        'kg159', 'kg160', 'kg161', 'kg162', 'kg191',
      };
      for (final q in all) {
        if (!ids.contains(q['id'])) continue;
        final all125 = [
          q['questionText'] as String,
          ...(q['choices'] as List<dynamic>).cast<String>(),
        ].join();
        expect(all125, isNot(contains('125ccの二輪車')), reason: '${q['id']}');
      }
    });
  
    test('規制標識の説明に「赤地に白のバツ印」「黄色地」を書かない（規制標識(1)は白地・赤枠・青い記号）', () {
      for (final q in all) {
        if (q['topicTag'] != 'signs') continue;
        final e = q['explanation'] as String;
        if (e.contains('規制標識')) {
          expect(e, isNot(contains('赤地に白のバツ')), reason: '${q['id']}');
          expect(e, isNot(contains('黄色地')), reason: '${q['id']}');
        }
      }
    });

    test('駐停車禁止と駐車禁止: 出入口3m・工事区域5m・消火栓5m・火災報知機1mは駐車禁止（第45条）', () {
      for (final q in all) {
        final text = q['questionText'] as String;
        if (text.contains('駐停車が禁止') &&
            (text.contains('消火栓') || text.contains('火災報知機'))) {
          fail('${q['id']}: 第45条の場所は駐車禁止（駐停車禁止ではない）');
        }
      }
    });

    test('根拠が確認できず削除した問題が戻っていない（第4回確認）', () {
      const removed = {
        'f026', 'o044', 'g113', 'g061', 'o046', 'f042', 'g133', 'g098',
        'g090', 'f046', 'f055', 'f073', 'g134', 'g065', 'f083', 'g105',
        'f030', 'f025', 'kg235', 'f269', 'o210', 'g082', 'f047', 'o026',
      };
      final ids = all.map((q) => q['id'] as String).toSet();
      expect(ids.intersection(removed), isEmpty);
    });

    test('g059 は教則（下り坂のエンジンブレーキ）に沿い、出典がある', () {
      final q = all.firstWhere((q) => q['id'] == 'g059');
      expect(q['sourceRef'], contains('教則'));
      expect((q['choices'] as List)[q['answer'] as int] as String,
          contains('フットブレーキの使い過ぎ'));
    });

    test('出典のある問題は確認日も持つ。出典付きは900問以上（第5回確認）', () {
      final withSrc = all.where((q) => (q['sourceRef'] as String?)?.isNotEmpty ?? false).toList();
      expect(withSrc.length, greaterThanOrEqualTo(900));
      for (final q in withSrc) {
        expect(q['lawVersion'], isNotNull, reason: '${q['id']}');
      }
    });

    test('一般道路の法定最高速度: 60km/hは中央線・車両通行帯がある道路。ない道路は30km/h（施行令第11条）', () {
      final f225 = all.firstWhere((q) => q['id'] == 'f225');
      expect((f225['choices'] as List)[f225['answer'] as int], contains('30'));
      for (final id in ['at013', 'f201', 'kg159', 'o229']) {
        final q = all.firstWhere((q) => q['id'] == id);
        expect(q['questionText'], contains('中央線'), reason: id);
      }
    });

    test('大型・普通自動二輪車の夜間駐車灯火は施行令第18条第2項の対象外。誤った問題が戻っていない', () {
      final ids = all.map((q) => q['id'] as String).toSet();
      expect(ids.intersection({'at092', 'f288', 'kg149'}), isEmpty);
    });

    test('二輪の積載長は「乗車装置または積載装置の長さ+0.3m」。10分の1・10分の2ではない', () {
      final q = all.firstWhere((q) => q['id'] == 'f289');
      expect((q['choices'] as List)[q['answer'] as int], contains('0.3メートル'));
    });
  });
}
