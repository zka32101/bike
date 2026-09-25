import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/providers.dart';

/// Googleサインイン画面。認証準備完了（[authReadyProvider]）が未サインイン
/// だった場合に表示される、アプリ起動時の入口。
class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = await ref.read(authServiceProvider).signInWithGoogle();
      if (uid != null) {
        ref.invalidate(authReadyProvider);
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.two_wheeler, size: 64),
                const SizedBox(height: 16),
                Text(
                  '原付・バイク免許コレ！',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Googleアカウントでログインすると、学習データが\n端末を変えても引き継がれます。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _signIn,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: const Text('Googleでログイン'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => ref.read(offlineModeAcceptedProvider.notifier).state = true,
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
