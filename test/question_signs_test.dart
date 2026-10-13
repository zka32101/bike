import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_license_kore/data/question_signs.dart';
import 'package:bike_license_kore/models/traffic_sign.dart';
import 'package:bike_license_kore/widgets/traffic_sign_painter.dart';

void main() {
  test('all signIds exist in kTrafficSigns', () {
    final ids = kTrafficSigns.map((s) => s.id).toSet();
    for (final e in kQuestionSigns.entries) {
      expect(ids.contains(e.value.signId), isTrue, reason: e.key);
    }
  });

  test('all questionIds exist in the question JSON', () {
    final ids = <String>{};
    for (final f in Directory('assets/questions').listSync()) {
      if (f is File && f.path.endsWith('.json')) {
        for (final q in jsonDecode(f.readAsStringSync()) as List) {
          ids.add((q as Map)['id'] as String);
        }
      }
    }
    for (final k in kQuestionSigns.keys) {
      expect(ids.contains(k), isTrue, reason: k);
    }
  });

  testWidgets('unknown id shows nothing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: QuestionSignView(questionId: 'zzz999'))));
    expect(find.byType(TrafficSignWidget), findsNothing);
  });

  testWidgets('registered id shows sign at 320px without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final id = kQuestionSigns.keys.first;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Column(children: [
      const Text('問題文'),
      QuestionSignView(questionId: id, size: 120),
    ]))));
    expect(find.byType(TrafficSignWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('explanationOnly hidden before answer, shown after',
      (tester) async {
    const m = {'x': QuestionSign('sign_stop', QSMode.explanationOnly)};
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: QuestionSignView(questionId: 'x', signs: m))));
    expect(find.byType(TrafficSignWidget), findsNothing);
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: QuestionSignView(questionId: 'x', signs: m, answered: true))));
    expect(find.byType(TrafficSignWidget), findsOneWidget);
  });

  test('補助標識(auxSignId)は501〜509の補助標識を指し、at146は駐車禁止＋8-20', () {
    final byId = {for (final s in kTrafficSigns) s.id: s};
    for (final e in kQuestionSigns.entries) {
      final a = e.value.auxSignId;
      if (a == null) continue;
      expect(byId[a], isNotNull, reason: e.key);
      expect(byId[a]!.shape, SignShape.auxPlate, reason: e.key);
    }
    final q = kQuestionSigns['at146']!;
    expect(q.signId, 'sign_no_parking');
    expect(byId[q.auxSignId]!.centerText, '8-20');
  });

  testWidgets('補助標識つきは本標識と補助板を縦に並べて出す', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Column(children: [
      QuestionSignView(questionId: 'at146', size: 120),
    ]))));
    expect(find.byType(TrafficSignWidget), findsNWidgets(2));
    final main = tester.getRect(find.byType(TrafficSignWidget).first);
    final aux = tester.getRect(
        find.descendant(of: find.byType(QuestionSignView), matching: find.byType(ClipRect)).first);
    expect(aux.top, greaterThan(main.bottom - 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('補助標識なしの問題は従来どおり1枚だけ', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: QuestionSignView(questionId: 'at030'))));
    expect(find.byType(TrafficSignWidget), findsOneWidget);
  });
}
