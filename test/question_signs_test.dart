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
}
