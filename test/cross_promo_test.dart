import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_core/cross_promo.dart';

import 'package:bike_license_kore/core/constants/app_ids.dart';

void main() {
  test('相互紹介の currentAppId は kUkalabAppIds と build.gradle.kts の applicationId に一致する', () {
    expect(isUkalabAppId(kBikeApplicationId), isTrue);
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, contains('applicationId = "$kBikeApplicationId"'));
  });

  testWidgets('掲載0件・Firebase未初期化でも例外なく何も表示しない', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('before'),
            UkalabCrossPromoSection(currentAppId: kBikeApplicationId),
            Text('after'),
          ],
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('他のアプリもチェック！'), findsNothing);
    expect(find.text('before'), findsOneWidget);
    expect(find.text('after'), findsOneWidget);
  });

  test('UkalabCrossPromo.init は Firebase 未設定でも例外を投げない', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await UkalabCrossPromo.init();
  });
}
