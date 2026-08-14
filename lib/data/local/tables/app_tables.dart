/// Centralised SQLite table names.
class AppTables {
  AppTables._();

  static const String users = 'users';
  static const String detectionSessions = 'detection_sessions';
  static const String detectionResults = 'detection_results';
  static const String authTokens = 'auth_tokens';
  static const String syncQueue = 'sync_queue';

  // Master
  static const String oceanQuestions = 'ocean_questions';
  static const String psychQuestions = 'psych_questions';
  static const String psychOptions = 'psych_options';
  static const String psychClasses = 'psych_classes';
  static const String psychMeta = 'psych_meta';
  static const String saranOcean = 'saran_ocean';
  static const String saranDefaultNeutral = 'saran_default_neutral';

  // App state
  static const String dailyMoods = 'daily_moods';
  static const String mentalScoreLog = 'mental_score_log';

  // Legacy (kept for migration drop only)
  static const String mbtiQuestions = 'mbti_questions';
  static const String mbtiOptions = 'mbti_options';
  static const String saranRecommendations = 'saran_recommendations';
}

enum SyncOperation { insert, update, delete }

extension SyncOperationX on SyncOperation {
  String get name => toString().split('.').last;
  static SyncOperation parse(String value) {
    return SyncOperation.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SyncOperation.update,
    );
  }
}

class SyncEntity {
  SyncEntity._();
  static const String user = 'user';
  static const String detectionSession = 'detection_session';
  static const String authToken = 'auth_token';
  static const String dailyMood = 'daily_mood';
  static const String userDataReset = 'user_data_reset';
  static const String accountDelete = 'account_delete';
}
