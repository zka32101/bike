/// 広告を出してはいけない場面の管理（禁止ゾーン）。
///
/// 広告の頻度（最短間隔・1日の上限）と同意（UMP）は app_common_kit の `AdGate`
/// が担当する。ここで担当するのは「いま広告を出してよい画面か」だけ。
///
/// 【禁止ゾーン・コードレベルで強制】
/// - 問題回答中（出題〜正誤演出）
/// - ひっかけ道場のボス戦中（現在ひっかけ道場画面はUIから非表示だが、ガード自体は保持）
/// - 合格予測メーター表示直後（Aha Moment直後は課金導線を優先）
///
/// UI側は広告を表示する直前に必ず [isAdAllowedNow] を通し、false の場合は
/// 一切表示しないこと。
enum AdBlockingContext {
  none,
  answeringQuestion,
  trapDojoBossBattle,
  justShowedPredictionMeter,
}

class AdGateService {
  AdGateService();

  AdBlockingContext _currentContext = AdBlockingContext.none;

  void enterContext(AdBlockingContext context) {
    _currentContext = context;
  }

  void exitContext() {
    _currentContext = AdBlockingContext.none;
  }

  /// 禁止ゾーンの外にいるか。
  bool get isAdAllowedNow => _currentContext == AdBlockingContext.none;
}
