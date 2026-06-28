/// Centralised SQLite table names and column helpers.
/// Keeps DDL and row-mapping code referencing a single source of truth.
class AppTables {
  AppTables._();

  // Transactional (user-owned, synced)
  static const String users = 'users';
  static const String detectionSessions = 'detection_sessions';
  static const String detectionResults = 'detection_results';
  static const String authTokens = 'auth_tokens';

  // Sync infrastructure
  static const String syncQueue = 'sync_queue';

  // Master / reference data (asset-seeded, NOT synced)
  static const String mbtiQuestions = 'mbti_questions';
  static const String mbtiOptions = 'mbti_options';
  static const String psychQuestions = 'psych_questions';
  static const String psychOptions = 'psych_options';
  static const String psychClasses = 'psych_classes';
  static const String psychMeta = 'psych_meta'; // scoring system scalars
  static const String saranRecommendations = 'saran_recommendations';
}

/// Sync-queue operation kinds.
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

/// Entity types recorded in the sync queue.
class SyncEntity {
  SyncEntity._();
  static const String user = 'user';
  static const String detectionSession = 'detection_session';
  static const String authToken = 'auth_token';
}
