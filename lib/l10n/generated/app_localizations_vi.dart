// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Luyện thi bằng lái xe máy!';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get menuAnswerQuestions => 'Luyện đề';

  @override
  String get menuStudyMode => 'Chế độ học';

  @override
  String get menuAnalytics => 'Phân tích học tập';

  @override
  String get menuMockExam => 'Thi thử';

  @override
  String get menuSignQuiz => 'Câu đố biển báo';

  @override
  String get menuTrapQuiz => 'Câu hỏi bẫy';

  @override
  String get menuNumberQuiz => 'Câu đố số liệu & khoảng cách';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsNotifications => 'Thông báo';

  @override
  String get settingsPlan => 'Gói';

  @override
  String get settingsHelp => 'Hướng dẫn sử dụng';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonNext => 'Tiếp';

  @override
  String get commonStart => 'Bắt đầu';

  @override
  String get commonHome => 'Về trang chủ';

  @override
  String commonLoadError(String error) {
    return 'Tải dữ liệu thất bại: $error';
  }

  @override
  String get commonNoQuestionsInCategory => 'Chưa có câu hỏi cho hạng bằng này';

  @override
  String get commonCategoryLocked => 'Mua gói để mở khóa hạng bằng này';

  @override
  String get commonViewPlans => 'Xem các gói';

  @override
  String get commonMarkMastered => 'Đã thuộc';

  @override
  String get commonMastered => 'Đã thuộc ✓';

  @override
  String homeAnswerQuestionsWithCategory(String category) {
    return 'Luyện đề ($category)';
  }

  @override
  String get homeAnswerQuestionsSubtitle =>
      'Câu hỏi ngẫu nhiên từ những câu chưa thuộc';

  @override
  String homeFreePreviewLimit(int count) {
    return 'Bản miễn phí chỉ cho làm $count câu đầu tiên';
  }

  @override
  String get homeUnlockWithPass => 'Mở khóa khi mua gói';

  @override
  String get homeStudyModeSubtitle =>
      'Học bằng cách đọc câu hỏi, đáp án và giải thích';

  @override
  String get homeAnalyticsSubtitle => 'Xem điểm yếu và mức tiến bộ';

  @override
  String homeMockExamSubtitle(int count, int minutes) {
    return '$count câu · $minutes phút · đạt từ 90% (cần mua gói)';
  }

  @override
  String get homeSignQuizSubtitle => 'Nhìn hình biển báo và đoán tên, ý nghĩa';

  @override
  String get homeTrapQuizSubtitle => 'Tập trung luyện riêng các câu hỏi bẫy';

  @override
  String get homeNumberQuizSubtitle =>
      'Luyện các con số như tốc độ tối đa, quãng đường phanh, khoảng cách giữa các xe';

  @override
  String get homeNoCategory =>
      'Chưa chọn hạng bằng lái. Vui lòng chọn trong Cài đặt.';

  @override
  String get homeSetCategory => 'Chọn hạng bằng';

  @override
  String homeStreak(int days) {
    return 'Học liên tục $days ngày!';
  }

  @override
  String get homeExamDatePrompt =>
      'Đăng ký ngày thi để tự động tính chỉ tiêu mỗi ngày';

  @override
  String get homeExamDateSet => 'Đặt';

  @override
  String get homeQuotaExplanation =>
      'Chỉ tiêu được tính từ số ngày còn lại, số câu chưa thuộc và cả thời gian làm lại các câu bạn từng sai';

  @override
  String get homeExamDatePassed =>
      'Đã qua ngày thi. Vui lòng kiểm tra lại cài đặt';

  @override
  String get homeNoUnmastered =>
      'Bạn đã thuộc hết các câu hỏi. Hãy duy trì phong độ nhé!';

  @override
  String homeDailyGoalPace(int count) {
    return 'Làm $count câu mỗi ngày là kịp ngày thi';
  }

  @override
  String get homeQuotaCalculating => 'Đang tính chỉ tiêu…';

  @override
  String homeExamCountdown(int days) {
    return 'Còn $days ngày đến ngày thi';
  }

  @override
  String dailyQuotaProgress(int current, int total) {
    return 'Câu $current / $total';
  }

  @override
  String get dailyQuotaAhaTitle => '🎉 Đúng 3 câu!';

  @override
  String get dailyQuotaContinue => 'Tiếp tục';

  @override
  String get dailyQuotaSeeAdFreePlans => 'Xem gói không quảng cáo';

  @override
  String get dailyQuotaCompleted => 'Hoàn thành luyện tập!';

  @override
  String dailyQuotaCorrectCount(int correct, int total) {
    return 'Đúng $correct / $total câu';
  }

  @override
  String studyModeTitleWithCategory(String category) {
    return 'Chế độ học ($category)';
  }

  @override
  String studyModeQuestionList(int count) {
    return 'Danh sách câu hỏi ($count câu)';
  }

  @override
  String get studyModeUnmasteredOnly => 'Chỉ câu chưa thuộc';

  @override
  String get studyModeAllMastered =>
      'Bạn đã đánh dấu \"Đã thuộc\" cho tất cả. Làm tốt lắm!';

  @override
  String get studyModeTopicSummaries => 'Tóm tắt theo chủ đề';

  @override
  String get analyticsRecalculate => 'Tính lại';

  @override
  String get analyticsCalculating => 'Đang tính toán dữ liệu phân tích...';

  @override
  String get analyticsLoadFailed => 'Tải dữ liệu phân tích thất bại';

  @override
  String get analyticsRetry => 'Thử lại';

  @override
  String get analyticsInsufficientData => 'Chưa đủ dữ liệu để phân tích';

  @override
  String analyticsRemainingQuestions(int count) {
    return 'Làm thêm $count câu để xem phân tích.\nHãy tiếp tục học nhé!';
  }

  @override
  String get analyticsByTopic => 'Theo chủ đề';

  @override
  String get analyticsByCategory => 'Theo hạng bằng';

  @override
  String get analyticsCategoryNote =>
      '* Một số câu thuộc nhiều hạng bằng,\nnên tổng có thể khác tổng số câu hỏi';

  @override
  String analyticsWeakTop(int count) {
    return 'Top $count điểm yếu';
  }

  @override
  String get analyticsRecommendedReview => 'Nên ôn tập';

  @override
  String get passRateTitle => 'Phân tích tỷ lệ đỗ';

  @override
  String get passRateNoData => 'Chưa có đủ dữ liệu trả lời';

  @override
  String get passRateNoDataHint =>
      'Hãy trả lời ít nhất 10 câu để xem phân tích.';

  @override
  String get passRatePredictionScore => 'Điểm dự đoán đỗ';

  @override
  String get passRateAccuracyStats => 'Thống kê tỷ lệ đúng';

  @override
  String get passRateCorrectCount => 'Số câu đúng';

  @override
  String get passRateAccuracy => 'Tỷ lệ đúng';

  @override
  String get passRateByCategory => 'Phân tích theo hạng bằng';

  @override
  String get passRateByStage => 'Phân tích theo giai đoạn';

  @override
  String get passRateByTopic => 'Phân tích theo chủ đề';

  @override
  String get passRateAlmostThere => 'Chỉ còn một bước nữa là đỗ!';

  @override
  String get passRateOnTrack => 'Bạn đang tiến bộ tốt';

  @override
  String get passRateNeedPractice => 'Cần luyện tập thêm';

  @override
  String get passRateKeepGoing => 'Hãy kiên trì từng chút một';

  @override
  String get trapDojoTitle => 'Võ đường câu hỏi bẫy';

  @override
  String get trapDojoNotReady =>
      'Câu hỏi bẫy cho hạng bằng này đang được chuẩn bị';

  @override
  String get trapDojoCompleted => 'Hoàn thành võ đường hôm nay!';

  @override
  String trapDojoBossProgress(int current, int total) {
    return 'Trùm $current / $total';
  }

  @override
  String get trapDojoNextBoss => 'Trùm tiếp theo';

  @override
  String get reviewNotFound => 'Không tìm thấy câu hỏi cần ôn tập';

  @override
  String reviewHeader(int count) {
    return 'Chỉ ôn lại $count câu đã làm sai';
  }
}
