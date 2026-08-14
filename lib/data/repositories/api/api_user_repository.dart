import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_client.dart';
import 'package:fem_psychmonitor/data/repositories/user_repository.dart';

class ApiUserRepository extends UserRepository {
  ApiUserRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  bool get isEnabled => _api.isEnabled;
  bool get hasRemoteSession => _api.hasRemoteSession;

  @override
  Future<UserModel> getProfile() async {
    final json = await _api.requestJson('GET', '/users/me');
    return userFromServer(json['user'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    final json = await _api.requestJson(
      'PUT',
      '/users/me',
      body: {
        'fullName': user.fullName,
        'phone': user.phone,
        'dateOfBirth': user.dateOfBirth?.millisecondsSinceEpoch,
      },
    );
    return userFromServer(json['user'] as Map<String, dynamic>);
  }

  Future<UserModel> syncState(UserModel user) async {
    final json = await _api.requestJson(
      'PUT',
      '/users/me/sync',
      body: {
        'fullName': user.fullName,
        'phone': user.phone,
        'dateOfBirth': user.dateOfBirth?.millisecondsSinceEpoch,
        'oceanScores': user.oceanScores?.toMap(),
        'oceanCompletedAt': user.oceanCompletedAt?.millisecondsSinceEpoch,
        'psychScore': user.psychScore,
        'psychClass': user.psychClass,
      },
    );
    return userFromServer(json['user'] as Map<String, dynamic>);
  }

  Future<UserModel> updateAssessment(UserModel user) async {
    final scores = user.oceanScores;
    if (scores == null ||
        user.oceanCompletedAt == null ||
        user.psychScore == null ||
        user.psychClass == null) {
      return user;
    }
    final json = await _api.requestJson(
      'PUT',
      '/users/me/assessment',
      body: {
        'oceanScores': scores.toMap(),
        'oceanCompletedAt': user.oceanCompletedAt!.millisecondsSinceEpoch,
        'psychScore': user.psychScore,
        'psychClass': user.psychClass,
      },
    );
    return userFromServer(json['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _api.request(
      'POST',
      '/users/me/password',
      body: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }
}
