import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Authentication を通じたユーザー認証サービス。
/// Googleアカウントによるサインインのみをサポートする（匿名ログインは廃止）。
abstract class AuthService {
  /// 現在のユーザー UID を取得
  /// null = 未ログイン
  String? get currentUid;

  /// Googleアカウントでサインイン。ユーザーがキャンセルした場合は null を返す。
  Future<String?> signInWithGoogle();

  /// ログアウト
  Future<void> signOut();

  /// 現在のAuth状態を Stream で監視
  Stream<User?> get authStateChanges;

  /// 起動時のAuth状態確認（すでにサインイン済みなら何もしない。
  /// 未サインインの場合もエラーにはせず、呼び出し側でサインイン画面へ誘導する）。
  Future<void> waitForAuthReady();
}

/// Firebase Authentication + Google Sign-In を使った実装
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              // Android で Firebase の ID トークンを取得するために必須
              // （google-services.json の oauth_client / client_type=3 と対応）。
              serverClientId:
                  '904710115227-365vjghmsgk5oj9ibk44p8t9ncauv39i.apps.googleusercontent.com',
            );

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // ユーザーがサインインをキャンセルした。
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception('Failed to get UID after Google sign-in');
      }
      if (kDebugMode) {
        debugPrint('Signed in with Google, UID: $uid');
      }
      return uid;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Google sign-in failed: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      if (kDebugMode) {
        debugPrint('Signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign-out failed: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<void> waitForAuthReady() async {
    // Google Sign-In はユーザー操作が必要なため、ここでは何もしない。
    // すでにサインイン済みなら _auth.currentUser が非nullになっている。
  }
}

/// テスト用スタブ実装
class StubAuthService implements AuthService {
  StubAuthService({String? initialUid}) : _currentUid = initialUid;

  String? _currentUid;

  @override
  String? get currentUid => _currentUid;

  @override
  Future<String?> signInWithGoogle() async {
    _currentUid = 'stub-google-user-${DateTime.now().millisecondsSinceEpoch}';
    if (kDebugMode) {
      debugPrint('Stub: Signed in with Google, UID: $_currentUid');
    }
    return _currentUid;
  }

  @override
  Future<void> signOut() async {
    _currentUid = null;
    if (kDebugMode) {
      debugPrint('Stub: Signed out');
    }
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  Future<void> waitForAuthReady() async {}
}
