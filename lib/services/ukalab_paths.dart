/// うかラボ共通 Firebase プロジェクト（ukalab-prod / ukalab-dev）での、この資格の examId。
/// Firestore の学習データは `users/{uid}/exams/<この値>/…` の下に置く
/// （app_common_kit/firebase/firestore.rules の examIds() と一致させること）。
const String ukalabExamId = 'bike_license';
