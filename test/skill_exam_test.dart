import 'package:bike_license_kore/core/constants/license_category.dart';
import 'package:bike_license_kore/models/skill_exam_tip.dart';
import 'package:bike_license_kore/views/skill_exam_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Iterable<String> _texts(SkillExamTip t) sync* {
  yield t.title;
  yield t.summary;
  yield t.sourceRef;
  for (final s in t.sections) {
    yield s.heading;
    yield s.body;
  }
  for (final c in t.checklist) {
    yield c.text;
  }
}

void main() {
  test('データ: id重複なし・ai-draft・自作・内容あり', () {
    final ids = kSkillExamTips.map((t) => t.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final t in kSkillExamTips) {
      expect(t.contentStatus, 'ai-draft', reason: t.id);
      expect(t.source, 'original', reason: t.id);
      expect(t.sourceRef, contains('自作'), reason: t.id);
      expect(t.categories, isNotEmpty, reason: t.id);
      expect(t.sections, isNotEmpty, reason: t.id);
      expect(t.checklist, isNotEmpty, reason: t.id);
    }
  });

  test('データ: 禁止語が入っていない', () {
    const banned = ['公式', '本試験相当', '過去問', '合格保証'];
    for (final t in kSkillExamTips) {
      for (final s in _texts(t)) {
        for (final w in banned) {
          expect(s.contains(w), isFalse, reason: '${t.id}: $w');
        }
      }
    }
    for (final w in banned) {
      expect(kSkillExamDraftNotice.contains(w), isFalse);
      expect(kSkillExamFollowNotice.contains(w), isFalse);
    }
  });

  test('データ: 速度・距離・時間・点数などの数値断定が入っていない', () {
    final digit = RegExp(r'[0-9０-９]');
    final kanjiNumber = RegExp(r'[一二三四五六七八九十百千]+\s*(秒|分間|キロ|メートル|センチ|点|回|割|km|cm)');
    final unit = RegExp(r'(km/h|ｋｍ|メートル|センチ|キロ|減点|合格点|秒以内|cc)');
    for (final t in kSkillExamTips) {
      for (final s in _texts(t)) {
        expect(digit.hasMatch(s), isFalse, reason: '${t.id}: $s');
        expect(kanjiNumber.hasMatch(s), isFalse, reason: '${t.id}: $s');
        expect(unit.hasMatch(s), isFalse, reason: '${t.id}: $s');
      }
    }
  });

  test('区分の出し分け: 原付に一本橋・方向変換は出ない、クラッチ項目は原付/AT限定で出ない', () {
    final gen = skillExamTipsFor(LicenseCategory.gentsuki).map((t) => t.id);
    expect(gen, isNot(contains('ippon_bashi')));
    expect(gen, isNot(contains('houkou_tenkan')));
    expect(gen, contains('kyuu_seidou'));
    final futsuu = skillExamTipsFor(LicenseCategory.futsuuNirin).map((t) => t.id);
    expect(futsuu, containsAll(['ippon_bashi', 'slalom', 'kyuu_seidou', 's_crank', 'houkou_tenkan']));
    final kyuu = kSkillExamTips.firstWhere((t) => t.id == 'kyuu_seidou');
    expect(kyuu.sectionsFor(LicenseCategory.futsuuNirin).length,
        greaterThan(kyuu.sectionsFor(LicenseCategory.atGentei).length));
    expect(kyuu.checklistFor(LicenseCategory.ogataNirin).length,
        greaterThan(kyuu.checklistFor(LicenseCategory.gentsuki).length));
  });

  testWidgets('一覧: 注意書き表示と区分切り替え', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SkillExamListView()));
    expect(find.text(kSkillExamDraftNotice), findsOneWidget);
    expect(find.text('方向変換'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, '原付'));
    await tester.pump();
    expect(find.text('方向変換'), findsNothing);
    expect(find.text('急制動'), findsOneWidget);
  });

  testWidgets('詳細: チェックリストを操作できる', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: SkillExamListView()));
    await tester.tap(find.text('急制動'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(kSkillExamDraftNotice), findsOneWidget);
    expect(find.textContaining('練習チェックリスト（0/'), findsOneWidget);
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pump();
    expect(find.textContaining('練習チェックリスト（1/'), findsOneWidget);
  });
}
