import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import 'cross_category_quiz.dart';

export 'cross_category_quiz.dart';

// ---------------------------------------------------------------------------
// 数字・距離クイズ
//
// trapNumberType が数値・距離に関する種類の問題だけを集め、区分横断で
// ランダムに10問出題する（アクセス権ルールは [CrossCategoryQuizController] 参照）。
//
// 【注意】問題データ（assets/questions/*.json）には `brakingDistance` や
// `licensePeriod` など、現行の [TrapNumberType] enum に存在しない値が含まれる。
// Question.fromJson はそれらを TrapNumberType.none に丸めてしまうため、
// enum だけで判定すると該当問題が漏れる。そこで同梱JSONの生の
// trapNumberType 文字列からも対象問題IDを抽出して判定している。
// ---------------------------------------------------------------------------

/// 数字・距離クイズの対象となる trapNumberType（JSON上の文字列値）。
const Set<String> numberQuizTrapTypes = {
  'speedLimit',
  'brakingDistance',
  'followingDistance',
  'loadLimit',
  'licensePeriod',
  'twoStageRightTurn',
};

/// 生の trapNumberType を読むための問題データアセット
/// （LocalDataService の区分→アセット対応と同じもの）。
const List<String> _questionAssets = [
  'assets/questions/gentsuki.json',
  'assets/questions/kogata_gentsuki_nirin.json',
  'assets/questions/futsuu_nirin.json',
  'assets/questions/ogata_nirin.json',
  'assets/questions/at_gentei.json',
];

/// 同梱JSON上で trapNumberType が [numberQuizTrapTypes] に該当する問題IDの集合。
final numberQuizQuestionIdsProvider = FutureProvider<Set<String>>((ref) async {
  final ids = <String>{};
  for (final asset in _questionAssets) {
    try {
      final raw = await rootBundle.loadString(asset);
      final list = jsonDecode(raw) as List;
      for (final e in list) {
        if (e is! Map<String, dynamic>) continue;
        final type = e['trapNumberType'];
        final id = e['id'];
        if (type is String && id is String && numberQuizTrapTypes.contains(type)) {
          ids.add(id);
        }
      }
    } catch (e) {
      debugPrint('Failed to read trapNumberType from $asset: $e');
    }
  }
  return ids;
});

class NumberQuizController extends CrossCategoryQuizController {
  @override
  Future<List<Question>> filterPool(List<Question> accessibleQuestions) async {
    Set<String> rawIds;
    try {
      rawIds = await ref.read(numberQuizQuestionIdsProvider.future);
    } catch (_) {
      rawIds = const {};
    }
    return accessibleQuestions
        .where(
          (q) =>
              numberQuizTrapTypes.contains(q.trapNumberType.name) ||
              rawIds.contains(q.id),
        )
        .toList();
  }
}

final numberQuizControllerProvider = AutoDisposeNotifierProvider<
    NumberQuizController, CrossCategoryQuizState>(NumberQuizController.new);
