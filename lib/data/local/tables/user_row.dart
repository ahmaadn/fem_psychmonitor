import 'dart:convert';

import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/models/auth_state.dart';
import 'package:fem_psychmonitor/data/models/user_model.dart';

/// Row ⇄ model mappers for the `users`, `auth_tokens` and `sync_queue` tables.
class UserRow {
  UserRow._();

  static const String colId = 'id';
  static const String colFullName = 'full_name';
  static const String colEmail = 'email';
  static const String colPhone = 'phone';
  static const String colDateOfBirth = 'date_of_birth';
  static const String colAvatarUrl = 'avatar_url';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colIsDirty = 'is_dirty';
  static const String colPasswordHash = 'password_hash';
  static const String colMbtiResult = 'mbti_result';
  static const String colPsychScore = 'psych_score';
  static const String colPsychClass = 'psych_class';

  static Map<String, Object?> toRow(
    UserModel user, {
    required String passwordHash,
    int? updatedAt,
    int? createdAt,
    bool isDirty = true,
  }) {
    final now = updatedAt ?? DateTime.now().millisecondsSinceEpoch;
    return {
      colId: user.id,
      colFullName: user.fullName,
      colEmail: user.email.toLowerCase(),
      colPhone: user.phone,
      colDateOfBirth: user.dateOfBirth?.millisecondsSinceEpoch,
      colAvatarUrl: user.avatarUrl,
      colCreatedAt: createdAt ?? user.createdAt.millisecondsSinceEpoch,
      colUpdatedAt: now,
      colIsDirty: isDirty ? 1 : 0,
      colPasswordHash: passwordHash,
      colMbtiResult: user.mbtiResult,
      colPsychScore: user.psychScore,
      colPsychClass: user.psychClass,
    };
  }

  static UserModel toModel(Map<String, Object?> row) {
    return UserModel(
      id: row[colId] as String,
      fullName: row[colFullName] as String,
      email: row[colEmail] as String,
      phone: row[colPhone] as String?,
      dateOfBirth: row[colDateOfBirth] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row[colDateOfBirth] as int),
      avatarUrl: row[colAvatarUrl] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row[colCreatedAt] as int),
      mbtiResult: row[colMbtiResult] as String?,
      psychScore: row[colPsychScore] as int?,
      psychClass: row[colPsychClass] as String?,
    );
  }
}

class AuthTokenRow {
  AuthTokenRow._();

  static const String colToken = 'token';
  static const String colUserId = 'user_id';
  static const String colIssuedAt = 'issued_at';
  static const String colExpiresAt = 'expires_at';

  static Map<String, Object?> toRow({
    required String token,
    required String userId,
    required DateTime issuedAt,
    DateTime? expiresAt,
  }) {
    return {
      colToken: token,
      colUserId: userId,
      colIssuedAt: issuedAt.millisecondsSinceEpoch,
      colExpiresAt: expiresAt?.millisecondsSinceEpoch,
    };
  }

  static String tokenFromRow(Map<String, Object?> row) =>
      row[colToken] as String;
}

/// A pending sync-queue entry.
class SyncQueueEntry {
  final int? id;
  final String entityType;
  final String entityId;
  final SyncOperation operation;
  final String? payloadJson;
  final DateTime queuedAt;

  const SyncQueueEntry({
    this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.payloadJson,
    required this.queuedAt,
  });

  Map<String, Object?> toRow() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation.name,
      'payload_json': payloadJson,
      'queued_at': queuedAt.millisecondsSinceEpoch,
      'synced_at': null,
    };
  }
}

/// Convenience: serialise a model as the sync payload JSON.
String syncPayloadJson(Map<String, dynamic> json) => jsonEncode(json);

/// Builds an [AuthState] from a stored token + user (used by `getCurrentAuth`).
AuthState buildAuthedState(UserModel user, String? token) =>
    AuthState.authenticated(user: user, token: token);
