import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/sync_queue_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/local/tables/user_row.dart';
import 'package:fem_psychmonitor/data/models/auth_state.dart';
import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/auth_repository.dart';
import 'package:sqflite/sqflite.dart';

class SqliteAuthRepository extends AuthRepository with SyncQueueHelper {
  static const guestEmail = 'guest@local';

  @override
  Future<AuthState> login(String email, String password) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      AppTables.users,
      where: 'email = ? AND is_guest = 0',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) {
      return AuthState.error('Email tidak terdaftar');
    }
    final row = rows.first;
    final storedHash = row[UserRow.colPasswordHash] as String;
    final salt = _extractSalt(storedHash);
    final candidateHash = _hashPassword(password, salt);
    if (candidateHash != storedHash) {
      return AuthState.error('Email atau password salah');
    }

    final user = UserRow.toModel(row);
    final token = _generateToken(user.id);
    await db.delete(AppTables.authTokens);
    await db.insert(
      AppTables.authTokens,
      AuthTokenRow.toRow(
        token: token,
        userId: user.id,
        issuedAt: DateTime.now(),
      ),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return AuthState.authenticated(user: user, token: token);
  }

  @override
  Future<AuthState> register(
    String fullName,
    String email,
    String password,
  ) async {
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      return AuthState.error('Semua field harus diisi');
    }
    final db = await DatabaseHelper.instance.database;

    final existing = await db.query(
      AppTables.users,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return AuthState.error('Email sudah terdaftar');
    }

    // Merge from guest if active
    final guestRows = await db.query(
      AppTables.users,
      where: 'is_guest = 1',
      limit: 1,
    );

    final now = DateTime.now();
    final userId = 'usr_${now.millisecondsSinceEpoch}';
    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);

    UserModel user = UserModel(
      id: userId,
      fullName: fullName,
      email: email,
      createdAt: now,
      isGuest: false,
    );

    if (guestRows.isNotEmpty) {
      final guest = UserRow.toModel(guestRows.first);
      user = user.copyWith(
        oceanScores: guest.oceanScores,
        oceanCompletedAt: guest.oceanCompletedAt,
        psychScore: guest.psychScore,
        psychClass: guest.psychClass,
        avatarUrl: guest.avatarUrl,
        phone: guest.phone,
        dateOfBirth: guest.dateOfBirth,
      );
    }

    await db.insert(
      AppTables.users,
      UserRow.toRow(
        user,
        passwordHash: passwordHash,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      ),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (guestRows.isNotEmpty) {
      final guestId = guestRows.first[UserRow.colId] as String;
      await db.update(
        AppTables.detectionSessions,
        {'user_id': userId},
        where: 'user_id = ?',
        whereArgs: [guestId],
      );
      await db.update(
        AppTables.dailyMoods,
        {'user_id': userId},
        where: 'user_id = ?',
        whereArgs: [guestId],
      );
      await db.update(
        AppTables.mentalScoreLog,
        {'user_id': userId},
        where: 'user_id = ?',
        whereArgs: [guestId],
      );
      await db.delete(
        AppTables.authTokens,
        where: 'user_id = ?',
        whereArgs: [guestId],
      );
      await db.delete(AppTables.users, where: 'id = ?', whereArgs: [guestId]);
    }

    final token = _generateToken(userId);
    await db.delete(AppTables.authTokens);
    await db.insert(
      AppTables.authTokens,
      AuthTokenRow.toRow(token: token, userId: userId, issuedAt: now),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await enqueue(
      entityType: SyncEntity.user,
      entityId: userId,
      operation: SyncOperation.insert,
      payloadJson: syncPayloadJson(user.toJson()),
    );

    return AuthState.authenticated(user: user, token: token);
  }

  @override
  Future<AuthState> continueAsGuest() async {
    final db = await DatabaseHelper.instance.database;
    final existing = await db.query(
      AppTables.users,
      where: 'is_guest = 1',
      limit: 1,
    );

    late UserModel user;
    if (existing.isNotEmpty) {
      user = UserRow.toModel(existing.first);
    } else {
      final now = DateTime.now();
      user = UserModel(
        id: 'guest_local',
        fullName: 'Tamu',
        email: guestEmail,
        createdAt: now,
        isGuest: true,
      );
      await db.insert(
        AppTables.users,
        UserRow.toRow(
          user,
          passwordHash: _hashPassword('guest', 'guest_salt_fixed1'),
          createdAt: now.millisecondsSinceEpoch,
          updatedAt: now.millisecondsSinceEpoch,
          isDirty: false,
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final token = _generateToken(user.id);
    await db.delete(AppTables.authTokens);
    await db.insert(
      AppTables.authTokens,
      AuthTokenRow.toRow(
        token: token,
        userId: user.id,
        issuedAt: DateTime.now(),
      ),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return AuthState.authenticated(user: user, token: token);
  }

  @override
  Future<void> logout() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(AppTables.authTokens);
  }

  @override
  Future<AuthState> getCurrentAuth() async {
    final db = await DatabaseHelper.instance.database;
    final tokenRows = await db.query(
      AppTables.authTokens,
      orderBy: '${AuthTokenRow.colIssuedAt} DESC',
      limit: 1,
    );
    if (tokenRows.isEmpty) return AuthState.initial();
    final userId = tokenRows.first[AuthTokenRow.colUserId] as String;
    final userRows = await db.query(
      AppTables.users,
      where: '${UserRow.colId} = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (userRows.isEmpty) return AuthState.initial();
    final user = UserRow.toModel(userRows.first);
    final token = tokenRows.first[AuthTokenRow.colToken] as String;
    return AuthState.authenticated(user: user, token: token);
  }

  @override
  Future<void> forgotPassword(String email) async {
    // Offline-first: no email transport.
  }

  @override
  Future<UserModel?> updateUserAssessment(UserModel user) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      AppTables.users,
      where: 'id = ?',
      whereArgs: [user.id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final hash = rows.first[UserRow.colPasswordHash] as String;
    await db.update(
      AppTables.users,
      UserRow.toRow(user, passwordHash: hash, isDirty: !user.isGuest),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    if (user.psychScore != null) {
      await db.insert(AppTables.mentalScoreLog, {
        'user_id': user.id,
        'at_ms': DateTime.now().millisecondsSinceEpoch,
        'score': user.psychScore,
        'reason': 'assessment',
      });
    }
    if (!user.isGuest) {
      await enqueue(
        entityType: SyncEntity.user,
        entityId: user.id,
        operation: SyncOperation.update,
        payloadJson: syncPayloadJson(user.toJson()),
      );
    }
    return user;
  }

  @override
  Future<void> deleteAccount(String userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete(
        AppTables.authTokens,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      await txn.delete(
        AppTables.syncQueue,
        where: 'entity_type != ?',
        whereArgs: [SyncEntity.accountDelete],
      );
      await txn.delete(AppTables.users, where: 'id = ?', whereArgs: [userId]);
    });
  }

  @override
  Future<void> resetUserData(String userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete(
        AppTables.detectionResults,
        where:
            'session_id IN (SELECT id FROM ${AppTables.detectionSessions} WHERE user_id = ?)',
        whereArgs: [userId],
      );
      await txn.delete(
        AppTables.detectionSessions,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      await txn.delete(
        AppTables.dailyMoods,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      await txn.delete(
        AppTables.mentalScoreLog,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      await txn.delete(
        AppTables.syncQueue,
        where: 'synced_at IS NULL AND entity_type IN (?, ?)',
        whereArgs: [SyncEntity.detectionSession, SyncEntity.dailyMood],
      );
      await txn.update(
        AppTables.users,
        {
          'ocean_o': null,
          'ocean_c': null,
          'ocean_e': null,
          'ocean_a': null,
          'ocean_n': null,
          'ocean_completed_at': null,
          'psych_score': null,
          'psych_class': null,
          'is_dirty': 0,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
    });
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt$password');
    final digest = sha256.convert(bytes);
    return '$salt\$$digest';
  }

  String _extractSalt(String storedHash) {
    final parts = storedHash.split('\$');
    return parts.isNotEmpty ? parts.first : '';
  }

  String _generateSalt() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rand = (now ^ (now << 17) ^ (now >> 3)).abs();
    final bytes = utf8.encode('fem_$rand');
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  String _generateToken(String userId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final bytes = utf8.encode('$userId\$$now');
    return sha256.convert(bytes).toString();
  }
}
