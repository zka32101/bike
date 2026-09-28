import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import 'cross_category_quiz.dart';

export 'cross_category_quiz.dart';

// ---------------------------------------------------------------------------
// ひっかけ問題専門クイズ
//
// 全免許区分の問題データから isTrapQuestion == true の問題だけを集め、
// 区分横断でランダムに10問出題する（アクセス権ルールは
// [CrossCategoryQuizController] 参照）。
// ---------------------------------------------------------------------------

class TrapQuizController extends CrossCategoryQuizController {
  @override
  Future<List<Question>> filterPool(List<Question> accessibleQuestions) async {
    return accessibleQuestions.where((q) => q.isTrapQuestion).toList();
  }
}

final trapQuizControllerProvider = AutoDisposeNotifierProvider<
    TrapQuizController, CrossCategoryQuizState>(TrapQuizController.new);
