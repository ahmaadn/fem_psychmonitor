import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const int _dbVersion = 2;
  static const String _dbName = 'fem_psychmonitor.db';

  Database? _db;
  static bool _ffiInitialised = false;

  static void initPlatform() {
    if (_ffiInitialised) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _ffiInitialised = true;
  }

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
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

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
        is_guest        INTEGER NOT NULL DEFAULT 0,
        ocean_o         REAL,
        ocean_c         REAL,
        ocean_e         REAL,
        ocean_a         REAL,
        ocean_n         REAL,
        ocean_completed_at INTEGER,
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
        self_report_emotion TEXT,
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

    batch.execute('''
      CREATE TABLE ${AppTables.oceanQuestions} (
        id            INTEGER PRIMARY KEY,
        trait         TEXT NOT NULL,
        positive_keyed INTEGER NOT NULL,
        statement_en  TEXT NOT NULL,
        statement_id  TEXT NOT NULL
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
      CREATE TABLE ${AppTables.saranOcean} (
        id            INTEGER PRIMARY KEY,
        trait         TEXT NOT NULL,
        level         TEXT NOT NULL,
        emotion       TEXT NOT NULL,
        sort_order    INTEGER NOT NULL,
        text_id       TEXT NOT NULL,
        text_en       TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE ${AppTables.saranDefaultNeutral} (
        id            INTEGER PRIMARY KEY,
        sort_order    INTEGER NOT NULL,
        text_id       TEXT NOT NULL,
        text_en       TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE ${AppTables.dailyMoods} (
        user_id       TEXT NOT NULL,
        date          TEXT NOT NULL,
        emotion       TEXT NOT NULL,
        created_at    INTEGER NOT NULL,
        updated_at    INTEGER NOT NULL,
        PRIMARY KEY (user_id, date),
        FOREIGN KEY (user_id) REFERENCES ${AppTables.users}(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE ${AppTables.mentalScoreLog} (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id       TEXT NOT NULL,
        at_ms         INTEGER NOT NULL,
        score         INTEGER NOT NULL,
        reason        TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${AppTables.users}(id) ON DELETE CASCADE
      )
    ''');

    batch.execute(
      'CREATE INDEX idx_sessions_user ON ${AppTables.detectionSessions}(user_id, started_at DESC)',
    );
    batch.execute(
      'CREATE INDEX idx_results_session ON ${AppTables.detectionResults}(session_id)',
    );
    batch.execute(
      'CREATE INDEX idx_sync_pending ON ${AppTables.syncQueue}(synced_at) WHERE synced_at IS NULL',
    );
    batch.execute(
      'CREATE INDEX idx_score_log_user ON ${AppTables.mentalScoreLog}(user_id, at_ms DESC)',
    );

    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Destructive master migration for pre-launch: rebuild OCEAN schema.
      await db.execute('DROP TABLE IF EXISTS ${AppTables.mbtiOptions}');
      await db.execute('DROP TABLE IF EXISTS ${AppTables.mbtiQuestions}');
      await db.execute('DROP TABLE IF EXISTS ${AppTables.saranRecommendations}');

      final cols = await db.rawQuery('PRAGMA table_info(${AppTables.users})');
      final names = cols.map((c) => c['name'] as String).toSet();
      if (!names.contains('is_guest')) {
        await db.execute(
          'ALTER TABLE ${AppTables.users} ADD COLUMN is_guest INTEGER NOT NULL DEFAULT 0',
        );
      }
      for (final c in [
        'ocean_o REAL',
        'ocean_c REAL',
        'ocean_e REAL',
        'ocean_a REAL',
        'ocean_n REAL',
        'ocean_completed_at INTEGER',
      ]) {
        final name = c.split(' ').first;
        if (!names.contains(name)) {
          await db.execute('ALTER TABLE ${AppTables.users} ADD COLUMN $c');
        }
      }

      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppTables.oceanQuestions} (
          id            INTEGER PRIMARY KEY,
          trait         TEXT NOT NULL,
          positive_keyed INTEGER NOT NULL,
          statement_en  TEXT NOT NULL,
          statement_id  TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppTables.saranOcean} (
          id            INTEGER PRIMARY KEY,
          trait         TEXT NOT NULL,
          level         TEXT NOT NULL,
          emotion       TEXT NOT NULL,
          sort_order    INTEGER NOT NULL,
          text_id       TEXT NOT NULL,
          text_en       TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppTables.saranDefaultNeutral} (
          id            INTEGER PRIMARY KEY,
          sort_order    INTEGER NOT NULL,
          text_id       TEXT NOT NULL,
          text_en       TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppTables.dailyMoods} (
          user_id       TEXT NOT NULL,
          date          TEXT NOT NULL,
          emotion       TEXT NOT NULL,
          created_at    INTEGER NOT NULL,
          updated_at    INTEGER NOT NULL,
          PRIMARY KEY (user_id, date)
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppTables.mentalScoreLog} (
          id            INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id       TEXT NOT NULL,
          at_ms         INTEGER NOT NULL,
          score         INTEGER NOT NULL,
          reason        TEXT NOT NULL
        )
      ''');

      final sessCols =
          await db.rawQuery('PRAGMA table_info(${AppTables.detectionSessions})');
      final sessNames = sessCols.map((c) => c['name'] as String).toSet();
      if (!sessNames.contains('self_report_emotion')) {
        await db.execute(
          'ALTER TABLE ${AppTables.detectionSessions} ADD COLUMN self_report_emotion TEXT',
        );
      }
    }
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
