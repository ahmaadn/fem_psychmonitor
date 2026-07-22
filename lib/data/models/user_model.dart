import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isGuest;
  final OceanScores? oceanScores;
  final DateTime? oceanCompletedAt;
  final int? psychScore;
  final String? psychClass;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.avatarUrl,
    required this.createdAt,
    this.isGuest = false,
    this.oceanScores,
    this.oceanCompletedAt,
    this.psychScore,
    this.psychClass,
  });

  bool get hasCompletedAssessment =>
      oceanScores != null && psychScore != null;

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isGuest,
    OceanScores? oceanScores,
    DateTime? oceanCompletedAt,
    int? psychScore,
    String? psychClass,
    bool clearOcean = false,
    bool clearPsych = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isGuest: isGuest ?? this.isGuest,
      oceanScores: clearOcean ? null : (oceanScores ?? this.oceanScores),
      oceanCompletedAt:
          clearOcean ? null : (oceanCompletedAt ?? this.oceanCompletedAt),
      psychScore: clearPsych ? null : (psychScore ?? this.psychScore),
      psychClass: clearPsych ? null : (psychClass ?? this.psychClass),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'isGuest': isGuest,
      'oceanScores': oceanScores?.toMap(),
      'oceanCompletedAt': oceanCompletedAt?.toIso8601String(),
      'psychScore': psychScore,
      'psychClass': psychClass,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    OceanScores? ocean;
    final rawOcean = json['oceanScores'];
    if (rawOcean is Map<String, dynamic>) {
      ocean = OceanScores.fromMap(rawOcean);
    }
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isGuest: json['isGuest'] as bool? ?? false,
      oceanScores: ocean,
      oceanCompletedAt: json['oceanCompletedAt'] != null
          ? DateTime.parse(json['oceanCompletedAt'] as String)
          : null,
      psychScore: json['psychScore'] as int?,
      psychClass: json['psychClass'] as String?,
    );
  }
}
