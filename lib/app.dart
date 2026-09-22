import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'views/home_view.dart';
import 'views/onboarding_view.dart';
import 'viewmodels/providers.dart';

/// ルートの [ScaffoldMessengerState] への参照。
/// [BikeLicenseKoreApp.build] の時点ではまだ MaterialApp/Scaffold が
/// ツリーに存在せず、その context で ScaffoldMessenger.of を呼ぶと
/// Null check 例外になるため、MaterialApp に渡す key 経由でアクセスする。
final scaffoldMessengerKeyProvider =
    Provider<GlobalKey<ScaffoldMessengerState>>(
  (ref) => GlobalKey<ScaffoldMessengerState>(),
);

class BikeLicenseKoreApp extends ConsumerWidget {
  const BikeLicenseKoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldMessengerKey = ref.watch(scaffoldMessengerKeyProvider);

    // アプリ起動時に Firebase Auth 初期化を実行
    // エラー時は同期的にスナックバーを表示して続行
    ref.listen(authReadyProvider, (previous, next) {
      next.when(
        data: (uid) {
          debugPrint('Auth initialized with UID: $uid');
        },
        loading: () {},
        error: (error, stackTrace) {
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text('認証初期化に失敗: $error')),
          );
        },
      );
    });

    // アプリ起動時にネットワークキュープロセッサーを初期化
    // これでオフラインキューの自動処理が開始される
    ref.listen(networkQueueProcessorProvider, (previous, next) {
      next.when(
        data: (processor) {
          if (context.mounted) {
            debugPrint('Network queue processor initialized');
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          if (context.mounted) {
            debugPrint('Failed to initialize network queue processor: $error');
          }
        },
      );
    });

    return MaterialApp(
      title: '原付・バイク免許コレ！',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system, // ダークモード必須（Step5.5）
      home: const _StartupGate(),
    );
  }
}

/// 起動時の入口を出し分ける。
/// 免許区分を1つ以上選択済み（オンボーディング完了済み）なら直接ホームへ、
/// 未選択なら従来どおりオンボーディングへ。ユーザー情報はローカルに
/// 永続化されているため、この判定はネットワーク接続を必要としない。
class _StartupGate extends ConsumerWidget {
  const _StartupGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userControllerProvider);
    return userAsync.when(
      data: (user) => user.licenseCategories.isEmpty
          ? const OnboardingView()
          : const HomeView(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      // ローカルユーザーの読み込みに失敗した場合はオンボーディングから
      // やり直せるようにする（フェイルセーフ）。
      error: (error, stackTrace) => const OnboardingView(),
    );
  }
}
