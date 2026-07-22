import 'package:fem_psychmonitor/data/models/auth_state.dart';
import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/auth_repository.dart';
import 'package:http/http.dart' as http;

class ApiAuthRepository extends AuthRepository {
  ApiAuthRepository({this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String? baseUrl;
  final http.Client _client;

  bool get _isEnabled => baseUrl != null && baseUrl!.isNotEmpty;

  @override
  Future<AuthState> login(String email, String password) async {
    if (!_isEnabled) return AuthState.initial();
    throw UnimplementedError('ApiAuthRepository.login requires a live server');
  }

  @override
  Future<AuthState> register(
    String fullName,
    String email,
    String password,
  ) async {
    if (!_isEnabled) return AuthState.initial();
    throw UnimplementedError(
        'ApiAuthRepository.register requires a live server');
  }

  @override
  Future<AuthState> continueAsGuest() async {
    if (!_isEnabled) return AuthState.initial();
    throw UnimplementedError(
        'ApiAuthRepository.continueAsGuest requires a live server');
  }

  @override
  Future<void> logout() async {
    if (!_isEnabled) return;
  }

  @override
  Future<AuthState> getCurrentAuth() async {
    if (!_isEnabled) return AuthState.initial();
    return AuthState.initial();
  }

  @override
  Future<void> forgotPassword(String email) async {
    if (!_isEnabled) return;
  }

  @override
  Future<UserModel?> updateUserAssessment(UserModel user) async {
    if (!_isEnabled) return user;
    return user;
  }

  @override
  Future<void> deleteAccount(String userId) async {
    if (!_isEnabled) return;
  }

  @override
  Future<void> resetUserData(String userId) async {
    if (!_isEnabled) return;
  }

  void close() => _client.close();
}
