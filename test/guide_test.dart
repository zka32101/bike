import 'dart:io';

import 'package:bike_license_kore/models/guide_article.dart';
import 'package:bike_license_kore/views/guide_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('解説記事のデータが正しい（id重複なし・出典あり・公式の図のファイルが存在）', () {
    final ids = kGuideArticles.map((a) => a.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final a in kGuideArticles) {
      expect(a.title.trim(), isNotEmpty, reason: a.id);
      expect(a.sourceRef.trim(), isNotEmpty, reason: a.id);
      expect(a.sections, isNotEmpty, reason: a.id);
      for (final (file, _) in a.officialFigures) {
        expect(File('assets/guides/$file').existsSync(), isTrue, reason: file);
      }
    }
  });

  test('条文で確認した要点が記事に入っている', () {
    String body(String id) => kGuideArticles
        .firstWhere((a) => a.id == id)
        .sections
        .map((s) => s.body)
        .join('\n');
    // 標識令 別表第六: 追越しのための右側部分はみ出し通行禁止・駐停車禁止・駐車禁止の標示は黄
    expect(body('line_colors'), contains('黄色い線'));
    expect(body('line_colors'), contains('駐停車禁止'));
    // 道路交通法34条5項・教則: 30メートル手前で合図、車両通行帯3以上
    expect(body('two_stage_right_turn'), contains('30メートル'));
    expect(body('two_stage_right_turn'), contains('3以上'));
    // 教則: 路側帯の余地は0.75メートル以上
    expect(body('roadside_strips'), contains('0.75メートル'));
    // 道路交通法45条: 出入口3m・工事5m・消火栓5m・火災報知機1mは駐車禁止
    expect(body('no_parking_vs_no_stopping'), contains('火災報知機から1メートル以内'));
  });

  testWidgets('一覧から記事を開ける', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GuideListView()));
    expect(find.text('役立つ情報'), findsOneWidget);
    await tester.tap(find.text('二段階右折の条件と方法'));
    await tester.pumpAndSettle();
    expect(find.text('二段階右折のしかた'), findsOneWidget);
  });
}
