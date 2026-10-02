import '../models/analytics_snapshot.dart';

/// 苦手分析で表示する分野。
///
/// [limit] が null（プレミアム）なら全分野をそのまま返す。無料のときは、
/// 回答のある分野のうち正答率の低い（苦手な）順に [limit] 件だけ返す。
List<CategoryPerformance> visibleTopics(
  List<CategoryPerformance> topics,
  int? limit,
) {
  if (limit == null) return topics;
  final answered = topics.where((t) => t.stat.attempts > 0).toList()
    ..sort((a, b) {
      final byAccuracy = a.stat.accuracy.compareTo(b.stat.accuracy);
      return byAccuracy != 0 ? byAccuracy : a.categoryId.compareTo(b.categoryId);
    });
  return answered.take(limit).toList();
}
