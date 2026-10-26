import 'package:app_common_kit/app_common_kit.dart';

/// bike のインタースティシャル表示ルール（CD-007: 1日1回・同一セッション2回目禁止）。
///
/// app_common_kit v4.0.0 の [AdRules] 既定（最短3分間隔・1日5回）を上書きする。
/// 日次カウントは kit の `AdFrequencyController` が端末内に保存し、表示済みなら
/// その日のうちは（同一セッションの2回目も含めて）拒否する。日付が変わると
/// 自動でリセットされる。最短間隔は日次上限が先に効くため、kit 既定値のまま残す。
const AdRules kBikeAdRules = AdRules(interstitialDailyCap: 1);
