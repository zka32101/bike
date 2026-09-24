/// 問題の分野・トピック分類（免許区分とは独立した軸）。
///
/// `Question.topicTag` / `QuestionMeta.topicTag` に格納される文字列値
/// （例: 'rules'）と対応する。学習分析画面の「分野別分析」で使用。
enum QuestionTopic {
  signs('signs', '標識・標示'),
  rules('rules', '法規・通行ルール'),
  parking('parking', '駐停車・積載・二人乗り'),
  operation('operation', '運転操作・技能'),
  hazardPrediction('hazard_prediction', '危険予測・安全確認'),
  maintenance('maintenance', '整備・点検'),
  licenseSystem('license_system', '免許制度'),
  emergency('emergency', '事故時の対応・応急救護');

  const QuestionTopic(this.id, this.label);

  /// JSON・集計キーに使われる安定識別子。
  final String id;

  /// 表示用の日本語ラベル。
  final String label;

  /// id から対応する QuestionTopic を取得。未知の id の場合は id をそのまま
  /// ラベルとして扱えるよう null を返す。
  static QuestionTopic? fromId(String id) {
    for (final topic in QuestionTopic.values) {
      if (topic.id == id) return topic;
    }
    return null;
  }

  /// id から表示ラベルを取得（未知の id の場合は id をそのまま返す）。
  static String labelFor(String id) => fromId(id)?.label ?? id;
}
