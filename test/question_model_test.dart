import 'package:bike_license_kore/models/question.dart';
import 'package:flutter_test/flutter_test.dart';

Question q({String? src, String? ver}) => Question.fromJson({
      'id': 'x',
      'licenseCategory': ['gentsuki'],
      'questionText': 'Q',
      'choices': ['a', 'b'],
      'answer': 0,
      'explanation': '解説',
      if (src != null) 'sourceRef': src,
      if (ver != null) 'lawVersion': ver,
    });

void main() {
  test('出典がなければ解説だけ', () {
    expect(q().displayExplanation, '解説');
    expect(q().toJson().containsKey('sourceRef'), isFalse);
  });

  test('出典があれば解説の後に出典と確認日を添える', () {
    final x = q(src: '道路交通法第71条の4', ver: '2026-10-02');
    expect(x.displayExplanation, '解説\n\n出典: 道路交通法第71条の4（2026-10-02 確認）');
    expect(x.toJson()['sourceRef'], '道路交通法第71条の4');
  });
}
