import 'package:bike_license_kore/core/constants/license_category.dart';
import 'package:bike_license_kore/models/bike_zukan_entry.dart';
import 'package:bike_license_kore/views/bike_zukan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _banned = [
  '公式', '本試験相当', '過去問', '合格保証',
  // 実在メーカー・車種名の混入チェック（簡易ブロックリスト）
  'ホンダ', 'ヤマハ', 'スズキ', 'カワサキ', 'Honda', 'Yamaha', 'Suzuki', 'Kawasaki',
  'ドゥカティ', 'ハーレー', 'トライアンフ', 'ベスパ', 'BMW', 'KTM',
  'カブ', 'レブル', 'ニンジャ', 'Ninja', 'ゼファー', 'ジクサー', 'PCX', 'NMAX', 'CBR', 'GSX',
];

String _all(BikeZukanEntry e) => [
      e.name, e.type, e.feel, e.suitedFor, e.beforeRiding, e.sourceRef, e.unlockHint,
    ].join('\n');

void main() {
  test('データはai-draft・自作で、禁止語と実在名を含まない', () {
    final ids = kBikeZukanEntries.map((e) => e.id).toSet();
    expect(ids.length, kBikeZukanEntries.length);
    for (final e in kBikeZukanEntries) {
      expect(e.contentStatus, 'ai-draft');
      expect(e.source, 'original');
      expect(e.sourceRef, contains('自作'));
      final t = _all(e);
      for (final w in _banned) {
        expect(t.contains(w), isFalse, reason: '${e.id}: $w');
      }
      // 実車の仕様に見える数値（出力・価格・燃費など）を書かない
      expect(RegExp(r'\d+\s*(ps|PS|kW|馬力|km/L|万円|円|kg)').hasMatch(t), isFalse,
          reason: e.id);
    }
    for (final w in _banned) {
      expect('$kZukanNotice$kZukanDisclaimer'.contains(w), isFalse, reason: w);
    }
    expect(kZukanNotice, contains('AI下書き'));
  });

  test('段階順・解放条件・割合計算', () {
    expect(kBikeZukanEntries.map((e) => e.stageIndex).toList(), [0, 1, 2, 3, 4]);
    final req = kBikeZukanEntries.map((e) => e.requiredCoverage).toList();
    expect(req, orderedEquals([...req]..sort()));
    expect(zukanCoverage(correctDistinct: 5, total: 0), 0);
    expect(zukanCoverage(correctDistinct: 5, total: 10), 0.5);
    expect(isZukanUnlocked(kBikeZukanEntries.first, 0.2), isTrue);
    expect(isZukanUnlocked(kBikeZukanEntries.first, 0.19), isFalse);
  });

  Future<void> pump(WidgetTester tester, Map<LicenseCategory, double> cov) async {
    tester.view.physicalSize = const Size(800, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: BikeZukanBody(coverageByCategory: cov)),
    ));
    await tester.pump();
  }

  testWidgets('未解放はロック表示と解放条件を出す', (tester) async {
    await pump(tester, const {});
    expect(find.text(kZukanNotice), findsOneWidget);
    expect(find.text('？？？'), findsNWidgets(5));
    expect(find.text('シティスクーター'), findsNothing);
    expect(find.textContaining('正解すると解放'), findsNWidgets(5));
    expect(find.text('解放 0 / 5'), findsOneWidget);
  });

  testWidgets('解放済みは紹介カードを出し、未解放はロックのまま', (tester) async {
    await pump(tester, const {LicenseCategory.gentsuki: 0.5});
    expect(find.text('シティスクーター'), findsOneWidget);
    expect(find.text('乗り味の特徴'), findsOneWidget);
    expect(find.text('向いている人'), findsOneWidget);
    expect(find.text('乗る前に知っておくこと'), findsOneWidget);
    expect(find.text('免許区分（目安）'), findsOneWidget);
    expect(find.text('？？？'), findsNWidgets(4));
    expect(find.text('解放 1 / 5'), findsOneWidget);
  });
}
