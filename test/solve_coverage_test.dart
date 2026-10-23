import 'package:bike_license_kore/data/app_cert.dart';
import 'package:bike_license_kore/data/solve_coverage.dart';
import 'package:bike_license_kore/widgets/solve_coverage_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

Widget _wrap(Widget child, Brightness b) => MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: b,
        ),
      ),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('solveLevel', () {
    test('5段階の境界', () {
      expect(solveLevel(0, 40), SolveLevel.none);
      expect(solveLevel(1, 40), SolveLevel.low);
      expect(solveLevel(13, 39), SolveLevel.low); // ちょうど 1/3
      expect(solveLevel(14, 39), SolveLevel.mid);
      expect(solveLevel(26, 39), SolveLevel.mid); // ちょうど 2/3
      expect(solveLevel(27, 39), SolveLevel.high);
      expect(solveLevel(99, 100), SolveLevel.high);
      expect(solveLevel(100, 100), SolveLevel.complete);
    });
    test('総数0・範囲外は安全', () {
      expect(solveLevel(0, 0), SolveLevel.none);
      expect(solveLevel(5, 0), SolveLevel.none);
      expect(solveLevel(-1, 10), SolveLevel.none);
      expect(solveLevel(12, 10), SolveLevel.complete);
      expect(solveRatio(12, 10), 1);
    });
  });

  group('aggregateCoverage', () {
    test('重複・対象外IDは数えない', () {
      final c = aggregateCoverage(['a', 'b', 'c', 'c'], {'a', 'c', 'zzz'});
      expect(c.solved, 2);
      expect(c.total, 3);
      expect(c.label, '2/3問');
    });
    test('空', () {
      expect(aggregateCoverage(const [], {'a'}), SolveCoverage.empty);
    });
  });

  group('色導出', () {
    test('0%は無色（面の色のまま）、段階が上がるほど濃い', () {
      const surface = Color(0xFFFFFFFF);
      const cert = Color(0xFF3050A0);
      expect(coverageFill(cert, SolveLevel.none, surface), surface);
      var prev = 1.0;
      for (final l in SolveLevel.values) {
        final lum = coverageFill(cert, l, surface).computeLuminance();
        expect(lum, lessThanOrEqualTo(prev));
        prev = lum;
      }
    });
    test('文字コントラストは全段階・ライト/ダークで4.5以上', () {
      for (final b in Brightness.values) {
        final scheme = ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: b,
        );
        for (final l in SolveLevel.values) {
          final fill = coverageFill(scheme.primary, l, scheme.surface);
          final fg = coverageForeground(
            fill,
            onSurface: scheme.onSurface,
            surface: scheme.surface,
          );
          expect(_contrast(fg, fill), greaterThanOrEqualTo(4.5));
        }
      }
    });
    test('資格色はテーマ主色', () {
      final t = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red));
      expect(bikeCertColor(t), t.colorScheme.primary);
    });
  });

  group('SolveCoverageBadge', () {
    for (final b in Brightness.values) {
      testWidgets('0% ${b.name}', (tester) async {
        await tester.pumpWidget(_wrap(
          const SolveCoverageBadge(
            coverage: SolveCoverage(solved: 0, total: 40),
            name: '普通二輪',
          ),
          b,
        ));
        expect(find.text('0/40問'), findsOneWidget);
        expect(find.bySemanticsLabel('普通二輪、40問中0問解答済み、0パーセント'),
            findsOneWidget);
      });
      testWidgets('途中 ${b.name}', (tester) async {
        await tester.pumpWidget(_wrap(
          const SolveCoverageBadge(
            coverage: SolveCoverage(solved: 12, total: 40),
            name: '普通二輪',
          ),
          b,
        ));
        expect(find.text('12/40問'), findsOneWidget);
        expect(find.bySemanticsLabel('普通二輪、40問中12問解答済み、30パーセント'),
            findsOneWidget);
      });
      testWidgets('100% ${b.name}', (tester) async {
        await tester.pumpWidget(_wrap(
          const SolveCoverageBadge(
            coverage: SolveCoverage(solved: 40, total: 40),
            name: '大型二輪',
          ),
          b,
        ));
        expect(find.text('40/40問'), findsOneWidget);
        expect(find.bySemanticsLabel('大型二輪、40問中40問解答済み、100パーセント'),
            findsOneWidget);
      });
    }
  });
}
