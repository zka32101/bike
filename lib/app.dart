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
/// まず Firebase Auth の匿名ログイン完了（[authReadyProvider]）を待ってから
/// ユーザーデータを読み込む。これを待たずに [userControllerProvider] を
/// 組み立てると、ログイン未完了の一瞬に [currentUidProvider] が
/// 'unknown_uid' を返し、その UID でユーザーが作成されてしまう競合状態が
/// 起きていたため（認証初期化に失敗しているように見える不具合の原因）。
class _StartupGate extends ConsumerWidget {
  const _StartupGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // オフライン継続を選択済みなら、Firebase認証の結果を待たずに進む
    // （currentUidProvider がローカル固定UIDにフォールバックする）。
    if (ref.watch(offlineModeAcceptedProvider)) {
      return const _AuthedStartupGate();
    }

    final authAsync = ref.watch(authReadyProvider);
    return authAsync.when(
      data: (_) => const _AuthedStartupGate(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  '認証の初期化に失敗しました',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(authReadyProvider),
                  child: const Text('再試行'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      ref.read(offlineModeAcceptedProvider.notifier).state = true,
                  child: const Text('オフラインで続ける（データはこの端末のみに保存されます）'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 認証完了後の入口の出し分け。
/// 免許区分を1つ以上選択済み（オンボーディング完了済み）なら直接ホームへ、
/// 未選択なら従来どおりオンボーディングへ。ユーザー情報はローカルに
/// 永続化されているため、この判定はネットワーク接続を必要としない。
class _AuthedStartupGate extends ConsumerWidget {
  const _AuthedStartupGate();

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
