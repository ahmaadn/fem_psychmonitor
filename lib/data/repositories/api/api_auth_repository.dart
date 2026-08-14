import 'package:fem_psychmonitor/data/models/auth_state.dart';
import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_client.dart';
import 'package:fem_psychmonitor/data/repositories/auth_repository.dart';

class ApiAuthRepository extends AuthRepository {
  ApiAuthRepository({required ApiClient apiClient})
    : sessionStore = apiClient.sessionStore,
      _api = apiClient;

  final RemoteAuthSessionStore sessionStore;
  final ApiClient _api;

  String get baseUrl => _api.baseUrl;
  bool get isEnabled => _api.isEnabled;
  bool get hasRemoteSession => _api.hasRemoteSession;

  @override
  Future<AuthState> login(String email, String password) async {
    if (!isEnabled) return AuthState.initial();
    final json = await _api.requestJson(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
      authenticated: false,
    );
    return _authStateFrom(json);
  }

  Future<AuthState> registerWithId({
    required String id,
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (!isEnabled) return AuthState.initial();
    final json = await _api.requestJson(
      'POST',
      '/auth/register',
      body: {
        'id': id,
        'fullName': fullName,
        'email': email,
        'password': password,
      },
      authenticated: false,
    );
    return _authStateFrom(json);
  }

  @override
  Future<AuthState> register(
    String fullName,
    String email,
    String password,
  ) async {
    if (!isEnabled) return AuthState.initial();
    final json = await _api.requestJson(
      'POST',
      '/auth/register',
      body: {'fullName': fullName, 'email': email, 'password': password},
      authenticated: false,
    );
    return _authStateFrom(json);
  }

  Future<AuthState> _authStateFrom(Map<String, dynamic> json) async {
    final accessToken = json['accessToken'] as String;
    final refreshToken = json['refreshToken'] as String;
    await sessionStore.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    return AuthState.authenticated(
      user: _userFromServer(json['user'] as Map<String, dynamic>),
      token: accessToken,
    );
  }

  @override
  Future<AuthState> continueAsGuest() async => AuthState.initial();

  @override
  Future<void> logout() async {
    if (isEnabled && hasRemoteSession) {
      await _api.request('POST', '/auth/logout');
    }
    await sessionStore.clearAll();
  }

  @override
  Future<AuthState> getCurrentAuth() async {
    if (!isEnabled || !hasRemoteSession) return AuthState.initial();
    final json = await _api.requestJson('GET', '/users/me');
    return AuthState.authenticated(
      user: _userFromServer(json['user'] as Map<String, dynamic>),
      token: sessionStore.accessToken,
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    if (!isEnabled) return;
    await _api.request(
      'POST',
      '/auth/forgot-password',
      body: {'email': email},
      authenticated: false,
    );
  }

  @override
  Future<UserModel?> updateUserAssessment(UserModel user) async {
    if (!isEnabled || !hasRemoteSession || user.oceanScores == null) {
      return user;
    }
    final json = await _api.requestJson(
      'PUT',
      '/users/me/assessment',
      body: {
        'oceanScores': user.oceanScores!.toMap(),
        'oceanCompletedAt': user.oceanCompletedAt?.millisecondsSinceEpoch,
        'psychScore': user.psychScore,
        'psychClass': user.psychClass,
      },
    );
    return _userFromServer(json['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAccount(String userId) async {
    if (!isEnabled || !hasRemoteSession) return;
    await _api.request('DELETE', '/users/me');
    await sessionStore.clearAll();
  }

  @override
  Future<void> resetUserData(String userId) async {
    if (!isEnabled || !hasRemoteSession) return;
    await _api.request('POST', '/users/me/reset');
  }

  void close() => _api.close();
}

UserModel userFromServer(Map<String, dynamic> json) => _userFromServer(json);

UserModel _userFromServer(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  for (final key in ['dateOfBirth', 'createdAt', 'oceanCompletedAt']) {
    final value = normalized[key];
    if (value is num) {
      normalized[key] = DateTime.fromMillisecondsSinceEpoch(
        value.toInt(),
      ).toIso8601String();
    }
  }
  return UserModel.fromJson(normalized);
}
