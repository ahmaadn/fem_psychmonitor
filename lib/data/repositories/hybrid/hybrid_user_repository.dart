import 'dart:async';

import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_user_repository.dart';
import 'package:fem_psychmonitor/data/repositories/sqlite/sqlite_user_repository.dart';
import 'package:fem_psychmonitor/data/repositories/user_repository.dart';
import 'package:flutter/foundation.dart';

class HybridUserRepository extends UserRepository {
  HybridUserRepository({
    required SqliteUserRepository local,
    required ApiUserRepository remote,
    Future<void> Function()? onChanged,
  }) : _local = local,
       _remote = remote,
       _onChanged = onChanged;

  final SqliteUserRepository _local;
  final ApiUserRepository _remote;
  final Future<void> Function()? _onChanged;

  @override
  Future<UserModel> getProfile() => _local.getProfile();

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    final saved = await _local.updateProfile(user);
    if (!saved.isGuest && _remote.hasRemoteSession) {
      unawaited(_syncProfile(saved));
    }
    final callback = _onChanged;
    if (callback != null) unawaited(callback());
    return saved;
  }

  Future<void> _syncProfile(UserModel user) async {
    try {
      await _remote.syncState(user);
    } catch (error) {
      debugPrint('[remote] profile sync failed: $error');
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _local.changePassword(oldPassword, newPassword);
    if (_remote.hasRemoteSession) {
      try {
        await _remote.changePassword(oldPassword, newPassword);
      } catch (error) {
        debugPrint('[remote] password sync failed: $error');
      }
    }
  }
}
