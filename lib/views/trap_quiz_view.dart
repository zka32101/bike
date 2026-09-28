import 'package:flutter/material.dart';

import '../viewmodels/trap_quiz_providers.dart';
import 'widgets/cross_category_quiz_scaffold.dart';

/// ひっかけ問題専門クイズ。全区分（アクセス可能な範囲）の
/// isTrapQuestion == true の問題からランダムに10問出題する。
class TrapQuizView extends StatelessWidget {
  const TrapQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return CrossCategoryQuizScaffold(
      title: 'ひっかけ問題クイズ',
      provider: trapQuizControllerProvider,
      emptyMessage: '出題できるひっかけ問題がありません。\nパスを購入すると全区分の問題が対象になります。',
      resultIcon: Icons.psychology_alt,
    );
  }
}
