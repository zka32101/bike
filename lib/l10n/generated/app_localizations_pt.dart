// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Carteira de Moto: Tudo em Um!';

  @override
  String get navHome => 'Início';

  @override
  String get navSettings => 'Configurações';

  @override
  String get menuAnswerQuestions => 'Resolver questões';

  @override
  String get menuStudyMode => 'Modo de estudo';

  @override
  String get menuAnalytics => 'Análise de estudo';

  @override
  String get menuMockExam => 'Simulado';

  @override
  String get menuSignQuiz => 'Quiz de placas';

  @override
  String get menuTrapQuiz => 'Quiz de pegadinhas';

  @override
  String get menuNumberQuiz => 'Quiz de números e distâncias';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsPlan => 'Plano';

  @override
  String get settingsHelp => 'Como usar';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonNext => 'Próximo';

  @override
  String get commonStart => 'Iniciar';

  @override
  String get commonHome => 'Voltar ao início';

  @override
  String commonLoadError(String error) {
    return 'Falha ao carregar: $error';
  }

  @override
  String get commonNoQuestionsInCategory =>
      'Ainda não há questões para esta categoria';

  @override
  String get commonCategoryLocked =>
      'Compre um passe para desbloquear esta categoria';

  @override
  String get commonViewPlans => 'Ver planos';

  @override
  String get commonMarkMastered => 'Aprendi';

  @override
  String get commonMastered => 'Aprendi ✓';

  @override
  String homeAnswerQuestionsWithCategory(String category) {
    return 'Resolver questões ($category)';
  }

  @override
  String get homeAnswerQuestionsSubtitle =>
      'Questões aleatórias entre as que você ainda não domina';

  @override
  String homeFreePreviewLimit(int count) {
    return 'A versão gratuita inclui apenas as primeiras $count questões';
  }

  @override
  String get homeUnlockWithPass => 'Desbloqueie comprando um passe';

  @override
  String get homeStudyModeSubtitle =>
      'Estude lendo questões, respostas e explicações';

  @override
  String get homeAnalyticsSubtitle => 'Veja seus pontos fracos e seu progresso';

  @override
  String homeMockExamSubtitle(int count, int minutes) {
    return '$count questões · $minutes min · aprovação com 90% (requer passe)';
  }

  @override
  String get homeSignQuizSubtitle =>
      'Veja a placa e acerte o nome e o significado';

  @override
  String get homeTrapQuizSubtitle =>
      'Pratique somente as questões com pegadinha';

  @override
  String get homeNumberQuizSubtitle =>
      'Pratique números como limites de velocidade, distância de frenagem e distância de seguimento';

  @override
  String get homeNoCategory =>
      'Nenhuma categoria de habilitação definida. Escolha uma nas Configurações.';

  @override
  String get homeSetCategory => 'Escolher categoria';

  @override
  String homeStreak(int days) {
    return '$days dias seguidos de estudo!';
  }

  @override
  String get homeExamDatePrompt =>
      'Defina a data da prova para calcular sua meta diária automaticamente';

  @override
  String get homeExamDateSet => 'Definir';

  @override
  String get homeQuotaExplanation =>
      'Sua meta diária considera os dias restantes, questões não dominadas e tempo extra para refazer as que você errar';

  @override
  String get homeExamDatePassed =>
      'A data da prova já passou. Revise suas configurações';

  @override
  String get homeNoUnmastered =>
      'Você dominou todas as questões. Continue assim!';

  @override
  String homeDailyGoalPace(int count) {
    return 'Resolva $count questões por dia para estar pronto até a prova';
  }

  @override
  String get homeQuotaCalculating => 'Calculando sua meta diária…';

  @override
  String homeExamCountdown(int days) {
    return 'Faltam $days dias para a prova';
  }

  @override
  String dailyQuotaProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get dailyQuotaAhaTitle => '🎉 3 acertos!';

  @override
  String get dailyQuotaContinue => 'Continuar';

  @override
  String get dailyQuotaSeeAdFreePlans => 'Ver planos sem anúncios';

  @override
  String get dailyQuotaCompleted => 'Treino concluído!';

  @override
  String dailyQuotaCorrectCount(int correct, int total) {
    return '$correct / $total corretas';
  }

  @override
  String studyModeTitleWithCategory(String category) {
    return 'Modo de estudo ($category)';
  }

  @override
  String studyModeQuestionList(int count) {
    return 'Questões ($count)';
  }

  @override
  String get studyModeUnmasteredOnly => 'Só não dominadas';

  @override
  String get studyModeAllMastered =>
      'Você marcou todas as questões como \"Aprendi\". Ótimo trabalho!';

  @override
  String get studyModeTopicSummaries => 'Resumo por tema';

  @override
  String get analyticsRecalculate => 'Recalcular';

  @override
  String get analyticsCalculating => 'Calculando análise...';

  @override
  String get analyticsLoadFailed => 'Falha ao carregar os dados de análise';

  @override
  String get analyticsRetry => 'Tentar novamente';

  @override
  String get analyticsInsufficientData =>
      'Ainda não há dados suficientes para análise';

  @override
  String analyticsRemainingQuestions(int count) {
    return 'Responda mais $count questões para ver sua análise.\nContinue estudando!';
  }

  @override
  String get analyticsByTopic => 'Por tema';

  @override
  String get analyticsByCategory => 'Por categoria';

  @override
  String get analyticsCategoryNote =>
      '* Algumas questões pertencem a várias categorias,\npor isso o total pode diferir do número de questões';

  @override
  String analyticsWeakTop(int count) {
    return 'Top $count pontos fracos';
  }

  @override
  String get analyticsRecommendedReview => 'Revisão recomendada';

  @override
  String get passRateTitle => 'Análise de aprovação';

  @override
  String get passRateNoData => 'Ainda não há respostas suficientes';

  @override
  String get passRateNoDataHint =>
      'Responda pelo menos 10 questões para ver sua análise.';

  @override
  String get passRatePredictionScore => 'Previsão de aprovação';

  @override
  String get passRateAccuracyStats => 'Estatísticas de acertos';

  @override
  String get passRateCorrectCount => 'Acertos';

  @override
  String get passRateAccuracy => 'Taxa de acerto';

  @override
  String get passRateByCategory => 'Análise por categoria';

  @override
  String get passRateByStage => 'Análise por etapa';

  @override
  String get passRateByTopic => 'Análise por tema';

  @override
  String get passRateAlmostThere => 'Falta pouco para a aprovação!';

  @override
  String get passRateOnTrack => 'Você está no caminho certo';

  @override
  String get passRateNeedPractice => 'É preciso praticar mais';

  @override
  String get passRateKeepGoing => 'Continue firme, passo a passo';

  @override
  String get trapDojoTitle => 'Dojo das pegadinhas';

  @override
  String get trapDojoNotReady =>
      'As pegadinhas desta categoria estão em preparação';

  @override
  String get trapDojoCompleted => 'Dojo de hoje concluído!';

  @override
  String trapDojoBossProgress(int current, int total) {
    return 'Chefe $current / $total';
  }

  @override
  String get trapDojoNextBoss => 'Próximo chefe';

  @override
  String get reviewNotFound => 'Nenhuma questão para revisar foi encontrada';

  @override
  String reviewHeader(int count) {
    return 'Revise apenas as $count questões que você errou';
  }
}
