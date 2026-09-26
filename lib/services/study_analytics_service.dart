import '../core/constants/license_category.dart';
import '../core/constants/question_topic.dart';
import '../models/analytics_snapshot.dart';
import '../models/question.dart';
import '../models/user_answer_log.dart';
import 'question_index.dart';

/// 学習分析を計算するサービス（pure & synchronous）
/// SharedPreferencesなし、Future なし、Riverpod依存なし。
abstract class StudyAnalyticsService {
  /// 回答ログから分析スナップショットを生成
  AnalyticsSnapshot aggregate({
    required String uid,
    required List<UserAnswerLog> logs,
    required QuestionIndex index,
    required DateTime now,
    int historyDays = 30,
  });
}

class DefaultStudyAnalyticsService implements StudyAnalyticsService {
  /// 閾値：信頼度のある分析には最低5回の試行が必要
  static const int minAttemptsForWeakArea = 5;

  /// 正答率が低い弱点の判定基準
  static const double weakAreaThreshold = 0.8;

  /// 返す弱点の最大数
  static const int maxWeakAreas = 5;

  /// サンプル問題の最大数
  static const int maxSampleQuestions = 20;

  @override
  AnalyticsSnapshot aggregate({
    required String uid,
    required List<UserAnswerLog> logs,
    required QuestionIndex index,
    required DateTime now,
    int historyDays = 30,
  }) {
    if (logs.isEmpty) {
      return AnalyticsSnapshot(
        uid: uid,
        generatedAt: now,
        sourceLogCount: 0,
        overall: AccuracyStat(attempts: 0, correctCount: 0),
        stages: [],
        categories: [],
        topics: [],
        weakAreas: [],
        recommendations: [],
        dailyHistory: [],
      );
    }

    // 累積統計とグループ化
    final byStage = <String, _StatAccumulator>{};
    final byCategory = <String, _StatAccumulator>{};
    final byTopic = <String, _StatAccumulator>{};
    final byTrapType = <TrapNumberType, _StatAccumulator>{};
    final byDifficulty = <int, _StatAccumulator>{};
    final byDay = <DateTime, _DailyAccumulator>{};
    final dailyQuestionSamples = <String, List<String>>{};

    int totalAttempts = 0;
    int totalCorrect = 0;
    int orphanCount = 0;

    // 単一パスで全ログを集計
    for (final log in logs) {
      totalAttempts++;
      if (log.isCorrect) totalCorrect++;

      final meta = index[log.questionId];
      if (meta == null) {
        orphanCount++;
        continue;
      }

      // ステージ別
      _addToAccumulator(byStage, meta.stageTag, log.isCorrect);
      if (!log.isCorrect) {
        dailyQuestionSamples
            .putIfAbsent('stage:${meta.stageTag}', () => [])
            .add(log.questionId);
      }

      // カテゴリ別（1つの問題が複数カテゴリに属する場合、全カテゴリにカウント）
      for (final category in meta.licenseCategory) {
        _addToAccumulator(byCategory, category, log.isCorrect);
        if (!log.isCorrect) {
          dailyQuestionSamples
              .putIfAbsent('category:$category', () => [])
              .add(log.questionId);
        }
      }

      // トピック（分野）別
      if (meta.topicTag != null && meta.topicTag!.isNotEmpty) {
        _addToAccumulator(byTopic, meta.topicTag!, log.isCorrect);
        if (!log.isCorrect) {
          dailyQuestionSamples
              .putIfAbsent('topic:${meta.topicTag}', () => [])
              .add(log.questionId);
        }
      }

      // トラップ問題の種別別
      if (meta.isTrapQuestion) {
        _addToAccumulator(byTrapType, meta.trapNumberType, log.isCorrect);
      }

      // 難易度別
      _addToAccumulator(byDifficulty, meta.difficulty, log.isCorrect);
      if (!log.isCorrect) {
        dailyQuestionSamples
            .putIfAbsent('difficulty:${meta.difficulty}', () => [])
            .add(log.questionId);
      }

      // 日別（timestampを日付に丸める）
      final dayKey = DateTime(
        log.answeredAt.year,
        log.answeredAt.month,
        log.answeredAt.day,
      );
      if (!byDay.containsKey(dayKey)) {
        byDay[dayKey] = _DailyAccumulator();
      }
      byDay[dayKey]!.attempts++;
      if (log.isCorrect) byDay[dayKey]!.correctCount++;

      // 弱点分析用のサンプル（トラップ種別ごと）
      if (meta.isTrapQuestion) {
        final key = 'trap:${meta.trapNumberType.name}';
        dailyQuestionSamples
            .putIfAbsent(key, () => [])
            .add(log.questionId);
      }
    }

    final overallAccuracy =
        totalAttempts == 0 ? 0.0 : totalCorrect / totalAttempts;

    // ステージパフォーマンスの構築
    final stages = byStage.entries
        .map((e) => StagePerformance(
          stageTag: e.key,
          stat: AccuracyStat(
            attempts: e.value.attempts,
            correctCount: e.value.correctCount,
          ),
        ))
        .toList();

    // カテゴリパフォーマンスの構築
    final categories = byCategory.entries
        .map((e) => CategoryPerformance(
          categoryId: e.key,
          stat: AccuracyStat(
            attempts: e.value.attempts,
            correctCount: e.value.correctCount,
          ),
        ))
        .toList();

    // トピック（分野）パフォーマンスの構築
    final topics = byTopic.entries
        .map((e) => CategoryPerformance(
          categoryId: e.key,
          stat: AccuracyStat(
            attempts: e.value.attempts,
            correctCount: e.value.correctCount,
          ),
        ))
        .toList();

    // 弱点の抽出（複数の角度から）
    final weakAreaCandidates = <WeakArea>[];

    // ステージ別の弱点
    for (final entry in byStage.entries) {
      final stat = entry.value;
      if (stat.attempts >= minAttemptsForWeakArea) {
        final accuracy = stat.correctCount / stat.attempts;
        if (accuracy < weakAreaThreshold) {
          final severity = _calculateSeverity(
            accuracy,
            stat.attempts,
            totalAttempts,
          );
          final key = 'stage:${entry.key}';
          weakAreaCandidates.add(WeakArea(
            kind: WeakAreaKind.stage,
            key: key,
            label: entry.key,
            stat: AccuracyStat(
              attempts: stat.attempts,
              correctCount: stat.correctCount,
            ),
            severity: severity,
            sampleQuestionIds: (dailyQuestionSamples[key] ?? [])
                .take(maxSampleQuestions)
                .toList(),
          ));
        }
      }
    }

    // カテゴリ別の弱点
    for (final entry in byCategory.entries) {
      final stat = entry.value;
      if (stat.attempts >= minAttemptsForWeakArea) {
        final accuracy = stat.correctCount / stat.attempts;
        if (accuracy < weakAreaThreshold) {
          final severity = _calculateSeverity(
            accuracy,
            stat.attempts,
            totalAttempts,
          );
          final key = 'category:${entry.key}';
          weakAreaCandidates.add(WeakArea(
            kind: WeakAreaKind.category,
            key: key,
            label: LicenseCategory.fromId(entry.key).label,
            stat: AccuracyStat(
              attempts: stat.attempts,
              correctCount: stat.correctCount,
            ),
            severity: severity,
            sampleQuestionIds: (dailyQuestionSamples[key] ?? [])
                .take(maxSampleQuestions)
                .toList(),
          ));
        }
      }
    }

    // トピック（分野）別の弱点
    for (final entry in byTopic.entries) {
      final stat = entry.value;
      if (stat.attempts >= minAttemptsForWeakArea) {
        final accuracy = stat.correctCount / stat.attempts;
        if (accuracy < weakAreaThreshold) {
          final severity = _calculateSeverity(
            accuracy,
            stat.attempts,
            totalAttempts,
          );
          final key = 'topic:${entry.key}';
          weakAreaCandidates.add(WeakArea(
            kind: WeakAreaKind.topic,
            key: key,
            label: QuestionTopic.labelFor(entry.key),
            stat: AccuracyStat(
              attempts: stat.attempts,
              correctCount: stat.correctCount,
            ),
            severity: severity,
            sampleQuestionIds: (dailyQuestionSamples[key] ?? [])
                .take(maxSampleQuestions)
                .toList(),
          ));
        }
      }
    }

    // トラップ種別の弱点
    for (final entry in byTrapType.entries) {
      final stat = entry.value;
      if (stat.attempts >= minAttemptsForWeakArea) {
        final accuracy = stat.correctCount / stat.attempts;
        if (accuracy < weakAreaThreshold) {
          final severity = _calculateSeverity(
            accuracy,
            stat.attempts,
            totalAttempts,
          );
          final label = _trapTypeLabel(entry.key);
          final key = 'trap:${entry.key.name}';
          weakAreaCandidates.add(WeakArea(
            kind: WeakAreaKind.trapType,
            key: key,
            label: label,
            stat: AccuracyStat(
              attempts: stat.attempts,
              correctCount: stat.correctCount,
            ),
            severity: severity,
            sampleQuestionIds: (dailyQuestionSamples[key] ?? [])
                .take(maxSampleQuestions)
                .toList(),
          ));
        }
      }
    }

    // 難易度別の弱点
    for (final entry in byDifficulty.entries) {
      final stat = entry.value;
      if (stat.attempts >= minAttemptsForWeakArea) {
        final accuracy = stat.correctCount / stat.attempts;
        if (accuracy < weakAreaThreshold) {
          final severity = _calculateSeverity(
            accuracy,
            stat.attempts,
            totalAttempts,
          );
          final key = 'difficulty:${entry.key}';
          weakAreaCandidates.add(WeakArea(
            kind: WeakAreaKind.difficulty,
            key: key,
            label: '難易度${entry.key}',
            stat: AccuracyStat(
              attempts: stat.attempts,
              correctCount: stat.correctCount,
            ),
            severity: severity,
            sampleQuestionIds: (dailyQuestionSamples[key] ?? [])
                .take(maxSampleQuestions)
                .toList(),
          ));
        }
      }
    }

    // 重大度でソート、上位を抽出
    weakAreaCandidates.sort((a, b) => b.severity.compareTo(a.severity));
    final weakAreas = weakAreaCandidates.take(maxWeakAreas).toList();

    // 復習推奨の生成
    final recommendations = _generateRecommendations(weakAreas);

    // 日別履歴の構築（日付の昇順、最近のhistoryDaysのみ）
    final cutoffDate = now.subtract(Duration(days: historyDays));
    final dailyHistory = byDay.entries
        .where((e) => e.key.isAfter(cutoffDate))
        .map((e) => DailyPerformancePoint(
          date: e.key,
          attempts: e.value.attempts,
          correctCount: e.value.correctCount,
        ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return AnalyticsSnapshot(
      uid: uid,
      generatedAt: now,
      sourceLogCount: logs.length,
      overall: AccuracyStat(
        attempts: totalAttempts,
        correctCount: totalCorrect,
      ),
      stages: stages,
      categories: categories,
      topics: topics,
      weakAreas: weakAreas,
      recommendations: recommendations,
      dailyHistory: dailyHistory,
      orphanLogCount: orphanCount,
    );
  }

  /// 重大度スコアを計算
  /// severity = (1 - accuracy) * confidence * volumeWeight
  double _calculateSeverity(
    double accuracy,
    int attempts,
    int totalAttempts,
  ) {
    final gapFromTarget = 1.0 - accuracy; // 0.8（弱点境界）から0.0（完璧）までの距離
    final confidence = (attempts / AccuracyStat.minReliableAttempts).clamp(0.0, 1.0);
    final volumeWeight =
        (attempts / (totalAttempts == 0 ? 1 : totalAttempts) * 5)
            .clamp(0.0, 1.0);
    return gapFromTarget * confidence * volumeWeight;
  }

  /// 復習推奨を生成
  List<ReviewRecommendation> _generateRecommendations(
    List<WeakArea> weakAreas,
  ) {
    final recommendations = <ReviewRecommendation>[];
    for (final area in weakAreas) {
      // カテゴリ別（区分別）は「全区分の全問題」しか導線がなく、押しても
      // 弱点の復習にならないため復習推奨のボタン自体を出さない。
      if (area.kind == WeakAreaKind.category) continue;

      // 実際に間違えた問題のサンプルが取れていない場合、押しても復習する
      // 対象が無く「全問出るだけ」になってしまうため推奨自体を出さない。
      if (area.sampleQuestionIds.isEmpty) continue;

      late String title;
      late String body;

      switch (area.kind) {
        case WeakAreaKind.trapType:
          title = '${area.label}を克服する';
          body = '${area.label}に関する、実際に間違えた問題だけを復習します。';
          break;
        case WeakAreaKind.stage:
          title = '${area.label}を集中練習';
          body = '${area.label}で間違えた問題だけを集中的に復習します。';
          break;
        case WeakAreaKind.difficulty:
          title = '難問への対応力を強化';
          body = '間違えた難問だけをピンポイントで復習します。';
          break;
        case WeakAreaKind.topic:
          title = '${area.label}を復習';
          body = '${area.label}で間違えた問題だけを復習します。';
          break;
        case WeakAreaKind.category:
          continue; // 上でスキップ済み（到達しない）
      }

      recommendations.add(ReviewRecommendation(
        weakAreaKey: area.key,
        title: title,
        body: body,
        action: ReviewActionType.targetedReview,
        payload: {'weakAreaKind': area.kind.name},
        sampleQuestionIds: area.sampleQuestionIds,
      ));
    }
    return recommendations;
  }

  /// トラップ問題の種別をラベルに変換
  String _trapTypeLabel(TrapNumberType type) {
    switch (type) {
      case TrapNumberType.none:
        return 'その他のひっかけ';
      case TrapNumberType.twoPersonRiding:
        return '二人乗り条件';
      case TrapNumberType.loadLimit:
        return '積載制限';
      case TrapNumberType.twoStageRightTurn:
        return '二段階右折';
      case TrapNumberType.speedLimit:
        return '速度制限';
      case TrapNumberType.followingDistance:
        return '追従距離';
      case TrapNumberType.other:
        return 'その他のひっかけ';
    }
  }

  /// 統計値を累積に追加するヘルパーメソッド
  void _addToAccumulator<K>(
    Map<K, _StatAccumulator> accumulators,
    K key,
    bool isCorrect,
  ) {
    accumulators.putIfAbsent(key, () => _StatAccumulator());
    accumulators[key]!.attempts++;
    if (isCorrect) {
      accumulators[key]!.correctCount++;
    }
  }
}

/// 統計値の累積用ヘルパークラス
class _StatAccumulator {
  int attempts = 0;
  int correctCount = 0;
}

/// 日別統計の累積用ヘルパークラス
class _DailyAccumulator {
  int attempts = 0;
  int correctCount = 0;
}
