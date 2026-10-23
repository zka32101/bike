import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Set<String> _keys(String path) {
  final map = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return map.keys.where((k) => !k.startsWith('@')).toSet();
}

void main() {
  test('app_ja.arb と app_en.arb のキー集合が一致する', () {
    final ja = _keys('lib/l10n/app_ja.arb');
    final en = _keys('lib/l10n/app_en.arb');
    expect(en.difference(ja), isEmpty, reason: 'en にだけあるキー');
    expect(ja.difference(en), isEmpty, reason: 'ja にだけあるキー');
  });

  test('対応言語は ja / en のみ', () {
    final arbs = Directory('lib/l10n')
        .listSync()
        .map((e) => e.path.split('/').last)
        .where((n) => n.endsWith('.arb'))
        .toSet();
    expect(arbs, {'app_ja.arb', 'app_en.arb'});
  });
}
