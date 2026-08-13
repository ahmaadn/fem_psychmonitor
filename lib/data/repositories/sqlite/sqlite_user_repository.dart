import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/sync_queue_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/local/tables/user_row.dart';
import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/user_repository.dart';

/// Offline-first user-profile repository backed by SQLite.
class SqliteUserRepository extends UserRepository with SyncQueueHelper {
  /// Asset path of the default avatar enforced when no avatar is supplied
  /// (US-20: register/profile must not require a real photo).
  static const String defaultAvatarAsset = 'assets/logo.png';

  @override
  Future<UserModel> getProfile() async {
    final db = await DatabaseHelper.instance.database;
    final tokenRows = await db.query(
      AppTables.authTokens,
      orderBy: '${AuthTokenRow.colIssuedAt} DESC',
      limit: 1,
    );
    String? userId;
    if (tokenRows.isNotEmpty) {
      userId = tokenRows.first[AuthTokenRow.colUserId] as String;
    } else {
      // Fallback: most recently created user (e.g. directly after register).
      final u = await db.query(
        AppTables.users,
        orderBy: '${UserRow.colCreatedAt} DESC',
        limit: 1,
      );
      if (u.isEmpty) {
        throw Exception('Belum ada profil pengguna');
      }
      return UserRow.toModel(u.first);
    }

    final rows = await db.query(
      AppTables.users,
      where: '${UserRow.colId} = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw Exception('Profil tidak ditemukan');
    }
    return UserRow.toModel(rows.first);
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    final db = await DatabaseHelper.instance.database;

    // US-20: enforce default avatar when none provided (no real photo required).
    final effectiveAvatar =
        (user.avatarUrl == null || user.avatarUrl!.trim().isEmpty)
            ? defaultAvatarAsset
            : user.avatarUrl;

    final updated = user.copyWith(avatarUrl: effectiveAvatar);

    // Re-read the password hash so we don't overwrite it with null.
    final existing = await db.query(
      AppTables.users,
      where: '${UserRow.colId} = ?',
      whereArgs: [user.id],
      limit: 1,
    );
    final passwordHash = existing.isEmpty
        ? ''
        : existing.first[UserRow.colPasswordHash] as String;

    await db.update(
      AppTables.users,
      UserRow.toRow(
        updated,
        passwordHash: passwordHash,
        isDirty: true,
      ),
      where: '${UserRow.colId} = ?',
      whereArgs: [user.id],
    );

    await enqueue(
      entityType: SyncEntity.user,
      entityId: user.id,
      operation: SyncOperation.update,
      payloadJson: syncPayloadJson(updated.toJson()),
    );

    return updated;
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = await getProfile();
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      AppTables.users,
      where: '${UserRow.colId} = ?',
      whereArgs: [user.id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw Exception('Pengguna tidak ditemukan');
    }
    final storedHash = rows.first[UserRow.colPasswordHash] as String;
    final salt = _extractSalt(storedHash);
    final candidateHash = _hashPassword(oldPassword, salt);
    if (candidateHash != storedHash) {
      throw Exception('Password lama salah');
    }

    final newSalt = _generateSalt();
    final newHash = _hashPassword(newPassword, newSalt);
    await db.update(
      AppTables.users,
      {
        UserRow.colPasswordHash: newHash,
        UserRow.colIsDirty: 1,
        UserRow.colUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${UserRow.colId} = ?',
      whereArgs: [user.id],
    );
  }

  String _hashPassword(String password, String salt) {
    final digest = sha256.convert(utf8.encode('$salt$password'));
    return '$salt\$$digest';
  }

  String _extractSalt(String storedHash) {
    final parts = storedHash.split('\$');
    return parts.isNotEmpty ? parts.first : '';
  }

  String _generateSalt() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rand = (now ^ (now << 17) ^ (now >> 3)).abs();
    return sha256.convert(utf8.encode('fem_$rand')).toString().substring(0, 16);
  }
}
