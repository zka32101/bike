import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ukalab_core/answer_feedback.dart' show AnswerFeedbackPanel;

import '../data/chapter_readings.dart';
import '../models/question.dart';
import '../views/chapter_reading_view.dart';

/// 誤答のあと、その問題に関連する読み物があるときだけ、`AnswerFeedbackPanel` で
/// 「読み物でおさらい」を出す(読み物(試作)のフラグ有効時だけ呼び出し側が置く)。
///
/// 関連する読み物が無い、または読み込めないときは何も出さない(出題の流れを止めない)。
/// 誤答の原因ラベルは、このアプリでは保存先が無いため記録しない。
class BikeReadingFeedback extends ConsumerWidget {
  const BikeReadingFeedback({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(chapterReadingsProvider).valueOrNull;
    if (readings == null) return const SizedBox.shrink();
    final related = readingsFor(readings, question.id);
    if (related.isEmpty) return const SizedBox.shrink();
    return AnswerFeedbackPanel(
      question: toCoreQuestion(question),
      selectedIndex: null,
      isCorrect: false,
      onCause: (_) {},
      relatedReadings: related,
      onOpenReading: (r) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => BikeReadingView(reading: r)),
      ),
    );
  }
}
