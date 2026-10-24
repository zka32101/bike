import 'package:bike_license_kore/l10n/generated/app_localizations.dart';
import 'package:bike_license_kore/models/question.dart';
import 'package:bike_license_kore/services/ad_gate_service.dart';
import 'package:bike_license_kore/viewmodels/providers.dart';
import 'package:bike_license_kore/views/trap_dojo_view.dart';
import 'package:bike_license_kore/widgets/trap_dojo_entry_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('導線から道場が開き、ボス戦コンテキストで広告停止、戻ると解除', (tester) async {
    final container = ProviderContainer(overrides: [
      questionsProvider.overrideWith((ref, query) async => <Question>[]),
    ]);
    addTearDown(container.dispose);
    final gate = container.read(adGateServiceProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ja'),
          home: const Scaffold(body: TrapDojoEntryCard(licenseCategory: 'moped')),
        ),
      ),
    );

    expect(find.byType(TrapDojoView), findsNothing);
    expect(gate.isAdAllowedNow, isTrue);

    await tester.tap(find.byType(TrapDojoEntryCard));
    await tester.pumpAndSettle();

    expect(find.byType(TrapDojoView), findsOneWidget);
    expect(gate.isAdAllowedNow, isFalse);

    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.pop();
    await tester.pumpAndSettle();
    expect(find.byType(TrapDojoView), findsNothing);
    expect(gate.isAdAllowedNow, isTrue);
  });
}
