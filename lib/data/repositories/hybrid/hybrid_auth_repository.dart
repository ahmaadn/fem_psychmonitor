import 'dart:async';

import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/local/tables/user_row.dart';
import 'package:fem_psychmonitor/data/models/auth_state.dart';
import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_user_repository.dart';
import 'package:fem_psychmonitor/data/repositories/auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/sqlite/sqlite_auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class HybridAuthRepository extends AuthRepository {
  HybridAuthRepository({
    required SqliteAuthRepository local,
    required ApiAuthRepository remote,
    required ApiUserRepository remoteUser,
    Future<void> Function()? onRemoteAuthenticated,
  }) : _local = local,
       _remote = remote,
       _remoteUser = remoteUser,
       _onRemoteAuthenticated = onRemoteAuthenticated;

  final SqliteAuthRepository _local;
  final ApiAuthRepository _remote;
  final ApiUserRepository _remoteUser;
  final Future<void> Function()? _onRemoteAuthenticated;

  @override
  Future<AuthState> login(String email, String password) async {
    if (_remote.isEnabled) {
      try {
        final remoteState = await _remote.login(email, password);
        if (remoteState.user != null) {
          await _cacheRemoteUser(remoteState.user!, password);
          _triggerSync();
          return _local.login(email, password);
        }
      } catch (error) {
        debugPrint('[remote] login failed: $error');
      }
    }

    final localState = await _local.login(email, password);
    final localUser = localState.user;
    if (localUser != null && _remote.isEnabled) {
      try {
        await _remote.registerWithId(
          id: localUser.id,
          fullName: localUser.fullName,
          email: localUser.email,
          password: password,
        );
        if (localUser.hasCompletedAssessment) {
          await _remoteUser.updateAssessment(localUser);
        }
        _triggerSync();
      } catch (error) {
        debugPrint('[remote] deferred registration failed: $error');
      }
    }
    return localState;
  }

  @override
  Future<AuthState> register(
    String fullName,
    String email,
    String password,
  ) async {
    final localState = await _local.register(fullName, email, password);
    final user = localState.user;
    if (user != null && _remote.isEnabled) {
      try {
        await _remote.registerWithId(
          id: user.id,
          fullName: user.fullName,
          email: user.email,
          password: password,
        );
        if (user.hasCompletedAssessment) {
          await _remoteUser.updateAssessment(user);
        }
        _triggerSync();
      } catch (error) {
        debugPrint('[remote] register failed: $error');
      }
    }
    return localState;
  }

  @override
  Future<AuthState> continueAsGuest() => _local.continueAsGuest();

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (error) {
      debugPrint('[remote] logout failed: $error');
      await _remote.sessionStore.clearAll();
    }
    await _local.logout();
  }

  @override
  Future<AuthState> getCurrentAuth() => _local.getCurrentAuth();

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _remote.forgotPassword(email);
    } catch (error) {
      debugPrint('[remote] forgot password failed: $error');
    }
  }

  @override
  Future<UserModel?> updateUserAssessment(UserModel user) async {
    final saved = await _local.updateUserAssessment(user);
    if (saved != null && !saved.isGuest && _remote.hasRemoteSession) {
      try {
        await _remoteUser.updateAssessment(saved);
      } catch (error) {
        debugPrint('[remote] assessment sync failed: $error');
      }
    }
    return saved;
  }

  @override
  Future<void> deleteAccount(String userId) async {
    var remoteDeleteSucceeded = false;
    if (_remote.hasRemoteSession) {
      try {
        await _remote.deleteAccount(userId);
        remoteDeleteSucceeded = true;
      } catch (error) {
        debugPrint('[remote] account deletion failed: $error');
      }
    }
    if (!remoteDeleteSucceeded && _remote.hasRemoteSession) {
      await _enqueueControl(SyncEntity.accountDelete, userId);
    }
    await _local.deleteAccount(userId);
  }

  @override
  Future<void> resetUserData(String userId) async {
    var remoteResetSucceeded = false;
    if (_remote.hasRemoteSession) {
      try {
        await _remote.resetUserData(userId);
        remoteResetSucceeded = true;
      } catch (error) {
        debugPrint('[remote] data reset failed: $error');
      }
    }
    await _local.resetUserData(userId);
    if (!remoteResetSucceeded) {
      await _enqueueControl(SyncEntity.userDataReset, userId);
    }
  }

  Future<void> _enqueueControl(String entityType, String userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      AppTables.syncQueue,
      SyncQueueEntry(
        entityType: entityType,
        entityId: userId,
        operation: SyncOperation.update,
        queuedAt: DateTime.now(),
      ).toRow(),
    );
  }

  void _triggerSync() {
    final callback = _onRemoteAuthenticated;
    if (callback != null) unawaited(callback());
  }

  Future<void> _cacheRemoteUser(UserModel user, String password) async {
    final db = await DatabaseHelper.instance.database;
    final localRows = await db.query(
      AppTables.users,
      where: '${UserRow.colEmail} = ?',
      whereArgs: [user.email.toLowerCase()],
      limit: 1,
    );
    if (localRows.isNotEmpty) {
      final localUser = UserRow.toModel(localRows.first);
      final hash = localRows.first[UserRow.colPasswordHash] as String;
      if (localUser.id == user.id) {
        await db.update(
          AppTables.users,
          UserRow.toRow(user, passwordHash: hash, isDirty: false),
          where: '${UserRow.colId} = ?',
          whereArgs: [user.id],
        );
        return;
      }
      await db.transaction((txn) async {
        await txn.update(
          AppTables.users,
          {UserRow.colEmail: '${localUser.id}@migration.local'},
          where: '${UserRow.colId} = ?',
          whereArgs: [localUser.id],
        );
        await txn.insert(
          AppTables.users,
          UserRow.toRow(user, passwordHash: hash, isDirty: false),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
        for (final table in [
          AppTables.detectionSessions,
          AppTables.dailyMoods,
          AppTables.mentalScoreLog,
          AppTables.authTokens,
        ]) {
          await txn.update(
            table,
            {'user_id': user.id},
            where: 'user_id = ?',
            whereArgs: [localUser.id],
          );
        }
        await txn.delete(
          AppTables.syncQueue,
          where: 'entity_type = ? AND entity_id = ?',
          whereArgs: [SyncEntity.user, localUser.id],
        );
        await txn.delete(
          AppTables.users,
          where: '${UserRow.colId} = ?',
          whereArgs: [localUser.id],
        );
      });
      return;
    }

    final registered = await _local.register(
      user.fullName,
      user.email,
      password,
    );
    final localUser = registered.user;
    if (localUser == null) return;
    final createdRows = await db.query(
      AppTables.users,
      where: '${UserRow.colId} = ?',
      whereArgs: [localUser.id],
      limit: 1,
    );
    final hash = createdRows.first[UserRow.colPasswordHash] as String;
    await db.transaction((txn) async {
      await txn.update(
        AppTables.users,
        {UserRow.colEmail: '${localUser.id}@migration.local'},
        where: '${UserRow.colId} = ?',
        whereArgs: [localUser.id],
      );
      await txn.insert(
        AppTables.users,
        UserRow.toRow(user, passwordHash: hash, isDirty: false),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      for (final table in [
        AppTables.detectionSessions,
        AppTables.dailyMoods,
        AppTables.mentalScoreLog,
        AppTables.authTokens,
      ]) {
        await txn.update(
          table,
          {'user_id': user.id},
          where: 'user_id = ?',
          whereArgs: [localUser.id],
        );
      }
      await txn.delete(
        AppTables.syncQueue,
        where: 'entity_type = ? AND entity_id = ?',
        whereArgs: [SyncEntity.user, localUser.id],
      );
      await txn.delete(
        AppTables.users,
        where: '${UserRow.colId} = ?',
        whereArgs: [localUser.id],
      );
    });
  }
}
