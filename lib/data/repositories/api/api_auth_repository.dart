import 'package:fem_psychmonitor/data/models/auth_state.dart';
import 'package:fem_psychmonitor/data/repositories/auth_repository.dart';
import 'package:http/http.dart' as http;

/// HTTP-backed [AuthRepository] scaffold. Calls are guarded by [baseUrl]: when
/// no live base URL is configured (current state — no server running), every
/// method is a no-op / returns an unauthenticated state, so the offline-first
/// SQLite layer remains the source of truth.
///
/// When a real server is stood up, set [baseUrl] and these stubs become live.
class ApiAuthRepository extends AuthRepository {
  ApiAuthRepository({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl,
        _client = client ?? http.Client();

  /// When null, the API layer is disabled (offline-only mode).
  final String? baseUrl;
  final http.Client _client;

  bool get _isEnabled => baseUrl != null && baseUrl!.isNotEmpty;

  @override
  Future<AuthState> login(String email, String password) async {
    if (!_isEnabled) return AuthState.initial();
    // TODO(server): POST {baseUrl}/auth/login with {email,password}; map the
    // returned token + user payload into an AuthState.
    throw UnimplementedError('ApiAuthRepository.login requires a live server');
  }

  @override
  Future<AuthState> register(
    String fullName,
    String email,
    String password,
  ) async {
    if (!_isEnabled) return AuthState.initial();
    throw UnimplementedError('ApiAuthRepository.register requires a live server');
  }

  @override
  Future<void> logout() async {
    if (!_isEnabled) return;
    // TODO(server): DELETE {baseUrl}/auth/logout (revoke token).
  }

  @override
  Future<AuthState> getCurrentAuth() async {
    if (!_isEnabled) return AuthState.initial();
    return AuthState.initial();
  }

  @override
  Future<void> forgotPassword(String email) async {
    if (!_isEnabled) return;
    // TODO(server): POST {baseUrl}/auth/forgot-password {email}.
  }

  void close() => _client.close();
}
