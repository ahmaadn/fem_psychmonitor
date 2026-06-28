import 'package:fem_psychmonitor/data/models/user_model.dart';
import 'package:fem_psychmonitor/data/repositories/user_repository.dart';
import 'package:http/http.dart' as http;

/// HTTP-backed [UserRepository] scaffold. No-op until a [baseUrl] is set.
class ApiUserRepository extends UserRepository {
  ApiUserRepository({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl,
        _client = client ?? http.Client();

  final String? baseUrl;
  final http.Client _client;

  bool get _isEnabled => baseUrl != null && baseUrl!.isNotEmpty;

  @override
  Future<UserModel> getProfile() async {
    if (!_isEnabled) {
      throw StateError('ApiUserRepository disabled — no base URL configured');
    }
    // TODO(server): GET {baseUrl}/users/me
    throw UnimplementedError('ApiUserRepository.getProfile requires a live server');
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    if (!_isEnabled) return user;
    // TODO(server): PUT {baseUrl}/users/me with user.toJson()
    throw UnimplementedError('ApiUserRepository.updateProfile requires a live server');
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (!_isEnabled) return;
    // TODO(server): POST {baseUrl}/users/me/password
    throw UnimplementedError('ApiUserRepository.changePassword requires a live server');
  }

  void close() => _client.close();
}
