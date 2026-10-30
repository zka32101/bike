import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ukalab_core/ui.dart' show RelatedReadingsCard;

import '../data/chapter_readings.dart';
import '../models/question.dart';
import '../views/chapter_reading_view.dart';

/// 誤答のあと、その問題に関連する読み物があるときだけ、core の [RelatedReadingsCard] で
/// 「読み物でおさらい」を出す(誤答原因の選択欄は付かない単体カード)。
///
/// 関連する読み物が無い、または読み込めないときは何も出さない(出題の流れを止めない)。
/// 呼び出し側([AnswerResultOverlay] の `wrongAnswerExtra`)は不正解のときだけ表示する。
class BikeReadingFeedback extends ConsumerWidget {
  const BikeReadingFeedback({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(chapterReadingsProvider).valueOrNull;
    if (readings == null) return const SizedBox.shrink();
    final related = readingsFor(readings, question.id);
    if (related.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: RelatedReadingsCard(
        readings: related,
        isCorrect: false,
        onOpenReading: (r) => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => BikeReadingView(reading: r)),
        ),
      ),
    );
  }
}
