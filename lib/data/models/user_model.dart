class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? avatarUrl;
  final DateTime createdAt;
  final String? mbtiResult;
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
    this.mbtiResult,
    this.psychScore,
    this.psychClass,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? avatarUrl,
    DateTime? createdAt,
    String? mbtiResult,
    int? psychScore,
    String? psychClass,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      mbtiResult: mbtiResult ?? this.mbtiResult,
      psychScore: psychScore ?? this.psychScore,
      psychClass: psychClass ?? this.psychClass,
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
      'mbtiResult': mbtiResult,
      'psychScore': psychScore,
      'psychClass': psychClass,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
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
      mbtiResult: json['mbtiResult'] as String?,
      psychScore: json['psychScore'] as int?,
      psychClass: json['psychClass'] as String?,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, fullName: $fullName, email: $email)';
}
