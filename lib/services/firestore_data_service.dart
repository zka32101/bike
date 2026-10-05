import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bike_unlock_progress.dart';
import '../models/pass_prediction_score.dart';
import '../models/question.dart';
import '../models/trap_dojo_session.dart';
import '../models/user.dart';
import '../models/user_answer_log.dart';
import 'local_data_service.dart';
import 'ukalab_paths.dart';

/// Firestore を用いたデータ永続化実装。
///
/// Production環境ではこのサービスを DataService として inject する。
/// FirebaseCore.initializeApp() で Firebase が初期化されている前提。
///
/// Firestore スキーマ:
/// - /users/{uid}/data/{docId} → AppUser JSON
/// - /questions/{category}/{docId} → Question JSON (本格投入時)
/// - /users/{uid}/answerLogs/{docId} → UserAnswerLog JSON
/// - /users/{uid}/predictionScore/{uid} → PassPredictionScore JSON
/// - /users/{uid}/bikeProgress/{docId} → BikeUnlockProgress JSON
/// - /users/{uid}/trapDojo/{docId} → TrapDojoSession JSON
///
/// キャッシング戦略:
/// - questions は assets/questions/*.json をローカルキャッシュ（Firestore投入後は Firestore から取得に移行）
/// - ユーザーデータ（logs, scores, progress）は Firestore から最新を取得
/// - Offline の場合は Firestore の自動オフライン対応に委ねる
class FirestoreDataService implements DataService {
  final FirebaseFirestore _firestore;

  FirestoreDataService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance {
    // オフライン対応を有効にする
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  static const String _answerLogsSubcollection = 'answerLogs';
  static const String _predictionScoreDoc = 'predictionScore';
  static const String _bikeUnlockSubcollection = 'bikeProgress';
  static const String _trapDojoSubcollection = 'trapDojo';

  @override
  Future<AppUser> loadUser(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(ukalabExamId)
          .get(const GetOptions(source: Source.serverAndCache));

      if (!docSnapshot.exists) {
        return AppUser(uid: uid);
      }

      return AppUser.fromJson(docSnapshot.data() ?? {});
    } catch (e) {
      // ネットワークエラー時はローカルキャッシュにフォールバック
      rethrow;
    }
  }

  @override
  Future<void> saveUser(AppUser user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('exams')
        .doc(ukalabExamId)
        .set(user.toJson(), SetOptions(merge: true));
  }

  @override
  Future<List<Question>> loadQuestions({
    required String licenseCategory,
    String? stageTag,
  }) async {
    // 本格投入時: Firestore から取得
    // 現段階: assets/questions/*.json をローカルサービスで取得（変わらず）
    final localService = LocalDataService();
    return localService.loadQuestions(
      licenseCategory: licenseCategory,
      stageTag: stageTag,
    );
  }

  @override
  Future<List<Question>> loadQuestionsByIds(List<String> ids) async {
    final localService = LocalDataService();
    return localService.loadQuestionsByIds(ids);
  }

  @override
  Future<void> appendAnswerLog(UserAnswerLog log) async {
    await _firestore
        .collection('users')
        .doc(log.uid)
        .collection('exams')
        .doc(ukalabExamId)
        .collection(_answerLogsSubcollection)
        .add(log.toJson());
  }

  @override
  Future<List<UserAnswerLog>> loadAnswerLogs(String uid, {DateTime? since}) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(uid)
        .collection('exams')
        .doc(ukalabExamId)
        .collection(_answerLogsSubcollection)
        .orderBy('answeredAt', descending: true);

    if (since != null) {
      query = query.where('answeredAt', isGreaterThanOrEqualTo: since);
    }

    final querySnapshot = await query
        .get(const GetOptions(source: Source.serverAndCache));

    return querySnapshot.docs
        .map((doc) => UserAnswerLog.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> savePredictionScore(PassPredictionScore score) async {
    await _firestore
        .collection('users')
        .doc(score.uid)
        .collection('exams')
        .doc(ukalabExamId)
        .collection('metadata')
        .doc(_predictionScoreDoc)
        .set(score.toJson(), SetOptions(merge: true));
  }

  @override
  Future<PassPredictionScore?> loadPredictionScore(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('exams')
          .doc(ukalabExamId)
          .collection('metadata')
          .doc(_predictionScoreDoc)
          .get(const GetOptions(source: Source.serverAndCache));

      if (!docSnapshot.exists) return null;

      return PassPredictionScore.fromJson(docSnapshot.data() ?? {});
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<BikeUnlockProgress>> loadBikeUnlockProgress(String uid) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('exams')
        .doc(ukalabExamId)
        .collection(_bikeUnlockSubcollection)
        .get(const GetOptions(source: Source.serverAndCache));

    return querySnapshot.docs
        .map((doc) => BikeUnlockProgress.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> saveBikeUnlockProgress(BikeUnlockProgress progress) async {
    await _firestore
        .collection('users')
        .doc(progress.uid)
        .collection('exams')
        .doc(ukalabExamId)
        .collection(_bikeUnlockSubcollection)
        .doc(progress.bikeId)
        .set(progress.toJson(), SetOptions(merge: true));
  }

  @override
  Future<List<TrapDojoSession>> loadTrapDojoSessions(String uid) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('exams')
        .doc(ukalabExamId)
        .collection(_trapDojoSubcollection)
        .orderBy('createdAt', descending: true)
        .get(const GetOptions(source: Source.serverAndCache));

    return querySnapshot.docs
        .map((doc) => TrapDojoSession.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> saveTrapDojoSession(TrapDojoSession session) async {
    // Use bossQuestionId as the document ID (one session per question per user)
    await _firestore
        .collection('users')
        .doc(session.uid)
        .collection('exams')
        .doc(ukalabExamId)
        .collection(_trapDojoSubcollection)
        .doc(session.bossQuestionId)
        .set(session.toJson(), SetOptions(merge: true));
  }
}
