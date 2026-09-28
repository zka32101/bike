import 'package:flutter/material.dart';

import '../viewmodels/number_quiz_providers.dart';
import 'widgets/cross_category_quiz_scaffold.dart';

/// 数字・距離クイズ。速度制限・制動距離・車間距離・積載制限・免許期間・
/// 二段階右折など、数字に関する問題（アクセス可能な範囲の全区分）から
/// ランダムに10問出題する。
class NumberQuizView extends StatelessWidget {
  const NumberQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return CrossCategoryQuizScaffold(
      title: '数字・距離クイズ',
      provider: numberQuizControllerProvider,
      emptyMessage: '出題できる数字・距離の問題がありません。\nパスを購入すると全区分の問題が対象になります。',
      resultIcon: Icons.speed,
    );
  }
}
