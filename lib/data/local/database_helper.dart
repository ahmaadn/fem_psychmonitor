import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Singleton wrapping the SQLite database used as the offline-first store.
///
/// On Windows / Linux / macOS desktop builds, [sqflite_common_ffi] is initialised
/// so the same code path works during desktop testing. Mobile builds use the
/// native `sqflite` implementation.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const int _dbVersion = 1;
  static const String _dbName = 'fem_psychmonitor.db';

  Database? _db;

  /// Whether desktop FFI has been initialised. Guarded so it only runs once.
  static bool _ffiInitialised = false;

  /// Initialise the platform-appropriate database factory.
  /// Must be called before any [database] access (i.e. early in `main`).
  static void initPlatform() {
    if (_ffiInitialised) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _ffiInitialised = true;
  }

  /// Open (or create) the database, lazily cached.
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = p.join(docsDir.path, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign-key enforcement (off by default in SQLite).
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // ── Transactional ──────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE ${AppTables.users} (
        id              TEXT PRIMARY KEY,
        full_name       TEXT NOT NULL,
        email           TEXT NOT NULL UNIQUE,
        phone           TEXT,
        date_of_birth   INTEGER,
        avatar_url      TEXT,
        created_at      INTEGER NOT NULL,
        updated_at      INTEGER NOT NULL,
        is_dirty        INTEGER NOT NULL DEFAULT 0,
        password_hash   TEXT NOT NULL,
        mbti_result     TEXT,
        psych_score     INTEGER,
        psych_class     TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE ${AppTables.detectionSessions} (
        id                  TEXT PRIMARY KEY,
        user_id             TEXT NOT NULL,
        started_at          INTEGER NOT NULL,
        stopped_at          INTEGER NOT NULL,
        source_type         TEXT NOT NULL,
        audio_file_path     TEXT,
        dominant_emotion     TEXT NOT NULL,
        dominant_confidence REAL NOT NULL,
        note                TEXT,
        corrected_emotion   TEXT,
        created_at          INTEGER NOT NULL,
        updated_at          INTEGER NOT NULL,
        is_dirty            INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES ${AppTables.users}(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE ${AppTables.detectionResults} (
        id          TEXT PRIMARY KEY,
        session_id  TEXT NOT NULL,
        start_sec   REAL NOT NULL,
        end_sec     REAL NOT NULL,
        label       TEXT NOT NULL,
        confidence  REAL NOT NULL,
        all_probs   TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES ${AppTables.detectionSessions}(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE ${AppTables.authTokens} (
        token       TEXT PRIMARY KEY,
        user_id     TEXT NOT NULL,
        issued_at   INTEGER NOT NULL,
        expires_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES ${AppTables.users}(id) ON DELETE CASCADE
      )
    ''');

    // ── Sync queue ──────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE ${AppTables.syncQueue} (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type   TEXT NOT NULL,
        entity_id     TEXT NOT NULL,
        operation     TEXT NOT NULL,
        payload_json   TEXT,
        queued_at     INTEGER NOT NULL,
        synced_at     INTEGER
      )
    ''');

    // ── Master / reference data ─────────────────────────────────────────
    batch.execute('''
      CREATE TABLE ${AppTables.mbtiQuestions} (
        id            INTEGER PRIMARY KEY,
        code          TEXT NOT NULL,
        dimension     TEXT NOT NULL,
        question_en   TEXT NOT NULL,
        question_id   TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE ${AppTables.mbtiOptions} (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id   INTEGER NOT NULL,
        code          TEXT NOT NULL,
        answer_en     TEXT NOT NULL,
        answer_id     TEXT NOT NULL,
        type          TEXT NOT NULL,
        FOREIGN KEY (question_id) REFERENCES ${AppTables.mbtiQuestions}(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE ${AppTables.psychQuestions} (
        id            INTEGER PRIMARY KEY,
        code          TEXT NOT NULL,
        category_en   TEXT NOT NULL,
        category_id   TEXT NOT NULL,
        question_en   TEXT NOT NULL,
        question_id   TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE ${AppTables.psychOptions} (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id   INTEGER NOT NULL,
        code          TEXT NOT NULL,
        answer_en     TEXT NOT NULL,
        answer_id     TEXT NOT NULL,
        score         INTEGER NOT NULL,
        FOREIGN KEY (question_id) REFERENCES ${AppTables.psychQuestions}(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE ${AppTables.psychClasses} (
        class_level        INTEGER PRIMARY KEY,
        class_name_en      TEXT NOT NULL,
        class_name_id      TEXT NOT NULL,
        display_range      TEXT NOT NULL,
        score_range        TEXT NOT NULL,
        description_en     TEXT NOT NULL,
        description_id     TEXT NOT NULL,
        recommendation_en  TEXT NOT NULL,
        recommendation_id  TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE ${AppTables.psychMeta} (
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE ${AppTables.saranRecommendations} (
        mbti_type      TEXT PRIMARY KEY,
        alias          TEXT NOT NULL,
        group_name     TEXT NOT NULL,
        emotions_json  TEXT NOT NULL
      )
    ''');

    // ── Indexes for read-heavy queries ───────────────────────────────────
    batch.execute(
      'CREATE INDEX idx_sessions_user ON ${AppTables.detectionSessions}(user_id, started_at DESC)',
    );
    batch.execute(
      'CREATE INDEX idx_results_session ON ${AppTables.detectionResults}(session_id)',
    );
    batch.execute(
      'CREATE INDEX idx_sync_pending ON ${AppTables.syncQueue}(synced_at) WHERE synced_at IS NULL',
    );

    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here. For v1 there is nothing to migrate.
  }

  /// Close the database (used in tests / hot-restart scenarios).
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
