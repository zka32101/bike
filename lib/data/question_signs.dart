import 'package:flutter/material.dart';

import '../models/traffic_sign.dart';
import '../widgets/traffic_sign_painter.dart';

/// 標識の絵の出し方。
enum QSMode {
  /// 出題中から表示する。
  question,

  /// 解答後（結果・解説）だけ表示する。
  explanationOnly,
}

/// 問題と標識の対応。
class QuestionSign {
  const QuestionSign(this.signId, this.mode);

  /// [kTrafficSigns] の id。
  final String signId;
  final QSMode mode;
}

/// 問題ID → 標識の対応表。
///
/// 問題文に「『X』の標識」の形で標識名が1つだけ含まれ、X が [kTrafficSigns]
/// の標識と一意に対応するものだけを登録している。一覧は docs/question_signs_audit.md。
const Map<String, QuestionSign> kQuestionSigns = {
  'at030': QuestionSign('sign_stop', QSMode.question),
  'at118': QuestionSign('sign_no_motorcycles', QSMode.question),
  'at184': QuestionSign('sign_one_way', QSMode.question),
  'at222': QuestionSign('sign_stop', QSMode.question),
  'at301': QuestionSign('sign_slow', QSMode.question),
  'at303': QuestionSign('sign_pedestrian_crossing', QSMode.question),
  'at306': QuestionSign('sign_no_motorcycles', QSMode.question),
  'at307': QuestionSign('sign_parking_angled', QSMode.question),
  'at309': QuestionSign('sign_slippery', QSMode.question),
  'at310': QuestionSign('sign_safety_zone', QSMode.question),
  'at312': QuestionSign('sign_tram_track_ok', QSMode.question),
  'at313': QuestionSign('sign_min_speed_30', QSMode.question),
  'at316': QuestionSign('sign_roundabout_ahead', QSMode.question),
  'at318': QuestionSign('sign_motorway', QSMode.question),
  'at319': QuestionSign('sign_straight_only', QSMode.question),
  'at322': QuestionSign('sign_no_crossing_vehicles', QSMode.question),
  'at327': QuestionSign('sign_school_zone', QSMode.question),
  'at330': QuestionSign('sign_no_u_turn', QSMode.question),
  'at331': QuestionSign('sign_stop', QSMode.question),
  'at333': QuestionSign('sign_parking_right', QSMode.question),
  'at334': QuestionSign('sign_no_parking', QSMode.question),
  'at336': QuestionSign('sign_no_large_buses', QSMode.question),
  'at339': QuestionSign('sign_parking_parallel', QSMode.question),
  'at343': QuestionSign('sign_right_curve', QSMode.question),
  'at345': QuestionSign('sign_bicycle_crossing', QSMode.question),
  'at346': QuestionSign('sign_one_way', QSMode.question),
  'f283': QuestionSign('sign_no_parking', QSMode.question),
  'f284': QuestionSign('sign_no_stopping', QSMode.question),
  'f303': QuestionSign('sign_no_entry', QSMode.question),
  'f304': QuestionSign('sign_pedestrian_crossing', QSMode.question),
  'f306': QuestionSign('sign_no_u_turn', QSMode.question),
  'f307': QuestionSign('sign_no_stopping', QSMode.question),
  'f309': QuestionSign('sign_one_way', QSMode.question),
  'f315': QuestionSign('sign_parking_angled', QSMode.question),
  'f318': QuestionSign('sign_side_by_side_ok', QSMode.question),
  'f322': QuestionSign('sign_min_speed_30', QSMode.question),
  'f325': QuestionSign('sign_no_crossing_vehicles', QSMode.question),
  'f328': QuestionSign('sign_no_motorcycles', QSMode.question),
  'f330': QuestionSign('sign_priority_road', QSMode.question),
  'f331': QuestionSign('sign_school_zone', QSMode.question),
  'f334': QuestionSign('sign_stop_line', QSMode.question),
  'f336': QuestionSign('sign_no_large_buses', QSMode.question),
  'f337': QuestionSign('sign_right_curve', QSMode.question),
  'f343': QuestionSign('sign_bicycle_crossing', QSMode.question),
  'f345': QuestionSign('sign_bus_lane', QSMode.question),
  'f346': QuestionSign('sign_slippery', QSMode.question),
  'f349': QuestionSign('sign_no_pedestrians', QSMode.question),
  'g216': QuestionSign('sign_stop', QSMode.question),
  'g301': QuestionSign('sign_min_speed_30', QSMode.question),
  'g303': QuestionSign('sign_parking_right', QSMode.question),
  'g304': QuestionSign('sign_straight_only', QSMode.question),
  'g306': QuestionSign('sign_right_curve', QSMode.question),
  'g307': QuestionSign('sign_motorway', QSMode.question),
  'g309': QuestionSign('sign_one_way', QSMode.question),
  'g310': QuestionSign('sign_bus_lane', QSMode.question),
  'g312': QuestionSign('sign_parking_allowed', QSMode.question),
  'g315': QuestionSign('sign_pedestrian_crossing', QSMode.question),
  'g316': QuestionSign('sign_stop_line', QSMode.question),
  'g319': QuestionSign('sign_tram_track_ok', QSMode.question),
  'g322': QuestionSign('sign_parking_parallel', QSMode.question),
  'g324': QuestionSign('sign_slippery', QSMode.question),
  'g325': QuestionSign('sign_safety_zone', QSMode.question),
  'g327': QuestionSign('sign_no_pedestrians', QSMode.question),
  'g328': QuestionSign('sign_parking_angled', QSMode.question),
  'g331': QuestionSign('sign_railroad_crossing', QSMode.question),
  'g333': QuestionSign('sign_slow', QSMode.question),
  'g334': QuestionSign('sign_roundabout_ahead', QSMode.question),
  'g337': QuestionSign('sign_school_zone', QSMode.question),
  'g339': QuestionSign('sign_pedestrian_only', QSMode.question),
  'g342': QuestionSign('sign_side_by_side_ok', QSMode.question),
  'g348': QuestionSign('sign_no_entry', QSMode.question),
  'g349': QuestionSign('sign_no_crossing_vehicles', QSMode.question),
  'kg018': QuestionSign('sign_no_parking', QSMode.question),
  'kg020': QuestionSign('sign_stop', QSMode.question),
  'kg119': QuestionSign('sign_motorway', QSMode.question),
  'kg120': QuestionSign('sign_no_tandem', QSMode.question),
  'kg301': QuestionSign('sign_no_u_turn', QSMode.question),
  'kg303': QuestionSign('sign_safety_zone', QSMode.question),
  'kg306': QuestionSign('sign_straight_only', QSMode.question),
  'kg307': QuestionSign('sign_stop_line', QSMode.question),
  'kg309': QuestionSign('sign_bus_lane', QSMode.question),
  'kg310': QuestionSign('sign_no_stopping', QSMode.question),
  'kg313': QuestionSign('sign_no_parking', QSMode.question),
  'kg318': QuestionSign('sign_motorway', QSMode.question),
  'kg319': QuestionSign('sign_no_entry', QSMode.question),
  'kg322': QuestionSign('sign_school_zone', QSMode.question),
  'kg324': QuestionSign('sign_slippery', QSMode.question),
  'kg325': QuestionSign('sign_no_crossing_vehicles', QSMode.question),
  'kg327': QuestionSign('sign_no_pedestrians', QSMode.question),
  'kg328': QuestionSign('sign_parking_right', QSMode.question),
  'kg331': QuestionSign('sign_pedestrian_only', QSMode.question),
  'kg333': QuestionSign('sign_priority_road', QSMode.question),
  'kg334': QuestionSign('sign_pedestrian_crossing', QSMode.question),
  'kg336': QuestionSign('sign_stop', QSMode.question),
  'kg337': QuestionSign('sign_slow', QSMode.question),
  'kg339': QuestionSign('sign_roundabout_ahead', QSMode.question),
  'kg340': QuestionSign('sign_bicycle_crossing', QSMode.question),
  'kg342': QuestionSign('sign_parking_angled', QSMode.question),
  'kg343': QuestionSign('sign_right_curve', QSMode.question),
  'kg348': QuestionSign('sign_parking_parallel', QSMode.question),
  'o304': QuestionSign('sign_min_speed_30', QSMode.question),
  'o306': QuestionSign('sign_pedestrian_crossing', QSMode.question),
  'o307': QuestionSign('sign_side_by_side_ok', QSMode.question),
  'o309': QuestionSign('sign_no_large_buses', QSMode.question),
  'o310': QuestionSign('sign_straight_only', QSMode.question),
  'o313': QuestionSign('sign_parking_allowed', QSMode.question),
  'o315': QuestionSign('sign_roundabout_ahead', QSMode.question),
  'o316': QuestionSign('sign_slow', QSMode.question),
  'o319': QuestionSign('sign_right_curve', QSMode.question),
  'o321': QuestionSign('sign_no_u_turn', QSMode.question),
  'o322': QuestionSign('sign_safety_zone', QSMode.question),
  'o325': QuestionSign('sign_school_zone', QSMode.question),
  'o327': QuestionSign('sign_no_stopping', QSMode.question),
  'o328': QuestionSign('sign_one_way', QSMode.question),
  'o331': QuestionSign('sign_parking_parallel', QSMode.question),
  'o333': QuestionSign('sign_pedestrian_only', QSMode.question),
  'o334': QuestionSign('sign_railroad_crossing', QSMode.question),
  'o336': QuestionSign('sign_no_pedestrians', QSMode.question),
  'o340': QuestionSign('sign_bicycle_crossing', QSMode.question),
  'o342': QuestionSign('sign_motorway', QSMode.question),
  'o343': QuestionSign('sign_tram_track_ok', QSMode.question),
  'o348': QuestionSign('sign_priority_road', QSMode.question),
};

/// 問題IDに対応する標識の絵を出す。対応がなければ何も出さない。
class QuestionSignView extends StatelessWidget {
  const QuestionSignView({
    super.key,
    required this.questionId,
    this.size = 72,
    this.answered = false,
    this.signs = kQuestionSigns,
  });

  final String questionId;
  final double size;

  /// 解答後（結果・解説表示）か。[QSMode.explanationOnly] の問題はこのときだけ出す。
  final bool answered;

  /// 対応表（テストで差し替える用。通常は [kQuestionSigns]）。
  final Map<String, QuestionSign> signs;

  @override
  Widget build(BuildContext context) {
    final entry = signs[questionId];
    if (entry == null) return const SizedBox.shrink();
    if (entry.mode == QSMode.explanationOnly && !answered) {
      return const SizedBox.shrink();
    }
    TrafficSign? sign;
    for (final s in kTrafficSigns) {
      if (s.id == entry.signId) {
        sign = s;
        break;
      }
    }
    if (sign == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(child: TrafficSignWidget(sign: sign, size: size)),
    );
  }
}
